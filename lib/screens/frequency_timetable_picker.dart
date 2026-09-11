import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'medication_schedule.dart';

class FrequencyTimetablePicker extends StatefulWidget {
  final ValueChanged<MedicationScheduleSelection> onChanged;

  const FrequencyTimetablePicker({super.key, required this.onChanged});

  @override
  State<FrequencyTimetablePicker> createState() =>
      _FrequencyTimetablePickerState();
}

class _FrequencyTimetablePickerState extends State<FrequencyTimetablePicker> {
  ScheduleMode _mode = ScheduleMode.timesPerDay;
  final _valueController = TextEditingController(text: '1');
  TimeOfDay? _firstDoseTime;
  List<TimeOfDay> _times = [];

  MealRelation _mealRelation = MealRelation.none;
  final _mealOffsetController = TextEditingController(text: '30');
  TimingUnit _timingUnit = TimingUnit.minutes;
  bool _useMealTimes = false;

  TimeOfDay _breakfastTime = defaultBreakfastTime;
  TimeOfDay _lunchTime = defaultLunchTime;
  TimeOfDay _dinnerTime = defaultDinnerTime;
  List<MealType> _doseMeals = [MealType.breakfast];

  @override
  void initState() {
    super.initState();
    _regenerate(notifyParent: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyParent());
  }

  @override
  void dispose() {
    _valueController.dispose();
    _mealOffsetController.dispose();
    super.dispose();
  }

  int? get _enteredValue => int.tryParse(_valueController.text.trim());
  int get _offsetValue => int.tryParse(_mealOffsetController.text.trim()) ?? 0;

  bool get _canAnchorToMeals {
    final value = _enteredValue;
    return _mode == ScheduleMode.timesPerDay &&
        value != null &&
        value >= 1 &&
        value <= 3 &&
        _mealRelation != MealRelation.none;
  }

  MealTimingSelection get _mealTiming => MealTimingSelection(
        relation: _mealRelation,
        offsetValue: _offsetValue,
        offsetUnit: _timingUnit,
        useMealTimesForTimetable: _useMealTimes && _canAnchorToMeals,
        breakfastTime: _breakfastTime,
        lunchTime: _lunchTime,
        dinnerTime: _dinnerTime,
        doseMeals: List.unmodifiable(_doseMeals),
      );

  void _resetDoseMealsForCount() {
    final count = _enteredValue ?? 1;
    if (count <= 1) {
      _doseMeals = [MealType.breakfast];
    } else if (count == 2) {
      _doseMeals = [MealType.breakfast, MealType.dinner];
    } else {
      _doseMeals = [MealType.breakfast, MealType.lunch, MealType.dinner];
    }
  }

  void _regenerate({bool notifyParent = true}) {
    final value = _enteredValue;

    if (value == null || value < 1 || value > 24) {
      setState(() => _times = []);
      return;
    }

    final generated = _useMealTimes && _canAnchorToMeals
        ? generateMealBasedTimes(
            doseMeals: _doseMeals,
            mealTiming: _mealTiming,
          )
        : switch (_mode) {
            ScheduleMode.timesPerDay => generateTimesPerDay(
                timesPerDay: value,
                firstDoseTime: _firstDoseTime,
              ),
            ScheduleMode.everyHours => generateIntervalTimes(
                intervalHours: value,
                firstDoseTime: _firstDoseTime,
              ),
          };

    setState(() => _times = generated);
    if (notifyParent) _notifyParent();
  }

  void _notifyParent() {
    final value = _enteredValue;
    if (value == null || value < 1 || value > 24 || _times.isEmpty) return;

    widget.onChanged(
      MedicationScheduleSelection(
        mode: _mode,
        value: value,
        firstDoseTime: _firstDoseTime,
        times: List.unmodifiable(_times),
        mealTiming: _mealTiming,
      ),
    );
  }

