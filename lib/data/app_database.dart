import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// ---------------------------------------------------------------------
/// TABLE
/// One row per profile (a person being tracked in the app).
/// `id` auto-increments, so once Medications/Appointments tables exist,
/// they can each store a `profileId` column pointing back to a row here.
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

/// ---------------------------------------------------------------------
/// DATABASE
/// Add more tables here later, e.g.:
///   @DriftDatabase(tables: [Profiles, VitalsTable, Medications, Appointments],
///                   daos: [ProfilesDao, VitalsDao, MedicationsDao, AppointmentsDao])
/// ---------------------------------------------------------------------

@DriftDatabase(
  tables: [Profiles, VitalsTable],
  daos: [ProfilesDao, VitalsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Existing installs (schema v1) only had Profiles.
            // Add the new VitalsTable without touching existing data.
            await m.createTable(vitalsTable);
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