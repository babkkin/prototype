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
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              profile.primaryCondition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
    final scheme = Theme.of(context).colorScheme;

    final others = [
      ('PR', vitals?.pulseRate),
      ('RR', vitals?.respiratoryRate),
      ('O2 SAT.', vitals?.oxygenSaturation),
      ('Pain', vitals?.pain == null ? null : '${vitals!.pain}/10'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        color: scheme.primaryContainer,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── h1: Blood Pressure ──
              Expanded(
                flex: 4,
                child: _Highlight(
                  label: 'BP',
                  value: vitals?.bp,
                  valueSize: 26,
                  labelSize: 12,
                ),
              ),
              const _VDivider(),

              // ── h2: Temperature ──
              Expanded(
                flex: 3,
                child: _Highlight(
                  label: 'Temp',
                  value: vitals?.temperature,
                  valueSize: 20,
                  labelSize: 11,
                ),
              ),
              const _VDivider(),

              // ── h3: Everything else ──
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: others
                      .map((o) => _MiniRow(label: o.$1, value: o.$2))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Large highlighted vital (used for BP and Temp)
class _Highlight extends StatelessWidget {
  final String label;
  final String? value;
  final double valueSize;
  final double labelSize;

  const _Highlight({
    required this.label,
    required this.value,
    required this.valueSize,
    required this.labelSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value ?? '--',
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: labelSize)),
      ],
    );
  }
}

// Compact label/value row for the right column
class _MiniRow extends StatelessWidget {
  final String label;
  final String? value;

  const _MiniRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10)),
        Text(
          value ?? '--',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Thin vertical divider between zones
class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
    );
  }
}

// ── Tab buttons row ────────────────────────────────────────────
class _TabButtonsRow extends StatefulWidget {
  final Profile profile;
  const _TabButtonsRow({required this.profile});

  @override
  State<_TabButtonsRow> createState() => _TabButtonsRowState();
}

class _TabButtonsRowState extends State<_TabButtonsRow> {
  int _selectedIndex = 0;
  final tabs = ['Medication', 'Symptoms', 'Appointment', 'Vitals'];

  void _onTabPressed(BuildContext context, int index) {
    setState(() => _selectedIndex = index);

    switch (tabs[index]) {
      case 'Medication':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageMedicationsScreen(profile: widget.profile),
          ),
        );
        break;
      case 'Symptoms':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SymptomsJournal(profile: widget.profile),
          ),
        );
        break;
      case 'Appointment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsScreen(profile: widget.profile),
          ),
        );
        break;
      case 'Vitals':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VitalsScreen(profile: widget.profile),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedIndex == index;
            return InkWell(
              onTap: () => _onTabPressed(context, index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? scheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
