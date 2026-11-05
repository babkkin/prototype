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

}

/// ---------------------------------------------------------------------
/// APPOINTMENTS
/// ---------------------------------------------------------------------

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(
        Profiles,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Purpose of the visit, e.g. "Cardiology follow-up".
  TextColumn get title => text().withLength(min: 1, max: 150)();
  TextColumn get doctorName => text().nullable()();
  TextColumn get location => text().nullable()();

  /// Date and time of the appointment (local time).
  DateTimeColumn get appointmentAt => dateTime()();

  TextColumn get notes => text().nullable()();
  BoolColumn get isDone =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

}

/// ---------------------------------------------------------------------
/// MEDICATION INTAKES
/// ---------------------------------------------------------------------

enum IntakeStatus {
  taken,
  skipped,
}

/// One record per dose that was taken or skipped.
/// Scheduled doses have [scheduledMinutes] (minutes since midnight);
/// as-needed (PRN) doses leave it null and can repeat during the day.
class MedicationIntakes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get profileId =>
      integer().references(
        Profiles,
        #id,
        onDelete: KeyAction.cascade,
      )();

  IntColumn get medicationId =>
      integer().references(
        Medications,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// The day the dose belongs to (local midnight).
  DateTimeColumn get scheduledDate => dateTime()();

  /// Minutes since midnight for scheduled doses; null for PRN.
  IntColumn get scheduledMinutes => integer().nullable()();

  TextColumn get status => textEnum<IntakeStatus>()();

  /// When the caregiver actually recorded it.
  DateTimeColumn get loggedAt =>
      dateTime().withDefault(currentDateAndTime)();
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

/// ---------------------------------------------------------------------
/// APPOINTMENTS DAO
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [Appointments])
class AppointmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AppointmentsDaoMixin {
  AppointmentsDao(super.db);

  /// All appointments for one profile, earliest first.
  Stream<List<Appointment>> watchAllForProfile(
    int profileId,
  ) {
    return (select(appointments)
          ..where(
            (t) => t.profileId.equals(profileId),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.appointmentAt),
          ]))
        .watch();
  }

  Future<int> insertAppointment(
    AppointmentsCompanion entry,
  ) {
    return into(appointments).insert(entry);
  }

  /// Updates only the fields present in [entry].
  Future<void> updateAppointment(
    int id,
    AppointmentsCompanion entry,
  ) {
    return (update(appointments)
          ..where((t) => t.id.equals(id)))
        .write(entry);
  }

  Future<void> setDone(int id, bool done) {
    return (update(appointments)
          ..where((t) => t.id.equals(id)))
        .write(AppointmentsCompanion(isDone: Value(done)));
  }

  Future<void> deleteAppointment(int id) {
    return (delete(appointments)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

/// ---------------------------------------------------------------------
/// MEDICATION INTAKES DAO
/// ---------------------------------------------------------------------

@DriftAccessor(tables: [MedicationIntakes])
class MedicationIntakesDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationIntakesDaoMixin {
  MedicationIntakesDao(super.db);

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Intake records of one profile for one day.
  Stream<List<MedicationIntake>> watchForDay(
    int profileId,
    DateTime day,
  ) {
    return (select(medicationIntakes)
          ..where(
            (t) =>
                t.profileId.equals(profileId) &
                t.scheduledDate.equals(_day(day)),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.loggedAt)]))
        .watch();
  }

  /// Records of one profile within [start, end] (inclusive days).
  Future<List<MedicationIntake>> getInRange(
    int profileId,
    DateTime start,
    DateTime end,
  ) {
    return (select(medicationIntakes)
          ..where(
            (t) =>
                t.profileId.equals(profileId) &
                t.scheduledDate.isBiggerOrEqualValue(_day(start)) &
                t.scheduledDate.isSmallerOrEqualValue(_day(end)),
          ))
        .get();
  }

  /// Marks a scheduled dose as taken or skipped (replaces any earlier mark).
  Future<void> setScheduledStatus({
    required int profileId,
    required int medicationId,
    required DateTime day,
    required int minutes,
    required IntakeStatus status,
  }) {
    return transaction(() async {
      await clearScheduled(
        medicationId: medicationId,
        day: day,
        minutes: minutes,
      );
      await into(medicationIntakes).insert(
        MedicationIntakesCompanion.insert(
          profileId: profileId,
          medicationId: medicationId,
          scheduledDate: _day(day),
          scheduledMinutes: Value(minutes),
          status: status,
        ),
      );
    });
  }

  /// Removes the mark from a scheduled dose (undo).
  Future<void> clearScheduled({
    required int medicationId,
    required DateTime day,
    required int minutes,
  }) {
    return (delete(medicationIntakes)
          ..where(
            (t) =>
                t.medicationId.equals(medicationId) &
                t.scheduledDate.equals(_day(day)) &
                t.scheduledMinutes.equals(minutes),
          ))
        .go();
  }

  /// Logs one as-needed (PRN) dose taken right now.
  Future<int> logPrnDose({
    required int profileId,
    required int medicationId,
  }) {
    return into(medicationIntakes).insert(
      MedicationIntakesCompanion.insert(
        profileId: profileId,
        medicationId: medicationId,
        scheduledDate: _day(DateTime.now()),
        status: IntakeStatus.taken,
      ),
    );
  }

  Future<void> deleteIntake(int id) {
    return (delete(medicationIntakes)
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
    Appointments,
    MedicationIntakes,
  ],
  daos: [
    ProfilesDao,
    VitalsDao,
    MedicationsDao,
    SymptomsDao,
    AppointmentsDao,
    MedicationIntakesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(
        // SQLite ignores FOREIGN KEY / ON DELETE CASCADE unless this is on.
        // Without it, deleting a profile would leave its medications,
        // vitals and symptoms behind as orphaned rows.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
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

          if (from < 5) {
            // v4 -> v5: added Appointments.
            await m.createTable(appointments);
          }

          if (from < 6) {
            // v5 -> v6: added medication intake tracking.
            await m.createTable(medicationIntakes);
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