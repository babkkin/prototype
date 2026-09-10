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

/// ---------------------------------------------------------------------
/// DATABASE
/// Add more tables here later, e.g.:
///   @DriftDatabase(tables: [Profiles, Medications, Appointments],
///                   daos: [ProfilesDao, MedicationsDao, AppointmentsDao])
/// ---------------------------------------------------------------------

@DriftDatabase(tables: [Profiles], daos: [ProfilesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        // onUpgrade: (m, from, to) async { ... } as the schema evolves
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}