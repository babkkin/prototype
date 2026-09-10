// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$ProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  ProfilesDaoManager get managers => ProfilesDaoManager(this);
}

class ProfilesDaoManager {
  final _$ProfilesDaoMixin _db;
  ProfilesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}

mixin _$VitalsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $VitalsTableTable get vitalsTable => attachedDatabase.vitalsTable;
  VitalsDaoManager get managers => VitalsDaoManager(this);
}

class VitalsDaoManager {
  final _$VitalsDaoMixin _db;
  VitalsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$VitalsTableTableTableManager get vitalsTable =>
      $$VitalsTableTableTableManager(_db.attachedDatabase, _db.vitalsTable);
}

mixin _$MedicationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MedicationsTable get medications => attachedDatabase.medications;
  MedicationsDaoManager get managers => MedicationsDaoManager(this);
}

class MedicationsDaoManager {
  final _$MedicationsDaoMixin _db;
  MedicationsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryConditionMeta = const VerificationMeta(
    'primaryCondition',
  );
  @override
  late final GeneratedColumn<String> primaryCondition = GeneratedColumn<String>(
    'primary_condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, age, primaryCondition];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('primary_condition')) {
      context.handle(
        _primaryConditionMeta,
        primaryCondition.isAcceptableOrUnknown(
          data['primary_condition']!,
          _primaryConditionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryConditionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      primaryCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_condition'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final int age;
  final String primaryCondition;
  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.primaryCondition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    map['primary_condition'] = Variable<String>(primaryCondition);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      primaryCondition: Value(primaryCondition),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      primaryCondition: serializer.fromJson<String>(json['primaryCondition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'primaryCondition': serializer.toJson<String>(primaryCondition),
    };
  }

  Profile copyWith({
    int? id,
    String? name,
    int? age,
    String? primaryCondition,
  }) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    age: age ?? this.age,
    primaryCondition: primaryCondition ?? this.primaryCondition,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      primaryCondition: data.primaryCondition.present
          ? data.primaryCondition.value
          : this.primaryCondition,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('primaryCondition: $primaryCondition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, age, primaryCondition);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.primaryCondition == this.primaryCondition);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String> primaryCondition;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.primaryCondition = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int age,
    required String primaryCondition,
  }) : name = Value(name),
       age = Value(age),
       primaryCondition = Value(primaryCondition);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? primaryCondition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (primaryCondition != null) 'primary_condition': primaryCondition,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? age,
    Value<String>? primaryCondition,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      primaryCondition: primaryCondition ?? this.primaryCondition,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (primaryCondition.present) {
      map['primary_condition'] = Variable<String>(primaryCondition.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('primaryCondition: $primaryCondition')
          ..write(')'))
        .toString();
  }
}

class $VitalsTableTable extends VitalsTable
    with TableInfo<$VitalsTableTable, VitalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VitalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bpMeta = const VerificationMeta('bp');
  @override
  late final GeneratedColumn<String> bp = GeneratedColumn<String>(
    'bp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<String> temperature = GeneratedColumn<String>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pulseRateMeta = const VerificationMeta(
    'pulseRate',
  );
  @override
  late final GeneratedColumn<String> pulseRate = GeneratedColumn<String>(
    'pulse_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<String> respiratoryRate = GeneratedColumn<String>(
    'respiratory_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oxygenSaturationMeta = const VerificationMeta(
    'oxygenSaturation',
  );
  @override
  late final GeneratedColumn<String> oxygenSaturation = GeneratedColumn<String>(
    'oxygen_saturation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<String> pain = GeneratedColumn<String>(
    'pain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    bp,
    temperature,
    pulseRate,
    respiratoryRate,
    oxygenSaturation,
    pain,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vitals_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VitalsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('bp')) {
      context.handle(_bpMeta, bp.isAcceptableOrUnknown(data['bp']!, _bpMeta));
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('pulse_rate')) {
      context.handle(
        _pulseRateMeta,
        pulseRate.isAcceptableOrUnknown(data['pulse_rate']!, _pulseRateMeta),
      );
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    }
    if (data.containsKey('oxygen_saturation')) {
      context.handle(
        _oxygenSaturationMeta,
        oxygenSaturation.isAcceptableOrUnknown(
          data['oxygen_saturation']!,
          _oxygenSaturationMeta,
        ),
      );
    }
    if (data.containsKey('pain')) {
      context.handle(
        _painMeta,
        pain.isAcceptableOrUnknown(data['pain']!, _painMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VitalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VitalsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      bp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bp'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temperature'],
      ),
      pulseRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pulse_rate'],
      ),
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}respiratory_rate'],
      ),
      oxygenSaturation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oxygen_saturation'],
      ),
      pain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pain'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $VitalsTableTable createAlias(String alias) {
    return $VitalsTableTable(attachedDatabase, alias);
  }
}

