import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_database.dart';
import 'medication_schedule.dart';
import 'frequency_timetable_picker.dart';

class AddMedicationScreen extends StatefulWidget {
  final int profileId;
  final Medication? existingMedication; // null = adding, not null = editing

  const AddMedicationScreen({
    super.key,
    required this.profileId,
    this.existingMedication,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  
  final _formKey = GlobalKey<FormState>();

  PrescriptionType _type = PrescriptionType.maintenance;

  List<String> _medicineNames = [];
  bool _isLoadingMedicines = true;
  bool get _isEditing => widget.existingMedication != null;
  

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

  final med = widget.existingMedication;
  if (med != null) {
    _type = med.prescriptionType;
    _medicationNameController.text = med.medicationName;
    _brandNameController.text = med.brandName ?? '';
    _strengthController.text = med.strength ?? '';
    _dosageController.text = med.dosage;
    _dosageFormController.text = med.dosageForm;
    _routeController.text = med.route;
    _prnIndicationController.text = med.prnIndication ?? '';
    _maxPrnDoseFrequencyController.text = med.maxPrnDoseFrequency ?? '';
    _specialInstructionsController.text = med.specialInstructions ?? '';
    _prescriberNameController.text = med.prescriberName ?? '';
    _startDate = med.startDate;
    _endDate = med.endDate;
  }

  _loadMedicineNames();
}

  Future<void> _loadMedicineNames() async {
    try {
      final raw = await rootBundle.loadString('assets/meadsv2.json');
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
    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before the start date'),
        ),
      );
      return;
    }


final isPrn = _type == PrescriptionType.prn;
final existing = widget.existingMedication;

// When editing a non-PRN med and the user didn't touch the picker,
// keep the schedule that was already saved.
final keepExistingSchedule = !isPrn &&
    _scheduleSelection == null &&
    existing != null &&
    existing.prescriptionType != PrescriptionType.prn;

if (!isPrn && _scheduleSelection == null && !keepExistingSchedule) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select a frequency')),
  );
  return;
}

final String frequencyValue = isPrn
    ? 'As needed (PRN)'
    : keepExistingSchedule
        ? existing!.frequency
        : _scheduleSelection!.storedFrequency;

final String? specificTimeValue = isPrn
    ? null
    : keepExistingSchedule
        ? existing!.specificTime
        : (_generatedTimes.isEmpty
            ? null
            : formatTimesForStorage(_generatedTimes, context));

final String? relationValue = isPrn
    ? null
    : keepExistingSchedule
        ? existing!.relationToMeals
        : _scheduleSelection!.mealTiming.storedRelation;

// EDIT MODE: return an updated Medication (keeps the same id)
if (existing != null) {
  Navigator.pop(
    context,
    existing.copyWith(
      prescriptionType: _type,
      medicationName: _medicationNameController.text.trim(),
      brandName: Value(_emptyToNull(_brandNameController.text)),
      strength: Value(_emptyToNull(_strengthController.text)),
      dosage: _dosageController.text.trim(),
      dosageForm: _dosageFormController.text.trim(),
      route: _routeController.text.trim(),
      frequency: frequencyValue,
      specificTime: Value(specificTimeValue),
      relationToMeals: Value(relationValue),
      startDate: _startDate!,
      endDate: Value(_endDate),
      prnIndication: Value(
          isPrn ? _emptyToNull(_prnIndicationController.text) : null),
      maxPrnDoseFrequency: Value(
          isPrn ? _emptyToNull(_maxPrnDoseFrequencyController.text) : null),
      specialInstructions:
          Value(_emptyToNull(_specialInstructionsController.text)),
      prescriberName: Value(_emptyToNull(_prescriberNameController.text)),
    ),
  );
  return;
}

