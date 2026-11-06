import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  /// Registered products per medicine name (strength + form), from
  /// assets/meadsv2.json. Used to offer real strengths and forms.
  Map<String, List<_Product>> _products = {};

  /// Prescribers typed earlier (medications + appointments) for quick pick.
  List<String> _knownPrescribers = [];
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
  final _durationDaysController = TextEditingController();
  final _totalDosesController = TextEditingController();


  // Flexible generated schedule returned by FrequencyTimetablePicker.
  MedicationScheduleSelection? _scheduleSelection;
  List<TimeOfDay> _generatedTimes = [];

  DateTime? _startDate;

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
    _totalDosesController.text = med.totalDoses?.toString() ?? '';

    // Existing end date -> number of days (inclusive of the start day).
    final end = med.endDate;
    if (end != null) {
      final days = DateTime.utc(end.year, end.month, end.day)
              .difference(DateTime.utc(
                med.startDate.year,
                med.startDate.month,
                med.startDate.day,
              ))
              .inDays +
          1;
      if (days >= 1) _durationDaysController.text = days.toString();
    }
  }

  _loadMedicineNames();
  WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrescribers());
}

  Future<void> _loadMedicineNames() async {
    try {
      final raw = await rootBundle.loadString('assets/meadsv2.json');
      final decoded = jsonDecode(raw) as List<dynamic>;

      final products = <String, List<_Product>>{};
      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final name = map['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;

        products.putIfAbsent(name, () => []).add(
              _Product(
                strength: map['dosage_strength']?.toString().trim() ?? '',
                form: _normalizeForm(map['dosage_form']?.toString() ?? ''),
              ),
            );
      }

      final names = products.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (!mounted) return;

      setState(() {
        _medicineNames = names;
        _products = products;
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
        final changed = selected != _medicationNameController.text;
        _medicationNameController.text = selected;

        if (changed) {
          _strengthController.clear();
          _dosageFormController.clear();
        }

        // Only one registered strength -> choose it for the user.
        final strengths = _strengthOptions;
        if (strengths.length == 1) _strengthController.text = strengths.first;
        _applyFormFromStrength();
      });
    }
  }

  // ── Select helpers ──────────────────────────────────────────

  static const _commonForms = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Suspension',
    'Solution',
    'Injection',
    'Cream',
    'Ointment',
    'Drops',
    'Inhaler',
    'Patch',
  ];

  static const _routes = [
    'Oral',
    'Sublingual',
    'Topical',
    'Inhalation',
    'Intravenous (IV)',
    'Intramuscular (IM)',
    'Subcutaneous',
    'Rectal',
    'Eye (ophthalmic)',
    'Ear (otic)',
  ];

  static const _durationChoices = ['3', '5', '7', '10', '14', '30'];

  static const _prnIndications = [
    'Pain',
    'Fever',
    'Headache',
    'Nausea',
    'Dizziness',
    'Chest discomfort',
    'Shortness of breath',
  ];

  static const _maxPrnChoices = [
    'Once every 4 hours',
    'Once every 6 hours',
    'Once every 8 hours',
    'Up to 3 times a day',
    'Up to 4 times a day',
  ];

  static const _instructionChoices = [
    'Take with a full glass of water',
    'Do not crush or chew',
    'Avoid alcohol',
    'Take at the same time every day',
    'Avoid grapefruit',
  ];

  List<_Product> get _productsForSelected =>
      _products[_medicationNameController.text.trim()] ?? const [];

  /// Strengths registered for the chosen medicine, smallest first.
  List<String> get _strengthOptions {
    final set = _productsForSelected
        .map((p) => p.strength)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    double leading(String s) =>
        double.tryParse(RegExp(r'[\d.]+').firstMatch(s)?.group(0) ?? '') ??
        double.infinity;

    set.sort((x, y) {
      final byNumber = leading(x).compareTo(leading(y));
      return byNumber != 0 ? byNumber : x.compareTo(y);
    });
    return set;
  }

  /// Forms registered for the chosen medicine (and strength), then common ones.
  List<String> get _formOptions {
    final strength = _strengthController.text.trim();
    final all = _productsForSelected;
    final forStrength = strength.isEmpty
        ? const <_Product>[]
        : all.where((p) => p.strength == strength).toList();

    final ordered = <String>[
      ...(forStrength.isNotEmpty ? forStrength : all).map((p) => p.form),
      ...all.map((p) => p.form),
      ..._commonForms,
    ].where((f) => f.isNotEmpty);

    return ordered.toSet().toList();
  }

  /// If the chosen strength comes in exactly one form, select that form.
  void _applyFormFromStrength() {
    final strength = _strengthController.text.trim();
    final forms = _productsForSelected
        .where((p) => p.strength == strength)
        .map((p) => p.form)
        .toSet();

    if (forms.length == 1) {
      _dosageFormController.text = forms.first;
      _applyRouteFromForm();
    }
  }

  /// Suggests a route from the form when the route is still empty.
  void _applyRouteFromForm() {
    if (_routeController.text.trim().isNotEmpty) return;

    final f = _dosageFormController.text.toLowerCase();
    String? route;

    if (f.contains('injection') || f.contains('infusion')) {
      route = f.contains('im/iv') || f.contains('iv')
          ? 'Intravenous (IV)'
          : f.contains('im')
              ? 'Intramuscular (IM)'
              : null;
    } else if (f.contains('cream') ||
        f.contains('ointment') ||
        f.contains('gel') ||
        f.contains('lotion') ||
        f.contains('patch')) {
      route = 'Topical';
    } else if (f.contains('inhal')) {
      route = 'Inhalation';
    } else if (f.contains('tablet') ||
        f.contains('capsule') ||
        f.contains('syrup') ||
        f.contains('suspension') ||
        f.contains('solution')) {
      route = 'Oral';
    }

    if (route != null) _routeController.text = route;
  }

  /// Word used after the amount: "1 tablet", "2 capsules", "5 mL".
  String get _doseUnit {
    final f = _dosageFormController.text.toLowerCase();
    if (f.contains('tablet')) return 'tablet';
    if (f.contains('capsule')) return 'capsule';
    if (f.contains('syrup') ||
        f.contains('suspension') ||
        f.contains('solution') ||
        f.contains('drops')) {
      return 'mL';
    }
    return 'dose';
  }

  List<String> get _dosageChoices {
    final unit = _doseUnit;
    if (unit == 'mL') return const ['5 mL', '10 mL', '15 mL'];

    String label(String amount, bool plural) =>
        '$amount $unit${plural ? 's' : ''}';

    return [
      label('\u00BD', false),
      label('1', false),
      label('1\u00BD', true),
      label('2', true),
    ];
  }

  Future<void> _loadPrescribers() async {
    try {
      final db = context.read<AppDatabase>();
      final meds =
          await db.medicationsDao.watchAllForProfile(widget.profileId).first;
      final appts = await db.appointmentsDao
          .watchAllForProfile(widget.profileId)
          .first;

      final names = <String>{
        for (final m in meds)
          if ((m.prescriberName ?? '').trim().isNotEmpty)
            m.prescriberName!.trim(),
        for (final ap in appts)
          if ((ap.doctorName ?? '').trim().isNotEmpty) ap.doctorName!.trim(),
      }.toList()
        ..sort((x, y) => x.toLowerCase().compareTo(y.toLowerCase()));

      if (!mounted) return;
      setState(() => _knownPrescribers = names);
    } catch (_) {
      // Suggestions are optional; ignore failures.
    }
  }

  Future<void> _pickStrength() async {
    final choice = await _chooseOption(
      title: 'Select strength',
      options: _strengthOptions,
      selected: _strengthController.text,
    );
    if (choice == null) return;

    setState(() {
      _strengthController.text = choice;
      _applyFormFromStrength();
    });
  }

  Future<void> _pickForm() async {
    final choice = await _chooseOption(
      title: 'Select dosage form',
      options: _formOptions,
      selected: _dosageFormController.text,
    );
    if (choice == null) return;

    setState(() {
      _dosageFormController.text = choice;
      _applyRouteFromForm();
    });
  }

  Future<void> _pickRoute() async {
    final choice = await _chooseOption(
      title: 'Select route',
      options: _routes,
      selected: _routeController.text,
    );
    if (choice == null) return;

    setState(() => _routeController.text = choice);
  }

  Future<String?> _chooseOption({
    required String title,
    required List<String> options,
    String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _OptionSheet(
        title: title,
        options: options,
        selected: selected ?? '',
      ),
    );
  }

  /// Dropdown arrow for a text field: opens a list, or appends to the text.
  Widget _listSuffix({
    required String title,
    required List<String> options,
    required TextEditingController controller,
    bool append = false,
    bool numbersOnly = false,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      icon: const Icon(Icons.arrow_drop_down),
      onPressed: () async {
        FocusScope.of(context).unfocus();
        final choice = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _OptionSheet(
            title: title,
            options: options,
            selected: controller.text.trim(),
            numbersOnly: numbersOnly,
          ),
        );
        if (choice == null) return;

        setState(() {
          final current = controller.text.trim();
          if (append && current.isNotEmpty && !current.contains(choice)) {
            controller.text = '$current. $choice';
          } else if (!append || current.isEmpty) {
            controller.text = choice;
          }
        });
      },
    );
  }

  /// Row of tappable suggestions shown under a field.
  Widget _chips({
    required List<String> options,
    required bool Function(String) isSelected,
    required ValueChanged<String> onPick,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 120, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 0,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option, style: const TextStyle(fontSize: 12)),
                selected: isSelected(option),
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (_) => onPick(option),
              ),
          ],
        ),
      ),
    );
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
    _durationDaysController.dispose();
    _totalDosesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  /// Optional duration typed by the caregiver ("for 7 days").
  int? get _durationDays {
    final days = int.tryParse(_durationDaysController.text.trim());
    return (days == null || days < 1) ? null : days;
  }

  /// Optional total number of doses prescribed.
  int? get _totalDoses {
    final total = int.tryParse(_totalDosesController.text.trim());
    return (total == null || total < 1) ? null : total;
  }

  /// Last day of the course: start date + duration - 1 (null = ongoing).
  DateTime? get _computedEndDate {
    final start = _startDate;
    final days = _durationDays;
    if (start == null || days == null) return null;

    return DateTime(start.year, start.month, start.day + days - 1);
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
      endDate: Value(_computedEndDate),
      totalDoses: Value(_totalDoses),
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
  endDate: Value(_computedEndDate),
  totalDoses: Value(_totalDoses),
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
                field: _strengthOptions.isEmpty
                    ? TextFormField(
                        controller: _strengthController,
                        decoration:
                            _compactDecoration(hintText: 'e.g. 300 mg'),
                      )
                    : TextFormField(
                        controller: _strengthController,
                        readOnly: true,
                        onTap: _pickStrength,
                        decoration: _compactDecoration(
                          hintText: 'Select strength',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
              ),

              _rowField(
                label: 'Dosage Form *',
                field: TextFormField(
                  controller: _dosageFormController,
                  readOnly: true,
                  onTap: _pickForm,
                  decoration: _compactDecoration(
                    hintText: 'Select form',
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  validator: (v) =>
                      _requiredValidator(v, 'the dosage form'),
                ),
              ),

              _rowField(
                label: 'Route *',
                field: TextFormField(
                  controller: _routeController,
                  readOnly: true,
                  onTap: _pickRoute,
                  decoration: _compactDecoration(
                    hintText: 'Select route',
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  validator: (v) => _requiredValidator(v, 'the route'),
                ),
              ),

              _rowField(
                label: 'Dosage *',
                field: TextFormField(
                  controller: _dosageController,
                  decoration: _compactDecoration(hintText: 'e.g. 1 tablet'),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => _requiredValidator(v, 'the dosage'),
                ),
              ),
              _chips(
                options: _dosageChoices,
                isSelected: (o) => _dosageController.text.trim() == o,
                onPick: (o) => setState(() => _dosageController.text = o),
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
                  onTap: _pickStartDate,
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
                label: 'Duration (days)',
                field: TextFormField(
                  controller: _durationDaysController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _compactDecoration(
                    hintText: 'Optional, e.g. 7',
                    suffixIcon: _listSuffix(
                      title: 'Duration (days)',
                      options: _durationChoices,
                      controller: _durationDaysController,
                      numbersOnly: true,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final text = v?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final n = int.tryParse(text);
                    return (n == null || n < 1)
                        ? 'Enter a number greater than 0'
                        : null;
                  },
                ),
              ),

              _rowField(
                label: 'Total Doses',
                field: TextFormField(
                  controller: _totalDosesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _compactDecoration(
                    hintText: 'Optional, doses prescribed',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final text = v?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final n = int.tryParse(text);
                    return (n == null || n < 1)
                        ? 'Enter a number greater than 0'
                        : null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _durationDays != null && _startDate != null
                      ? 'Ends on ${_formatDate(_computedEndDate)}.'
                          '${_totalDoses != null ? ' The total doses is used for the progress bar.' : ''}'
                      : _totalDoses != null
                          ? 'Progress is counted against the total doses.'
                          : 'Both are optional. Leave them empty for an ongoing medicine.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),

              if (isPrn) ...[
                _rowField(
                  label: 'PRN Indication *',
                  field: TextFormField(
                    controller: _prnIndicationController,
                    decoration: _compactDecoration(
                      hintText: 'e.g. for pain',
                      suffixIcon: _listSuffix(
                        title: 'PRN indication',
                        options: _prnIndications,
                        controller: _prnIndicationController,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => isPrn
                        ? _requiredValidator(v, 'the PRN indication')
                        : null,
                  ),
                ),
                _rowField(
                  label: 'Max PRN *',
                  field: TextFormField(
                    controller: _maxPrnDoseFrequencyController,
                    decoration: _compactDecoration(
                      hintText: 'Maximum dose/frequency',
                      suffixIcon: _listSuffix(
                        title: 'Maximum PRN',
                        options: _maxPrnChoices,
                        controller: _maxPrnDoseFrequencyController,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
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
                  decoration: _compactDecoration(
                    hintText: 'Optional',
                    suffixIcon: _listSuffix(
                      title: 'Add an instruction',
                      options: _instructionChoices,
                      controller: _specialInstructionsController,
                      append: true,
                    ),
                  ),
                  maxLines: 2,
                ),
              ),
              _rowField(
                label: 'Prescriber',
                field: TextFormField(
                  controller: _prescriberNameController,
                  decoration: _compactDecoration(
                    hintText: 'Optional',
                    suffixIcon: _knownPrescribers.isEmpty
                        ? null
                        : _listSuffix(
                            title: 'Prescriber',
                            options: _knownPrescribers,
                            controller: _prescriberNameController,
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Save Changes' : 'Save Medication'),
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

class _Product {
  final String strength;
  final String form;

  const _Product({required this.strength, required this.form});
}

/// "film coated TABLET" / "Film-Coated Tablet" -> "Film Coated Tablet".
String _normalizeForm(String raw) {
  var s = raw.toLowerCase().replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty) return '';

  s = s
      .split(' ')
      .map((w) => w.isEmpty
          ? w
          : w.startsWith('(')
              ? w.toUpperCase()
              : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  // Keep route abbreviations upper case: (iv), im/iv ...
  return s.replaceAllMapped(
    RegExp(r'\b(Iv|Im|Sc)\b'),
    (m) => m.group(1)!.toUpperCase(),
  );
}

/// Pick one option, or type your own ("Other").
class _OptionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selected;
  final bool numbersOnly;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    this.numbersOnly = false,
  });

  @override
  State<_OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<_OptionSheet> {
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _submitOther() {
    final text = _otherController.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
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
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in widget.options)
                    ListTile(
                      title: Text(option),
                      trailing: option == widget.selected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, option),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: TextField(
                      controller: _otherController,
                      keyboardType: widget.numbersOnly
                          ? TextInputType.number
                          : TextInputType.text,
                      inputFormatters: widget.numbersOnly
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
