import 'dart:typed_data';
import 'package:uuid/uuid.dart';

String newId() => const Uuid().v4();

class PhotoData {
  PhotoData({
    required this.bytes,
    required this.name,
    String? id,
    this.remotePath,
  }) : id = id ?? newId();
  final String id;
  final Uint8List bytes;
  final String name;
  String? remotePath;
}

class Finding {
  Finding({
    required this.type,
    required this.location,
    required this.severity,
    this.notes = '',
    this.recommendation = '',
    List<PhotoData>? photos,
    String? id,
  }) : id = id ?? newId(),
       photos = photos ?? [];
  final String id;
  String type;
  String location;
  String severity;
  String notes;
  String recommendation;
  final List<PhotoData> photos;
}

class SpaceAudit {
  SpaceAudit({
    required this.name,
    required this.section,
    this.owner = '',
    String? id,
    String? sectionId,
    String? inspectionId,
    this.sortOrder = 0,
  }) : id = id ?? newId(),
       sectionId = sectionId ?? newId(),
       inspectionId = inspectionId ?? newId();
  final String id;
  String sectionId;
  final String inspectionId;
  String name;
  String section;
  String owner;
  DateTime? inspectedAt;
  bool noIssues = false;
  int sortOrder;
  final List<Finding> findings = [];
  bool get isComplete => noIssues || findings.isNotEmpty;
}

class AuditFolder {
  AuditFolder({
    required this.name,
    this.kind = 'Space',
    this.parentId,
    this.sortOrder = 0,
    String? id,
  }) : id = id ?? newId();

  final String id;
  String name;
  String kind;
  String? parentId;
  int sortOrder;
}

class AuditProject {
  AuditProject({
    required this.number,
    required this.name,
    required this.site,
    required this.createdAt,
    required this.spaces,
    this.coverPhoto,
    this.preamble = '',
    this.conclusion = '',
    String? id,
    this.organisationId,
    this.projectType = 'Other',
    List<AuditFolder>? folders,
  }) : id = id ?? newId(),
       folders = folders ?? foldersFromSpaces(spaces);
  final String id;
  String? organisationId;
  String projectType;
  String number;
  String name;
  String site;
  final DateTime createdAt;
  final List<SpaceAudit> spaces;
  final List<AuditFolder> folders;
  PhotoData? coverPhoto;
  String preamble;
  String conclusion;
  int get completed => spaces.where((s) => s.isComplete).length;
  int get issueCount => spaces.fold(0, (sum, s) => sum + s.findings.length);
  double get progress => spaces.isEmpty ? 0 : completed / spaces.length;

  static List<AuditFolder> foldersFromSpaces(List<SpaceAudit> spaces) {
    final byId = <String, AuditFolder>{};
    for (final room in spaces) {
      byId.putIfAbsent(
        room.sectionId,
        () => AuditFolder(id: room.sectionId, name: room.section),
      );
    }
    return byId.values.toList();
  }
}

class SpaceTemplate {
  SpaceTemplate({
    required this.id,
    required this.name,
    required this.kind,
    this.roomNames = const [],
  });
  final String id;
  String name;
  String kind;
  final List<String> roomNames;

  SpaceTemplate copy() => SpaceTemplate(
    id: id,
    name: name,
    kind: kind,
    roomNames: List<String>.from(roomNames),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    'roomNames': roomNames,
  };

  factory SpaceTemplate.fromJson(Map<String, dynamic> value) => SpaceTemplate(
    id: value['id'] as String? ?? newId(),
    name: value['name'] as String? ?? 'Space',
    kind: value['kind'] as String? ?? 'Space',
    roomNames:
        (value['roomNames'] as List<dynamic>? ?? const []).cast<String>(),
  );
}

class ProjectTemplate {
  ProjectTemplate({
    required this.id,
    required this.name,
    required this.spaceTemplates,
  });
  final String id;
  String name;
  final List<SpaceTemplate> spaceTemplates;

  ProjectTemplate copy() => ProjectTemplate(
    id: id,
    name: name,
    spaceTemplates: spaceTemplates.map((value) => value.copy()).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spaceTemplates': spaceTemplates.map((value) => value.toJson()).toList(),
  };

