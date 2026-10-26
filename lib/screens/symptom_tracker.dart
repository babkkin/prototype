import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart';
import 'symptom.dart' as reference;

// =====================================================================
// GUIDED SYMPTOM TRACKER (COLDSPA)
//
//   SymptomPickerList     ->  symptoms from assets/symptoms.json,
//                             shown in the journal
//   _SymptomWizardScreen  ->  one COLDSPA question per screen, then a
//                             "recorded" summary
//
// Answers are saved into the existing Symptoms table (no migration):
//   character          "<Symptom> - <how it feels>"
//   onset / location / duration / severity   (as answered)
//   pattern            "Occurs: <when>. Better/worse: <what changes it>"
//   associatedFactors  other symptoms
// =====================================================================

/// Last option of every question. Picking it shows a text box; if the
/// box is left empty the answer is saved as "Not sure".
const String _kOther = 'Other / Not sure';

// ---------------------------------------------------------------------
// SYMPTOM (names come from assets/symptoms.json)
// ---------------------------------------------------------------------

const _defaultLocations = [
  'Head',
  'Neck',
  'Chest',
  'Stomach area',
  'Back',
  'Arms or legs',
  'Joints (e.g., knees, shoulders)',
  'Whole body',
];

const _defaultCharacters = [
  'Aching, like sore muscles',
  'Sharp, like being pricked or stabbed',
  'Burning, like a hot sensation',
  'Throbbing, like a pulsing pain',
  'Dull, like a constant ache',
  'Pressure or tightness',
  'Tingling or numbness',
  'Weak or tired feeling',
];

const _onsetOptions = [
  'Just now',
  'Earlier today',
  'Yesterday',
  '2 to 3 days ago',
  'About a week ago',
  'More than a week ago',
  'More than a month ago',
];

const _durationOptions = [
  'A few seconds',
  'A few minutes',
  'Several hours',
  'It comes and goes throughout the day',
  'It does not go away',
];

const _patternOptions = [
  'In the morning',
  'At night',
  'When moving or doing activities',
  'After eating',
  'Any time, without a clear pattern',
];

const _modifierOptions = [
  'Gets worse when moving',
  'Gets better with rest',
  'Gets worse after eating',
  'Gets better after medication',
  'Nothing seems to help',
];

const _associatedOptions = [
  'Fever',
  'Nausea or vomiting',
  'Dizziness',
  'Shortness of breath',
  'Tiredness',
  'Sweating',
  'Loss of appetite',
  'Cough',
  'Headache',
  'No other symptoms',
];

const _defaultLocationQuestion = 'Which part of the body is affected?';

class _SymptomDef {
  final String name;
  final IconData icon;
  final Color color;

  /// When set, the location question is skipped and this is saved.
  final String? fixedLocation;
  final String locationQuestion;
  final List<String> locationOptions;
  final List<String> characterOptions;
  final List<String> patternOptions;
  final List<String> modifierOptions;
  final List<String> associatedOptions;

  const _SymptomDef({
    required this.name,
    required this.icon,
    required this.color,
    this.fixedLocation,
    this.locationQuestion = _defaultLocationQuestion,
    this.locationOptions = _defaultLocations,
    this.characterOptions = _defaultCharacters,
    this.patternOptions = _patternOptions,
    this.modifierOptions = _modifierOptions,
    this.associatedOptions = _associatedOptions,
  });

  /// Uses the symptom's own COLDSPA choices from assets/symptoms.json where
  /// it has them, and the shared generic choices for anything it leaves out.
  factory _SymptomDef.fromReference(reference.Symptom s, Color color) {
    final c = s.coldspa;

    List<String> pick(List<String>? custom, List<String> fallback) =>
        (custom == null || custom.isEmpty) ? fallback : custom;

    return _SymptomDef(
      name: s.name,
      icon: Icons.healing,
      color: color,
      fixedLocation: c?.fixedLocation,
      locationQuestion: c?.locationQuestion ?? _defaultLocationQuestion,
      locationOptions: pick(c?.location, _defaultLocations),
      characterOptions: pick(c?.character, _defaultCharacters),
      patternOptions: pick(c?.pattern, _patternOptions),
      modifierOptions: pick(c?.modifiers, _modifierOptions),
      associatedOptions: pick(c?.associated, _associatedOptions),
    );
  }
}

// ---------------------------------------------------------------------
// STEPS
// ---------------------------------------------------------------------

class _Step {
  final String key;
  final String question;
  final String hint;
  final List<String> options;
  final bool multi;

