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
  }) : id = id ?? newId(),
       sectionId = sectionId ?? newId(),
       inspectionId = inspectionId ?? newId();
  final String id;
  String sectionId;
  final String inspectionId;
  final String name;
  final String section;
  String owner;
  DateTime? inspectedAt;
  bool noIssues = false;
  final List<Finding> findings = [];
  bool get isComplete => noIssues || findings.isNotEmpty;
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
  }) : id = id ?? newId();
  final String id;
  String? organisationId;
  String number;
  String name;
  String site;
  final DateTime createdAt;
  final List<SpaceAudit> spaces;
  PhotoData? coverPhoto;
  String preamble;
  String conclusion;
  int get completed => spaces.where((s) => s.isComplete).length;
  int get issueCount => spaces.fold(0, (sum, s) => sum + s.findings.length);
  double get progress => spaces.isEmpty ? 0 : completed / spaces.length;
}

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
  }) : customIssueTypes = customIssueTypes ?? [];
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
  bool get onboardingComplete =>
      name.trim().isNotEmpty &&
      designation.trim().isNotEmpty &&
      organisation.trim().isNotEmpty &&
      licence.trim().isNotEmpty;
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
