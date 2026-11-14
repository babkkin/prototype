import 'dart:convert';
import 'add_medication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart';
import '../models/medicine_info.dart';
import 'medicine.dart';
import 'daily_medication_schedule.dart' show DoseProgress;

class MedicationsScreen extends StatefulWidget {
  final List<Medication> medications;

  const MedicationsScreen({
    super.key,
    required this.medications,
  });

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final Set<int> _expandedMedicationIds = {};

  Future<MedicineInfo?> _findMedicineInfo(String medicationName) async {
    try {
      final raw = await rootBundle.loadString('assets/medicines.json');
      final decoded = jsonDecode(raw) as List<dynamic>;
      final target = medicationName.trim().toLowerCase();

      for (final item in decoded) {
        final medicine = MedicineInfo.fromJson(item as Map<String, dynamic>);
        if (medicine.name.trim().toLowerCase() == target) return medicine;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> _showMedicineInfo(
    BuildContext context,
    Medication medication,
  ) async {
    final medicine = await _findMedicineInfo(medication.medicationName);

    if (!context.mounted) return;

    if (medicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No reference information found for ${medication.medicationName}.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineDetailsScreen(medicine: medicine),
      ),
    );
  }

  Future<void> _editMedication(
    BuildContext context,
    Medication med,
  ) async {
    final dao = context.read<AppDatabase>().medicationsDao;
    final messenger = ScaffoldMessenger.of(context);

    final updated = await Navigator.of(context).push<Medication>(
      MaterialPageRoute(
        builder: (_) => AddMedicationScreen(
          profileId: med.profileId,
          existingMedication: med,
        ),
      ),
    );

    if (updated == null) return; // user backed out

    await dao.updateMedication(updated);

    messenger.showSnackBar(
      SnackBar(content: Text('${updated.medicationName} updated.')),
    );
  }

  Future<void> _deleteMedication(
    BuildContext context,
    Medication med,
  ) async {
    final dao = context.read<AppDatabase>().medicationsDao;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete medication?'),
        content: Text(
          '${med.medicationName} will be permanently removed from this profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await dao.deleteMedication(med.id);
    _expandedMedicationIds.remove(med.id);

    messenger.showSnackBar(
      SnackBar(content: Text('${med.medicationName} deleted.')),
    );
  }

  void _toggleExpanded(Medication medication) {
    setState(() {
      if (_expandedMedicationIds.contains(medication.id)) {
        _expandedMedicationIds.remove(medication.id);
      } else {
        _expandedMedicationIds.add(medication.id);
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Ongoing';

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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _typeLabel(PrescriptionType type) {
    return switch (type) {
      PrescriptionType.maintenance => 'Maintenance',
      PrescriptionType.temporary => 'Temporary',
      PrescriptionType.prn => 'PRN / As Needed',
    };
  }

  String _displayNullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '--' : trimmed;
  }

  // ---- active vs past ------------------------------------------------

  bool _showPast = false;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Past = stopped by the caregiver, or the end date has gone by.
  bool _isPast(Medication m) {
    if (m.stoppedAt != null) return true;
    final end = m.endDate;
    if (end == null) return false;
    return _dateOnly(end).isBefore(_dateOnly(DateTime.now()));
  }

  String _endReason(Medication m) {
    if (m.stoppedAt == null) return 'Course ended (end date reached)';
    final r = m.stopReason?.trim() ?? '';
    return r.isEmpty ? 'Stopped' : r;
  }

  static const _stopReasons = [
    'Course completed',
    'Doctor stopped it',
    'Side effects',
    'No longer needed',
    'Other',
  ];

  Future<String?> _askStopReason(BuildContext context, Medication med) {
    var choice = _stopReasons.first;
    final other = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text('Stop ${med.medicationName}?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'It moves to Past medications and leaves the daily '
                  'schedule. Its dose history is kept.',
                ),
                const SizedBox(height: 8),
                for (final r in _stopReasons)
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(r),
                    value: r,
                    groupValue: choice,
                    onChanged: (v) => setLocal(() => choice = v ?? choice),
                  ),
                if (choice == 'Other')
                  TextField(
                    controller: other,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Reason (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = other.text.trim();
                Navigator.pop(
                  dialogContext,
                  choice == 'Other' && text.isNotEmpty
                      ? 'Other: $text'
                      : choice,
                );
              },
              child: const Text('Stop medication'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _stopMedication(BuildContext context, Medication med) async {
    final dao = context.read<AppDatabase>().medicationsDao;
    final messenger = ScaffoldMessenger.of(context);

    final reason = await _askStopReason(context, med);
    if (reason == null) return;

    await dao.stopMedication(med.id, reason: reason);
    _expandedMedicationIds.remove(med.id);

    messenger.showSnackBar(
      SnackBar(content: Text('${med.medicationName} stopped.')),
    );
  }

  Future<void> _resumeMedication(BuildContext context, Medication med) async {
    final dao = context.read<AppDatabase>().medicationsDao;
    final messenger = ScaffoldMessenger.of(context);

    await dao.resumeMedication(med.id);
    _expandedMedicationIds.remove(med.id);

    messenger.showSnackBar(
      SnackBar(content: Text('${med.medicationName} resumed (ongoing).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medications.isEmpty) {
      return const Center(
        child: Text('No medications added yet.'),
      );
    }

    final active = widget.medications.where((m) => !_isPast(m)).toList();
    final past = widget.medications.where(_isPast).toList()
      ..sort((a, b) => (b.endDate ?? b.startDate)
          .compareTo(a.endDate ?? a.startDate));

    // This list is the screen's main scroller, so it must scroll itself.
    // The bottom padding keeps the last row clear of the add (+) button.
    return StreamBuilder<Map<int, (int, int)>>(
      stream: context
          .read<AppDatabase>()
          .medicationIntakesDao
          .watchIntakeCounts(widget.medications.first.profileId),
      builder: (context, snapshot) {
        final counts = snapshot.data ?? const <int, (int, int)>{};

        return ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            if (active.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No active medications.'),
              ),
            for (final med in active) ...[
              _medRow(context, med, counts, past: false),
              const Divider(height: 1),
            ],
            if (past.isNotEmpty) ...[
              ListTile(
                title: Text('Past medications (${past.length})'),
                subtitle: const Text(
                  'Completed or stopped. Dose history is kept.',
                ),
                trailing: Icon(
                  _showPast
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onTap: () => setState(() => _showPast = !_showPast),
              ),
              const Divider(height: 1),
              if (_showPast)
                for (final med in past) ...[
                  _medRow(context, med, counts, past: true),
                  const Divider(height: 1),
                ],
            ],
          ],
        );
      },
    );
  }

  Widget _medRow(
    BuildContext context,
    Medication med,
    Map<int, (int, int)> counts, {
    required bool past,
  }) {
    final isExpanded = _expandedMedicationIds.contains(med.id);
    final (taken, skipped) = counts[med.id] ?? (0, 0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: () => _showMedicineInfo(context, med),
                      child: Text(
                        med.medicationName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      med.dosage,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TypeBadge(type: med.prescriptionType),
                    ),
                  ),
                  IconButton(
                    tooltip: isExpanded
                        ? 'Hide prescription details'
                        : 'Show prescription details',
                    onPressed: () => _toggleExpanded(med),
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                ],
              ),
              if (past)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${_formatDate(med.startDate)} - '
                    '${_formatDate(med.endDate)} | ${_endReason(med)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              DoseProgress(medication: med, taken: taken),
            ],
          ),
        ),
        if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prescription Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _PrescriptionDetailRow(
                      label: 'Brand Name',
                      value: _displayNullable(med.brandName),
                    ),
                    _PrescriptionDetailRow(
                      label: 'Strength',
                      value: _displayNullable(med.strength),
                    ),
                    _PrescriptionDetailRow(
                      label: 'Dosage',
                      value: med.dosage,
                    ),
                    _PrescriptionDetailRow(
                      label: 'Dosage Form',
                      value: med.dosageForm,
                    ),
                    _PrescriptionDetailRow(
                      label: 'Route',
                      value: med.route,
                    ),
                    _PrescriptionDetailRow(
                      label: 'Type',
                      value: _typeLabel(med.prescriptionType),
                    ),
                    _PrescriptionDetailRow(
                      label: 'Frequency',
                      value: med.frequency,
                    ),
                    _PrescriptionDetailRow(
                      label: 'Schedule',
                      value: _displayNullable(med.specificTime),
                    ),
                    _PrescriptionDetailRow(
                      label: 'Relation to Meals',
                      value: _displayNullable(med.relationToMeals),
                    ),
                    _PrescriptionDetailRow(
                      label: 'Start Date',
                      value: _formatDate(med.startDate),
                    ),
                    _PrescriptionDetailRow(
                      label: 'End Date',
                      value: _formatDate(med.endDate),
                    ),
                    if (past) ...[
                      _PrescriptionDetailRow(
                        label: 'Ended Because',
                        value: _endReason(med),
                      ),
                      if (med.stoppedAt != null)
                        _PrescriptionDetailRow(
                          label: 'Stopped On',
                          value: _formatDate(med.stoppedAt),
                        ),
                    ],
                    _PrescriptionDetailRow(
                      label: 'Doses Recorded',
                      value: 'Taken $taken, skipped $skipped',
                    ),
                    _PrescriptionDetailRow(
                      label: 'Total Doses',
                      value: med.totalDoses == null
                          ? '--'
                          : '${med.totalDoses} ($taken taken)',
                    ),
                    if (med.prescriptionType == PrescriptionType.prn) ...[
                      _PrescriptionDetailRow(
                        label: 'PRN Indication',
                        value: _displayNullable(med.prnIndication),
                      ),
                      _PrescriptionDetailRow(
                        label: 'Maximum PRN Dose/Frequency',
                        value: _displayNullable(med.maxPrnDoseFrequency),
                      ),
                    ],
                    _PrescriptionDetailRow(
                      label: 'Prescriber',
                      value: _displayNullable(med.prescriberName),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Special Instructions',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayNullable(med.specialInstructions),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      children: [
                        if (!past)
                          TextButton.icon(
                            onPressed: () => _editMedication(context, med),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                        if (!past)
                          TextButton.icon(
                            onPressed: () => _stopMedication(context, med),
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('Stop'),
                          ),
                        if (past && med.stoppedAt != null)
                          TextButton.icon(
                            onPressed: () => _resumeMedication(context, med),
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Resume'),
                          ),
                        TextButton.icon(
                          onPressed: () => _deleteMedication(context, med),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
      ],
    );
  }
}

class _PrescriptionDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _PrescriptionDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final PrescriptionType type;

  const _TypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      PrescriptionType.maintenance => ('M', Colors.blue),
      PrescriptionType.temporary => ('T', Colors.orange),
      PrescriptionType.prn => ('PRN', Colors.purple),
    };

    return CircleAvatar(
      radius: 14,
      backgroundColor: color.withValues(alpha: 0.15),
      foregroundColor: color,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