  /// Options that cannot be combined with any other (e.g. "None").
  final Set<String> exclusive;
  final bool isSeverity;

  const _Step({
    required this.key,
    required this.question,
    this.hint = '',
    this.options = const [],
    this.multi = false,
    this.exclusive = const {},
    this.isSeverity = false,
  });
}

const _hintSingle = 'Choose the option that best fits.';
const _hintMulti = 'You can select more than one if needed.';

/// Tailored lists in symptoms.json don't need to repeat the "none of these"
/// option; it is added here so it is always available.
List<String> _withTail(List<String> options, String tail) =>
    options.contains(tail) ? options : [...options, tail];

List<_Step> _stepsFor(_SymptomDef s) => [
      if (s.fixedLocation == null)
        _Step(
          key: 'location',
          question: s.locationQuestion,
          hint: _hintMulti,
          options: s.locationOptions,
          multi: true,
        ),
      _Step(
        key: 'character',
        question: 'What does it feel like?',
        hint: 'Choose the description that best fits.',
        options: s.characterOptions,
      ),
      const _Step(
        key: 'onset',
        question: 'When did it start?',
        hint: _hintSingle,
        options: _onsetOptions,
      ),
      const _Step(
        key: 'duration',
        question: 'How long does it last?',
        hint: _hintSingle,
        options: _durationOptions,
      ),
      const _Step(
        key: 'severity',
        question: 'How bad is it?',
        hint: 'Tap a number on the scale from 0 to 10.',
        isSeverity: true,
      ),
      _Step(
        key: 'pattern',
        question: 'When does it usually happen?',
        hint: _hintSingle,
        options: s.patternOptions,
      ),
      _Step(
        key: 'modifiers',
        question: 'What makes it better or worse?',
        hint: _hintMulti,
        options: _withTail(s.modifierOptions, 'Nothing seems to help'),
        multi: true,
        exclusive: {'Nothing seems to help'},
      ),
      _Step(
        key: 'associated',
        question: 'Do you have other symptoms with it?',
        hint: _hintMulti,
        options: _withTail(s.associatedOptions, 'No other symptoms'),
        multi: true,
        exclusive: {'No other symptoms'},
      ),
    ];

// =====================================================================
// SYMPTOM LIST (embedded in the journal)
// =====================================================================

class SymptomPickerList extends StatelessWidget {
  final Profile profile;

  /// The symptoms from assets/symptoms.json, shown in file order.
  final List<reference.Symptom> symptoms;
  final bool loadFailed;

  /// Optional line shown above the list (e.g. which filter is applied).
  final String? note;

  /// Opens the reference information (summary and points) for a symptom.
  final void Function(reference.Symptom symptom)? onInfo;

  const SymptomPickerList({
    super.key,
    required this.profile,
    required this.symptoms,
    this.loadFailed = false,
    this.note,
    this.onInfo,
  });

  Future<void> _open(BuildContext context, _SymptomDef def) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _SymptomWizardScreen(profile: profile, symptom: def),
      ),
    );
  }

  Future<void> _askCustom(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CustomSymptomDialog(),
    );
    if (name == null || !context.mounted) return;

    await _open(
      context,
      _SymptomDef(
        name: name,
        icon: Icons.edit_note,
        color: Theme.of(context).colorScheme.primary,
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
          onTap: () => _open(
            context,
            _SymptomDef.fromReference(symptom, scheme.primary),
          ),
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
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(note!, style: const TextStyle(fontSize: 12)),
          ),
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
        OutlinedButton.icon(
          onPressed: () => _askCustom(context),
          icon: const Icon(Icons.edit_note),
          label: const Text('Other symptom (type your own)'),
        ),
      ],
    );
  }
}

class _CustomSymptomDialog extends StatefulWidget {
  const _CustomSymptomDialog();

  @override
  State<_CustomSymptomDialog> createState() => _CustomSymptomDialogState();
}

class _CustomSymptomDialogState extends State<_CustomSymptomDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Which symptom?'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Type the symptom'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }
}

// =====================================================================
// SCREEN 2: QUESTIONS, ONE PER PAGE
// =====================================================================

class _SymptomWizardScreen extends StatefulWidget {
  final Profile profile;
  final _SymptomDef symptom;

  const _SymptomWizardScreen({
    required this.profile,
    required this.symptom,
  });

  @override
  State<_SymptomWizardScreen> createState() => _SymptomWizardScreenState();
}