  factory ProjectTemplate.fromJson(Map<String, dynamic> value) =>
      ProjectTemplate(
        id: value['id'] as String? ?? newId(),
        name: value['name'] as String? ?? 'Project template',
        spaceTemplates:
            (value['spaceTemplates'] as List<dynamic>? ?? const [])
                .map(
                  (item) => SpaceTemplate.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(),
      );
}

final baseProjectTemplates = <ProjectTemplate>[
  ProjectTemplate(
    id: 'society',
    name: 'Housing society',
    spaceTemplates: [
      SpaceTemplate(id: 'building', name: 'Building', kind: 'Building'),
      SpaceTemplate(id: 'wing', name: 'Wing', kind: 'Wing'),
      SpaceTemplate(
        id: 'flat',
        name: 'Flat',
        kind: 'Flat',
        roomNames: ['Living room', 'Kitchen', 'Bedroom', 'Bathroom', 'Balcony'],
      ),
      SpaceTemplate(id: 'clubhouse', name: 'Club house', kind: 'Amenity'),
    ],
  ),
  ProjectTemplate(
    id: 'hospital',
    name: 'Hospital',
    spaceTemplates: [
      SpaceTemplate(id: 'ward', name: 'Ward', kind: 'Ward'),
      SpaceTemplate(id: 'department', name: 'Department', kind: 'Department'),
      SpaceTemplate(id: 'hospital_room', name: 'Room', kind: 'Room'),
    ],
  ),
  ProjectTemplate(
    id: 'school',
    name: 'School',
    spaceTemplates: [
      SpaceTemplate(id: 'block', name: 'Block', kind: 'Block'),
      SpaceTemplate(id: 'floor', name: 'Floor', kind: 'Floor'),
      SpaceTemplate(id: 'classroom', name: 'Classroom', kind: 'Classroom'),
    ],
  ),
  ProjectTemplate(
    id: 'office',
    name: 'Office',
    spaceTemplates: [
      SpaceTemplate(id: 'office_floor', name: 'Floor', kind: 'Floor'),
      SpaceTemplate(id: 'department', name: 'Department', kind: 'Department'),
      SpaceTemplate(id: 'cabin', name: 'Cabin', kind: 'Room'),
    ],
  ),
  ProjectTemplate(
    id: 'other',
    name: 'Other',
    spaceTemplates: [
      SpaceTemplate(id: 'generic_space', name: 'Space', kind: 'Space'),
    ],
  ),
];

class EngineerProfile {
  EngineerProfile({
    this.name = '',
    this.designation = '',
    this.organisation = '',
    this.licence = '',
    this.phone = '',
    this.email = '',
    this.letterhead,
    this.signature,
    this.letterheadRemotePath,
    this.signatureRemotePath,
    this.darkMode = false,
    List<String>? customIssueTypes,
    List<String>? customProjectTemplates,
    List<String>? customSpaceTemplates,
    List<ProjectTemplate>? projectTemplates,
  }) : customIssueTypes = customIssueTypes ?? [],
       customProjectTemplates = customProjectTemplates ?? [],
       customSpaceTemplates = customSpaceTemplates ?? [],
       projectTemplates =
           projectTemplates ??
           _initialTemplates(customProjectTemplates, customSpaceTemplates);
  String name;
  String designation;
  String organisation;
  String licence;
  String phone;
  String email;
  PhotoData? letterhead;
  PhotoData? signature;
  String? letterheadRemotePath;
  String? signatureRemotePath;
  bool darkMode;
  final List<String> customIssueTypes;
  final List<String> customProjectTemplates;
  final List<String> customSpaceTemplates;
  final List<ProjectTemplate> projectTemplates;
  bool get onboardingComplete =>
      name.trim().isNotEmpty &&
      designation.trim().isNotEmpty &&
      organisation.trim().isNotEmpty &&
      licence.trim().isNotEmpty;

  static List<ProjectTemplate> _initialTemplates(
    List<String>? legacyProjects,
    List<String>? legacySpaces,
  ) {
    final result = baseProjectTemplates.map((value) => value.copy()).toList();
    for (final name in legacyProjects ?? const <String>[]) {
      result.add(
        ProjectTemplate(
          id: 'custom_${newId()}',
          name: name,
          spaceTemplates: [
            ...(legacySpaces ?? const <String>[]).map(
              (space) => SpaceTemplate(id: newId(), name: space, kind: space),
            ),
            SpaceTemplate(id: newId(), name: 'Space', kind: 'Space'),
          ],
        ),
      );
    }
    return result;
  }
}

const issueTypes = <String>[
  'Leakage / seepage',
  'Crack in wall',
  'Crack in ceiling',
  'Crack in beam / column',
  'Plaster crack / damage',
  'Corrosion / exposed steel',
  'Vegetation growth',
  'Overloading / deflection',
  'Vibration',
  'Termite / timber damage',
  'Other',
];
const locations = <String>[
  'Left wall',
  'Right wall',
  'Adjacent wall',
  'Opposite wall',
  'Ceiling / slab',
  'Beam / column',
  'Floor',
  'External area',
  'Other',
];
const severities = <String>[
  'A · Attend within 1 month',
  'B · Attend within 3 months',
  'Monitor',
];

String normalizeSeverity(String? value) {
  if (value?.trimLeft().startsWith('A') == true) return severities.first;
  if (value?.trimLeft().startsWith('B') == true) return severities[1];
  return severities.last;
}
