import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_database.dart';

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

  Future<Map<String, dynamic>?> _findMedicineInfo(
    String medicationName,
  ) async {
    try {
      final raw = await rootBundle.loadString('assets/medicines.json');
      final decoded = jsonDecode(raw) as List<dynamic>;

      for (final item in decoded) {
        final medicine = item as Map<String, dynamic>;
        final name = medicine['name']?.toString().trim().toLowerCase();

        if (name == medicationName.trim().toLowerCase()) {
          return medicine;
        }
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

    List<String> stringList(String key) {
      return (medicine[key] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
    }

    final genericName = medicine['genericName']?.toString() ?? '';
    final category = medicine['category']?.toString() ?? '';
    final form = medicine['form']?.toString() ?? '';
    final description = medicine['description']?.toString() ?? '';
    final howItWorks = medicine['howItWorks']?.toString() ?? '';
    final storage = medicine['storage']?.toString() ?? '';

    final brandNames = stringList('brandNames');
    final commonStrengths = stringList('commonStrengths');
    final commonUses = stringList('commonUses');
    final commonSideEffects = stringList('commonSideEffects');
    final precautions = stringList('precautions');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            medicine['name']?.toString() ?? medication.medicationName,
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (genericName.isNotEmpty) ...[
                    Text(
                      genericName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _InfoLine(label: 'Category', value: category),
                  _InfoLine(label: 'Form', value: form),
                  if (brandNames.isNotEmpty)
                    _InfoLine(
                      label: 'Brand names',
                      value: brandNames.join(', '),
                    ),
                  if (commonStrengths.isNotEmpty)
                    _InfoLine(
                      label: 'Common strengths',
                      value: commonStrengths.join(', '),
                    ),
                  const Divider(height: 28),
                  if (description.isNotEmpty)
                    _InfoSection(
                      title: 'Description',
                      child: Text(description),
                    ),
                  if (commonUses.isNotEmpty)
                    _InfoSection(
                      title: 'Common uses',
                      child: _BulletList(items: commonUses),
                    ),
                  if (howItWorks.isNotEmpty)
                    _InfoSection(
                      title: 'How it works',
                      child: Text(howItWorks),
                    ),
                  if (commonSideEffects.isNotEmpty)
                    _InfoSection(
                      title: 'Common side effects',
                      child: _BulletList(items: commonSideEffects),
                    ),
                  if (precautions.isNotEmpty)
                    _InfoSection(
                      title: 'Precautions',
                      child: _BulletList(items: precautions),
                    ),
                  if (storage.isNotEmpty)
                    _InfoSection(
                      title: 'Storage',
                      child: Text(storage),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Reference information only. Follow the patient-specific prescription and healthcare professional instructions.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    if (widget.medications.isEmpty) {
      return const Center(
        child: Text('No medications added yet.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.medications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final med = widget.medications[index];
        final isExpanded = _expandedMedicationIds.contains(med.id);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
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
                      child: _TypeBadge(
                        type: med.prescriptionType,
                      ),
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
                  ],
                ),
              ),
          ],
        );
      },
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          )
          .toList(),
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
