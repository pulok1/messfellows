// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessesTable extends Messes with TableInfo<$MessesTable, MessRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BDT'),
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('৳'),
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
    name,
    currencyCode,
    currencySymbol,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessRow> instance, {
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
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
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
  $MessesTable createAlias(String alias) {
    return $MessesTable(attachedDatabase, alias);
  }
}

class MessRow extends DataClass implements Insertable<MessRow> {
  final String id;
  final String name;
  final String currencyCode;
  final String currencySymbol;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MessRow({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.currencySymbol,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessesCompanion toCompanion(bool nullToAbsent) {
    return MessesCompanion(
      id: Value(id),
      name: Value(name),
      currencyCode: Value(currencyCode),
      currencySymbol: Value(currencySymbol),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MessRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MessRow copyWith({
    String? id,
    String? name,
    String? currencyCode,
    String? currencySymbol,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MessRow(
    id: id ?? this.id,
    name: name ?? this.name,
    currencyCode: currencyCode ?? this.currencyCode,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MessRow copyWithCompanion(MessesCompanion data) {
    return MessRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, currencyCode, currencySymbol, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.currencyCode == this.currencyCode &&
          other.currencySymbol == this.currencySymbol &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessesCompanion extends UpdateCompanion<MessRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> currencyCode;
  final Value<String> currencySymbol;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MessesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessesCompanion.insert({
    required String id,
    required String name,
    this.currencyCode = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MessRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? currencyCode,
    Expression<String>? currencySymbol,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? currencyCode,
    Value<String>? currencySymbol,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MessesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
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
    return (StringBuffer('MessesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messIdMeta = const VerificationMeta('messId');
  @override
  late final GeneratedColumn<String> messId = GeneratedColumn<String>(
    'mess_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messes (id)',
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leftAtMeta = const VerificationMeta('leftAt');
  @override
  late final GeneratedColumn<DateTime> leftAt = GeneratedColumn<DateTime>(
    'left_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
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
    messId,
    name,
    phone,
    joinedAt,
    leftAt,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mess_id')) {
      context.handle(
        _messIdMeta,
        messId.isAcceptableOrUnknown(data['mess_id']!, _messIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    if (data.containsKey('left_at')) {
      context.handle(
        _leftAtMeta,
        leftAt.isAcceptableOrUnknown(data['left_at']!, _leftAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mess_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
      leftAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}left_at'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
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
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String messId;
  final String name;
  final String? phone;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemberRow({
    required this.id,
    required this.messId,
    required this.name,
    this.phone,
    required this.joinedAt,
    this.leftAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mess_id'] = Variable<String>(messId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['joined_at'] = Variable<DateTime>(joinedAt);
    if (!nullToAbsent || leftAt != null) {
      map['left_at'] = Variable<DateTime>(leftAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      messId: Value(messId),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      joinedAt: Value(joinedAt),
      leftAt: leftAt == null && nullToAbsent
          ? const Value.absent()
          : Value(leftAt),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      messId: serializer.fromJson<String>(json['messId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      leftAt: serializer.fromJson<DateTime?>(json['leftAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messId': serializer.toJson<String>(messId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'leftAt': serializer.toJson<DateTime?>(leftAt),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemberRow copyWith({
    String? id,
    String? messId,
    String? name,
    Value<String?> phone = const Value.absent(),
    DateTime? joinedAt,
    Value<DateTime?> leftAt = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MemberRow(
    id: id ?? this.id,
    messId: messId ?? this.messId,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    joinedAt: joinedAt ?? this.joinedAt,
    leftAt: leftAt.present ? leftAt.value : this.leftAt,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MemberRow copyWithCompanion(MembersCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      messId: data.messId.present ? data.messId.value : this.messId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      leftAt: data.leftAt.present ? data.leftAt.value : this.leftAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('leftAt: $leftAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messId,
    name,
    phone,
    joinedAt,
    leftAt,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.messId == this.messId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.joinedAt == this.joinedAt &&
          other.leftAt == this.leftAt &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> messId;
  final Value<String> name;
  final Value<String?> phone;
  final Value<DateTime> joinedAt;
  final Value<DateTime?> leftAt;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.messId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.leftAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String messId,
    required String name,
    this.phone = const Value.absent(),
    required DateTime joinedAt,
    this.leftAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messId = Value(messId),
       name = Value(name),
       joinedAt = Value(joinedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? messId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? leftAt,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messId != null) 'mess_id': messId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (leftAt != null) 'left_at': leftAt,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? messId,
    Value<String>? name,
    Value<String?>? phone,
    Value<DateTime>? joinedAt,
    Value<DateTime?>? leftAt,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      isActive: isActive ?? this.isActive,
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
    if (messId.present) {
      map['mess_id'] = Variable<String>(messId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (leftAt.present) {
      map['left_at'] = Variable<DateTime>(leftAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('leftAt: $leftAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealEntriesTable extends MealEntries
    with TableInfo<$MealEntriesTable, MealEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messIdMeta = const VerificationMeta('messId');
  @override
  late final GeneratedColumn<String> messId = GeneratedColumn<String>(
    'mess_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messes (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
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
  static const VerificationMeta _breakfastMeta = const VerificationMeta(
    'breakfast',
  );
  @override
  late final GeneratedColumn<bool> breakfast = GeneratedColumn<bool>(
    'breakfast',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("breakfast" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lunchMeta = const VerificationMeta('lunch');
  @override
  late final GeneratedColumn<bool> lunch = GeneratedColumn<bool>(
    'lunch',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lunch" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dinnerMeta = const VerificationMeta('dinner');
  @override
  late final GeneratedColumn<bool> dinner = GeneratedColumn<bool>(
    'dinner',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dinner" IN (0, 1))',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messId,
    memberId,
    date,
    breakfast,
    lunch,
    dinner,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mess_id')) {
      context.handle(
        _messIdMeta,
        messId.isAcceptableOrUnknown(data['mess_id']!, _messIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('breakfast')) {
      context.handle(
        _breakfastMeta,
        breakfast.isAcceptableOrUnknown(data['breakfast']!, _breakfastMeta),
      );
    }
    if (data.containsKey('lunch')) {
      context.handle(
        _lunchMeta,
        lunch.isAcceptableOrUnknown(data['lunch']!, _lunchMeta),
      );
    }
    if (data.containsKey('dinner')) {
      context.handle(
        _dinnerMeta,
        dinner.isAcceptableOrUnknown(data['dinner']!, _dinnerMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messId, memberId, date},
  ];
  @override
  MealEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mess_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      breakfast: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}breakfast'],
      )!,
      lunch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lunch'],
      )!,
      dinner: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dinner'],
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
  $MealEntriesTable createAlias(String alias) {
    return $MealEntriesTable(attachedDatabase, alias);
  }
}

class MealEntryRow extends DataClass implements Insertable<MealEntryRow> {
  final String id;
  final String messId;
  final String memberId;
  final DateTime date;
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MealEntryRow({
    required this.id,
    required this.messId,
    required this.memberId,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mess_id'] = Variable<String>(messId);
    map['member_id'] = Variable<String>(memberId);
    map['date'] = Variable<DateTime>(date);
    map['breakfast'] = Variable<bool>(breakfast);
    map['lunch'] = Variable<bool>(lunch);
    map['dinner'] = Variable<bool>(dinner);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MealEntriesCompanion toCompanion(bool nullToAbsent) {
    return MealEntriesCompanion(
      id: Value(id),
      messId: Value(messId),
      memberId: Value(memberId),
      date: Value(date),
      breakfast: Value(breakfast),
      lunch: Value(lunch),
      dinner: Value(dinner),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MealEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEntryRow(
      id: serializer.fromJson<String>(json['id']),
      messId: serializer.fromJson<String>(json['messId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      date: serializer.fromJson<DateTime>(json['date']),
      breakfast: serializer.fromJson<bool>(json['breakfast']),
      lunch: serializer.fromJson<bool>(json['lunch']),
      dinner: serializer.fromJson<bool>(json['dinner']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messId': serializer.toJson<String>(messId),
      'memberId': serializer.toJson<String>(memberId),
      'date': serializer.toJson<DateTime>(date),
      'breakfast': serializer.toJson<bool>(breakfast),
      'lunch': serializer.toJson<bool>(lunch),
      'dinner': serializer.toJson<bool>(dinner),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MealEntryRow copyWith({
    String? id,
    String? messId,
    String? memberId,
    DateTime? date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MealEntryRow(
    id: id ?? this.id,
    messId: messId ?? this.messId,
    memberId: memberId ?? this.memberId,
    date: date ?? this.date,
    breakfast: breakfast ?? this.breakfast,
    lunch: lunch ?? this.lunch,
    dinner: dinner ?? this.dinner,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MealEntryRow copyWithCompanion(MealEntriesCompanion data) {
    return MealEntryRow(
      id: data.id.present ? data.id.value : this.id,
      messId: data.messId.present ? data.messId.value : this.messId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      date: data.date.present ? data.date.value : this.date,
      breakfast: data.breakfast.present ? data.breakfast.value : this.breakfast,
      lunch: data.lunch.present ? data.lunch.value : this.lunch,
      dinner: data.dinner.present ? data.dinner.value : this.dinner,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealEntryRow(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('memberId: $memberId, ')
          ..write('date: $date, ')
          ..write('breakfast: $breakfast, ')
          ..write('lunch: $lunch, ')
          ..write('dinner: $dinner, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messId,
    memberId,
    date,
    breakfast,
    lunch,
    dinner,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEntryRow &&
          other.id == this.id &&
          other.messId == this.messId &&
          other.memberId == this.memberId &&
          other.date == this.date &&
          other.breakfast == this.breakfast &&
          other.lunch == this.lunch &&
          other.dinner == this.dinner &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MealEntriesCompanion extends UpdateCompanion<MealEntryRow> {
  final Value<String> id;
  final Value<String> messId;
  final Value<String> memberId;
  final Value<DateTime> date;
  final Value<bool> breakfast;
  final Value<bool> lunch;
  final Value<bool> dinner;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MealEntriesCompanion({
    this.id = const Value.absent(),
    this.messId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.date = const Value.absent(),
    this.breakfast = const Value.absent(),
    this.lunch = const Value.absent(),
    this.dinner = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealEntriesCompanion.insert({
    required String id,
    required String messId,
    required String memberId,
    required DateTime date,
    this.breakfast = const Value.absent(),
    this.lunch = const Value.absent(),
    this.dinner = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messId = Value(messId),
       memberId = Value(memberId),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MealEntryRow> custom({
    Expression<String>? id,
    Expression<String>? messId,
    Expression<String>? memberId,
    Expression<DateTime>? date,
    Expression<bool>? breakfast,
    Expression<bool>? lunch,
    Expression<bool>? dinner,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messId != null) 'mess_id': messId,
      if (memberId != null) 'member_id': memberId,
      if (date != null) 'date': date,
      if (breakfast != null) 'breakfast': breakfast,
      if (lunch != null) 'lunch': lunch,
      if (dinner != null) 'dinner': dinner,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? messId,
    Value<String>? memberId,
    Value<DateTime>? date,
    Value<bool>? breakfast,
    Value<bool>? lunch,
    Value<bool>? dinner,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MealEntriesCompanion(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
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
    if (messId.present) {
      map['mess_id'] = Variable<String>(messId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (breakfast.present) {
      map['breakfast'] = Variable<bool>(breakfast.value);
    }
    if (lunch.present) {
      map['lunch'] = Variable<bool>(lunch.value);
    }
    if (dinner.present) {
      map['dinner'] = Variable<bool>(dinner.value);
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
    return (StringBuffer('MealEntriesCompanion(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('memberId: $memberId, ')
          ..write('date: $date, ')
          ..write('breakfast: $breakfast, ')
          ..write('lunch: $lunch, ')
          ..write('dinner: $dinner, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messIdMeta = const VerificationMeta('messId');
  @override
  late final GeneratedColumn<String> messId = GeneratedColumn<String>(
    'mess_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messes (id)',
    ),
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
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByMemberIdMeta = const VerificationMeta(
    'paidByMemberId',
  );
  @override
  late final GeneratedColumn<String> paidByMemberId = GeneratedColumn<String>(
    'paid_by_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    messId,
    date,
    amountMinorUnits,
    paidByMemberId,
    category,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mess_id')) {
      context.handle(
        _messIdMeta,
        messId.isAcceptableOrUnknown(data['mess_id']!, _messIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('paid_by_member_id')) {
      context.handle(
        _paidByMemberIdMeta,
        paidByMemberId.isAcceptableOrUnknown(
          data['paid_by_member_id']!,
          _paidByMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidByMemberIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mess_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      paidByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_member_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
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
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final String messId;
  final DateTime date;
  final int amountMinorUnits;
  final String paidByMemberId;
  final String category;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExpenseRow({
    required this.id,
    required this.messId,
    required this.date,
    required this.amountMinorUnits,
    required this.paidByMemberId,
    required this.category,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mess_id'] = Variable<String>(messId);
    map['date'] = Variable<DateTime>(date);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['paid_by_member_id'] = Variable<String>(paidByMemberId);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      messId: Value(messId),
      date: Value(date),
      amountMinorUnits: Value(amountMinorUnits),
      paidByMemberId: Value(paidByMemberId),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      messId: serializer.fromJson<String>(json['messId']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      paidByMemberId: serializer.fromJson<String>(json['paidByMemberId']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messId': serializer.toJson<String>(messId),
      'date': serializer.toJson<DateTime>(date),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'paidByMemberId': serializer.toJson<String>(paidByMemberId),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExpenseRow copyWith({
    String? id,
    String? messId,
    DateTime? date,
    int? amountMinorUnits,
    String? paidByMemberId,
    String? category,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExpenseRow(
    id: id ?? this.id,
    messId: messId ?? this.messId,
    date: date ?? this.date,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    category: category ?? this.category,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      messId: data.messId.present ? data.messId.value : this.messId,
      date: data.date.present ? data.date.value : this.date,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      paidByMemberId: data.paidByMemberId.present
          ? data.paidByMemberId.value
          : this.paidByMemberId,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('date: $date, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messId,
    date,
    amountMinorUnits,
    paidByMemberId,
    category,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.messId == this.messId &&
          other.date == this.date &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.paidByMemberId == this.paidByMemberId &&
          other.category == this.category &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String> messId;
  final Value<DateTime> date;
  final Value<int> amountMinorUnits;
  final Value<String> paidByMemberId;
  final Value<String> category;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.messId = const Value.absent(),
    this.date = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.paidByMemberId = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String messId,
    required DateTime date,
    required int amountMinorUnits,
    required String paidByMemberId,
    required String category,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messId = Value(messId),
       date = Value(date),
       amountMinorUnits = Value(amountMinorUnits),
       paidByMemberId = Value(paidByMemberId),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? messId,
    Expression<DateTime>? date,
    Expression<int>? amountMinorUnits,
    Expression<String>? paidByMemberId,
    Expression<String>? category,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messId != null) 'mess_id': messId,
      if (date != null) 'date': date,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (paidByMemberId != null) 'paid_by_member_id': paidByMemberId,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? messId,
    Value<DateTime>? date,
    Value<int>? amountMinorUnits,
    Value<String>? paidByMemberId,
    Value<String>? category,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      date: date ?? this.date,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      category: category ?? this.category,
      note: note ?? this.note,
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
    if (messId.present) {
      map['mess_id'] = Variable<String>(messId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (paidByMemberId.present) {
      map['paid_by_member_id'] = Variable<String>(paidByMemberId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('date: $date, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messIdMeta = const VerificationMeta('messId');
  @override
  late final GeneratedColumn<String> messId = GeneratedColumn<String>(
    'mess_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messes (id)',
    ),
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
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    messId,
    date,
    memberId,
    amountMinorUnits,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mess_id')) {
      context.handle(
        _messIdMeta,
        messId.isAcceptableOrUnknown(data['mess_id']!, _messIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mess_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
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
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String messId;
  final DateTime date;
  final String memberId;
  final int amountMinorUnits;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PaymentRow({
    required this.id,
    required this.messId,
    required this.date,
    required this.memberId,
    required this.amountMinorUnits,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mess_id'] = Variable<String>(messId);
    map['date'] = Variable<DateTime>(date);
    map['member_id'] = Variable<String>(memberId);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      messId: Value(messId),
      date: Value(date),
      memberId: Value(memberId),
      amountMinorUnits: Value(amountMinorUnits),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      messId: serializer.fromJson<String>(json['messId']),
      date: serializer.fromJson<DateTime>(json['date']),
      memberId: serializer.fromJson<String>(json['memberId']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messId': serializer.toJson<String>(messId),
      'date': serializer.toJson<DateTime>(date),
      'memberId': serializer.toJson<String>(memberId),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? messId,
    DateTime? date,
    String? memberId,
    int? amountMinorUnits,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PaymentRow(
    id: id ?? this.id,
    messId: messId ?? this.messId,
    date: date ?? this.date,
    memberId: memberId ?? this.memberId,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      messId: data.messId.present ? data.messId.value : this.messId,
      date: data.date.present ? data.date.value : this.date,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('date: $date, ')
          ..write('memberId: $memberId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messId,
    date,
    memberId,
    amountMinorUnits,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.messId == this.messId &&
          other.date == this.date &&
          other.memberId == this.memberId &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> messId;
  final Value<DateTime> date;
  final Value<String> memberId;
  final Value<int> amountMinorUnits;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.messId = const Value.absent(),
    this.date = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String messId,
    required DateTime date,
    required String memberId,
    required int amountMinorUnits,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messId = Value(messId),
       date = Value(date),
       memberId = Value(memberId),
       amountMinorUnits = Value(amountMinorUnits),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? messId,
    Expression<DateTime>? date,
    Expression<String>? memberId,
    Expression<int>? amountMinorUnits,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messId != null) 'mess_id': messId,
      if (date != null) 'date': date,
      if (memberId != null) 'member_id': memberId,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? messId,
    Value<DateTime>? date,
    Value<String>? memberId,
    Value<int>? amountMinorUnits,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      date: date ?? this.date,
      memberId: memberId ?? this.memberId,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      note: note ?? this.note,
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
    if (messId.present) {
      map['mess_id'] = Variable<String>(messId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('date: $date, ')
          ..write('memberId: $memberId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlySettlementsTable extends MonthlySettlements
    with TableInfo<$MonthlySettlementsTable, MonthlySettlementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlySettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messIdMeta = const VerificationMeta('messId');
  @override
  late final GeneratedColumn<String> messId = GeneratedColumn<String>(
    'mess_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messes (id)',
    ),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpenseMinorUnitsMeta =
      const VerificationMeta('totalExpenseMinorUnits');
  @override
  late final GeneratedColumn<int> totalExpenseMinorUnits = GeneratedColumn<int>(
    'total_expense_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMealsMeta = const VerificationMeta(
    'totalMeals',
  );
  @override
  late final GeneratedColumn<int> totalMeals = GeneratedColumn<int>(
    'total_meals',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealRateMinorUnitsMeta =
      const VerificationMeta('mealRateMinorUnits');
  @override
  late final GeneratedColumn<int> mealRateMinorUnits = GeneratedColumn<int>(
    'meal_rate_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SettlementStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SettlementStatus.open.name),
      ).withConverter<SettlementStatus>(
        $MonthlySettlementsTable.$converterstatus,
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
    messId,
    month,
    year,
    totalExpenseMinorUnits,
    totalMeals,
    mealRateMinorUnits,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlySettlementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mess_id')) {
      context.handle(
        _messIdMeta,
        messId.isAcceptableOrUnknown(data['mess_id']!, _messIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('total_expense_minor_units')) {
      context.handle(
        _totalExpenseMinorUnitsMeta,
        totalExpenseMinorUnits.isAcceptableOrUnknown(
          data['total_expense_minor_units']!,
          _totalExpenseMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExpenseMinorUnitsMeta);
    }
    if (data.containsKey('total_meals')) {
      context.handle(
        _totalMealsMeta,
        totalMeals.isAcceptableOrUnknown(data['total_meals']!, _totalMealsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMealsMeta);
    }
    if (data.containsKey('meal_rate_minor_units')) {
      context.handle(
        _mealRateMinorUnitsMeta,
        mealRateMinorUnits.isAcceptableOrUnknown(
          data['meal_rate_minor_units']!,
          _mealRateMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealRateMinorUnitsMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messId, month, year},
  ];
  @override
  MonthlySettlementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlySettlementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mess_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      totalExpenseMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_expense_minor_units'],
      )!,
      totalMeals: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_meals'],
      )!,
      mealRateMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_rate_minor_units'],
      )!,
      status: $MonthlySettlementsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
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
  $MonthlySettlementsTable createAlias(String alias) {
    return $MonthlySettlementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SettlementStatus, String, String> $converterstatus =
      const EnumNameConverter<SettlementStatus>(SettlementStatus.values);
}

class MonthlySettlementRow extends DataClass
    implements Insertable<MonthlySettlementRow> {
  final String id;
  final String messId;
  final int month;
  final int year;
  final int totalExpenseMinorUnits;
  final int totalMeals;
  final int mealRateMinorUnits;
  final SettlementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MonthlySettlementRow({
    required this.id,
    required this.messId,
    required this.month,
    required this.year,
    required this.totalExpenseMinorUnits,
    required this.totalMeals,
    required this.mealRateMinorUnits,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mess_id'] = Variable<String>(messId);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    map['total_expense_minor_units'] = Variable<int>(totalExpenseMinorUnits);
    map['total_meals'] = Variable<int>(totalMeals);
    map['meal_rate_minor_units'] = Variable<int>(mealRateMinorUnits);
    {
      map['status'] = Variable<String>(
        $MonthlySettlementsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MonthlySettlementsCompanion toCompanion(bool nullToAbsent) {
    return MonthlySettlementsCompanion(
      id: Value(id),
      messId: Value(messId),
      month: Value(month),
      year: Value(year),
      totalExpenseMinorUnits: Value(totalExpenseMinorUnits),
      totalMeals: Value(totalMeals),
      mealRateMinorUnits: Value(mealRateMinorUnits),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonthlySettlementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlySettlementRow(
      id: serializer.fromJson<String>(json['id']),
      messId: serializer.fromJson<String>(json['messId']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      totalExpenseMinorUnits: serializer.fromJson<int>(
        json['totalExpenseMinorUnits'],
      ),
      totalMeals: serializer.fromJson<int>(json['totalMeals']),
      mealRateMinorUnits: serializer.fromJson<int>(json['mealRateMinorUnits']),
      status: $MonthlySettlementsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messId': serializer.toJson<String>(messId),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'totalExpenseMinorUnits': serializer.toJson<int>(totalExpenseMinorUnits),
      'totalMeals': serializer.toJson<int>(totalMeals),
      'mealRateMinorUnits': serializer.toJson<int>(mealRateMinorUnits),
      'status': serializer.toJson<String>(
        $MonthlySettlementsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MonthlySettlementRow copyWith({
    String? id,
    String? messId,
    int? month,
    int? year,
    int? totalExpenseMinorUnits,
    int? totalMeals,
    int? mealRateMinorUnits,
    SettlementStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MonthlySettlementRow(
    id: id ?? this.id,
    messId: messId ?? this.messId,
    month: month ?? this.month,
    year: year ?? this.year,
    totalExpenseMinorUnits:
        totalExpenseMinorUnits ?? this.totalExpenseMinorUnits,
    totalMeals: totalMeals ?? this.totalMeals,
    mealRateMinorUnits: mealRateMinorUnits ?? this.mealRateMinorUnits,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MonthlySettlementRow copyWithCompanion(MonthlySettlementsCompanion data) {
    return MonthlySettlementRow(
      id: data.id.present ? data.id.value : this.id,
      messId: data.messId.present ? data.messId.value : this.messId,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      totalExpenseMinorUnits: data.totalExpenseMinorUnits.present
          ? data.totalExpenseMinorUnits.value
          : this.totalExpenseMinorUnits,
      totalMeals: data.totalMeals.present
          ? data.totalMeals.value
          : this.totalMeals,
      mealRateMinorUnits: data.mealRateMinorUnits.present
          ? data.mealRateMinorUnits.value
          : this.mealRateMinorUnits,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlySettlementRow(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('totalExpenseMinorUnits: $totalExpenseMinorUnits, ')
          ..write('totalMeals: $totalMeals, ')
          ..write('mealRateMinorUnits: $mealRateMinorUnits, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messId,
    month,
    year,
    totalExpenseMinorUnits,
    totalMeals,
    mealRateMinorUnits,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlySettlementRow &&
          other.id == this.id &&
          other.messId == this.messId &&
          other.month == this.month &&
          other.year == this.year &&
          other.totalExpenseMinorUnits == this.totalExpenseMinorUnits &&
          other.totalMeals == this.totalMeals &&
          other.mealRateMinorUnits == this.mealRateMinorUnits &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MonthlySettlementsCompanion
    extends UpdateCompanion<MonthlySettlementRow> {
  final Value<String> id;
  final Value<String> messId;
  final Value<int> month;
  final Value<int> year;
  final Value<int> totalExpenseMinorUnits;
  final Value<int> totalMeals;
  final Value<int> mealRateMinorUnits;
  final Value<SettlementStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MonthlySettlementsCompanion({
    this.id = const Value.absent(),
    this.messId = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.totalExpenseMinorUnits = const Value.absent(),
    this.totalMeals = const Value.absent(),
    this.mealRateMinorUnits = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlySettlementsCompanion.insert({
    required String id,
    required String messId,
    required int month,
    required int year,
    required int totalExpenseMinorUnits,
    required int totalMeals,
    required int mealRateMinorUnits,
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messId = Value(messId),
       month = Value(month),
       year = Value(year),
       totalExpenseMinorUnits = Value(totalExpenseMinorUnits),
       totalMeals = Value(totalMeals),
       mealRateMinorUnits = Value(mealRateMinorUnits),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MonthlySettlementRow> custom({
    Expression<String>? id,
    Expression<String>? messId,
    Expression<int>? month,
    Expression<int>? year,
    Expression<int>? totalExpenseMinorUnits,
    Expression<int>? totalMeals,
    Expression<int>? mealRateMinorUnits,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messId != null) 'mess_id': messId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (totalExpenseMinorUnits != null)
        'total_expense_minor_units': totalExpenseMinorUnits,
      if (totalMeals != null) 'total_meals': totalMeals,
      if (mealRateMinorUnits != null)
        'meal_rate_minor_units': mealRateMinorUnits,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlySettlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? messId,
    Value<int>? month,
    Value<int>? year,
    Value<int>? totalExpenseMinorUnits,
    Value<int>? totalMeals,
    Value<int>? mealRateMinorUnits,
    Value<SettlementStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MonthlySettlementsCompanion(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      month: month ?? this.month,
      year: year ?? this.year,
      totalExpenseMinorUnits:
          totalExpenseMinorUnits ?? this.totalExpenseMinorUnits,
      totalMeals: totalMeals ?? this.totalMeals,
      mealRateMinorUnits: mealRateMinorUnits ?? this.mealRateMinorUnits,
      status: status ?? this.status,
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
    if (messId.present) {
      map['mess_id'] = Variable<String>(messId.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (totalExpenseMinorUnits.present) {
      map['total_expense_minor_units'] = Variable<int>(
        totalExpenseMinorUnits.value,
      );
    }
    if (totalMeals.present) {
      map['total_meals'] = Variable<int>(totalMeals.value);
    }
    if (mealRateMinorUnits.present) {
      map['meal_rate_minor_units'] = Variable<int>(mealRateMinorUnits.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MonthlySettlementsTable.$converterstatus.toSql(status.value),
      );
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
    return (StringBuffer('MonthlySettlementsCompanion(')
          ..write('id: $id, ')
          ..write('messId: $messId, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('totalExpenseMinorUnits: $totalExpenseMinorUnits, ')
          ..write('totalMeals: $totalMeals, ')
          ..write('mealRateMinorUnits: $mealRateMinorUnits, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlySettlementMembersTable extends MonthlySettlementMembers
    with TableInfo<$MonthlySettlementMembersTable, MonthlySettlementMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlySettlementMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settlementIdMeta = const VerificationMeta(
    'settlementId',
  );
  @override
  late final GeneratedColumn<String> settlementId = GeneratedColumn<String>(
    'settlement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES monthly_settlements (id)',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES members (id)',
    ),
  );
  static const VerificationMeta _mealCountMeta = const VerificationMeta(
    'mealCount',
  );
  @override
  late final GeneratedColumn<int> mealCount = GeneratedColumn<int>(
    'meal_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealCostMinorUnitsMeta =
      const VerificationMeta('mealCostMinorUnits');
  @override
  late final GeneratedColumn<int> mealCostMinorUnits = GeneratedColumn<int>(
    'meal_cost_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMinorUnitsMeta =
      const VerificationMeta('paidAmountMinorUnits');
  @override
  late final GeneratedColumn<int> paidAmountMinorUnits = GeneratedColumn<int>(
    'paid_amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMinorUnitsMeta = const VerificationMeta(
    'balanceMinorUnits',
  );
  @override
  late final GeneratedColumn<int> balanceMinorUnits = GeneratedColumn<int>(
    'balance_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    settlementId,
    memberId,
    mealCount,
    mealCostMinorUnits,
    paidAmountMinorUnits,
    balanceMinorUnits,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_settlement_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlySettlementMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('settlement_id')) {
      context.handle(
        _settlementIdMeta,
        settlementId.isAcceptableOrUnknown(
          data['settlement_id']!,
          _settlementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settlementIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('meal_count')) {
      context.handle(
        _mealCountMeta,
        mealCount.isAcceptableOrUnknown(data['meal_count']!, _mealCountMeta),
      );
    } else if (isInserting) {
      context.missing(_mealCountMeta);
    }
    if (data.containsKey('meal_cost_minor_units')) {
      context.handle(
        _mealCostMinorUnitsMeta,
        mealCostMinorUnits.isAcceptableOrUnknown(
          data['meal_cost_minor_units']!,
          _mealCostMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealCostMinorUnitsMeta);
    }
    if (data.containsKey('paid_amount_minor_units')) {
      context.handle(
        _paidAmountMinorUnitsMeta,
        paidAmountMinorUnits.isAcceptableOrUnknown(
          data['paid_amount_minor_units']!,
          _paidAmountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidAmountMinorUnitsMeta);
    }
    if (data.containsKey('balance_minor_units')) {
      context.handle(
        _balanceMinorUnitsMeta,
        balanceMinorUnits.isAcceptableOrUnknown(
          data['balance_minor_units']!,
          _balanceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceMinorUnitsMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {settlementId, memberId},
  ];
  @override
  MonthlySettlementMemberRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlySettlementMemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      settlementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      mealCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_count'],
      )!,
      mealCostMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_cost_minor_units'],
      )!,
      paidAmountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_amount_minor_units'],
      )!,
      balanceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_minor_units'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MonthlySettlementMembersTable createAlias(String alias) {
    return $MonthlySettlementMembersTable(attachedDatabase, alias);
  }
}

class MonthlySettlementMemberRow extends DataClass
    implements Insertable<MonthlySettlementMemberRow> {
  final String id;
  final String settlementId;
  final String memberId;
  final int mealCount;
  final int mealCostMinorUnits;
  final int paidAmountMinorUnits;
  final int balanceMinorUnits;
  final DateTime createdAt;
  const MonthlySettlementMemberRow({
    required this.id,
    required this.settlementId,
    required this.memberId,
    required this.mealCount,
    required this.mealCostMinorUnits,
    required this.paidAmountMinorUnits,
    required this.balanceMinorUnits,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['settlement_id'] = Variable<String>(settlementId);
    map['member_id'] = Variable<String>(memberId);
    map['meal_count'] = Variable<int>(mealCount);
    map['meal_cost_minor_units'] = Variable<int>(mealCostMinorUnits);
    map['paid_amount_minor_units'] = Variable<int>(paidAmountMinorUnits);
    map['balance_minor_units'] = Variable<int>(balanceMinorUnits);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MonthlySettlementMembersCompanion toCompanion(bool nullToAbsent) {
    return MonthlySettlementMembersCompanion(
      id: Value(id),
      settlementId: Value(settlementId),
      memberId: Value(memberId),
      mealCount: Value(mealCount),
      mealCostMinorUnits: Value(mealCostMinorUnits),
      paidAmountMinorUnits: Value(paidAmountMinorUnits),
      balanceMinorUnits: Value(balanceMinorUnits),
      createdAt: Value(createdAt),
    );
  }

  factory MonthlySettlementMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlySettlementMemberRow(
      id: serializer.fromJson<String>(json['id']),
      settlementId: serializer.fromJson<String>(json['settlementId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      mealCount: serializer.fromJson<int>(json['mealCount']),
      mealCostMinorUnits: serializer.fromJson<int>(json['mealCostMinorUnits']),
      paidAmountMinorUnits: serializer.fromJson<int>(
        json['paidAmountMinorUnits'],
      ),
      balanceMinorUnits: serializer.fromJson<int>(json['balanceMinorUnits']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'settlementId': serializer.toJson<String>(settlementId),
      'memberId': serializer.toJson<String>(memberId),
      'mealCount': serializer.toJson<int>(mealCount),
      'mealCostMinorUnits': serializer.toJson<int>(mealCostMinorUnits),
      'paidAmountMinorUnits': serializer.toJson<int>(paidAmountMinorUnits),
      'balanceMinorUnits': serializer.toJson<int>(balanceMinorUnits),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MonthlySettlementMemberRow copyWith({
    String? id,
    String? settlementId,
    String? memberId,
    int? mealCount,
    int? mealCostMinorUnits,
    int? paidAmountMinorUnits,
    int? balanceMinorUnits,
    DateTime? createdAt,
  }) => MonthlySettlementMemberRow(
    id: id ?? this.id,
    settlementId: settlementId ?? this.settlementId,
    memberId: memberId ?? this.memberId,
    mealCount: mealCount ?? this.mealCount,
    mealCostMinorUnits: mealCostMinorUnits ?? this.mealCostMinorUnits,
    paidAmountMinorUnits: paidAmountMinorUnits ?? this.paidAmountMinorUnits,
    balanceMinorUnits: balanceMinorUnits ?? this.balanceMinorUnits,
    createdAt: createdAt ?? this.createdAt,
  );
  MonthlySettlementMemberRow copyWithCompanion(
    MonthlySettlementMembersCompanion data,
  ) {
    return MonthlySettlementMemberRow(
      id: data.id.present ? data.id.value : this.id,
      settlementId: data.settlementId.present
          ? data.settlementId.value
          : this.settlementId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      mealCount: data.mealCount.present ? data.mealCount.value : this.mealCount,
      mealCostMinorUnits: data.mealCostMinorUnits.present
          ? data.mealCostMinorUnits.value
          : this.mealCostMinorUnits,
      paidAmountMinorUnits: data.paidAmountMinorUnits.present
          ? data.paidAmountMinorUnits.value
          : this.paidAmountMinorUnits,
      balanceMinorUnits: data.balanceMinorUnits.present
          ? data.balanceMinorUnits.value
          : this.balanceMinorUnits,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlySettlementMemberRow(')
          ..write('id: $id, ')
          ..write('settlementId: $settlementId, ')
          ..write('memberId: $memberId, ')
          ..write('mealCount: $mealCount, ')
          ..write('mealCostMinorUnits: $mealCostMinorUnits, ')
          ..write('paidAmountMinorUnits: $paidAmountMinorUnits, ')
          ..write('balanceMinorUnits: $balanceMinorUnits, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    settlementId,
    memberId,
    mealCount,
    mealCostMinorUnits,
    paidAmountMinorUnits,
    balanceMinorUnits,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlySettlementMemberRow &&
          other.id == this.id &&
          other.settlementId == this.settlementId &&
          other.memberId == this.memberId &&
          other.mealCount == this.mealCount &&
          other.mealCostMinorUnits == this.mealCostMinorUnits &&
          other.paidAmountMinorUnits == this.paidAmountMinorUnits &&
          other.balanceMinorUnits == this.balanceMinorUnits &&
          other.createdAt == this.createdAt);
}

class MonthlySettlementMembersCompanion
    extends UpdateCompanion<MonthlySettlementMemberRow> {
  final Value<String> id;
  final Value<String> settlementId;
  final Value<String> memberId;
  final Value<int> mealCount;
  final Value<int> mealCostMinorUnits;
  final Value<int> paidAmountMinorUnits;
  final Value<int> balanceMinorUnits;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MonthlySettlementMembersCompanion({
    this.id = const Value.absent(),
    this.settlementId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.mealCount = const Value.absent(),
    this.mealCostMinorUnits = const Value.absent(),
    this.paidAmountMinorUnits = const Value.absent(),
    this.balanceMinorUnits = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlySettlementMembersCompanion.insert({
    required String id,
    required String settlementId,
    required String memberId,
    required int mealCount,
    required int mealCostMinorUnits,
    required int paidAmountMinorUnits,
    required int balanceMinorUnits,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       settlementId = Value(settlementId),
       memberId = Value(memberId),
       mealCount = Value(mealCount),
       mealCostMinorUnits = Value(mealCostMinorUnits),
       paidAmountMinorUnits = Value(paidAmountMinorUnits),
       balanceMinorUnits = Value(balanceMinorUnits),
       createdAt = Value(createdAt);
  static Insertable<MonthlySettlementMemberRow> custom({
    Expression<String>? id,
    Expression<String>? settlementId,
    Expression<String>? memberId,
    Expression<int>? mealCount,
    Expression<int>? mealCostMinorUnits,
    Expression<int>? paidAmountMinorUnits,
    Expression<int>? balanceMinorUnits,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (settlementId != null) 'settlement_id': settlementId,
      if (memberId != null) 'member_id': memberId,
      if (mealCount != null) 'meal_count': mealCount,
      if (mealCostMinorUnits != null)
        'meal_cost_minor_units': mealCostMinorUnits,
      if (paidAmountMinorUnits != null)
        'paid_amount_minor_units': paidAmountMinorUnits,
      if (balanceMinorUnits != null) 'balance_minor_units': balanceMinorUnits,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlySettlementMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? settlementId,
    Value<String>? memberId,
    Value<int>? mealCount,
    Value<int>? mealCostMinorUnits,
    Value<int>? paidAmountMinorUnits,
    Value<int>? balanceMinorUnits,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MonthlySettlementMembersCompanion(
      id: id ?? this.id,
      settlementId: settlementId ?? this.settlementId,
      memberId: memberId ?? this.memberId,
      mealCount: mealCount ?? this.mealCount,
      mealCostMinorUnits: mealCostMinorUnits ?? this.mealCostMinorUnits,
      paidAmountMinorUnits: paidAmountMinorUnits ?? this.paidAmountMinorUnits,
      balanceMinorUnits: balanceMinorUnits ?? this.balanceMinorUnits,
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
    if (settlementId.present) {
      map['settlement_id'] = Variable<String>(settlementId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (mealCount.present) {
      map['meal_count'] = Variable<int>(mealCount.value);
    }
    if (mealCostMinorUnits.present) {
      map['meal_cost_minor_units'] = Variable<int>(mealCostMinorUnits.value);
    }
    if (paidAmountMinorUnits.present) {
      map['paid_amount_minor_units'] = Variable<int>(
        paidAmountMinorUnits.value,
      );
    }
    if (balanceMinorUnits.present) {
      map['balance_minor_units'] = Variable<int>(balanceMinorUnits.value);
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
    return (StringBuffer('MonthlySettlementMembersCompanion(')
          ..write('id: $id, ')
          ..write('settlementId: $settlementId, ')
          ..write('memberId: $memberId, ')
          ..write('mealCount: $mealCount, ')
          ..write('mealCostMinorUnits: $mealCostMinorUnits, ')
          ..write('paidAmountMinorUnits: $paidAmountMinorUnits, ')
          ..write('balanceMinorUnits: $balanceMinorUnits, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessesTable messes = $MessesTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $MealEntriesTable mealEntries = $MealEntriesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $MonthlySettlementsTable monthlySettlements =
      $MonthlySettlementsTable(this);
  late final $MonthlySettlementMembersTable monthlySettlementMembers =
      $MonthlySettlementMembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messes,
    members,
    mealEntries,
    expenses,
    payments,
    monthlySettlements,
    monthlySettlementMembers,
  ];
}

typedef $$MessesTableCreateCompanionBuilder = MessesCompanion Function({
  required String id,
  required String name,
  Value<String> currencyCode,
  Value<String> currencySymbol,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MessesTableUpdateCompanionBuilder = MessesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> currencyCode,
  Value<String> currencySymbol,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MessesTableReferences
    extends BaseReferences<_$AppDatabase, $MessesTable, MessRow> {
  $$MessesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MembersTable, List<MemberRow>> _membersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.members,
    aliasName: 'messes__id__members__mess_id',
  );

  $$MembersTableProcessedTableManager get membersRefs {
    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.messId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_membersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MealEntriesTable, List<MealEntryRow>>
  _mealEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealEntries,
    aliasName: 'messes__id__meal_entries__mess_id',
  );

  $$MealEntriesTableProcessedTableManager get mealEntriesRefs {
    final manager = $$MealEntriesTableTableManager(
      $_db,
      $_db.mealEntries,
    ).filter((f) => f.messId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'messes__id__expenses__mess_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.messId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'messes__id__payments__mess_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.messId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MonthlySettlementsTable,
    List<MonthlySettlementRow>
  >
  _monthlySettlementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.monthlySettlements,
        aliasName: 'messes__id__monthly_settlements__mess_id',
      );

  $$MonthlySettlementsTableProcessedTableManager get monthlySettlementsRefs {
    final manager = $$MonthlySettlementsTableTableManager(
      $_db,
      $_db.monthlySettlements,
    ).filter((f) => f.messId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _monthlySettlementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessesTableFilterComposer
    extends Composer<_$AppDatabase, $MessesTable> {
  $$MessesTableFilterComposer({
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
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

  Expression<bool> membersRefs(
    Expression<bool> Function($$MembersTableFilterComposer f) f,
  ) {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mealEntriesRefs(
    Expression<bool> Function($$MealEntriesTableFilterComposer f) f,
  ) {
    final $$MealEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableFilterComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> monthlySettlementsRefs(
    Expression<bool> Function($$MonthlySettlementsTableFilterComposer f) f,
  ) {
    final $$MonthlySettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monthlySettlements,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlySettlementsTableFilterComposer(
            $db: $db,
            $table: $db.monthlySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessesTable> {
  $$MessesTableOrderingComposer({
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
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

class $$MessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessesTable> {
  $$MessesTableAnnotationComposer({
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

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> membersRefs<T extends Object>(
    Expression<T> Function($$MembersTableAnnotationComposer a) f,
  ) {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mealEntriesRefs<T extends Object>(
    Expression<T> Function($$MealEntriesTableAnnotationComposer a) f,
  ) {
    final $$MealEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.messId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> monthlySettlementsRefs<T extends Object>(
    Expression<T> Function($$MonthlySettlementsTableAnnotationComposer a) f,
  ) {
    final $$MonthlySettlementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.monthlySettlements,
          getReferencedColumn: (t) => t.messId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MonthlySettlementsTableAnnotationComposer(
                $db: $db,
                $table: $db.monthlySettlements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessesTable,
          MessRow,
          $$MessesTableFilterComposer,
          $$MessesTableOrderingComposer,
          $$MessesTableAnnotationComposer,
          $$MessesTableCreateCompanionBuilder,
          $$MessesTableUpdateCompanionBuilder,
          (MessRow, $$MessesTableReferences),
          MessRow,
          PrefetchHooks Function({
            bool membersRefs,
            bool mealEntriesRefs,
            bool expensesRefs,
            bool paymentsRefs,
            bool monthlySettlementsRefs,
          })
        > {
  $$MessesTableTableManager(_$AppDatabase db, $MessesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessesCompanion(
                id: id,
                name: name,
                currencyCode: currencyCode,
                currencySymbol: currencySymbol,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> currencyCode = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MessesCompanion.insert(
                id: id,
                name: name,
                currencyCode: currencyCode,
                currencySymbol: currencySymbol,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessesTable, MessRow>(table),
                  $$MessesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                membersRefs = false,
                mealEntriesRefs = false,
                expensesRefs = false,
                paymentsRefs = false,
                monthlySettlementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (membersRefs) db.members,
                    if (mealEntriesRefs) db.mealEntries,
                    if (expensesRefs) db.expenses,
                    if (paymentsRefs) db.payments,
                    if (monthlySettlementsRefs) db.monthlySettlements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (membersRefs)
                        await $_getPrefetchedData<
                          MessRow,
                          $MessesTable,
                          MemberRow
                        >(
                          currentTable: table,
                          referencedTable: $$MessesTableReferences
                              ._membersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessesTableReferences(
                                db,
                                table,
                                p0,
                              ).membersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mealEntriesRefs)
                        await $_getPrefetchedData<
                          MessRow,
                          $MessesTable,
                          MealEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$MessesTableReferences
                              ._mealEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessesTableReferences(
                                db,
                                table,
                                p0,
                              ).mealEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          MessRow,
                          $MessesTable,
                          ExpenseRow
                        >(
                          currentTable: table,
                          referencedTable: $$MessesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          MessRow,
                          $MessesTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$MessesTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (monthlySettlementsRefs)
                        await $_getPrefetchedData<
                          MessRow,
                          $MessesTable,
                          MonthlySettlementRow
                        >(
                          currentTable: table,
                          referencedTable: $$MessesTableReferences
                              ._monthlySettlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessesTableReferences(
                                db,
                                table,
                                p0,
                              ).monthlySettlementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messId == item.id,
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

typedef $$MessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessesTable,
      MessRow,
      $$MessesTableFilterComposer,
      $$MessesTableOrderingComposer,
      $$MessesTableAnnotationComposer,
      $$MessesTableCreateCompanionBuilder,
      $$MessesTableUpdateCompanionBuilder,
      (MessRow, $$MessesTableReferences),
      MessRow,
      PrefetchHooks Function({
        bool membersRefs,
        bool mealEntriesRefs,
        bool expensesRefs,
        bool paymentsRefs,
        bool monthlySettlementsRefs,
      })
    >;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  required String messId,
  required String name,
  Value<String?> phone,
  required DateTime joinedAt,
  Value<DateTime?> leftAt,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> messId,
  Value<String> name,
  Value<String?> phone,
  Value<DateTime> joinedAt,
  Value<DateTime?> leftAt,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MembersTableReferences
    extends BaseReferences<_$AppDatabase, $MembersTable, MemberRow> {
  $$MembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessesTable _messIdTable(_$AppDatabase db) =>
      db.messes.createAlias('members__mess_id__messes__id');

  $$MessesTableProcessedTableManager get messId {
    final $_column = $_itemColumn<String>('mess_id')!;

    final manager = $$MessesTableTableManager(
      $_db,
      $_db.messes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MealEntriesTable, List<MealEntryRow>>
  _mealEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealEntries,
    aliasName: 'members__id__meal_entries__member_id',
  );

  $$MealEntriesTableProcessedTableManager get mealEntriesRefs {
    final manager = $$MealEntriesTableTableManager(
      $_db,
      $_db.mealEntries,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'members__id__expenses__paid_by_member_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.paidByMemberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'members__id__payments__member_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MonthlySettlementMembersTable,
    List<MonthlySettlementMemberRow>
  >
  _monthlySettlementMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.monthlySettlementMembers,
        aliasName: 'members__id__monthly_settlement_members__member_id',
      );

  $$MonthlySettlementMembersTableProcessedTableManager
  get monthlySettlementMembersRefs {
    final manager = $$MonthlySettlementMembersTableTableManager(
      $_db,
      $_db.monthlySettlementMembers,
    ).filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _monthlySettlementMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leftAt => $composableBuilder(
    column: $table.leftAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  $$MessesTableFilterComposer get messId {
    final $$MessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableFilterComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> mealEntriesRefs(
    Expression<bool> Function($$MealEntriesTableFilterComposer f) f,
  ) {
    final $$MealEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableFilterComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paidByMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> monthlySettlementMembersRefs(
    Expression<bool> Function($$MonthlySettlementMembersTableFilterComposer f)
    f,
  ) {
    final $$MonthlySettlementMembersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.monthlySettlementMembers,
          getReferencedColumn: (t) => t.memberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MonthlySettlementMembersTableFilterComposer(
                $db: $db,
                $table: $db.monthlySettlementMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leftAt => $composableBuilder(
    column: $table.leftAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  $$MessesTableOrderingComposer get messId {
    final $$MessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableOrderingComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get leftAt =>
      $composableBuilder(column: $table.leftAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MessesTableAnnotationComposer get messId {
    final $$MessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableAnnotationComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> mealEntriesRefs<T extends Object>(
    Expression<T> Function($$MealEntriesTableAnnotationComposer a) f,
  ) {
    final $$MealEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paidByMemberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.memberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> monthlySettlementMembersRefs<T extends Object>(
    Expression<T> Function($$MonthlySettlementMembersTableAnnotationComposer a)
    f,
  ) {
    final $$MonthlySettlementMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.monthlySettlementMembers,
          getReferencedColumn: (t) => t.memberId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MonthlySettlementMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.monthlySettlementMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          MemberRow,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (MemberRow, $$MembersTableReferences),
          MemberRow,
          PrefetchHooks Function({
            bool messId,
            bool mealEntriesRefs,
            bool expensesRefs,
            bool paymentsRefs,
            bool monthlySettlementMembersRefs,
          })
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<DateTime?> leftAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                messId: messId,
                name: name,
                phone: phone,
                joinedAt: joinedAt,
                leftAt: leftAt,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messId,
                required String name,
                Value<String?> phone = const Value.absent(),
                required DateTime joinedAt,
                Value<DateTime?> leftAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                messId: messId,
                name: name,
                phone: phone,
                joinedAt: joinedAt,
                leftAt: leftAt,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MembersTable, MemberRow>(table),
                  $$MembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                messId = false,
                mealEntriesRefs = false,
                expensesRefs = false,
                paymentsRefs = false,
                monthlySettlementMembersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mealEntriesRefs) db.mealEntries,
                    if (expensesRefs) db.expenses,
                    if (paymentsRefs) db.payments,
                    if (monthlySettlementMembersRefs)
                      db.monthlySettlementMembers,
                  ],
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
                        if (messId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.messId,
                            referencedTable: $$MembersTableReferences
                                ._messIdTable(db),
                            referencedColumn: $$MembersTableReferences
                                ._messIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mealEntriesRefs)
                        await $_getPrefetchedData<
                          MemberRow,
                          $MembersTable,
                          MealEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._mealEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).mealEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          MemberRow,
                          $MembersTable,
                          ExpenseRow
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paidByMemberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          MemberRow,
                          $MembersTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (monthlySettlementMembersRefs)
                        await $_getPrefetchedData<
                          MemberRow,
                          $MembersTable,
                          MonthlySettlementMemberRow
                        >(
                          currentTable: table,
                          referencedTable: $$MembersTableReferences
                              ._monthlySettlementMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MembersTableReferences(
                                db,
                                table,
                                p0,
                              ).monthlySettlementMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memberId == item.id,
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

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      MemberRow,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (MemberRow, $$MembersTableReferences),
      MemberRow,
      PrefetchHooks Function({
        bool messId,
        bool mealEntriesRefs,
        bool expensesRefs,
        bool paymentsRefs,
        bool monthlySettlementMembersRefs,
      })
    >;
typedef $$MealEntriesTableCreateCompanionBuilder =
    MealEntriesCompanion Function({
      required String id,
      required String messId,
      required String memberId,
      required DateTime date,
      Value<bool> breakfast,
      Value<bool> lunch,
      Value<bool> dinner,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MealEntriesTableUpdateCompanionBuilder =
    MealEntriesCompanion Function({
      Value<String> id,
      Value<String> messId,
      Value<String> memberId,
      Value<DateTime> date,
      Value<bool> breakfast,
      Value<bool> lunch,
      Value<bool> dinner,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MealEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntryRow> {
  $$MealEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessesTable _messIdTable(_$AppDatabase db) =>
      db.messes.createAlias('meal_entries__mess_id__messes__id');

  $$MessesTableProcessedTableManager get messId {
    final $_column = $_itemColumn<String>('mess_id')!;

    final manager = $$MessesTableTableManager(
      $_db,
      $_db.messes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias('meal_entries__member_id__members__id');

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MealEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get breakfast => $composableBuilder(
    column: $table.breakfast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lunch => $composableBuilder(
    column: $table.lunch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dinner => $composableBuilder(
    column: $table.dinner,
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

  $$MessesTableFilterComposer get messId {
    final $$MessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableFilterComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get breakfast => $composableBuilder(
    column: $table.breakfast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lunch => $composableBuilder(
    column: $table.lunch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dinner => $composableBuilder(
    column: $table.dinner,
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

  $$MessesTableOrderingComposer get messId {
    final $$MessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableOrderingComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get breakfast =>
      $composableBuilder(column: $table.breakfast, builder: (column) => column);

  GeneratedColumn<bool> get lunch =>
      $composableBuilder(column: $table.lunch, builder: (column) => column);

  GeneratedColumn<bool> get dinner =>
      $composableBuilder(column: $table.dinner, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MessesTableAnnotationComposer get messId {
    final $$MessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableAnnotationComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEntriesTable,
          MealEntryRow,
          $$MealEntriesTableFilterComposer,
          $$MealEntriesTableOrderingComposer,
          $$MealEntriesTableAnnotationComposer,
          $$MealEntriesTableCreateCompanionBuilder,
          $$MealEntriesTableUpdateCompanionBuilder,
          (MealEntryRow, $$MealEntriesTableReferences),
          MealEntryRow,
          PrefetchHooks Function({bool messId, bool memberId})
        > {
  $$MealEntriesTableTableManager(_$AppDatabase db, $MealEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> breakfast = const Value.absent(),
                Value<bool> lunch = const Value.absent(),
                Value<bool> dinner = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion(
                id: id,
                messId: messId,
                memberId: memberId,
                date: date,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messId,
                required String memberId,
                required DateTime date,
                Value<bool> breakfast = const Value.absent(),
                Value<bool> lunch = const Value.absent(),
                Value<bool> dinner = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion.insert(
                id: id,
                messId: messId,
                memberId: memberId,
                date: date,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MealEntriesTable, MealEntryRow>(table),
                  $$MealEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messId = false, memberId = false}) {
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
                    if (messId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.messId,
                        referencedTable: $$MealEntriesTableReferences
                            ._messIdTable(db),
                        referencedColumn: $$MealEntriesTableReferences
                            ._messIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (memberId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memberId,
                        referencedTable: $$MealEntriesTableReferences
                            ._memberIdTable(db),
                        referencedColumn: $$MealEntriesTableReferences
                            ._memberIdTable(db)
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

typedef $$MealEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEntriesTable,
      MealEntryRow,
      $$MealEntriesTableFilterComposer,
      $$MealEntriesTableOrderingComposer,
      $$MealEntriesTableAnnotationComposer,
      $$MealEntriesTableCreateCompanionBuilder,
      $$MealEntriesTableUpdateCompanionBuilder,
      (MealEntryRow, $$MealEntriesTableReferences),
      MealEntryRow,
      PrefetchHooks Function({bool messId, bool memberId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String messId,
  required DateTime date,
  required int amountMinorUnits,
  required String paidByMemberId,
  required String category,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> messId,
  Value<DateTime> date,
  Value<int> amountMinorUnits,
  Value<String> paidByMemberId,
  Value<String> category,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessesTable _messIdTable(_$AppDatabase db) =>
      db.messes.createAlias('expenses__mess_id__messes__id');

  $$MessesTableProcessedTableManager get messId {
    final $_column = $_itemColumn<String>('mess_id')!;

    final manager = $$MessesTableTableManager(
      $_db,
      $_db.messes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _paidByMemberIdTable(_$AppDatabase db) =>
      db.members.createAlias('expenses__paid_by_member_id__members__id');

  $$MembersTableProcessedTableManager get paidByMemberId {
    final $_column = $_itemColumn<String>('paid_by_member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paidByMemberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  $$MessesTableFilterComposer get messId {
    final $$MessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableFilterComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get paidByMemberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  $$MessesTableOrderingComposer get messId {
    final $$MessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableOrderingComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get paidByMemberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MessesTableAnnotationComposer get messId {
    final $$MessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableAnnotationComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get paidByMemberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByMemberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (ExpenseRow, $$ExpensesTableReferences),
          ExpenseRow,
          PrefetchHooks Function({bool messId, bool paidByMemberId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> paidByMemberId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                messId: messId,
                date: date,
                amountMinorUnits: amountMinorUnits,
                paidByMemberId: paidByMemberId,
                category: category,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messId,
                required DateTime date,
                required int amountMinorUnits,
                required String paidByMemberId,
                required String category,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                messId: messId,
                date: date,
                amountMinorUnits: amountMinorUnits,
                paidByMemberId: paidByMemberId,
                category: category,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messId = false, paidByMemberId = false}) {
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
                    if (messId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.messId,
                        referencedTable: $$ExpensesTableReferences._messIdTable(
                          db,
                        ),
                        referencedColumn: $$ExpensesTableReferences
                            ._messIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (paidByMemberId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.paidByMemberId,
                        referencedTable: $$ExpensesTableReferences
                            ._paidByMemberIdTable(db),
                        referencedColumn: $$ExpensesTableReferences
                            ._paidByMemberIdTable(db)
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, $$ExpensesTableReferences),
      ExpenseRow,
      PrefetchHooks Function({bool messId, bool paidByMemberId})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String messId,
  required DateTime date,
  required String memberId,
  required int amountMinorUnits,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> messId,
  Value<DateTime> date,
  Value<String> memberId,
  Value<int> amountMinorUnits,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessesTable _messIdTable(_$AppDatabase db) =>
      db.messes.createAlias('payments__mess_id__messes__id');

  $$MessesTableProcessedTableManager get messId {
    final $_column = $_itemColumn<String>('mess_id')!;

    final manager = $$MessesTableTableManager(
      $_db,
      $_db.messes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) =>
      db.members.createAlias('payments__member_id__members__id');

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  $$MessesTableFilterComposer get messId {
    final $$MessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableFilterComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  $$MessesTableOrderingComposer get messId {
    final $$MessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableOrderingComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MessesTableAnnotationComposer get messId {
    final $$MessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableAnnotationComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool messId, bool memberId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                messId: messId,
                date: date,
                memberId: memberId,
                amountMinorUnits: amountMinorUnits,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messId,
                required DateTime date,
                required String memberId,
                required int amountMinorUnits,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                messId: messId,
                date: date,
                memberId: memberId,
                amountMinorUnits: amountMinorUnits,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, PaymentRow>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messId = false, memberId = false}) {
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
                    if (messId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.messId,
                        referencedTable: $$PaymentsTableReferences._messIdTable(
                          db,
                        ),
                        referencedColumn: $$PaymentsTableReferences
                            ._messIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (memberId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memberId,
                        referencedTable: $$PaymentsTableReferences
                            ._memberIdTable(db),
                        referencedColumn: $$PaymentsTableReferences
                            ._memberIdTable(db)
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool messId, bool memberId})
    >;
typedef $$MonthlySettlementsTableCreateCompanionBuilder =
    MonthlySettlementsCompanion Function({
      required String id,
      required String messId,
      required int month,
      required int year,
      required int totalExpenseMinorUnits,
      required int totalMeals,
      required int mealRateMinorUnits,
      Value<SettlementStatus> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MonthlySettlementsTableUpdateCompanionBuilder =
    MonthlySettlementsCompanion Function({
      Value<String> id,
      Value<String> messId,
      Value<int> month,
      Value<int> year,
      Value<int> totalExpenseMinorUnits,
      Value<int> totalMeals,
      Value<int> mealRateMinorUnits,
      Value<SettlementStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MonthlySettlementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MonthlySettlementsTable,
          MonthlySettlementRow
        > {
  $$MonthlySettlementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MessesTable _messIdTable(_$AppDatabase db) =>
      db.messes.createAlias('monthly_settlements__mess_id__messes__id');

  $$MessesTableProcessedTableManager get messId {
    final $_column = $_itemColumn<String>('mess_id')!;

    final manager = $$MessesTableTableManager(
      $_db,
      $_db.messes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MonthlySettlementMembersTable,
    List<MonthlySettlementMemberRow>
  >
  _monthlySettlementMembersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.monthlySettlementMembers,
    aliasName:
        'monthly_settlements__id__monthly_settlement_members__settlement_id',
  );

  $$MonthlySettlementMembersTableProcessedTableManager
  get monthlySettlementMembersRefs {
    final manager = $$MonthlySettlementMembersTableTableManager(
      $_db,
      $_db.monthlySettlementMembers,
    ).filter((f) => f.settlementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _monthlySettlementMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MonthlySettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlySettlementsTable> {
  $$MonthlySettlementsTableFilterComposer({
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

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExpenseMinorUnits => $composableBuilder(
    column: $table.totalExpenseMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMeals => $composableBuilder(
    column: $table.totalMeals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealRateMinorUnits => $composableBuilder(
    column: $table.mealRateMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SettlementStatus, SettlementStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MessesTableFilterComposer get messId {
    final $$MessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableFilterComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> monthlySettlementMembersRefs(
    Expression<bool> Function($$MonthlySettlementMembersTableFilterComposer f)
    f,
  ) {
    final $$MonthlySettlementMembersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.monthlySettlementMembers,
          getReferencedColumn: (t) => t.settlementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MonthlySettlementMembersTableFilterComposer(
                $db: $db,
                $table: $db.monthlySettlementMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MonthlySettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlySettlementsTable> {
  $$MonthlySettlementsTableOrderingComposer({
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

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExpenseMinorUnits => $composableBuilder(
    column: $table.totalExpenseMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMeals => $composableBuilder(
    column: $table.totalMeals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealRateMinorUnits => $composableBuilder(
    column: $table.mealRateMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  $$MessesTableOrderingComposer get messId {
    final $$MessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableOrderingComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlySettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlySettlementsTable> {
  $$MonthlySettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get totalExpenseMinorUnits => $composableBuilder(
    column: $table.totalExpenseMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMeals => $composableBuilder(
    column: $table.totalMeals,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mealRateMinorUnits => $composableBuilder(
    column: $table.mealRateMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SettlementStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MessesTableAnnotationComposer get messId {
    final $$MessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messId,
      referencedTable: $db.messes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessesTableAnnotationComposer(
            $db: $db,
            $table: $db.messes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> monthlySettlementMembersRefs<T extends Object>(
    Expression<T> Function($$MonthlySettlementMembersTableAnnotationComposer a)
    f,
  ) {
    final $$MonthlySettlementMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.monthlySettlementMembers,
          getReferencedColumn: (t) => t.settlementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MonthlySettlementMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.monthlySettlementMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MonthlySettlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlySettlementsTable,
          MonthlySettlementRow,
          $$MonthlySettlementsTableFilterComposer,
          $$MonthlySettlementsTableOrderingComposer,
          $$MonthlySettlementsTableAnnotationComposer,
          $$MonthlySettlementsTableCreateCompanionBuilder,
          $$MonthlySettlementsTableUpdateCompanionBuilder,
          (MonthlySettlementRow, $$MonthlySettlementsTableReferences),
          MonthlySettlementRow,
          PrefetchHooks Function({
            bool messId,
            bool monthlySettlementMembersRefs,
          })
        > {
  $$MonthlySettlementsTableTableManager(
    _$AppDatabase db,
    $MonthlySettlementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlySettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlySettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlySettlementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messId = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> totalExpenseMinorUnits = const Value.absent(),
                Value<int> totalMeals = const Value.absent(),
                Value<int> mealRateMinorUnits = const Value.absent(),
                Value<SettlementStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlySettlementsCompanion(
                id: id,
                messId: messId,
                month: month,
                year: year,
                totalExpenseMinorUnits: totalExpenseMinorUnits,
                totalMeals: totalMeals,
                mealRateMinorUnits: mealRateMinorUnits,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messId,
                required int month,
                required int year,
                required int totalExpenseMinorUnits,
                required int totalMeals,
                required int mealRateMinorUnits,
                Value<SettlementStatus> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MonthlySettlementsCompanion.insert(
                id: id,
                messId: messId,
                month: month,
                year: year,
                totalExpenseMinorUnits: totalExpenseMinorUnits,
                totalMeals: totalMeals,
                mealRateMinorUnits: mealRateMinorUnits,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonthlySettlementsTable, MonthlySettlementRow>(
                    table,
                  ),
                  $$MonthlySettlementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({messId = false, monthlySettlementMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (monthlySettlementMembersRefs)
                      db.monthlySettlementMembers,
                  ],
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
                        if (messId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.messId,
                            referencedTable: $$MonthlySettlementsTableReferences
                                ._messIdTable(db),
                            referencedColumn:
                                $$MonthlySettlementsTableReferences
                                    ._messIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (monthlySettlementMembersRefs)
                        await $_getPrefetchedData<
                          MonthlySettlementRow,
                          $MonthlySettlementsTable,
                          MonthlySettlementMemberRow
                        >(
                          currentTable: table,
                          referencedTable: $$MonthlySettlementsTableReferences
                              ._monthlySettlementMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MonthlySettlementsTableReferences(
                                db,
                                table,
                                p0,
                              ).monthlySettlementMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.settlementId == item.id,
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

typedef $$MonthlySettlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlySettlementsTable,
      MonthlySettlementRow,
      $$MonthlySettlementsTableFilterComposer,
      $$MonthlySettlementsTableOrderingComposer,
      $$MonthlySettlementsTableAnnotationComposer,
      $$MonthlySettlementsTableCreateCompanionBuilder,
      $$MonthlySettlementsTableUpdateCompanionBuilder,
      (MonthlySettlementRow, $$MonthlySettlementsTableReferences),
      MonthlySettlementRow,
      PrefetchHooks Function({bool messId, bool monthlySettlementMembersRefs})
    >;
typedef $$MonthlySettlementMembersTableCreateCompanionBuilder =
    MonthlySettlementMembersCompanion Function({
      required String id,
      required String settlementId,
      required String memberId,
      required int mealCount,
      required int mealCostMinorUnits,
      required int paidAmountMinorUnits,
      required int balanceMinorUnits,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MonthlySettlementMembersTableUpdateCompanionBuilder =
    MonthlySettlementMembersCompanion Function({
      Value<String> id,
      Value<String> settlementId,
      Value<String> memberId,
      Value<int> mealCount,
      Value<int> mealCostMinorUnits,
      Value<int> paidAmountMinorUnits,
      Value<int> balanceMinorUnits,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MonthlySettlementMembersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MonthlySettlementMembersTable,
          MonthlySettlementMemberRow
        > {
  $$MonthlySettlementMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MonthlySettlementsTable _settlementIdTable(_$AppDatabase db) =>
      db.monthlySettlements.createAlias(
        'monthly_settlement_members__settlement_id__monthly_settlements__id',
      );

  $$MonthlySettlementsTableProcessedTableManager get settlementId {
    final $_column = $_itemColumn<String>('settlement_id')!;

    final manager = $$MonthlySettlementsTableTableManager(
      $_db,
      $_db.monthlySettlements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_settlementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MembersTable _memberIdTable(_$AppDatabase db) => db.members
      .createAlias('monthly_settlement_members__member_id__members__id');

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager(
      $_db,
      $_db.members,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MonthlySettlementMembersTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlySettlementMembersTable> {
  $$MonthlySettlementMembersTableFilterComposer({
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

  ColumnFilters<int> get mealCount => $composableBuilder(
    column: $table.mealCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealCostMinorUnits => $composableBuilder(
    column: $table.mealCostMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAmountMinorUnits => $composableBuilder(
    column: $table.paidAmountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceMinorUnits => $composableBuilder(
    column: $table.balanceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MonthlySettlementsTableFilterComposer get settlementId {
    final $$MonthlySettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementId,
      referencedTable: $db.monthlySettlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlySettlementsTableFilterComposer(
            $db: $db,
            $table: $db.monthlySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableFilterComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlySettlementMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlySettlementMembersTable> {
  $$MonthlySettlementMembersTableOrderingComposer({
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

  ColumnOrderings<int> get mealCount => $composableBuilder(
    column: $table.mealCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealCostMinorUnits => $composableBuilder(
    column: $table.mealCostMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAmountMinorUnits => $composableBuilder(
    column: $table.paidAmountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceMinorUnits => $composableBuilder(
    column: $table.balanceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MonthlySettlementsTableOrderingComposer get settlementId {
    final $$MonthlySettlementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementId,
      referencedTable: $db.monthlySettlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlySettlementsTableOrderingComposer(
            $db: $db,
            $table: $db.monthlySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableOrderingComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlySettlementMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlySettlementMembersTable> {
  $$MonthlySettlementMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mealCount =>
      $composableBuilder(column: $table.mealCount, builder: (column) => column);

  GeneratedColumn<int> get mealCostMinorUnits => $composableBuilder(
    column: $table.mealCostMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidAmountMinorUnits => $composableBuilder(
    column: $table.paidAmountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceMinorUnits => $composableBuilder(
    column: $table.balanceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MonthlySettlementsTableAnnotationComposer get settlementId {
    final $$MonthlySettlementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.settlementId,
          referencedTable: $db.monthlySettlements,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MonthlySettlementsTableAnnotationComposer(
                $db: $db,
                $table: $db.monthlySettlements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memberId,
      referencedTable: $db.members,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MembersTableAnnotationComposer(
            $db: $db,
            $table: $db.members,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlySettlementMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlySettlementMembersTable,
          MonthlySettlementMemberRow,
          $$MonthlySettlementMembersTableFilterComposer,
          $$MonthlySettlementMembersTableOrderingComposer,
          $$MonthlySettlementMembersTableAnnotationComposer,
          $$MonthlySettlementMembersTableCreateCompanionBuilder,
          $$MonthlySettlementMembersTableUpdateCompanionBuilder,
          (
            MonthlySettlementMemberRow,
            $$MonthlySettlementMembersTableReferences,
          ),
          MonthlySettlementMemberRow,
          PrefetchHooks Function({bool settlementId, bool memberId})
        > {
  $$MonthlySettlementMembersTableTableManager(
    _$AppDatabase db,
    $MonthlySettlementMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlySettlementMembersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MonthlySettlementMembersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MonthlySettlementMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> settlementId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> mealCount = const Value.absent(),
                Value<int> mealCostMinorUnits = const Value.absent(),
                Value<int> paidAmountMinorUnits = const Value.absent(),
                Value<int> balanceMinorUnits = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlySettlementMembersCompanion(
                id: id,
                settlementId: settlementId,
                memberId: memberId,
                mealCount: mealCount,
                mealCostMinorUnits: mealCostMinorUnits,
                paidAmountMinorUnits: paidAmountMinorUnits,
                balanceMinorUnits: balanceMinorUnits,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String settlementId,
                required String memberId,
                required int mealCount,
                required int mealCostMinorUnits,
                required int paidAmountMinorUnits,
                required int balanceMinorUnits,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MonthlySettlementMembersCompanion.insert(
                id: id,
                settlementId: settlementId,
                memberId: memberId,
                mealCount: mealCount,
                mealCostMinorUnits: mealCostMinorUnits,
                paidAmountMinorUnits: paidAmountMinorUnits,
                balanceMinorUnits: balanceMinorUnits,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $MonthlySettlementMembersTable,
                    MonthlySettlementMemberRow
                  >(table),
                  $$MonthlySettlementMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({settlementId = false, memberId = false}) {
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
                    if (settlementId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.settlementId,
                        referencedTable:
                            $$MonthlySettlementMembersTableReferences
                                ._settlementIdTable(db),
                        referencedColumn:
                            $$MonthlySettlementMembersTableReferences
                                ._settlementIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (memberId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memberId,
                        referencedTable:
                            $$MonthlySettlementMembersTableReferences
                                ._memberIdTable(db),
                        referencedColumn:
                            $$MonthlySettlementMembersTableReferences
                                ._memberIdTable(db)
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

typedef $$MonthlySettlementMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlySettlementMembersTable,
      MonthlySettlementMemberRow,
      $$MonthlySettlementMembersTableFilterComposer,
      $$MonthlySettlementMembersTableOrderingComposer,
      $$MonthlySettlementMembersTableAnnotationComposer,
      $$MonthlySettlementMembersTableCreateCompanionBuilder,
      $$MonthlySettlementMembersTableUpdateCompanionBuilder,
      (MonthlySettlementMemberRow, $$MonthlySettlementMembersTableReferences),
      MonthlySettlementMemberRow,
      PrefetchHooks Function({bool settlementId, bool memberId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessesTableTableManager get messes =>
      $$MessesTableTableManager(_db, _db.messes);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db, _db.mealEntries);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$MonthlySettlementsTableTableManager get monthlySettlements =>
      $$MonthlySettlementsTableTableManager(_db, _db.monthlySettlements);
  $$MonthlySettlementMembersTableTableManager get monthlySettlementMembers =>
      $$MonthlySettlementMembersTableTableManager(
        _db,
        _db.monthlySettlementMembers,
      );
}
