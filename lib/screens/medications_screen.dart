import 'package:flutter/material.dart';
import '../data/app_database.dart';

class MedicationsScreen extends StatelessWidget {
  final List<Medication> medications;

  const MedicationsScreen({super.key, required this.medications});

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) {
      return const Center(child: Text('No medications added yet.'));
    }

    return ListView.builder(
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final med = medications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _TypeBadge(type: med.prescriptionType),
            title: Text(
              med.medicationName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_subtitleFor(med)),
            isThreeLine: true,
            onTap: () {}, // TODO: medication detail/edit view
          ),
        );
      },
    );
  }

  String _subtitleFor(Medication med) {
    final parts = <String>[
      if (med.strength != null) med.strength!,
      med.dosage,
      med.frequency,
    ];
    final line1 = parts.join(' • ');

    final extra = <String>[];
    if (med.prescriptionType == PrescriptionType.prn &&
        med.prnIndication != null) {
      extra.add('PRN: ${med.prnIndication}');
    }
    if (med.specialInstructions != null) {
      extra.add(med.specialInstructions!);
    }

    return extra.isEmpty ? line1 : '$line1\n${extra.join(' • ')}';
  }
}

/// Small colored badge showing prescription type at a glance.
class _TypeBadge extends StatelessWidget {
  final PrescriptionType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      PrescriptionType.maintenance => ('M', Colors.blue),
      PrescriptionType.temporary => ('T', Colors.orange),
      PrescriptionType.prn => ('PRN', Colors.purple),
    };

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      foregroundColor: color,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
