import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_database.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();

  List<_Condition> _conditions = [];
  bool _isLoadingConditions = true;

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    try {
      final raw = await rootBundle.loadString('assets/conditions.json');
      final decoded = jsonDecode(raw) as List<dynamic>;

      final items = decoded
          .map((e) => _Condition.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (!mounted) return;
      setState(() {
        _conditions = items;
        _isLoadingConditions = false;
      });
    } catch (_) {
      // If the list can't load, the picker still offers "Other" so a
      // profile can always be created.
      if (!mounted) return;
      setState(() {
        _conditions = [];
        _isLoadingConditions = false;
      });
    }
  }

  Future<void> _selectCondition() async {
    if (_isLoadingConditions) return;

    final result = await showModalBottomSheet<_ConditionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ConditionPicker(
        conditions: _conditions,
        selected: _conditionController.text,
      ),
    );

    if (result == null || !mounted) return;

    if (result.askCustom) {
      final custom = await showDialog<String>(
        context: context,
        builder: (_) =>
            _CustomConditionDialog(initial: _conditionController.text),
      );
      if (custom != null && mounted) {
        setState(() => _conditionController.text = custom);
      }
    } else if (result.value != null) {
      setState(() => _conditionController.text = result.value!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // A Companion is Drift's way of describing "the fields for one
      // row, minus the auto-generated id" — the database assigns the
      // id itself when we insert this.
      final newProfile = ProfilesCompanion.insert(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        primaryCondition: _conditionController.text.trim(),
      );
      Navigator.pop(context, newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return 'Enter a name';
                  if (name.length > 100) return 'Name is too long (max 100)';
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Enter an age';
                  final age = int.tryParse(text);
                  if (age == null) return 'Enter a valid number';
                  if (age < 0 || age > 120) return 'Enter an age from 0 to 120';
                  return null;
                },
              ),
              TextFormField(
                controller: _conditionController,
                readOnly: true,
                onTap: _selectCondition,
                decoration: InputDecoration(
                  labelText: 'Primary Condition',
                  hintText:
                      _isLoadingConditions ? 'Loading...' : 'Select condition',
                  suffixIcon: _isLoadingConditions
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.arrow_drop_down),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Select a condition'
                        : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry from assets/conditions.json. [aliases] are only used for
/// searching (e.g. typing "high blood pressure" finds "Hypertension").
class _Condition {
  final String name;
  final List<String> aliases;

  const _Condition({required this.name, required this.aliases});

  factory _Condition.fromJson(Map<String, dynamic> json) {
    return _Condition(
      name: json['name'] as String,
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        aliases.any((a) => a.toLowerCase().contains(q));
  }
}

/// What the picker sheet hands back: either a chosen/typed value, or a
/// request to open the "type your own" dialog.
class _ConditionResult {
  final String? value;
  final bool askCustom;

  const _ConditionResult.picked(String this.value) : askCustom = false;
  const _ConditionResult.custom()
      : value = null,
        askCustom = true;
}

class _ConditionPicker extends StatefulWidget {
  final List<_Condition> conditions;
  final String selected;

  const _ConditionPicker({
    required this.conditions,
    required this.selected,
  });

  @override
  State<_ConditionPicker> createState() => _ConditionPickerState();
}

class _ConditionPickerState extends State<_ConditionPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim();
    final filtered = widget.conditions.where((c) => c.matches(query)).toList();

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Primary Condition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search conditions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No matching condition in the list.'),
                  ),
                for (final c in filtered)
                  ListTile(
                    title: Text(c.name),
                    trailing: c.name == widget.selected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () =>
                        Navigator.pop(context, _ConditionResult.picked(c.name)),
                  ),
                const Divider(height: 1),
                // Always available, so a profile can be created even when
                // the condition is not in the list.
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(
                    query.isEmpty
                        ? 'Other (type your own)...'
                        : 'Use "$query"',
                  ),
                  onTap: () => Navigator.pop(
                    context,
                    query.isEmpty
                        ? const _ConditionResult.custom()
                        : _ConditionResult.picked(query),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomConditionDialog extends StatefulWidget {
  final String initial;

  const _CustomConditionDialog({required this.initial});

  @override
  State<_CustomConditionDialog> createState() => _CustomConditionDialogState();
}

class _CustomConditionDialogState extends State<_CustomConditionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    Navigator.pop(context, text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Primary condition'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Type the condition'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Use this'),
        ),
      ],
    );
  }
}