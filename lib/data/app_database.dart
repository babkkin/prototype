import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// ---------------------------------------------------------------------
/// TABLE
/// One row per profile (a person being tracked in the app).
/// `id` auto-increments, so other tables (Vitals, Medications, etc.)
/// each store a `profileId` column pointing back to a row here.
/// ---------------------------------------------------------------------

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get age => integer()();
  TextColumn get primaryCondition => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ---------------------------------------------------------------------
/// TABLE
/// One row per vitals reading, linked back to a profile via `profileId`.
/// A profile can have many readings over time (history), so this is a
/// separate table rather than columns on Profiles.
/// ---------------------------------------------------------------------

class VitalsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get bp => text().nullable()();
  TextColumn get temperature => text().nullable()();
  TextColumn get pulseRate => text().nullable()();
  TextColumn get respiratoryRate => text().nullable()();
  TextColumn get oxygenSaturation => text().nullable()();
  TextColumn get pain => text().nullable()();
  DateTimeColumn get recordedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// ---------------------------------------------------------------------
/// TABLE
/// One row per prescribed medication, linked back to a profile.
///
/// `prescriptionType` covers maintenance / temporary / PRN (as-needed).
/// Almost every field applies to all three types — only `prnIndication`
/// and `maxPrnDoseFrequency` are meaningful when prescriptionType is
/// PRN, so they're left nullable and simply unused otherwise, rather
/// than splitting this into separate tables.
/// ---------------------------------------------------------------------

/// Keep this in sync with the check constraint below if you add a type.
enum PrescriptionType { maintenance, temporary, prn }

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  // Prescription status / type (maintenance, temporary, or PRN)
  TextColumn get prescriptionType =>
      textEnum<PrescriptionType>()();

  // Core identification
  TextColumn get medicationName => text()();
  TextColumn get brandName => text().nullable()(); // often blank — generic only on script
  TextColumn get strength => text().nullable()(); // e.g. "300 mg"

  // Dosing
  TextColumn get dosage => text()(); // e.g. "1 tablet"
  TextColumn get dosageForm => text()(); // tablet, capsule, syrup, etc.
  TextColumn get route => text()(); // oral, topical, etc.
  TextColumn get frequency => text()(); // e.g. "twice a day"
  TextColumn get specificTime => text().nullable()(); // e.g. "7:00 AM" — free text since
  // patients may have multiple times a day; store as comma-separated or
  // move to its own table later if you need structured multi-time schedules.
  TextColumn get relationToMeals => text().nullable()(); // before/with/after meals

  // Duration
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()(); // null = ongoing

  // PRN-only fields (leave null for maintenance/temporary)
  TextColumn get prnIndication => text().nullable()(); // e.g. "for pain"
  TextColumn get maxPrnDoseFrequency => text().nullable()(); // e.g. "max 4x/day"

  // Shared extras
  TextColumn get specialInstructions => text().nullable()(); // e.g. "Hold if active bleeding"
  TextColumn get prescriberName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ---------------------------------------------------------------------
/// DAO
/// Drift auto-generates a data class called `Profile` from the
/// `Profiles` table above (singular of the table name). You'll import
/// and use `Profile` in your UI just like the old model class, except
/// this one comes straight from the database.
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  /// Live list of all profiles. A StreamBuilder on this will
  /// automatically rebuild whenever a profile is added, edited, or
  /// deleted — no manual setState bookkeeping required.
  Stream<List<Profile>> watchAll() {
    return (select(profiles)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Inserts a new profile and returns its auto-generated id.
  Future<int> insertProfile(ProfilesCompanion entry) {
    return into(profiles).insert(entry);
  }

  Future<void> updateProfile(Profile profile) {
    return update(profiles).replace(profile);
  }

  Future<void> deleteProfile(int id) {
    return (delete(profiles)..where((t) => t.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [VitalsTable])
class VitalsDao extends DatabaseAccessor<AppDatabase> with _$VitalsDaoMixin {
  VitalsDao(super.db);

  /// Live stream of the single most recent reading for a profile.
  /// Emits null if that profile has no readings yet — DetailsPage
  /// falls back to showing '--' for each field in that case.
  Stream<VitalsTableData?> watchLatestForProfile(int profileId) {
    final query = select(vitalsTable)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  /// Live stream of full reading history for a profile, most recent first.
  Stream<List<VitalsTableData>> watchHistoryForProfile(int profileId) {
    return (select(vitalsTable)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
        .watch();
  }

  /// Inserts a new reading (e.g. from a "log vitals" form).
  Future<int> insertVitals(VitalsTableCompanion entry) {
    return into(vitalsTable).insert(entry);
  }
}

@DriftAccessor(tables: [Medications])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  /// Live list of all medications for a profile, grouped implicitly by
  /// prescriptionType in the UI layer (query just returns everything,
  /// ordered by name).
  Stream<List<Medication>> watchAllForProfile(int profileId) {
    return (select(medications)
          ..where((t) => t.profileId.equals(profileId))
          ..orderBy([(t) => OrderingTerm(expression: t.medicationName)]))
        .watch();
  }

  /// Live list filtered to just one prescription type, e.g. showing
  /// only PRN meds in a "as needed" tab.
  Stream<List<Medication>> watchByType(
    int profileId,
    PrescriptionType type,
  ) {
    return (select(medications)
          ..where((t) =>
              t.profileId.equals(profileId) &
              t.prescriptionType.equalsValue(type))
          ..orderBy([(t) => OrderingTerm(expression: t.medicationName)]))
        .watch();
  }

  Future<int> insertMedication(MedicationsCompanion entry) {
    return into(medications).insert(entry);
  }

  Future<void> updateMedication(Medication medication) {
    return update(medications).replace(medication);
  }

  Future<void> deleteMedication(int id) {
    return (delete(medications)..where((t) => t.id.equals(id))).go();
  }
}

/// ---------------------------------------------------------------------
/// DATABASE
/// ---------------------------------------------------------------------

@DriftDatabase(
  tables: [Profiles, VitalsTable, Medications],
  daos: [ProfilesDao, VitalsDao, MedicationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 -> v2: added VitalsTable.
            await m.createTable(vitalsTable);
          }
          if (from < 3) {
            // v2 -> v3: added Medications.
            await m.createTable(medications);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}