class _SymptomWizardScreenState extends State<_SymptomWizardScreen> {
  late final List<_Step> _steps;
  final Map<String, Set<String>> _selected = {};
  final Map<String, TextEditingController> _otherControllers = {};

  int _index = 0;
  int? _severity;
  bool _saving = false;
  bool _saved = false;
  List<(String, String)> _summary = const [];

  _SymptomDef get _def => widget.symptom;
  _Step get _step => _steps[_index];

  @override
  void initState() {
    super.initState();
    _steps = _stepsFor(widget.symptom);
    for (final s in _steps) {
      if (s.isSeverity) continue;
      _selected[s.key] = {};
      _otherControllers[s.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _otherControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// The saved text for one step, or null while it is unanswered.
  String? _answerFor(_Step step) {
    if (step.isSeverity) {
      return _severity == null ? null : '$_severity/10';
    }

    final chosen = _selected[step.key]!;
    if (chosen.isEmpty) return null;

    final parts = <String>[
      for (final o in step.options)
        if (chosen.contains(o)) o,
    ];

    if (chosen.contains(_kOther)) {
      final text = _otherControllers[step.key]!.text.trim();
      parts.add(text.isEmpty ? 'Not sure' : text);
    }

    return parts.join(', ');
  }

  bool get _canContinue => _answerFor(_step) != null;

  void _toggle(_Step step, String option) {
    setState(() {
      final set = _selected[step.key]!;

      if (!step.multi) {
        set
          ..clear()
          ..add(option);
        return;
      }

      if (set.contains(option)) {
        set.remove(option);
        return;
      }

      if (step.exclusive.contains(option)) {
        set.clear();
      } else {
        set.removeWhere(step.exclusive.contains);
      }
      set.add(option);
    });
  }

  Future<void> _next() async {
    if (!_canContinue || _saving) return;
    FocusScope.of(context).unfocus();

    if (_index < _steps.length - 1) {
      setState(() => _index++);
      return;
    }

    await _save();
  }

  void _back() {
    if (_index > 0) setState(() => _index--);
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final dao = context.read<AppDatabase>().symptomsDao;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final a = {for (final s in _steps) s.key: _answerFor(s)!};

      await dao.insertSymptom(
        SymptomsCompanion.insert(
          profileId: widget.profile.id,
          character: '${_def.name} - ${a['character']}',
          onset: a['onset']!,
          location: _def.fixedLocation ?? a['location']!,
          duration: a['duration']!,
          severity: a['severity']!,
          pattern:
              'Occurs: ${a['pattern']}. Better/worse: ${a['modifiers']}',
          associatedFactors: a['associated']!,
        ),
      );

      if (!mounted) return;

      setState(() {
        _summary = [
          if (_def.fixedLocation == null) ('Location', a['location']!),
          ('Feels like', a['character']!),
          ('Started', a['onset']!),
          ('Duration', a['duration']!),
          ('Severity', a['severity']!),
          ('Occurs', a['pattern']!),
          ('Better / worse', a['modifiers']!),
          ('Other symptoms', a['associated']!),
        ];
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

    final step = _step;
    final isLast = _index == _steps.length - 1;

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
                  '${_index + 1} of ${_steps.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_index + 1) / _steps.length,
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
                    Text(
                      '${_index + 1}. ${step.question}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.hint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (step.isSeverity)
                      _severityScale(context)
                    else
                      ..._optionList(context, step),
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

  Widget _headerCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _def.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _IconBadge(icon: _def.icon, color: _def.color, size: 48),
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

  List<Widget> _optionList(BuildContext context, _Step step) {
    final all = [...step.options, _kOther];
    final chosen = _selected[step.key]!;

    return [
      for (final option in all) _optionTile(context, step, option),
      if (chosen.contains(_kOther))
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: TextField(
            controller: _otherControllers[step.key],
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Describe it, or leave blank if not sure',
              border: OutlineInputBorder(),
            ),
          ),
        ),
    ];
  }

  Widget _optionTile(BuildContext context, _Step step, String option) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selected[step.key]!.contains(option);

    final IconData icon = step.multi
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
          onTap: () => _toggle(step, option),
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

  Widget _severityScale(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                onTap: () => setState(() => _severity = n),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _severity == n ? scheme.primary : scheme.surface,
                    border: Border.all(
                      color: _severity == n
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    '$n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          _severity == n ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _severity == null ? '- / 10' : '$_severity / 10',
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
                                  width: 120,
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
