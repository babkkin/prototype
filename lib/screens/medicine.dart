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
      medicine.genericName,
      medicine.category,
      medicine.form,
      ...medicine.brandNames,
      ...medicine.commonStrengths,
      ...medicine.commonUses,
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
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final medicine = medicines[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              child: const Icon(Icons.medication_outlined),
                            ),
                            title: Text(
                              medicine.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${medicine.category}\n'
                                '${medicine.form} • ${medicine.commonStrengths.join(', ')}',
                              ),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicineDetailsScreen(
                                    medicine: medicine,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
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
          const SizedBox(height: 4),
          Text(
            medicine.genericName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Category', value: medicine.category),
          _InfoRow(label: 'Form', value: medicine.form),
          _InfoRow(
            label: 'Common strengths',
            value: medicine.commonStrengths.join(', '),
          ),
          if (medicine.brandNames.isNotEmpty)
            _InfoRow(
              label: 'Brand names',
              value: medicine.brandNames.join(', '),
            ),
          const Divider(height: 32),
          _TextSection(
            title: 'Description',
            text: medicine.description,
          ),
          _ListSection(
            title: 'Common uses',
            items: medicine.commonUses,
          ),
          _TextSection(
            title: 'How it works',
            text: medicine.howItWorks,
          ),
          _ListSection(
            title: 'Common side effects',
            items: medicine.commonSideEffects,
          ),
          _ListSection(
            title: 'Precautions',
            items: medicine.precautions,
          ),
          _TextSection(
            title: 'Storage',
            text: medicine.storage,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Reference information only. Follow the patient-specific prescription and healthcare professional instructions.',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
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

class _TextSection extends StatelessWidget {
  final String title;
  final String text;

  const _TextSection({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

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
          Text(text),
        ],
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
