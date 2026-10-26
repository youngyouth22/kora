// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTableTable extends ProfilesTable
    with TableInfo<$ProfilesTableTable, ProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> goals =
      GeneratedColumn<String>(
        'goals',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ProfilesTableTable.$convertergoals);
  static const VerificationMeta _skinTypeMeta = const VerificationMeta(
    'skinType',
  );
  @override
  late final GeneratedColumn<String> skinType = GeneratedColumn<String>(
    'skin_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  sensitivities = GeneratedColumn<String>(
    'sensitivities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ProfilesTableTable.$convertersensitivities);
  static const VerificationMeta _skinToneSelfMeta = const VerificationMeta(
    'skinToneSelf',
  );
  @override
  late final GeneratedColumn<int> skinToneSelf = GeneratedColumn<int>(
    'skin_tone_self',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sunHabitMeta = const VerificationMeta(
    'sunHabit',
  );
  @override
  late final GeneratedColumn<String> sunHabit = GeneratedColumn<String>(
    'sun_habit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  currentActives = GeneratedColumn<String>(
    'current_actives',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ProfilesTableTable.$convertercurrentActives);
  static const VerificationMeta _activesStartedMeta = const VerificationMeta(
    'activesStarted',
  );
  @override
  late final GeneratedColumn<String> activesStarted = GeneratedColumn<String>(
    'actives_started',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _scanWeekdayMeta = const VerificationMeta(
    'scanWeekday',
  );
  @override
  late final GeneratedColumn<int> scanWeekday = GeneratedColumn<int>(
    'scan_weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _scanTimeMeta = const VerificationMeta(
    'scanTime',
  );
  @override
  late final GeneratedColumn<String> scanTime = GeneratedColumn<String>(
    'scan_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('18:00'),
  );
  static const VerificationMeta _ageConfirmedMeta = const VerificationMeta(
    'ageConfirmed',
  );
  @override
  late final GeneratedColumn<bool> ageConfirmed = GeneratedColumn<bool>(
    'age_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("age_confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keepPhotosMeta = const VerificationMeta(
    'keepPhotos',
  );
  @override
  late final GeneratedColumn<bool> keepPhotos = GeneratedColumn<bool>(
    'keep_photos',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_photos" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingStepMeta = const VerificationMeta(
    'onboardingStep',
  );
  @override
  late final GeneratedColumn<int> onboardingStep = GeneratedColumn<int>(
    'onboarding_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<DateTime> onboardingCompletedAt =
      GeneratedColumn<DateTime>(
        'onboarding_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isDemoMeta = const VerificationMeta('isDemo');
  @override
  late final GeneratedColumn<bool> isDemo = GeneratedColumn<bool>(
    'is_demo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_demo" IN (0, 1))',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    goals,
    skinType,
    sensitivities,
    skinToneSelf,
    sunHabit,
    currentActives,
    activesStarted,
    timezone,
    locale,
    scanWeekday,
    scanTime,
    ageConfirmed,
    keepPhotos,
    onboardingStep,
    onboardingCompletedAt,
    isDemo,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('skin_type')) {
      context.handle(
        _skinTypeMeta,
        skinType.isAcceptableOrUnknown(data['skin_type']!, _skinTypeMeta),
      );
    }
    if (data.containsKey('skin_tone_self')) {
      context.handle(
        _skinToneSelfMeta,
        skinToneSelf.isAcceptableOrUnknown(
          data['skin_tone_self']!,
          _skinToneSelfMeta,
        ),
      );
    }
    if (data.containsKey('sun_habit')) {
      context.handle(
        _sunHabitMeta,
        sunHabit.isAcceptableOrUnknown(data['sun_habit']!, _sunHabitMeta),
      );
    }
    if (data.containsKey('actives_started')) {
      context.handle(
        _activesStartedMeta,
        activesStarted.isAcceptableOrUnknown(
          data['actives_started']!,
          _activesStartedMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('scan_weekday')) {
      context.handle(
        _scanWeekdayMeta,
        scanWeekday.isAcceptableOrUnknown(
          data['scan_weekday']!,
          _scanWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('scan_time')) {
      context.handle(
        _scanTimeMeta,
        scanTime.isAcceptableOrUnknown(data['scan_time']!, _scanTimeMeta),
      );
    }
    if (data.containsKey('age_confirmed')) {
      context.handle(
        _ageConfirmedMeta,
        ageConfirmed.isAcceptableOrUnknown(
          data['age_confirmed']!,
          _ageConfirmedMeta,
        ),
      );
    }
    if (data.containsKey('keep_photos')) {
      context.handle(
        _keepPhotosMeta,
        keepPhotos.isAcceptableOrUnknown(data['keep_photos']!, _keepPhotosMeta),
      );
    }
    if (data.containsKey('onboarding_step')) {
      context.handle(
        _onboardingStepMeta,
        onboardingStep.isAcceptableOrUnknown(
          data['onboarding_step']!,
          _onboardingStepMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
        _onboardingCompletedAtMeta,
        onboardingCompletedAt.isAcceptableOrUnknown(
          data['onboarding_completed_at']!,
          _onboardingCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_demo')) {
      context.handle(
        _isDemoMeta,
        isDemo.isAcceptableOrUnknown(data['is_demo']!, _isDemoMeta),
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      goals: $ProfilesTableTable.$convertergoals.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goals'],
        )!,
      ),
      skinType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skin_type'],
      ),
      sensitivities: $ProfilesTableTable.$convertersensitivities.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sensitivities'],
        )!,
      ),
      skinToneSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skin_tone_self'],
      ),
      sunHabit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sun_habit'],
      ),
      currentActives: $ProfilesTableTable.$convertercurrentActives.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}current_actives'],
        )!,
      ),
      activesStarted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actives_started'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      scanWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_weekday'],
      )!,
      scanTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_time'],
      )!,
      ageConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}age_confirmed'],
      )!,
      keepPhotos: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_photos'],
      )!,
      onboardingStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarding_step'],
      )!,
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}onboarding_completed_at'],
      ),
      isDemo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_demo'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ProfilesTableTable createAlias(String alias) {
    return $ProfilesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertergoals =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertersensitivities =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertercurrentActives =
      const StringListConverter();
}

class ProfileEntry extends DataClass implements Insertable<ProfileEntry> {
  /// Primary key matching auth.users(id) or guest UUID.
  final String id;

  /// User display name.
  final String? displayName;

  /// Skin goals (up to 3 concern keys).
  final List<String> goals;

  /// Skin type: oily, dry, combination, normal, unknown.
  final String? skinType;

  /// Skin sensitivities tags.
  final List<String> sensitivities;

  /// Fitzpatrick skin tone (1 to 6).
  final int? skinToneSelf;

  /// Sun exposure habit: never, sometimes, daily.
  final String? sunHabit;

  /// Current active ingredients in use.
  final List<String> currentActives;

  /// When actives were started: lt_2w, 2_8w, gt_2m.
  final String? activesStarted;

  /// User timezone (e.g. UTC, America/New_York).
  final String timezone;

  /// User locale.
  final String locale;

  /// Weekly scan day (ISO weekday 1..7, 7 = Sunday).
  final int scanWeekday;

  /// Scan reminder time (e.g. '18:00').
  final String scanTime;

  /// Confirmation of adult age.
  final bool ageConfirmed;

  /// Whether user keeps scan photos on remote storage.
  final bool keepPhotos;

  /// Onboarding step completed.
  final int onboardingStep;

  /// When onboarding was finished.
  final DateTime? onboardingCompletedAt;

