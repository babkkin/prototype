import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart';
import 'symptom.dart' as reference;

// =====================================================================
// GUIDED SYMPTOM TRACKER (COLDSPA)
//
//   SymptomPickerList     ->  symptoms from assets/symptoms.json,
//                             shown in the journal
//   _SymptomWizardScreen  ->  one question per screen (the questions come
//                             from each symptom's "steps" in the JSON),
//                             then a "recorded" summary
//
// Every step names the Symptoms column it is saved into (no migration):
//   character / onset / location / duration / severity / pattern /
//   associated -> associatedFactors
// When several steps share a column their answers are joined as
// "Label: answer; Label: answer". The symptom name is added to character.
// =====================================================================

/// Added as the last option of a question that has no "Other" of its own.
/// Picking any "Other" option shows a text box; if the box is left empty
/// the answer is saved as "Not sure".
const String _kOther = 'Other / Not sure';

bool _isOther(String option) {
  final o = option.trim().toLowerCase();
  return o == 'other' || o == 'others' || option == _kOther;
}

/// "None", "No other symptoms", "Nothing makes it better" ... cannot be
/// combined with other choices in a multi-select question.
bool _isExclusive(String option) {
  final o = option.trim().toLowerCase();
  return o == 'none' || o.startsWith('no ') || o.startsWith('nothing');
}

const _hintSingle = 'Choose the option that best fits.';
const _hintMulti = 'You can select more than one if needed.';

// =====================================================================
// SYMPTOM LIST (embedded in the journal)
// =====================================================================

class SymptomPickerList extends StatelessWidget {
  final Profile profile;

  /// The symptoms from assets/symptoms.json, shown in file order.
  final List<reference.Symptom> symptoms;
  final bool loadFailed;

  /// Opens the reference information (sources, follow-up tools) for a symptom.
  final void Function(reference.Symptom symptom)? onInfo;

  const SymptomPickerList({
    super.key,
    required this.profile,
    required this.symptoms,
    this.loadFailed = false,
    this.onInfo,
  });

  Future<void> _open(BuildContext context, reference.Symptom symptom) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _SymptomWizardScreen(profile: profile, symptom: symptom),
      ),
    );
  }

  Widget _tile(BuildContext context, reference.Symptom symptom) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () => _open(context, symptom),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _IconBadge(icon: Icons.healing, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (symptom.summary.trim().isNotEmpty)
                        Text(
                          symptom.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (onInfo != null)
                  IconButton(
                    tooltip: 'About ${symptom.name}',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () => onInfo!(symptom),
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loadFailed)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Unable to load the symptom list.'),
          )
        else if (symptoms.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('No symptoms available.'),
          ),
        for (final symptom in symptoms) _tile(context, symptom),
      ],
    );
  }
}

// =====================================================================
// SCREEN 2: QUESTIONS, ONE PER PAGE
// =====================================================================

class _SymptomWizardScreen extends StatefulWidget {
  final Profile profile;
  final reference.Symptom symptom;

  const _SymptomWizardScreen({
    required this.profile,
    required this.symptom,
  });

  @override
  State<_SymptomWizardScreen> createState() => _SymptomWizardScreenState();
}

class _SymptomWizardScreenState extends State<_SymptomWizardScreen> {
  // Answers are keyed by the step's position in the JSON list, because
  // several steps can share a column (and a label).
  final Map<int, Set<String>> _selected = {};
  final Map<int, int> _scale = {};
  final Map<int, TextEditingController> _controllers = {};

  /// Position (in [_visible]) of the question on screen.
  int _index = 0;
  bool _saving = false;
  bool _saved = false;
  List<(String, String)> _summary = const [];
  bool _mentionedSelfHarm = false;

