import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Every symptom now has a name, a one-line summary, and a list of
// bullet points with more detail.
class Symptom {
  final String name;
  final String summary;
  final List<String> points;

  const Symptom({
    required this.name,
    required this.summary,
    required this.points,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'] as String,
      summary: json['summary'] as String,
      points: (json['points'] as List<dynamic>)
          .map((point) => point as String)
          .toList(),
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
                // The list row now previews the summary, not a bullet.
                subtitle: Text(
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
            Text(
              symptom.summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
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