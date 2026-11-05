import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/medicine_info.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final _searchController = TextEditingController();
  late Future<List<MedicineInfo>> _medicinesFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _medicinesFuture = _loadMedicines();
  }

  Future<List<MedicineInfo>> _loadMedicines() async {
    final raw = await rootBundle.loadString('assets/medicines.json');
    final decoded = jsonDecode(raw) as List<dynamic>;

    final medicines = decoded
        .map((item) => MedicineInfo.fromJson(item as Map<String, dynamic>))
        .toList();

    medicines.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return medicines;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(MedicineInfo medicine) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;

    final searchable = [
      medicine.name,
      medicine.drugClass,
      medicine.usedFor,
    ].join(' ').toLowerCase();

    return searchable.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Medicines'),
      ),
      body: FutureBuilder<List<MedicineInfo>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load medicine information.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final medicines =
              (snapshot.data ?? const <MedicineInfo>[]).where(_matches).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search medicines',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: medicines.isEmpty
                    ? const Center(child: Text('No medicines found.'))
                    : ListView.separated(
                        itemCount: medicines.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) =>
                            _MedicineTile(medicine: medicines[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Collapsed: drug name + drug class. Expanded: the memo layout.
class _MedicineTile extends StatelessWidget {
  final MedicineInfo medicine;

  const _MedicineTile({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: const Icon(Icons.medication_outlined),
        ),
        title: Text(
          medicine.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          medicine.drugClass.isNotEmpty
              ? medicine.drugClass
              : 'Information not available yet',
        ),
        children: [_MedicineBody(medicine: medicine)],
      ),
    );
  }
}

class MedicineDetailsScreen extends StatelessWidget {
  final MedicineInfo medicine;

  const MedicineDetailsScreen({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(medicine.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            medicine.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (medicine.drugClass.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                medicine.drugClass,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          const SizedBox(height: 16),
          _MedicineBody(medicine: medicine),
        ],
      ),
    );
  }
}

class _MedicineBody extends StatelessWidget {
  final MedicineInfo medicine;

  const _MedicineBody({required this.medicine});

  @override
  Widget build(BuildContext context) {
    if (!medicine.hasDetails) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Detailed information for this medicine has not been added yet. '
          'Ask the prescriber or pharmacist about it.',
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBox(title: 'What is it used for?', text: medicine.usedFor),
        _InfoBox(title: 'How does it work?', text: medicine.howItWorks),
        _Dropdown(
          title: 'Side effects',
          hasContent: medicine.commonSideEffects.isNotEmpty ||
              medicine.adverseEffects.isNotEmpty,
          children: [
            _ListSection(
              title: 'Common',
              items: medicine.commonSideEffects,
            ),
            _ListSection(
              title: 'Serious \u2014 get medical help',
              items: medicine.adverseEffects,
            ),
          ],
        ),
        _Dropdown(
          title: 'Warnings',
          hasContent: medicine.warnings.isNotEmpty,
          children: [Text(medicine.warnings)],
        ),
        _Dropdown(
          title: 'Older adult safety',
          hasContent: medicine.olderAdultSafety.isNotEmpty,
          children: [Text(medicine.olderAdultSafety)],
        ),
        _Dropdown(
          title: 'Caregiver guidance',
          hasContent: medicine.caregiverGuidance.isNotEmpty,
          children: [Text(medicine.caregiverGuidance)],
        ),
        if (medicine.sources.isNotEmpty)
          _InfoBox(title: 'Source:', text: medicine.sources.join('\n')),
        const SizedBox(height: 4),
        Text(
          'Reference information only. Follow the patient-specific '
          'prescription and healthcare professional instructions.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String text;

  const _InfoBox({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}

/// A row with a title and an arrow; tapping reveals its content.
class _Dropdown extends StatelessWidget {
  final String title;
  final bool hasContent;
  final List<Widget> children;

  const _Dropdown({
    required this.title,
    required this.hasContent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasContent) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ListSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          ...items.map(
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
          ),
        ],
      ),
    );
  }
}
