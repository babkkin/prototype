import 'package:flutter/material.dart';
import '../models/profile.dart';
import 'details.dart';

class ProfilesScreen extends StatelessWidget {
  final List<Profile> profiles;

  const ProfilesScreen({super.key, required this.profiles});

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
              child: Text(patient.name[0]),
            ),
            title: Text(
              patient.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${patient.age} yrs old • ${patient.primaryCondition}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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