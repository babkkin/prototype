import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'manage_medications.dart';

class DailyMedicationSchedule extends StatelessWidget {
  final Profile profile;

  const DailyMedicationSchedule({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final medicationsDao = context.watch<AppDatabase>().medicationsDao;

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: StreamBuilder<List<Medication>>(
        stream: medicationsDao.watchAllForProfile(profile.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load medications: ${snapshot.error}'),
              ),
            );
          }

          final allMedications = snapshot.data ?? const <Medication>[];
          final today = _dateOnly(DateTime.now());
          final active = allMedications
              .where((medication) => _isActiveOn(medication, today))
              .toList();

          final scheduledEntries = <_DoseEntry>[];
          final prnMedications = <Medication>[];

          for (final medication in active) {
            if (medication.prescriptionType == PrescriptionType.prn) {
              prnMedications.add(medication);
              continue;
            }

            final parsedTimes = _parseStoredTimes(medication.specificTime);
            for (final time in parsedTimes) {
              scheduledEntries.add(
                _DoseEntry(medication: medication, time: time),
              );
            }
          }

          scheduledEntries.sort(
            (a, b) => _minutesOfDay(a.time).compareTo(_minutesOfDay(b.time)),
          );
          prnMedications.sort(
            (a, b) => a.medicationName
                .toLowerCase()
                .compareTo(b.medicationName.toLowerCase()),
          );

          if (scheduledEntries.isEmpty && prnMedications.isEmpty) {
            return _EmptyMedicationState(profile: profile);
          }

          final grouped = <int, List<_DoseEntry>>{};
          for (final entry in scheduledEntries) {
            grouped.putIfAbsent(_minutesOfDay(entry.time), () => []).add(entry);
          }

          final orderedMinutes = grouped.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's Medication Schedule",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    _formatToday(today),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (orderedMinutes.isEmpty)
                const _NoScheduledMedicationMessage()
              else
                ...orderedMinutes.map((minutes) {
                  final entries = grouped[minutes]!;
                  return _TimeGroup(
                    time: entries.first.time,
                    entries: entries,
                  );
                }),
              if (prnMedications.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'As Needed (PRN)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                ...prnMedications.map(
                  (medication) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PrnMedicationCard(medication: medication),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TimeGroup extends StatelessWidget {
  final TimeOfDay time;
  final List<_DoseEntry> entries;

  const _TimeGroup({
    required this.time,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 86,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              _formatTime12Hour(time),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Column(
              children: entries
                  .map(
                    (entry) => _MedicationDoseCard(
                      medication: entry.medication,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationDoseCard extends StatelessWidget {
  final Medication medication;

  const _MedicationDoseCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    final title = _medicationDisplayName(medication);
    final doseAndRoute = [medication.dosage, medication.route]
        .where((value) => value.trim().isNotEmpty)
        .join(' • ');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (doseAndRoute.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(doseAndRoute),
            ],
            if (_hasText(medication.relationToMeals)) ...[
              const SizedBox(height: 4),
              Text(
                medication.relationToMeals!.trim(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_hasText(medication.specialInstructions)) ...[
              const SizedBox(height: 4),
              Text(
                medication.specialInstructions!.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrnMedicationCard extends StatelessWidget {
  final Medication medication;

  const _PrnMedicationCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _medicationDisplayName(medication),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text([medication.dosage, medication.route]
                .where((value) => value.trim().isNotEmpty)
                .join(' • ')),
            if (_hasText(medication.prnIndication)) ...[
              const SizedBox(height: 4),
              Text('For: ${medication.prnIndication!.trim()}'),
            ],
            if (_hasText(medication.maxPrnDoseFrequency)) ...[
              const SizedBox(height: 4),
              Text('Maximum: ${medication.maxPrnDoseFrequency!.trim()}'),
            ],
            if (_hasText(medication.specialInstructions)) ...[
              const SizedBox(height: 4),
              Text(
                medication.specialInstructions!.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoScheduledMedicationMessage extends StatelessWidget {
  const _NoScheduledMedicationMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'No fixed-time medications are scheduled for today.',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}

class _EmptyMedicationState extends StatelessWidget {
  final Profile profile;

  const _EmptyMedicationState({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medication_outlined, size: 42),
            const SizedBox(height: 12),
            const Text(
              'No medications scheduled for today.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageMedicationsScreen(profile: profile),
                  ),
                );
              },
              icon: const Icon(Icons.medication_outlined),
              label: const Text('Manage Medications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoseEntry {
  final Medication medication;
  final TimeOfDay time;

  const _DoseEntry({
    required this.medication,
    required this.time,
  });
}

bool _isActiveOn(Medication medication, DateTime date) {
  final start = _dateOnly(medication.startDate);
  final end = medication.endDate == null ? null : _dateOnly(medication.endDate!);

  if (date.isBefore(start)) return false;
  if (end != null && date.isAfter(end)) return false;
  return true;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _minutesOfDay(TimeOfDay time) => time.hour * 60 + time.minute;

String _medicationDisplayName(Medication medication) {
  final name = medication.medicationName.trim();
  final strength = medication.strength?.trim();
  if (strength == null || strength.isEmpty) return name;
  return '$name $strength';
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _formatToday(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

/// Parses the current `specificTime` values created by TimeOfDay.format().
/// Supports common 12-hour values ("8:00 AM") and 24-hour values ("20:00").

String _formatTime12Hour(TimeOfDay time) {
  final period = time.hour >= 12 ? 'PM' : 'AM';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute $period';
}

List<TimeOfDay> _parseStoredTimes(String? stored) {
  if (stored == null || stored.trim().isEmpty) return const [];

  final results = <TimeOfDay>[];
  for (final raw in stored.split(',')) {
    final parsed = _parseTime(raw.trim());
    if (parsed != null) results.add(parsed);
  }
  return results;
}

TimeOfDay? _parseTime(String input) {
  if (input.isEmpty) return null;

  final normalized = input
      .toUpperCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final twelveHour = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$')
      .firstMatch(normalized);
  if (twelveHour != null) {
    var hour = int.tryParse(twelveHour.group(1)!);
    final minute = int.tryParse(twelveHour.group(2)!);
    final period = twelveHour.group(3)!;

    if (hour == null || minute == null) return null;
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;

    if (hour == 12) hour = 0;
    if (period == 'PM') hour += 12;
    return TimeOfDay(hour: hour, minute: minute);
  }

  final twentyFourHour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalized);
  if (twentyFourHour != null) {
    final hour = int.tryParse(twentyFourHour.group(1)!);
    final minute = int.tryParse(twentyFourHour.group(2)!);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  return null;
}
