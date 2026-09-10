import 'package:flutter/material.dart';
import '../models/profile.dart';
import 'profile_screen.dart';
import 'add_profile.dart';

class ManageProfilesScreen extends StatefulWidget {
  const ManageProfilesScreen({super.key});

  @override
  State<ManageProfilesScreen> createState() => _ManageProfilesScreenState();
}

class _ManageProfilesScreenState extends State<ManageProfilesScreen> {
  final List<Profile> profiles = [];

  void _addProfile(Profile newProfile) {
    setState(() {
      profiles.add(newProfile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profiles'),
      ),
      body: ProfilesScreen(profiles: profiles),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newProfile = await Navigator.push<Profile>(
              context,
              MaterialPageRoute(builder: (context) => const AddProfileScreen()),
            );

            if (newProfile != null) {
              _addProfile(newProfile);
            }
          },
          child: const Icon(Icons.add),
        ),
    );
  }
}