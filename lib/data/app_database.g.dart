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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $VitalsTableTable vitalsTable = $VitalsTableTable(this);
  late final ProfilesDao profilesDao = ProfilesDao(this as AppDatabase);
  late final VitalsDao vitalsDao = VitalsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [profiles, vitalsTable];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vitals_table', kind: UpdateKind.delete)],
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
          PrefetchHooks Function({bool vitalsTableRefs})
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
          prefetchHooksCallback: ({vitalsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vitalsTableRefs) db.vitalsTable],
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
                      managerFromTypedResult: (p0) => $$ProfilesTableReferences(
                        db,
                        table,
                        p0,
                      ).vitalsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
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
      PrefetchHooks Function({bool vitalsTableRefs})
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$VitalsTableTableTableManager get vitalsTable =>
      $$VitalsTableTableTableManager(_db, _db.vitalsTable);
}
