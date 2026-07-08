// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthProfileIdMeta = const VerificationMeta(
    'birthProfileId',
  );
  @override
  late final GeneratedColumn<String> birthProfileId = GeneratedColumn<String>(
    'birth_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fortuneToneMeta = const VerificationMeta(
    'fortuneTone',
  );
  @override
  late final GeneratedColumn<String> fortuneTone = GeneratedColumn<String>(
    'fortune_tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('soft'),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Seoul'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    birthProfileId,
    fortuneTone,
    timezone,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('birth_profile_id')) {
      context.handle(
        _birthProfileIdMeta,
        birthProfileId.isAcceptableOrUnknown(
          data['birth_profile_id']!,
          _birthProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthProfileIdMeta);
    }
    if (data.containsKey('fortune_tone')) {
      context.handle(
        _fortuneToneMeta,
        fortuneTone.isAcceptableOrUnknown(
          data['fortune_tone']!,
          _fortuneToneMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      birthProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_profile_id'],
      )!,
      fortuneTone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fortune_tone'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String nickname;
  final String birthProfileId;
  final String fortuneTone;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.birthProfileId,
    required this.fortuneTone,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nickname'] = Variable<String>(nickname);
    map['birth_profile_id'] = Variable<String>(birthProfileId);
    map['fortune_tone'] = Variable<String>(fortuneTone);
    map['timezone'] = Variable<String>(timezone);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      birthProfileId: Value(birthProfileId),
      fortuneTone: Value(fortuneTone),
      timezone: Value(timezone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      birthProfileId: serializer.fromJson<String>(json['birthProfileId']),
      fortuneTone: serializer.fromJson<String>(json['fortuneTone']),
      timezone: serializer.fromJson<String>(json['timezone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nickname': serializer.toJson<String>(nickname),
      'birthProfileId': serializer.toJson<String>(birthProfileId),
      'fortuneTone': serializer.toJson<String>(fortuneTone),
      'timezone': serializer.toJson<String>(timezone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? nickname,
    String? birthProfileId,
    String? fortuneTone,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    birthProfileId: birthProfileId ?? this.birthProfileId,
    fortuneTone: fortuneTone ?? this.fortuneTone,
    timezone: timezone ?? this.timezone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      birthProfileId: data.birthProfileId.present
          ? data.birthProfileId.value
          : this.birthProfileId,
      fortuneTone: data.fortuneTone.present
          ? data.fortuneTone.value
          : this.fortuneTone,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('birthProfileId: $birthProfileId, ')
          ..write('fortuneTone: $fortuneTone, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    birthProfileId,
    fortuneTone,
    timezone,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.birthProfileId == this.birthProfileId &&
          other.fortuneTone == this.fortuneTone &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> nickname;
  final Value<String> birthProfileId;
  final Value<String> fortuneTone;
  final Value<String> timezone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.birthProfileId = const Value.absent(),
    this.fortuneTone = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String nickname,
    required String birthProfileId,
    this.fortuneTone = const Value.absent(),
    this.timezone = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nickname = Value(nickname),
       birthProfileId = Value(birthProfileId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? nickname,
    Expression<String>? birthProfileId,
    Expression<String>? fortuneTone,
    Expression<String>? timezone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (birthProfileId != null) 'birth_profile_id': birthProfileId,
      if (fortuneTone != null) 'fortune_tone': fortuneTone,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? nickname,
    Value<String>? birthProfileId,
    Value<String>? fortuneTone,
    Value<String>? timezone,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      birthProfileId: birthProfileId ?? this.birthProfileId,
      fortuneTone: fortuneTone ?? this.fortuneTone,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (birthProfileId.present) {
      map['birth_profile_id'] = Variable<String>(birthProfileId.value);
    }
    if (fortuneTone.present) {
      map['fortune_tone'] = Variable<String>(fortuneTone.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('birthProfileId: $birthProfileId, ')
          ..write('fortuneTone: $fortuneTone, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BirthProfilesTable extends BirthProfiles
    with TableInfo<$BirthProfilesTable, BirthProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BirthProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthHourMeta = const VerificationMeta(
    'birthHour',
  );
  @override
  late final GeneratedColumn<int> birthHour = GeneratedColumn<int>(
    'birth_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthMinuteMeta = const VerificationMeta(
    'birthMinute',
  );
  @override
  late final GeneratedColumn<int> birthMinute = GeneratedColumn<int>(
    'birth_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthTimeKnownMeta = const VerificationMeta(
    'birthTimeKnown',
  );
  @override
  late final GeneratedColumn<bool> birthTimeKnown = GeneratedColumn<bool>(
    'birth_time_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("birth_time_known" IN (0, 1))',
    ),
  );
  static const VerificationMeta _calendarTypeMeta = const VerificationMeta(
    'calendarType',
  );
  @override
  late final GeneratedColumn<String> calendarType = GeneratedColumn<String>(
    'calendar_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLeapMonthMeta = const VerificationMeta(
    'isLeapMonth',
  );
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
    'is_leap_month',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leap_month" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Seoul'),
  );
  static const VerificationMeta _genderModeMeta = const VerificationMeta(
    'genderMode',
  );
  @override
  late final GeneratedColumn<String> genderMode = GeneratedColumn<String>(
    'gender_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    displayName,
    birthDate,
    birthHour,
    birthMinute,
    birthTimeKnown,
    calendarType,
    isLeapMonth,
    timezone,
    genderMode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'birth_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<BirthProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('birth_hour')) {
      context.handle(
        _birthHourMeta,
        birthHour.isAcceptableOrUnknown(data['birth_hour']!, _birthHourMeta),
      );
    }
    if (data.containsKey('birth_minute')) {
      context.handle(
        _birthMinuteMeta,
        birthMinute.isAcceptableOrUnknown(
          data['birth_minute']!,
          _birthMinuteMeta,
        ),
      );
    }
    if (data.containsKey('birth_time_known')) {
      context.handle(
        _birthTimeKnownMeta,
        birthTimeKnown.isAcceptableOrUnknown(
          data['birth_time_known']!,
          _birthTimeKnownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthTimeKnownMeta);
    }
    if (data.containsKey('calendar_type')) {
      context.handle(
        _calendarTypeMeta,
        calendarType.isAcceptableOrUnknown(
          data['calendar_type']!,
          _calendarTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarTypeMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
        _isLeapMonthMeta,
        isLeapMonth.isAcceptableOrUnknown(
          data['is_leap_month']!,
          _isLeapMonthMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('gender_mode')) {
      context.handle(
        _genderModeMeta,
        genderMode.isAcceptableOrUnknown(data['gender_mode']!, _genderModeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BirthProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BirthProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      birthHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_hour'],
      ),
      birthMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_minute'],
      ),
      birthTimeKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}birth_time_known'],
      )!,
      calendarType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_type'],
      )!,
      isLeapMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leap_month'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      genderMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender_mode'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BirthProfilesTable createAlias(String alias) {
    return $BirthProfilesTable(attachedDatabase, alias);
  }
}

class BirthProfile extends DataClass implements Insertable<BirthProfile> {
  final String id;
  final String userId;
  final String displayName;
  final DateTime birthDate;
  final int? birthHour;
  final int? birthMinute;
  final bool birthTimeKnown;
  final String calendarType;
  final bool isLeapMonth;
  final String timezone;
  final String? genderMode;
  final DateTime createdAt;
  const BirthProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.birthDate,
    this.birthHour,
    this.birthMinute,
    required this.birthTimeKnown,
    required this.calendarType,
    required this.isLeapMonth,
    required this.timezone,
    this.genderMode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['birth_date'] = Variable<DateTime>(birthDate);
    if (!nullToAbsent || birthHour != null) {
      map['birth_hour'] = Variable<int>(birthHour);
    }
    if (!nullToAbsent || birthMinute != null) {
      map['birth_minute'] = Variable<int>(birthMinute);
    }
    map['birth_time_known'] = Variable<bool>(birthTimeKnown);
    map['calendar_type'] = Variable<String>(calendarType);
    map['is_leap_month'] = Variable<bool>(isLeapMonth);
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || genderMode != null) {
      map['gender_mode'] = Variable<String>(genderMode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BirthProfilesCompanion toCompanion(bool nullToAbsent) {
    return BirthProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      displayName: Value(displayName),
      birthDate: Value(birthDate),
      birthHour: birthHour == null && nullToAbsent
          ? const Value.absent()
          : Value(birthHour),
      birthMinute: birthMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(birthMinute),
      birthTimeKnown: Value(birthTimeKnown),
      calendarType: Value(calendarType),
      isLeapMonth: Value(isLeapMonth),
      timezone: Value(timezone),
      genderMode: genderMode == null && nullToAbsent
          ? const Value.absent()
          : Value(genderMode),
      createdAt: Value(createdAt),
    );
  }

  factory BirthProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BirthProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      birthHour: serializer.fromJson<int?>(json['birthHour']),
      birthMinute: serializer.fromJson<int?>(json['birthMinute']),
      birthTimeKnown: serializer.fromJson<bool>(json['birthTimeKnown']),
      calendarType: serializer.fromJson<String>(json['calendarType']),
      isLeapMonth: serializer.fromJson<bool>(json['isLeapMonth']),
      timezone: serializer.fromJson<String>(json['timezone']),
      genderMode: serializer.fromJson<String?>(json['genderMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'birthHour': serializer.toJson<int?>(birthHour),
      'birthMinute': serializer.toJson<int?>(birthMinute),
      'birthTimeKnown': serializer.toJson<bool>(birthTimeKnown),
      'calendarType': serializer.toJson<String>(calendarType),
      'isLeapMonth': serializer.toJson<bool>(isLeapMonth),
      'timezone': serializer.toJson<String>(timezone),
      'genderMode': serializer.toJson<String?>(genderMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BirthProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    DateTime? birthDate,
    Value<int?> birthHour = const Value.absent(),
    Value<int?> birthMinute = const Value.absent(),
    bool? birthTimeKnown,
    String? calendarType,
    bool? isLeapMonth,
    String? timezone,
    Value<String?> genderMode = const Value.absent(),
    DateTime? createdAt,
  }) => BirthProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    birthDate: birthDate ?? this.birthDate,
    birthHour: birthHour.present ? birthHour.value : this.birthHour,
    birthMinute: birthMinute.present ? birthMinute.value : this.birthMinute,
    birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
    calendarType: calendarType ?? this.calendarType,
    isLeapMonth: isLeapMonth ?? this.isLeapMonth,
    timezone: timezone ?? this.timezone,
    genderMode: genderMode.present ? genderMode.value : this.genderMode,
    createdAt: createdAt ?? this.createdAt,
  );
  BirthProfile copyWithCompanion(BirthProfilesCompanion data) {
    return BirthProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthHour: data.birthHour.present ? data.birthHour.value : this.birthHour,
      birthMinute: data.birthMinute.present
          ? data.birthMinute.value
          : this.birthMinute,
      birthTimeKnown: data.birthTimeKnown.present
          ? data.birthTimeKnown.value
          : this.birthTimeKnown,
      calendarType: data.calendarType.present
          ? data.calendarType.value
          : this.calendarType,
      isLeapMonth: data.isLeapMonth.present
          ? data.isLeapMonth.value
          : this.isLeapMonth,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      genderMode: data.genderMode.present
          ? data.genderMode.value
          : this.genderMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BirthProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthHour: $birthHour, ')
          ..write('birthMinute: $birthMinute, ')
          ..write('birthTimeKnown: $birthTimeKnown, ')
          ..write('calendarType: $calendarType, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('timezone: $timezone, ')
          ..write('genderMode: $genderMode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    displayName,
    birthDate,
    birthHour,
    birthMinute,
    birthTimeKnown,
    calendarType,
    isLeapMonth,
    timezone,
    genderMode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BirthProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.birthDate == this.birthDate &&
          other.birthHour == this.birthHour &&
          other.birthMinute == this.birthMinute &&
          other.birthTimeKnown == this.birthTimeKnown &&
          other.calendarType == this.calendarType &&
          other.isLeapMonth == this.isLeapMonth &&
          other.timezone == this.timezone &&
          other.genderMode == this.genderMode &&
          other.createdAt == this.createdAt);
}

class BirthProfilesCompanion extends UpdateCompanion<BirthProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> displayName;
  final Value<DateTime> birthDate;
  final Value<int?> birthHour;
  final Value<int?> birthMinute;
  final Value<bool> birthTimeKnown;
  final Value<String> calendarType;
  final Value<bool> isLeapMonth;
  final Value<String> timezone;
  final Value<String?> genderMode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BirthProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthHour = const Value.absent(),
    this.birthMinute = const Value.absent(),
    this.birthTimeKnown = const Value.absent(),
    this.calendarType = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.timezone = const Value.absent(),
    this.genderMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BirthProfilesCompanion.insert({
    required String id,
    required String userId,
    required String displayName,
    required DateTime birthDate,
    this.birthHour = const Value.absent(),
    this.birthMinute = const Value.absent(),
    required bool birthTimeKnown,
    required String calendarType,
    this.isLeapMonth = const Value.absent(),
    this.timezone = const Value.absent(),
    this.genderMode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       displayName = Value(displayName),
       birthDate = Value(birthDate),
       birthTimeKnown = Value(birthTimeKnown),
       calendarType = Value(calendarType),
       createdAt = Value(createdAt);
  static Insertable<BirthProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<DateTime>? birthDate,
    Expression<int>? birthHour,
    Expression<int>? birthMinute,
    Expression<bool>? birthTimeKnown,
    Expression<String>? calendarType,
    Expression<bool>? isLeapMonth,
    Expression<String>? timezone,
    Expression<String>? genderMode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthHour != null) 'birth_hour': birthHour,
      if (birthMinute != null) 'birth_minute': birthMinute,
      if (birthTimeKnown != null) 'birth_time_known': birthTimeKnown,
      if (calendarType != null) 'calendar_type': calendarType,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (timezone != null) 'timezone': timezone,
      if (genderMode != null) 'gender_mode': genderMode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BirthProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? displayName,
    Value<DateTime>? birthDate,
    Value<int?>? birthHour,
    Value<int?>? birthMinute,
    Value<bool>? birthTimeKnown,
    Value<String>? calendarType,
    Value<bool>? isLeapMonth,
    Value<String>? timezone,
    Value<String?>? genderMode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BirthProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
      birthMinute: birthMinute ?? this.birthMinute,
      birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
      calendarType: calendarType ?? this.calendarType,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      timezone: timezone ?? this.timezone,
      genderMode: genderMode ?? this.genderMode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (birthHour.present) {
      map['birth_hour'] = Variable<int>(birthHour.value);
    }
    if (birthMinute.present) {
      map['birth_minute'] = Variable<int>(birthMinute.value);
    }
    if (birthTimeKnown.present) {
      map['birth_time_known'] = Variable<bool>(birthTimeKnown.value);
    }
    if (calendarType.present) {
      map['calendar_type'] = Variable<String>(calendarType.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (genderMode.present) {
      map['gender_mode'] = Variable<String>(genderMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BirthProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthHour: $birthHour, ')
          ..write('birthMinute: $birthMinute, ')
          ..write('birthTimeKnown: $birthTimeKnown, ')
          ..write('calendarType: $calendarType, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('timezone: $timezone, ')
          ..write('genderMode: $genderMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailySnapshotsTable extends DailySnapshots
    with TableInfo<$DailySnapshotsTable, DailySnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthProfileIdMeta = const VerificationMeta(
    'birthProfileId',
  );
  @override
  late final GeneratedColumn<String> birthProfileId = GeneratedColumn<String>(
    'birth_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<String> guardianId = GeneratedColumn<String>(
    'guardian_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineVersionMeta = const VerificationMeta(
    'engineVersion',
  );
  @override
  late final GeneratedColumn<String> engineVersion = GeneratedColumn<String>(
    'engine_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<String> ruleVersion = GeneratedColumn<String>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    birthProfileId,
    date,
    payloadJson,
    guardianId,
    engineVersion,
    ruleVersion,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('birth_profile_id')) {
      context.handle(
        _birthProfileIdMeta,
        birthProfileId.isAcceptableOrUnknown(
          data['birth_profile_id']!,
          _birthProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthProfileIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    }
    if (data.containsKey('engine_version')) {
      context.handle(
        _engineVersionMeta,
        engineVersion.isAcceptableOrUnknown(
          data['engine_version']!,
          _engineVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineVersionMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailySnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      birthProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_profile_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_id'],
      ),
      engineVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_version'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailySnapshotsTable createAlias(String alias) {
    return $DailySnapshotsTable(attachedDatabase, alias);
  }
}

class DailySnapshot extends DataClass implements Insertable<DailySnapshot> {
  final String id;
  final String userId;
  final String birthProfileId;
  final DateTime date;
  final String payloadJson;
  final String? guardianId;
  final String engineVersion;
  final String ruleVersion;
  final DateTime createdAt;
  const DailySnapshot({
    required this.id,
    required this.userId,
    required this.birthProfileId,
    required this.date,
    required this.payloadJson,
    this.guardianId,
    required this.engineVersion,
    required this.ruleVersion,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['birth_profile_id'] = Variable<String>(birthProfileId);
    map['date'] = Variable<DateTime>(date);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || guardianId != null) {
      map['guardian_id'] = Variable<String>(guardianId);
    }
    map['engine_version'] = Variable<String>(engineVersion);
    map['rule_version'] = Variable<String>(ruleVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailySnapshotsCompanion toCompanion(bool nullToAbsent) {
    return DailySnapshotsCompanion(
      id: Value(id),
      userId: Value(userId),
      birthProfileId: Value(birthProfileId),
      date: Value(date),
      payloadJson: Value(payloadJson),
      guardianId: guardianId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianId),
      engineVersion: Value(engineVersion),
      ruleVersion: Value(ruleVersion),
      createdAt: Value(createdAt),
    );
  }

  factory DailySnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySnapshot(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      birthProfileId: serializer.fromJson<String>(json['birthProfileId']),
      date: serializer.fromJson<DateTime>(json['date']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      guardianId: serializer.fromJson<String?>(json['guardianId']),
      engineVersion: serializer.fromJson<String>(json['engineVersion']),
      ruleVersion: serializer.fromJson<String>(json['ruleVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'birthProfileId': serializer.toJson<String>(birthProfileId),
      'date': serializer.toJson<DateTime>(date),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'guardianId': serializer.toJson<String?>(guardianId),
      'engineVersion': serializer.toJson<String>(engineVersion),
      'ruleVersion': serializer.toJson<String>(ruleVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailySnapshot copyWith({
    String? id,
    String? userId,
    String? birthProfileId,
    DateTime? date,
    String? payloadJson,
    Value<String?> guardianId = const Value.absent(),
    String? engineVersion,
    String? ruleVersion,
    DateTime? createdAt,
  }) => DailySnapshot(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    birthProfileId: birthProfileId ?? this.birthProfileId,
    date: date ?? this.date,
    payloadJson: payloadJson ?? this.payloadJson,
    guardianId: guardianId.present ? guardianId.value : this.guardianId,
    engineVersion: engineVersion ?? this.engineVersion,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    createdAt: createdAt ?? this.createdAt,
  );
  DailySnapshot copyWithCompanion(DailySnapshotsCompanion data) {
    return DailySnapshot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      birthProfileId: data.birthProfileId.present
          ? data.birthProfileId.value
          : this.birthProfileId,
      date: data.date.present ? data.date.value : this.date,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      engineVersion: data.engineVersion.present
          ? data.engineVersion.value
          : this.engineVersion,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySnapshot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('birthProfileId: $birthProfileId, ')
          ..write('date: $date, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('guardianId: $guardianId, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    birthProfileId,
    date,
    payloadJson,
    guardianId,
    engineVersion,
    ruleVersion,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySnapshot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.birthProfileId == this.birthProfileId &&
          other.date == this.date &&
          other.payloadJson == this.payloadJson &&
          other.guardianId == this.guardianId &&
          other.engineVersion == this.engineVersion &&
          other.ruleVersion == this.ruleVersion &&
          other.createdAt == this.createdAt);
}

class DailySnapshotsCompanion extends UpdateCompanion<DailySnapshot> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> birthProfileId;
  final Value<DateTime> date;
  final Value<String> payloadJson;
  final Value<String?> guardianId;
  final Value<String> engineVersion;
  final Value<String> ruleVersion;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailySnapshotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.birthProfileId = const Value.absent(),
    this.date = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.engineVersion = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySnapshotsCompanion.insert({
    required String id,
    required String userId,
    required String birthProfileId,
    required DateTime date,
    required String payloadJson,
    this.guardianId = const Value.absent(),
    required String engineVersion,
    required String ruleVersion,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       birthProfileId = Value(birthProfileId),
       date = Value(date),
       payloadJson = Value(payloadJson),
       engineVersion = Value(engineVersion),
       ruleVersion = Value(ruleVersion),
       createdAt = Value(createdAt);
  static Insertable<DailySnapshot> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? birthProfileId,
    Expression<DateTime>? date,
    Expression<String>? payloadJson,
    Expression<String>? guardianId,
    Expression<String>? engineVersion,
    Expression<String>? ruleVersion,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (birthProfileId != null) 'birth_profile_id': birthProfileId,
      if (date != null) 'date': date,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (guardianId != null) 'guardian_id': guardianId,
      if (engineVersion != null) 'engine_version': engineVersion,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? birthProfileId,
    Value<DateTime>? date,
    Value<String>? payloadJson,
    Value<String?>? guardianId,
    Value<String>? engineVersion,
    Value<String>? ruleVersion,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailySnapshotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      birthProfileId: birthProfileId ?? this.birthProfileId,
      date: date ?? this.date,
      payloadJson: payloadJson ?? this.payloadJson,
      guardianId: guardianId ?? this.guardianId,
      engineVersion: engineVersion ?? this.engineVersion,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (birthProfileId.present) {
      map['birth_profile_id'] = Variable<String>(birthProfileId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<String>(guardianId.value);
    }
    if (engineVersion.present) {
      map['engine_version'] = Variable<String>(engineVersion.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<String>(ruleVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('birthProfileId: $birthProfileId, ')
          ..write('date: $date, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('guardianId: $guardianId, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyRecordsTable extends DailyRecords
    with TableInfo<$DailyRecordsTable, DailyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyLevelMeta = const VerificationMeta(
    'energyLevel',
  );
  @override
  late final GeneratedColumn<int> energyLevel = GeneratedColumn<int>(
    'energy_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<String> guardianId = GeneratedColumn<String>(
    'guardian_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    mood,
    energyLevel,
    memo,
    guardianId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('energy_level')) {
      context.handle(
        _energyLevelMeta,
        energyLevel.isAcceptableOrUnknown(
          data['energy_level']!,
          _energyLevelMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      energyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_level'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyRecordsTable createAlias(String alias) {
    return $DailyRecordsTable(attachedDatabase, alias);
  }
}

class DailyRecord extends DataClass implements Insertable<DailyRecord> {
  final String id;
  final String userId;
  final DateTime date;
  final String? mood;
  final int? energyLevel;
  final String? memo;
  final String? guardianId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyRecord({
    required this.id,
    required this.userId,
    required this.date,
    this.mood,
    this.energyLevel,
    this.memo,
    this.guardianId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || energyLevel != null) {
      map['energy_level'] = Variable<int>(energyLevel);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || guardianId != null) {
      map['guardian_id'] = Variable<String>(guardianId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyRecordsCompanion toCompanion(bool nullToAbsent) {
    return DailyRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      energyLevel: energyLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(energyLevel),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      guardianId: guardianId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyRecord(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      mood: serializer.fromJson<String?>(json['mood']),
      energyLevel: serializer.fromJson<int?>(json['energyLevel']),
      memo: serializer.fromJson<String?>(json['memo']),
      guardianId: serializer.fromJson<String?>(json['guardianId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'mood': serializer.toJson<String?>(mood),
      'energyLevel': serializer.toJson<int?>(energyLevel),
      'memo': serializer.toJson<String?>(memo),
      'guardianId': serializer.toJson<String?>(guardianId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyRecord copyWith({
    String? id,
    String? userId,
    DateTime? date,
    Value<String?> mood = const Value.absent(),
    Value<int?> energyLevel = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    Value<String?> guardianId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    mood: mood.present ? mood.value : this.mood,
    energyLevel: energyLevel.present ? energyLevel.value : this.energyLevel,
    memo: memo.present ? memo.value : this.memo,
    guardianId: guardianId.present ? guardianId.value : this.guardianId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyRecord copyWithCompanion(DailyRecordsCompanion data) {
    return DailyRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      mood: data.mood.present ? data.mood.value : this.mood,
      energyLevel: data.energyLevel.present
          ? data.energyLevel.value
          : this.energyLevel,
      memo: data.memo.present ? data.memo.value : this.memo,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('memo: $memo, ')
          ..write('guardianId: $guardianId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    date,
    mood,
    energyLevel,
    memo,
    guardianId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.mood == this.mood &&
          other.energyLevel == this.energyLevel &&
          other.memo == this.memo &&
          other.guardianId == this.guardianId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyRecordsCompanion extends UpdateCompanion<DailyRecord> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<String?> mood;
  final Value<int?> energyLevel;
  final Value<String?> memo;
  final Value<String?> guardianId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.mood = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.memo = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyRecordsCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    this.mood = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.memo = const Value.absent(),
    this.guardianId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyRecord> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<String>? mood,
    Expression<int>? energyLevel,
    Expression<String>? memo,
    Expression<String>? guardianId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (mood != null) 'mood': mood,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (memo != null) 'memo': memo,
      if (guardianId != null) 'guardian_id': guardianId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<String?>? mood,
    Value<int?>? energyLevel,
    Value<String?>? memo,
    Value<String?>? guardianId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      memo: memo ?? this.memo,
      guardianId: guardianId ?? this.guardianId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<int>(energyLevel.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<String>(guardianId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('memo: $memo, ')
          ..write('guardianId: $guardianId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GuardianCardsTable extends GuardianCards
    with TableInfo<$GuardianCardsTable, GuardianCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuardianCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elementMeta = const VerificationMeta(
    'element',
  );
  @override
  late final GeneratedColumn<String> element = GeneratedColumn<String>(
    'element',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, element, rarity, assetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guardian_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuardianCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('element')) {
      context.handle(
        _elementMeta,
        element.isAcceptableOrUnknown(data['element']!, _elementMeta),
      );
    } else if (isInserting) {
      context.missing(_elementMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GuardianCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuardianCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      element: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}element'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      ),
    );
  }

  @override
  $GuardianCardsTable createAlias(String alias) {
    return $GuardianCardsTable(attachedDatabase, alias);
  }
}

class GuardianCard extends DataClass implements Insertable<GuardianCard> {
  final String id;
  final String name;
  final String element;
  final String rarity;
  final String? assetId;
  const GuardianCard({
    required this.id,
    required this.name,
    required this.element,
    required this.rarity,
    this.assetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['element'] = Variable<String>(element);
    map['rarity'] = Variable<String>(rarity);
    if (!nullToAbsent || assetId != null) {
      map['asset_id'] = Variable<String>(assetId);
    }
    return map;
  }

  GuardianCardsCompanion toCompanion(bool nullToAbsent) {
    return GuardianCardsCompanion(
      id: Value(id),
      name: Value(name),
      element: Value(element),
      rarity: Value(rarity),
      assetId: assetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetId),
    );
  }

  factory GuardianCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuardianCard(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      element: serializer.fromJson<String>(json['element']),
      rarity: serializer.fromJson<String>(json['rarity']),
      assetId: serializer.fromJson<String?>(json['assetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'element': serializer.toJson<String>(element),
      'rarity': serializer.toJson<String>(rarity),
      'assetId': serializer.toJson<String?>(assetId),
    };
  }

  GuardianCard copyWith({
    String? id,
    String? name,
    String? element,
    String? rarity,
    Value<String?> assetId = const Value.absent(),
  }) => GuardianCard(
    id: id ?? this.id,
    name: name ?? this.name,
    element: element ?? this.element,
    rarity: rarity ?? this.rarity,
    assetId: assetId.present ? assetId.value : this.assetId,
  );
  GuardianCard copyWithCompanion(GuardianCardsCompanion data) {
    return GuardianCard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      element: data.element.present ? data.element.value : this.element,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuardianCard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('element: $element, ')
          ..write('rarity: $rarity, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, element, rarity, assetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuardianCard &&
          other.id == this.id &&
          other.name == this.name &&
          other.element == this.element &&
          other.rarity == this.rarity &&
          other.assetId == this.assetId);
}

class GuardianCardsCompanion extends UpdateCompanion<GuardianCard> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> element;
  final Value<String> rarity;
  final Value<String?> assetId;
  final Value<int> rowid;
  const GuardianCardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.element = const Value.absent(),
    this.rarity = const Value.absent(),
    this.assetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuardianCardsCompanion.insert({
    required String id,
    required String name,
    required String element,
    required String rarity,
    this.assetId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       element = Value(element),
       rarity = Value(rarity);
  static Insertable<GuardianCard> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? element,
    Expression<String>? rarity,
    Expression<String>? assetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (element != null) 'element': element,
      if (rarity != null) 'rarity': rarity,
      if (assetId != null) 'asset_id': assetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuardianCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? element,
    Value<String>? rarity,
    Value<String?>? assetId,
    Value<int>? rowid,
  }) {
    return GuardianCardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      element: element ?? this.element,
      rarity: rarity ?? this.rarity,
      assetId: assetId ?? this.assetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (element.present) {
      map['element'] = Variable<String>(element.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuardianCardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('element: $element, ')
          ..write('rarity: $rarity, ')
          ..write('assetId: $assetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnedCardsTable extends OwnedCards
    with TableInfo<$OwnedCardsTable, OwnedCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _firstSourceMeta = const VerificationMeta(
    'firstSource',
  );
  @override
  late final GeneratedColumn<String> firstSource = GeneratedColumn<String>(
    'first_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    cardId,
    unlockedAt,
    count,
    firstSource,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnedCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('first_source')) {
      context.handle(
        _firstSourceMeta,
        firstSource.isAcceptableOrUnknown(
          data['first_source']!,
          _firstSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, cardId};
  @override
  OwnedCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedCard(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      firstSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_source'],
      )!,
    );
  }

  @override
  $OwnedCardsTable createAlias(String alias) {
    return $OwnedCardsTable(attachedDatabase, alias);
  }
}

class OwnedCard extends DataClass implements Insertable<OwnedCard> {
  final String userId;
  final String cardId;
  final DateTime unlockedAt;
  final int count;
  final String firstSource;
  const OwnedCard({
    required this.userId,
    required this.cardId,
    required this.unlockedAt,
    required this.count,
    required this.firstSource,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['card_id'] = Variable<String>(cardId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    map['count'] = Variable<int>(count);
    map['first_source'] = Variable<String>(firstSource);
    return map;
  }

  OwnedCardsCompanion toCompanion(bool nullToAbsent) {
    return OwnedCardsCompanion(
      userId: Value(userId),
      cardId: Value(cardId),
      unlockedAt: Value(unlockedAt),
      count: Value(count),
      firstSource: Value(firstSource),
    );
  }

  factory OwnedCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedCard(
      userId: serializer.fromJson<String>(json['userId']),
      cardId: serializer.fromJson<String>(json['cardId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
      count: serializer.fromJson<int>(json['count']),
      firstSource: serializer.fromJson<String>(json['firstSource']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'cardId': serializer.toJson<String>(cardId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
      'count': serializer.toJson<int>(count),
      'firstSource': serializer.toJson<String>(firstSource),
    };
  }

  OwnedCard copyWith({
    String? userId,
    String? cardId,
    DateTime? unlockedAt,
    int? count,
    String? firstSource,
  }) => OwnedCard(
    userId: userId ?? this.userId,
    cardId: cardId ?? this.cardId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    count: count ?? this.count,
    firstSource: firstSource ?? this.firstSource,
  );
  OwnedCard copyWithCompanion(OwnedCardsCompanion data) {
    return OwnedCard(
      userId: data.userId.present ? data.userId.value : this.userId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      count: data.count.present ? data.count.value : this.count,
      firstSource: data.firstSource.present
          ? data.firstSource.value
          : this.firstSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedCard(')
          ..write('userId: $userId, ')
          ..write('cardId: $cardId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('count: $count, ')
          ..write('firstSource: $firstSource')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, cardId, unlockedAt, count, firstSource);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedCard &&
          other.userId == this.userId &&
          other.cardId == this.cardId &&
          other.unlockedAt == this.unlockedAt &&
          other.count == this.count &&
          other.firstSource == this.firstSource);
}

class OwnedCardsCompanion extends UpdateCompanion<OwnedCard> {
  final Value<String> userId;
  final Value<String> cardId;
  final Value<DateTime> unlockedAt;
  final Value<int> count;
  final Value<String> firstSource;
  final Value<int> rowid;
  const OwnedCardsCompanion({
    this.userId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.count = const Value.absent(),
    this.firstSource = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedCardsCompanion.insert({
    required String userId,
    required String cardId,
    required DateTime unlockedAt,
    this.count = const Value.absent(),
    required String firstSource,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       cardId = Value(cardId),
       unlockedAt = Value(unlockedAt),
       firstSource = Value(firstSource);
  static Insertable<OwnedCard> custom({
    Expression<String>? userId,
    Expression<String>? cardId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? count,
    Expression<String>? firstSource,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (cardId != null) 'card_id': cardId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (count != null) 'count': count,
      if (firstSource != null) 'first_source': firstSource,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedCardsCompanion copyWith({
    Value<String>? userId,
    Value<String>? cardId,
    Value<DateTime>? unlockedAt,
    Value<int>? count,
    Value<String>? firstSource,
    Value<int>? rowid,
  }) {
    return OwnedCardsCompanion(
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      count: count ?? this.count,
      firstSource: firstSource ?? this.firstSource,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (firstSource.present) {
      map['first_source'] = Variable<String>(firstSource.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedCardsCompanion(')
          ..write('userId: $userId, ')
          ..write('cardId: $cardId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('count: $count, ')
          ..write('firstSource: $firstSource, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineLogsTable extends RoutineLogs
    with TableInfo<$RoutineLogsTable, RoutineLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineTemplateIdMeta = const VerificationMeta(
    'routineTemplateId',
  );
  @override
  late final GeneratedColumn<String> routineTemplateId =
      GeneratedColumn<String>(
        'routine_template_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    routineTemplateId,
    completed,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('routine_template_id')) {
      context.handle(
        _routineTemplateIdMeta,
        routineTemplateId.isAcceptableOrUnknown(
          data['routine_template_id']!,
          _routineTemplateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineTemplateIdMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      routineTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_template_id'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $RoutineLogsTable createAlias(String alias) {
    return $RoutineLogsTable(attachedDatabase, alias);
  }
}

class RoutineLog extends DataClass implements Insertable<RoutineLog> {
  final String id;
  final String userId;
  final DateTime date;
  final String routineTemplateId;
  final bool completed;
  final DateTime? completedAt;
  const RoutineLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.routineTemplateId,
    required this.completed,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['routine_template_id'] = Variable<String>(routineTemplateId);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RoutineLogsCompanion toCompanion(bool nullToAbsent) {
    return RoutineLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      routineTemplateId: Value(routineTemplateId),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory RoutineLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      routineTemplateId: serializer.fromJson<String>(json['routineTemplateId']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'routineTemplateId': serializer.toJson<String>(routineTemplateId),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  RoutineLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? routineTemplateId,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => RoutineLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    routineTemplateId: routineTemplateId ?? this.routineTemplateId,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  RoutineLog copyWithCompanion(RoutineLogsCompanion data) {
    return RoutineLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      routineTemplateId: data.routineTemplateId.present
          ? data.routineTemplateId.value
          : this.routineTemplateId,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('routineTemplateId: $routineTemplateId, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, date, routineTemplateId, completed, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.routineTemplateId == this.routineTemplateId &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt);
}

class RoutineLogsCompanion extends UpdateCompanion<RoutineLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<String> routineTemplateId;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const RoutineLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.routineTemplateId = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineLogsCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    required String routineTemplateId,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       routineTemplateId = Value(routineTemplateId);
  static Insertable<RoutineLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<String>? routineTemplateId,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (routineTemplateId != null) 'routine_template_id': routineTemplateId,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<String>? routineTemplateId,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return RoutineLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      routineTemplateId: routineTemplateId ?? this.routineTemplateId,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (routineTemplateId.present) {
      map['routine_template_id'] = Variable<String>(routineTemplateId.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('routineTemplateId: $routineTemplateId, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineStreaksTable extends RoutineStreaks
    with TableInfo<$RoutineStreaksTable, RoutineStreak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineStreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCompletedDateMeta = const VerificationMeta(
    'lastCompletedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedDate =
      GeneratedColumn<DateTime>(
        'last_completed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    currentStreak,
    longestStreak,
    lastCompletedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_streaks';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineStreak> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_date')) {
      context.handle(
        _lastCompletedDateMeta,
        lastCompletedDate.isAcceptableOrUnknown(
          data['last_completed_date']!,
          _lastCompletedDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  RoutineStreak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineStreak(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastCompletedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_date'],
      ),
    );
  }

  @override
  $RoutineStreaksTable createAlias(String alias) {
    return $RoutineStreaksTable(attachedDatabase, alias);
  }
}

class RoutineStreak extends DataClass implements Insertable<RoutineStreak> {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  const RoutineStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastCompletedDate != null) {
      map['last_completed_date'] = Variable<DateTime>(lastCompletedDate);
    }
    return map;
  }

  RoutineStreaksCompanion toCompanion(bool nullToAbsent) {
    return RoutineStreaksCompanion(
      userId: Value(userId),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastCompletedDate: lastCompletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedDate),
    );
  }

  factory RoutineStreak.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineStreak(
      userId: serializer.fromJson<String>(json['userId']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastCompletedDate: serializer.fromJson<DateTime?>(
        json['lastCompletedDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastCompletedDate': serializer.toJson<DateTime?>(lastCompletedDate),
    };
  }

  RoutineStreak copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    Value<DateTime?> lastCompletedDate = const Value.absent(),
  }) => RoutineStreak(
    userId: userId ?? this.userId,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastCompletedDate: lastCompletedDate.present
        ? lastCompletedDate.value
        : this.lastCompletedDate,
  );
  RoutineStreak copyWithCompanion(RoutineStreaksCompanion data) {
    return RoutineStreak(
      userId: data.userId.present ? data.userId.value : this.userId,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastCompletedDate: data.lastCompletedDate.present
          ? data.lastCompletedDate.value
          : this.lastCompletedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineStreak(')
          ..write('userId: $userId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, currentStreak, longestStreak, lastCompletedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineStreak &&
          other.userId == this.userId &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastCompletedDate == this.lastCompletedDate);
}

class RoutineStreaksCompanion extends UpdateCompanion<RoutineStreak> {
  final Value<String> userId;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<DateTime?> lastCompletedDate;
  final Value<int> rowid;
  const RoutineStreaksCompanion({
    this.userId = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineStreaksCompanion.insert({
    required String userId,
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<RoutineStreak> custom({
    Expression<String>? userId,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<DateTime>? lastCompletedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastCompletedDate != null) 'last_completed_date': lastCompletedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineStreaksCompanion copyWith({
    Value<String>? userId,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<DateTime?>? lastCompletedDate,
    Value<int>? rowid,
  }) {
    return RoutineStreaksCompanion(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastCompletedDate.present) {
      map['last_completed_date'] = Variable<DateTime>(lastCompletedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineStreaksCompanion(')
          ..write('userId: $userId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChemistryProfilesTable extends ChemistryProfiles
    with TableInfo<$ChemistryProfilesTable, ChemistryProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChemistryProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthHourMeta = const VerificationMeta(
    'birthHour',
  );
  @override
  late final GeneratedColumn<int> birthHour = GeneratedColumn<int>(
    'birth_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthMinuteMeta = const VerificationMeta(
    'birthMinute',
  );
  @override
  late final GeneratedColumn<int> birthMinute = GeneratedColumn<int>(
    'birth_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calendarTypeMeta = const VerificationMeta(
    'calendarType',
  );
  @override
  late final GeneratedColumn<String> calendarType = GeneratedColumn<String>(
    'calendar_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLeapMonthMeta = const VerificationMeta(
    'isLeapMonth',
  );
  @override
  late final GeneratedColumn<bool> isLeapMonth = GeneratedColumn<bool>(
    'is_leap_month',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leap_month" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUserId,
    label,
    relationType,
    birthDate,
    birthHour,
    birthMinute,
    calendarType,
    isLeapMonth,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chemistry_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChemistryProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationTypeMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('birth_hour')) {
      context.handle(
        _birthHourMeta,
        birthHour.isAcceptableOrUnknown(data['birth_hour']!, _birthHourMeta),
      );
    }
    if (data.containsKey('birth_minute')) {
      context.handle(
        _birthMinuteMeta,
        birthMinute.isAcceptableOrUnknown(
          data['birth_minute']!,
          _birthMinuteMeta,
        ),
      );
    }
    if (data.containsKey('calendar_type')) {
      context.handle(
        _calendarTypeMeta,
        calendarType.isAcceptableOrUnknown(
          data['calendar_type']!,
          _calendarTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calendarTypeMeta);
    }
    if (data.containsKey('is_leap_month')) {
      context.handle(
        _isLeapMonthMeta,
        isLeapMonth.isAcceptableOrUnknown(
          data['is_leap_month']!,
          _isLeapMonthMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChemistryProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChemistryProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      birthHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_hour'],
      ),
      birthMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_minute'],
      ),
      calendarType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_type'],
      )!,
      isLeapMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leap_month'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChemistryProfilesTable createAlias(String alias) {
    return $ChemistryProfilesTable(attachedDatabase, alias);
  }
}

class ChemistryProfile extends DataClass
    implements Insertable<ChemistryProfile> {
  final String id;
  final String ownerUserId;
  final String label;
  final String relationType;
  final DateTime birthDate;
  final int? birthHour;
  final int? birthMinute;
  final String calendarType;
  final bool isLeapMonth;
  final DateTime createdAt;
  const ChemistryProfile({
    required this.id,
    required this.ownerUserId,
    required this.label,
    required this.relationType,
    required this.birthDate,
    this.birthHour,
    this.birthMinute,
    required this.calendarType,
    required this.isLeapMonth,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['label'] = Variable<String>(label);
    map['relation_type'] = Variable<String>(relationType);
    map['birth_date'] = Variable<DateTime>(birthDate);
    if (!nullToAbsent || birthHour != null) {
      map['birth_hour'] = Variable<int>(birthHour);
    }
    if (!nullToAbsent || birthMinute != null) {
      map['birth_minute'] = Variable<int>(birthMinute);
    }
    map['calendar_type'] = Variable<String>(calendarType);
    map['is_leap_month'] = Variable<bool>(isLeapMonth);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChemistryProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChemistryProfilesCompanion(
      id: Value(id),
      ownerUserId: Value(ownerUserId),
      label: Value(label),
      relationType: Value(relationType),
      birthDate: Value(birthDate),
      birthHour: birthHour == null && nullToAbsent
          ? const Value.absent()
          : Value(birthHour),
      birthMinute: birthMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(birthMinute),
      calendarType: Value(calendarType),
      isLeapMonth: Value(isLeapMonth),
      createdAt: Value(createdAt),
    );
  }

  factory ChemistryProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChemistryProfile(
      id: serializer.fromJson<String>(json['id']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      label: serializer.fromJson<String>(json['label']),
      relationType: serializer.fromJson<String>(json['relationType']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      birthHour: serializer.fromJson<int?>(json['birthHour']),
      birthMinute: serializer.fromJson<int?>(json['birthMinute']),
      calendarType: serializer.fromJson<String>(json['calendarType']),
      isLeapMonth: serializer.fromJson<bool>(json['isLeapMonth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'label': serializer.toJson<String>(label),
      'relationType': serializer.toJson<String>(relationType),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'birthHour': serializer.toJson<int?>(birthHour),
      'birthMinute': serializer.toJson<int?>(birthMinute),
      'calendarType': serializer.toJson<String>(calendarType),
      'isLeapMonth': serializer.toJson<bool>(isLeapMonth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChemistryProfile copyWith({
    String? id,
    String? ownerUserId,
    String? label,
    String? relationType,
    DateTime? birthDate,
    Value<int?> birthHour = const Value.absent(),
    Value<int?> birthMinute = const Value.absent(),
    String? calendarType,
    bool? isLeapMonth,
    DateTime? createdAt,
  }) => ChemistryProfile(
    id: id ?? this.id,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    label: label ?? this.label,
    relationType: relationType ?? this.relationType,
    birthDate: birthDate ?? this.birthDate,
    birthHour: birthHour.present ? birthHour.value : this.birthHour,
    birthMinute: birthMinute.present ? birthMinute.value : this.birthMinute,
    calendarType: calendarType ?? this.calendarType,
    isLeapMonth: isLeapMonth ?? this.isLeapMonth,
    createdAt: createdAt ?? this.createdAt,
  );
  ChemistryProfile copyWithCompanion(ChemistryProfilesCompanion data) {
    return ChemistryProfile(
      id: data.id.present ? data.id.value : this.id,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      label: data.label.present ? data.label.value : this.label,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthHour: data.birthHour.present ? data.birthHour.value : this.birthHour,
      birthMinute: data.birthMinute.present
          ? data.birthMinute.value
          : this.birthMinute,
      calendarType: data.calendarType.present
          ? data.calendarType.value
          : this.calendarType,
      isLeapMonth: data.isLeapMonth.present
          ? data.isLeapMonth.value
          : this.isLeapMonth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChemistryProfile(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('label: $label, ')
          ..write('relationType: $relationType, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthHour: $birthHour, ')
          ..write('birthMinute: $birthMinute, ')
          ..write('calendarType: $calendarType, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUserId,
    label,
    relationType,
    birthDate,
    birthHour,
    birthMinute,
    calendarType,
    isLeapMonth,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChemistryProfile &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.label == this.label &&
          other.relationType == this.relationType &&
          other.birthDate == this.birthDate &&
          other.birthHour == this.birthHour &&
          other.birthMinute == this.birthMinute &&
          other.calendarType == this.calendarType &&
          other.isLeapMonth == this.isLeapMonth &&
          other.createdAt == this.createdAt);
}

class ChemistryProfilesCompanion extends UpdateCompanion<ChemistryProfile> {
  final Value<String> id;
  final Value<String> ownerUserId;
  final Value<String> label;
  final Value<String> relationType;
  final Value<DateTime> birthDate;
  final Value<int?> birthHour;
  final Value<int?> birthMinute;
  final Value<String> calendarType;
  final Value<bool> isLeapMonth;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChemistryProfilesCompanion({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.label = const Value.absent(),
    this.relationType = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthHour = const Value.absent(),
    this.birthMinute = const Value.absent(),
    this.calendarType = const Value.absent(),
    this.isLeapMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChemistryProfilesCompanion.insert({
    required String id,
    required String ownerUserId,
    required String label,
    required String relationType,
    required DateTime birthDate,
    this.birthHour = const Value.absent(),
    this.birthMinute = const Value.absent(),
    required String calendarType,
    this.isLeapMonth = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUserId = Value(ownerUserId),
       label = Value(label),
       relationType = Value(relationType),
       birthDate = Value(birthDate),
       calendarType = Value(calendarType),
       createdAt = Value(createdAt);
  static Insertable<ChemistryProfile> custom({
    Expression<String>? id,
    Expression<String>? ownerUserId,
    Expression<String>? label,
    Expression<String>? relationType,
    Expression<DateTime>? birthDate,
    Expression<int>? birthHour,
    Expression<int>? birthMinute,
    Expression<String>? calendarType,
    Expression<bool>? isLeapMonth,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (label != null) 'label': label,
      if (relationType != null) 'relation_type': relationType,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthHour != null) 'birth_hour': birthHour,
      if (birthMinute != null) 'birth_minute': birthMinute,
      if (calendarType != null) 'calendar_type': calendarType,
      if (isLeapMonth != null) 'is_leap_month': isLeapMonth,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChemistryProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUserId,
    Value<String>? label,
    Value<String>? relationType,
    Value<DateTime>? birthDate,
    Value<int?>? birthHour,
    Value<int?>? birthMinute,
    Value<String>? calendarType,
    Value<bool>? isLeapMonth,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChemistryProfilesCompanion(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      label: label ?? this.label,
      relationType: relationType ?? this.relationType,
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
      birthMinute: birthMinute ?? this.birthMinute,
      calendarType: calendarType ?? this.calendarType,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (birthHour.present) {
      map['birth_hour'] = Variable<int>(birthHour.value);
    }
    if (birthMinute.present) {
      map['birth_minute'] = Variable<int>(birthMinute.value);
    }
    if (calendarType.present) {
      map['calendar_type'] = Variable<String>(calendarType.value);
    }
    if (isLeapMonth.present) {
      map['is_leap_month'] = Variable<bool>(isLeapMonth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChemistryProfilesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('label: $label, ')
          ..write('relationType: $relationType, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthHour: $birthHour, ')
          ..write('birthMinute: $birthMinute, ')
          ..write('calendarType: $calendarType, ')
          ..write('isLeapMonth: $isLeapMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChemistryResultsTable extends ChemistryResults
    with TableInfo<$ChemistryResultsTable, ChemistryResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChemistryResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerProfileIdMeta = const VerificationMeta(
    'partnerProfileId',
  );
  @override
  late final GeneratedColumn<String> partnerProfileId = GeneratedColumn<String>(
    'partner_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineVersionMeta = const VerificationMeta(
    'engineVersion',
  );
  @override
  late final GeneratedColumn<String> engineVersion = GeneratedColumn<String>(
    'engine_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculatedAtMeta = const VerificationMeta(
    'calculatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
    'calculated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUserId,
    partnerProfileId,
    payloadJson,
    engineVersion,
    calculatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chemistry_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChemistryResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('partner_profile_id')) {
      context.handle(
        _partnerProfileIdMeta,
        partnerProfileId.isAcceptableOrUnknown(
          data['partner_profile_id']!,
          _partnerProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partnerProfileIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('engine_version')) {
      context.handle(
        _engineVersionMeta,
        engineVersion.isAcceptableOrUnknown(
          data['engine_version']!,
          _engineVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineVersionMeta);
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
        _calculatedAtMeta,
        calculatedAt.isAcceptableOrUnknown(
          data['calculated_at']!,
          _calculatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChemistryResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChemistryResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      )!,
      partnerProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_profile_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      engineVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_version'],
      )!,
      calculatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_at'],
      )!,
    );
  }

  @override
  $ChemistryResultsTable createAlias(String alias) {
    return $ChemistryResultsTable(attachedDatabase, alias);
  }
}

class ChemistryResult extends DataClass implements Insertable<ChemistryResult> {
  final String id;
  final String ownerUserId;
  final String partnerProfileId;
  final String payloadJson;
  final String engineVersion;
  final DateTime calculatedAt;
  const ChemistryResult({
    required this.id,
    required this.ownerUserId,
    required this.partnerProfileId,
    required this.payloadJson,
    required this.engineVersion,
    required this.calculatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['partner_profile_id'] = Variable<String>(partnerProfileId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['engine_version'] = Variable<String>(engineVersion);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    return map;
  }

  ChemistryResultsCompanion toCompanion(bool nullToAbsent) {
    return ChemistryResultsCompanion(
      id: Value(id),
      ownerUserId: Value(ownerUserId),
      partnerProfileId: Value(partnerProfileId),
      payloadJson: Value(payloadJson),
      engineVersion: Value(engineVersion),
      calculatedAt: Value(calculatedAt),
    );
  }

  factory ChemistryResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChemistryResult(
      id: serializer.fromJson<String>(json['id']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      partnerProfileId: serializer.fromJson<String>(json['partnerProfileId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      engineVersion: serializer.fromJson<String>(json['engineVersion']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'partnerProfileId': serializer.toJson<String>(partnerProfileId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'engineVersion': serializer.toJson<String>(engineVersion),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
    };
  }

  ChemistryResult copyWith({
    String? id,
    String? ownerUserId,
    String? partnerProfileId,
    String? payloadJson,
    String? engineVersion,
    DateTime? calculatedAt,
  }) => ChemistryResult(
    id: id ?? this.id,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    partnerProfileId: partnerProfileId ?? this.partnerProfileId,
    payloadJson: payloadJson ?? this.payloadJson,
    engineVersion: engineVersion ?? this.engineVersion,
    calculatedAt: calculatedAt ?? this.calculatedAt,
  );
  ChemistryResult copyWithCompanion(ChemistryResultsCompanion data) {
    return ChemistryResult(
      id: data.id.present ? data.id.value : this.id,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      partnerProfileId: data.partnerProfileId.present
          ? data.partnerProfileId.value
          : this.partnerProfileId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      engineVersion: data.engineVersion.present
          ? data.engineVersion.value
          : this.engineVersion,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChemistryResult(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('partnerProfileId: $partnerProfileId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUserId,
    partnerProfileId,
    payloadJson,
    engineVersion,
    calculatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChemistryResult &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.partnerProfileId == this.partnerProfileId &&
          other.payloadJson == this.payloadJson &&
          other.engineVersion == this.engineVersion &&
          other.calculatedAt == this.calculatedAt);
}

class ChemistryResultsCompanion extends UpdateCompanion<ChemistryResult> {
  final Value<String> id;
  final Value<String> ownerUserId;
  final Value<String> partnerProfileId;
  final Value<String> payloadJson;
  final Value<String> engineVersion;
  final Value<DateTime> calculatedAt;
  final Value<int> rowid;
  const ChemistryResultsCompanion({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.partnerProfileId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.engineVersion = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChemistryResultsCompanion.insert({
    required String id,
    required String ownerUserId,
    required String partnerProfileId,
    required String payloadJson,
    required String engineVersion,
    required DateTime calculatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUserId = Value(ownerUserId),
       partnerProfileId = Value(partnerProfileId),
       payloadJson = Value(payloadJson),
       engineVersion = Value(engineVersion),
       calculatedAt = Value(calculatedAt);
  static Insertable<ChemistryResult> custom({
    Expression<String>? id,
    Expression<String>? ownerUserId,
    Expression<String>? partnerProfileId,
    Expression<String>? payloadJson,
    Expression<String>? engineVersion,
    Expression<DateTime>? calculatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (partnerProfileId != null) 'partner_profile_id': partnerProfileId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (engineVersion != null) 'engine_version': engineVersion,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChemistryResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUserId,
    Value<String>? partnerProfileId,
    Value<String>? payloadJson,
    Value<String>? engineVersion,
    Value<DateTime>? calculatedAt,
    Value<int>? rowid,
  }) {
    return ChemistryResultsCompanion(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      partnerProfileId: partnerProfileId ?? this.partnerProfileId,
      payloadJson: payloadJson ?? this.payloadJson,
      engineVersion: engineVersion ?? this.engineVersion,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (partnerProfileId.present) {
      map['partner_profile_id'] = Variable<String>(partnerProfileId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (engineVersion.present) {
      map['engine_version'] = Variable<String>(engineVersion.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChemistryResultsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('partnerProfileId: $partnerProfileId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('engineVersion: $engineVersion, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTable extends NotificationSettings
    with TableInfo<$NotificationSettingsTable, NotificationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [type, enabled, hour, minute];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type};
  @override
  NotificationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSetting(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
    );
  }

  @override
  $NotificationSettingsTable createAlias(String alias) {
    return $NotificationSettingsTable(attachedDatabase, alias);
  }
}

class NotificationSetting extends DataClass
    implements Insertable<NotificationSetting> {
  final String type;
  final bool enabled;
  final int hour;
  final int minute;
  const NotificationSetting({
    required this.type,
    required this.enabled,
    required this.hour,
    required this.minute,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['enabled'] = Variable<bool>(enabled);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    return map;
  }

  NotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsCompanion(
      type: Value(type),
      enabled: Value(enabled),
      hour: Value(hour),
      minute: Value(minute),
    );
  }

  factory NotificationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSetting(
      type: serializer.fromJson<String>(json['type']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'enabled': serializer.toJson<bool>(enabled),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
    };
  }

  NotificationSetting copyWith({
    String? type,
    bool? enabled,
    int? hour,
    int? minute,
  }) => NotificationSetting(
    type: type ?? this.type,
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );
  NotificationSetting copyWithCompanion(NotificationSettingsCompanion data) {
    return NotificationSetting(
      type: data.type.present ? data.type.value : this.type,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSetting(')
          ..write('type: $type, ')
          ..write('enabled: $enabled, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(type, enabled, hour, minute);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSetting &&
          other.type == this.type &&
          other.enabled == this.enabled &&
          other.hour == this.hour &&
          other.minute == this.minute);
}

class NotificationSettingsCompanion
    extends UpdateCompanion<NotificationSetting> {
  final Value<String> type;
  final Value<bool> enabled;
  final Value<int> hour;
  final Value<int> minute;
  final Value<int> rowid;
  const NotificationSettingsCompanion({
    this.type = const Value.absent(),
    this.enabled = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationSettingsCompanion.insert({
    required String type,
    this.enabled = const Value.absent(),
    required int hour,
    this.minute = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       hour = Value(hour);
  static Insertable<NotificationSetting> custom({
    Expression<String>? type,
    Expression<bool>? enabled,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (enabled != null) 'enabled': enabled,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationSettingsCompanion copyWith({
    Value<String>? type,
    Value<bool>? enabled,
    Value<int>? hour,
    Value<int>? minute,
    Value<int>? rowid,
  }) {
    return NotificationSettingsCompanion(
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsCompanion(')
          ..write('type: $type, ')
          ..write('enabled: $enabled, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarketInstrumentsTable extends MarketInstruments
    with TableInfo<$MarketInstrumentsTable, MarketInstrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketInstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _corpNameMeta = const VerificationMeta(
    'corpName',
  );
  @override
  late final GeneratedColumn<String> corpName = GeneratedColumn<String>(
    'corp_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseDateMeta = const VerificationMeta(
    'baseDate',
  );
  @override
  late final GeneratedColumn<String> baseDate = GeneratedColumn<String>(
    'base_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    market,
    name,
    normalizedName,
    corpName,
    isin,
    baseDate,
    source,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketInstrument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    } else if (isInserting) {
      context.missing(_marketMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('corp_name')) {
      context.handle(
        _corpNameMeta,
        corpName.isAcceptableOrUnknown(data['corp_name']!, _corpNameMeta),
      );
    } else if (isInserting) {
      context.missing(_corpNameMeta);
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('base_date')) {
      context.handle(
        _baseDateMeta,
        baseDate.isAcceptableOrUnknown(data['base_date']!, _baseDateMeta),
      );
    } else if (isInserting) {
      context.missing(_baseDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarketInstrument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketInstrument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      corpName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corp_name'],
      )!,
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      ),
      baseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MarketInstrumentsTable createAlias(String alias) {
    return $MarketInstrumentsTable(attachedDatabase, alias);
  }
}

class MarketInstrument extends DataClass
    implements Insertable<MarketInstrument> {
  final String id;
  final String symbol;
  final String market;
  final String name;
  final String normalizedName;
  final String corpName;
  final String? isin;
  final String baseDate;
  final String source;
  final DateTime updatedAt;
  const MarketInstrument({
    required this.id,
    required this.symbol,
    required this.market,
    required this.name,
    required this.normalizedName,
    required this.corpName,
    this.isin,
    required this.baseDate,
    required this.source,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['market'] = Variable<String>(market);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['corp_name'] = Variable<String>(corpName);
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    map['base_date'] = Variable<String>(baseDate);
    map['source'] = Variable<String>(source);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MarketInstrumentsCompanion toCompanion(bool nullToAbsent) {
    return MarketInstrumentsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      market: Value(market),
      name: Value(name),
      normalizedName: Value(normalizedName),
      corpName: Value(corpName),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      baseDate: Value(baseDate),
      source: Value(source),
      updatedAt: Value(updatedAt),
    );
  }

  factory MarketInstrument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketInstrument(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      market: serializer.fromJson<String>(json['market']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      corpName: serializer.fromJson<String>(json['corpName']),
      isin: serializer.fromJson<String?>(json['isin']),
      baseDate: serializer.fromJson<String>(json['baseDate']),
      source: serializer.fromJson<String>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'market': serializer.toJson<String>(market),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'corpName': serializer.toJson<String>(corpName),
      'isin': serializer.toJson<String?>(isin),
      'baseDate': serializer.toJson<String>(baseDate),
      'source': serializer.toJson<String>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MarketInstrument copyWith({
    String? id,
    String? symbol,
    String? market,
    String? name,
    String? normalizedName,
    String? corpName,
    Value<String?> isin = const Value.absent(),
    String? baseDate,
    String? source,
    DateTime? updatedAt,
  }) => MarketInstrument(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    market: market ?? this.market,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    corpName: corpName ?? this.corpName,
    isin: isin.present ? isin.value : this.isin,
    baseDate: baseDate ?? this.baseDate,
    source: source ?? this.source,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MarketInstrument copyWithCompanion(MarketInstrumentsCompanion data) {
    return MarketInstrument(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      market: data.market.present ? data.market.value : this.market,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      corpName: data.corpName.present ? data.corpName.value : this.corpName,
      isin: data.isin.present ? data.isin.value : this.isin,
      baseDate: data.baseDate.present ? data.baseDate.value : this.baseDate,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketInstrument(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('corpName: $corpName, ')
          ..write('isin: $isin, ')
          ..write('baseDate: $baseDate, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    market,
    name,
    normalizedName,
    corpName,
    isin,
    baseDate,
    source,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketInstrument &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.market == this.market &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.corpName == this.corpName &&
          other.isin == this.isin &&
          other.baseDate == this.baseDate &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt);
}

class MarketInstrumentsCompanion extends UpdateCompanion<MarketInstrument> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> market;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> corpName;
  final Value<String?> isin;
  final Value<String> baseDate;
  final Value<String> source;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MarketInstrumentsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.market = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.corpName = const Value.absent(),
    this.isin = const Value.absent(),
    this.baseDate = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketInstrumentsCompanion.insert({
    required String id,
    required String symbol,
    required String market,
    required String name,
    required String normalizedName,
    required String corpName,
    this.isin = const Value.absent(),
    required String baseDate,
    required String source,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       symbol = Value(symbol),
       market = Value(market),
       name = Value(name),
       normalizedName = Value(normalizedName),
       corpName = Value(corpName),
       baseDate = Value(baseDate),
       source = Value(source),
       updatedAt = Value(updatedAt);
  static Insertable<MarketInstrument> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? market,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? corpName,
    Expression<String>? isin,
    Expression<String>? baseDate,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (market != null) 'market': market,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (corpName != null) 'corp_name': corpName,
      if (isin != null) 'isin': isin,
      if (baseDate != null) 'base_date': baseDate,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketInstrumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? symbol,
    Value<String>? market,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? corpName,
    Value<String?>? isin,
    Value<String>? baseDate,
    Value<String>? source,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MarketInstrumentsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      corpName: corpName ?? this.corpName,
      isin: isin ?? this.isin,
      baseDate: baseDate ?? this.baseDate,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (corpName.present) {
      map['corp_name'] = Variable<String>(corpName.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (baseDate.present) {
      map['base_date'] = Variable<String>(baseDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketInstrumentsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('market: $market, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('corpName: $corpName, ')
          ..write('isin: $isin, ')
          ..write('baseDate: $baseDate, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarketWatchItemsTable extends MarketWatchItems
    with TableInfo<$MarketWatchItemsTable, MarketWatchItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketWatchItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userTagsJsonMeta = const VerificationMeta(
    'userTagsJson',
  );
  @override
  late final GeneratedColumn<String> userTagsJson = GeneratedColumn<String>(
    'user_tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    instrumentId,
    memo,
    userTagsJson,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_watch_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketWatchItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('user_tags_json')) {
      context.handle(
        _userTagsJsonMeta,
        userTagsJson.isAcceptableOrUnknown(
          data['user_tags_json']!,
          _userTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarketWatchItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketWatchItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      userTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_tags_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $MarketWatchItemsTable createAlias(String alias) {
    return $MarketWatchItemsTable(attachedDatabase, alias);
  }
}

class MarketWatchItem extends DataClass implements Insertable<MarketWatchItem> {
  final String id;
  final String userId;
  final String instrumentId;
  final String? memo;
  final String userTagsJson;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const MarketWatchItem({
    required this.id,
    required this.userId,
    required this.instrumentId,
    this.memo,
    required this.userTagsJson,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['instrument_id'] = Variable<String>(instrumentId);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['user_tags_json'] = Variable<String>(userTagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  MarketWatchItemsCompanion toCompanion(bool nullToAbsent) {
    return MarketWatchItemsCompanion(
      id: Value(id),
      userId: Value(userId),
      instrumentId: Value(instrumentId),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      userTagsJson: Value(userTagsJson),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory MarketWatchItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketWatchItem(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      memo: serializer.fromJson<String?>(json['memo']),
      userTagsJson: serializer.fromJson<String>(json['userTagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'memo': serializer.toJson<String?>(memo),
      'userTagsJson': serializer.toJson<String>(userTagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  MarketWatchItem copyWith({
    String? id,
    String? userId,
    String? instrumentId,
    Value<String?> memo = const Value.absent(),
    String? userTagsJson,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => MarketWatchItem(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    instrumentId: instrumentId ?? this.instrumentId,
    memo: memo.present ? memo.value : this.memo,
    userTagsJson: userTagsJson ?? this.userTagsJson,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  MarketWatchItem copyWithCompanion(MarketWatchItemsCompanion data) {
    return MarketWatchItem(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      memo: data.memo.present ? data.memo.value : this.memo,
      userTagsJson: data.userTagsJson.present
          ? data.userTagsJson.value
          : this.userTagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketWatchItem(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('memo: $memo, ')
          ..write('userTagsJson: $userTagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    instrumentId,
    memo,
    userTagsJson,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketWatchItem &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.instrumentId == this.instrumentId &&
          other.memo == this.memo &&
          other.userTagsJson == this.userTagsJson &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class MarketWatchItemsCompanion extends UpdateCompanion<MarketWatchItem> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> instrumentId;
  final Value<String?> memo;
  final Value<String> userTagsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const MarketWatchItemsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.memo = const Value.absent(),
    this.userTagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketWatchItemsCompanion.insert({
    required String id,
    required String userId,
    required String instrumentId,
    this.memo = const Value.absent(),
    this.userTagsJson = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       instrumentId = Value(instrumentId),
       createdAt = Value(createdAt);
  static Insertable<MarketWatchItem> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? instrumentId,
    Expression<String>? memo,
    Expression<String>? userTagsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (memo != null) 'memo': memo,
      if (userTagsJson != null) 'user_tags_json': userTagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketWatchItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? instrumentId,
    Value<String?>? memo,
    Value<String>? userTagsJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return MarketWatchItemsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      instrumentId: instrumentId ?? this.instrumentId,
      memo: memo ?? this.memo,
      userTagsJson: userTagsJson ?? this.userTagsJson,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (userTagsJson.present) {
      map['user_tags_json'] = Variable<String>(userTagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketWatchItemsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('memo: $memo, ')
          ..write('userTagsJson: $userTagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $BirthProfilesTable birthProfiles = $BirthProfilesTable(this);
  late final $DailySnapshotsTable dailySnapshots = $DailySnapshotsTable(this);
  late final $DailyRecordsTable dailyRecords = $DailyRecordsTable(this);
  late final $GuardianCardsTable guardianCards = $GuardianCardsTable(this);
  late final $OwnedCardsTable ownedCards = $OwnedCardsTable(this);
  late final $RoutineLogsTable routineLogs = $RoutineLogsTable(this);
  late final $RoutineStreaksTable routineStreaks = $RoutineStreaksTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $ChemistryProfilesTable chemistryProfiles =
      $ChemistryProfilesTable(this);
  late final $ChemistryResultsTable chemistryResults = $ChemistryResultsTable(
    this,
  );
  late final $NotificationSettingsTable notificationSettings =
      $NotificationSettingsTable(this);
  late final $MarketInstrumentsTable marketInstruments =
      $MarketInstrumentsTable(this);
  late final $MarketWatchItemsTable marketWatchItems = $MarketWatchItemsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    birthProfiles,
    dailySnapshots,
    dailyRecords,
    guardianCards,
    ownedCards,
    routineLogs,
    routineStreaks,
    appMeta,
    chemistryProfiles,
    chemistryResults,
    notificationSettings,
    marketInstruments,
    marketWatchItems,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String nickname,
      required String birthProfileId,
      Value<String> fortuneTone,
      Value<String> timezone,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> nickname,
      Value<String> birthProfileId,
      Value<String> fortuneTone,
      Value<String> timezone,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthProfileId => $composableBuilder(
    column: $table.birthProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fortuneTone => $composableBuilder(
    column: $table.fortuneTone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthProfileId => $composableBuilder(
    column: $table.birthProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fortuneTone => $composableBuilder(
    column: $table.fortuneTone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get birthProfileId => $composableBuilder(
    column: $table.birthProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fortuneTone => $composableBuilder(
    column: $table.fortuneTone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> birthProfileId = const Value.absent(),
                Value<String> fortuneTone = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                nickname: nickname,
                birthProfileId: birthProfileId,
                fortuneTone: fortuneTone,
                timezone: timezone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nickname,
                required String birthProfileId,
                Value<String> fortuneTone = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                birthProfileId: birthProfileId,
                fortuneTone: fortuneTone,
                timezone: timezone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$BirthProfilesTableCreateCompanionBuilder =
    BirthProfilesCompanion Function({
      required String id,
      required String userId,
      required String displayName,
      required DateTime birthDate,
      Value<int?> birthHour,
      Value<int?> birthMinute,
      required bool birthTimeKnown,
      required String calendarType,
      Value<bool> isLeapMonth,
      Value<String> timezone,
      Value<String?> genderMode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BirthProfilesTableUpdateCompanionBuilder =
    BirthProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> displayName,
      Value<DateTime> birthDate,
      Value<int?> birthHour,
      Value<int?> birthMinute,
      Value<bool> birthTimeKnown,
      Value<String> calendarType,
      Value<bool> isLeapMonth,
      Value<String> timezone,
      Value<String?> genderMode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BirthProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $BirthProfilesTable> {
  $$BirthProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthHour => $composableBuilder(
    column: $table.birthHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthMinute => $composableBuilder(
    column: $table.birthMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get birthTimeKnown => $composableBuilder(
    column: $table.birthTimeKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarType => $composableBuilder(
    column: $table.calendarType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genderMode => $composableBuilder(
    column: $table.genderMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BirthProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BirthProfilesTable> {
  $$BirthProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthHour => $composableBuilder(
    column: $table.birthHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthMinute => $composableBuilder(
    column: $table.birthMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get birthTimeKnown => $composableBuilder(
    column: $table.birthTimeKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarType => $composableBuilder(
    column: $table.calendarType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genderMode => $composableBuilder(
    column: $table.genderMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BirthProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BirthProfilesTable> {
  $$BirthProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get birthHour =>
      $composableBuilder(column: $table.birthHour, builder: (column) => column);

  GeneratedColumn<int> get birthMinute => $composableBuilder(
    column: $table.birthMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get birthTimeKnown => $composableBuilder(
    column: $table.birthTimeKnown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarType => $composableBuilder(
    column: $table.calendarType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get genderMode => $composableBuilder(
    column: $table.genderMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BirthProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BirthProfilesTable,
          BirthProfile,
          $$BirthProfilesTableFilterComposer,
          $$BirthProfilesTableOrderingComposer,
          $$BirthProfilesTableAnnotationComposer,
          $$BirthProfilesTableCreateCompanionBuilder,
          $$BirthProfilesTableUpdateCompanionBuilder,
          (
            BirthProfile,
            BaseReferences<_$AppDatabase, $BirthProfilesTable, BirthProfile>,
          ),
          BirthProfile,
          PrefetchHooks Function()
        > {
  $$BirthProfilesTableTableManager(_$AppDatabase db, $BirthProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BirthProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BirthProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BirthProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<int?> birthHour = const Value.absent(),
                Value<int?> birthMinute = const Value.absent(),
                Value<bool> birthTimeKnown = const Value.absent(),
                Value<String> calendarType = const Value.absent(),
                Value<bool> isLeapMonth = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> genderMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BirthProfilesCompanion(
                id: id,
                userId: userId,
                displayName: displayName,
                birthDate: birthDate,
                birthHour: birthHour,
                birthMinute: birthMinute,
                birthTimeKnown: birthTimeKnown,
                calendarType: calendarType,
                isLeapMonth: isLeapMonth,
                timezone: timezone,
                genderMode: genderMode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String displayName,
                required DateTime birthDate,
                Value<int?> birthHour = const Value.absent(),
                Value<int?> birthMinute = const Value.absent(),
                required bool birthTimeKnown,
                required String calendarType,
                Value<bool> isLeapMonth = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> genderMode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BirthProfilesCompanion.insert(
                id: id,
                userId: userId,
                displayName: displayName,
                birthDate: birthDate,
                birthHour: birthHour,
                birthMinute: birthMinute,
                birthTimeKnown: birthTimeKnown,
                calendarType: calendarType,
                isLeapMonth: isLeapMonth,
                timezone: timezone,
                genderMode: genderMode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BirthProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BirthProfilesTable,
      BirthProfile,
      $$BirthProfilesTableFilterComposer,
      $$BirthProfilesTableOrderingComposer,
      $$BirthProfilesTableAnnotationComposer,
      $$BirthProfilesTableCreateCompanionBuilder,
      $$BirthProfilesTableUpdateCompanionBuilder,
      (
        BirthProfile,
        BaseReferences<_$AppDatabase, $BirthProfilesTable, BirthProfile>,
      ),
      BirthProfile,
      PrefetchHooks Function()
    >;
typedef $$DailySnapshotsTableCreateCompanionBuilder =
    DailySnapshotsCompanion Function({
      required String id,
      required String userId,
      required String birthProfileId,
      required DateTime date,
      required String payloadJson,
      Value<String?> guardianId,
      required String engineVersion,
      required String ruleVersion,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DailySnapshotsTableUpdateCompanionBuilder =
    DailySnapshotsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> birthProfileId,
      Value<DateTime> date,
      Value<String> payloadJson,
      Value<String?> guardianId,
      Value<String> engineVersion,
      Value<String> ruleVersion,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DailySnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $DailySnapshotsTable> {
  $$DailySnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthProfileId => $composableBuilder(
    column: $table.birthProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianId => $composableBuilder(
    column: $table.guardianId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySnapshotsTable> {
  $$DailySnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthProfileId => $composableBuilder(
    column: $table.birthProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianId => $composableBuilder(
    column: $table.guardianId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySnapshotsTable> {
  $$DailySnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get birthProfileId => $composableBuilder(
    column: $table.birthProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guardianId => $composableBuilder(
    column: $table.guardianId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailySnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySnapshotsTable,
          DailySnapshot,
          $$DailySnapshotsTableFilterComposer,
          $$DailySnapshotsTableOrderingComposer,
          $$DailySnapshotsTableAnnotationComposer,
          $$DailySnapshotsTableCreateCompanionBuilder,
          $$DailySnapshotsTableUpdateCompanionBuilder,
          (
            DailySnapshot,
            BaseReferences<_$AppDatabase, $DailySnapshotsTable, DailySnapshot>,
          ),
          DailySnapshot,
          PrefetchHooks Function()
        > {
  $$DailySnapshotsTableTableManager(
    _$AppDatabase db,
    $DailySnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> birthProfileId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> guardianId = const Value.absent(),
                Value<String> engineVersion = const Value.absent(),
                Value<String> ruleVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySnapshotsCompanion(
                id: id,
                userId: userId,
                birthProfileId: birthProfileId,
                date: date,
                payloadJson: payloadJson,
                guardianId: guardianId,
                engineVersion: engineVersion,
                ruleVersion: ruleVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String birthProfileId,
                required DateTime date,
                required String payloadJson,
                Value<String?> guardianId = const Value.absent(),
                required String engineVersion,
                required String ruleVersion,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailySnapshotsCompanion.insert(
                id: id,
                userId: userId,
                birthProfileId: birthProfileId,
                date: date,
                payloadJson: payloadJson,
                guardianId: guardianId,
                engineVersion: engineVersion,
                ruleVersion: ruleVersion,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySnapshotsTable,
      DailySnapshot,
      $$DailySnapshotsTableFilterComposer,
      $$DailySnapshotsTableOrderingComposer,
      $$DailySnapshotsTableAnnotationComposer,
      $$DailySnapshotsTableCreateCompanionBuilder,
      $$DailySnapshotsTableUpdateCompanionBuilder,
      (
        DailySnapshot,
        BaseReferences<_$AppDatabase, $DailySnapshotsTable, DailySnapshot>,
      ),
      DailySnapshot,
      PrefetchHooks Function()
    >;
typedef $$DailyRecordsTableCreateCompanionBuilder =
    DailyRecordsCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      Value<String?> mood,
      Value<int?> energyLevel,
      Value<String?> memo,
      Value<String?> guardianId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DailyRecordsTableUpdateCompanionBuilder =
    DailyRecordsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<String?> mood,
      Value<int?> energyLevel,
      Value<String?> memo,
      Value<String?> guardianId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DailyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyRecordsTable> {
  $$DailyRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianId => $composableBuilder(
    column: $table.guardianId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyRecordsTable> {
  $$DailyRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianId => $composableBuilder(
    column: $table.guardianId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyRecordsTable> {
  $$DailyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get guardianId => $composableBuilder(
    column: $table.guardianId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyRecordsTable,
          DailyRecord,
          $$DailyRecordsTableFilterComposer,
          $$DailyRecordsTableOrderingComposer,
          $$DailyRecordsTableAnnotationComposer,
          $$DailyRecordsTableCreateCompanionBuilder,
          $$DailyRecordsTableUpdateCompanionBuilder,
          (
            DailyRecord,
            BaseReferences<_$AppDatabase, $DailyRecordsTable, DailyRecord>,
          ),
          DailyRecord,
          PrefetchHooks Function()
        > {
  $$DailyRecordsTableTableManager(_$AppDatabase db, $DailyRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int?> energyLevel = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> guardianId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyRecordsCompanion(
                id: id,
                userId: userId,
                date: date,
                mood: mood,
                energyLevel: energyLevel,
                memo: memo,
                guardianId: guardianId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                Value<String?> mood = const Value.absent(),
                Value<int?> energyLevel = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> guardianId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyRecordsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                mood: mood,
                energyLevel: energyLevel,
                memo: memo,
                guardianId: guardianId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyRecordsTable,
      DailyRecord,
      $$DailyRecordsTableFilterComposer,
      $$DailyRecordsTableOrderingComposer,
      $$DailyRecordsTableAnnotationComposer,
      $$DailyRecordsTableCreateCompanionBuilder,
      $$DailyRecordsTableUpdateCompanionBuilder,
      (
        DailyRecord,
        BaseReferences<_$AppDatabase, $DailyRecordsTable, DailyRecord>,
      ),
      DailyRecord,
      PrefetchHooks Function()
    >;
typedef $$GuardianCardsTableCreateCompanionBuilder =
    GuardianCardsCompanion Function({
      required String id,
      required String name,
      required String element,
      required String rarity,
      Value<String?> assetId,
      Value<int> rowid,
    });
typedef $$GuardianCardsTableUpdateCompanionBuilder =
    GuardianCardsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> element,
      Value<String> rarity,
      Value<String?> assetId,
      Value<int> rowid,
    });

class $$GuardianCardsTableFilterComposer
    extends Composer<_$AppDatabase, $GuardianCardsTable> {
  $$GuardianCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get element => $composableBuilder(
    column: $table.element,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GuardianCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $GuardianCardsTable> {
  $$GuardianCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get element => $composableBuilder(
    column: $table.element,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuardianCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuardianCardsTable> {
  $$GuardianCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get element =>
      $composableBuilder(column: $table.element, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);
}

class $$GuardianCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuardianCardsTable,
          GuardianCard,
          $$GuardianCardsTableFilterComposer,
          $$GuardianCardsTableOrderingComposer,
          $$GuardianCardsTableAnnotationComposer,
          $$GuardianCardsTableCreateCompanionBuilder,
          $$GuardianCardsTableUpdateCompanionBuilder,
          (
            GuardianCard,
            BaseReferences<_$AppDatabase, $GuardianCardsTable, GuardianCard>,
          ),
          GuardianCard,
          PrefetchHooks Function()
        > {
  $$GuardianCardsTableTableManager(_$AppDatabase db, $GuardianCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuardianCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuardianCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuardianCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> element = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuardianCardsCompanion(
                id: id,
                name: name,
                element: element,
                rarity: rarity,
                assetId: assetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String element,
                required String rarity,
                Value<String?> assetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuardianCardsCompanion.insert(
                id: id,
                name: name,
                element: element,
                rarity: rarity,
                assetId: assetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GuardianCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuardianCardsTable,
      GuardianCard,
      $$GuardianCardsTableFilterComposer,
      $$GuardianCardsTableOrderingComposer,
      $$GuardianCardsTableAnnotationComposer,
      $$GuardianCardsTableCreateCompanionBuilder,
      $$GuardianCardsTableUpdateCompanionBuilder,
      (
        GuardianCard,
        BaseReferences<_$AppDatabase, $GuardianCardsTable, GuardianCard>,
      ),
      GuardianCard,
      PrefetchHooks Function()
    >;
typedef $$OwnedCardsTableCreateCompanionBuilder =
    OwnedCardsCompanion Function({
      required String userId,
      required String cardId,
      required DateTime unlockedAt,
      Value<int> count,
      required String firstSource,
      Value<int> rowid,
    });
typedef $$OwnedCardsTableUpdateCompanionBuilder =
    OwnedCardsCompanion Function({
      Value<String> userId,
      Value<String> cardId,
      Value<DateTime> unlockedAt,
      Value<int> count,
      Value<String> firstSource,
      Value<int> rowid,
    });

class $$OwnedCardsTableFilterComposer
    extends Composer<_$AppDatabase, $OwnedCardsTable> {
  $$OwnedCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstSource => $composableBuilder(
    column: $table.firstSource,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OwnedCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnedCardsTable> {
  $$OwnedCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstSource => $composableBuilder(
    column: $table.firstSource,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnedCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnedCardsTable> {
  $$OwnedCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get firstSource => $composableBuilder(
    column: $table.firstSource,
    builder: (column) => column,
  );
}

class $$OwnedCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnedCardsTable,
          OwnedCard,
          $$OwnedCardsTableFilterComposer,
          $$OwnedCardsTableOrderingComposer,
          $$OwnedCardsTableAnnotationComposer,
          $$OwnedCardsTableCreateCompanionBuilder,
          $$OwnedCardsTableUpdateCompanionBuilder,
          (
            OwnedCard,
            BaseReferences<_$AppDatabase, $OwnedCardsTable, OwnedCard>,
          ),
          OwnedCard,
          PrefetchHooks Function()
        > {
  $$OwnedCardsTableTableManager(_$AppDatabase db, $OwnedCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String> firstSource = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnedCardsCompanion(
                userId: userId,
                cardId: cardId,
                unlockedAt: unlockedAt,
                count: count,
                firstSource: firstSource,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String cardId,
                required DateTime unlockedAt,
                Value<int> count = const Value.absent(),
                required String firstSource,
                Value<int> rowid = const Value.absent(),
              }) => OwnedCardsCompanion.insert(
                userId: userId,
                cardId: cardId,
                unlockedAt: unlockedAt,
                count: count,
                firstSource: firstSource,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnedCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnedCardsTable,
      OwnedCard,
      $$OwnedCardsTableFilterComposer,
      $$OwnedCardsTableOrderingComposer,
      $$OwnedCardsTableAnnotationComposer,
      $$OwnedCardsTableCreateCompanionBuilder,
      $$OwnedCardsTableUpdateCompanionBuilder,
      (OwnedCard, BaseReferences<_$AppDatabase, $OwnedCardsTable, OwnedCard>),
      OwnedCard,
      PrefetchHooks Function()
    >;
typedef $$RoutineLogsTableCreateCompanionBuilder =
    RoutineLogsCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      required String routineTemplateId,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$RoutineLogsTableUpdateCompanionBuilder =
    RoutineLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<String> routineTemplateId,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$RoutineLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineLogsTable> {
  $$RoutineLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineTemplateId => $composableBuilder(
    column: $table.routineTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineLogsTable> {
  $$RoutineLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineTemplateId => $composableBuilder(
    column: $table.routineTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineLogsTable> {
  $$RoutineLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get routineTemplateId => $composableBuilder(
    column: $table.routineTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$RoutineLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineLogsTable,
          RoutineLog,
          $$RoutineLogsTableFilterComposer,
          $$RoutineLogsTableOrderingComposer,
          $$RoutineLogsTableAnnotationComposer,
          $$RoutineLogsTableCreateCompanionBuilder,
          $$RoutineLogsTableUpdateCompanionBuilder,
          (
            RoutineLog,
            BaseReferences<_$AppDatabase, $RoutineLogsTable, RoutineLog>,
          ),
          RoutineLog,
          PrefetchHooks Function()
        > {
  $$RoutineLogsTableTableManager(_$AppDatabase db, $RoutineLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> routineTemplateId = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineLogsCompanion(
                id: id,
                userId: userId,
                date: date,
                routineTemplateId: routineTemplateId,
                completed: completed,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                required String routineTemplateId,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineLogsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                routineTemplateId: routineTemplateId,
                completed: completed,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineLogsTable,
      RoutineLog,
      $$RoutineLogsTableFilterComposer,
      $$RoutineLogsTableOrderingComposer,
      $$RoutineLogsTableAnnotationComposer,
      $$RoutineLogsTableCreateCompanionBuilder,
      $$RoutineLogsTableUpdateCompanionBuilder,
      (
        RoutineLog,
        BaseReferences<_$AppDatabase, $RoutineLogsTable, RoutineLog>,
      ),
      RoutineLog,
      PrefetchHooks Function()
    >;
typedef $$RoutineStreaksTableCreateCompanionBuilder =
    RoutineStreaksCompanion Function({
      required String userId,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastCompletedDate,
      Value<int> rowid,
    });
typedef $$RoutineStreaksTableUpdateCompanionBuilder =
    RoutineStreaksCompanion Function({
      Value<String> userId,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastCompletedDate,
      Value<int> rowid,
    });

class $$RoutineStreaksTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineStreaksTable> {
  $$RoutineStreaksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineStreaksTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineStreaksTable> {
  $$RoutineStreaksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineStreaksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineStreaksTable> {
  $$RoutineStreaksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => column,
  );
}

class $$RoutineStreaksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineStreaksTable,
          RoutineStreak,
          $$RoutineStreaksTableFilterComposer,
          $$RoutineStreaksTableOrderingComposer,
          $$RoutineStreaksTableAnnotationComposer,
          $$RoutineStreaksTableCreateCompanionBuilder,
          $$RoutineStreaksTableUpdateCompanionBuilder,
          (
            RoutineStreak,
            BaseReferences<_$AppDatabase, $RoutineStreaksTable, RoutineStreak>,
          ),
          RoutineStreak,
          PrefetchHooks Function()
        > {
  $$RoutineStreaksTableTableManager(
    _$AppDatabase db,
    $RoutineStreaksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineStreaksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineStreaksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineStreaksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastCompletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineStreaksCompanion(
                userId: userId,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCompletedDate: lastCompletedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastCompletedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineStreaksCompanion.insert(
                userId: userId,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCompletedDate: lastCompletedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineStreaksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineStreaksTable,
      RoutineStreak,
      $$RoutineStreaksTableFilterComposer,
      $$RoutineStreaksTableOrderingComposer,
      $$RoutineStreaksTableAnnotationComposer,
      $$RoutineStreaksTableCreateCompanionBuilder,
      $$RoutineStreaksTableUpdateCompanionBuilder,
      (
        RoutineStreak,
        BaseReferences<_$AppDatabase, $RoutineStreaksTable, RoutineStreak>,
      ),
      RoutineStreak,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$ChemistryProfilesTableCreateCompanionBuilder =
    ChemistryProfilesCompanion Function({
      required String id,
      required String ownerUserId,
      required String label,
      required String relationType,
      required DateTime birthDate,
      Value<int?> birthHour,
      Value<int?> birthMinute,
      required String calendarType,
      Value<bool> isLeapMonth,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ChemistryProfilesTableUpdateCompanionBuilder =
    ChemistryProfilesCompanion Function({
      Value<String> id,
      Value<String> ownerUserId,
      Value<String> label,
      Value<String> relationType,
      Value<DateTime> birthDate,
      Value<int?> birthHour,
      Value<int?> birthMinute,
      Value<String> calendarType,
      Value<bool> isLeapMonth,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ChemistryProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ChemistryProfilesTable> {
  $$ChemistryProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthHour => $composableBuilder(
    column: $table.birthHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthMinute => $composableBuilder(
    column: $table.birthMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarType => $composableBuilder(
    column: $table.calendarType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChemistryProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChemistryProfilesTable> {
  $$ChemistryProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthHour => $composableBuilder(
    column: $table.birthHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthMinute => $composableBuilder(
    column: $table.birthMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarType => $composableBuilder(
    column: $table.calendarType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChemistryProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChemistryProfilesTable> {
  $$ChemistryProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get birthHour =>
      $composableBuilder(column: $table.birthHour, builder: (column) => column);

  GeneratedColumn<int> get birthMinute => $composableBuilder(
    column: $table.birthMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarType => $composableBuilder(
    column: $table.calendarType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLeapMonth => $composableBuilder(
    column: $table.isLeapMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChemistryProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChemistryProfilesTable,
          ChemistryProfile,
          $$ChemistryProfilesTableFilterComposer,
          $$ChemistryProfilesTableOrderingComposer,
          $$ChemistryProfilesTableAnnotationComposer,
          $$ChemistryProfilesTableCreateCompanionBuilder,
          $$ChemistryProfilesTableUpdateCompanionBuilder,
          (
            ChemistryProfile,
            BaseReferences<
              _$AppDatabase,
              $ChemistryProfilesTable,
              ChemistryProfile
            >,
          ),
          ChemistryProfile,
          PrefetchHooks Function()
        > {
  $$ChemistryProfilesTableTableManager(
    _$AppDatabase db,
    $ChemistryProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChemistryProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChemistryProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChemistryProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUserId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> relationType = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<int?> birthHour = const Value.absent(),
                Value<int?> birthMinute = const Value.absent(),
                Value<String> calendarType = const Value.absent(),
                Value<bool> isLeapMonth = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChemistryProfilesCompanion(
                id: id,
                ownerUserId: ownerUserId,
                label: label,
                relationType: relationType,
                birthDate: birthDate,
                birthHour: birthHour,
                birthMinute: birthMinute,
                calendarType: calendarType,
                isLeapMonth: isLeapMonth,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUserId,
                required String label,
                required String relationType,
                required DateTime birthDate,
                Value<int?> birthHour = const Value.absent(),
                Value<int?> birthMinute = const Value.absent(),
                required String calendarType,
                Value<bool> isLeapMonth = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChemistryProfilesCompanion.insert(
                id: id,
                ownerUserId: ownerUserId,
                label: label,
                relationType: relationType,
                birthDate: birthDate,
                birthHour: birthHour,
                birthMinute: birthMinute,
                calendarType: calendarType,
                isLeapMonth: isLeapMonth,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChemistryProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChemistryProfilesTable,
      ChemistryProfile,
      $$ChemistryProfilesTableFilterComposer,
      $$ChemistryProfilesTableOrderingComposer,
      $$ChemistryProfilesTableAnnotationComposer,
      $$ChemistryProfilesTableCreateCompanionBuilder,
      $$ChemistryProfilesTableUpdateCompanionBuilder,
      (
        ChemistryProfile,
        BaseReferences<
          _$AppDatabase,
          $ChemistryProfilesTable,
          ChemistryProfile
        >,
      ),
      ChemistryProfile,
      PrefetchHooks Function()
    >;
typedef $$ChemistryResultsTableCreateCompanionBuilder =
    ChemistryResultsCompanion Function({
      required String id,
      required String ownerUserId,
      required String partnerProfileId,
      required String payloadJson,
      required String engineVersion,
      required DateTime calculatedAt,
      Value<int> rowid,
    });
typedef $$ChemistryResultsTableUpdateCompanionBuilder =
    ChemistryResultsCompanion Function({
      Value<String> id,
      Value<String> ownerUserId,
      Value<String> partnerProfileId,
      Value<String> payloadJson,
      Value<String> engineVersion,
      Value<DateTime> calculatedAt,
      Value<int> rowid,
    });

class $$ChemistryResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ChemistryResultsTable> {
  $$ChemistryResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerProfileId => $composableBuilder(
    column: $table.partnerProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChemistryResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChemistryResultsTable> {
  $$ChemistryResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerProfileId => $composableBuilder(
    column: $table.partnerProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChemistryResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChemistryResultsTable> {
  $$ChemistryResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerProfileId => $composableBuilder(
    column: $table.partnerProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engineVersion => $composableBuilder(
    column: $table.engineVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
    column: $table.calculatedAt,
    builder: (column) => column,
  );
}

class $$ChemistryResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChemistryResultsTable,
          ChemistryResult,
          $$ChemistryResultsTableFilterComposer,
          $$ChemistryResultsTableOrderingComposer,
          $$ChemistryResultsTableAnnotationComposer,
          $$ChemistryResultsTableCreateCompanionBuilder,
          $$ChemistryResultsTableUpdateCompanionBuilder,
          (
            ChemistryResult,
            BaseReferences<
              _$AppDatabase,
              $ChemistryResultsTable,
              ChemistryResult
            >,
          ),
          ChemistryResult,
          PrefetchHooks Function()
        > {
  $$ChemistryResultsTableTableManager(
    _$AppDatabase db,
    $ChemistryResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChemistryResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChemistryResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChemistryResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUserId = const Value.absent(),
                Value<String> partnerProfileId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> engineVersion = const Value.absent(),
                Value<DateTime> calculatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChemistryResultsCompanion(
                id: id,
                ownerUserId: ownerUserId,
                partnerProfileId: partnerProfileId,
                payloadJson: payloadJson,
                engineVersion: engineVersion,
                calculatedAt: calculatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUserId,
                required String partnerProfileId,
                required String payloadJson,
                required String engineVersion,
                required DateTime calculatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChemistryResultsCompanion.insert(
                id: id,
                ownerUserId: ownerUserId,
                partnerProfileId: partnerProfileId,
                payloadJson: payloadJson,
                engineVersion: engineVersion,
                calculatedAt: calculatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChemistryResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChemistryResultsTable,
      ChemistryResult,
      $$ChemistryResultsTableFilterComposer,
      $$ChemistryResultsTableOrderingComposer,
      $$ChemistryResultsTableAnnotationComposer,
      $$ChemistryResultsTableCreateCompanionBuilder,
      $$ChemistryResultsTableUpdateCompanionBuilder,
      (
        ChemistryResult,
        BaseReferences<_$AppDatabase, $ChemistryResultsTable, ChemistryResult>,
      ),
      ChemistryResult,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableCreateCompanionBuilder =
    NotificationSettingsCompanion Function({
      required String type,
      Value<bool> enabled,
      required int hour,
      Value<int> minute,
      Value<int> rowid,
    });
typedef $$NotificationSettingsTableUpdateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<String> type,
      Value<bool> enabled,
      Value<int> hour,
      Value<int> minute,
      Value<int> rowid,
    });

class $$NotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);
}

class $$NotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting,
          $$NotificationSettingsTableFilterComposer,
          $$NotificationSettingsTableOrderingComposer,
          $$NotificationSettingsTableAnnotationComposer,
          $$NotificationSettingsTableCreateCompanionBuilder,
          $$NotificationSettingsTableUpdateCompanionBuilder,
          (
            NotificationSetting,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTable,
              NotificationSetting
            >,
          ),
          NotificationSetting,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsCompanion(
                type: type,
                enabled: enabled,
                hour: hour,
                minute: minute,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                Value<bool> enabled = const Value.absent(),
                required int hour,
                Value<int> minute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsCompanion.insert(
                type: type,
                enabled: enabled,
                hour: hour,
                minute: minute,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTable,
      NotificationSetting,
      $$NotificationSettingsTableFilterComposer,
      $$NotificationSettingsTableOrderingComposer,
      $$NotificationSettingsTableAnnotationComposer,
      $$NotificationSettingsTableCreateCompanionBuilder,
      $$NotificationSettingsTableUpdateCompanionBuilder,
      (
        NotificationSetting,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting
        >,
      ),
      NotificationSetting,
      PrefetchHooks Function()
    >;
typedef $$MarketInstrumentsTableCreateCompanionBuilder =
    MarketInstrumentsCompanion Function({
      required String id,
      required String symbol,
      required String market,
      required String name,
      required String normalizedName,
      required String corpName,
      Value<String?> isin,
      required String baseDate,
      required String source,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MarketInstrumentsTableUpdateCompanionBuilder =
    MarketInstrumentsCompanion Function({
      Value<String> id,
      Value<String> symbol,
      Value<String> market,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> corpName,
      Value<String?> isin,
      Value<String> baseDate,
      Value<String> source,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MarketInstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $MarketInstrumentsTable> {
  $$MarketInstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get corpName => $composableBuilder(
    column: $table.corpName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseDate => $composableBuilder(
    column: $table.baseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketInstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketInstrumentsTable> {
  $$MarketInstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get corpName => $composableBuilder(
    column: $table.corpName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseDate => $composableBuilder(
    column: $table.baseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketInstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketInstrumentsTable> {
  $$MarketInstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get corpName =>
      $composableBuilder(column: $table.corpName, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get baseDate =>
      $composableBuilder(column: $table.baseDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MarketInstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketInstrumentsTable,
          MarketInstrument,
          $$MarketInstrumentsTableFilterComposer,
          $$MarketInstrumentsTableOrderingComposer,
          $$MarketInstrumentsTableAnnotationComposer,
          $$MarketInstrumentsTableCreateCompanionBuilder,
          $$MarketInstrumentsTableUpdateCompanionBuilder,
          (
            MarketInstrument,
            BaseReferences<
              _$AppDatabase,
              $MarketInstrumentsTable,
              MarketInstrument
            >,
          ),
          MarketInstrument,
          PrefetchHooks Function()
        > {
  $$MarketInstrumentsTableTableManager(
    _$AppDatabase db,
    $MarketInstrumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketInstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketInstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketInstrumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> market = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> corpName = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String> baseDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketInstrumentsCompanion(
                id: id,
                symbol: symbol,
                market: market,
                name: name,
                normalizedName: normalizedName,
                corpName: corpName,
                isin: isin,
                baseDate: baseDate,
                source: source,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String symbol,
                required String market,
                required String name,
                required String normalizedName,
                required String corpName,
                Value<String?> isin = const Value.absent(),
                required String baseDate,
                required String source,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MarketInstrumentsCompanion.insert(
                id: id,
                symbol: symbol,
                market: market,
                name: name,
                normalizedName: normalizedName,
                corpName: corpName,
                isin: isin,
                baseDate: baseDate,
                source: source,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketInstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketInstrumentsTable,
      MarketInstrument,
      $$MarketInstrumentsTableFilterComposer,
      $$MarketInstrumentsTableOrderingComposer,
      $$MarketInstrumentsTableAnnotationComposer,
      $$MarketInstrumentsTableCreateCompanionBuilder,
      $$MarketInstrumentsTableUpdateCompanionBuilder,
      (
        MarketInstrument,
        BaseReferences<
          _$AppDatabase,
          $MarketInstrumentsTable,
          MarketInstrument
        >,
      ),
      MarketInstrument,
      PrefetchHooks Function()
    >;
typedef $$MarketWatchItemsTableCreateCompanionBuilder =
    MarketWatchItemsCompanion Function({
      required String id,
      required String userId,
      required String instrumentId,
      Value<String?> memo,
      Value<String> userTagsJson,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$MarketWatchItemsTableUpdateCompanionBuilder =
    MarketWatchItemsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> instrumentId,
      Value<String?> memo,
      Value<String> userTagsJson,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

class $$MarketWatchItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MarketWatchItemsTable> {
  $$MarketWatchItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userTagsJson => $composableBuilder(
    column: $table.userTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketWatchItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketWatchItemsTable> {
  $$MarketWatchItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userTagsJson => $composableBuilder(
    column: $table.userTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketWatchItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketWatchItemsTable> {
  $$MarketWatchItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get userTagsJson => $composableBuilder(
    column: $table.userTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );
}

class $$MarketWatchItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketWatchItemsTable,
          MarketWatchItem,
          $$MarketWatchItemsTableFilterComposer,
          $$MarketWatchItemsTableOrderingComposer,
          $$MarketWatchItemsTableAnnotationComposer,
          $$MarketWatchItemsTableCreateCompanionBuilder,
          $$MarketWatchItemsTableUpdateCompanionBuilder,
          (
            MarketWatchItem,
            BaseReferences<
              _$AppDatabase,
              $MarketWatchItemsTable,
              MarketWatchItem
            >,
          ),
          MarketWatchItem,
          PrefetchHooks Function()
        > {
  $$MarketWatchItemsTableTableManager(
    _$AppDatabase db,
    $MarketWatchItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketWatchItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketWatchItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketWatchItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String> userTagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketWatchItemsCompanion(
                id: id,
                userId: userId,
                instrumentId: instrumentId,
                memo: memo,
                userTagsJson: userTagsJson,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String instrumentId,
                Value<String?> memo = const Value.absent(),
                Value<String> userTagsJson = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketWatchItemsCompanion.insert(
                id: id,
                userId: userId,
                instrumentId: instrumentId,
                memo: memo,
                userTagsJson: userTagsJson,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketWatchItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketWatchItemsTable,
      MarketWatchItem,
      $$MarketWatchItemsTableFilterComposer,
      $$MarketWatchItemsTableOrderingComposer,
      $$MarketWatchItemsTableAnnotationComposer,
      $$MarketWatchItemsTableCreateCompanionBuilder,
      $$MarketWatchItemsTableUpdateCompanionBuilder,
      (
        MarketWatchItem,
        BaseReferences<_$AppDatabase, $MarketWatchItemsTable, MarketWatchItem>,
      ),
      MarketWatchItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$BirthProfilesTableTableManager get birthProfiles =>
      $$BirthProfilesTableTableManager(_db, _db.birthProfiles);
  $$DailySnapshotsTableTableManager get dailySnapshots =>
      $$DailySnapshotsTableTableManager(_db, _db.dailySnapshots);
  $$DailyRecordsTableTableManager get dailyRecords =>
      $$DailyRecordsTableTableManager(_db, _db.dailyRecords);
  $$GuardianCardsTableTableManager get guardianCards =>
      $$GuardianCardsTableTableManager(_db, _db.guardianCards);
  $$OwnedCardsTableTableManager get ownedCards =>
      $$OwnedCardsTableTableManager(_db, _db.ownedCards);
  $$RoutineLogsTableTableManager get routineLogs =>
      $$RoutineLogsTableTableManager(_db, _db.routineLogs);
  $$RoutineStreaksTableTableManager get routineStreaks =>
      $$RoutineStreaksTableTableManager(_db, _db.routineStreaks);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$ChemistryProfilesTableTableManager get chemistryProfiles =>
      $$ChemistryProfilesTableTableManager(_db, _db.chemistryProfiles);
  $$ChemistryResultsTableTableManager get chemistryResults =>
      $$ChemistryResultsTableTableManager(_db, _db.chemistryResults);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(_db, _db.notificationSettings);
  $$MarketInstrumentsTableTableManager get marketInstruments =>
      $$MarketInstrumentsTableTableManager(_db, _db.marketInstruments);
  $$MarketWatchItemsTableTableManager get marketWatchItems =>
      $$MarketWatchItemsTableTableManager(_db, _db.marketWatchItems);
}