  /// Whether this profile is a demo profile.
  final bool isDemo;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Local sync timestamp with Supabase.
  final DateTime? syncedAt;
  const ProfileEntry({
    required this.id,
    this.displayName,
    required this.goals,
    this.skinType,
    required this.sensitivities,
    this.skinToneSelf,
    this.sunHabit,
    required this.currentActives,
    this.activesStarted,
    required this.timezone,
    required this.locale,
    required this.scanWeekday,
    required this.scanTime,
    required this.ageConfirmed,
    required this.keepPhotos,
    required this.onboardingStep,
    this.onboardingCompletedAt,
    required this.isDemo,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    {
      map['goals'] = Variable<String>(
        $ProfilesTableTable.$convertergoals.toSql(goals),
      );
    }
    if (!nullToAbsent || skinType != null) {
      map['skin_type'] = Variable<String>(skinType);
    }
    {
      map['sensitivities'] = Variable<String>(
        $ProfilesTableTable.$convertersensitivities.toSql(sensitivities),
      );
    }
    if (!nullToAbsent || skinToneSelf != null) {
      map['skin_tone_self'] = Variable<int>(skinToneSelf);
    }
    if (!nullToAbsent || sunHabit != null) {
      map['sun_habit'] = Variable<String>(sunHabit);
    }
    {
      map['current_actives'] = Variable<String>(
        $ProfilesTableTable.$convertercurrentActives.toSql(currentActives),
      );
    }
    if (!nullToAbsent || activesStarted != null) {
      map['actives_started'] = Variable<String>(activesStarted);
    }
    map['timezone'] = Variable<String>(timezone);
    map['locale'] = Variable<String>(locale);
    map['scan_weekday'] = Variable<int>(scanWeekday);
    map['scan_time'] = Variable<String>(scanTime);
    map['age_confirmed'] = Variable<bool>(ageConfirmed);
    map['keep_photos'] = Variable<bool>(keepPhotos);
    map['onboarding_step'] = Variable<int>(onboardingStep);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<DateTime>(
        onboardingCompletedAt,
      );
    }
    map['is_demo'] = Variable<bool>(isDemo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return ProfilesTableCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      goals: Value(goals),
      skinType: skinType == null && nullToAbsent
          ? const Value.absent()
          : Value(skinType),
      sensitivities: Value(sensitivities),
      skinToneSelf: skinToneSelf == null && nullToAbsent
          ? const Value.absent()
          : Value(skinToneSelf),
      sunHabit: sunHabit == null && nullToAbsent
          ? const Value.absent()
          : Value(sunHabit),
      currentActives: Value(currentActives),
      activesStarted: activesStarted == null && nullToAbsent
          ? const Value.absent()
          : Value(activesStarted),
      timezone: Value(timezone),
      locale: Value(locale),
      scanWeekday: Value(scanWeekday),
      scanTime: Value(scanTime),
      ageConfirmed: Value(ageConfirmed),
      keepPhotos: Value(keepPhotos),
      onboardingStep: Value(onboardingStep),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      isDemo: Value(isDemo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileEntry(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      goals: serializer.fromJson<List<String>>(json['goals']),
      skinType: serializer.fromJson<String?>(json['skinType']),
      sensitivities: serializer.fromJson<List<String>>(json['sensitivities']),
      skinToneSelf: serializer.fromJson<int?>(json['skinToneSelf']),
      sunHabit: serializer.fromJson<String?>(json['sunHabit']),
      currentActives: serializer.fromJson<List<String>>(json['currentActives']),
      activesStarted: serializer.fromJson<String?>(json['activesStarted']),
      timezone: serializer.fromJson<String>(json['timezone']),
      locale: serializer.fromJson<String>(json['locale']),
      scanWeekday: serializer.fromJson<int>(json['scanWeekday']),
      scanTime: serializer.fromJson<String>(json['scanTime']),
      ageConfirmed: serializer.fromJson<bool>(json['ageConfirmed']),
      keepPhotos: serializer.fromJson<bool>(json['keepPhotos']),
      onboardingStep: serializer.fromJson<int>(json['onboardingStep']),
      onboardingCompletedAt: serializer.fromJson<DateTime?>(
        json['onboardingCompletedAt'],
      ),
      isDemo: serializer.fromJson<bool>(json['isDemo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'goals': serializer.toJson<List<String>>(goals),
      'skinType': serializer.toJson<String?>(skinType),
      'sensitivities': serializer.toJson<List<String>>(sensitivities),
      'skinToneSelf': serializer.toJson<int?>(skinToneSelf),
      'sunHabit': serializer.toJson<String?>(sunHabit),
      'currentActives': serializer.toJson<List<String>>(currentActives),
      'activesStarted': serializer.toJson<String?>(activesStarted),
      'timezone': serializer.toJson<String>(timezone),
      'locale': serializer.toJson<String>(locale),
      'scanWeekday': serializer.toJson<int>(scanWeekday),
      'scanTime': serializer.toJson<String>(scanTime),
      'ageConfirmed': serializer.toJson<bool>(ageConfirmed),
      'keepPhotos': serializer.toJson<bool>(keepPhotos),
      'onboardingStep': serializer.toJson<int>(onboardingStep),
      'onboardingCompletedAt': serializer.toJson<DateTime?>(
        onboardingCompletedAt,
      ),
      'isDemo': serializer.toJson<bool>(isDemo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ProfileEntry copyWith({
    String? id,
    Value<String?> displayName = const Value.absent(),
    List<String>? goals,
    Value<String?> skinType = const Value.absent(),
    List<String>? sensitivities,
    Value<int?> skinToneSelf = const Value.absent(),
    Value<String?> sunHabit = const Value.absent(),
    List<String>? currentActives,
    Value<String?> activesStarted = const Value.absent(),
    String? timezone,
    String? locale,
    int? scanWeekday,
    String? scanTime,
    bool? ageConfirmed,
    bool? keepPhotos,
    int? onboardingStep,
    Value<DateTime?> onboardingCompletedAt = const Value.absent(),
    bool? isDemo,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ProfileEntry(
    id: id ?? this.id,
    displayName: displayName.present ? displayName.value : this.displayName,
    goals: goals ?? this.goals,
    skinType: skinType.present ? skinType.value : this.skinType,
    sensitivities: sensitivities ?? this.sensitivities,
    skinToneSelf: skinToneSelf.present ? skinToneSelf.value : this.skinToneSelf,
    sunHabit: sunHabit.present ? sunHabit.value : this.sunHabit,
    currentActives: currentActives ?? this.currentActives,
    activesStarted: activesStarted.present
        ? activesStarted.value
        : this.activesStarted,
    timezone: timezone ?? this.timezone,
    locale: locale ?? this.locale,
    scanWeekday: scanWeekday ?? this.scanWeekday,
    scanTime: scanTime ?? this.scanTime,
    ageConfirmed: ageConfirmed ?? this.ageConfirmed,
    keepPhotos: keepPhotos ?? this.keepPhotos,
    onboardingStep: onboardingStep ?? this.onboardingStep,
    onboardingCompletedAt: onboardingCompletedAt.present
        ? onboardingCompletedAt.value
        : this.onboardingCompletedAt,
    isDemo: isDemo ?? this.isDemo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ProfileEntry copyWithCompanion(ProfilesTableCompanion data) {
    return ProfileEntry(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      goals: data.goals.present ? data.goals.value : this.goals,
      skinType: data.skinType.present ? data.skinType.value : this.skinType,
      sensitivities: data.sensitivities.present
          ? data.sensitivities.value
          : this.sensitivities,
      skinToneSelf: data.skinToneSelf.present
          ? data.skinToneSelf.value
          : this.skinToneSelf,
      sunHabit: data.sunHabit.present ? data.sunHabit.value : this.sunHabit,
      currentActives: data.currentActives.present
          ? data.currentActives.value
          : this.currentActives,
      activesStarted: data.activesStarted.present
          ? data.activesStarted.value
          : this.activesStarted,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      locale: data.locale.present ? data.locale.value : this.locale,
      scanWeekday: data.scanWeekday.present
          ? data.scanWeekday.value
          : this.scanWeekday,
      scanTime: data.scanTime.present ? data.scanTime.value : this.scanTime,
      ageConfirmed: data.ageConfirmed.present
          ? data.ageConfirmed.value
          : this.ageConfirmed,
      keepPhotos: data.keepPhotos.present
          ? data.keepPhotos.value
          : this.keepPhotos,
      onboardingStep: data.onboardingStep.present
          ? data.onboardingStep.value
          : this.onboardingStep,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      isDemo: data.isDemo.present ? data.isDemo.value : this.isDemo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntry(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('goals: $goals, ')
          ..write('skinType: $skinType, ')
          ..write('sensitivities: $sensitivities, ')
          ..write('skinToneSelf: $skinToneSelf, ')
          ..write('sunHabit: $sunHabit, ')
          ..write('currentActives: $currentActives, ')
          ..write('activesStarted: $activesStarted, ')
          ..write('timezone: $timezone, ')
          ..write('locale: $locale, ')
          ..write('scanWeekday: $scanWeekday, ')
          ..write('scanTime: $scanTime, ')
          ..write('ageConfirmed: $ageConfirmed, ')
          ..write('keepPhotos: $keepPhotos, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    displayName,
    goals,
    skinType,
    sensitivities,
    skinToneSelf,
    sunHabit,
    currentActives,
    activesStarted,
    timezone,
    locale,
    scanWeekday,
    scanTime,
    ageConfirmed,
    keepPhotos,
    onboardingStep,
    onboardingCompletedAt,
    isDemo,
    createdAt,
    updatedAt,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileEntry &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.goals == this.goals &&
          other.skinType == this.skinType &&
          other.sensitivities == this.sensitivities &&
          other.skinToneSelf == this.skinToneSelf &&
          other.sunHabit == this.sunHabit &&
          other.currentActives == this.currentActives &&
          other.activesStarted == this.activesStarted &&
          other.timezone == this.timezone &&
          other.locale == this.locale &&
          other.scanWeekday == this.scanWeekday &&
          other.scanTime == this.scanTime &&
          other.ageConfirmed == this.ageConfirmed &&
          other.keepPhotos == this.keepPhotos &&
          other.onboardingStep == this.onboardingStep &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.isDemo == this.isDemo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class ProfilesTableCompanion extends UpdateCompanion<ProfileEntry> {
  final Value<String> id;
  final Value<String?> displayName;
  final Value<List<String>> goals;
  final Value<String?> skinType;
  final Value<List<String>> sensitivities;
  final Value<int?> skinToneSelf;
  final Value<String?> sunHabit;
  final Value<List<String>> currentActives;
  final Value<String?> activesStarted;
  final Value<String> timezone;
  final Value<String> locale;
  final Value<int> scanWeekday;
  final Value<String> scanTime;
  final Value<bool> ageConfirmed;
  final Value<bool> keepPhotos;
  final Value<int> onboardingStep;
  final Value<DateTime?> onboardingCompletedAt;
  final Value<bool> isDemo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ProfilesTableCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.goals = const Value.absent(),
    this.skinType = const Value.absent(),
    this.sensitivities = const Value.absent(),
    this.skinToneSelf = const Value.absent(),
    this.sunHabit = const Value.absent(),
    this.currentActives = const Value.absent(),
    this.activesStarted = const Value.absent(),
    this.timezone = const Value.absent(),
    this.locale = const Value.absent(),
    this.scanWeekday = const Value.absent(),
    this.scanTime = const Value.absent(),
    this.ageConfirmed = const Value.absent(),
    this.keepPhotos = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesTableCompanion.insert({
    required String id,
    this.displayName = const Value.absent(),
    this.goals = const Value.absent(),
    this.skinType = const Value.absent(),
    this.sensitivities = const Value.absent(),
    this.skinToneSelf = const Value.absent(),
    this.sunHabit = const Value.absent(),
    this.currentActives = const Value.absent(),
    this.activesStarted = const Value.absent(),
    this.timezone = const Value.absent(),
    this.locale = const Value.absent(),
    this.scanWeekday = const Value.absent(),
    this.scanTime = const Value.absent(),
    this.ageConfirmed = const Value.absent(),
    this.keepPhotos = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.isDemo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileEntry> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? goals,
    Expression<String>? skinType,
    Expression<String>? sensitivities,
    Expression<int>? skinToneSelf,
    Expression<String>? sunHabit,
    Expression<String>? currentActives,
    Expression<String>? activesStarted,
    Expression<String>? timezone,
    Expression<String>? locale,
    Expression<int>? scanWeekday,
    Expression<String>? scanTime,
    Expression<bool>? ageConfirmed,
    Expression<bool>? keepPhotos,
    Expression<int>? onboardingStep,
    Expression<DateTime>? onboardingCompletedAt,
    Expression<bool>? isDemo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (goals != null) 'goals': goals,
      if (skinType != null) 'skin_type': skinType,
      if (sensitivities != null) 'sensitivities': sensitivities,
      if (skinToneSelf != null) 'skin_tone_self': skinToneSelf,
      if (sunHabit != null) 'sun_habit': sunHabit,
      if (currentActives != null) 'current_actives': currentActives,
      if (activesStarted != null) 'actives_started': activesStarted,
      if (timezone != null) 'timezone': timezone,
      if (locale != null) 'locale': locale,
      if (scanWeekday != null) 'scan_weekday': scanWeekday,
      if (scanTime != null) 'scan_time': scanTime,
      if (ageConfirmed != null) 'age_confirmed': ageConfirmed,
      if (keepPhotos != null) 'keep_photos': keepPhotos,
      if (onboardingStep != null) 'onboarding_step': onboardingStep,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (isDemo != null) 'is_demo': isDemo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? displayName,
    Value<List<String>>? goals,
    Value<String?>? skinType,
    Value<List<String>>? sensitivities,
    Value<int?>? skinToneSelf,
    Value<String?>? sunHabit,
    Value<List<String>>? currentActives,
    Value<String?>? activesStarted,
    Value<String>? timezone,
    Value<String>? locale,
    Value<int>? scanWeekday,
    Value<String>? scanTime,
    Value<bool>? ageConfirmed,
    Value<bool>? keepPhotos,
    Value<int>? onboardingStep,
    Value<DateTime?>? onboardingCompletedAt,
    Value<bool>? isDemo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ProfilesTableCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      goals: goals ?? this.goals,
      skinType: skinType ?? this.skinType,
      sensitivities: sensitivities ?? this.sensitivities,
      skinToneSelf: skinToneSelf ?? this.skinToneSelf,
      sunHabit: sunHabit ?? this.sunHabit,
      currentActives: currentActives ?? this.currentActives,
      activesStarted: activesStarted ?? this.activesStarted,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      scanWeekday: scanWeekday ?? this.scanWeekday,
      scanTime: scanTime ?? this.scanTime,
      ageConfirmed: ageConfirmed ?? this.ageConfirmed,
      keepPhotos: keepPhotos ?? this.keepPhotos,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (goals.present) {
      map['goals'] = Variable<String>(
        $ProfilesTableTable.$convertergoals.toSql(goals.value),
      );
    }
    if (skinType.present) {
      map['skin_type'] = Variable<String>(skinType.value);
    }
    if (sensitivities.present) {
      map['sensitivities'] = Variable<String>(
        $ProfilesTableTable.$convertersensitivities.toSql(sensitivities.value),
      );
    }
    if (skinToneSelf.present) {
      map['skin_tone_self'] = Variable<int>(skinToneSelf.value);
    }
    if (sunHabit.present) {
      map['sun_habit'] = Variable<String>(sunHabit.value);
    }
    if (currentActives.present) {
      map['current_actives'] = Variable<String>(
        $ProfilesTableTable.$convertercurrentActives.toSql(
          currentActives.value,
        ),
      );
    }
    if (activesStarted.present) {
      map['actives_started'] = Variable<String>(activesStarted.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (scanWeekday.present) {
      map['scan_weekday'] = Variable<int>(scanWeekday.value);
    }
    if (scanTime.present) {
      map['scan_time'] = Variable<String>(scanTime.value);
    }
    if (ageConfirmed.present) {
      map['age_confirmed'] = Variable<bool>(ageConfirmed.value);
    }
    if (keepPhotos.present) {
      map['keep_photos'] = Variable<bool>(keepPhotos.value);
    }
    if (onboardingStep.present) {
      map['onboarding_step'] = Variable<int>(onboardingStep.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] = Variable<DateTime>(
        onboardingCompletedAt.value,
      );
    }
    if (isDemo.present) {
      map['is_demo'] = Variable<bool>(isDemo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('goals: $goals, ')
          ..write('skinType: $skinType, ')
          ..write('sensitivities: $sensitivities, ')
          ..write('skinToneSelf: $skinToneSelf, ')
          ..write('sunHabit: $sunHabit, ')
          ..write('currentActives: $currentActives, ')
          ..write('activesStarted: $activesStarted, ')
          ..write('timezone: $timezone, ')
          ..write('locale: $locale, ')
          ..write('scanWeekday: $scanWeekday, ')
          ..write('scanTime: $scanTime, ')
          ..write('ageConfirmed: $ageConfirmed, ')
          ..write('keepPhotos: $keepPhotos, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScansTableTable extends ScansTable
    with TableInfo<$ScansTableTable, ScanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScansTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('created'),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SD'),
  );
  static const VerificationMeta _apiFileIdMeta = const VerificationMeta(
    'apiFileId',
  );
  @override
  late final GeneratedColumn<String> apiFileId = GeneratedColumn<String>(
    'api_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apiTaskIdMeta = const VerificationMeta(
    'apiTaskId',
  );
  @override
  late final GeneratedColumn<String> apiTaskId = GeneratedColumn<String>(
    'api_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
    'overall_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skinAgeMeta = const VerificationMeta(
    'skinAge',
  );
  @override
  late final GeneratedColumn<int> skinAge = GeneratedColumn<int>(
    'skin_age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityOkMeta = const VerificationMeta(
    'qualityOk',
  );
  @override
  late final GeneratedColumn<bool> qualityOk = GeneratedColumn<bool>(
    'quality_ok',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quality_ok" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _qualityFlagsMeta = const VerificationMeta(
    'qualityFlags',
  );
  @override
  late final GeneratedColumn<String> qualityFlags = GeneratedColumn<String>(
    'quality_flags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDemoMeta = const VerificationMeta('isDemo');
  @override
  late final GeneratedColumn<bool> isDemo = GeneratedColumn<bool>(
    'is_demo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_demo" IN (0, 1))',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    status,
    mode,
    apiFileId,
    apiTaskId,
    errorCode,
    overallScore,
    skinAge,
    qualityOk,
    qualityFlags,
    photoPath,
    resultJson,
    isDemo,
    createdAt,
    completedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanEntry> instance, {
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('api_file_id')) {
      context.handle(
        _apiFileIdMeta,
        apiFileId.isAcceptableOrUnknown(data['api_file_id']!, _apiFileIdMeta),
      );
    }
    if (data.containsKey('api_task_id')) {
      context.handle(
        _apiTaskIdMeta,
        apiTaskId.isAcceptableOrUnknown(data['api_task_id']!, _apiTaskIdMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    }
    if (data.containsKey('skin_age')) {
      context.handle(
        _skinAgeMeta,
        skinAge.isAcceptableOrUnknown(data['skin_age']!, _skinAgeMeta),
      );
    }
    if (data.containsKey('quality_ok')) {
      context.handle(
        _qualityOkMeta,
        qualityOk.isAcceptableOrUnknown(data['quality_ok']!, _qualityOkMeta),
      );
    }
    if (data.containsKey('quality_flags')) {
      context.handle(
        _qualityFlagsMeta,
        qualityFlags.isAcceptableOrUnknown(
          data['quality_flags']!,
          _qualityFlagsMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    if (data.containsKey('is_demo')) {
      context.handle(
        _isDemoMeta,
        isDemo.isAcceptableOrUnknown(data['is_demo']!, _isDemoMeta),
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      apiFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_file_id'],
      ),
      apiTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_task_id'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_score'],
      ),
      skinAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skin_age'],
      ),
      qualityOk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quality_ok'],
      )!,
      qualityFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_flags'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
      isDemo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_demo'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ScansTableTable createAlias(String alias) {
    return $ScansTableTable(attachedDatabase, alias);
  }
}

class ScanEntry extends DataClass implements Insertable<ScanEntry> {
  /// Primary key (UUID).
  final String id;

  /// Foreign key referencing profiles(id).
  final String userId;

  /// Scan status: created, uploading, processing, done, failed, canceled.
  final String status;

  /// Scan mode: SD or HD.
  final String mode;

  /// Remote API file ID from YouCam / Supabase.
  final String? apiFileId;

  /// Remote API task ID for asynchronous polling.
  final String? apiTaskId;

  /// Error code if analysis failed.
  final String? errorCode;

  /// Overall skin score (0..100).
  final double? overallScore;

  /// Estimated skin age.
  final int? skinAge;

  /// Whether lighting and quality checks passed.
  final bool qualityOk;

  /// Quality diagnostic flags JSON.
  final String qualityFlags;

  /// Local or remote storage path for scan photo.
  final String? photoPath;

  /// Raw analysis provider result JSON.
  final String? resultJson;

  /// Whether this is a mock or demo scan.
  final bool isDemo;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Completion timestamp.
  final DateTime? completedAt;

  /// Sync timestamp with remote.
  final DateTime? syncedAt;
  const ScanEntry({
    required this.id,
    required this.userId,
    required this.status,
    required this.mode,
    this.apiFileId,
    this.apiTaskId,
    this.errorCode,
    this.overallScore,
    this.skinAge,
    required this.qualityOk,
    required this.qualityFlags,
    this.photoPath,
    this.resultJson,
    required this.isDemo,
    required this.createdAt,
    this.completedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['status'] = Variable<String>(status);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || apiFileId != null) {
      map['api_file_id'] = Variable<String>(apiFileId);
    }
    if (!nullToAbsent || apiTaskId != null) {
      map['api_task_id'] = Variable<String>(apiTaskId);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || overallScore != null) {
      map['overall_score'] = Variable<double>(overallScore);
    }
    if (!nullToAbsent || skinAge != null) {
      map['skin_age'] = Variable<int>(skinAge);
    }
    map['quality_ok'] = Variable<bool>(qualityOk);
    map['quality_flags'] = Variable<String>(qualityFlags);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    map['is_demo'] = Variable<bool>(isDemo);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ScansTableCompanion toCompanion(bool nullToAbsent) {
    return ScansTableCompanion(
      id: Value(id),
      userId: Value(userId),
      status: Value(status),
      mode: Value(mode),
      apiFileId: apiFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(apiFileId),
      apiTaskId: apiTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(apiTaskId),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      overallScore: overallScore == null && nullToAbsent
          ? const Value.absent()
          : Value(overallScore),
      skinAge: skinAge == null && nullToAbsent
          ? const Value.absent()
          : Value(skinAge),
      qualityOk: Value(qualityOk),
      qualityFlags: Value(qualityFlags),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      isDemo: Value(isDemo),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ScanEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      mode: serializer.fromJson<String>(json['mode']),
      apiFileId: serializer.fromJson<String?>(json['apiFileId']),
      apiTaskId: serializer.fromJson<String?>(json['apiTaskId']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      overallScore: serializer.fromJson<double?>(json['overallScore']),
      skinAge: serializer.fromJson<int?>(json['skinAge']),
      qualityOk: serializer.fromJson<bool>(json['qualityOk']),
      qualityFlags: serializer.fromJson<String>(json['qualityFlags']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      isDemo: serializer.fromJson<bool>(json['isDemo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String>(status),
      'mode': serializer.toJson<String>(mode),
      'apiFileId': serializer.toJson<String?>(apiFileId),
      'apiTaskId': serializer.toJson<String?>(apiTaskId),
      'errorCode': serializer.toJson<String?>(errorCode),
      'overallScore': serializer.toJson<double?>(overallScore),
      'skinAge': serializer.toJson<int?>(skinAge),
      'qualityOk': serializer.toJson<bool>(qualityOk),
      'qualityFlags': serializer.toJson<String>(qualityFlags),
      'photoPath': serializer.toJson<String?>(photoPath),
      'resultJson': serializer.toJson<String?>(resultJson),
      'isDemo': serializer.toJson<bool>(isDemo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ScanEntry copyWith({
    String? id,
    String? userId,
    String? status,
    String? mode,
    Value<String?> apiFileId = const Value.absent(),
    Value<String?> apiTaskId = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    Value<double?> overallScore = const Value.absent(),
    Value<int?> skinAge = const Value.absent(),
    bool? qualityOk,
    String? qualityFlags,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> resultJson = const Value.absent(),
    bool? isDemo,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ScanEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    status: status ?? this.status,
    mode: mode ?? this.mode,
    apiFileId: apiFileId.present ? apiFileId.value : this.apiFileId,
    apiTaskId: apiTaskId.present ? apiTaskId.value : this.apiTaskId,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    overallScore: overallScore.present ? overallScore.value : this.overallScore,
    skinAge: skinAge.present ? skinAge.value : this.skinAge,
    qualityOk: qualityOk ?? this.qualityOk,
    qualityFlags: qualityFlags ?? this.qualityFlags,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
    isDemo: isDemo ?? this.isDemo,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ScanEntry copyWithCompanion(ScansTableCompanion data) {
    return ScanEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      mode: data.mode.present ? data.mode.value : this.mode,
      apiFileId: data.apiFileId.present ? data.apiFileId.value : this.apiFileId,
      apiTaskId: data.apiTaskId.present ? data.apiTaskId.value : this.apiTaskId,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      skinAge: data.skinAge.present ? data.skinAge.value : this.skinAge,
      qualityOk: data.qualityOk.present ? data.qualityOk.value : this.qualityOk,
      qualityFlags: data.qualityFlags.present
          ? data.qualityFlags.value
          : this.qualityFlags,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      isDemo: data.isDemo.present ? data.isDemo.value : this.isDemo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('mode: $mode, ')
          ..write('apiFileId: $apiFileId, ')
          ..write('apiTaskId: $apiTaskId, ')
          ..write('errorCode: $errorCode, ')
          ..write('overallScore: $overallScore, ')
          ..write('skinAge: $skinAge, ')
          ..write('qualityOk: $qualityOk, ')
          ..write('qualityFlags: $qualityFlags, ')
          ..write('photoPath: $photoPath, ')
          ..write('resultJson: $resultJson, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    status,
    mode,
    apiFileId,
    apiTaskId,
    errorCode,
    overallScore,
    skinAge,
    qualityOk,
    qualityFlags,
    photoPath,
    resultJson,
    isDemo,
    createdAt,
    completedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.mode == this.mode &&
          other.apiFileId == this.apiFileId &&
          other.apiTaskId == this.apiTaskId &&
          other.errorCode == this.errorCode &&
          other.overallScore == this.overallScore &&
          other.skinAge == this.skinAge &&
          other.qualityOk == this.qualityOk &&
          other.qualityFlags == this.qualityFlags &&
          other.photoPath == this.photoPath &&
          other.resultJson == this.resultJson &&
          other.isDemo == this.isDemo &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.syncedAt == this.syncedAt);
}

class ScansTableCompanion extends UpdateCompanion<ScanEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> status;
  final Value<String> mode;
  final Value<String?> apiFileId;
  final Value<String?> apiTaskId;
  final Value<String?> errorCode;
  final Value<double?> overallScore;
  final Value<int?> skinAge;
  final Value<bool> qualityOk;
  final Value<String> qualityFlags;
  final Value<String?> photoPath;
  final Value<String?> resultJson;
  final Value<bool> isDemo;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ScansTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.mode = const Value.absent(),
    this.apiFileId = const Value.absent(),
    this.apiTaskId = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.skinAge = const Value.absent(),
    this.qualityOk = const Value.absent(),
    this.qualityFlags = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScansTableCompanion.insert({
    required String id,
    required String userId,
    this.status = const Value.absent(),
    this.mode = const Value.absent(),
    this.apiFileId = const Value.absent(),
    this.apiTaskId = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.skinAge = const Value.absent(),
    this.qualityOk = const Value.absent(),
    this.qualityFlags = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.isDemo = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       createdAt = Value(createdAt);
  static Insertable<ScanEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<String>? mode,
    Expression<String>? apiFileId,
    Expression<String>? apiTaskId,
    Expression<String>? errorCode,
    Expression<double>? overallScore,
    Expression<int>? skinAge,
    Expression<bool>? qualityOk,
    Expression<String>? qualityFlags,
    Expression<String>? photoPath,
    Expression<String>? resultJson,
    Expression<bool>? isDemo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (mode != null) 'mode': mode,
      if (apiFileId != null) 'api_file_id': apiFileId,
      if (apiTaskId != null) 'api_task_id': apiTaskId,
      if (errorCode != null) 'error_code': errorCode,
      if (overallScore != null) 'overall_score': overallScore,
      if (skinAge != null) 'skin_age': skinAge,
      if (qualityOk != null) 'quality_ok': qualityOk,
      if (qualityFlags != null) 'quality_flags': qualityFlags,
      if (photoPath != null) 'photo_path': photoPath,
      if (resultJson != null) 'result_json': resultJson,
      if (isDemo != null) 'is_demo': isDemo,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScansTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? status,
    Value<String>? mode,
    Value<String?>? apiFileId,
    Value<String?>? apiTaskId,
    Value<String?>? errorCode,
    Value<double?>? overallScore,
    Value<int?>? skinAge,
    Value<bool>? qualityOk,
    Value<String>? qualityFlags,
    Value<String?>? photoPath,
    Value<String?>? resultJson,
    Value<bool>? isDemo,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ScansTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      apiFileId: apiFileId ?? this.apiFileId,
      apiTaskId: apiTaskId ?? this.apiTaskId,
      errorCode: errorCode ?? this.errorCode,
      overallScore: overallScore ?? this.overallScore,
      skinAge: skinAge ?? this.skinAge,
      qualityOk: qualityOk ?? this.qualityOk,
      qualityFlags: qualityFlags ?? this.qualityFlags,
      photoPath: photoPath ?? this.photoPath,
      resultJson: resultJson ?? this.resultJson,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (apiFileId.present) {
      map['api_file_id'] = Variable<String>(apiFileId.value);
    }
    if (apiTaskId.present) {
      map['api_task_id'] = Variable<String>(apiTaskId.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (skinAge.present) {
      map['skin_age'] = Variable<int>(skinAge.value);
    }
    if (qualityOk.present) {
      map['quality_ok'] = Variable<bool>(qualityOk.value);
    }
    if (qualityFlags.present) {
      map['quality_flags'] = Variable<String>(qualityFlags.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (isDemo.present) {
      map['is_demo'] = Variable<bool>(isDemo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScansTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('mode: $mode, ')
          ..write('apiFileId: $apiFileId, ')
          ..write('apiTaskId: $apiTaskId, ')
          ..write('errorCode: $errorCode, ')
          ..write('overallScore: $overallScore, ')
          ..write('skinAge: $skinAge, ')
          ..write('qualityOk: $qualityOk, ')
          ..write('qualityFlags: $qualityFlags, ')
          ..write('photoPath: $photoPath, ')
          ..write('resultJson: $resultJson, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanConcernsTableTable extends ScanConcernsTable
    with TableInfo<$ScanConcernsTableTable, ScanConcernEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanConcernsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<String> scanId = GeneratedColumn<String>(
    'scan_id',
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
  static const VerificationMeta _concernMeta = const VerificationMeta(
    'concern',
  );
  @override
  late final GeneratedColumn<String> concern = GeneratedColumn<String>(
    'concern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawScoreMeta = const VerificationMeta(
    'rawScore',
  );
  @override
  late final GeneratedColumn<double> rawScore = GeneratedColumn<double>(
    'raw_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uiScoreMeta = const VerificationMeta(
    'uiScore',
  );
  @override
  late final GeneratedColumn<double> uiScore = GeneratedColumn<double>(
    'ui_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maskPathMeta = const VerificationMeta(
    'maskPath',
  );
  @override
  late final GeneratedColumn<String> maskPath = GeneratedColumn<String>(
    'mask_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scanId,
    userId,
    concern,
    zone,
    rawScore,
    uiScore,
    maskPath,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_concerns';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanConcernEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('concern')) {
      context.handle(
        _concernMeta,
        concern.isAcceptableOrUnknown(data['concern']!, _concernMeta),
      );
    } else if (isInserting) {
      context.missing(_concernMeta);
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    }
    if (data.containsKey('raw_score')) {
      context.handle(
        _rawScoreMeta,
        rawScore.isAcceptableOrUnknown(data['raw_score']!, _rawScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_rawScoreMeta);
    }
    if (data.containsKey('ui_score')) {
      context.handle(
        _uiScoreMeta,
        uiScore.isAcceptableOrUnknown(data['ui_score']!, _uiScoreMeta),
      );
    }
    if (data.containsKey('mask_path')) {
      context.handle(
        _maskPathMeta,
        maskPath.isAcceptableOrUnknown(data['mask_path']!, _maskPathMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanConcernEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanConcernEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      concern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concern'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      ),
      rawScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}raw_score'],
      )!,
      uiScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ui_score'],
      ),
      maskPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mask_path'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ScanConcernsTableTable createAlias(String alias) {
    return $ScanConcernsTableTable(attachedDatabase, alias);
  }
}

class ScanConcernEntry extends DataClass
    implements Insertable<ScanConcernEntry> {
  /// Primary key (UUID).
  final String id;

  /// Foreign key referencing scans(id).
  final String scanId;

  /// Foreign key referencing profiles(id).
  final String userId;

  /// Concern metric key (e.g. spots, wrinkles, pores, texture).
  final String concern;

  /// Facial zone (forehead, left_cheek, etc.).
  final String? zone;

  /// Normalized raw score (0..100) used for trends and clinical verdicts.
  final double rawScore;

  /// Provider cosmetic display score.
  final double? uiScore;

  /// Path to mask overlay image.
  final String? maskPath;

  /// Sync timestamp with remote.
  final DateTime? syncedAt;
  const ScanConcernEntry({
    required this.id,
    required this.scanId,
    required this.userId,
    required this.concern,
    this.zone,
    required this.rawScore,
    this.uiScore,
    this.maskPath,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scan_id'] = Variable<String>(scanId);
    map['user_id'] = Variable<String>(userId);
    map['concern'] = Variable<String>(concern);
    if (!nullToAbsent || zone != null) {
      map['zone'] = Variable<String>(zone);
    }
    map['raw_score'] = Variable<double>(rawScore);
    if (!nullToAbsent || uiScore != null) {
      map['ui_score'] = Variable<double>(uiScore);
    }
    if (!nullToAbsent || maskPath != null) {
      map['mask_path'] = Variable<String>(maskPath);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ScanConcernsTableCompanion toCompanion(bool nullToAbsent) {
    return ScanConcernsTableCompanion(
      id: Value(id),
      scanId: Value(scanId),
      userId: Value(userId),
      concern: Value(concern),
      zone: zone == null && nullToAbsent ? const Value.absent() : Value(zone),
      rawScore: Value(rawScore),
      uiScore: uiScore == null && nullToAbsent
          ? const Value.absent()
          : Value(uiScore),
      maskPath: maskPath == null && nullToAbsent
          ? const Value.absent()
          : Value(maskPath),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ScanConcernEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanConcernEntry(
      id: serializer.fromJson<String>(json['id']),
      scanId: serializer.fromJson<String>(json['scanId']),
      userId: serializer.fromJson<String>(json['userId']),
      concern: serializer.fromJson<String>(json['concern']),
      zone: serializer.fromJson<String?>(json['zone']),
      rawScore: serializer.fromJson<double>(json['rawScore']),
      uiScore: serializer.fromJson<double?>(json['uiScore']),
      maskPath: serializer.fromJson<String?>(json['maskPath']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scanId': serializer.toJson<String>(scanId),
      'userId': serializer.toJson<String>(userId),
      'concern': serializer.toJson<String>(concern),
      'zone': serializer.toJson<String?>(zone),
      'rawScore': serializer.toJson<double>(rawScore),
      'uiScore': serializer.toJson<double?>(uiScore),
      'maskPath': serializer.toJson<String?>(maskPath),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ScanConcernEntry copyWith({
    String? id,
    String? scanId,
    String? userId,
    String? concern,
    Value<String?> zone = const Value.absent(),
    double? rawScore,
    Value<double?> uiScore = const Value.absent(),
    Value<String?> maskPath = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ScanConcernEntry(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    userId: userId ?? this.userId,
    concern: concern ?? this.concern,
    zone: zone.present ? zone.value : this.zone,
    rawScore: rawScore ?? this.rawScore,
    uiScore: uiScore.present ? uiScore.value : this.uiScore,
    maskPath: maskPath.present ? maskPath.value : this.maskPath,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ScanConcernEntry copyWithCompanion(ScanConcernsTableCompanion data) {
    return ScanConcernEntry(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      userId: data.userId.present ? data.userId.value : this.userId,
      concern: data.concern.present ? data.concern.value : this.concern,
      zone: data.zone.present ? data.zone.value : this.zone,
      rawScore: data.rawScore.present ? data.rawScore.value : this.rawScore,
      uiScore: data.uiScore.present ? data.uiScore.value : this.uiScore,
      maskPath: data.maskPath.present ? data.maskPath.value : this.maskPath,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanConcernEntry(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('userId: $userId, ')
          ..write('concern: $concern, ')
          ..write('zone: $zone, ')
          ..write('rawScore: $rawScore, ')
          ..write('uiScore: $uiScore, ')
          ..write('maskPath: $maskPath, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scanId,
    userId,
    concern,
    zone,
    rawScore,
    uiScore,
    maskPath,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanConcernEntry &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.userId == this.userId &&
          other.concern == this.concern &&
          other.zone == this.zone &&
          other.rawScore == this.rawScore &&
          other.uiScore == this.uiScore &&
          other.maskPath == this.maskPath &&
          other.syncedAt == this.syncedAt);
}

class ScanConcernsTableCompanion extends UpdateCompanion<ScanConcernEntry> {
  final Value<String> id;
  final Value<String> scanId;
  final Value<String> userId;
  final Value<String> concern;
  final Value<String?> zone;
  final Value<double> rawScore;
  final Value<double?> uiScore;
  final Value<String?> maskPath;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ScanConcernsTableCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.userId = const Value.absent(),
    this.concern = const Value.absent(),
    this.zone = const Value.absent(),
    this.rawScore = const Value.absent(),
    this.uiScore = const Value.absent(),
    this.maskPath = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanConcernsTableCompanion.insert({
    required String id,
    required String scanId,
    required String userId,
    required String concern,
    this.zone = const Value.absent(),
    required double rawScore,
    this.uiScore = const Value.absent(),
    this.maskPath = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scanId = Value(scanId),
       userId = Value(userId),
       concern = Value(concern),
       rawScore = Value(rawScore);
  static Insertable<ScanConcernEntry> custom({
    Expression<String>? id,
    Expression<String>? scanId,
    Expression<String>? userId,
    Expression<String>? concern,
    Expression<String>? zone,
    Expression<double>? rawScore,
    Expression<double>? uiScore,
    Expression<String>? maskPath,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (userId != null) 'user_id': userId,
      if (concern != null) 'concern': concern,
      if (zone != null) 'zone': zone,
      if (rawScore != null) 'raw_score': rawScore,
      if (uiScore != null) 'ui_score': uiScore,
      if (maskPath != null) 'mask_path': maskPath,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanConcernsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? scanId,
    Value<String>? userId,
    Value<String>? concern,
    Value<String?>? zone,
    Value<double>? rawScore,
    Value<double?>? uiScore,
    Value<String?>? maskPath,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ScanConcernsTableCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      userId: userId ?? this.userId,
      concern: concern ?? this.concern,
      zone: zone ?? this.zone,
      rawScore: rawScore ?? this.rawScore,
      uiScore: uiScore ?? this.uiScore,
      maskPath: maskPath ?? this.maskPath,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<String>(scanId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (concern.present) {
      map['concern'] = Variable<String>(concern.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (rawScore.present) {
      map['raw_score'] = Variable<double>(rawScore.value);
    }
    if (uiScore.present) {
      map['ui_score'] = Variable<double>(uiScore.value);
    }
    if (maskPath.present) {
      map['mask_path'] = Variable<String>(maskPath.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanConcernsTableCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('userId: $userId, ')
          ..write('concern: $concern, ')
          ..write('zone: $zone, ')
          ..write('rawScore: $rawScore, ')
          ..write('uiScore: $uiScore, ')
          ..write('maskPath: $maskPath, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTableTable extends RoutineItemsTable
    with TableInfo<$RoutineItemsTableTable, RoutineItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepTypeMeta = const VerificationMeta(
    'stepType',
  );
  @override
  late final GeneratedColumn<String> stepType = GeneratedColumn<String>(
    'step_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> actives =
      GeneratedColumn<String>(
        'actives',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($RoutineItemsTableTable.$converteractives);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('both'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>?, String> days =
      GeneratedColumn<String>(
        'days',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<int>?>($RoutineItemsTableTable.$converterdaysn);
  static const VerificationMeta _startedOnMeta = const VerificationMeta(
    'startedOn',
  );
  @override
  late final GeneratedColumn<DateTime> startedOn = GeneratedColumn<DateTime>(
    'started_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _catalogProductIdMeta = const VerificationMeta(
    'catalogProductId',
  );
  @override
  late final GeneratedColumn<String> catalogProductId = GeneratedColumn<String>(
    'catalog_product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientsRawMeta = const VerificationMeta(
    'ingredientsRaw',
  );
  @override
  late final GeneratedColumn<String> ingredientsRaw = GeneratedColumn<String>(
    'ingredients_raw',
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    brand,
    stepType,
    actives,
    period,
    days,
    startedOn,
    active,
    sortOrder,
    catalogProductId,
    ingredientsRaw,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineItemEntry> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('step_type')) {
      context.handle(
        _stepTypeMeta,
        stepType.isAcceptableOrUnknown(data['step_type']!, _stepTypeMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('started_on')) {
      context.handle(
        _startedOnMeta,
        startedOn.isAcceptableOrUnknown(data['started_on']!, _startedOnMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('catalog_product_id')) {
      context.handle(
        _catalogProductIdMeta,
        catalogProductId.isAcceptableOrUnknown(
          data['catalog_product_id']!,
          _catalogProductIdMeta,
        ),
      );
    }
    if (data.containsKey('ingredients_raw')) {
      context.handle(
        _ingredientsRawMeta,
        ingredientsRaw.isAcceptableOrUnknown(
          data['ingredients_raw']!,
          _ingredientsRawMeta,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItemEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      stepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_type'],
      )!,
      actives: $RoutineItemsTableTable.$converteractives.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}actives'],
        )!,
      ),
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      days: $RoutineItemsTableTable.$converterdaysn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}days'],
        ),
      ),
      startedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_on'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      catalogProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_product_id'],
      ),
      ingredientsRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients_raw'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $RoutineItemsTableTable createAlias(String alias) {
    return $RoutineItemsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converteractives =
      const StringListConverter();
  static TypeConverter<List<int>, String> $converterdays =
      const IntListConverter();
  static TypeConverter<List<int>?, String?> $converterdaysn =
      NullAwareTypeConverter.wrap($converterdays);
}

class RoutineItemEntry extends DataClass
    implements Insertable<RoutineItemEntry> {
  /// Primary key (UUID).
  final String id;

  /// Foreign key referencing profiles(id).
  final String userId;

  /// Product name.
  final String name;

  /// Product brand name.
  final String? brand;

  /// Step type: cleanser, toner, serum, treatment, moisturizer, spf, mask, other.
  final String stepType;

  /// Active ingredients in product.
  final List<String> actives;

  /// Routine application period: am, pm, both.
  final String period;

  /// Days of application (ISO weekdays 1..7).
  final List<int>? days;

  /// Date started using this product.
  final DateTime? startedOn;

  /// Whether product is actively in the routine.
  final bool active;

  /// Display sort order index.
  final int sortOrder;

  /// Optional link to catalog product.
  final String? catalogProductId;

  /// Raw OCR ingredients text.
  final String? ingredientsRaw;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Sync timestamp with remote.
  final DateTime? syncedAt;
  const RoutineItemEntry({
    required this.id,
    required this.userId,
    required this.name,
    this.brand,
    required this.stepType,
    required this.actives,
    required this.period,
    this.days,
    this.startedOn,
    required this.active,
    required this.sortOrder,
    this.catalogProductId,
    this.ingredientsRaw,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['step_type'] = Variable<String>(stepType);
    {
      map['actives'] = Variable<String>(
        $RoutineItemsTableTable.$converteractives.toSql(actives),
      );
    }
    map['period'] = Variable<String>(period);
    if (!nullToAbsent || days != null) {
      map['days'] = Variable<String>(
        $RoutineItemsTableTable.$converterdaysn.toSql(days),
      );
    }
    if (!nullToAbsent || startedOn != null) {
      map['started_on'] = Variable<DateTime>(startedOn);
    }
    map['active'] = Variable<bool>(active);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || catalogProductId != null) {
      map['catalog_product_id'] = Variable<String>(catalogProductId);
    }
    if (!nullToAbsent || ingredientsRaw != null) {
      map['ingredients_raw'] = Variable<String>(ingredientsRaw);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  RoutineItemsTableCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      stepType: Value(stepType),
      actives: Value(actives),
      period: Value(period),
      days: days == null && nullToAbsent ? const Value.absent() : Value(days),
      startedOn: startedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startedOn),
      active: Value(active),
      sortOrder: Value(sortOrder),
      catalogProductId: catalogProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogProductId),
      ingredientsRaw: ingredientsRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientsRaw),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory RoutineItemEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItemEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      stepType: serializer.fromJson<String>(json['stepType']),
      actives: serializer.fromJson<List<String>>(json['actives']),
      period: serializer.fromJson<String>(json['period']),
      days: serializer.fromJson<List<int>?>(json['days']),
      startedOn: serializer.fromJson<DateTime?>(json['startedOn']),
      active: serializer.fromJson<bool>(json['active']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      catalogProductId: serializer.fromJson<String?>(json['catalogProductId']),
      ingredientsRaw: serializer.fromJson<String?>(json['ingredientsRaw']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'stepType': serializer.toJson<String>(stepType),
      'actives': serializer.toJson<List<String>>(actives),
      'period': serializer.toJson<String>(period),
      'days': serializer.toJson<List<int>?>(days),
      'startedOn': serializer.toJson<DateTime?>(startedOn),
      'active': serializer.toJson<bool>(active),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'catalogProductId': serializer.toJson<String?>(catalogProductId),
      'ingredientsRaw': serializer.toJson<String?>(ingredientsRaw),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  RoutineItemEntry copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> brand = const Value.absent(),
    String? stepType,
    List<String>? actives,
    String? period,
    Value<List<int>?> days = const Value.absent(),
    Value<DateTime?> startedOn = const Value.absent(),
    bool? active,
    int? sortOrder,
    Value<String?> catalogProductId = const Value.absent(),
    Value<String?> ingredientsRaw = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => RoutineItemEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    stepType: stepType ?? this.stepType,
    actives: actives ?? this.actives,
    period: period ?? this.period,
    days: days.present ? days.value : this.days,
    startedOn: startedOn.present ? startedOn.value : this.startedOn,
    active: active ?? this.active,
    sortOrder: sortOrder ?? this.sortOrder,
    catalogProductId: catalogProductId.present
        ? catalogProductId.value
        : this.catalogProductId,
    ingredientsRaw: ingredientsRaw.present
        ? ingredientsRaw.value
        : this.ingredientsRaw,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  RoutineItemEntry copyWithCompanion(RoutineItemsTableCompanion data) {
    return RoutineItemEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      stepType: data.stepType.present ? data.stepType.value : this.stepType,
      actives: data.actives.present ? data.actives.value : this.actives,
      period: data.period.present ? data.period.value : this.period,
      days: data.days.present ? data.days.value : this.days,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      active: data.active.present ? data.active.value : this.active,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      catalogProductId: data.catalogProductId.present
          ? data.catalogProductId.value
          : this.catalogProductId,
      ingredientsRaw: data.ingredientsRaw.present
          ? data.ingredientsRaw.value
          : this.ingredientsRaw,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('stepType: $stepType, ')
          ..write('actives: $actives, ')
          ..write('period: $period, ')
          ..write('days: $days, ')
          ..write('startedOn: $startedOn, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('catalogProductId: $catalogProductId, ')
          ..write('ingredientsRaw: $ingredientsRaw, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    brand,
    stepType,
    actives,
    period,
    days,
    startedOn,
    active,
    sortOrder,
    catalogProductId,
    ingredientsRaw,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItemEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.stepType == this.stepType &&
          other.actives == this.actives &&
          other.period == this.period &&
          other.days == this.days &&
          other.startedOn == this.startedOn &&
          other.active == this.active &&
          other.sortOrder == this.sortOrder &&
          other.catalogProductId == this.catalogProductId &&
          other.ingredientsRaw == this.ingredientsRaw &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class RoutineItemsTableCompanion extends UpdateCompanion<RoutineItemEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String> stepType;
  final Value<List<String>> actives;
  final Value<String> period;
  final Value<List<int>?> days;
  final Value<DateTime?> startedOn;
  final Value<bool> active;
  final Value<int> sortOrder;
  final Value<String?> catalogProductId;
  final Value<String?> ingredientsRaw;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const RoutineItemsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.stepType = const Value.absent(),
    this.actives = const Value.absent(),
    this.period = const Value.absent(),
    this.days = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.catalogProductId = const Value.absent(),
    this.ingredientsRaw = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineItemsTableCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.brand = const Value.absent(),
    this.stepType = const Value.absent(),
    this.actives = const Value.absent(),
    this.period = const Value.absent(),
    this.days = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.catalogProductId = const Value.absent(),
    this.ingredientsRaw = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineItemEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? stepType,
    Expression<String>? actives,
    Expression<String>? period,
    Expression<String>? days,
    Expression<DateTime>? startedOn,
    Expression<bool>? active,
    Expression<int>? sortOrder,
    Expression<String>? catalogProductId,
    Expression<String>? ingredientsRaw,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (stepType != null) 'step_type': stepType,
      if (actives != null) 'actives': actives,
      if (period != null) 'period': period,
      if (days != null) 'days': days,
      if (startedOn != null) 'started_on': startedOn,
      if (active != null) 'active': active,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (catalogProductId != null) 'catalog_product_id': catalogProductId,
      if (ingredientsRaw != null) 'ingredients_raw': ingredientsRaw,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? brand,
    Value<String>? stepType,
    Value<List<String>>? actives,
    Value<String>? period,
    Value<List<int>?>? days,
    Value<DateTime?>? startedOn,
    Value<bool>? active,
    Value<int>? sortOrder,
    Value<String?>? catalogProductId,
    Value<String?>? ingredientsRaw,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return RoutineItemsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      stepType: stepType ?? this.stepType,
      actives: actives ?? this.actives,
      period: period ?? this.period,
      days: days ?? this.days,
      startedOn: startedOn ?? this.startedOn,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      catalogProductId: catalogProductId ?? this.catalogProductId,
      ingredientsRaw: ingredientsRaw ?? this.ingredientsRaw,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (stepType.present) {
      map['step_type'] = Variable<String>(stepType.value);
    }
    if (actives.present) {
      map['actives'] = Variable<String>(
        $RoutineItemsTableTable.$converteractives.toSql(actives.value),
      );
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (days.present) {
      map['days'] = Variable<String>(
        $RoutineItemsTableTable.$converterdaysn.toSql(days.value),
      );
    }
    if (startedOn.present) {
      map['started_on'] = Variable<DateTime>(startedOn.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (catalogProductId.present) {
      map['catalog_product_id'] = Variable<String>(catalogProductId.value);
    }
    if (ingredientsRaw.present) {
      map['ingredients_raw'] = Variable<String>(ingredientsRaw.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('stepType: $stepType, ')
          ..write('actives: $actives, ')
          ..write('period: $period, ')
          ..write('days: $days, ')
          ..write('startedOn: $startedOn, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('catalogProductId: $catalogProductId, ')
          ..write('ingredientsRaw: $ingredientsRaw, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineLogsTableTable extends RoutineLogsTable
    with TableInfo<$RoutineLogsTableTable, RoutineLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineLogsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('am'),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    itemId,
    logDate,
    period,
    done,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineLogEntry> instance, {
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $RoutineLogsTableTable createAlias(String alias) {
    return $RoutineLogsTableTable(attachedDatabase, alias);
  }
}

class RoutineLogEntry extends DataClass implements Insertable<RoutineLogEntry> {
  /// Primary key (UUID).
  final String id;

  /// Foreign key referencing profiles(id).
  final String userId;

  /// Foreign key referencing routine_items(id).
  final String itemId;

  /// ISO date string (YYYY-MM-DD).
  final String logDate;

  /// Period: am or pm.
  final String period;

  /// Whether step was completed.
  final bool done;

  /// Log creation timestamp.
  final DateTime createdAt;

  /// Sync timestamp with remote.
  final DateTime? syncedAt;
  const RoutineLogEntry({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.logDate,
    required this.period,
    required this.done,
    required this.createdAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['item_id'] = Variable<String>(itemId);
    map['log_date'] = Variable<String>(logDate);
    map['period'] = Variable<String>(period);
    map['done'] = Variable<bool>(done);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  RoutineLogsTableCompanion toCompanion(bool nullToAbsent) {
    return RoutineLogsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      itemId: Value(itemId),
      logDate: Value(logDate),
      period: Value(period),
      done: Value(done),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory RoutineLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineLogEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      logDate: serializer.fromJson<String>(json['logDate']),
      period: serializer.fromJson<String>(json['period']),
      done: serializer.fromJson<bool>(json['done']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'itemId': serializer.toJson<String>(itemId),
      'logDate': serializer.toJson<String>(logDate),
      'period': serializer.toJson<String>(period),
      'done': serializer.toJson<bool>(done),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  RoutineLogEntry copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? logDate,
    String? period,
    bool? done,
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => RoutineLogEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    itemId: itemId ?? this.itemId,
    logDate: logDate ?? this.logDate,
    period: period ?? this.period,
    done: done ?? this.done,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  RoutineLogEntry copyWithCompanion(RoutineLogsTableCompanion data) {
    return RoutineLogEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      period: data.period.present ? data.period.value : this.period,
      done: data.done.present ? data.done.value : this.done,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLogEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('logDate: $logDate, ')
          ..write('period: $period, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    itemId,
    logDate,
    period,
    done,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineLogEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.itemId == this.itemId &&
          other.logDate == this.logDate &&
          other.period == this.period &&
          other.done == this.done &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class RoutineLogsTableCompanion extends UpdateCompanion<RoutineLogEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> itemId;
  final Value<String> logDate;
  final Value<String> period;
  final Value<bool> done;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const RoutineLogsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.period = const Value.absent(),
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineLogsTableCompanion.insert({
    required String id,
    required String userId,
    required String itemId,
    required String logDate,
    this.period = const Value.absent(),
    this.done = const Value.absent(),
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       itemId = Value(itemId),
       logDate = Value(logDate),
       createdAt = Value(createdAt);
  static Insertable<RoutineLogEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? itemId,
    Expression<String>? logDate,
    Expression<String>? period,
    Expression<bool>? done,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (itemId != null) 'item_id': itemId,
      if (logDate != null) 'log_date': logDate,
      if (period != null) 'period': period,
      if (done != null) 'done': done,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? itemId,
    Value<String>? logDate,
    Value<String>? period,
    Value<bool>? done,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return RoutineLogsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      logDate: logDate ?? this.logDate,
      period: period ?? this.period,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('logDate: $logDate, ')
          ..write('period: $period, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperimentsTableTable extends ExperimentsTable
    with TableInfo<$ExperimentsTableTable, ExperimentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> targets =
      GeneratedColumn<String>(
        'targets',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ExperimentsTableTable.$convertertargets);
  static const VerificationMeta _plannedDaysMeta = const VerificationMeta(
    'plannedDays',
  );
  @override
  late final GeneratedColumn<int> plannedDays = GeneratedColumn<int>(
    'planned_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(42),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedOnMeta = const VerificationMeta(
    'startedOn',
  );
  @override
  late final GeneratedColumn<String> startedOn = GeneratedColumn<String>(
    'started_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adherenceMeta = const VerificationMeta(
    'adherence',
  );
  @override
  late final GeneratedColumn<double> adherence = GeneratedColumn<double>(
    'adherence',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    itemId,
    title,
    targets,
    plannedDays,
    startedAt,
    startedOn,
    endedAt,
    status,
    verdict,
    adherence,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExperimentEntry> instance, {
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('planned_days')) {
      context.handle(
        _plannedDaysMeta,
        plannedDays.isAcceptableOrUnknown(
          data['planned_days']!,
          _plannedDaysMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('started_on')) {
      context.handle(
        _startedOnMeta,
        startedOn.isAcceptableOrUnknown(data['started_on']!, _startedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startedOnMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    }
    if (data.containsKey('adherence')) {
      context.handle(
        _adherenceMeta,
        adherence.isAcceptableOrUnknown(data['adherence']!, _adherenceMeta),
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
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExperimentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExperimentEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      targets: $ExperimentsTableTable.$convertertargets.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}targets'],
        )!,
      ),
      plannedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_days'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      startedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_on'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      ),
      adherence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}adherence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ExperimentsTableTable createAlias(String alias) {
    return $ExperimentsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertargets =
      const StringListConverter();
}

class ExperimentEntry extends DataClass implements Insertable<ExperimentEntry> {
  /// Primary key (UUID).
  final String id;

  /// Foreign key referencing profiles(id).
  final String userId;

  /// Optional foreign key referencing routine_items(id).
  final String? itemId;

  /// Experiment title (snapshot of tested product).
  final String title;

  /// Target concern keys (1..2).
  final List<String> targets;

  /// Planned tracking days (14..180).
  final int plannedDays;

  /// Started timestamp.
  final DateTime startedAt;

  /// ISO date string when experiment started (YYYY-MM-DD).
  final String startedOn;

  /// Ended timestamp if finished or stopped.
  final DateTime? endedAt;

  /// Status: active, paused, completed, stopped.
  final String status;

  /// Statistical / AI verdict JSON snapshot.
  final String? verdict;

  /// Adherence rate (0.000 to 1.000).
  final double? adherence;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Sync timestamp with remote.
  final DateTime? syncedAt;
  const ExperimentEntry({
    required this.id,
    required this.userId,
    this.itemId,
    required this.title,
    required this.targets,
    required this.plannedDays,
    required this.startedAt,
    required this.startedOn,
    this.endedAt,
    required this.status,
    this.verdict,
    this.adherence,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    map['title'] = Variable<String>(title);
    {
      map['targets'] = Variable<String>(
        $ExperimentsTableTable.$convertertargets.toSql(targets),
      );
    }
    map['planned_days'] = Variable<int>(plannedDays);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['started_on'] = Variable<String>(startedOn);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || verdict != null) {
      map['verdict'] = Variable<String>(verdict);
    }
    if (!nullToAbsent || adherence != null) {
      map['adherence'] = Variable<double>(adherence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ExperimentsTableCompanion toCompanion(bool nullToAbsent) {
    return ExperimentsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      title: Value(title),
      targets: Value(targets),
      plannedDays: Value(plannedDays),
      startedAt: Value(startedAt),
      startedOn: Value(startedOn),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      verdict: verdict == null && nullToAbsent
          ? const Value.absent()
          : Value(verdict),
      adherence: adherence == null && nullToAbsent
          ? const Value.absent()
          : Value(adherence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ExperimentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExperimentEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      title: serializer.fromJson<String>(json['title']),
      targets: serializer.fromJson<List<String>>(json['targets']),
      plannedDays: serializer.fromJson<int>(json['plannedDays']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      startedOn: serializer.fromJson<String>(json['startedOn']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      verdict: serializer.fromJson<String?>(json['verdict']),
      adherence: serializer.fromJson<double?>(json['adherence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'itemId': serializer.toJson<String?>(itemId),
      'title': serializer.toJson<String>(title),
      'targets': serializer.toJson<List<String>>(targets),
      'plannedDays': serializer.toJson<int>(plannedDays),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'startedOn': serializer.toJson<String>(startedOn),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'verdict': serializer.toJson<String?>(verdict),
      'adherence': serializer.toJson<double?>(adherence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ExperimentEntry copyWith({
    String? id,
    String? userId,
    Value<String?> itemId = const Value.absent(),
    String? title,
    List<String>? targets,
    int? plannedDays,
    DateTime? startedAt,
    String? startedOn,
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    Value<String?> verdict = const Value.absent(),
    Value<double?> adherence = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ExperimentEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    itemId: itemId.present ? itemId.value : this.itemId,
    title: title ?? this.title,
    targets: targets ?? this.targets,
    plannedDays: plannedDays ?? this.plannedDays,
    startedAt: startedAt ?? this.startedAt,
    startedOn: startedOn ?? this.startedOn,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    verdict: verdict.present ? verdict.value : this.verdict,
    adherence: adherence.present ? adherence.value : this.adherence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ExperimentEntry copyWithCompanion(ExperimentsTableCompanion data) {
    return ExperimentEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      title: data.title.present ? data.title.value : this.title,
      targets: data.targets.present ? data.targets.value : this.targets,
      plannedDays: data.plannedDays.present
          ? data.plannedDays.value
          : this.plannedDays,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      adherence: data.adherence.present ? data.adherence.value : this.adherence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('targets: $targets, ')
          ..write('plannedDays: $plannedDays, ')
          ..write('startedAt: $startedAt, ')
          ..write('startedOn: $startedOn, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('verdict: $verdict, ')
          ..write('adherence: $adherence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    itemId,
    title,
    targets,
    plannedDays,
    startedAt,
    startedOn,
    endedAt,
    status,
    verdict,
    adherence,
    createdAt,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExperimentEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.itemId == this.itemId &&
          other.title == this.title &&
          other.targets == this.targets &&
          other.plannedDays == this.plannedDays &&
          other.startedAt == this.startedAt &&
          other.startedOn == this.startedOn &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.verdict == this.verdict &&
          other.adherence == this.adherence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class ExperimentsTableCompanion extends UpdateCompanion<ExperimentEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> itemId;
  final Value<String> title;
  final Value<List<String>> targets;
  final Value<int> plannedDays;
  final Value<DateTime> startedAt;
  final Value<String> startedOn;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<String?> verdict;
  final Value<double?> adherence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ExperimentsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.title = const Value.absent(),
    this.targets = const Value.absent(),
    this.plannedDays = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.verdict = const Value.absent(),
    this.adherence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperimentsTableCompanion.insert({
    required String id,
    required String userId,
    this.itemId = const Value.absent(),
    required String title,
    this.targets = const Value.absent(),
    this.plannedDays = const Value.absent(),
    required DateTime startedAt,
    required String startedOn,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.verdict = const Value.absent(),
    this.adherence = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       startedAt = Value(startedAt),
       startedOn = Value(startedOn),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExperimentEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? itemId,
    Expression<String>? title,
    Expression<String>? targets,
    Expression<int>? plannedDays,
    Expression<DateTime>? startedAt,
    Expression<String>? startedOn,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<String>? verdict,
    Expression<double>? adherence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (itemId != null) 'item_id': itemId,
      if (title != null) 'title': title,
      if (targets != null) 'targets': targets,
      if (plannedDays != null) 'planned_days': plannedDays,
      if (startedAt != null) 'started_at': startedAt,
      if (startedOn != null) 'started_on': startedOn,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (verdict != null) 'verdict': verdict,
      if (adherence != null) 'adherence': adherence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperimentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? itemId,
    Value<String>? title,
    Value<List<String>>? targets,
    Value<int>? plannedDays,
    Value<DateTime>? startedAt,
    Value<String>? startedOn,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<String?>? verdict,
    Value<double?>? adherence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ExperimentsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      targets: targets ?? this.targets,
      plannedDays: plannedDays ?? this.plannedDays,
      startedAt: startedAt ?? this.startedAt,
      startedOn: startedOn ?? this.startedOn,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      verdict: verdict ?? this.verdict,
      adherence: adherence ?? this.adherence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targets.present) {
      map['targets'] = Variable<String>(
        $ExperimentsTableTable.$convertertargets.toSql(targets.value),
      );
    }
    if (plannedDays.present) {
      map['planned_days'] = Variable<int>(plannedDays.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<String>(startedOn.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (adherence.present) {
      map['adherence'] = Variable<double>(adherence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('targets: $targets, ')
          ..write('plannedDays: $plannedDays, ')
          ..write('startedAt: $startedAt, ')
          ..write('startedOn: $startedOn, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('verdict: $verdict, ')
          ..write('adherence: $adherence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperimentScansTableTable extends ExperimentScansTable
    with TableInfo<$ExperimentScansTableTable, ExperimentScanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentScansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _experimentIdMeta = const VerificationMeta(
    'experimentId',
  );
  @override
  late final GeneratedColumn<String> experimentId = GeneratedColumn<String>(
    'experiment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<String> scanId = GeneratedColumn<String>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [experimentId, scanId, role, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiment_scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExperimentScanEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('experiment_id')) {
      context.handle(
        _experimentIdMeta,
        experimentId.isAcceptableOrUnknown(
          data['experiment_id']!,
          _experimentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_experimentIdMeta);
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {experimentId, scanId};
  @override
  ExperimentScanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExperimentScanEntry(
      experimentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experiment_id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ExperimentScansTableTable createAlias(String alias) {
    return $ExperimentScansTableTable(attachedDatabase, alias);
  }
}

class ExperimentScanEntry extends DataClass
    implements Insertable<ExperimentScanEntry> {
  /// Foreign key referencing experiments(id).
  final String experimentId;

  /// Foreign key referencing scans(id).
  final String scanId;

  /// Role in experiment: 'baseline' or 'followup'.
  final String role;

  /// Sync timestamp with remote.
  final DateTime? syncedAt;
  const ExperimentScanEntry({
    required this.experimentId,
    required this.scanId,
    required this.role,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['experiment_id'] = Variable<String>(experimentId);
    map['scan_id'] = Variable<String>(scanId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ExperimentScansTableCompanion toCompanion(bool nullToAbsent) {
    return ExperimentScansTableCompanion(
      experimentId: Value(experimentId),
      scanId: Value(scanId),
      role: Value(role),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ExperimentScanEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExperimentScanEntry(
      experimentId: serializer.fromJson<String>(json['experimentId']),
      scanId: serializer.fromJson<String>(json['scanId']),
      role: serializer.fromJson<String>(json['role']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'experimentId': serializer.toJson<String>(experimentId),
      'scanId': serializer.toJson<String>(scanId),
      'role': serializer.toJson<String>(role),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  ExperimentScanEntry copyWith({
    String? experimentId,
    String? scanId,
    String? role,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => ExperimentScanEntry(
    experimentId: experimentId ?? this.experimentId,
    scanId: scanId ?? this.scanId,
    role: role ?? this.role,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ExperimentScanEntry copyWithCompanion(ExperimentScansTableCompanion data) {
    return ExperimentScanEntry(
      experimentId: data.experimentId.present
          ? data.experimentId.value
          : this.experimentId,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      role: data.role.present ? data.role.value : this.role,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentScanEntry(')
          ..write('experimentId: $experimentId, ')
          ..write('scanId: $scanId, ')
          ..write('role: $role, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(experimentId, scanId, role, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExperimentScanEntry &&
          other.experimentId == this.experimentId &&
          other.scanId == this.scanId &&
          other.role == this.role &&
          other.syncedAt == this.syncedAt);
}

class ExperimentScansTableCompanion
    extends UpdateCompanion<ExperimentScanEntry> {
  final Value<String> experimentId;
  final Value<String> scanId;
  final Value<String> role;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ExperimentScansTableCompanion({
    this.experimentId = const Value.absent(),
    this.scanId = const Value.absent(),
    this.role = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperimentScansTableCompanion.insert({
    required String experimentId,
    required String scanId,
    required String role,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : experimentId = Value(experimentId),
       scanId = Value(scanId),
       role = Value(role);
  static Insertable<ExperimentScanEntry> custom({
    Expression<String>? experimentId,
    Expression<String>? scanId,
    Expression<String>? role,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (experimentId != null) 'experiment_id': experimentId,
      if (scanId != null) 'scan_id': scanId,
      if (role != null) 'role': role,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperimentScansTableCompanion copyWith({
    Value<String>? experimentId,
    Value<String>? scanId,
    Value<String>? role,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ExperimentScansTableCompanion(
      experimentId: experimentId ?? this.experimentId,
      scanId: scanId ?? this.scanId,
      role: role ?? this.role,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (experimentId.present) {
      map['experiment_id'] = Variable<String>(experimentId.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<String>(scanId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentScansTableCompanion(')
          ..write('experimentId: $experimentId, ')
          ..write('scanId: $scanId, ')
          ..write('role: $role, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMutationsTableTable extends SyncMutationsTable
    with TableInfo<$SyncMutationsTableTable, SyncMutationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMutationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('upsert'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
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
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptMeta = const VerificationMeta(
    'lastAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    recordId,
    action,
    payload,
    createdAt,
    attempts,
    lastAttempt,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMutationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
        _lastAttemptMeta,
        lastAttempt.isAcceptableOrUnknown(
          data['last_attempt']!,
          _lastAttemptMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMutationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMutationEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncMutationsTableTable createAlias(String alias) {
    return $SyncMutationsTableTable(attachedDatabase, alias);
  }
}

class SyncMutationEntry extends DataClass
    implements Insertable<SyncMutationEntry> {
  /// Unique mutation identifier (UUID).
  final String id;

  /// Target PostgreSQL table name (e.g. 'profiles', 'scans', 'routine_items').
  final String targetTable;

  /// Target record primary key ID.
  final String recordId;

  /// Mutation action: 'upsert' or 'delete'.
  final String action;

  /// JSON payload representing the record state at mutation time.
  final String payload;

  /// Local timestamp when mutation was enqueued.
  final DateTime createdAt;

  /// Number of sync delivery attempts.
  final int attempts;

  /// Timestamp of the last sync attempt.
  final DateTime? lastAttempt;

  /// Diagnostic error message if last attempt failed.
  final String? errorMessage;
  const SyncMutationEntry({
    required this.id,
    required this.targetTable,
    required this.recordId,
    required this.action,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastAttempt,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncMutationsTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMutationsTableCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncMutationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMutationEntry(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncMutationEntry copyWith({
    String? id,
    String? targetTable,
    String? recordId,
    String? action,
    String? payload,
    DateTime? createdAt,
    int? attempts,
    Value<DateTime?> lastAttempt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncMutationEntry(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncMutationEntry copyWithCompanion(SyncMutationsTableCompanion data) {
    return SyncMutationEntry(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttempt: data.lastAttempt.present
          ? data.lastAttempt.value
          : this.lastAttempt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMutationEntry(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    recordId,
    action,
    payload,
    createdAt,
    attempts,
    lastAttempt,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMutationEntry &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastAttempt == this.lastAttempt &&
          other.errorMessage == this.errorMessage);
}

class SyncMutationsTableCompanion extends UpdateCompanion<SyncMutationEntry> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<DateTime?> lastAttempt;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const SyncMutationsTableCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMutationsTableCompanion.insert({
    required String id,
    required String targetTable,
    required String recordId,
    this.action = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTable = Value(targetTable),
       recordId = Value(recordId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncMutationEntry> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<DateTime>? lastAttempt,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMutationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<DateTime?>? lastAttempt,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return SyncMutationsTableCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMutationsTableCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTableTable profilesTable = $ProfilesTableTable(this);
  late final $ScansTableTable scansTable = $ScansTableTable(this);
  late final $ScanConcernsTableTable scanConcernsTable =
      $ScanConcernsTableTable(this);
  late final $RoutineItemsTableTable routineItemsTable =
      $RoutineItemsTableTable(this);
  late final $RoutineLogsTableTable routineLogsTable = $RoutineLogsTableTable(
    this,
  );
  late final $ExperimentsTableTable experimentsTable = $ExperimentsTableTable(
    this,
  );
  late final $ExperimentScansTableTable experimentScansTable =
      $ExperimentScansTableTable(this);
  late final $SyncMutationsTableTable syncMutationsTable =
      $SyncMutationsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profilesTable,
    scansTable,
    scanConcernsTable,
    routineItemsTable,
    routineLogsTable,
    experimentsTable,
    experimentScansTable,
    syncMutationsTable,
  ];
}

typedef $$ProfilesTableTableCreateCompanionBuilder =
    ProfilesTableCompanion Function({
      required String id,
      Value<String?> displayName,
      Value<List<String>> goals,
      Value<String?> skinType,
      Value<List<String>> sensitivities,
      Value<int?> skinToneSelf,
      Value<String?> sunHabit,
      Value<List<String>> currentActives,
      Value<String?> activesStarted,
      Value<String> timezone,
      Value<String> locale,
      Value<int> scanWeekday,
      Value<String> scanTime,
      Value<bool> ageConfirmed,
      Value<bool> keepPhotos,
      Value<int> onboardingStep,
      Value<DateTime?> onboardingCompletedAt,
      Value<bool> isDemo,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableTableUpdateCompanionBuilder =
    ProfilesTableCompanion Function({
      Value<String> id,
      Value<String?> displayName,
      Value<List<String>> goals,
      Value<String?> skinType,
      Value<List<String>> sensitivities,
      Value<int?> skinToneSelf,
      Value<String?> sunHabit,
      Value<List<String>> currentActives,
      Value<String?> activesStarted,
      Value<String> timezone,
      Value<String> locale,
      Value<int> scanWeekday,
      Value<String> scanTime,
      Value<bool> ageConfirmed,
      Value<bool> keepPhotos,
      Value<int> onboardingStep,
      Value<DateTime?> onboardingCompletedAt,
      Value<bool> isDemo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get goals => $composableBuilder(
    column: $table.goals,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get skinType => $composableBuilder(
    column: $table.skinType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get sensitivities => $composableBuilder(
    column: $table.sensitivities,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get skinToneSelf => $composableBuilder(
    column: $table.skinToneSelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sunHabit => $composableBuilder(
    column: $table.sunHabit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get currentActives => $composableBuilder(
    column: $table.currentActives,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get activesStarted => $composableBuilder(
    column: $table.activesStarted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scanWeekday => $composableBuilder(
    column: $table.scanWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanTime => $composableBuilder(
    column: $table.scanTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ageConfirmed => $composableBuilder(
    column: $table.ageConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepPhotos => $composableBuilder(
    column: $table.keepPhotos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDemo => $composableBuilder(
    column: $table.isDemo,
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

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goals => $composableBuilder(
    column: $table.goals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skinType => $composableBuilder(
    column: $table.skinType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensitivities => $composableBuilder(
    column: $table.sensitivities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skinToneSelf => $composableBuilder(
    column: $table.skinToneSelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sunHabit => $composableBuilder(
    column: $table.sunHabit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentActives => $composableBuilder(
    column: $table.currentActives,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activesStarted => $composableBuilder(
    column: $table.activesStarted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scanWeekday => $composableBuilder(
    column: $table.scanWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanTime => $composableBuilder(
    column: $table.scanTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ageConfirmed => $composableBuilder(
    column: $table.ageConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepPhotos => $composableBuilder(
    column: $table.keepPhotos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDemo => $composableBuilder(
    column: $table.isDemo,
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

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get goals =>
      $composableBuilder(column: $table.goals, builder: (column) => column);

  GeneratedColumn<String> get skinType =>
      $composableBuilder(column: $table.skinType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get sensitivities =>
      $composableBuilder(
        column: $table.sensitivities,
        builder: (column) => column,
      );

  GeneratedColumn<int> get skinToneSelf => $composableBuilder(
    column: $table.skinToneSelf,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sunHabit =>
      $composableBuilder(column: $table.sunHabit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get currentActives =>
      $composableBuilder(
        column: $table.currentActives,
        builder: (column) => column,
      );

  GeneratedColumn<String> get activesStarted => $composableBuilder(
    column: $table.activesStarted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<int> get scanWeekday => $composableBuilder(
    column: $table.scanWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scanTime =>
      $composableBuilder(column: $table.scanTime, builder: (column) => column);

  GeneratedColumn<bool> get ageConfirmed => $composableBuilder(
    column: $table.ageConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepPhotos => $composableBuilder(
    column: $table.keepPhotos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get onboardingStep => $composableBuilder(
    column: $table.onboardingStep,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDemo =>
      $composableBuilder(column: $table.isDemo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTableTable,
          ProfileEntry,
          $$ProfilesTableTableFilterComposer,
          $$ProfilesTableTableOrderingComposer,
          $$ProfilesTableTableAnnotationComposer,
          $$ProfilesTableTableCreateCompanionBuilder,
          $$ProfilesTableTableUpdateCompanionBuilder,
          (
            ProfileEntry,
            BaseReferences<_$AppDatabase, $ProfilesTableTable, ProfileEntry>,
          ),
          ProfileEntry,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableTableManager(_$AppDatabase db, $ProfilesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<List<String>> goals = const Value.absent(),
                Value<String?> skinType = const Value.absent(),
                Value<List<String>> sensitivities = const Value.absent(),
                Value<int?> skinToneSelf = const Value.absent(),
                Value<String?> sunHabit = const Value.absent(),
                Value<List<String>> currentActives = const Value.absent(),
                Value<String?> activesStarted = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> scanWeekday = const Value.absent(),
                Value<String> scanTime = const Value.absent(),
                Value<bool> ageConfirmed = const Value.absent(),
                Value<bool> keepPhotos = const Value.absent(),
                Value<int> onboardingStep = const Value.absent(),
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<bool> isDemo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion(
                id: id,
                displayName: displayName,
                goals: goals,
                skinType: skinType,
                sensitivities: sensitivities,
                skinToneSelf: skinToneSelf,
                sunHabit: sunHabit,
                currentActives: currentActives,
                activesStarted: activesStarted,
                timezone: timezone,
                locale: locale,
                scanWeekday: scanWeekday,
                scanTime: scanTime,
                ageConfirmed: ageConfirmed,
                keepPhotos: keepPhotos,
                onboardingStep: onboardingStep,
                onboardingCompletedAt: onboardingCompletedAt,
                isDemo: isDemo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> displayName = const Value.absent(),
                Value<List<String>> goals = const Value.absent(),
                Value<String?> skinType = const Value.absent(),
                Value<List<String>> sensitivities = const Value.absent(),
                Value<int?> skinToneSelf = const Value.absent(),
                Value<String?> sunHabit = const Value.absent(),
                Value<List<String>> currentActives = const Value.absent(),
                Value<String?> activesStarted = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> scanWeekday = const Value.absent(),
                Value<String> scanTime = const Value.absent(),
                Value<bool> ageConfirmed = const Value.absent(),
                Value<bool> keepPhotos = const Value.absent(),
                Value<int> onboardingStep = const Value.absent(),
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<bool> isDemo = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion.insert(
                id: id,
                displayName: displayName,
                goals: goals,
                skinType: skinType,
                sensitivities: sensitivities,
                skinToneSelf: skinToneSelf,
                sunHabit: sunHabit,
                currentActives: currentActives,
                activesStarted: activesStarted,
                timezone: timezone,
                locale: locale,
                scanWeekday: scanWeekday,
                scanTime: scanTime,
                ageConfirmed: ageConfirmed,
                keepPhotos: keepPhotos,
                onboardingStep: onboardingStep,
                onboardingCompletedAt: onboardingCompletedAt,
                isDemo: isDemo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTableTable, ProfileEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProfilesTableTable,
                    ProfileEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTableTable,
      ProfileEntry,
      $$ProfilesTableTableFilterComposer,
      $$ProfilesTableTableOrderingComposer,
      $$ProfilesTableTableAnnotationComposer,
      $$ProfilesTableTableCreateCompanionBuilder,
      $$ProfilesTableTableUpdateCompanionBuilder,
      (
        ProfileEntry,
        BaseReferences<_$AppDatabase, $ProfilesTableTable, ProfileEntry>,
      ),
      ProfileEntry,
      PrefetchHooks Function()
    >;
typedef $$ScansTableTableCreateCompanionBuilder = ScansTableCompanion Function({
  required String id,
  required String userId,
  Value<String> status,
  Value<String> mode,
  Value<String?> apiFileId,
  Value<String?> apiTaskId,
  Value<String?> errorCode,
  Value<double?> overallScore,
  Value<int?> skinAge,
  Value<bool> qualityOk,
  Value<String> qualityFlags,
  Value<String?> photoPath,
  Value<String?> resultJson,
  Value<bool> isDemo,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$ScansTableTableUpdateCompanionBuilder = ScansTableCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> status,
  Value<String> mode,
  Value<String?> apiFileId,
  Value<String?> apiTaskId,
  Value<String?> errorCode,
  Value<double?> overallScore,
  Value<int?> skinAge,
  Value<bool> qualityOk,
  Value<String> qualityFlags,
  Value<String?> photoPath,
  Value<String?> resultJson,
  Value<bool> isDemo,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$ScansTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScansTableTable> {
  $$ScansTableTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiFileId => $composableBuilder(
    column: $table.apiFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiTaskId => $composableBuilder(
    column: $table.apiTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skinAge => $composableBuilder(
    column: $table.skinAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get qualityOk => $composableBuilder(
    column: $table.qualityOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityFlags => $composableBuilder(
    column: $table.qualityFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDemo => $composableBuilder(
    column: $table.isDemo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScansTableTable> {
  $$ScansTableTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiFileId => $composableBuilder(
    column: $table.apiFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiTaskId => $composableBuilder(
    column: $table.apiTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skinAge => $composableBuilder(
    column: $table.skinAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get qualityOk => $composableBuilder(
    column: $table.qualityOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityFlags => $composableBuilder(
    column: $table.qualityFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDemo => $composableBuilder(
    column: $table.isDemo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScansTableTable> {
  $$ScansTableTableAnnotationComposer({
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get apiFileId =>
      $composableBuilder(column: $table.apiFileId, builder: (column) => column);

  GeneratedColumn<String> get apiTaskId =>
      $composableBuilder(column: $table.apiTaskId, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skinAge =>
      $composableBuilder(column: $table.skinAge, builder: (column) => column);

  GeneratedColumn<bool> get qualityOk =>
      $composableBuilder(column: $table.qualityOk, builder: (column) => column);

  GeneratedColumn<String> get qualityFlags => $composableBuilder(
    column: $table.qualityFlags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDemo =>
      $composableBuilder(column: $table.isDemo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ScansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScansTableTable,
          ScanEntry,
          $$ScansTableTableFilterComposer,
          $$ScansTableTableOrderingComposer,
          $$ScansTableTableAnnotationComposer,
          $$ScansTableTableCreateCompanionBuilder,
          $$ScansTableTableUpdateCompanionBuilder,
          (
            ScanEntry,
            BaseReferences<_$AppDatabase, $ScansTableTable, ScanEntry>,
          ),
          ScanEntry,
          PrefetchHooks Function()
        > {
  $$ScansTableTableTableManager(_$AppDatabase db, $ScansTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScansTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScansTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> apiFileId = const Value.absent(),
                Value<String?> apiTaskId = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<int?> skinAge = const Value.absent(),
                Value<bool> qualityOk = const Value.absent(),
                Value<String> qualityFlags = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<bool> isDemo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScansTableCompanion(
                id: id,
                userId: userId,
                status: status,
                mode: mode,
                apiFileId: apiFileId,
                apiTaskId: apiTaskId,
                errorCode: errorCode,
                overallScore: overallScore,
                skinAge: skinAge,
                qualityOk: qualityOk,
                qualityFlags: qualityFlags,
                photoPath: photoPath,
                resultJson: resultJson,
                isDemo: isDemo,
                createdAt: createdAt,
                completedAt: completedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> status = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> apiFileId = const Value.absent(),
                Value<String?> apiTaskId = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<int?> skinAge = const Value.absent(),
                Value<bool> qualityOk = const Value.absent(),
                Value<String> qualityFlags = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<bool> isDemo = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScansTableCompanion.insert(
                id: id,
                userId: userId,
                status: status,
                mode: mode,
                apiFileId: apiFileId,
                apiTaskId: apiTaskId,
                errorCode: errorCode,
                overallScore: overallScore,
                skinAge: skinAge,
                qualityOk: qualityOk,
                qualityFlags: qualityFlags,
                photoPath: photoPath,
                resultJson: resultJson,
                isDemo: isDemo,
                createdAt: createdAt,
                completedAt: completedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScansTableTable, ScanEntry>(table),
                  BaseReferences<_$AppDatabase, $ScansTableTable, ScanEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScansTableTable,
      ScanEntry,
      $$ScansTableTableFilterComposer,
      $$ScansTableTableOrderingComposer,
      $$ScansTableTableAnnotationComposer,
      $$ScansTableTableCreateCompanionBuilder,
      $$ScansTableTableUpdateCompanionBuilder,
      (ScanEntry, BaseReferences<_$AppDatabase, $ScansTableTable, ScanEntry>),
      ScanEntry,
      PrefetchHooks Function()
    >;
typedef $$ScanConcernsTableTableCreateCompanionBuilder =
    ScanConcernsTableCompanion Function({
      required String id,
      required String scanId,
      required String userId,
      required String concern,
      Value<String?> zone,
      required double rawScore,
      Value<double?> uiScore,
      Value<String?> maskPath,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ScanConcernsTableTableUpdateCompanionBuilder =
    ScanConcernsTableCompanion Function({
      Value<String> id,
      Value<String> scanId,
      Value<String> userId,
      Value<String> concern,
      Value<String?> zone,
      Value<double> rawScore,
      Value<double?> uiScore,
      Value<String?> maskPath,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ScanConcernsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScanConcernsTableTable> {
  $$ScanConcernsTableTableFilterComposer({
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

  ColumnFilters<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concern => $composableBuilder(
    column: $table.concern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rawScore => $composableBuilder(
    column: $table.rawScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get uiScore => $composableBuilder(
    column: $table.uiScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maskPath => $composableBuilder(
    column: $table.maskPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanConcernsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanConcernsTableTable> {
  $$ScanConcernsTableTableOrderingComposer({
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

  ColumnOrderings<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concern => $composableBuilder(
    column: $table.concern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rawScore => $composableBuilder(
    column: $table.rawScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get uiScore => $composableBuilder(
    column: $table.uiScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maskPath => $composableBuilder(
    column: $table.maskPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanConcernsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanConcernsTableTable> {
  $$ScanConcernsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scanId =>
      $composableBuilder(column: $table.scanId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get concern =>
      $composableBuilder(column: $table.concern, builder: (column) => column);

  GeneratedColumn<String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<double> get rawScore =>
      $composableBuilder(column: $table.rawScore, builder: (column) => column);

  GeneratedColumn<double> get uiScore =>
      $composableBuilder(column: $table.uiScore, builder: (column) => column);

  GeneratedColumn<String> get maskPath =>
      $composableBuilder(column: $table.maskPath, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ScanConcernsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanConcernsTableTable,
          ScanConcernEntry,
          $$ScanConcernsTableTableFilterComposer,
          $$ScanConcernsTableTableOrderingComposer,
          $$ScanConcernsTableTableAnnotationComposer,
          $$ScanConcernsTableTableCreateCompanionBuilder,
          $$ScanConcernsTableTableUpdateCompanionBuilder,
          (
            ScanConcernEntry,
            BaseReferences<
              _$AppDatabase,
              $ScanConcernsTableTable,
              ScanConcernEntry
            >,
          ),
          ScanConcernEntry,
          PrefetchHooks Function()
        > {
  $$ScanConcernsTableTableTableManager(
    _$AppDatabase db,
    $ScanConcernsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanConcernsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanConcernsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanConcernsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scanId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> concern = const Value.absent(),
                Value<String?> zone = const Value.absent(),
                Value<double> rawScore = const Value.absent(),
                Value<double?> uiScore = const Value.absent(),
                Value<String?> maskPath = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanConcernsTableCompanion(
                id: id,
                scanId: scanId,
                userId: userId,
                concern: concern,
                zone: zone,
                rawScore: rawScore,
                uiScore: uiScore,
                maskPath: maskPath,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scanId,
                required String userId,
                required String concern,
                Value<String?> zone = const Value.absent(),
                required double rawScore,
                Value<double?> uiScore = const Value.absent(),
                Value<String?> maskPath = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanConcernsTableCompanion.insert(
                id: id,
                scanId: scanId,
                userId: userId,
                concern: concern,
                zone: zone,
                rawScore: rawScore,
                uiScore: uiScore,
                maskPath: maskPath,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanConcernsTableTable, ScanConcernEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScanConcernsTableTable,
                    ScanConcernEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanConcernsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanConcernsTableTable,
      ScanConcernEntry,
      $$ScanConcernsTableTableFilterComposer,
      $$ScanConcernsTableTableOrderingComposer,
      $$ScanConcernsTableTableAnnotationComposer,
      $$ScanConcernsTableTableCreateCompanionBuilder,
      $$ScanConcernsTableTableUpdateCompanionBuilder,
      (
        ScanConcernEntry,
        BaseReferences<
          _$AppDatabase,
          $ScanConcernsTableTable,
          ScanConcernEntry
        >,
      ),
      ScanConcernEntry,
      PrefetchHooks Function()
    >;
typedef $$RoutineItemsTableTableCreateCompanionBuilder =
    RoutineItemsTableCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> brand,
      Value<String> stepType,
      Value<List<String>> actives,
      Value<String> period,
      Value<List<int>?> days,
      Value<DateTime?> startedOn,
      Value<bool> active,
      Value<int> sortOrder,
      Value<String?> catalogProductId,
      Value<String?> ingredientsRaw,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$RoutineItemsTableTableUpdateCompanionBuilder =
    RoutineItemsTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> brand,
      Value<String> stepType,
      Value<List<String>> actives,
      Value<String> period,
      Value<List<int>?> days,
      Value<DateTime?> startedOn,
      Value<bool> active,
      Value<int> sortOrder,
      Value<String?> catalogProductId,
      Value<String?> ingredientsRaw,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$RoutineItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineItemsTableTable> {
  $$RoutineItemsTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get actives => $composableBuilder(
    column: $table.actives,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>?, List<int>, String> get days =>
      $composableBuilder(
        column: $table.days,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogProductId => $composableBuilder(
    column: $table.catalogProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientsRaw => $composableBuilder(
    column: $table.ingredientsRaw,
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

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineItemsTableTable> {
  $$RoutineItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actives => $composableBuilder(
    column: $table.actives,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogProductId => $composableBuilder(
    column: $table.catalogProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientsRaw => $composableBuilder(
    column: $table.ingredientsRaw,
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

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineItemsTableTable> {
  $$RoutineItemsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get stepType =>
      $composableBuilder(column: $table.stepType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get actives =>
      $composableBuilder(column: $table.actives, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>?, String> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<DateTime> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get catalogProductId => $composableBuilder(
    column: $table.catalogProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientsRaw => $composableBuilder(
    column: $table.ingredientsRaw,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$RoutineItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineItemsTableTable,
          RoutineItemEntry,
          $$RoutineItemsTableTableFilterComposer,
          $$RoutineItemsTableTableOrderingComposer,
          $$RoutineItemsTableTableAnnotationComposer,
          $$RoutineItemsTableTableCreateCompanionBuilder,
          $$RoutineItemsTableTableUpdateCompanionBuilder,
          (
            RoutineItemEntry,
            BaseReferences<
              _$AppDatabase,
              $RoutineItemsTableTable,
              RoutineItemEntry
            >,
          ),
          RoutineItemEntry,
          PrefetchHooks Function()
        > {
  $$RoutineItemsTableTableTableManager(
    _$AppDatabase db,
    $RoutineItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String> stepType = const Value.absent(),
                Value<List<String>> actives = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<List<int>?> days = const Value.absent(),
                Value<DateTime?> startedOn = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> catalogProductId = const Value.absent(),
                Value<String?> ingredientsRaw = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsTableCompanion(
                id: id,
                userId: userId,
                name: name,
                brand: brand,
                stepType: stepType,
                actives: actives,
                period: period,
                days: days,
                startedOn: startedOn,
                active: active,
                sortOrder: sortOrder,
                catalogProductId: catalogProductId,
                ingredientsRaw: ingredientsRaw,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String> stepType = const Value.absent(),
                Value<List<String>> actives = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<List<int>?> days = const Value.absent(),
                Value<DateTime?> startedOn = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> catalogProductId = const Value.absent(),
                Value<String?> ingredientsRaw = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsTableCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                brand: brand,
                stepType: stepType,
                actives: actives,
                period: period,
                days: days,
                startedOn: startedOn,
                active: active,
                sortOrder: sortOrder,
                catalogProductId: catalogProductId,
                ingredientsRaw: ingredientsRaw,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineItemsTableTable, RoutineItemEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RoutineItemsTableTable,
                    RoutineItemEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineItemsTableTable,
      RoutineItemEntry,
      $$RoutineItemsTableTableFilterComposer,
      $$RoutineItemsTableTableOrderingComposer,
      $$RoutineItemsTableTableAnnotationComposer,
      $$RoutineItemsTableTableCreateCompanionBuilder,
      $$RoutineItemsTableTableUpdateCompanionBuilder,
      (
        RoutineItemEntry,
        BaseReferences<
          _$AppDatabase,
          $RoutineItemsTableTable,
          RoutineItemEntry
        >,
      ),
      RoutineItemEntry,
      PrefetchHooks Function()
    >;
typedef $$RoutineLogsTableTableCreateCompanionBuilder =
    RoutineLogsTableCompanion Function({
      required String id,
      required String userId,
      required String itemId,
      required String logDate,
      Value<String> period,
      Value<bool> done,
      required DateTime createdAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$RoutineLogsTableTableUpdateCompanionBuilder =
    RoutineLogsTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> itemId,
      Value<String> logDate,
      Value<String> period,
      Value<bool> done,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$RoutineLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineLogsTableTable> {
  $$RoutineLogsTableTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineLogsTableTable> {
  $$RoutineLogsTableTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineLogsTableTable> {
  $$RoutineLogsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$RoutineLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineLogsTableTable,
          RoutineLogEntry,
          $$RoutineLogsTableTableFilterComposer,
          $$RoutineLogsTableTableOrderingComposer,
          $$RoutineLogsTableTableAnnotationComposer,
          $$RoutineLogsTableTableCreateCompanionBuilder,
          $$RoutineLogsTableTableUpdateCompanionBuilder,
          (
            RoutineLogEntry,
            BaseReferences<
              _$AppDatabase,
              $RoutineLogsTableTable,
              RoutineLogEntry
            >,
          ),
          RoutineLogEntry,
          PrefetchHooks Function()
        > {
  $$RoutineLogsTableTableTableManager(
    _$AppDatabase db,
    $RoutineLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> logDate = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineLogsTableCompanion(
                id: id,
                userId: userId,
                itemId: itemId,
                logDate: logDate,
                period: period,
                done: done,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String itemId,
                required String logDate,
                Value<String> period = const Value.absent(),
                Value<bool> done = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineLogsTableCompanion.insert(
                id: id,
                userId: userId,
                itemId: itemId,
                logDate: logDate,
                period: period,
                done: done,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineLogsTableTable, RoutineLogEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RoutineLogsTableTable,
                    RoutineLogEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineLogsTableTable,
      RoutineLogEntry,
      $$RoutineLogsTableTableFilterComposer,
      $$RoutineLogsTableTableOrderingComposer,
      $$RoutineLogsTableTableAnnotationComposer,
      $$RoutineLogsTableTableCreateCompanionBuilder,
      $$RoutineLogsTableTableUpdateCompanionBuilder,
      (
        RoutineLogEntry,
        BaseReferences<_$AppDatabase, $RoutineLogsTableTable, RoutineLogEntry>,
      ),
      RoutineLogEntry,
      PrefetchHooks Function()
    >;
typedef $$ExperimentsTableTableCreateCompanionBuilder =
    ExperimentsTableCompanion Function({
      required String id,
      required String userId,
      Value<String?> itemId,
      required String title,
      Value<List<String>> targets,
      Value<int> plannedDays,
      required DateTime startedAt,
      required String startedOn,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String?> verdict,
      Value<double?> adherence,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ExperimentsTableTableUpdateCompanionBuilder =
    ExperimentsTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> itemId,
      Value<String> title,
      Value<List<String>> targets,
      Value<int> plannedDays,
      Value<DateTime> startedAt,
      Value<String> startedOn,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String?> verdict,
      Value<double?> adherence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ExperimentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExperimentsTableTable> {
  $$ExperimentsTableTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get targets => $composableBuilder(
    column: $table.targets,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get plannedDays => $composableBuilder(
    column: $table.plannedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get adherence => $composableBuilder(
    column: $table.adherence,
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

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExperimentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperimentsTableTable> {
  $$ExperimentsTableTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targets => $composableBuilder(
    column: $table.targets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDays => $composableBuilder(
    column: $table.plannedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get adherence => $composableBuilder(
    column: $table.adherence,
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

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExperimentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperimentsTableTable> {
  $$ExperimentsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get targets =>
      $composableBuilder(column: $table.targets, builder: (column) => column);

  GeneratedColumn<int> get plannedDays => $composableBuilder(
    column: $table.plannedDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<double> get adherence =>
      $composableBuilder(column: $table.adherence, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ExperimentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExperimentsTableTable,
          ExperimentEntry,
          $$ExperimentsTableTableFilterComposer,
          $$ExperimentsTableTableOrderingComposer,
          $$ExperimentsTableTableAnnotationComposer,
          $$ExperimentsTableTableCreateCompanionBuilder,
          $$ExperimentsTableTableUpdateCompanionBuilder,
          (
            ExperimentEntry,
            BaseReferences<
              _$AppDatabase,
              $ExperimentsTableTable,
              ExperimentEntry
            >,
          ),
          ExperimentEntry,
          PrefetchHooks Function()
        > {
  $$ExperimentsTableTableTableManager(
    _$AppDatabase db,
    $ExperimentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperimentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<List<String>> targets = const Value.absent(),
                Value<int> plannedDays = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> startedOn = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> verdict = const Value.absent(),
                Value<double?> adherence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentsTableCompanion(
                id: id,
                userId: userId,
                itemId: itemId,
                title: title,
                targets: targets,
                plannedDays: plannedDays,
                startedAt: startedAt,
                startedOn: startedOn,
                endedAt: endedAt,
                status: status,
                verdict: verdict,
                adherence: adherence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> itemId = const Value.absent(),
                required String title,
                Value<List<String>> targets = const Value.absent(),
                Value<int> plannedDays = const Value.absent(),
                required DateTime startedAt,
                required String startedOn,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> verdict = const Value.absent(),
                Value<double?> adherence = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentsTableCompanion.insert(
                id: id,
                userId: userId,
                itemId: itemId,
                title: title,
                targets: targets,
                plannedDays: plannedDays,
                startedAt: startedAt,
                startedOn: startedOn,
                endedAt: endedAt,
                status: status,
                verdict: verdict,
                adherence: adherence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExperimentsTableTable, ExperimentEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ExperimentsTableTable,
                    ExperimentEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExperimentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExperimentsTableTable,
      ExperimentEntry,
      $$ExperimentsTableTableFilterComposer,
      $$ExperimentsTableTableOrderingComposer,
      $$ExperimentsTableTableAnnotationComposer,
      $$ExperimentsTableTableCreateCompanionBuilder,
      $$ExperimentsTableTableUpdateCompanionBuilder,
      (
        ExperimentEntry,
        BaseReferences<_$AppDatabase, $ExperimentsTableTable, ExperimentEntry>,
      ),
      ExperimentEntry,
      PrefetchHooks Function()
    >;
typedef $$ExperimentScansTableTableCreateCompanionBuilder =
    ExperimentScansTableCompanion Function({
      required String experimentId,
      required String scanId,
      required String role,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ExperimentScansTableTableUpdateCompanionBuilder =
    ExperimentScansTableCompanion Function({
      Value<String> experimentId,
      Value<String> scanId,
      Value<String> role,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ExperimentScansTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExperimentScansTableTable> {
  $$ExperimentScansTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get experimentId => $composableBuilder(
    column: $table.experimentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExperimentScansTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperimentScansTableTable> {
  $$ExperimentScansTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get experimentId => $composableBuilder(
    column: $table.experimentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanId => $composableBuilder(
    column: $table.scanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExperimentScansTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperimentScansTableTable> {
  $$ExperimentScansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get experimentId => $composableBuilder(
    column: $table.experimentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scanId =>
      $composableBuilder(column: $table.scanId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ExperimentScansTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExperimentScansTableTable,
          ExperimentScanEntry,
          $$ExperimentScansTableTableFilterComposer,
          $$ExperimentScansTableTableOrderingComposer,
          $$ExperimentScansTableTableAnnotationComposer,
          $$ExperimentScansTableTableCreateCompanionBuilder,
          $$ExperimentScansTableTableUpdateCompanionBuilder,
          (
            ExperimentScanEntry,
            BaseReferences<
              _$AppDatabase,
              $ExperimentScansTableTable,
              ExperimentScanEntry
            >,
          ),
          ExperimentScanEntry,
          PrefetchHooks Function()
        > {
  $$ExperimentScansTableTableTableManager(
    _$AppDatabase db,
    $ExperimentScansTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentScansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentScansTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExperimentScansTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> experimentId = const Value.absent(),
                Value<String> scanId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentScansTableCompanion(
                experimentId: experimentId,
                scanId: scanId,
                role: role,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String experimentId,
                required String scanId,
                required String role,
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentScansTableCompanion.insert(
                experimentId: experimentId,
                scanId: scanId,
                role: role,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExperimentScansTableTable, ExperimentScanEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ExperimentScansTableTable,
                    ExperimentScanEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExperimentScansTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExperimentScansTableTable,
      ExperimentScanEntry,
      $$ExperimentScansTableTableFilterComposer,
      $$ExperimentScansTableTableOrderingComposer,
      $$ExperimentScansTableTableAnnotationComposer,
      $$ExperimentScansTableTableCreateCompanionBuilder,
      $$ExperimentScansTableTableUpdateCompanionBuilder,
      (
        ExperimentScanEntry,
        BaseReferences<
          _$AppDatabase,
          $ExperimentScansTableTable,
          ExperimentScanEntry
        >,
      ),
      ExperimentScanEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncMutationsTableTableCreateCompanionBuilder =
    SyncMutationsTableCompanion Function({
      required String id,
      required String targetTable,
      required String recordId,
      Value<String> action,
      required String payload,
      required DateTime createdAt,
      Value<int> attempts,
      Value<DateTime?> lastAttempt,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$SyncMutationsTableTableUpdateCompanionBuilder =
    SyncMutationsTableCompanion Function({
      Value<String> id,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<DateTime?> lastAttempt,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$SyncMutationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMutationsTableTable> {
  $$SyncMutationsTableTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMutationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMutationsTableTable> {
  $$SyncMutationsTableTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMutationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMutationsTableTable> {
  $$SyncMutationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncMutationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMutationsTableTable,
          SyncMutationEntry,
          $$SyncMutationsTableTableFilterComposer,
          $$SyncMutationsTableTableOrderingComposer,
          $$SyncMutationsTableTableAnnotationComposer,
          $$SyncMutationsTableTableCreateCompanionBuilder,
          $$SyncMutationsTableTableUpdateCompanionBuilder,
          (
            SyncMutationEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncMutationsTableTable,
              SyncMutationEntry
            >,
          ),
          SyncMutationEntry,
          PrefetchHooks Function()
        > {
  $$SyncMutationsTableTableTableManager(
    _$AppDatabase db,
    $SyncMutationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMutationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMutationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMutationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMutationsTableCompanion(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastAttempt: lastAttempt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTable,
                required String recordId,
                Value<String> action = const Value.absent(),
                required String payload,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMutationsTableCompanion.insert(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastAttempt: lastAttempt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMutationsTableTable, SyncMutationEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncMutationsTableTable,
                    SyncMutationEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMutationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMutationsTableTable,
      SyncMutationEntry,
      $$SyncMutationsTableTableFilterComposer,
      $$SyncMutationsTableTableOrderingComposer,
      $$SyncMutationsTableTableAnnotationComposer,
      $$SyncMutationsTableTableCreateCompanionBuilder,
      $$SyncMutationsTableTableUpdateCompanionBuilder,
      (
        SyncMutationEntry,
        BaseReferences<
          _$AppDatabase,
          $SyncMutationsTableTable,
          SyncMutationEntry
        >,
      ),
      SyncMutationEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableTableManager get profilesTable =>
      $$ProfilesTableTableTableManager(_db, _db.profilesTable);
  $$ScansTableTableTableManager get scansTable =>
      $$ScansTableTableTableManager(_db, _db.scansTable);
  $$ScanConcernsTableTableTableManager get scanConcernsTable =>
      $$ScanConcernsTableTableTableManager(_db, _db.scanConcernsTable);
  $$RoutineItemsTableTableTableManager get routineItemsTable =>
      $$RoutineItemsTableTableTableManager(_db, _db.routineItemsTable);
  $$RoutineLogsTableTableTableManager get routineLogsTable =>
      $$RoutineLogsTableTableTableManager(_db, _db.routineLogsTable);
  $$ExperimentsTableTableTableManager get experimentsTable =>
      $$ExperimentsTableTableTableManager(_db, _db.experimentsTable);
  $$ExperimentScansTableTableTableManager get experimentScansTable =>
      $$ExperimentScansTableTableTableManager(_db, _db.experimentScansTable);
  $$SyncMutationsTableTableTableManager get syncMutationsTable =>
      $$SyncMutationsTableTableTableManager(_db, _db.syncMutationsTable);
}