  reference.Symptom get _def => widget.symptom;
  List<reference.SymptomStep> get _all => _def.steps;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _all.length; i++) {
      _selected[i] = {};
      _controllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Indexes of the questions that apply to the answers given so far.
  List<int> get _visible {
    final result = <int>[];
    for (var i = 0; i < _all.length; i++) {
      final s = _all[i];
      if (s.showIfStep != null) {
        final dep = _all.indexWhere((x) => x.id == s.showIfStep);
        final chosen = dep < 0 ? const <String>{} : _selected[dep]!;
        if (!chosen.any(s.showIfAnyOf.contains)) continue;
      }
      result.add(i);
    }
    return result;
  }

  int get _current {
    final v = _visible;
    return v[_index < v.length ? _index : v.length - 1];
  }

  List<String> _optionsFor(reference.SymptomStep s) => [
        ...s.options,
        if (!s.options.any(_isOther)) _kOther,
      ];

  /// The saved text for one question, or null while it is unanswered.
  /// Text questions are optional and return '' when left blank.
  String? _answerFor(int i) {
    final step = _all[i];

    if (step.type == 'scale') {
      final n = _scale[i];
      return n == null ? null : '$n/10';
    }

    if (step.type == 'text') return _controllers[i]!.text.trim();

    final chosen = _selected[i]!;
    if (chosen.isEmpty) return null;

    final parts = <String>[];
    for (final o in _optionsFor(step)) {
      if (!chosen.contains(o)) continue;
      if (_isOther(o)) {
        final text = _controllers[i]!.text.trim();
        parts.add(text.isEmpty ? 'Not sure' : text);
      } else {
        parts.add(o);
      }
    }

    return parts.join(', ');
  }

  bool get _canContinue => _answerFor(_current) != null;

  void _toggle(int i, String option) {
    final step = _all[i];

    setState(() {
      final set = _selected[i]!;

      if (step.type != 'multi') {
        set
          ..clear()
          ..add(option);
        return;
      }

      if (set.contains(option)) {
        set.remove(option);
        return;
      }

      if (_isExclusive(option)) {
        set.clear();
      } else {
        set.removeWhere(_isExclusive);
      }
      set.add(option);
    });
  }

  Future<void> _next() async {
    if (!_canContinue || _saving) return;
    FocusScope.of(context).unfocus();

    if (_index < _visible.length - 1) {
      setState(() => _index++);
      return;
    }

    await _save();
  }

  void _back() {
    if (_index > 0) setState(() => _index--);
  }

  Iterable<(String, String, String)> _answered() sync* {
    for (final i in _visible) {
      final a = _answerFor(i);
      if (a == null || a.isEmpty) continue;
      yield (_all[i].field, _all[i].label, a);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final dao = context.read<AppDatabase>().symptomsDao;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final answered = [for (final (f, l, v) in _answered()) (f, l, v)];
      String col(String field) {
        final mine = [
          for (final (f, l, v) in answered)
            if (f == field) (l, v),
        ];
        if (mine.isEmpty) {
          return field == 'location' ? 'Not applicable' : 'Not recorded';
        }
        if (mine.length == 1) return mine.first.$2;
        return mine.map((e) => '${e.$1}: ${e.$2}').join('; ');
      }

      await dao.insertSymptom(
        SymptomsCompanion.insert(
          profileId: widget.profile.id,
          character: '${_def.name} - ${col('character')}',
          onset: col('onset'),
          location: col('location'),
          duration: col('duration'),
          severity: col('severity'),
          pattern: col('pattern'),
          associatedFactors: col('associated'),
        ),
      );

      if (!mounted) return;

      setState(() {
        _summary = [for (final (_, l, v) in answered) (l, v)];
        _mentionedSelfHarm = answered.any(
          (e) => e.$3.toLowerCase().contains('thoughts of death'),
        );
        _saving = false;
        _saved = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to save symptom: $e')),
      );
    }
  }

  // ---- UI ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_saved) return _buildDone(context);

    final visible = _visible;
    final i = _current;
    final step = _all[i];
    final isLast = _index == visible.length - 1;
    final hint = step.hint.isNotEmpty
        ? step.hint
        : switch (step.type) {
            'multi' => _hintMulti,
            'scale' => 'Tap a number on the scale from 0 to 10.',
            'text' => 'Optional. Leave blank to skip.',
            _ => _hintSingle,
          };

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_def.name),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_index + 1} of ${visible.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_index + 1) / visible.length,
              minHeight: 4,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
              child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_index == 0) _headerCard(context),
                    if (_index == 0 && _def.emergencyWarning.trim().isNotEmpty)
                      _emergencyBanner(context),
                    Text(
                      '${_index + 1}. ${step.question}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (step.type == 'scale')
                      _severityScale(context, i)
                    else if (step.type == 'text')
                      TextField(
                        controller: _controllers[i],
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Type here (optional)',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      ..._optionList(context, i),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canContinue && !_saving ? _next : null,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isLast ? 'Save' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emergencyBanner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.emergency_outlined,
            color: scheme.onErrorContainer,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _def.emergencyWarning,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _IconBadge(
            icon: Icons.healing,
            color: Theme.of(context).colorScheme.primary,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _def.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Please answer a few questions to help us understand '
                  'this symptom better.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _optionList(BuildContext context, int i) {
    final all = _optionsFor(_all[i]);
    final chosen = _selected[i]!;

    return [
      for (final option in all) _optionTile(context, i, option),
      if (chosen.any(_isOther))
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: TextField(
            controller: _controllers[i],
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Describe it, or leave blank if not sure',
              border: OutlineInputBorder(),
            ),
          ),
        ),
    ];
  }

  Widget _optionTile(BuildContext context, int i, String option) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selected[i]!.contains(option);

    final IconData icon = _all[i].type == 'multi'
        ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
        : (selected
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: () => _toggle(i, option),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(option)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _severityScale(BuildContext context, int i) {
    final scheme = Theme.of(context).colorScheme;
    final value = _scale[i];

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var n = 0; n <= 10; n++)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _scale[i] = n),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value == n ? scheme.primary : scheme.surface,
                    border: Border.all(
                      color: value == n
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    '$n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          value == n ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          value == null ? '- / 10' : '$value / 10',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Not bothersome', style: TextStyle(fontSize: 12)),
            Text('Worst imaginable', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_def.name} recorded!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your response has been saved.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final (label, value) in _summary)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    '$label:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(child: Text(value)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_mentionedSelfHarm) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 20, color: scheme.onErrorContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Thoughts of death or self-harm need prompt '
                              'attention. Please contact a doctor, a crisis '
                              'line, or local emergency services right away '
                              'if there is any danger.',
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tip: you can report more symptoms, or review '
                            'your history anytime in the Symptom Journal.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Back to symptom list'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconBadge({
    required this.icon,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}
