import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

class LocalStateRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

class LocalProjects extends Table {
  TextColumn get id => text()();
  TextColumn get organisationId => text().nullable()();
  TextColumn get projectType => text()();
  TextColumn get number => text()();
  TextColumn get name => text()();
  TextColumn get site => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get preamble => text()();
  TextColumn get conclusion => text()();
  IntColumn get sortOrder => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalFolders extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  IntColumn get sortOrder => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalRooms extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get folderId => text()();
  TextColumn get inspectionId => text()();
  TextColumn get name => text()();
  TextColumn get sectionName => text()();
  DateTimeColumn get inspectedAt => dateTime().nullable()();
  BoolColumn get noIssues => boolean()();
  IntColumn get sortOrder => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalFindings extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text()();
  TextColumn get type => text()();
  TextColumn get location => text()();
  TextColumn get severity => text()();
  TextColumn get notes => text()();
  TextColumn get recommendation => text()();
  IntColumn get sortOrder => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get ownerKind => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  BlobColumn get bytes => blob()();
  TextColumn get remotePath => text().nullable()();
  IntColumn get sortOrder => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPendingDeletes extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get remoteId => text()();
  TextColumn get bucket => text().nullable()();
  TextColumn get objectPath => text().nullable()();
}

@DriftDatabase(
  tables: [
    LocalStateRows,
    LocalProjects,
    LocalFolders,
    LocalRooms,
    LocalFindings,
    LocalPhotos,
    LocalProfiles,
    LocalPendingDeletes,
  ],
)
class AudomateDatabase extends _$AudomateDatabase {
  AudomateDatabase(String name)
    : super(
        driftDatabase(
          name: name,
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.dart.js'),
          ),
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  AudomateDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
