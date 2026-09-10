import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_database.dart';
import 'medication_schedule.dart';
import 'frequency_timetable_picker.dart';

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

  List<String> _medicineNames = [];
  bool _isLoadingMedicines = true;

  final _medicationNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _dosageController = TextEditingController();
  final _dosageFormController = TextEditingController();
  final _routeController = TextEditingController();
  final _prnIndicationController = TextEditingController();
  final _maxPrnDoseFrequencyController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _prescriberNameController = TextEditingController();

  // Flexible generated schedule returned by FrequencyTimetablePicker.
  MedicationScheduleSelection? _scheduleSelection;
  List<TimeOfDay> _generatedTimes = [];

  DateTime? _startDate;
  DateTime? _endDate; // left null = ongoing

  @override
  void initState() {
    super.initState();
    _loadMedicineNames();
  }

  Future<void> _loadMedicineNames() async {
    try {
      final raw = await rootBundle.loadString('assets/medicines.json');
      final decoded = jsonDecode(raw) as List<dynamic>;

      final names = decoded
          .map((item) => (item as Map<String, dynamic>)['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (!mounted) return;

      setState(() {
        _medicineNames = names;
        _isLoadingMedicines = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _medicineNames = [];
        _isLoadingMedicines = false;
      });
    }
  }

  Future<void> _selectMedicationName() async {
    if (_isLoadingMedicines) return;

    if (_medicineNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load medicines from assets/medicines.json'),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _MedicationNamePicker(
          medicines: _medicineNames,
          selectedMedicine: _medicationNameController.text,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _medicationNameController.text = selected;
      });
    }
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _brandNameController.dispose();
    _strengthController.dispose();
    _dosageController.dispose();
    _dosageFormController.dispose();
    _routeController.dispose();
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

    final isPrn = _type == PrescriptionType.prn;

    // PRN meds don't use the auto timetable (they're taken as needed,
    // governed by maxPrnDoseFrequency instead) — frequency still needs
    // *some* value since the column isn't nullable, so we use the PRN
    // label directly rather than requiring a picker selection.
    if (!isPrn && _scheduleSelection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a frequency')),
      );
      return;
    }

    final frequencyValue = isPrn
        ? 'As needed (PRN)'
        : _scheduleSelection!.storedFrequency;

    final specificTimeValue = isPrn || _generatedTimes.isEmpty
        ? null
        : formatTimesForStorage(_generatedTimes, context);

    final newMedication = MedicationsCompanion.insert(
      profileId: widget.profileId,
      prescriptionType: _type,
      medicationName: _medicationNameController.text.trim(),
      brandName: Value(_emptyToNull(_brandNameController.text)),
      strength: Value(_emptyToNull(_strengthController.text)),
      dosage: _dosageController.text.trim(),
      dosageForm: _dosageFormController.text.trim(),
      route: _routeController.text.trim(),
      frequency: frequencyValue,
      specificTime: Value(specificTimeValue),
      relationToMeals: Value(isPrn
          ? null
          : _scheduleSelection!.mealTiming.storedRelation),
      startDate: _startDate!,
      endDate: Value(_endDate),
      prnIndication: Value(isPrn
          ? _emptyToNull(_prnIndicationController.text)
          : null),
      maxPrnDoseFrequency: Value(isPrn
          ? _emptyToNull(_maxPrnDoseFrequencyController.text)
          : null),
      specialInstructions:
          Value(_emptyToNull(_specialInstructionsController.text)),
      prescriberName: Value(_emptyToNull(_prescriberNameController.text)),
    );

    Navigator.pop(context, newMedication);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isPrn = _type == PrescriptionType.prn;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                readOnly: true,
                onTap: _selectMedicationName,
                decoration: InputDecoration(
                  labelText: 'Medication Name *',
                  hintText: _isLoadingMedicines
                      ? 'Loading medicines...'
                      : 'Select medication',
                  suffixIcon: _isLoadingMedicines
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.arrow_drop_down),
                ),
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
                    const InputDecoration(labelText: 'Dosage * (e.g. 1 tablet)'),
                validator: (v) => _requiredValidator(v, 'the dosage'),
              ),
              TextFormField(
                controller: _dosageFormController,
                decoration: const InputDecoration(
                    labelText: 'Dosage Form * (tablet, capsule, syrup...)'),
                validator: (v) => _requiredValidator(v, 'the dosage form'),
              ),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                    labelText: 'Route * (oral, topical, etc.)'),
                validator: (v) => _requiredValidator(v, 'the route'),
              ),
              const SizedBox(height: 12),

              // Frequency + auto-generated timetable — replaces the old
              // free-text Frequency and Specific Time fields. Hidden for
              // PRN meds, which use maxPrnDoseFrequency instead.
              if (!isPrn)
                FrequencyTimetablePicker(
                  onChanged: (selection) {
                    setState(() {
                      _scheduleSelection = selection;
                      _generatedTimes = selection.times;
                    });
                  },
                ),
              if (!isPrn) const SizedBox(height: 12),

              // Duration
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date *'),
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
                      labelText: 'PRN Indication * (e.g. for pain)'),
                  validator: (v) =>
                      isPrn ? _requiredValidator(v, 'the PRN indication') : null,
                ),
                TextFormField(
                  controller: _maxPrnDoseFrequencyController,
                  decoration: const InputDecoration(
                      labelText: 'Maximum PRN Dose/Frequency *'),
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

class _MedicationNamePicker extends StatefulWidget {
  final List<String> medicines;
  final String selectedMedicine;

  const _MedicationNamePicker({
    required this.medicines,
    required this.selectedMedicine,
  });

  @override
  State<_MedicationNamePicker> createState() => _MedicationNamePickerState();
}

class _MedicationNamePickerState extends State<_MedicationNamePicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.medicines.where((medicine) {
      return medicine.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    return FractionallySizedBox(
      heightFactor: 0.80,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Medication',
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
                hintText: 'Search medicines',
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
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No medicines found.'),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final medicine = filtered[index];
                      final isSelected =
                          medicine == widget.selectedMedicine;

                      return ListTile(
                        title: Text(medicine),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, medicine),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

