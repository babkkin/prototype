import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'manage_medications.dart';
import 'daily_medication_schedule.dart';
import 'appointments_screen.dart';
import  'vitals_screen.dart';
import 'package:prototype_app/screens/symptoms_journal.dart';
import '../services/medical_summary_service.dart';

class DetailsPage extends StatelessWidget {
  final Profile profile;

  const DetailsPage({
    super.key,
    required this.profile,
  });

  Future<void> _openSummary(BuildContext context, String action) async {
    // Step 1: choose the period the summary should cover.
    const options = [
      ('recent', 'Most recent entries'),
      ('7', 'Last 7 days'),
      ('30', 'Last 30 days'),
      ('90', 'Last 90 days'),
      ('custom', 'Custom range...'),
    ];

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Summary period',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            for (final (key, label) in options)
              ListTile(
                title: Text(label),
                onTap: () => Navigator.pop(sheetContext, key),
              ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    DateTimeRange? range;
    final now = DateTime.now();
    if (choice == 'custom') {
      range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: now,
        initialDateRange: DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        ),
      );
      if (range == null || !context.mounted) return;
    } else if (choice != 'recent') {
      final days = int.parse(choice);
      range = DateTimeRange(
        start: now.subtract(Duration(days: days - 1)),
        end: now,
      );
    }

    // Step 2: build the PDF for that period (spinner until it is ready).
    final service = MedicalSummaryService(context.read<AppDatabase>());
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    var spinnerOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    void closeSpinner() {
      if (!spinnerOpen) return;
      spinnerOpen = false;
      navigator.pop();
    }

    try {
      if (action == 'share') {
        await service.share(profile.id, range: range, onReady: closeSpinner);
      } else {
        await service.preview(profile.id, range: range, onReady: closeSpinner);
      }
    } catch (e) {
      closeSpinner();
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to create summary: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = context.watch<AppDatabase>();
    final vitalsDao = database.vitalsDao;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Medical summary',
            onSelected: (value) => _openSummary(context, value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'preview',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined),
                  title: Text('View / print summary'),
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share_outlined),
                  title: Text('Share with doctor'),
                ),
              ),
            ],
          ),
        ],
      ),
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
      ('Pain', vitals?.pain == null ? null : '${vitals!.pain}/10'),
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
          MaterialPageRoute(
            builder: (context) => SymptomsJournal(profile: profile),
          ),
        );
        break;
      case 'Appointment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsScreen(profile: profile),
          ),
        );
        break;
          case 'Vitals':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VitalsScreen(profile: profile),
              ),
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

