import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../data/app_database.dart';

class AddMedicationScreen extends StatefulWidget {
  /// The profile this medication belongs to — required since every
  /// Medications row must link back to a profileId.
  final int profileId;

  const AddMedicationScreen({super.key, required this.profileId});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  PrescriptionType _type = PrescriptionType.maintenance;

  final _medicationNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _dosageController = TextEditingController();
  final _dosageFormController = TextEditingController();
  final _routeController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _specificTimeController = TextEditingController();
  final _relationToMealsController = TextEditingController();
  final _prnIndicationController = TextEditingController();
  final _maxPrnDoseFrequencyController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _prescriberNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate; // left null = ongoing

  @override
  void dispose() {
    _medicationNameController.dispose();
    _brandNameController.dispose();
    _strengthController.dispose();
    _dosageController.dispose();
    _dosageFormController.dispose();
    _routeController.dispose();
    _frequencyController.dispose();
    _specificTimeController.dispose();
    _relationToMealsController.dispose();
    _prnIndicationController.dispose();
    _maxPrnDoseFrequencyController.dispose();
    _specialInstructionsController.dispose();
    _prescriberNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a start date')),
      );
      return;
    }

    final newMedication = MedicationsCompanion.insert(
      profileId: widget.profileId,
      prescriptionType: _type,
      medicationName: _medicationNameController.text,
      brandName: Value(_emptyToNull(_brandNameController.text)),
      strength: Value(_emptyToNull(_strengthController.text)),
      dosage: _dosageController.text,
      dosageForm: _dosageFormController.text,
      route: _routeController.text,
      frequency: _frequencyController.text,
      specificTime: Value(_emptyToNull(_specificTimeController.text)),
      relationToMeals: Value(_emptyToNull(_relationToMealsController.text)),
      startDate: _startDate!,
      endDate: Value(_endDate),
      prnIndication: Value(_type == PrescriptionType.prn
          ? _emptyToNull(_prnIndicationController.text)
          : null),
      maxPrnDoseFrequency: Value(_type == PrescriptionType.prn
          ? _emptyToNull(_maxPrnDoseFrequencyController.text)
          : null),
      specialInstructions:
          Value(_emptyToNull(_specialInstructionsController.text)),
      prescriberName: Value(_emptyToNull(_prescriberNameController.text)),
    );

    Navigator.pop(context, newMedication);
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;

  String? _requiredValidator(String? value, String label) =>
      (value == null || value.isEmpty) ? 'Enter $label' : null;

  @override
  Widget build(BuildContext context) {
    final isPrn = _type == PrescriptionType.prn;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Prescription type — drives which PRN-only fields show below.
              DropdownButtonFormField<PrescriptionType>(
                initialValue: _type,
                decoration:
                    const InputDecoration(labelText: 'Prescription Type'),
                items: const [
                  DropdownMenuItem(
                    value: PrescriptionType.maintenance,
                    child: Text('Maintenance'),
                  ),
                  DropdownMenuItem(
                    value: PrescriptionType.temporary,
                    child: Text('Temporary'),
                  ),
                  DropdownMenuItem(
                    value: PrescriptionType.prn,
                    child: Text('PRN (As Needed)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _medicationNameController,
                decoration:
                    const InputDecoration(labelText: 'Medication Name'),
                validator: (v) => _requiredValidator(v, 'the medication name'),
              ),
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                    labelText: 'Brand Name (if applicable)'),
              ),
              TextFormField(
                controller: _strengthController,
                decoration:
                    const InputDecoration(labelText: 'Strength (e.g. 300 mg)'),
              ),
              TextFormField(
                controller: _dosageController,
                decoration:
                    const InputDecoration(labelText: 'Dosage (e.g. 1 tablet)'),
                validator: (v) => _requiredValidator(v, 'the dosage'),
              ),
              TextFormField(
                controller: _dosageFormController,
                decoration: const InputDecoration(
                    labelText: 'Dosage Form (tablet, capsule, syrup...)'),
                validator: (v) => _requiredValidator(v, 'the dosage form'),
              ),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                    labelText: 'Route (oral, topical, etc.)'),
                validator: (v) => _requiredValidator(v, 'the route'),
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                    labelText: 'Frequency (e.g. twice a day)'),
                validator: (v) => _requiredValidator(v, 'the frequency'),
              ),
              TextFormField(
                controller: _specificTimeController,
                decoration: const InputDecoration(
                    labelText: 'Specific Time (e.g. 7:00 AM)'),
              ),
              TextFormField(
                controller: _relationToMealsController,
                decoration: const InputDecoration(
                    labelText: 'Relation to Meals (before/with/after)'),
              ),
              const SizedBox(height: 12),

              // Duration
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date'),
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End Date (leave blank if ongoing)'),
                subtitle: Text(_formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 12),

              // PRN-only fields — only shown/required when type is PRN.
              if (isPrn) ...[
                TextFormField(
                  controller: _prnIndicationController,
                  decoration: const InputDecoration(
                      labelText: 'PRN Indication (e.g. for pain)'),
                  validator: (v) =>
                      isPrn ? _requiredValidator(v, 'the PRN indication') : null,
                ),
                TextFormField(
                  controller: _maxPrnDoseFrequencyController,
                  decoration: const InputDecoration(
                      labelText: 'Maximum PRN Dose/Frequency'),
                  validator: (v) => isPrn
                      ? _requiredValidator(v, 'the max PRN dose/frequency')
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _specialInstructionsController,
                decoration: const InputDecoration(
                    labelText: 'Special Instructions / Notes'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _prescriberNameController,
                decoration:
                    const InputDecoration(labelText: 'Prescriber / Doctor'),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}