import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'manage_medications.dart';
import 'symptom.dart';
import 'daily_medication_schedule.dart';

class DetailsPage extends StatelessWidget {
  final Profile profile;

  const DetailsPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final database = context.watch<AppDatabase>();
    final vitalsDao = database.vitalsDao;

    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: Column(
        children: [
          StreamBuilder<VitalsTableData?>(
            stream: vitalsDao.watchLatestForProfile(profile.id),
            builder: (context, snapshot) {
              return _VitalsDashboard(vitals: snapshot.data);
            },
          ),
          _ProfileInfoContainer(profile: profile),
          _TabButtonsRow(profile: profile),
          const Divider(height: 1),
          Expanded(
            child: DailyMedicationSchedule(profile: profile),
          ),
        ],
      ),
    );
  }
}

// ── Vitals dashboard ──────────────────────────────────────────
class _VitalsDashboard extends StatelessWidget {
  final VitalsTableData? vitals;
  const _VitalsDashboard({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('BP', vitals?.bp),
      ('T', vitals?.temperature),
      ('PR', vitals?.pulseRate),
      ('RR', vitals?.respiratoryRate),
      ('O2 SAT.', vitals?.oxygenSaturation),
      ('Pain', vitals?.pain),
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
    final firstLetter = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim()[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(firstLetter),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profile.primaryCondition,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab buttons row ────────────────────────────────────────────
class _TabButtonsRow extends StatelessWidget {
  final Profile profile;
  const _TabButtonsRow({required this.profile});

  void _onTabPressed(BuildContext context, String label) {
    switch (label) {
      case 'Medication':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageMedicationsScreen(profile: profile),
          ),
        );
        break;
      case 'Symptoms':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SymptomsScreen()),
        );
        break;
      default:
        // TODO: wire up once AppointmentScreen / VitalsScreen exist.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Medication', 'Symptoms', 'Appointment', 'Vitals'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: tabs.map((label) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                onPressed: () => _onTabPressed(context, label),
                child: Text(label),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
