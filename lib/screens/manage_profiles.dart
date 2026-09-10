import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'profile_screen.dart';
import 'add_profile.dart';
import 'add_medication.dart';

class ManageProfilesScreen extends StatelessWidget {
  const ManageProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.watch<AppDatabase>().profilesDao;
    final medicationsDao = context.watch<AppDatabase>().medicationsDao;

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

          if (newProfile == null) return; // user backed out of the form

          // insertProfile returns the auto-generated id — needed so
          // AddMedicationScreen knows which profile to link the
          // medication to via the profileId foreign key.
          final newProfileId = await dao.insertProfile(newProfile);

          if (!context.mounted) return;

          final addMedicationNow = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add a medication now?'),
              content: const Text(
                  'You can add medications for this profile now, or skip and add them later.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Skip'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Add Medication'),
                ),
              ],
            ),
          );

          if (addMedicationNow == true && context.mounted) {
            final newMedication = await Navigator.push<MedicationsCompanion>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddMedicationScreen(profileId: newProfileId),
              ),
            );

            if (newMedication != null) {
              await medicationsDao.insertMedication(newMedication);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}