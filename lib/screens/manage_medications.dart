import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import 'medications_screen.dart';
import 'add_medication.dart'; // AddMedicationScreen

/// Shows every medication logged for one profile, with a FAB to add more.
/// Reached from the "Medication" tab button on DetailsPage.
class ManageMedicationsScreen extends StatelessWidget {
  final Profile profile;

  const ManageMedicationsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final dao = context.watch<AppDatabase>().medicationsDao;

    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.name} — Medications'),
      ),
      // StreamBuilder rebuilds automatically whenever a medication is
      // added, edited, or deleted for this profile.
      body: StreamBuilder<List<Medication>>(
        stream: dao.watchAllForProfile(profile.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return MedicationsScreen(medications: snapshot.data!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMedication = await Navigator.push<MedicationsCompanion>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddMedicationScreen(profileId: profile.id),
            ),
          );

          if (newMedication != null) {
            await dao.insertMedication(newMedication);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}