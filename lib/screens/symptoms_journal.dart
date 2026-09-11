import 'package:flutter/material.dart';

import '../data/app_database.dart';
import 'add_symptom_entry.dart';
import 'symptom.dart' as reference;

class SymptomsJournal extends StatefulWidget {
  final Profile profile;

  const SymptomsJournal({
    super.key,
    required this.profile,
  });

  @override
  State<SymptomsJournal> createState() => _SymptomsJournalState();
}

class _SymptomsJournalState extends State<SymptomsJournal> {
  final AppDatabase _database = AppDatabase();

  late final Future<List<reference.Symptom>> _symptomsFuture;

  @override
  void initState() {
    super.initState();

    // Loads the reference symptoms from assets/symptoms.json.
    _symptomsFuture = reference.loadSymptoms();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  Future<void> _openAddEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddSymptomEntry(
          profile: widget.profile,
          database: _database,
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom journal entry saved.'),
        ),
      );
    }
  }

  void _showReferenceDetails(reference.Symptom symptom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                Text(
                  symptom.summary,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                if (symptom.points.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  const Text(
                    'More Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  for (final point in symptom.points)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEntryDetails(Symptom entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Symptom Journal Entry',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 4),

                Text(
                  _formatDateTime(entry.loggedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 24),

                _detailItem(
                  'Character',
                  entry.character,
                ),

                _detailItem(
                  'Onset',
                  entry.onset,
                ),

                _detailItem(
                  'Location',
                  entry.location,
                ),

                _detailItem(
                  'Duration',
                  entry.duration,
                ),

                _detailItem(
                  'Severity',
                  entry.severity,
                ),

                _detailItem(
                  'Pattern',
                  entry.pattern,
                ),

                _detailItem(
                  'Associated Factors',
                  entry.associatedFactors,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(Symptom entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: const Text(
            'This symptom journal entry will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _database.symptomsDao.deleteSymptom(entry.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry deleted.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Symptoms — ${widget.profile.name}',
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntry,
        tooltip: 'Add symptom entry',
        child: const Icon(Icons.add),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --------------------------------------------------
          // COMMON SYMPTOMS FROM JSON
          // --------------------------------------------------

          const Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          FutureBuilder<List<reference.Symptom>>(
            future: _symptomsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox(
                  height: 110,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Unable to load symptom reference.',
                  ),
                );
              }

              final symptoms = snapshot.data ?? [];

              if (symptoms.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Text(
                    'No symptom reference available.',
                  ),
                );
              }

              return SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: symptoms.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final symptom = symptoms[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        _showReferenceDetails(symptom);
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              symptom.name,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Expanded(
                              child: Text(
                                symptom.summary,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                maxLines: 3,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Align(
                              alignment:
                                  Alignment.centerRight,
                              child: Icon(
                                Icons.chevron_right,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // --------------------------------------------------
          // JOURNAL HISTORY
          // --------------------------------------------------

          const Text(
            'Symptom Journal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          StreamBuilder<List<Symptom>>(
            stream: _database.symptomsDao
                .watchAllForProfile(widget.profile.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                  child: Text(
                    'Unable to load journal entries:\n'
                    '${snapshot.error}',
                  ),
                );
              }

              final entries = snapshot.data ?? [];

              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .outline,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No symptom journal entries yet.',
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap + to add the first entry.',
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 6,
                    ),

                    title: Text(
                      entry.character,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Severity: ${entry.severity}',
                          ),
                          Text(
                            _formatDateTime(
                              entry.loggedAt,
                            ),
                          ),
                        ],
                      ),
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view') {
                          _showEntryDetails(entry);
                        }

                        if (value == 'delete') {
                          _deleteEntry(entry);
                        }
                      },
                      itemBuilder: (context) =>
                          const [
                        PopupMenuItem(
                          value: 'view',
                          child:
                              Text('View Details'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),

                    onTap: () {
                      _showEntryDetails(entry);
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _detailItem(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
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

    final month =
        months[dateTime.month - 1];

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month ${dateTime.day}, ${dateTime.year} • '
        '$hour:$minute $period';
  }
}