import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'details.dart';
import '../data/app_database.dart'; // provides the Drift-generated Profile class

class ProfilesScreen extends StatelessWidget {
  final List<Profile> profiles;

  const ProfilesScreen({super.key, required this.profiles});

  Future<void> _confirmDelete(BuildContext context, Profile patient) async {
    final dao = context.read<AppDatabase>().profilesDao;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${patient.name}?'),
        content: const Text(
          'This permanently deletes this profile and all of its medications, '
          'vitals and symptom entries. This cannot be undone.',
        ),
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

    await dao.deleteProfile(patient.id);
    messenger.showSnackBar(
      SnackBar(content: Text('${patient.name} deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return const Center(child: Text('No profiles added yet.'));
    }

    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final patient = profiles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                patient.name.trim().isEmpty
                    ? '?'
                    : patient.name.trim()[0].toUpperCase(),
              ),
            ),
            title: Text(
              patient.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                Text('${patient.age} yrs old • ${patient.primaryCondition}'),
            trailing: PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (value) {
                if (value == 'delete') _confirmDelete(context, patient);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete profile')),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailsPage(profile: patient)),
              );
            },
          ),
        );
      },
    );
  }
}