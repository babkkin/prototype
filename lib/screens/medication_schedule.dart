import 'package:flutter/material.dart';

enum ScheduleMode {
  timesPerDay,
  everyHours,
}

extension ScheduleModeLabel on ScheduleMode {
  String get label {
    switch (this) {
      case ScheduleMode.timesPerDay:
        return 'Times per day';
      case ScheduleMode.everyHours:
        return 'Every X hours';
    }
  }
}

enum MealRelation {
  none,
  before,
  withMeal,
  after,
}

extension MealRelationLabel on MealRelation {
  String get label {
    switch (this) {
      case MealRelation.none:
        return 'No relation to meals';
      case MealRelation.before:
        return 'Before meals';
      case MealRelation.withMeal:
        return 'With meals';
      case MealRelation.after:
        return 'After meals';
    }
  }
}

enum TimingUnit {
  minutes,
  hours,
}

extension TimingUnitLabel on TimingUnit {
  String get label => this == TimingUnit.minutes ? 'Minutes' : 'Hours';
}

enum MealType {
  breakfast,
  lunch,
  dinner,
}

extension MealTypeLabel on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}

class MealTimingSelection {
  final MealRelation relation;
  final int offsetValue;
  final TimingUnit offsetUnit;
  final bool useMealTimesForTimetable;
  final TimeOfDay breakfastTime;
  final TimeOfDay lunchTime;
  final TimeOfDay dinnerTime;
  final List<MealType> doseMeals;

  const MealTimingSelection({
    required this.relation,
    required this.offsetValue,
    required this.offsetUnit,
    required this.useMealTimesForTimetable,
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.doseMeals,
  });

  int get offsetMinutes {
    if (relation == MealRelation.none || relation == MealRelation.withMeal) {
      return 0;
    }
    return offsetUnit == TimingUnit.minutes
        ? offsetValue
        : offsetValue * 60;
  }

  String? get storedRelation {
    switch (relation) {
      case MealRelation.none:
        return null;
      case MealRelation.withMeal:
        return 'With meals';
      case MealRelation.before:
        return '$offsetValue ${_unitText(offsetValue)} before meals';
      case MealRelation.after:
        return '$offsetValue ${_unitText(offsetValue)} after meals';
    }
  }

  String _unitText(int value) {
    if (offsetUnit == TimingUnit.minutes) {
      return value == 1 ? 'minute' : 'minutes';
    }
    return value == 1 ? 'hour' : 'hours';
  }

  TimeOfDay timeForMeal(MealType meal) {
    switch (meal) {
      case MealType.breakfast:
        return breakfastTime;
      case MealType.lunch:
        return lunchTime;
      case MealType.dinner:
        return dinnerTime;
    }
  }
}

class MedicationScheduleSelection {
  final ScheduleMode mode;
  final int value;
  final TimeOfDay? firstDoseTime;
  final List<TimeOfDay> times;
  final MealTimingSelection mealTiming;

  const MedicationScheduleSelection({
    required this.mode,
    required this.value,
    required this.firstDoseTime,
    required this.times,
    required this.mealTiming,
  });

  String get storedFrequency {
    switch (mode) {
      case ScheduleMode.timesPerDay:
        if (value == 1) return 'Once a day';
        return '$value times a day';
      case ScheduleMode.everyHours:
        if (value == 1) return 'Every hour';
        return 'Every $value hours';
    }
  }
}

const TimeOfDay defaultFirstDose = TimeOfDay(hour: 8, minute: 0);
const TimeOfDay defaultBreakfastTime = TimeOfDay(hour: 8, minute: 0);
const TimeOfDay defaultLunchTime = TimeOfDay(hour: 12, minute: 0);
const TimeOfDay defaultDinnerTime = TimeOfDay(hour: 18, minute: 0);

List<TimeOfDay> generateTimesPerDay({
  required int timesPerDay,
  TimeOfDay? firstDoseTime,
}) {
  if (timesPerDay < 1) return [];

  final first = firstDoseTime ?? defaultFirstDose;
  if (timesPerDay == 1) return [first];

  const wakingWindowMinutes = 14 * 60;
  final gap = wakingWindowMinutes / (timesPerDay - 1);
  final firstMinutes = timeOfDayToMinutes(first);

  return List.generate(timesPerDay, (index) {
    final offset = (gap * index).round();
    return timeOfDayFromMinutes(firstMinutes + offset);
  });
}

List<TimeOfDay> generateIntervalTimes({
  required int intervalHours,
  TimeOfDay? firstDoseTime,
}) {
  if (intervalHours < 1) return [];

  final first = firstDoseTime ?? defaultFirstDose;
  final firstMinutes = timeOfDayToMinutes(first);
  final intervalMinutes = intervalHours * 60;
  final doseCount = (24 * 60 / intervalMinutes).ceil();

  return List.generate(doseCount, (index) {
    return timeOfDayFromMinutes(firstMinutes + (intervalMinutes * index));
  });
}

List<TimeOfDay> generateMealBasedTimes({
  required List<MealType> doseMeals,
  required MealTimingSelection mealTiming,
}) {
  return doseMeals.map((meal) {
    final mealTime = mealTiming.timeForMeal(meal);
    return applyMealOffset(
      mealTime: mealTime,
      relation: mealTiming.relation,
      offsetMinutes: mealTiming.offsetMinutes,
    );
  }).toList();
}

TimeOfDay applyMealOffset({
  required TimeOfDay mealTime,
  required MealRelation relation,
  required int offsetMinutes,
}) {
  final mealMinutes = timeOfDayToMinutes(mealTime);

  switch (relation) {
    case MealRelation.none:
    case MealRelation.withMeal:
      return mealTime;
    case MealRelation.before:
      return timeOfDayFromMinutes(mealMinutes - offsetMinutes);
    case MealRelation.after:
      return timeOfDayFromMinutes(mealMinutes + offsetMinutes);
  }
}

int timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

TimeOfDay timeOfDayFromMinutes(int minutes) {
  final normalized = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60);
  return TimeOfDay(
    hour: normalized ~/ 60,
    minute: normalized % 60,
  );
}

String formatTimesForStorage(List<TimeOfDay> times, BuildContext context) {
  return times.map((t) => t.format(context)).join(', ');
}
