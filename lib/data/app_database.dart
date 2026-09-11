import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// ---------------------------------------------------------------------
/// PROFILES
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
/// VITALS
/// ---------------------------------------------------------------------

class VitalsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(
        Profiles,
        #id,
        onDelete: KeyAction.cascade,
      )();

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
/// MEDICATIONS
/// ---------------------------------------------------------------------

enum PrescriptionType {
  maintenance,
  temporary,
  prn,
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(
        Profiles,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get prescriptionType =>
      textEnum<PrescriptionType>()();

  // Medication identification
  TextColumn get medicationName => text()();
  TextColumn get brandName => text().nullable()();
  TextColumn get strength => text().nullable()();

  // Dosing
  TextColumn get dosage => text()();
  TextColumn get dosageForm => text()();
  TextColumn get route => text()();
  TextColumn get frequency => text()();
  TextColumn get specificTime => text().nullable()();
  TextColumn get relationToMeals => text().nullable()();

  // Duration
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();

  // PRN
  TextColumn get prnIndication => text().nullable()();
  TextColumn get maxPrnDoseFrequency => text().nullable()();

  // Extras
  TextColumn get specialInstructions => text().nullable()();
  TextColumn get prescriberName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ---------------------------------------------------------------------
/// SYMPTOM JOURNAL
/// ---------------------------------------------------------------------

class Symptoms extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(
        Profiles,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get character => text()();
  TextColumn get onset => text()();
  TextColumn get location => text()();
  TextColumn get duration => text()();
  TextColumn get severity => text()();
  TextColumn get pattern => text()();
  TextColumn get associatedFactors => text()();

  DateTimeColumn get loggedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// =====================================================================
/// DAOs
/// =====================================================================

/// ---------------------------------------------------------------------
/// PROFILES DAO
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  Stream<List<Profile>> watchAll() {
    return (select(profiles)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  Future<int> insertProfile(ProfilesCompanion entry) {
    return into(profiles).insert(entry);
  }

  Future<void> updateProfile(Profile profile) {
    return update(profiles).replace(profile);
  }

  Future<void> deleteProfile(int id) {
    return (delete(profiles)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

/// ---------------------------------------------------------------------
/// VITALS DAO
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [VitalsTable])
class VitalsDao extends DatabaseAccessor<AppDatabase>
    with _$VitalsDaoMixin {
  VitalsDao(super.db);

  Stream<VitalsTableData?> watchLatestForProfile(
    int profileId,
  ) {
    final query = select(vitalsTable)
      ..where(
        (t) => t.profileId.equals(profileId),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.recordedAt),
      ])
      ..limit(1);

    return query.watchSingleOrNull();
  }

  Stream<List<VitalsTableData>> watchHistoryForProfile(
    int profileId,
  ) {
    return (select(vitalsTable)
          ..where(
            (t) => t.profileId.equals(profileId),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.recordedAt),
          ]))
        .watch();
  }

  Future<int> insertVitals(
    VitalsTableCompanion entry,
  ) {
    return into(vitalsTable).insert(entry);
  }
}

/// ---------------------------------------------------------------------
/// MEDICATIONS DAO
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [Medications])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.db);

  Stream<List<Medication>> watchAllForProfile(
    int profileId,
  ) {
    return (select(medications)
          ..where(
            (t) => t.profileId.equals(profileId),
          )
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.medicationName,
                ),
          ]))
        .watch();
  }

  Stream<List<Medication>> watchByType(
    int profileId,
    PrescriptionType type,
  ) {
    return (select(medications)
          ..where(
            (t) =>
                t.profileId.equals(profileId) &
                t.prescriptionType.equalsValue(type),
          )
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.medicationName,
                ),
          ]))
        .watch();
  }

  Future<int> insertMedication(
    MedicationsCompanion entry,
  ) {
    return into(medications).insert(entry);
  }

  Future<void> updateMedication(
    Medication medication,
  ) {
    return update(medications).replace(medication);
  }

  Future<void> deleteMedication(int id) {
    return (delete(medications)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

/// ---------------------------------------------------------------------
/// SYMPTOMS DAO
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [Symptoms])
class SymptomsDao extends DatabaseAccessor<AppDatabase>
    with _$SymptomsDaoMixin {
  SymptomsDao(super.db);

  /// Save a new COLDSPA journal entry.
  Future<int> insertSymptom(
    SymptomsCompanion entry,
  ) {
    return into(symptoms).insert(entry);
  }

  /// Watch all journal entries for one profile,
  /// newest first.
  Stream<List<Symptom>> watchAllForProfile(
    int profileId,
  ) {
    return (select(symptoms)
          ..where(
            (t) => t.profileId.equals(profileId),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.loggedAt),
          ]))
        .watch();
  }

  /// Delete one journal entry.
  Future<void> deleteSymptom(int id) {
    return (delete(symptoms)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

/// =====================================================================
/// DATABASE
/// =====================================================================

@DriftDatabase(
  tables: [
    Profiles,
    VitalsTable,
    Medications,
    Symptoms,
  ],
  daos: [
    ProfilesDao,
    VitalsDao,
    MedicationsDao,
    SymptomsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(
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

          if (from < 4) {
            // v3 -> v4: added Symptoms journal.
            await m.createTable(symptoms);
          }
        },
      );
}

/// ---------------------------------------------------------------------
/// DATABASE CONNECTION
/// ---------------------------------------------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory();

    final file =
        File(p.join(dbFolder.path, 'app_db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}