class VitalsTableData extends DataClass implements Insertable<VitalsTableData> {
  final int id;
  final int profileId;
  final String? bp;
  final String? temperature;
  final String? pulseRate;
  final String? respiratoryRate;
  final String? oxygenSaturation;
  final String? pain;
  final DateTime recordedAt;
  const VitalsTableData({
    required this.id,
    required this.profileId,
    this.bp,
    this.temperature,
    this.pulseRate,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.pain,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    if (!nullToAbsent || bp != null) {
      map['bp'] = Variable<String>(bp);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<String>(temperature);
    }
    if (!nullToAbsent || pulseRate != null) {
      map['pulse_rate'] = Variable<String>(pulseRate);
    }
    if (!nullToAbsent || respiratoryRate != null) {
      map['respiratory_rate'] = Variable<String>(respiratoryRate);
    }
    if (!nullToAbsent || oxygenSaturation != null) {
      map['oxygen_saturation'] = Variable<String>(oxygenSaturation);
    }
    if (!nullToAbsent || pain != null) {
      map['pain'] = Variable<String>(pain);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  VitalsTableCompanion toCompanion(bool nullToAbsent) {
    return VitalsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      bp: bp == null && nullToAbsent ? const Value.absent() : Value(bp),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      pulseRate: pulseRate == null && nullToAbsent
          ? const Value.absent()
          : Value(pulseRate),
      respiratoryRate: respiratoryRate == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRate),
      oxygenSaturation: oxygenSaturation == null && nullToAbsent
          ? const Value.absent()
          : Value(oxygenSaturation),
      pain: pain == null && nullToAbsent ? const Value.absent() : Value(pain),
      recordedAt: Value(recordedAt),
    );
  }

  factory VitalsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VitalsTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      bp: serializer.fromJson<String?>(json['bp']),
      temperature: serializer.fromJson<String?>(json['temperature']),
      pulseRate: serializer.fromJson<String?>(json['pulseRate']),
      respiratoryRate: serializer.fromJson<String?>(json['respiratoryRate']),
      oxygenSaturation: serializer.fromJson<String?>(json['oxygenSaturation']),
      pain: serializer.fromJson<String?>(json['pain']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'bp': serializer.toJson<String?>(bp),
      'temperature': serializer.toJson<String?>(temperature),
      'pulseRate': serializer.toJson<String?>(pulseRate),
      'respiratoryRate': serializer.toJson<String?>(respiratoryRate),
      'oxygenSaturation': serializer.toJson<String?>(oxygenSaturation),
      'pain': serializer.toJson<String?>(pain),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  VitalsTableData copyWith({
    int? id,
    int? profileId,
    Value<String?> bp = const Value.absent(),
    Value<String?> temperature = const Value.absent(),
    Value<String?> pulseRate = const Value.absent(),
    Value<String?> respiratoryRate = const Value.absent(),
    Value<String?> oxygenSaturation = const Value.absent(),
    Value<String?> pain = const Value.absent(),
    DateTime? recordedAt,
  }) => VitalsTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    bp: bp.present ? bp.value : this.bp,
    temperature: temperature.present ? temperature.value : this.temperature,
    pulseRate: pulseRate.present ? pulseRate.value : this.pulseRate,
    respiratoryRate: respiratoryRate.present
        ? respiratoryRate.value
        : this.respiratoryRate,
    oxygenSaturation: oxygenSaturation.present
        ? oxygenSaturation.value
        : this.oxygenSaturation,
    pain: pain.present ? pain.value : this.pain,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  VitalsTableData copyWithCompanion(VitalsTableCompanion data) {
    return VitalsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      bp: data.bp.present ? data.bp.value : this.bp,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      pulseRate: data.pulseRate.present ? data.pulseRate.value : this.pulseRate,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      oxygenSaturation: data.oxygenSaturation.present
          ? data.oxygenSaturation.value
          : this.oxygenSaturation,
      pain: data.pain.present ? data.pain.value : this.pain,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VitalsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('bp: $bp, ')
          ..write('temperature: $temperature, ')
          ..write('pulseRate: $pulseRate, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('oxygenSaturation: $oxygenSaturation, ')
          ..write('pain: $pain, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    bp,
    temperature,
    pulseRate,
    respiratoryRate,
    oxygenSaturation,
    pain,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VitalsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.bp == this.bp &&
          other.temperature == this.temperature &&
          other.pulseRate == this.pulseRate &&
          other.respiratoryRate == this.respiratoryRate &&
          other.oxygenSaturation == this.oxygenSaturation &&
          other.pain == this.pain &&
          other.recordedAt == this.recordedAt);
}

class VitalsTableCompanion extends UpdateCompanion<VitalsTableData> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String?> bp;
  final Value<String?> temperature;
  final Value<String?> pulseRate;
  final Value<String?> respiratoryRate;
  final Value<String?> oxygenSaturation;
  final Value<String?> pain;
  final Value<DateTime> recordedAt;
  const VitalsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.bp = const Value.absent(),
    this.temperature = const Value.absent(),
    this.pulseRate = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.oxygenSaturation = const Value.absent(),
    this.pain = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  VitalsTableCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    this.bp = const Value.absent(),
    this.temperature = const Value.absent(),
    this.pulseRate = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.oxygenSaturation = const Value.absent(),
    this.pain = const Value.absent(),
    this.recordedAt = const Value.absent(),
  }) : profileId = Value(profileId);
  static Insertable<VitalsTableData> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? bp,
    Expression<String>? temperature,
    Expression<String>? pulseRate,
    Expression<String>? respiratoryRate,
    Expression<String>? oxygenSaturation,
    Expression<String>? pain,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (bp != null) 'bp': bp,
      if (temperature != null) 'temperature': temperature,
      if (pulseRate != null) 'pulse_rate': pulseRate,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (oxygenSaturation != null) 'oxygen_saturation': oxygenSaturation,
      if (pain != null) 'pain': pain,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  VitalsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String?>? bp,
    Value<String?>? temperature,
    Value<String?>? pulseRate,
    Value<String?>? respiratoryRate,
    Value<String?>? oxygenSaturation,
    Value<String?>? pain,
    Value<DateTime>? recordedAt,
  }) {
    return VitalsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      bp: bp ?? this.bp,
      temperature: temperature ?? this.temperature,
      pulseRate: pulseRate ?? this.pulseRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      pain: pain ?? this.pain,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (bp.present) {
      map['bp'] = Variable<String>(bp.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<String>(temperature.value);
    }
    if (pulseRate.present) {
      map['pulse_rate'] = Variable<String>(pulseRate.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<String>(respiratoryRate.value);
    }
    if (oxygenSaturation.present) {
      map['oxygen_saturation'] = Variable<String>(oxygenSaturation.value);
    }
    if (pain.present) {
      map['pain'] = Variable<String>(pain.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VitalsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('bp: $bp, ')
          ..write('temperature: $temperature, ')
          ..write('pulseRate: $pulseRate, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('oxygenSaturation: $oxygenSaturation, ')
          ..write('pain: $pain, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrescriptionType, String>
  prescriptionType =
      GeneratedColumn<String>(
        'prescription_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrescriptionType>(
        $MedicationsTable.$converterprescriptionType,
      );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageFormMeta = const VerificationMeta(
    'dosageForm',
  );
  @override
  late final GeneratedColumn<String> dosageForm = GeneratedColumn<String>(
    'dosage_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specificTimeMeta = const VerificationMeta(
    'specificTime',
  );
  @override
  late final GeneratedColumn<String> specificTime = GeneratedColumn<String>(
    'specific_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationToMealsMeta = const VerificationMeta(
    'relationToMeals',
  );
  @override
  late final GeneratedColumn<String> relationToMeals = GeneratedColumn<String>(
    'relation_to_meals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prnIndicationMeta = const VerificationMeta(
    'prnIndication',
  );
  @override
  late final GeneratedColumn<String> prnIndication = GeneratedColumn<String>(
    'prn_indication',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPrnDoseFrequencyMeta =
      const VerificationMeta('maxPrnDoseFrequency');
  @override
  late final GeneratedColumn<String> maxPrnDoseFrequency =
      GeneratedColumn<String>(
        'max_prn_dose_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _specialInstructionsMeta =
      const VerificationMeta('specialInstructions');
  @override
  late final GeneratedColumn<String> specialInstructions =
      GeneratedColumn<String>(
        'special_instructions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _prescriberNameMeta = const VerificationMeta(
    'prescriberName',
  );
  @override
  late final GeneratedColumn<String> prescriberName = GeneratedColumn<String>(
    'prescriber_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    prescriptionType,
    medicationName,
    brandName,
    strength,
    dosage,
    dosageForm,
    route,
    frequency,
    specificTime,
    relationToMeals,
    startDate,
    endDate,
    prnIndication,
    maxPrnDoseFrequency,
    specialInstructions,
    prescriberName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('dosage_form')) {
      context.handle(
        _dosageFormMeta,
        dosageForm.isAcceptableOrUnknown(data['dosage_form']!, _dosageFormMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageFormMeta);
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    } else if (isInserting) {
      context.missing(_routeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('specific_time')) {
      context.handle(
        _specificTimeMeta,
        specificTime.isAcceptableOrUnknown(
          data['specific_time']!,
          _specificTimeMeta,
        ),
      );
    }
    if (data.containsKey('relation_to_meals')) {
      context.handle(
        _relationToMealsMeta,
        relationToMeals.isAcceptableOrUnknown(
          data['relation_to_meals']!,
          _relationToMealsMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('prn_indication')) {
      context.handle(
        _prnIndicationMeta,
        prnIndication.isAcceptableOrUnknown(
          data['prn_indication']!,
          _prnIndicationMeta,
        ),
      );
    }
    if (data.containsKey('max_prn_dose_frequency')) {
      context.handle(
        _maxPrnDoseFrequencyMeta,
        maxPrnDoseFrequency.isAcceptableOrUnknown(
          data['max_prn_dose_frequency']!,
          _maxPrnDoseFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('special_instructions')) {
      context.handle(
        _specialInstructionsMeta,
        specialInstructions.isAcceptableOrUnknown(
          data['special_instructions']!,
          _specialInstructionsMeta,
        ),
      );
    }
    if (data.containsKey('prescriber_name')) {
      context.handle(
        _prescriberNameMeta,
        prescriberName.isAcceptableOrUnknown(
          data['prescriber_name']!,
          _prescriberNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      prescriptionType: $MedicationsTable.$converterprescriptionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prescription_type'],
        )!,
      ),
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      ),
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      ),
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      dosageForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage_form'],
      )!,
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      specificTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specific_time'],
      ),
      relationToMeals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_to_meals'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      prnIndication: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prn_indication'],
      ),
      maxPrnDoseFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_prn_dose_frequency'],
      ),
      specialInstructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_instructions'],
      ),
      prescriberName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescriber_name'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrescriptionType, String, String>
  $converterprescriptionType = const EnumNameConverter<PrescriptionType>(
    PrescriptionType.values,
  );
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final int profileId;
  final PrescriptionType prescriptionType;
  final String medicationName;
  final String? brandName;
  final String? strength;
  final String dosage;
  final String dosageForm;
  final String route;
  final String frequency;
  final String? specificTime;
  final String? relationToMeals;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prnIndication;
  final String? maxPrnDoseFrequency;
  final String? specialInstructions;
  final String? prescriberName;
  const Medication({
    required this.id,
    required this.profileId,
    required this.prescriptionType,
    required this.medicationName,
    this.brandName,
    this.strength,
    required this.dosage,
    required this.dosageForm,
    required this.route,
    required this.frequency,
    this.specificTime,
    this.relationToMeals,
    required this.startDate,
    this.endDate,
    this.prnIndication,
    this.maxPrnDoseFrequency,
    this.specialInstructions,
    this.prescriberName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    {
      map['prescription_type'] = Variable<String>(
        $MedicationsTable.$converterprescriptionType.toSql(prescriptionType),
      );
    }
    map['medication_name'] = Variable<String>(medicationName);
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    map['dosage'] = Variable<String>(dosage);
    map['dosage_form'] = Variable<String>(dosageForm);
    map['route'] = Variable<String>(route);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || specificTime != null) {
      map['specific_time'] = Variable<String>(specificTime);
    }
    if (!nullToAbsent || relationToMeals != null) {
      map['relation_to_meals'] = Variable<String>(relationToMeals);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || prnIndication != null) {
      map['prn_indication'] = Variable<String>(prnIndication);
    }
    if (!nullToAbsent || maxPrnDoseFrequency != null) {
      map['max_prn_dose_frequency'] = Variable<String>(maxPrnDoseFrequency);
    }
    if (!nullToAbsent || specialInstructions != null) {
      map['special_instructions'] = Variable<String>(specialInstructions);
    }
    if (!nullToAbsent || prescriberName != null) {
      map['prescriber_name'] = Variable<String>(prescriberName);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      prescriptionType: Value(prescriptionType),
      medicationName: Value(medicationName),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      dosage: Value(dosage),
      dosageForm: Value(dosageForm),
      route: Value(route),
      frequency: Value(frequency),
      specificTime: specificTime == null && nullToAbsent
          ? const Value.absent()
          : Value(specificTime),
      relationToMeals: relationToMeals == null && nullToAbsent
          ? const Value.absent()
          : Value(relationToMeals),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      prnIndication: prnIndication == null && nullToAbsent
          ? const Value.absent()
          : Value(prnIndication),
      maxPrnDoseFrequency: maxPrnDoseFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPrnDoseFrequency),
      specialInstructions: specialInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(specialInstructions),
      prescriberName: prescriberName == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriberName),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      prescriptionType: $MedicationsTable.$converterprescriptionType.fromJson(
        serializer.fromJson<String>(json['prescriptionType']),
      ),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      strength: serializer.fromJson<String?>(json['strength']),
      dosage: serializer.fromJson<String>(json['dosage']),
      dosageForm: serializer.fromJson<String>(json['dosageForm']),
      route: serializer.fromJson<String>(json['route']),
      frequency: serializer.fromJson<String>(json['frequency']),
      specificTime: serializer.fromJson<String?>(json['specificTime']),
      relationToMeals: serializer.fromJson<String?>(json['relationToMeals']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      prnIndication: serializer.fromJson<String?>(json['prnIndication']),
      maxPrnDoseFrequency: serializer.fromJson<String?>(
        json['maxPrnDoseFrequency'],
      ),
      specialInstructions: serializer.fromJson<String?>(
        json['specialInstructions'],
      ),
      prescriberName: serializer.fromJson<String?>(json['prescriberName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'prescriptionType': serializer.toJson<String>(
        $MedicationsTable.$converterprescriptionType.toJson(prescriptionType),
      ),
      'medicationName': serializer.toJson<String>(medicationName),
      'brandName': serializer.toJson<String?>(brandName),
      'strength': serializer.toJson<String?>(strength),
      'dosage': serializer.toJson<String>(dosage),
      'dosageForm': serializer.toJson<String>(dosageForm),
      'route': serializer.toJson<String>(route),
      'frequency': serializer.toJson<String>(frequency),
      'specificTime': serializer.toJson<String?>(specificTime),
      'relationToMeals': serializer.toJson<String?>(relationToMeals),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'prnIndication': serializer.toJson<String?>(prnIndication),
      'maxPrnDoseFrequency': serializer.toJson<String?>(maxPrnDoseFrequency),
      'specialInstructions': serializer.toJson<String?>(specialInstructions),
      'prescriberName': serializer.toJson<String?>(prescriberName),
    };
  }

  Medication copyWith({
    int? id,
    int? profileId,
    PrescriptionType? prescriptionType,
    String? medicationName,
    Value<String?> brandName = const Value.absent(),
    Value<String?> strength = const Value.absent(),
    String? dosage,
    String? dosageForm,
    String? route,
    String? frequency,
    Value<String?> specificTime = const Value.absent(),
    Value<String?> relationToMeals = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> prnIndication = const Value.absent(),
    Value<String?> maxPrnDoseFrequency = const Value.absent(),
    Value<String?> specialInstructions = const Value.absent(),
    Value<String?> prescriberName = const Value.absent(),
  }) => Medication(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    prescriptionType: prescriptionType ?? this.prescriptionType,
    medicationName: medicationName ?? this.medicationName,
    brandName: brandName.present ? brandName.value : this.brandName,
    strength: strength.present ? strength.value : this.strength,
    dosage: dosage ?? this.dosage,
    dosageForm: dosageForm ?? this.dosageForm,
    route: route ?? this.route,
    frequency: frequency ?? this.frequency,
    specificTime: specificTime.present ? specificTime.value : this.specificTime,
    relationToMeals: relationToMeals.present
        ? relationToMeals.value
        : this.relationToMeals,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    prnIndication: prnIndication.present
        ? prnIndication.value
        : this.prnIndication,
    maxPrnDoseFrequency: maxPrnDoseFrequency.present
        ? maxPrnDoseFrequency.value
        : this.maxPrnDoseFrequency,
    specialInstructions: specialInstructions.present
        ? specialInstructions.value
        : this.specialInstructions,
    prescriberName: prescriberName.present
        ? prescriberName.value
        : this.prescriberName,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      prescriptionType: data.prescriptionType.present
          ? data.prescriptionType.value
          : this.prescriptionType,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      strength: data.strength.present ? data.strength.value : this.strength,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      dosageForm: data.dosageForm.present
          ? data.dosageForm.value
          : this.dosageForm,
      route: data.route.present ? data.route.value : this.route,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      specificTime: data.specificTime.present
          ? data.specificTime.value
          : this.specificTime,
      relationToMeals: data.relationToMeals.present
          ? data.relationToMeals.value
          : this.relationToMeals,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      prnIndication: data.prnIndication.present
          ? data.prnIndication.value
          : this.prnIndication,
      maxPrnDoseFrequency: data.maxPrnDoseFrequency.present
          ? data.maxPrnDoseFrequency.value
          : this.maxPrnDoseFrequency,
      specialInstructions: data.specialInstructions.present
          ? data.specialInstructions.value
          : this.specialInstructions,
      prescriberName: data.prescriberName.present
          ? data.prescriberName.value
          : this.prescriberName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('prescriptionType: $prescriptionType, ')
          ..write('medicationName: $medicationName, ')
          ..write('brandName: $brandName, ')
          ..write('strength: $strength, ')
          ..write('dosage: $dosage, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('route: $route, ')
          ..write('frequency: $frequency, ')
          ..write('specificTime: $specificTime, ')
          ..write('relationToMeals: $relationToMeals, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('prnIndication: $prnIndication, ')
          ..write('maxPrnDoseFrequency: $maxPrnDoseFrequency, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('prescriberName: $prescriberName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    prescriptionType,
    medicationName,
    brandName,
    strength,
    dosage,
    dosageForm,
    route,
    frequency,
    specificTime,
    relationToMeals,
    startDate,
    endDate,
    prnIndication,
    maxPrnDoseFrequency,
    specialInstructions,
    prescriberName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.prescriptionType == this.prescriptionType &&
          other.medicationName == this.medicationName &&
          other.brandName == this.brandName &&
          other.strength == this.strength &&
          other.dosage == this.dosage &&
          other.dosageForm == this.dosageForm &&
          other.route == this.route &&
          other.frequency == this.frequency &&
          other.specificTime == this.specificTime &&
          other.relationToMeals == this.relationToMeals &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.prnIndication == this.prnIndication &&
          other.maxPrnDoseFrequency == this.maxPrnDoseFrequency &&
          other.specialInstructions == this.specialInstructions &&
          other.prescriberName == this.prescriberName);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<PrescriptionType> prescriptionType;
  final Value<String> medicationName;
  final Value<String?> brandName;
  final Value<String?> strength;
  final Value<String> dosage;
  final Value<String> dosageForm;
  final Value<String> route;
  final Value<String> frequency;
  final Value<String?> specificTime;
  final Value<String?> relationToMeals;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> prnIndication;
  final Value<String?> maxPrnDoseFrequency;
  final Value<String?> specialInstructions;
  final Value<String?> prescriberName;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.prescriptionType = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.brandName = const Value.absent(),
    this.strength = const Value.absent(),
    this.dosage = const Value.absent(),
    this.dosageForm = const Value.absent(),
    this.route = const Value.absent(),
    this.frequency = const Value.absent(),
    this.specificTime = const Value.absent(),
    this.relationToMeals = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.prnIndication = const Value.absent(),
    this.maxPrnDoseFrequency = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    this.prescriberName = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required PrescriptionType prescriptionType,
    required String medicationName,
    this.brandName = const Value.absent(),
    this.strength = const Value.absent(),
    required String dosage,
    required String dosageForm,
    required String route,
    required String frequency,
    this.specificTime = const Value.absent(),
    this.relationToMeals = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.prnIndication = const Value.absent(),
    this.maxPrnDoseFrequency = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    this.prescriberName = const Value.absent(),
  }) : profileId = Value(profileId),
       prescriptionType = Value(prescriptionType),
       medicationName = Value(medicationName),
       dosage = Value(dosage),
       dosageForm = Value(dosageForm),
       route = Value(route),
       frequency = Value(frequency),
       startDate = Value(startDate);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? prescriptionType,
    Expression<String>? medicationName,
    Expression<String>? brandName,
    Expression<String>? strength,
    Expression<String>? dosage,
    Expression<String>? dosageForm,
    Expression<String>? route,
    Expression<String>? frequency,
    Expression<String>? specificTime,
    Expression<String>? relationToMeals,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? prnIndication,
    Expression<String>? maxPrnDoseFrequency,
    Expression<String>? specialInstructions,
    Expression<String>? prescriberName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (prescriptionType != null) 'prescription_type': prescriptionType,
      if (medicationName != null) 'medication_name': medicationName,
      if (brandName != null) 'brand_name': brandName,
      if (strength != null) 'strength': strength,
      if (dosage != null) 'dosage': dosage,
      if (dosageForm != null) 'dosage_form': dosageForm,
      if (route != null) 'route': route,
      if (frequency != null) 'frequency': frequency,
      if (specificTime != null) 'specific_time': specificTime,
      if (relationToMeals != null) 'relation_to_meals': relationToMeals,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (prnIndication != null) 'prn_indication': prnIndication,
      if (maxPrnDoseFrequency != null)
        'max_prn_dose_frequency': maxPrnDoseFrequency,
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
      if (prescriberName != null) 'prescriber_name': prescriberName,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<PrescriptionType>? prescriptionType,
    Value<String>? medicationName,
    Value<String?>? brandName,
    Value<String?>? strength,
    Value<String>? dosage,
    Value<String>? dosageForm,
    Value<String>? route,
    Value<String>? frequency,
    Value<String?>? specificTime,
    Value<String?>? relationToMeals,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? prnIndication,
    Value<String?>? maxPrnDoseFrequency,
    Value<String?>? specialInstructions,
    Value<String?>? prescriberName,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      medicationName: medicationName ?? this.medicationName,
      brandName: brandName ?? this.brandName,
      strength: strength ?? this.strength,
      dosage: dosage ?? this.dosage,
      dosageForm: dosageForm ?? this.dosageForm,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      specificTime: specificTime ?? this.specificTime,
      relationToMeals: relationToMeals ?? this.relationToMeals,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prnIndication: prnIndication ?? this.prnIndication,
      maxPrnDoseFrequency: maxPrnDoseFrequency ?? this.maxPrnDoseFrequency,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      prescriberName: prescriberName ?? this.prescriberName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (prescriptionType.present) {
      map['prescription_type'] = Variable<String>(
        $MedicationsTable.$converterprescriptionType.toSql(
          prescriptionType.value,
        ),
      );
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (dosageForm.present) {
      map['dosage_form'] = Variable<String>(dosageForm.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (specificTime.present) {
      map['specific_time'] = Variable<String>(specificTime.value);
    }
    if (relationToMeals.present) {
      map['relation_to_meals'] = Variable<String>(relationToMeals.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (prnIndication.present) {
      map['prn_indication'] = Variable<String>(prnIndication.value);
    }
    if (maxPrnDoseFrequency.present) {
      map['max_prn_dose_frequency'] = Variable<String>(
        maxPrnDoseFrequency.value,
      );
    }
    if (specialInstructions.present) {
      map['special_instructions'] = Variable<String>(specialInstructions.value);
    }
    if (prescriberName.present) {
      map['prescriber_name'] = Variable<String>(prescriberName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('prescriptionType: $prescriptionType, ')
          ..write('medicationName: $medicationName, ')
          ..write('brandName: $brandName, ')
          ..write('strength: $strength, ')
          ..write('dosage: $dosage, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('route: $route, ')
          ..write('frequency: $frequency, ')
          ..write('specificTime: $specificTime, ')
          ..write('relationToMeals: $relationToMeals, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('prnIndication: $prnIndication, ')
          ..write('maxPrnDoseFrequency: $maxPrnDoseFrequency, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('prescriberName: $prescriberName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $VitalsTableTable vitalsTable = $VitalsTableTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final ProfilesDao profilesDao = ProfilesDao(this as AppDatabase);
  late final VitalsDao vitalsDao = VitalsDao(this as AppDatabase);
  late final MedicationsDao medicationsDao = MedicationsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    vitalsTable,
    medications,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vitals_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medications', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String name,
  required int age,
  required String primaryCondition,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> age,
  Value<String> primaryCondition,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VitalsTableTable, List<VitalsTableData>>
  _vitalsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vitalsTable,
    aliasName: 'profiles__id__vitals_table__profile_id',
  );

  $$VitalsTableTableProcessedTableManager get vitalsTableRefs {
    final manager = $$VitalsTableTableTableManager(
      $_db,
      $_db.vitalsTable,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vitalsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicationsTable, List<Medication>>
  _medicationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medications,
    aliasName: 'profiles__id__medications__profile_id',
  );

  $$MedicationsTableProcessedTableManager get medicationsRefs {
    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryCondition => $composableBuilder(
    column: $table.primaryCondition,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vitalsTableRefs(
    Expression<bool> Function($$VitalsTableTableFilterComposer f) f,
  ) {
    final $$VitalsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vitalsTable,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VitalsTableTableFilterComposer(
            $db: $db,
            $table: $db.vitalsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicationsRefs(
    Expression<bool> Function($$MedicationsTableFilterComposer f) f,
  ) {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryCondition => $composableBuilder(
    column: $table.primaryCondition,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get primaryCondition => $composableBuilder(
    column: $table.primaryCondition,
    builder: (column) => column,
  );

  Expression<T> vitalsTableRefs<T extends Object>(
    Expression<T> Function($$VitalsTableTableAnnotationComposer a) f,
  ) {
    final $$VitalsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vitalsTable,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VitalsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.vitalsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicationsRefs<T extends Object>(
    Expression<T> Function($$MedicationsTableAnnotationComposer a) f,
  ) {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({bool vitalsTableRefs, bool medicationsRefs})
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> primaryCondition = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                age: age,
                primaryCondition: primaryCondition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int age,
                required String primaryCondition,
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                age: age,
                primaryCondition: primaryCondition,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vitalsTableRefs = false, medicationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vitalsTableRefs) db.vitalsTable,
                    if (medicationsRefs) db.medications,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vitalsTableRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          VitalsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._vitalsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).vitalsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicationsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Medication
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._medicationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool vitalsTableRefs, bool medicationsRefs})
    >;
typedef $$VitalsTableTableCreateCompanionBuilder =
    VitalsTableCompanion Function({
      Value<int> id,
      required int profileId,
      Value<String?> bp,
      Value<String?> temperature,
      Value<String?> pulseRate,
      Value<String?> respiratoryRate,
      Value<String?> oxygenSaturation,
      Value<String?> pain,
      Value<DateTime> recordedAt,
    });
typedef $$VitalsTableTableUpdateCompanionBuilder =
    VitalsTableCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String?> bp,
      Value<String?> temperature,
      Value<String?> pulseRate,
      Value<String?> respiratoryRate,
      Value<String?> oxygenSaturation,
      Value<String?> pain,
      Value<DateTime> recordedAt,
    });

final class $$VitalsTableTableReferences
    extends BaseReferences<_$AppDatabase, $VitalsTableTable, VitalsTableData> {
  $$VitalsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('vitals_table__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VitalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VitalsTableTable> {
  $$VitalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bp => $composableBuilder(
    column: $table.bp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pulseRate => $composableBuilder(
    column: $table.pulseRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pain => $composableBuilder(
    column: $table.pain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VitalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VitalsTableTable> {
  $$VitalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bp => $composableBuilder(
    column: $table.bp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pulseRate => $composableBuilder(
    column: $table.pulseRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pain => $composableBuilder(
    column: $table.pain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VitalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VitalsTableTable> {
  $$VitalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bp =>
      $composableBuilder(column: $table.bp, builder: (column) => column);

  GeneratedColumn<String> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pulseRate =>
      $composableBuilder(column: $table.pulseRate, builder: (column) => column);

  GeneratedColumn<String> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oxygenSaturation => $composableBuilder(
    column: $table.oxygenSaturation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pain =>
      $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VitalsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VitalsTableTable,
          VitalsTableData,
          $$VitalsTableTableFilterComposer,
          $$VitalsTableTableOrderingComposer,
          $$VitalsTableTableAnnotationComposer,
          $$VitalsTableTableCreateCompanionBuilder,
          $$VitalsTableTableUpdateCompanionBuilder,
          (VitalsTableData, $$VitalsTableTableReferences),
          VitalsTableData,
          PrefetchHooks Function({bool profileId})
        > {
  $$VitalsTableTableTableManager(_$AppDatabase db, $VitalsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VitalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VitalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VitalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String?> bp = const Value.absent(),
                Value<String?> temperature = const Value.absent(),
                Value<String?> pulseRate = const Value.absent(),
                Value<String?> respiratoryRate = const Value.absent(),
                Value<String?> oxygenSaturation = const Value.absent(),
                Value<String?> pain = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
              }) => VitalsTableCompanion(
                id: id,
                profileId: profileId,
                bp: bp,
                temperature: temperature,
                pulseRate: pulseRate,
                respiratoryRate: respiratoryRate,
                oxygenSaturation: oxygenSaturation,
                pain: pain,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                Value<String?> bp = const Value.absent(),
                Value<String?> temperature = const Value.absent(),
                Value<String?> pulseRate = const Value.absent(),
                Value<String?> respiratoryRate = const Value.absent(),
                Value<String?> oxygenSaturation = const Value.absent(),
                Value<String?> pain = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
              }) => VitalsTableCompanion.insert(
                id: id,
                profileId: profileId,
                bp: bp,
                temperature: temperature,
                pulseRate: pulseRate,
                respiratoryRate: respiratoryRate,
                oxygenSaturation: oxygenSaturation,
                pain: pain,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VitalsTableTable, VitalsTableData>(table),
                  $$VitalsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$VitalsTableTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$VitalsTableTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VitalsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VitalsTableTable,
      VitalsTableData,
      $$VitalsTableTableFilterComposer,
      $$VitalsTableTableOrderingComposer,
      $$VitalsTableTableAnnotationComposer,
      $$VitalsTableTableCreateCompanionBuilder,
      $$VitalsTableTableUpdateCompanionBuilder,
      (VitalsTableData, $$VitalsTableTableReferences),
      VitalsTableData,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required int profileId,
      required PrescriptionType prescriptionType,
      required String medicationName,
      Value<String?> brandName,
      Value<String?> strength,
      required String dosage,
      required String dosageForm,
      required String route,
      required String frequency,
      Value<String?> specificTime,
      Value<String?> relationToMeals,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<String?> prnIndication,
      Value<String?> maxPrnDoseFrequency,
      Value<String?> specialInstructions,
      Value<String?> prescriberName,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<PrescriptionType> prescriptionType,
      Value<String> medicationName,
      Value<String?> brandName,
      Value<String?> strength,
      Value<String> dosage,
      Value<String> dosageForm,
      Value<String> route,
      Value<String> frequency,
      Value<String?> specificTime,
      Value<String?> relationToMeals,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<String?> prnIndication,
      Value<String?> maxPrnDoseFrequency,
      Value<String?> specialInstructions,
      Value<String?> prescriberName,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('medications__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrescriptionType, PrescriptionType, String>
  get prescriptionType => $composableBuilder(
    column: $table.prescriptionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specificTime => $composableBuilder(
    column: $table.specificTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationToMeals => $composableBuilder(
    column: $table.relationToMeals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prnIndication => $composableBuilder(
    column: $table.prnIndication,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maxPrnDoseFrequency => $composableBuilder(
    column: $table.maxPrnDoseFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialInstructions => $composableBuilder(
    column: $table.specialInstructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriberName => $composableBuilder(
    column: $table.prescriberName,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriptionType => $composableBuilder(
    column: $table.prescriptionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specificTime => $composableBuilder(
    column: $table.specificTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationToMeals => $composableBuilder(
    column: $table.relationToMeals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prnIndication => $composableBuilder(
    column: $table.prnIndication,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maxPrnDoseFrequency => $composableBuilder(
    column: $table.maxPrnDoseFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialInstructions => $composableBuilder(
    column: $table.specialInstructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriberName => $composableBuilder(
    column: $table.prescriberName,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrescriptionType, String>
  get prescriptionType => $composableBuilder(
    column: $table.prescriptionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get specificTime => $composableBuilder(
    column: $table.specificTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relationToMeals => $composableBuilder(
    column: $table.relationToMeals,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get prnIndication => $composableBuilder(
    column: $table.prnIndication,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maxPrnDoseFrequency => $composableBuilder(
    column: $table.maxPrnDoseFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialInstructions => $composableBuilder(
    column: $table.specialInstructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriberName => $composableBuilder(
    column: $table.prescriberName,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({bool profileId})
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<PrescriptionType> prescriptionType = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<String?> brandName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String> dosageForm = const Value.absent(),
                Value<String> route = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> specificTime = const Value.absent(),
                Value<String?> relationToMeals = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> prnIndication = const Value.absent(),
                Value<String?> maxPrnDoseFrequency = const Value.absent(),
                Value<String?> specialInstructions = const Value.absent(),
                Value<String?> prescriberName = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                profileId: profileId,
                prescriptionType: prescriptionType,
                medicationName: medicationName,
                brandName: brandName,
                strength: strength,
                dosage: dosage,
                dosageForm: dosageForm,
                route: route,
                frequency: frequency,
                specificTime: specificTime,
                relationToMeals: relationToMeals,
                startDate: startDate,
                endDate: endDate,
                prnIndication: prnIndication,
                maxPrnDoseFrequency: maxPrnDoseFrequency,
                specialInstructions: specialInstructions,
                prescriberName: prescriberName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required PrescriptionType prescriptionType,
                required String medicationName,
                Value<String?> brandName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                required String dosage,
                required String dosageForm,
                required String route,
                required String frequency,
                Value<String?> specificTime = const Value.absent(),
                Value<String?> relationToMeals = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> prnIndication = const Value.absent(),
                Value<String?> maxPrnDoseFrequency = const Value.absent(),
                Value<String?> specialInstructions = const Value.absent(),
                Value<String?> prescriberName = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                profileId: profileId,
                prescriptionType: prescriptionType,
                medicationName: medicationName,
                brandName: brandName,
                strength: strength,
                dosage: dosage,
                dosageForm: dosageForm,
                route: route,
                frequency: frequency,
                specificTime: specificTime,
                relationToMeals: relationToMeals,
                startDate: startDate,
                endDate: endDate,
                prnIndication: prnIndication,
                maxPrnDoseFrequency: maxPrnDoseFrequency,
                specialInstructions: specialInstructions,
                prescriberName: prescriberName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationsTable, Medication>(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$MedicationsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$MedicationsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({bool profileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$VitalsTableTableTableManager get vitalsTable =>
      $$VitalsTableTableTableManager(_db, _db.vitalsTable);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
}
