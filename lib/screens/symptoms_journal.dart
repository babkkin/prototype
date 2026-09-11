import 'package:flutter/material.dart';
import '../data/app_database.dart';

class SymptomsJournal extends StatefulWidget {
  final Profile profile;
  const SymptomsJournal({super.key, required this.profile});

  @override
  State<SymptomsJournal> createState() => _SymptomsJournalState();
}

class _SymptomsJournalState extends State<SymptomsJournal> {
  final _formKey = GlobalKey<FormState>();

  // COLDSPA controllers
  final _characterController = TextEditingController();
  final _onsetController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _severityController = TextEditingController();
  final _patternController = TextEditingController();
  final _associatedController = TextEditingController();

  // Placeholder reference data — swap for real content later
  final List<Map<String, String>> _commonSymptoms = const [
    {'name': 'Fever', 'note': 'Elevated body temperature, often with chills or sweating.'},
    {'name': 'Cough', 'note': 'Dry or productive cough; note frequency and triggers.'},
    {'name': 'Fatigue', 'note': 'Unusual tiredness not relieved by rest.'},
    {'name': 'Nausea', 'note': 'Feeling of sickness with an urge to vomit.'},
    {'name': 'Shortness of Breath', 'note': 'Difficulty breathing, even at rest.'},
  ];

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

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      // TODO: once a Symptoms table exists in Drift, insert here, e.g.:
      // await symptomsDao.insertSymptom(SymptomsCompanion.insert(
      //   profileId: widget.profile.id,
      //   character: _characterController.text,
      //   onset: _onsetController.text,
      //   location: _locationController.text,
      //   duration: _durationController.text,
      //   severity: _severityController.text,
      //   pattern: _patternController.text,
      //   associatedFactors: _associatedController.text,
      // ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symptom entry saved (not yet persisted to DB).')),
      );

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Symptoms — ${widget.profile.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Common Symptoms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _commonSymptoms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final symptom = _commonSymptoms[index];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          symptom['note']!,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'New Journal Entry (COLDSPA)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Form(
            key: _formKey,
            child: Column(
              children: [
                _coldspaField('Character', 'What does the symptom feel like?', _characterController),
                _coldspaField('Onset', 'When did it start?', _onsetController),
                _coldspaField('Location', 'Where is it occurring?', _locationController),
                _coldspaField('Duration', 'How long does it last?', _durationController),
                _coldspaField('Severity', 'How severe is it (e.g. scale of 1-10)?', _severityController),
                _coldspaField('Pattern', 'What makes it better or worse?', _patternController),
                _coldspaField('Associated Factors', 'Any other symptoms occurring alongside it?', _associatedController),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveEntry,
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coldspaField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}