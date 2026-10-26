import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/app_database.dart';
import 'add_appointment.dart';

/// Lists every appointment for one profile, split into Upcoming and
/// Past & completed. Reached from the "Appointment" tab on DetailsPage.
class AppointmentsScreen extends StatelessWidget {
  final Profile profile;

  const AppointmentsScreen({super.key, required this.profile});

  static final _when = DateFormat('EEE, MMM d, y • h:mm a');

  Future<void> _add(BuildContext context) async {
    final dao = context.read<AppDatabase>().appointmentsDao;

    final entry = await Navigator.push<AppointmentsCompanion>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAppointmentScreen(profileId: profile.id),
      ),
    );

    if (entry != null) await dao.insertAppointment(entry);
  }

  Future<void> _edit(BuildContext context, Appointment appointment) async {
    final dao = context.read<AppDatabase>().appointmentsDao;

    final entry = await Navigator.push<AppointmentsCompanion>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAppointmentScreen(
          profileId: profile.id,
          existing: appointment,
        ),
      ),
    );

    if (entry != null) await dao.updateAppointment(appointment.id, entry);
  }

  Future<void> _delete(BuildContext context, Appointment appointment) async {
    final dao = context.read<AppDatabase>().appointmentsDao;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete appointment?'),
        content: Text('"${appointment.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await dao.deleteAppointment(appointment.id);
    messenger.showSnackBar(
      const SnackBar(content: Text('Appointment deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dao = context.read<AppDatabase>().appointmentsDao;

    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.name} — Appointments'),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: dao.watchAllForProfile(profile.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load appointments: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;

          if (all.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text('No appointments yet.'),
                  const SizedBox(height: 4),
                  const Text('Tap + to add the first one.'),
                ],
              ),
            );
          }

          final now = DateTime.now();

          // `all` is earliest-first. Upcoming keeps that order; past items
          // are shown newest-first.
          final upcoming = all
              .where((a) => !a.isDone && !a.appointmentAt.isBefore(now))
              .toList();
          final past = all
              .where((a) => a.isDone || a.appointmentAt.isBefore(now))
              .toList()
              .reversed
              .toList();

          return ListView(
            // Keeps the last row clear of the add (+) button.
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (upcoming.isNotEmpty) ...[
                const _SectionHeader('Upcoming'),
                ...upcoming.map((a) => _tile(context, a)),
              ],
              if (past.isNotEmpty) ...[
                const _SectionHeader('Past & completed'),
                ...past.map((a) => _tile(context, a)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context),
        tooltip: 'Add appointment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _tile(BuildContext context, Appointment a) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = !a.isDone && a.appointmentAt.isBefore(DateTime.now());

    final details = [
      if (_has(a.doctorName)) a.doctorName!.trim(),
      if (_has(a.location)) a.location!.trim(),
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: a.isDone
            ? scheme.primaryContainer
            : overdue
                ? scheme.errorContainer
                : scheme.secondaryContainer,
        foregroundColor: a.isDone
            ? scheme.onPrimaryContainer
            : overdue
                ? scheme.onErrorContainer
                : scheme.onSecondaryContainer,
        child: Icon(a.isDone ? Icons.event_available : Icons.event),
      ),
      title: Text(
        a.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: a.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_when.format(a.appointmentAt)),
          if (details.isNotEmpty) Text(details.join(' • ')),
          if (overdue)
            Text(
              'Not marked as done',
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          if (_has(a.notes))
            Text(
              a.notes!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'toggle':
              context
                  .read<AppDatabase>()
                  .appointmentsDao
                  .setDone(a.id, !a.isDone);
              break;
            case 'edit':
              _edit(context, a);
              break;
            case 'delete':
              _delete(context, a);
              break;
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'toggle',
            child: Text(a.isDone ? 'Mark as not done' : 'Mark as done'),
          ),
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => _edit(context, a),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

bool _has(String? value) => value != null && value.trim().isNotEmpty;