// ADD MODE: unchanged
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
  relationToMeals: Value(relationValue),
  startDate: _startDate!,
  endDate: Value(_endDate),
  prnIndication:
      Value(isPrn ? _emptyToNull(_prnIndicationController.text) : null),
  maxPrnDoseFrequency: Value(
      isPrn ? _emptyToNull(_maxPrnDoseFrequencyController.text) : null),
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

  Widget _rowField({
    required String label,
    required Widget field,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  InputDecoration _compactDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrn = _type == PrescriptionType.prn;

    return Scaffold(
      appBar: AppBar(
      title: Text(_isEditing ? 'Edit Medication' : 'Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              _rowField(
                label: 'Type',
                field: DropdownButtonFormField<PrescriptionType>(
                  initialValue: _type,
                  isExpanded: true,
                  decoration: _compactDecoration(),
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
              ),


              _rowField(
                label: 'Medication *',
                field: TextFormField(
                  controller: _medicationNameController,
                  readOnly: true,
                  onTap: _selectMedicationName,
                  decoration: _compactDecoration(
                    hintText: _isLoadingMedicines
                        ? 'Loading medicines...'
                        : 'Select medication',
                    suffixIcon: _isLoadingMedicines
                        ? const Padding(
                            padding: EdgeInsets.all(7),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.arrow_drop_down),
                  ),
                  validator: (v) =>
                      _requiredValidator(v, 'the medication name'),
                ),
              ),


              _rowField(
                label: 'Brand',
                field: TextFormField(
                  controller: _brandNameController,
                  decoration: _compactDecoration(hintText: 'Optional'),
                ),
              ),

              _rowField(
                label: 'Strength',
                field: TextFormField(
                  controller: _strengthController,
                  decoration: _compactDecoration(hintText: 'e.g. 300 mg'),
                ),
              ),

              _rowField(
                label: 'Dosage *',
                field: TextFormField(
                  controller: _dosageController,
                  decoration: _compactDecoration(hintText: 'e.g. 1 tablet'),
                  validator: (v) => _requiredValidator(v, 'the dosage'),
                ),
              ),

              _rowField(
                label: 'Dosage Form *',
                field: TextFormField(
                  controller: _dosageFormController,
                  decoration:
                      _compactDecoration(hintText: 'Tablet, capsule, syrup...'),
                  validator: (v) =>
                      _requiredValidator(v, 'the dosage form'),
                ),
              ),

              _rowField(
                label: 'Route *',
                field: TextFormField(
                  controller: _routeController,
                  decoration:
                      _compactDecoration(hintText: 'Oral, topical, etc.'),
                  validator: (v) => _requiredValidator(v, 'the route'),
                ),
              ),

              if (!isPrn) ...[
                const SizedBox(height: 4),
                if (_isEditing &&
                    _scheduleSelection == null &&
                    widget.existingMedication!.prescriptionType != PrescriptionType.prn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Current schedule: ${widget.existingMedication!.frequency}'
                      '${widget.existingMedication!.specificTime != null ? ' at ${widget.existingMedication!.specificTime}' : ''}. '
                      'Pick a frequency below only if you want to change it.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                    FrequencyTimetablePicker(
                      notifyOnInit: !_isEditing,
                      onChanged: (selection) {
                        setState(() {
                          _scheduleSelection = selection;
                          _generatedTimes = selection.times;
                        });
                      },
                    ),
                const SizedBox(height: 2),
              ],

              _rowField(
                label: 'Start Date *',
                field: InkWell(
                  onTap: () => _pickDate(isStart: true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_startDate))),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              _rowField(
                label: 'End Date',
                field: InkWell(
                  onTap: () => _pickDate(isStart: false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_endDate))),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              if (isPrn) ...[
                _rowField(
                  label: 'PRN Indication *',
                  field: TextFormField(
                    controller: _prnIndicationController,
                    decoration:
                        _compactDecoration(hintText: 'e.g. for pain'),
                    validator: (v) => isPrn
                        ? _requiredValidator(v, 'the PRN indication')
                        : null,
                  ),
                ),
                _rowField(
                  label: 'Max PRN *',
                  field: TextFormField(
                    controller: _maxPrnDoseFrequencyController,
                    decoration:
                        _compactDecoration(hintText: 'Maximum dose/frequency'),
                    validator: (v) => isPrn
                        ? _requiredValidator(v, 'the max PRN dose/frequency')
                        : null,
                  ),
                ),
              ],

              _rowField(
                label: 'Instructions',
                field: TextFormField(
                  controller: _specialInstructionsController,
                  decoration: _compactDecoration(hintText: 'Optional'),
                  maxLines: 2,
                ),
              ),

              _rowField(
                label: 'Prescriber',
                field: TextFormField(
                  controller: _prescriberNameController,
                  decoration: _compactDecoration(hintText: 'Optional'),
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Medication'),
                ),
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
  final _otherController = TextEditingController(); // moved here
  String _query = '';

  void _submitOther() {                             // moved here
    final text = _otherController.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context, text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.medicines.where((medicine) {
      return medicine.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    // Padding on the outside pushes the whole sheet above the keyboard
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
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

            // "Other" tile: type your own medicine name
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: TextField(
                controller: _otherController,
                decoration: const InputDecoration(
                  hintText: 'Other (type your own)...',
                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitOther(),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _submitOther,
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No medicines found.'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final medicine = filtered[index];
                        final isSelected = medicine == widget.selectedMedicine;

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
      ),
    );
  }
}