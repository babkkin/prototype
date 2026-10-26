import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart';
import 'symptom_tracker.dart';
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
  bool _showAllSymptoms = false;

  late final Future<List<reference.Symptom>> _symptomsFuture;

  @override
  void initState() {
    super.initState();

    // Loads the reference symptoms from assets/symptoms.json.
    _symptomsFuture = reference.loadSymptoms();
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
    // Read before any await so BuildContext is never used across a gap.
    final dao = context.read<AppDatabase>().symptomsDao;

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

    await dao.deleteSymptom(entry.id);

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

          const Text(
            'Tap a symptom to answer a few questions about it.',
          ),

          const SizedBox(height: 12),

          FutureBuilder<List<reference.Symptom>>(
            future: _symptomsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 110,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final all = snapshot.data ?? const <reference.Symptom>[];

              // Symptoms tagged for this profile's primary condition are
              // shown on their own; a profile whose condition has no tagged
              // symptoms simply sees the whole list.
              final condition =
                  widget.profile.primaryCondition.trim().toLowerCase();
              final matching = condition.isEmpty
                  ? const <reference.Symptom>[]
                  : all
                      .where(
                        (s) => s.conditions.any(
                          (c) => condition.contains(c.toLowerCase()),
                        ),
                      )
                      .toList();
              final filtered =
                  matching.isNotEmpty && matching.length < all.length;
              final narrowed = filtered && !_showAllSymptoms;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SymptomPickerList(
                    profile: widget.profile,
                    symptoms: narrowed ? matching : all,
                    loadFailed: snapshot.hasError,
                    note: narrowed
                        ? 'Showing symptoms common with '
                            '${widget.profile.primaryCondition.trim()}.'
                        : null,
                    onInfo: _showReferenceDetails,
                  ),
                  if (filtered)
                    Center(
                      child: TextButton(
                        onPressed: () => setState(
                          () => _showAllSymptoms = !_showAllSymptoms,
                        ),
                        child: Text(
                          _showAllSymptoms
                              ? 'Show only symptoms for this condition'
                              : 'Show all symptoms',
                        ),
                      ),
                    ),
                ],
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
            stream: context.read<AppDatabase>().symptomsDao
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
                        'Tap a symptom above to log the first one.',
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
                separatorBuilder: (_, _) =>
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