  Future<void> _pickFirstDoseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _firstDoseTime ?? defaultFirstDose,
    );
    if (picked != null) {
      _firstDoseTime = picked;
      _regenerate();
    }
  }

  void _clearFirstDoseTime() {
    _firstDoseTime = null;
    _regenerate();
  }

  Future<void> _pickMealTime(MealType meal) async {
    final current = switch (meal) {
      MealType.breakfast => _breakfastTime,
      MealType.lunch => _lunchTime,
      MealType.dinner => _dinnerTime,
    };

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );

    if (picked == null) return;

    setState(() {
      switch (meal) {
        case MealType.breakfast:
          _breakfastTime = picked;
          break;
        case MealType.lunch:
          _lunchTime = picked;
          break;
        case MealType.dinner:
          _dinnerTime = picked;
          break;
      }
    });
    _regenerate();
  }

  Future<void> _editTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
    );
    if (picked != null) {
      setState(() => _times[index] = picked);
      _notifyParent();
    }
  }

  String? _validateFrequencyValue(String? raw) {
    final value = int.tryParse(raw?.trim() ?? '');
    if (value == null || value < 1) return 'Required — enter a number greater than 0';
    if (_mode == ScheduleMode.timesPerDay && value > 24) {
      return 'Enter 24 or fewer times per day';
    }
    if (_mode == ScheduleMode.everyHours && value > 24) {
      return 'Enter an interval from 1 to 24 hours';
    }
    return null;
  }

  String? _validateOffset(String? raw) {
    if (_mealRelation == MealRelation.none ||
        _mealRelation == MealRelation.withMeal) {
      return null;
    }
    final value = int.tryParse(raw?.trim() ?? '');
    if (value == null || value < 1) {
      return 'Required — enter the prescribed time offset';
    }
    if (_timingUnit == TimingUnit.minutes && value > 1439) {
      return 'Enter fewer than 1440 minutes';
    }
    if (_timingUnit == TimingUnit.hours && value > 23) {
      return 'Enter fewer than 24 hours';
    }
    return null;
  }

  Widget _inlineRow({
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
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  InputDecoration _compactDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  Widget _compactTimeValue({
    required String text,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enteredValue = _enteredValue ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inlineRow(
          label: 'Frequency *',
          field: DropdownButtonFormField<ScheduleMode>(
            initialValue: _mode,
            isExpanded: true,
            decoration: _compactDecoration(),
            items: ScheduleMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode.label),
                  ),
                )
                .toList(),
            onChanged: (mode) {
              if (mode == null) return;
              setState(() {
                _mode = mode;
                _valueController.text =
                    mode == ScheduleMode.timesPerDay ? '1' : '8';
                _useMealTimes = false;
                _resetDoseMealsForCount();
              });
              _regenerate();
            },
          ),
        ),

        _inlineRow(
          label: _mode == ScheduleMode.timesPerDay ? 'Times / day *' : 'Every hours *',
          field: TextFormField(
            controller: _valueController,
            decoration: _compactDecoration(
              hintText: _mode == ScheduleMode.timesPerDay ? 'e.g. 2' : 'e.g. 8',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: _validateFrequencyValue,
            onChanged: (_) {
              setState(() {
                _resetDoseMealsForCount();
                if (!_canAnchorToMeals) _useMealTimes = false;
              });
              _regenerate();
            },
          ),
        ),

        _inlineRow(
          label: 'First Dose',
          field: _compactTimeValue(
            text: _firstDoseTime == null
                ? '8:00 AM (default)'
                : _firstDoseTime!.format(context),
            onTap: _pickFirstDoseTime,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_firstDoseTime != null)
                  InkWell(
                    onTap: _clearFirstDoseTime,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.restart_alt, size: 18),
                    ),
                  ),
                const Icon(Icons.access_time, size: 18),
              ],
            ),
          ),
        ),

        _inlineRow(
          label: 'Meals',
          field: DropdownButtonFormField<MealRelation>(
            initialValue: _mealRelation,
            isExpanded: true,
            decoration: _compactDecoration(),
            items: MealRelation.values
                .map(
                  (relation) => DropdownMenuItem(
                    value: relation,
                    child: Text(relation.label),
                  ),
                )
                .toList(),
            onChanged: (relation) {
              if (relation == null) return;
              setState(() {
                _mealRelation = relation;
                if (relation == MealRelation.none) _useMealTimes = false;
              });
              _regenerate();
            },
          ),
        ),

        if (_mealRelation == MealRelation.before ||
            _mealRelation == MealRelation.after)
          _inlineRow(
            label: 'Meal Offset *',
            field: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mealOffsetController,
                    decoration: _compactDecoration(hintText: '30'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: _validateOffset,
                    onChanged: (_) => _regenerate(),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField<TimingUnit>(
                    initialValue: _timingUnit,
                    isExpanded: true,
                    decoration: _compactDecoration(),
                    items: TimingUnit.values
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit.label.toLowerCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (unit) {
                      if (unit == null) return;
                      setState(() => _timingUnit = unit);
                      _regenerate();
                    },
                  ),
                ),
              ],
            ),
          ),

        if (_mealRelation != MealRelation.none)
          _inlineRow(
            label: 'Meal Schedule',
            field: Row(
              children: [
                Switch(
                  value: _useMealTimes && _canAnchorToMeals,
                  onChanged: _canAnchorToMeals
                      ? (enabled) {
                          setState(() {
                            _useMealTimes = enabled;
                            if (enabled) _resetDoseMealsForCount();
                          });
                          _regenerate();
                        }
                      : null,
                ),
                const Expanded(
                  child: Text(
                    'Use meal times',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

        if (_useMealTimes && _canAnchorToMeals) ...[
          _inlineRow(
            label: 'Breakfast',
            field: _compactTimeValue(
              text: _breakfastTime.format(context),
              onTap: () => _pickMealTime(MealType.breakfast),
              trailing: const Icon(Icons.access_time, size: 18),
            ),
          ),
          _inlineRow(
            label: 'Lunch',
            field: _compactTimeValue(
              text: _lunchTime.format(context),
              onTap: () => _pickMealTime(MealType.lunch),
              trailing: const Icon(Icons.access_time, size: 18),
            ),
          ),
          _inlineRow(
            label: 'Dinner',
            field: _compactTimeValue(
              text: _dinnerTime.format(context),
              onTap: () => _pickMealTime(MealType.dinner),
              trailing: const Icon(Icons.access_time, size: 18),
            ),
          ),
          if (enteredValue < 3)
            ...List.generate(
              enteredValue,
              (index) => _inlineRow(
                label: enteredValue == 1 ? 'Dose Meal' : 'Dose ${index + 1} Meal',
                field: DropdownButtonFormField<MealType>(
                  value: _doseMeals[index],
                  isExpanded: true,
                  decoration: _compactDecoration(),
                  items: MealType.values
                      .map(
                        (meal) => DropdownMenuItem(
                          value: meal,
                          child: Text(meal.label),
                        ),
                      )
                      .toList(),
                  onChanged: (meal) {
                    if (meal == null) return;
                    setState(() => _doseMeals[index] = meal);
                    _regenerate();
                  },
                ),
              ),
            ),
        ],

        if (_times.isNotEmpty)
          _inlineRow(
            label: 'Times',
            field: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: List.generate(
                _times.length,
                (index) => ActionChip(
                  visualDensity: const VisualDensity(
                    horizontal: -3,
                    vertical: -3,
                  ),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                  label: Text(
                    _times[index].format(context),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _editTime(index),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
