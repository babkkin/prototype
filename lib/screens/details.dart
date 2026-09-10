import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/vitals.dart';

class DetailsPage extends StatelessWidget {
  final Profile profile;
  final Vitals vitals; // pass in real data later; defaults to empty for now

  const DetailsPage({
    super.key,
    required this.profile,
    this.vitals = const Vitals(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: Column(
        children: [
          _VitalsDashboard(vitals: vitals),
          _ProfileInfoContainer(profile: profile),
          _TabButtonsRow(),
          const Divider(height: 1),
          Expanded(
            child: _PrescriptionContainer(),
          ),
        ],
      ),
    );
  }
}

// ── Vitals dashboard ──────────────────────────────────────────
class _VitalsDashboard extends StatelessWidget {
  final Vitals vitals;
  const _VitalsDashboard({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('BP', vitals.bp),
      ('T', vitals.temperature),
      ('PR', vitals.pulseRate),
      ('RR', vitals.respiratoryRate),
      ('O2 SAT.', vitals.oxygenSaturation),
      ('Pain', vitals.pain),
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 3, // 3 boxes per row → 2 rows for 6 items
        shrinkWrap: true, // lets GridView size itself instead of expanding infinitely
        physics: const NeverScrollableScrollPhysics(), // parent Column handles scrolling if needed
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3,
        children: items.map((item) {
          final (label, value) = item;
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value ?? '--',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Name / condition container ────────────────────────────────
class _ProfileInfoContainer extends StatelessWidget {
  final Profile profile;
  const _ProfileInfoContainer({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(profile.name[0]),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                profile.primaryCondition,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tab buttons row ────────────────────────────────────────────
class _TabButtonsRow extends StatelessWidget {
  const _TabButtonsRow();

  @override
  Widget build(BuildContext context) {
    final tabs = ['Medication', 'Symptoms', 'Appointment', 'Vitals'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((label) {
          return OutlinedButton(
            onPressed: () {
              // TODO: Navigator.push to the respective screen once built
              // e.g. MedicationScreen, SymptomsScreen, AppointmentScreen, VitalsScreen
            },
            child: Text(label),
          );
        }).toList(),
      ),
    );
  }
}

// ── Prescription container (lower half, read-only) ─────────────
class _PrescriptionContainer extends StatelessWidget {
  const _PrescriptionContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Doctor's Prescription",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No prescription entered yet.', // placeholder until caretaker input is wired up
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}