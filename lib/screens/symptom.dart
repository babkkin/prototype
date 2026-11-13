import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One question in a symptom's guided assessment (assets/symptoms.json).
///
/// [field] says which Symptoms column the answer is saved into:
/// character, onset, location, duration, severity, pattern, associated.
/// Several steps may share a field; their answers are combined.
class SymptomStep {
  final String? id;
  final String field;
  final String label;
  final String question;
  final String hint;

  /// single | multi | scale | text
  final String type;
  final List<String> options;

  /// Step is only asked when the step with this id has one of [showIfAnyOf].
  final String? showIfStep;
  final List<String> showIfAnyOf;

  const SymptomStep({
    this.id,
    required this.field,
    required this.label,
    required this.question,
    this.hint = '',
    this.type = 'single',
    this.options = const [],
    this.showIfStep,
    this.showIfAnyOf = const [],
  });

  factory SymptomStep.fromJson(Map<String, dynamic> json) {
    final showIf = json['showIf'] as Map<String, dynamic>?;
    return SymptomStep(
      id: json['id'] as String?,
      field: json['field'] as String,
      label: (json['label'] as String?) ?? (json['field'] as String),
      question: json['question'] as String,
      hint: (json['hint'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'single',
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      showIfStep: showIf?['step'] as String?,
      showIfAnyOf: (showIf?['anyOf'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// A symptom with its guided questions. The summary and points are
/// optional: the reference PDFs do not include them.
class Symptom {
  final String name;
  final String group;
  final String summary;
  final List<String> points;
  final List<SymptomStep> steps;
  final String followUp;
  final String emergencyWarning;
  final List<String> sources;

  const Symptom({
    required this.name,
    this.group = '',
    this.summary = '',
    this.points = const [],
    this.steps = const [],
    this.followUp = '',
    this.emergencyWarning = '',
    this.sources = const [],
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) => (json[key] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    return Symptom(
      name: json['name'] as String,
      group: (json['group'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      points: list('points'),
      steps: (json['steps'] as List<dynamic>? ?? const [])
          .map((e) => SymptomStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      followUp: (json['followUp'] as String?) ?? '',
      emergencyWarning: (json['emergencyWarning'] as String?) ?? '',
      sources: list('sources'),
    );
  }
}

// Reads assets/symptoms.json and turns it into a List<Symptom>.
Future<List<Symptom>> loadSymptoms() async {
  final jsonString = await rootBundle.loadString('assets/symptoms.json');
  final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

  return jsonList
      .map((item) => Symptom.fromJson(item as Map<String, dynamic>))
      .toList();
}

// --- SCREEN 1: the list of symptoms ---
class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({super.key});

  @override
  State<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  late final Future<List<Symptom>> _symptomsFuture;

  @override
  void initState() {
    super.initState();
    _symptomsFuture = loadSymptoms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptoms')),
      body: FutureBuilder<List<Symptom>>(
        future: _symptomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }

          final symptoms = snapshot.data!;

          return ListView.builder(
            itemCount: symptoms.length,
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              return ListTile(
                title: Text(symptom.name),
                // The list row previews the summary, not a bullet.
                subtitle: symptom.summary.isEmpty
                    ? null
                    : Text(
                        symptom.summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SymptomDetailScreen(symptom: symptom),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --- SCREEN 2: header, summary sentence, then bulleted details ---
class SymptomDetailScreen extends StatelessWidget {
  final Symptom symptom;

  const SymptomDetailScreen({super.key, required this.symptom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(symptom.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (symptom.summary.isNotEmpty) ...[
              Text(
                symptom.summary,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            for (final point in symptom.points) _BulletPoint(text: point),
          ],
        ),
      ),
    );
  }
}

// A small reusable "• text" row for one bullet point.
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 16, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}