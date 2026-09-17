import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';

class ReportService {
  static Future<void> share(
    AuditProject project,
    EngineerProfile profile, {
    Set<String> issueFilters = const {},
    bool noIssuesOnly = false,
    bool issuesOnly = false,
  }) async {
    final bytes = await build(
      project,
      profile,
      issueFilters: issueFilters,
      noIssuesOnly: noIssuesOnly,
      issuesOnly: issuesOnly,
    );
    final suffix =
        issueFilters.isEmpty && !noIssuesOnly
            ? (issuesOnly ? '_issues' : '_complete')
            : '_filtered';
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${project.number}$suffix.pdf',
    );
  }

  static Future<Uint8List> build(
    AuditProject project,
    EngineerProfile profile, {
    Set<String> issueFilters = const {},
    bool noIssuesOnly = false,
    bool issuesOnly = false,
  }) async {
    final green = PdfColor.fromHex('#3D6656'),
        pale = PdfColor.fromHex('#F4EFE5'),
        grey = PdfColor.fromHex('#66736C'),
        ink = PdfColor.fromHex('#202522');
    final wordmarkFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Figtree-Variable.ttf'),
    );
    final reportTheme = pw.ThemeData.withFont(
      base: wordmarkFont,
      bold: wordmarkFont,
      italic: wordmarkFont,
      boldItalic: wordmarkFont,
    );
    final doc = pw.Document(
      title: '${project.name} Structural Audit',
      author: profile.name,
      creator: 'audomate',
      theme: reportTheme.copyWith(
        defaultTextStyle: const pw.TextStyle(fontSize: 13),
        paragraphStyle: const pw.TextStyle(fontSize: 13, lineSpacing: 5),
      ),
    );
    final cover =
        project.coverPhoto == null
            ? null
            : pw.MemoryImage(project.coverPhoto!.bytes);
    final letterhead =
        profile.letterhead == null
            ? null
            : pw.MemoryImage(profile.letterhead!.bytes);
    final signature =
        profile.signature == null
            ? null
            : pw.MemoryImage(profile.signature!.bytes);
    final priorityACount = project.spaces.fold<int>(
      0,
      (total, room) =>
          total +
          room.findings
              .where((finding) => finding.severity.trimLeft().startsWith('A'))
              .length,
    );
    final issueCounts = <String, int>{};
    for (final room in project.spaces) {
      for (final finding in room.findings) {
        issueCounts.update(
          finding.type,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final identifiedIssues =
        issueCounts.entries.toList()..sort((a, b) {
          final count = b.value.compareTo(a.value);
          return count != 0 ? count : a.key.compareTo(b.key);
        });
    final outlineNumbers = _buildOutlineNumbers(project);
    final selected =
        project.spaces
            .where(
              (s) =>
                  noIssuesOnly
                      ? s.noIssues
                      : !issuesOnly ||
                          issueFilters.isEmpty ||
                          issueFilters.every(
                            (tag) => s.findings.any((f) => f.type == tag),
                          ),
            )
            .toList()
          ..sort((a, b) {
            final path = _folderSortKey(
              project,
              a,
            ).compareTo(_folderSortKey(project, b));
            return path != 0
                ? path
                : a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        build:
            (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _brand(grey, green, ink, wordmarkFont),
                pw.SizedBox(height: 8),
                if (letterhead != null)
                  pw.Container(
                    height: 110,
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Image(letterhead, fit: pw.BoxFit.contain),
                  ),
                pw.Spacer(),
                if (cover != null)
                  pw.Container(
                    height: 280,
                    width: double.infinity,
                    child: pw.Image(cover, fit: pw.BoxFit.cover),
                  ),
                pw.SizedBox(height: 30),
                pw.Text(
                  issuesOnly
                      ? 'FOCUSED ISSUE REPORT'
                      : 'STRUCTURAL AUDIT REPORT',
                  style: pw.TextStyle(
                    color: green,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  project.name,
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  project.site,
                  style: pw.TextStyle(fontSize: 15, color: grey),
                ),
                if (issueFilters.isNotEmpty || noIssuesOnly) ...[
                  pw.SizedBox(height: 14),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: pale,
                    child: pw.Text(
                      noIssuesOnly
                          ? 'Filter: No issues reported'
                          : 'Filters: ${issueFilters.join(', ')}',
                      style: pw.TextStyle(
                        color: green,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                pw.Spacer(),
                pw.Divider(color: green),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Project no. ${project.number}'),
                    pw.Text('Project date ${_date(project.createdAt)}'),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'by ${profile.organisation}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Generated ${_date(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 11, color: grey),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );

    if (!issuesOnly) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(42),
          build:
              (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _brand(grey, green, ink, wordmarkFont),
                  pw.SizedBox(height: 12),
                  if (project.preamble.isNotEmpty) ...[
                    pw.Text(
                      'Preamble',
                      style: pw.TextStyle(
                        fontSize: 25,
                        color: green,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 14),
                    pw.Text(
                      project.preamble,
                      style: const pw.TextStyle(fontSize: 14, lineSpacing: 5),
                    ),
                    pw.SizedBox(height: 26),
                  ],
                  pw.Text(
                    'Observation summary',
                    style: pw.TextStyle(
                      fontSize: project.preamble.isEmpty ? 25 : 20,
                      color: project.preamble.isEmpty ? green : null,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  // pw.Text(
                  //   'Buildings: $buildingCount  |  Flats: $flatCount  |  Rooms: ${project.spaces.length}  |  Inspected: ${project.completed}',
                  //   style: const pw.TextStyle(fontSize: 10),
                  // ),
                  pw.SizedBox(height: 18),
                  pw.Text(
                    'Identified issues',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 7),
                  if (identifiedIssues.isEmpty)
                    pw.Text(
                      'No structural issues were identified.',
                      style: const pw.TextStyle(fontSize: 12),
                    )
                  else
                    ...identifiedIssues.map(
                      (issue) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text(
                          '- ${issue.key}: ${issue.value} ${issue.value == 1 ? 'observation' : 'observations'}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Total issues: ${project.issueCount}  |  Priority A: $priorityACount',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Rectification classification',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 7),
                  pw.Text(
                    'A - attend within 1 month\nB - attend within 3 months\nMonitor - observe and reassess as advised',
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
                  ),
                ],
              ),
        ),
      );
    }
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 46, 42, 54),
        header:
            (_) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  profile.organisation,
                  style: pw.TextStyle(color: grey, fontSize: 11),
                ),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      '${project.number}  |  ',
                      style: pw.TextStyle(color: grey, fontSize: 11),
                    ),
                    _wordmark(grey, green, ink, wordmarkFont),
                  ],
                ),
              ],
            ),
        footer:
            (c) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${c.pageNumber} of ${c.pagesCount}',
                style: pw.TextStyle(color: grey, fontSize: 11),
              ),
            ),
        build: (_) {
          final widgets = <pw.Widget>[
            pw.Text(
              issuesOnly ? 'Filtered observations' : 'Detailed observations',
              style: pw.TextStyle(
                fontSize: 25,
                color: green,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 18),
          ];
          var renderedRooms = 0;
          var photoNumber = 1;
          var currentFolderPath = <AuditFolder>[];
          for (final s in selected) {
            final findings =
                s.findings
                    .where(
                      (f) =>
                          issueFilters.isEmpty || issueFilters.contains(f.type),
                    )
                    .toList();
            if (issuesOnly && findings.isEmpty) continue;
            final folderPath = _folderPath(project, s);
            var commonDepth = 0;
            while (commonDepth < currentFolderPath.length &&
                commonDepth < folderPath.length &&
                currentFolderPath[commonDepth].id ==
                    folderPath[commonDepth].id) {
              commonDepth++;
            }
            for (var depth = commonDepth; depth < folderPath.length; depth++) {
              widgets.add(
                _folderHeading(
                  folderPath[depth],
                  number: outlineNumbers.folder[folderPath[depth].id] ?? '',
                  depth: depth,
                  first: renderedRooms == 0 && depth == 0,
                  pale: pale,
                  green: green,
                  grey: grey,
                ),
              );
            }
            currentFolderPath = folderPath;
            widgets.addAll(
              _space(
                s,
                findings,
                outlineNumbers.room[s.id] ?? '${renderedRooms + 1}',
                pale,
                green,
                locationPath: [
                  ...folderPath.map((folder) => folder.name),
                  s.name,
                ].join(' > '),
                firstPhotoNumber: photoNumber,
                includeNoIssues: !issuesOnly,
              ),
            );
            renderedRooms++;
            photoNumber += findings.fold<int>(
              0,
              (total, finding) => total + finding.photos.length,
            );
          }
          return widgets;
        },
      ),
    );

    if (!issuesOnly) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(42),
          build:
              (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _brand(grey, green, ink, wordmarkFont),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Conclusion',
                    style: pw.TextStyle(
                      fontSize: 25,
                      color: green,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    project.conclusion.isEmpty
                        ? 'The observations and recommendations recorded in this report should be acted upon within the stated priority periods.'
                        : project.conclusion,
                    style: const pw.TextStyle(fontSize: 14, lineSpacing: 5),
                  ),
                  pw.Spacer(),
                  if (signature != null)
                    pw.Container(
                      height: 90,
                      width: 210,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Image(signature, fit: pw.BoxFit.contain),
                    ),
                  pw.Text(
                    profile.name,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(profile.designation),
                  pw.Text(profile.organisation),
                  if (profile.licence.isNotEmpty)
                    pw.Text('Licence No: ${profile.licence}'),
                ],
              ),
        ),
      );
    }
    return doc.save();
  }

  static _OutlineNumbers _buildOutlineNumbers(AuditProject project) {
    final result = _OutlineNumbers();
    final visitedFolders = <String>{};

    void numberLevel(String? parentId, List<int> prefix) {
      final childFolders =
          project.folders
              .where((folder) => folder.parentId == parentId)
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
      final childRooms =
          parentId == null
              ? <SpaceAudit>[]
              : (project.spaces
                  .where((room) => room.sectionId == parentId)
                  .toList()
                ..sort(
                  (a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                ));

      var position = 0;
      for (final folder in childFolders) {
        if (!visitedFolders.add(folder.id)) continue;
        position++;
        final parts = [...prefix, position];
        result.folder[folder.id] = parts.join('.');
        numberLevel(folder.id, parts);
      }
      for (final room in childRooms) {
        position++;
        result.room[room.id] = [...prefix, position].join('.');
      }
    }

    numberLevel(null, const []);

    // Keep malformed legacy/orphaned records printable instead of dropping
    // their outline labels entirely.
    var fallbackRoot =
        result.folder.values.where((number) => !number.contains('.')).length;
    for (final folder in project.folders) {
      if (visitedFolders.contains(folder.id)) continue;
      fallbackRoot++;
      result.folder[folder.id] = '$fallbackRoot';
      visitedFolders.add(folder.id);
      numberLevel(folder.id, [fallbackRoot]);
    }
    for (final room in project.spaces) {
      if (result.room.containsKey(room.id)) continue;
      fallbackRoot++;
      result.room[room.id] = '$fallbackRoot';
    }
    return result;
  }

  static List<AuditFolder> _folderPath(AuditProject project, SpaceAudit room) {
    final foldersById = {
      for (final folder in project.folders) folder.id: folder,
    };
    final path = <AuditFolder>[];
    final visited = <String>{};
    AuditFolder? folder = foldersById[room.sectionId];

    // Old locally-created projects may only have the denormalized section
    // name. Preserve a useful heading for those records too.
    if (folder == null) {
      return [AuditFolder(id: room.sectionId, name: room.section)];
    }

    while (folder != null && visited.add(folder.id)) {
      path.add(folder);
      final parentId = folder.parentId;
      folder = parentId == null ? null : foldersById[parentId];
    }
    return path.reversed.toList();
  }

  static String _folderSortKey(AuditProject project, SpaceAudit room) =>
      _folderPath(
        project,
        room,
      ).map((folder) => folder.name.toLowerCase()).join('\u0000');

  static pw.Widget _folderHeading(
    AuditFolder folder, {
    required String number,
    required int depth,
    required bool first,
    required PdfColor pale,
    required PdfColor green,
    required PdfColor grey,
  }) {
    final isRoot = depth == 0;
    final fontSize = isRoot ? 19.0 : (depth == 1 ? 16.0 : 14.0);
    return pw.Padding(
      padding: pw.EdgeInsets.only(
        left: depth > 2 ? 36 : depth * 18.0,
        top: first ? 0 : (isRoot ? 44 : 22),
        bottom: isRoot ? 8 : 5,
      ),
      child: pw.Container(
        width: double.infinity,
        padding: pw.EdgeInsets.only(bottom: isRoot ? 6 : 2),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom:
                isRoot
                    ? pw.BorderSide(color: pale, width: 1)
                    : pw.BorderSide.none,
          ),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 58,
              child: pw.Text(
                number,
                style: pw.TextStyle(
                  fontSize: fontSize,
                  color: isRoot ? green : grey,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                '${folder.kind} ${folder.name}',
                style: pw.TextStyle(
                  fontSize: fontSize,
                  color: isRoot ? green : grey,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<pw.Widget> _space(
    SpaceAudit s,
    List<Finding> findings,
    String number,
    PdfColor pale,
    PdfColor green, {
    required String locationPath,
    required int firstPhotoNumber,
    required bool includeNoIssues,
  }) {
    final out = <pw.Widget>[
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.only(bottom: 5),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: pale, width: 1)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 58,
              child: pw.Text(
                number,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Room ${s.name}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Location: $locationPath${s.inspectedAt == null ? '' : '  |  Inspected ${_dateTime(s.inspectedAt!)}'}',
        style: const pw.TextStyle(fontSize: 11),
      ),
      pw.SizedBox(height: 8),
    ];
    if (findings.isEmpty && includeNoIssues) {
      out.add(
        pw.Text(
          s.noIssues
              ? 'No structural issues were observed.'
              : 'Inspection not yet completed.',
          style: const pw.TextStyle(fontSize: 13),
        ),
      );
    }
    var nextPhotoNumber = firstPhotoNumber;
    for (final f in findings) {
      out.addAll([
        pw.Text(
          f.type,
          style: pw.TextStyle(
            fontSize: 14,
            color: green,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Observed at: ${f.location}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        if (f.notes.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Observation: ${f.notes}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        if (f.recommendation.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Recommendation: ${f.recommendation}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        pw.SizedBox(height: 5),
        pw.Text(
          'Rectification classification: ${f.severity.replaceAll(' · ', ' - ')}',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        if (f.photos.isNotEmpty) ...[
          pw.SizedBox(height: 9),
          ..._photoRows(f.photos, firstNumber: nextPhotoNumber),
        ],
        pw.SizedBox(height: 10),
      ]);
      nextPhotoNumber += f.photos.length;
    }
    out.add(pw.SizedBox(height: 12));
    return out;
  }

  static List<pw.Widget> _photoRows(
    List<PhotoData> photos, {
    required int firstNumber,
  }) {
    final rows = <pw.Widget>[];
    for (var i = 0; i < photos.length; i += 2) {
      final cells = <pw.Widget>[_photo(photos[i], firstNumber + i)];
      if (i + 1 < photos.length) {
        cells.add(_photo(photos[i + 1], firstNumber + i + 1));
      }
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            mainAxisAlignment:
                cells.length == 1
                    ? pw.MainAxisAlignment.center
                    : pw.MainAxisAlignment.spaceBetween,
            children: cells,
          ),
        ),
      );
    }
    return rows;
  }

  static pw.Widget _photo(PhotoData p, int number) => pw.Column(
    children: [
      pw.Container(
        width: 240,
        height: 150,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Image(pw.MemoryImage(p.bytes), fit: pw.BoxFit.cover),
      ),
      pw.SizedBox(height: 3),
      pw.Text('Photo $number', style: const pw.TextStyle(fontSize: 10)),
    ],
  );
  static pw.Widget _brand(
    PdfColor grey,
    PdfColor green,
    PdfColor ink,
    pw.Font font,
  ) => pw.Align(
    alignment: pw.Alignment.centerRight,
    child: _wordmark(grey, green, ink, font),
  );
  static pw.Widget _wordmark(
    PdfColor grey,
    PdfColor green,
    PdfColor ink,
    pw.Font font,
  ) => pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: 'made with ',
          style: pw.TextStyle(font: font, fontSize: 9, color: grey),
        ),
        pw.TextSpan(
          text: 'audo',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: green,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        pw.TextSpan(
          text: 'mate.',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: ink,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ],
    ),
  );
  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  static String _dateTime(DateTime d) =>
      '${_date(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _OutlineNumbers {
  final Map<String, String> folder = {};
  final Map<String, String> room = {};
}
