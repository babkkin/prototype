import 'package:flutter/material.dart';
import '../data/app_database.dart';

class AddSymptomEntry extends StatefulWidget {
  final Profile profile;
  final AppDatabase database;

  const AddSymptomEntry({
    super.key,
    required this.profile,
    required this.database,
  });

  @override
  State<AddSymptomEntry> createState() => _AddSymptomEntryState();
}

class _AddSymptomEntryState extends State<AddSymptomEntry> {
  final _formKey = GlobalKey<FormState>();

  final _characterController = TextEditingController();
  final _onsetController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _severityController = TextEditingController();
  final _patternController = TextEditingController();
  final _associatedController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _characterController.dispose();
    _onsetController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _severityController.dispose();
    _patternController.dispose();
    _associatedController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.database.symptomsDao.insertSymptom(
        SymptomsCompanion.insert(
          profileId: widget.profile.id,
          character: _characterController.text.trim(),
          onset: _onsetController.text.trim(),
          location: _locationController.text.trim(),
          duration: _durationController.text.trim(),
          severity: _severityController.text.trim(),
          pattern: _patternController.text.trim(),
          associatedFactors: _associatedController.text.trim(),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save journal entry: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Symptom Entry'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 4),

              Text(
                'COLDSPA Symptom Journal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              _coldspaField(
                label: 'Character',
                hint: 'What does the symptom feel like?',
                controller: _characterController,
              ),

              _coldspaField(
                label: 'Onset',
                hint: 'When did it start?',
                controller: _onsetController,
              ),

              _coldspaField(
                label: 'Location',
                hint: 'Where is it occurring?',
                controller: _locationController,
              ),

              _coldspaField(
                label: 'Duration',
                hint: 'How long does it last?',
                controller: _durationController,
              ),

              _coldspaField(
                label: 'Severity',
                hint: 'How severe is it? Example: 7/10',
                controller: _severityController,
              ),

              _coldspaField(
                label: 'Pattern',
                hint: 'What makes it better or worse?',
                controller: _patternController,
              ),

              _coldspaField(
                label: 'Associated Factors',
                hint: 'Are there other symptoms occurring with it?',
                controller: _associatedController,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveEntry,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coldspaField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        },
      ),
    );
  }
}