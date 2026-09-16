// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalStateRowsTable extends LocalStateRows
    with TableInfo<$LocalStateRowsTable, LocalStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStateRowsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'local_state_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStateRow> instance, {
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
  LocalStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStateRow(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $LocalStateRowsTable createAlias(String alias) {
    return $LocalStateRowsTable(attachedDatabase, alias);
  }
}

class LocalStateRow extends DataClass implements Insertable<LocalStateRow> {
  final String key;
  final String value;
  const LocalStateRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalStateRowsCompanion toCompanion(bool nullToAbsent) {
    return LocalStateRowsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStateRow(
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

  LocalStateRow copyWith({String? key, String? value}) =>
      LocalStateRow(key: key ?? this.key, value: value ?? this.value);
  LocalStateRow copyWithCompanion(LocalStateRowsCompanion data) {
    return LocalStateRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStateRow(')
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
      (other is LocalStateRow &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalStateRowsCompanion extends UpdateCompanion<LocalStateRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalStateRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStateRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalStateRow> custom({
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

  LocalStateRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalStateRowsCompanion(
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
    return (StringBuffer('LocalStateRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProjectsTable extends LocalProjects
    with TableInfo<$LocalProjectsTable, LocalProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organisationIdMeta = const VerificationMeta(
    'organisationId',
  );
  @override
  late final GeneratedColumn<String> organisationId = GeneratedColumn<String>(
    'organisation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectTypeMeta = const VerificationMeta(
    'projectType',
  );
  @override
  late final GeneratedColumn<String> projectType = GeneratedColumn<String>(
    'project_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
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
  static const VerificationMeta _siteMeta = const VerificationMeta('site');
  @override
  late final GeneratedColumn<String> site = GeneratedColumn<String>(
    'site',
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
  static const VerificationMeta _preambleMeta = const VerificationMeta(
    'preamble',
  );
  @override
  late final GeneratedColumn<String> preamble = GeneratedColumn<String>(
    'preamble',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conclusionMeta = const VerificationMeta(
    'conclusion',
  );
  @override
  late final GeneratedColumn<String> conclusion = GeneratedColumn<String>(
    'conclusion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organisationId,
    projectType,
    number,
    name,
    site,
    createdAt,
    preamble,
    conclusion,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organisation_id')) {
      context.handle(
        _organisationIdMeta,
        organisationId.isAcceptableOrUnknown(
          data['organisation_id']!,
          _organisationIdMeta,
        ),
      );
    }
    if (data.containsKey('project_type')) {
      context.handle(
        _projectTypeMeta,
        projectType.isAcceptableOrUnknown(
          data['project_type']!,
          _projectTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_projectTypeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('site')) {
      context.handle(
        _siteMeta,
        site.isAcceptableOrUnknown(data['site']!, _siteMeta),
      );
    } else if (isInserting) {
      context.missing(_siteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('preamble')) {
      context.handle(
        _preambleMeta,
        preamble.isAcceptableOrUnknown(data['preamble']!, _preambleMeta),
      );
    } else if (isInserting) {
      context.missing(_preambleMeta);
    }
    if (data.containsKey('conclusion')) {
      context.handle(
        _conclusionMeta,
        conclusion.isAcceptableOrUnknown(data['conclusion']!, _conclusionMeta),
      );
    } else if (isInserting) {
      context.missing(_conclusionMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProject(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      organisationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organisation_id'],
      ),
      projectType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}project_type'],
          )!,
      number:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}number'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      site:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}site'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      preamble:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}preamble'],
          )!,
      conclusion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}conclusion'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $LocalProjectsTable createAlias(String alias) {
    return $LocalProjectsTable(attachedDatabase, alias);
  }
}

class LocalProject extends DataClass implements Insertable<LocalProject> {
  final String id;
  final String? organisationId;
  final String projectType;
  final String number;
  final String name;
  final String site;
  final DateTime createdAt;
  final String preamble;
  final String conclusion;
  final int sortOrder;
  const LocalProject({
    required this.id,
    this.organisationId,
    required this.projectType,
    required this.number,
    required this.name,
    required this.site,
    required this.createdAt,
    required this.preamble,
    required this.conclusion,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || organisationId != null) {
      map['organisation_id'] = Variable<String>(organisationId);
    }
    map['project_type'] = Variable<String>(projectType);
    map['number'] = Variable<String>(number);
    map['name'] = Variable<String>(name);
    map['site'] = Variable<String>(site);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['preamble'] = Variable<String>(preamble);
    map['conclusion'] = Variable<String>(conclusion);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalProjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalProjectsCompanion(
      id: Value(id),
      organisationId:
          organisationId == null && nullToAbsent
              ? const Value.absent()
              : Value(organisationId),
      projectType: Value(projectType),
      number: Value(number),
      name: Value(name),
      site: Value(site),
      createdAt: Value(createdAt),
      preamble: Value(preamble),
      conclusion: Value(conclusion),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProject(
      id: serializer.fromJson<String>(json['id']),
      organisationId: serializer.fromJson<String?>(json['organisationId']),
      projectType: serializer.fromJson<String>(json['projectType']),
      number: serializer.fromJson<String>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      site: serializer.fromJson<String>(json['site']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      preamble: serializer.fromJson<String>(json['preamble']),
      conclusion: serializer.fromJson<String>(json['conclusion']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organisationId': serializer.toJson<String?>(organisationId),
      'projectType': serializer.toJson<String>(projectType),
      'number': serializer.toJson<String>(number),
      'name': serializer.toJson<String>(name),
      'site': serializer.toJson<String>(site),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'preamble': serializer.toJson<String>(preamble),
      'conclusion': serializer.toJson<String>(conclusion),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalProject copyWith({
    String? id,
    Value<String?> organisationId = const Value.absent(),
    String? projectType,
    String? number,
    String? name,
    String? site,
    DateTime? createdAt,
    String? preamble,
    String? conclusion,
    int? sortOrder,
  }) => LocalProject(
    id: id ?? this.id,
    organisationId:
        organisationId.present ? organisationId.value : this.organisationId,
    projectType: projectType ?? this.projectType,
    number: number ?? this.number,
    name: name ?? this.name,
    site: site ?? this.site,
    createdAt: createdAt ?? this.createdAt,
    preamble: preamble ?? this.preamble,
    conclusion: conclusion ?? this.conclusion,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalProject copyWithCompanion(LocalProjectsCompanion data) {
    return LocalProject(
      id: data.id.present ? data.id.value : this.id,
      organisationId:
          data.organisationId.present
              ? data.organisationId.value
              : this.organisationId,
      projectType:
          data.projectType.present ? data.projectType.value : this.projectType,
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      site: data.site.present ? data.site.value : this.site,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      preamble: data.preamble.present ? data.preamble.value : this.preamble,
      conclusion:
          data.conclusion.present ? data.conclusion.value : this.conclusion,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProject(')
          ..write('id: $id, ')
          ..write('organisationId: $organisationId, ')
          ..write('projectType: $projectType, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('site: $site, ')
          ..write('createdAt: $createdAt, ')
          ..write('preamble: $preamble, ')
          ..write('conclusion: $conclusion, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organisationId,
    projectType,
    number,
    name,
    site,
    createdAt,
    preamble,
    conclusion,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProject &&
          other.id == this.id &&
          other.organisationId == this.organisationId &&
          other.projectType == this.projectType &&
          other.number == this.number &&
          other.name == this.name &&
          other.site == this.site &&
          other.createdAt == this.createdAt &&
          other.preamble == this.preamble &&
          other.conclusion == this.conclusion &&
          other.sortOrder == this.sortOrder);
}

class LocalProjectsCompanion extends UpdateCompanion<LocalProject> {
  final Value<String> id;
  final Value<String?> organisationId;
  final Value<String> projectType;
  final Value<String> number;
  final Value<String> name;
  final Value<String> site;
  final Value<DateTime> createdAt;
  final Value<String> preamble;
  final Value<String> conclusion;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalProjectsCompanion({
    this.id = const Value.absent(),
    this.organisationId = const Value.absent(),
    this.projectType = const Value.absent(),
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.site = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.preamble = const Value.absent(),
    this.conclusion = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProjectsCompanion.insert({
    required String id,
    this.organisationId = const Value.absent(),
    required String projectType,
    required String number,
    required String name,
    required String site,
    required DateTime createdAt,
    required String preamble,
    required String conclusion,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectType = Value(projectType),
       number = Value(number),
       name = Value(name),
       site = Value(site),
       createdAt = Value(createdAt),
       preamble = Value(preamble),
       conclusion = Value(conclusion),
       sortOrder = Value(sortOrder);
  static Insertable<LocalProject> custom({
    Expression<String>? id,
    Expression<String>? organisationId,
    Expression<String>? projectType,
    Expression<String>? number,
    Expression<String>? name,
    Expression<String>? site,
    Expression<DateTime>? createdAt,
    Expression<String>? preamble,
    Expression<String>? conclusion,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organisationId != null) 'organisation_id': organisationId,
      if (projectType != null) 'project_type': projectType,
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (site != null) 'site': site,
      if (createdAt != null) 'created_at': createdAt,
      if (preamble != null) 'preamble': preamble,
      if (conclusion != null) 'conclusion': conclusion,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProjectsCompanion copyWith({
    Value<String>? id,
    Value<String?>? organisationId,
    Value<String>? projectType,
    Value<String>? number,
    Value<String>? name,
    Value<String>? site,
    Value<DateTime>? createdAt,
    Value<String>? preamble,
    Value<String>? conclusion,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalProjectsCompanion(
      id: id ?? this.id,
      organisationId: organisationId ?? this.organisationId,
      projectType: projectType ?? this.projectType,
      number: number ?? this.number,
      name: name ?? this.name,
      site: site ?? this.site,
      createdAt: createdAt ?? this.createdAt,
      preamble: preamble ?? this.preamble,
      conclusion: conclusion ?? this.conclusion,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organisationId.present) {
      map['organisation_id'] = Variable<String>(organisationId.value);
    }
    if (projectType.present) {
      map['project_type'] = Variable<String>(projectType.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (site.present) {
      map['site'] = Variable<String>(site.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (preamble.present) {
      map['preamble'] = Variable<String>(preamble.value);
    }
    if (conclusion.present) {
      map['conclusion'] = Variable<String>(conclusion.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProjectsCompanion(')
          ..write('id: $id, ')
          ..write('organisationId: $organisationId, ')
          ..write('projectType: $projectType, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('site: $site, ')
          ..write('createdAt: $createdAt, ')
          ..write('preamble: $preamble, ')
          ..write('conclusion: $conclusion, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFoldersTable extends LocalFolders
    with TableInfo<$LocalFoldersTable, LocalFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    parentId,
    name,
    kind,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFolder(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      projectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}project_id'],
          )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      kind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}kind'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $LocalFoldersTable createAlias(String alias) {
    return $LocalFoldersTable(attachedDatabase, alias);
  }
}

class LocalFolder extends DataClass implements Insertable<LocalFolder> {
  final String id;
  final String projectId;
  final String? parentId;
  final String name;
  final String kind;
  final int sortOrder;
  const LocalFolder({
    required this.id,
    required this.projectId,
    this.parentId,
    required this.name,
    required this.kind,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalFoldersCompanion toCompanion(bool nullToAbsent) {
    return LocalFoldersCompanion(
      id: Value(id),
      projectId: Value(projectId),
      parentId:
          parentId == null && nullToAbsent
              ? const Value.absent()
              : Value(parentId),
      name: Value(name),
      kind: Value(kind),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFolder(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalFolder copyWith({
    String? id,
    String? projectId,
    Value<String?> parentId = const Value.absent(),
    String? name,
    String? kind,
    int? sortOrder,
  }) => LocalFolder(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalFolder copyWithCompanion(LocalFoldersCompanion data) {
    return LocalFolder(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFolder(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, parentId, name, kind, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFolder &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.sortOrder == this.sortOrder);
}

class LocalFoldersCompanion extends UpdateCompanion<LocalFolder> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalFoldersCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFoldersCompanion.insert({
    required String id,
    required String projectId,
    this.parentId = const Value.absent(),
    required String name,
    required String kind,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       name = Value(name),
       kind = Value(kind),
       sortOrder = Value(sortOrder);
  static Insertable<LocalFolder> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String?>? parentId,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalFoldersCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFoldersCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRoomsTable extends LocalRooms
    with TableInfo<$LocalRoomsTable, LocalRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inspectionIdMeta = const VerificationMeta(
    'inspectionId',
  );
  @override
  late final GeneratedColumn<String> inspectionId = GeneratedColumn<String>(
    'inspection_id',
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
  static const VerificationMeta _sectionNameMeta = const VerificationMeta(
    'sectionName',
  );
  @override
  late final GeneratedColumn<String> sectionName = GeneratedColumn<String>(
    'section_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inspectedAtMeta = const VerificationMeta(
    'inspectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> inspectedAt = GeneratedColumn<DateTime>(
    'inspected_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noIssuesMeta = const VerificationMeta(
    'noIssues',
  );
  @override
  late final GeneratedColumn<bool> noIssues = GeneratedColumn<bool>(
    'no_issues',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_issues" IN (0, 1))',
    ),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    folderId,
    inspectionId,
    name,
    sectionName,
    inspectedAt,
    noIssues,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('inspection_id')) {
      context.handle(
        _inspectionIdMeta,
        inspectionId.isAcceptableOrUnknown(
          data['inspection_id']!,
          _inspectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('section_name')) {
      context.handle(
        _sectionNameMeta,
        sectionName.isAcceptableOrUnknown(
          data['section_name']!,
          _sectionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionNameMeta);
    }
    if (data.containsKey('inspected_at')) {
      context.handle(
        _inspectedAtMeta,
        inspectedAt.isAcceptableOrUnknown(
          data['inspected_at']!,
          _inspectedAtMeta,
        ),
      );
    }
    if (data.containsKey('no_issues')) {
      context.handle(
        _noIssuesMeta,
        noIssues.isAcceptableOrUnknown(data['no_issues']!, _noIssuesMeta),
      );
    } else if (isInserting) {
      context.missing(_noIssuesMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRoom(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      projectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}project_id'],
          )!,
      folderId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}folder_id'],
          )!,
      inspectionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}inspection_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      sectionName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}section_name'],
          )!,
      inspectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inspected_at'],
      ),
      noIssues:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}no_issues'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $LocalRoomsTable createAlias(String alias) {
    return $LocalRoomsTable(attachedDatabase, alias);
  }
}

class LocalRoom extends DataClass implements Insertable<LocalRoom> {
  final String id;
  final String projectId;
  final String folderId;
  final String inspectionId;
  final String name;
  final String sectionName;
  final DateTime? inspectedAt;
  final bool noIssues;
  final int sortOrder;
  const LocalRoom({
    required this.id,
    required this.projectId,
    required this.folderId,
    required this.inspectionId,
    required this.name,
    required this.sectionName,
    this.inspectedAt,
    required this.noIssues,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['folder_id'] = Variable<String>(folderId);
    map['inspection_id'] = Variable<String>(inspectionId);
    map['name'] = Variable<String>(name);
    map['section_name'] = Variable<String>(sectionName);
    if (!nullToAbsent || inspectedAt != null) {
      map['inspected_at'] = Variable<DateTime>(inspectedAt);
    }
    map['no_issues'] = Variable<bool>(noIssues);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalRoomsCompanion toCompanion(bool nullToAbsent) {
    return LocalRoomsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      folderId: Value(folderId),
      inspectionId: Value(inspectionId),
      name: Value(name),
      sectionName: Value(sectionName),
      inspectedAt:
          inspectedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(inspectedAt),
      noIssues: Value(noIssues),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRoom(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      folderId: serializer.fromJson<String>(json['folderId']),
      inspectionId: serializer.fromJson<String>(json['inspectionId']),
      name: serializer.fromJson<String>(json['name']),
      sectionName: serializer.fromJson<String>(json['sectionName']),
      inspectedAt: serializer.fromJson<DateTime?>(json['inspectedAt']),
      noIssues: serializer.fromJson<bool>(json['noIssues']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'folderId': serializer.toJson<String>(folderId),
      'inspectionId': serializer.toJson<String>(inspectionId),
      'name': serializer.toJson<String>(name),
      'sectionName': serializer.toJson<String>(sectionName),
      'inspectedAt': serializer.toJson<DateTime?>(inspectedAt),
      'noIssues': serializer.toJson<bool>(noIssues),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalRoom copyWith({
    String? id,
    String? projectId,
    String? folderId,
    String? inspectionId,
    String? name,
    String? sectionName,
    Value<DateTime?> inspectedAt = const Value.absent(),
    bool? noIssues,
    int? sortOrder,
  }) => LocalRoom(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    folderId: folderId ?? this.folderId,
    inspectionId: inspectionId ?? this.inspectionId,
    name: name ?? this.name,
    sectionName: sectionName ?? this.sectionName,
    inspectedAt: inspectedAt.present ? inspectedAt.value : this.inspectedAt,
    noIssues: noIssues ?? this.noIssues,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalRoom copyWithCompanion(LocalRoomsCompanion data) {
    return LocalRoom(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      inspectionId:
          data.inspectionId.present
              ? data.inspectionId.value
              : this.inspectionId,
      name: data.name.present ? data.name.value : this.name,
      sectionName:
          data.sectionName.present ? data.sectionName.value : this.sectionName,
      inspectedAt:
          data.inspectedAt.present ? data.inspectedAt.value : this.inspectedAt,
      noIssues: data.noIssues.present ? data.noIssues.value : this.noIssues,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoom(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('folderId: $folderId, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('name: $name, ')
          ..write('sectionName: $sectionName, ')
          ..write('inspectedAt: $inspectedAt, ')
          ..write('noIssues: $noIssues, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    folderId,
    inspectionId,
    name,
    sectionName,
    inspectedAt,
    noIssues,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRoom &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.folderId == this.folderId &&
          other.inspectionId == this.inspectionId &&
          other.name == this.name &&
          other.sectionName == this.sectionName &&
          other.inspectedAt == this.inspectedAt &&
          other.noIssues == this.noIssues &&
          other.sortOrder == this.sortOrder);
}

class LocalRoomsCompanion extends UpdateCompanion<LocalRoom> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> folderId;
  final Value<String> inspectionId;
  final Value<String> name;
  final Value<String> sectionName;
  final Value<DateTime?> inspectedAt;
  final Value<bool> noIssues;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalRoomsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.inspectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.sectionName = const Value.absent(),
    this.inspectedAt = const Value.absent(),
    this.noIssues = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRoomsCompanion.insert({
    required String id,
    required String projectId,
    required String folderId,
    required String inspectionId,
    required String name,
    required String sectionName,
    this.inspectedAt = const Value.absent(),
    required bool noIssues,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       folderId = Value(folderId),
       inspectionId = Value(inspectionId),
       name = Value(name),
       sectionName = Value(sectionName),
       noIssues = Value(noIssues),
       sortOrder = Value(sortOrder);
  static Insertable<LocalRoom> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? folderId,
    Expression<String>? inspectionId,
    Expression<String>? name,
    Expression<String>? sectionName,
    Expression<DateTime>? inspectedAt,
    Expression<bool>? noIssues,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (folderId != null) 'folder_id': folderId,
      if (inspectionId != null) 'inspection_id': inspectionId,
      if (name != null) 'name': name,
      if (sectionName != null) 'section_name': sectionName,
      if (inspectedAt != null) 'inspected_at': inspectedAt,
      if (noIssues != null) 'no_issues': noIssues,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? folderId,
    Value<String>? inspectionId,
    Value<String>? name,
    Value<String>? sectionName,
    Value<DateTime?>? inspectedAt,
    Value<bool>? noIssues,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalRoomsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      folderId: folderId ?? this.folderId,
      inspectionId: inspectionId ?? this.inspectionId,
      name: name ?? this.name,
      sectionName: sectionName ?? this.sectionName,
      inspectedAt: inspectedAt ?? this.inspectedAt,
      noIssues: noIssues ?? this.noIssues,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (inspectionId.present) {
      map['inspection_id'] = Variable<String>(inspectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sectionName.present) {
      map['section_name'] = Variable<String>(sectionName.value);
    }
    if (inspectedAt.present) {
      map['inspected_at'] = Variable<DateTime>(inspectedAt.value);
    }
    if (noIssues.present) {
      map['no_issues'] = Variable<bool>(noIssues.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoomsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('folderId: $folderId, ')
          ..write('inspectionId: $inspectionId, ')
          ..write('name: $name, ')
          ..write('sectionName: $sectionName, ')
          ..write('inspectedAt: $inspectedAt, ')
          ..write('noIssues: $noIssues, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFindingsTable extends LocalFindings
    with TableInfo<$LocalFindingsTable, LocalFinding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendationMeta = const VerificationMeta(
    'recommendation',
  );
  @override
  late final GeneratedColumn<String> recommendation = GeneratedColumn<String>(
    'recommendation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    type,
    location,
    severity,
    notes,
    recommendation,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_findings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFinding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('recommendation')) {
      context.handle(
        _recommendationMeta,
        recommendation.isAcceptableOrUnknown(
          data['recommendation']!,
          _recommendationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendationMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFinding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFinding(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      roomId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}room_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      location:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}location'],
          )!,
      severity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}severity'],
          )!,
      notes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}notes'],
          )!,
      recommendation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}recommendation'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $LocalFindingsTable createAlias(String alias) {
    return $LocalFindingsTable(attachedDatabase, alias);
  }
}

class LocalFinding extends DataClass implements Insertable<LocalFinding> {
  final String id;
  final String roomId;
  final String type;
  final String location;
  final String severity;
  final String notes;
  final String recommendation;
  final int sortOrder;
  const LocalFinding({
    required this.id,
    required this.roomId,
    required this.type,
    required this.location,
    required this.severity,
    required this.notes,
    required this.recommendation,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['type'] = Variable<String>(type);
    map['location'] = Variable<String>(location);
    map['severity'] = Variable<String>(severity);
    map['notes'] = Variable<String>(notes);
    map['recommendation'] = Variable<String>(recommendation);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalFindingsCompanion toCompanion(bool nullToAbsent) {
    return LocalFindingsCompanion(
      id: Value(id),
      roomId: Value(roomId),
      type: Value(type),
      location: Value(location),
      severity: Value(severity),
      notes: Value(notes),
      recommendation: Value(recommendation),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalFinding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFinding(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      type: serializer.fromJson<String>(json['type']),
      location: serializer.fromJson<String>(json['location']),
      severity: serializer.fromJson<String>(json['severity']),
      notes: serializer.fromJson<String>(json['notes']),
      recommendation: serializer.fromJson<String>(json['recommendation']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'type': serializer.toJson<String>(type),
      'location': serializer.toJson<String>(location),
      'severity': serializer.toJson<String>(severity),
      'notes': serializer.toJson<String>(notes),
      'recommendation': serializer.toJson<String>(recommendation),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalFinding copyWith({
    String? id,
    String? roomId,
    String? type,
    String? location,
    String? severity,
    String? notes,
    String? recommendation,
    int? sortOrder,
  }) => LocalFinding(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    type: type ?? this.type,
    location: location ?? this.location,
    severity: severity ?? this.severity,
    notes: notes ?? this.notes,
    recommendation: recommendation ?? this.recommendation,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalFinding copyWithCompanion(LocalFindingsCompanion data) {
    return LocalFinding(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      type: data.type.present ? data.type.value : this.type,
      location: data.location.present ? data.location.value : this.location,
      severity: data.severity.present ? data.severity.value : this.severity,
      notes: data.notes.present ? data.notes.value : this.notes,
      recommendation:
          data.recommendation.present
              ? data.recommendation.value
              : this.recommendation,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFinding(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('type: $type, ')
          ..write('location: $location, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes, ')
          ..write('recommendation: $recommendation, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomId,
    type,
    location,
    severity,
    notes,
    recommendation,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFinding &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.type == this.type &&
          other.location == this.location &&
          other.severity == this.severity &&
          other.notes == this.notes &&
          other.recommendation == this.recommendation &&
          other.sortOrder == this.sortOrder);
}

class LocalFindingsCompanion extends UpdateCompanion<LocalFinding> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> type;
  final Value<String> location;
  final Value<String> severity;
  final Value<String> notes;
  final Value<String> recommendation;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalFindingsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.type = const Value.absent(),
    this.location = const Value.absent(),
    this.severity = const Value.absent(),
    this.notes = const Value.absent(),
    this.recommendation = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFindingsCompanion.insert({
    required String id,
    required String roomId,
    required String type,
    required String location,
    required String severity,
    required String notes,
    required String recommendation,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomId = Value(roomId),
       type = Value(type),
       location = Value(location),
       severity = Value(severity),
       notes = Value(notes),
       recommendation = Value(recommendation),
       sortOrder = Value(sortOrder);
  static Insertable<LocalFinding> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? type,
    Expression<String>? location,
    Expression<String>? severity,
    Expression<String>? notes,
    Expression<String>? recommendation,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (type != null) 'type': type,
      if (location != null) 'location': location,
      if (severity != null) 'severity': severity,
      if (notes != null) 'notes': notes,
      if (recommendation != null) 'recommendation': recommendation,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFindingsCompanion copyWith({
    Value<String>? id,
    Value<String>? roomId,
    Value<String>? type,
    Value<String>? location,
    Value<String>? severity,
    Value<String>? notes,
    Value<String>? recommendation,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalFindingsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      type: type ?? this.type,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      recommendation: recommendation ?? this.recommendation,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recommendation.present) {
      map['recommendation'] = Variable<String>(recommendation.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFindingsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('type: $type, ')
          ..write('location: $location, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes, ')
          ..write('recommendation: $recommendation, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPhotosTable extends LocalPhotos
    with TableInfo<$LocalPhotosTable, LocalPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerKindMeta = const VerificationMeta(
    'ownerKind',
  );
  @override
  late final GeneratedColumn<String> ownerKind = GeneratedColumn<String>(
    'owner_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
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
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePathMeta = const VerificationMeta(
    'remotePath',
  );
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
    'remote_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerKind,
    ownerId,
    name,
    bytes,
    remotePath,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_kind')) {
      context.handle(
        _ownerKindMeta,
        ownerKind.isAcceptableOrUnknown(data['owner_kind']!, _ownerKindMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKindMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('remote_path')) {
      context.handle(
        _remotePathMeta,
        remotePath.isAcceptableOrUnknown(data['remote_path']!, _remotePathMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPhoto(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      ownerKind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_kind'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      bytes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}bytes'],
          )!,
      remotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_path'],
      ),
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
    );
  }

  @override
  $LocalPhotosTable createAlias(String alias) {
    return $LocalPhotosTable(attachedDatabase, alias);
  }
}

class LocalPhoto extends DataClass implements Insertable<LocalPhoto> {
  final String id;
  final String ownerKind;
  final String ownerId;
  final String name;
  final Uint8List bytes;
  final String? remotePath;
  final int sortOrder;
  const LocalPhoto({
    required this.id,
    required this.ownerKind,
    required this.ownerId,
    required this.name,
    required this.bytes,
    this.remotePath,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_kind'] = Variable<String>(ownerKind);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['bytes'] = Variable<Uint8List>(bytes);
    if (!nullToAbsent || remotePath != null) {
      map['remote_path'] = Variable<String>(remotePath);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalPhotosCompanion toCompanion(bool nullToAbsent) {
    return LocalPhotosCompanion(
      id: Value(id),
      ownerKind: Value(ownerKind),
      ownerId: Value(ownerId),
      name: Value(name),
      bytes: Value(bytes),
      remotePath:
          remotePath == null && nullToAbsent
              ? const Value.absent()
              : Value(remotePath),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPhoto(
      id: serializer.fromJson<String>(json['id']),
      ownerKind: serializer.fromJson<String>(json['ownerKind']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      remotePath: serializer.fromJson<String?>(json['remotePath']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerKind': serializer.toJson<String>(ownerKind),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'remotePath': serializer.toJson<String?>(remotePath),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalPhoto copyWith({
    String? id,
    String? ownerKind,
    String? ownerId,
    String? name,
    Uint8List? bytes,
    Value<String?> remotePath = const Value.absent(),
    int? sortOrder,
  }) => LocalPhoto(
    id: id ?? this.id,
    ownerKind: ownerKind ?? this.ownerKind,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    bytes: bytes ?? this.bytes,
    remotePath: remotePath.present ? remotePath.value : this.remotePath,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalPhoto copyWithCompanion(LocalPhotosCompanion data) {
    return LocalPhoto(
      id: data.id.present ? data.id.value : this.id,
      ownerKind: data.ownerKind.present ? data.ownerKind.value : this.ownerKind,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      remotePath:
          data.remotePath.present ? data.remotePath.value : this.remotePath,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPhoto(')
          ..write('id: $id, ')
          ..write('ownerKind: $ownerKind, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('bytes: $bytes, ')
          ..write('remotePath: $remotePath, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerKind,
    ownerId,
    name,
    $driftBlobEquality.hash(bytes),
    remotePath,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPhoto &&
          other.id == this.id &&
          other.ownerKind == this.ownerKind &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.remotePath == this.remotePath &&
          other.sortOrder == this.sortOrder);
}

class LocalPhotosCompanion extends UpdateCompanion<LocalPhoto> {
  final Value<String> id;
  final Value<String> ownerKind;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<Uint8List> bytes;
  final Value<String?> remotePath;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalPhotosCompanion({
    this.id = const Value.absent(),
    this.ownerKind = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.bytes = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPhotosCompanion.insert({
    required String id,
    required String ownerKind,
    required String ownerId,
    required String name,
    required Uint8List bytes,
    this.remotePath = const Value.absent(),
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerKind = Value(ownerKind),
       ownerId = Value(ownerId),
       name = Value(name),
       bytes = Value(bytes),
       sortOrder = Value(sortOrder);
  static Insertable<LocalPhoto> custom({
    Expression<String>? id,
    Expression<String>? ownerKind,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<Uint8List>? bytes,
    Expression<String>? remotePath,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerKind != null) 'owner_kind': ownerKind,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (bytes != null) 'bytes': bytes,
      if (remotePath != null) 'remote_path': remotePath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerKind,
    Value<String>? ownerId,
    Value<String>? name,
    Value<Uint8List>? bytes,
    Value<String?>? remotePath,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalPhotosCompanion(
      id: id ?? this.id,
      ownerKind: ownerKind ?? this.ownerKind,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      bytes: bytes ?? this.bytes,
      remotePath: remotePath ?? this.remotePath,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerKind.present) {
      map['owner_kind'] = Variable<String>(ownerKind.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPhotosCompanion(')
          ..write('id: $id, ')
          ..write('ownerKind: $ownerKind, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('bytes: $bytes, ')
          ..write('remotePath: $remotePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      payload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload'],
          )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final String id;
  final String payload;
  const LocalProfile({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(id: Value(id), payload: Value(payload));
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  LocalProfile copyWith({String? id, String? payload}) =>
      LocalProfile(id: id ?? this.id, payload: payload ?? this.payload);
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.id == this.id &&
          other.payload == this.payload);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<LocalProfile> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPendingDeletesTable extends LocalPendingDeletes
    with TableInfo<$LocalPendingDeletesTable, LocalPendingDelete> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPendingDeletesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _objectPathMeta = const VerificationMeta(
    'objectPath',
  );
  @override
  late final GeneratedColumn<String> objectPath = GeneratedColumn<String>(
    'object_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    targetTable,
    remoteId,
    bucket,
    objectPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pending_deletes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPendingDelete> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
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
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    }
    if (data.containsKey('object_path')) {
      context.handle(
        _objectPathMeta,
        objectPath.isAcceptableOrUnknown(data['object_path']!, _objectPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  LocalPendingDelete map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPendingDelete(
      rowId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}row_id'],
          )!,
      targetTable:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}target_table'],
          )!,
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      ),
      objectPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_path'],
      ),
    );
  }

  @override
  $LocalPendingDeletesTable createAlias(String alias) {
    return $LocalPendingDeletesTable(attachedDatabase, alias);
  }
}

class LocalPendingDelete extends DataClass
    implements Insertable<LocalPendingDelete> {
  final int rowId;
  final String targetTable;
  final String remoteId;
  final String? bucket;
  final String? objectPath;
  const LocalPendingDelete({
    required this.rowId,
    required this.targetTable,
    required this.remoteId,
    this.bucket,
    this.objectPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['target_table'] = Variable<String>(targetTable);
    map['remote_id'] = Variable<String>(remoteId);
    if (!nullToAbsent || bucket != null) {
      map['bucket'] = Variable<String>(bucket);
    }
    if (!nullToAbsent || objectPath != null) {
      map['object_path'] = Variable<String>(objectPath);
    }
    return map;
  }

  LocalPendingDeletesCompanion toCompanion(bool nullToAbsent) {
    return LocalPendingDeletesCompanion(
      rowId: Value(rowId),
      targetTable: Value(targetTable),
      remoteId: Value(remoteId),
      bucket:
          bucket == null && nullToAbsent ? const Value.absent() : Value(bucket),
      objectPath:
          objectPath == null && nullToAbsent
              ? const Value.absent()
              : Value(objectPath),
    );
  }

  factory LocalPendingDelete.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPendingDelete(
      rowId: serializer.fromJson<int>(json['rowId']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      bucket: serializer.fromJson<String?>(json['bucket']),
      objectPath: serializer.fromJson<String?>(json['objectPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'targetTable': serializer.toJson<String>(targetTable),
      'remoteId': serializer.toJson<String>(remoteId),
      'bucket': serializer.toJson<String?>(bucket),
      'objectPath': serializer.toJson<String?>(objectPath),
    };
  }

  LocalPendingDelete copyWith({
    int? rowId,
    String? targetTable,
    String? remoteId,
    Value<String?> bucket = const Value.absent(),
    Value<String?> objectPath = const Value.absent(),
  }) => LocalPendingDelete(
    rowId: rowId ?? this.rowId,
    targetTable: targetTable ?? this.targetTable,
    remoteId: remoteId ?? this.remoteId,
    bucket: bucket.present ? bucket.value : this.bucket,
    objectPath: objectPath.present ? objectPath.value : this.objectPath,
  );
  LocalPendingDelete copyWithCompanion(LocalPendingDeletesCompanion data) {
    return LocalPendingDelete(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      targetTable:
          data.targetTable.present ? data.targetTable.value : this.targetTable,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      objectPath:
          data.objectPath.present ? data.objectPath.value : this.objectPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPendingDelete(')
          ..write('rowId: $rowId, ')
          ..write('targetTable: $targetTable, ')
          ..write('remoteId: $remoteId, ')
          ..write('bucket: $bucket, ')
          ..write('objectPath: $objectPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rowId, targetTable, remoteId, bucket, objectPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPendingDelete &&
          other.rowId == this.rowId &&
          other.targetTable == this.targetTable &&
          other.remoteId == this.remoteId &&
          other.bucket == this.bucket &&
          other.objectPath == this.objectPath);
}

class LocalPendingDeletesCompanion extends UpdateCompanion<LocalPendingDelete> {
  final Value<int> rowId;
  final Value<String> targetTable;
  final Value<String> remoteId;
  final Value<String?> bucket;
  final Value<String?> objectPath;
  const LocalPendingDeletesCompanion({
    this.rowId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.bucket = const Value.absent(),
    this.objectPath = const Value.absent(),
  });
  LocalPendingDeletesCompanion.insert({
    this.rowId = const Value.absent(),
    required String targetTable,
    required String remoteId,
    this.bucket = const Value.absent(),
    this.objectPath = const Value.absent(),
  }) : targetTable = Value(targetTable),
       remoteId = Value(remoteId);
  static Insertable<LocalPendingDelete> custom({
    Expression<int>? rowId,
    Expression<String>? targetTable,
    Expression<String>? remoteId,
    Expression<String>? bucket,
    Expression<String>? objectPath,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (targetTable != null) 'target_table': targetTable,
      if (remoteId != null) 'remote_id': remoteId,
      if (bucket != null) 'bucket': bucket,
      if (objectPath != null) 'object_path': objectPath,
    });
  }

  LocalPendingDeletesCompanion copyWith({
    Value<int>? rowId,
    Value<String>? targetTable,
    Value<String>? remoteId,
    Value<String?>? bucket,
    Value<String?>? objectPath,
  }) {
    return LocalPendingDeletesCompanion(
      rowId: rowId ?? this.rowId,
      targetTable: targetTable ?? this.targetTable,
      remoteId: remoteId ?? this.remoteId,
      bucket: bucket ?? this.bucket,
      objectPath: objectPath ?? this.objectPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (objectPath.present) {
      map['object_path'] = Variable<String>(objectPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPendingDeletesCompanion(')
          ..write('rowId: $rowId, ')
          ..write('targetTable: $targetTable, ')
          ..write('remoteId: $remoteId, ')
          ..write('bucket: $bucket, ')
          ..write('objectPath: $objectPath')
          ..write(')'))
        .toString();
  }
}

abstract class _$AudomateDatabase extends GeneratedDatabase {
  _$AudomateDatabase(QueryExecutor e) : super(e);
  $AudomateDatabaseManager get managers => $AudomateDatabaseManager(this);
  late final $LocalStateRowsTable localStateRows = $LocalStateRowsTable(this);
  late final $LocalProjectsTable localProjects = $LocalProjectsTable(this);
  late final $LocalFoldersTable localFolders = $LocalFoldersTable(this);
  late final $LocalRoomsTable localRooms = $LocalRoomsTable(this);
  late final $LocalFindingsTable localFindings = $LocalFindingsTable(this);
  late final $LocalPhotosTable localPhotos = $LocalPhotosTable(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $LocalPendingDeletesTable localPendingDeletes =
      $LocalPendingDeletesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localStateRows,
    localProjects,
    localFolders,
    localRooms,
    localFindings,
    localPhotos,
    localProfiles,
    localPendingDeletes,
  ];
}

typedef $$LocalStateRowsTableCreateCompanionBuilder =
    LocalStateRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalStateRowsTableUpdateCompanionBuilder =
    LocalStateRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalStateRowsTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalStateRowsTable> {
  $$LocalStateRowsTableFilterComposer({
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

class $$LocalStateRowsTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalStateRowsTable> {
  $$LocalStateRowsTableOrderingComposer({
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

class $$LocalStateRowsTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalStateRowsTable> {
  $$LocalStateRowsTableAnnotationComposer({
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

class $$LocalStateRowsTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalStateRowsTable,
          LocalStateRow,
          $$LocalStateRowsTableFilterComposer,
          $$LocalStateRowsTableOrderingComposer,
          $$LocalStateRowsTableAnnotationComposer,
          $$LocalStateRowsTableCreateCompanionBuilder,
          $$LocalStateRowsTableUpdateCompanionBuilder,
          (
            LocalStateRow,
            BaseReferences<
              _$AudomateDatabase,
              $LocalStateRowsTable,
              LocalStateRow
            >,
          ),
          LocalStateRow,
          PrefetchHooks Function()
        > {
  $$LocalStateRowsTableTableManager(
    _$AudomateDatabase db,
    $LocalStateRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalStateRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalStateRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalStateRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  LocalStateRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalStateRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStateRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalStateRowsTable,
      LocalStateRow,
      $$LocalStateRowsTableFilterComposer,
      $$LocalStateRowsTableOrderingComposer,
      $$LocalStateRowsTableAnnotationComposer,
      $$LocalStateRowsTableCreateCompanionBuilder,
      $$LocalStateRowsTableUpdateCompanionBuilder,
      (
        LocalStateRow,
        BaseReferences<_$AudomateDatabase, $LocalStateRowsTable, LocalStateRow>,
      ),
      LocalStateRow,
      PrefetchHooks Function()
    >;
typedef $$LocalProjectsTableCreateCompanionBuilder =
    LocalProjectsCompanion Function({
      required String id,
      Value<String?> organisationId,
      required String projectType,
      required String number,
      required String name,
      required String site,
      required DateTime createdAt,
      required String preamble,
      required String conclusion,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LocalProjectsTableUpdateCompanionBuilder =
    LocalProjectsCompanion Function({
      Value<String> id,
      Value<String?> organisationId,
      Value<String> projectType,
      Value<String> number,
      Value<String> name,
      Value<String> site,
      Value<DateTime> createdAt,
      Value<String> preamble,
      Value<String> conclusion,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalProjectsTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalProjectsTable> {
  $$LocalProjectsTableFilterComposer({
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

  ColumnFilters<String> get organisationId => $composableBuilder(
    column: $table.organisationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectType => $composableBuilder(
    column: $table.projectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get site => $composableBuilder(
    column: $table.site,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preamble => $composableBuilder(
    column: $table.preamble,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProjectsTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalProjectsTable> {
  $$LocalProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get organisationId => $composableBuilder(
    column: $table.organisationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectType => $composableBuilder(
    column: $table.projectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get site => $composableBuilder(
    column: $table.site,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preamble => $composableBuilder(
    column: $table.preamble,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProjectsTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalProjectsTable> {
  $$LocalProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organisationId => $composableBuilder(
    column: $table.organisationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectType => $composableBuilder(
    column: $table.projectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get site =>
      $composableBuilder(column: $table.site, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get preamble =>
      $composableBuilder(column: $table.preamble, builder: (column) => column);

  GeneratedColumn<String> get conclusion => $composableBuilder(
    column: $table.conclusion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalProjectsTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalProjectsTable,
          LocalProject,
          $$LocalProjectsTableFilterComposer,
          $$LocalProjectsTableOrderingComposer,
          $$LocalProjectsTableAnnotationComposer,
          $$LocalProjectsTableCreateCompanionBuilder,
          $$LocalProjectsTableUpdateCompanionBuilder,
          (
            LocalProject,
            BaseReferences<
              _$AudomateDatabase,
              $LocalProjectsTable,
              LocalProject
            >,
          ),
          LocalProject,
          PrefetchHooks Function()
        > {
  $$LocalProjectsTableTableManager(
    _$AudomateDatabase db,
    $LocalProjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalProjectsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> organisationId = const Value.absent(),
                Value<String> projectType = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> site = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> preamble = const Value.absent(),
                Value<String> conclusion = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProjectsCompanion(
                id: id,
                organisationId: organisationId,
                projectType: projectType,
                number: number,
                name: name,
                site: site,
                createdAt: createdAt,
                preamble: preamble,
                conclusion: conclusion,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> organisationId = const Value.absent(),
                required String projectType,
                required String number,
                required String name,
                required String site,
                required DateTime createdAt,
                required String preamble,
                required String conclusion,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalProjectsCompanion.insert(
                id: id,
                organisationId: organisationId,
                projectType: projectType,
                number: number,
                name: name,
                site: site,
                createdAt: createdAt,
                preamble: preamble,
                conclusion: conclusion,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalProjectsTable,
      LocalProject,
      $$LocalProjectsTableFilterComposer,
      $$LocalProjectsTableOrderingComposer,
      $$LocalProjectsTableAnnotationComposer,
      $$LocalProjectsTableCreateCompanionBuilder,
      $$LocalProjectsTableUpdateCompanionBuilder,
      (
        LocalProject,
        BaseReferences<_$AudomateDatabase, $LocalProjectsTable, LocalProject>,
      ),
      LocalProject,
      PrefetchHooks Function()
    >;
typedef $$LocalFoldersTableCreateCompanionBuilder =
    LocalFoldersCompanion Function({
      required String id,
      required String projectId,
      Value<String?> parentId,
      required String name,
      required String kind,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LocalFoldersTableUpdateCompanionBuilder =
    LocalFoldersCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String?> parentId,
      Value<String> name,
      Value<String> kind,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalFoldersTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalFoldersTable> {
  $$LocalFoldersTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFoldersTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalFoldersTable> {
  $$LocalFoldersTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFoldersTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalFoldersTable> {
  $$LocalFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalFoldersTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalFoldersTable,
          LocalFolder,
          $$LocalFoldersTableFilterComposer,
          $$LocalFoldersTableOrderingComposer,
          $$LocalFoldersTableAnnotationComposer,
          $$LocalFoldersTableCreateCompanionBuilder,
          $$LocalFoldersTableUpdateCompanionBuilder,
          (
            LocalFolder,
            BaseReferences<_$AudomateDatabase, $LocalFoldersTable, LocalFolder>,
          ),
          LocalFolder,
          PrefetchHooks Function()
        > {
  $$LocalFoldersTableTableManager(
    _$AudomateDatabase db,
    $LocalFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$LocalFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFoldersCompanion(
                id: id,
                projectId: projectId,
                parentId: parentId,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                Value<String?> parentId = const Value.absent(),
                required String name,
                required String kind,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalFoldersCompanion.insert(
                id: id,
                projectId: projectId,
                parentId: parentId,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalFoldersTable,
      LocalFolder,
      $$LocalFoldersTableFilterComposer,
      $$LocalFoldersTableOrderingComposer,
      $$LocalFoldersTableAnnotationComposer,
      $$LocalFoldersTableCreateCompanionBuilder,
      $$LocalFoldersTableUpdateCompanionBuilder,
      (
        LocalFolder,
        BaseReferences<_$AudomateDatabase, $LocalFoldersTable, LocalFolder>,
      ),
      LocalFolder,
      PrefetchHooks Function()
    >;
typedef $$LocalRoomsTableCreateCompanionBuilder =
    LocalRoomsCompanion Function({
      required String id,
      required String projectId,
      required String folderId,
      required String inspectionId,
      required String name,
      required String sectionName,
      Value<DateTime?> inspectedAt,
      required bool noIssues,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LocalRoomsTableUpdateCompanionBuilder =
    LocalRoomsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> folderId,
      Value<String> inspectionId,
      Value<String> name,
      Value<String> sectionName,
      Value<DateTime?> inspectedAt,
      Value<bool> noIssues,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalRoomsTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noIssues => $composableBuilder(
    column: $table.noIssues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRoomsTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noIssues => $composableBuilder(
    column: $table.noIssues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRoomsTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalRoomsTable> {
  $$LocalRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get inspectionId => $composableBuilder(
    column: $table.inspectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sectionName => $composableBuilder(
    column: $table.sectionName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get noIssues =>
      $composableBuilder(column: $table.noIssues, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalRoomsTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalRoomsTable,
          LocalRoom,
          $$LocalRoomsTableFilterComposer,
          $$LocalRoomsTableOrderingComposer,
          $$LocalRoomsTableAnnotationComposer,
          $$LocalRoomsTableCreateCompanionBuilder,
          $$LocalRoomsTableUpdateCompanionBuilder,
          (
            LocalRoom,
            BaseReferences<_$AudomateDatabase, $LocalRoomsTable, LocalRoom>,
          ),
          LocalRoom,
          PrefetchHooks Function()
        > {
  $$LocalRoomsTableTableManager(_$AudomateDatabase db, $LocalRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> folderId = const Value.absent(),
                Value<String> inspectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sectionName = const Value.absent(),
                Value<DateTime?> inspectedAt = const Value.absent(),
                Value<bool> noIssues = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRoomsCompanion(
                id: id,
                projectId: projectId,
                folderId: folderId,
                inspectionId: inspectionId,
                name: name,
                sectionName: sectionName,
                inspectedAt: inspectedAt,
                noIssues: noIssues,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String folderId,
                required String inspectionId,
                required String name,
                required String sectionName,
                Value<DateTime?> inspectedAt = const Value.absent(),
                required bool noIssues,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalRoomsCompanion.insert(
                id: id,
                projectId: projectId,
                folderId: folderId,
                inspectionId: inspectionId,
                name: name,
                sectionName: sectionName,
                inspectedAt: inspectedAt,
                noIssues: noIssues,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalRoomsTable,
      LocalRoom,
      $$LocalRoomsTableFilterComposer,
      $$LocalRoomsTableOrderingComposer,
      $$LocalRoomsTableAnnotationComposer,
      $$LocalRoomsTableCreateCompanionBuilder,
      $$LocalRoomsTableUpdateCompanionBuilder,
      (
        LocalRoom,
        BaseReferences<_$AudomateDatabase, $LocalRoomsTable, LocalRoom>,
      ),
      LocalRoom,
      PrefetchHooks Function()
    >;
typedef $$LocalFindingsTableCreateCompanionBuilder =
    LocalFindingsCompanion Function({
      required String id,
      required String roomId,
      required String type,
      required String location,
      required String severity,
      required String notes,
      required String recommendation,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LocalFindingsTableUpdateCompanionBuilder =
    LocalFindingsCompanion Function({
      Value<String> id,
      Value<String> roomId,
      Value<String> type,
      Value<String> location,
      Value<String> severity,
      Value<String> notes,
      Value<String> recommendation,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalFindingsTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalFindingsTable> {
  $$LocalFindingsTableFilterComposer({
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

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendation => $composableBuilder(
    column: $table.recommendation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFindingsTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalFindingsTable> {
  $$LocalFindingsTableOrderingComposer({
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

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendation => $composableBuilder(
    column: $table.recommendation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFindingsTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalFindingsTable> {
  $$LocalFindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get recommendation => $composableBuilder(
    column: $table.recommendation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalFindingsTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalFindingsTable,
          LocalFinding,
          $$LocalFindingsTableFilterComposer,
          $$LocalFindingsTableOrderingComposer,
          $$LocalFindingsTableAnnotationComposer,
          $$LocalFindingsTableCreateCompanionBuilder,
          $$LocalFindingsTableUpdateCompanionBuilder,
          (
            LocalFinding,
            BaseReferences<
              _$AudomateDatabase,
              $LocalFindingsTable,
              LocalFinding
            >,
          ),
          LocalFinding,
          PrefetchHooks Function()
        > {
  $$LocalFindingsTableTableManager(
    _$AudomateDatabase db,
    $LocalFindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalFindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalFindingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalFindingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> recommendation = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFindingsCompanion(
                id: id,
                roomId: roomId,
                type: type,
                location: location,
                severity: severity,
                notes: notes,
                recommendation: recommendation,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomId,
                required String type,
                required String location,
                required String severity,
                required String notes,
                required String recommendation,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalFindingsCompanion.insert(
                id: id,
                roomId: roomId,
                type: type,
                location: location,
                severity: severity,
                notes: notes,
                recommendation: recommendation,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalFindingsTable,
      LocalFinding,
      $$LocalFindingsTableFilterComposer,
      $$LocalFindingsTableOrderingComposer,
      $$LocalFindingsTableAnnotationComposer,
      $$LocalFindingsTableCreateCompanionBuilder,
      $$LocalFindingsTableUpdateCompanionBuilder,
      (
        LocalFinding,
        BaseReferences<_$AudomateDatabase, $LocalFindingsTable, LocalFinding>,
      ),
      LocalFinding,
      PrefetchHooks Function()
    >;
typedef $$LocalPhotosTableCreateCompanionBuilder =
    LocalPhotosCompanion Function({
      required String id,
      required String ownerKind,
      required String ownerId,
      required String name,
      required Uint8List bytes,
      Value<String?> remotePath,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$LocalPhotosTableUpdateCompanionBuilder =
    LocalPhotosCompanion Function({
      Value<String> id,
      Value<String> ownerKind,
      Value<String> ownerId,
      Value<String> name,
      Value<Uint8List> bytes,
      Value<String?> remotePath,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LocalPhotosTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalPhotosTable> {
  $$LocalPhotosTableFilterComposer({
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

  ColumnFilters<String> get ownerKind => $composableBuilder(
    column: $table.ownerKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPhotosTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalPhotosTable> {
  $$LocalPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get ownerKind => $composableBuilder(
    column: $table.ownerKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPhotosTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalPhotosTable> {
  $$LocalPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerKind =>
      $composableBuilder(column: $table.ownerKind, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalPhotosTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalPhotosTable,
          LocalPhoto,
          $$LocalPhotosTableFilterComposer,
          $$LocalPhotosTableOrderingComposer,
          $$LocalPhotosTableAnnotationComposer,
          $$LocalPhotosTableCreateCompanionBuilder,
          $$LocalPhotosTableUpdateCompanionBuilder,
          (
            LocalPhoto,
            BaseReferences<_$AudomateDatabase, $LocalPhotosTable, LocalPhoto>,
          ),
          LocalPhoto,
          PrefetchHooks Function()
        > {
  $$LocalPhotosTableTableManager(_$AudomateDatabase db, $LocalPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$LocalPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerKind = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<String?> remotePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPhotosCompanion(
                id: id,
                ownerKind: ownerKind,
                ownerId: ownerId,
                name: name,
                bytes: bytes,
                remotePath: remotePath,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerKind,
                required String ownerId,
                required String name,
                required Uint8List bytes,
                Value<String?> remotePath = const Value.absent(),
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalPhotosCompanion.insert(
                id: id,
                ownerKind: ownerKind,
                ownerId: ownerId,
                name: name,
                bytes: bytes,
                remotePath: remotePath,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalPhotosTable,
      LocalPhoto,
      $$LocalPhotosTableFilterComposer,
      $$LocalPhotosTableOrderingComposer,
      $$LocalPhotosTableAnnotationComposer,
      $$LocalPhotosTableCreateCompanionBuilder,
      $$LocalPhotosTableUpdateCompanionBuilder,
      (
        LocalPhoto,
        BaseReferences<_$AudomateDatabase, $LocalPhotosTable, LocalPhoto>,
      ),
      LocalPhoto,
      PrefetchHooks Function()
    >;
typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (
            LocalProfile,
            BaseReferences<
              _$AudomateDatabase,
              $LocalProfilesTable,
              LocalProfile
            >,
          ),
          LocalProfile,
          PrefetchHooks Function()
        > {
  $$LocalProfilesTableTableManager(
    _$AudomateDatabase db,
    $LocalProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (
        LocalProfile,
        BaseReferences<_$AudomateDatabase, $LocalProfilesTable, LocalProfile>,
      ),
      LocalProfile,
      PrefetchHooks Function()
    >;
typedef $$LocalPendingDeletesTableCreateCompanionBuilder =
    LocalPendingDeletesCompanion Function({
      Value<int> rowId,
      required String targetTable,
      required String remoteId,
      Value<String?> bucket,
      Value<String?> objectPath,
    });
typedef $$LocalPendingDeletesTableUpdateCompanionBuilder =
    LocalPendingDeletesCompanion Function({
      Value<int> rowId,
      Value<String> targetTable,
      Value<String> remoteId,
      Value<String?> bucket,
      Value<String?> objectPath,
    });

class $$LocalPendingDeletesTableFilterComposer
    extends Composer<_$AudomateDatabase, $LocalPendingDeletesTable> {
  $$LocalPendingDeletesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectPath => $composableBuilder(
    column: $table.objectPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPendingDeletesTableOrderingComposer
    extends Composer<_$AudomateDatabase, $LocalPendingDeletesTable> {
  $$LocalPendingDeletesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectPath => $composableBuilder(
    column: $table.objectPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPendingDeletesTableAnnotationComposer
    extends Composer<_$AudomateDatabase, $LocalPendingDeletesTable> {
  $$LocalPendingDeletesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get objectPath => $composableBuilder(
    column: $table.objectPath,
    builder: (column) => column,
  );
}

class $$LocalPendingDeletesTableTableManager
    extends
        RootTableManager<
          _$AudomateDatabase,
          $LocalPendingDeletesTable,
          LocalPendingDelete,
          $$LocalPendingDeletesTableFilterComposer,
          $$LocalPendingDeletesTableOrderingComposer,
          $$LocalPendingDeletesTableAnnotationComposer,
          $$LocalPendingDeletesTableCreateCompanionBuilder,
          $$LocalPendingDeletesTableUpdateCompanionBuilder,
          (
            LocalPendingDelete,
            BaseReferences<
              _$AudomateDatabase,
              $LocalPendingDeletesTable,
              LocalPendingDelete
            >,
          ),
          LocalPendingDelete,
          PrefetchHooks Function()
        > {
  $$LocalPendingDeletesTableTableManager(
    _$AudomateDatabase db,
    $LocalPendingDeletesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalPendingDeletesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LocalPendingDeletesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalPendingDeletesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> remoteId = const Value.absent(),
                Value<String?> bucket = const Value.absent(),
                Value<String?> objectPath = const Value.absent(),
              }) => LocalPendingDeletesCompanion(
                rowId: rowId,
                targetTable: targetTable,
                remoteId: remoteId,
                bucket: bucket,
                objectPath: objectPath,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String targetTable,
                required String remoteId,
                Value<String?> bucket = const Value.absent(),
                Value<String?> objectPath = const Value.absent(),
              }) => LocalPendingDeletesCompanion.insert(
                rowId: rowId,
                targetTable: targetTable,
                remoteId: remoteId,
                bucket: bucket,
                objectPath: objectPath,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPendingDeletesTableProcessedTableManager =
    ProcessedTableManager<
      _$AudomateDatabase,
      $LocalPendingDeletesTable,
      LocalPendingDelete,
      $$LocalPendingDeletesTableFilterComposer,
      $$LocalPendingDeletesTableOrderingComposer,
      $$LocalPendingDeletesTableAnnotationComposer,
      $$LocalPendingDeletesTableCreateCompanionBuilder,
      $$LocalPendingDeletesTableUpdateCompanionBuilder,
      (
        LocalPendingDelete,
        BaseReferences<
          _$AudomateDatabase,
          $LocalPendingDeletesTable,
          LocalPendingDelete
        >,
      ),
      LocalPendingDelete,
      PrefetchHooks Function()
    >;

class $AudomateDatabaseManager {
  final _$AudomateDatabase _db;
  $AudomateDatabaseManager(this._db);
  $$LocalStateRowsTableTableManager get localStateRows =>
      $$LocalStateRowsTableTableManager(_db, _db.localStateRows);
  $$LocalProjectsTableTableManager get localProjects =>
      $$LocalProjectsTableTableManager(_db, _db.localProjects);
  $$LocalFoldersTableTableManager get localFolders =>
      $$LocalFoldersTableTableManager(_db, _db.localFolders);
  $$LocalRoomsTableTableManager get localRooms =>
      $$LocalRoomsTableTableManager(_db, _db.localRooms);
  $$LocalFindingsTableTableManager get localFindings =>
      $$LocalFindingsTableTableManager(_db, _db.localFindings);
  $$LocalPhotosTableTableManager get localPhotos =>
      $$LocalPhotosTableTableManager(_db, _db.localPhotos);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$LocalPendingDeletesTableTableManager get localPendingDeletes =>
      $$LocalPendingDeletesTableTableManager(_db, _db.localPendingDeletes);
}
