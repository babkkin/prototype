import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'profile_screen.dart';
import 'add_profile.dart';

class ManageProfilesScreen extends StatelessWidget {
  const ManageProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.watch<AppDatabase>().profilesDao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profiles'),
      ),
      // StreamBuilder rebuilds this automatically whenever the
      // profiles table changes — no setState needed here anymore.
      body: StreamBuilder<List<Profile>>(
        stream: dao.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ProfilesScreen(profiles: snapshot.data!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProfile = await Navigator.push<ProfilesCompanion>(
            context,
            MaterialPageRoute(builder: (context) => const AddProfileScreen()),
          );

          if (newProfile != null) {
            await dao.insertProfile(newProfile);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}