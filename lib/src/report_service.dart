import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
    final suffix = issueFilters.isEmpty && !noIssuesOnly
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
    final doc = pw.Document(title: '${project.name} Structural Audit');
    final green = PdfColor.fromHex('#3D6656'),
        pale = PdfColor.fromHex('#F4EFE5'),
        grey = PdfColor.fromHex('#66736C');
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
    final selected =
        project.spaces
            .where(
              (s) => noIssuesOnly
                  ? s.noIssues
                  : !issuesOnly ||
                      issueFilters.isEmpty ||
                      issueFilters.every(
                        (tag) => s.findings.any((f) => f.type == tag),
                      ),
            )
            .toList()
          ..sort((a, b) {
            final section = a.section.toLowerCase().compareTo(
              b.section.toLowerCase(),
            );
            return section != 0
                ? section
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
                _brand(grey),
                pw.SizedBox(height: 8),
                if (letterhead != null)
                  pw.Container(
                    height: 70,
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
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  project.name,
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  project.site,
                  style: pw.TextStyle(fontSize: 13, color: grey),
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
                    pw.Text('Generated ${_date(DateTime.now())}'),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  profile.organisation,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
      ),
    );

    if (!issuesOnly && project.preamble.isNotEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(42),
          build:
              (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _brand(grey),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Preamble',
                    style: pw.TextStyle(
                      fontSize: 23,
                      color: green,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    project.preamble,
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
                  ),
                  pw.SizedBox(height: 26),
                  pw.Text(
                    'Audit overview',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      _metric('${project.spaces.length}', 'Spaces'),
                      pw.SizedBox(width: 10),
                      _metric('${project.completed}', 'Inspected'),
                      pw.SizedBox(width: 10),
                      _metric('${project.issueCount}', 'Issues'),
                    ],
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
                  style: pw.TextStyle(color: grey, fontSize: 9),
                ),
                pw.Text(
                  '${project.number}  ·  made with audomate.',
                  style: pw.TextStyle(color: grey, fontSize: 9),
                ),
              ],
            ),
        footer:
            (c) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${c.pageNumber} of ${c.pagesCount}',
                style: pw.TextStyle(color: grey, fontSize: 9),
              ),
            ),
        build: (_) {
          final widgets = <pw.Widget>[
            pw.Text(
              issuesOnly ? 'Filtered observations' : 'Detailed observations',
              style: pw.TextStyle(
                fontSize: 23,
                color: green,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 18),
          ];
          var n = 1;
          String? currentSection;
          for (final s in selected) {
            final findings = s.findings
                .where(
                  (f) => issueFilters.isEmpty || issueFilters.contains(f.type),
                )
                .toList();
            if (issuesOnly && findings.isEmpty) continue;
            if (currentSection != s.section) {
              currentSection = s.section;
              widgets.addAll([
                pw.SizedBox(height: n == 1 ? 0 : 10),
                pw.Text(
                  currentSection,
                  style: pw.TextStyle(
                    fontSize: 17,
                    color: green,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(color: pale),
                pw.SizedBox(height: 6),
              ]);
            }
            widgets.addAll(
              _space(
                s,
                findings,
                n++,
                pale,
                green,
                includeNoIssues: !issuesOnly,
              ),
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
                  _brand(grey),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Conclusion',
                    style: pw.TextStyle(
                      fontSize: 23,
                      color: green,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    project.conclusion.isEmpty
                        ? 'The observations and recommendations recorded in this report should be acted upon within the stated priority periods.'
                        : project.conclusion,
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
                  ),
                  pw.Spacer(),
                  if (signature != null)
                    pw.Container(
                      height: 55,
                      width: 150,
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

  static List<pw.Widget> _space(
    SpaceAudit s,
    List<Finding> findings,
    int number,
    PdfColor pale,
    PdfColor green, {
    required bool includeNoIssues,
  }) {
    final out = <pw.Widget>[
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(11),
        decoration: pw.BoxDecoration(
          color: pale,
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '$number. ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    s.name,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    s.section +
                        (s.inspectedAt == null
                            ? ''
                            : '  ·  Inspected ${_date(s.inspectedAt!)}'),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 8),
    ];
    if (findings.isEmpty && includeNoIssues) {
      out.add(
        pw.Text(
          s.noIssues
              ? 'No structural issues were observed.'
              : 'Inspection not yet completed.',
          style: const pw.TextStyle(fontSize: 11),
        ),
      );
    }
    for (final f in findings) {
      out.addAll([
        pw.Text(
          f.type,
          style: pw.TextStyle(
            fontSize: 12,
            color: green,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Location: ${f.location}  |  Priority: ${f.severity}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        if (f.notes.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Observation: ${f.notes}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
        if (f.recommendation.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Recommendation: ${f.recommendation}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
        if (f.photos.isNotEmpty) ...[
          pw.SizedBox(height: 9),
          ..._photoRows(f.photos),
        ],
        pw.SizedBox(height: 10),
      ]);
    }
    out.add(pw.SizedBox(height: 12));
    return out;
  }

  static List<pw.Widget> _photoRows(List<PhotoData> photos) {
    final rows = <pw.Widget>[];
    for (var i = 0; i < photos.length; i += 2) {
      final cells = <pw.Widget>[_photo(photos[i])];
      if (i + 1 < photos.length) cells.add(_photo(photos[i + 1]));
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

  static pw.Widget _photo(PhotoData p) => pw.Container(
    width: 240,
    height: 150,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Image(pw.MemoryImage(p.bytes), fit: pw.BoxFit.cover),
  );
  static pw.Widget _brand(PdfColor grey) => pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Text(
      'made with audomate.',
      style: pw.TextStyle(fontSize: 7, color: grey),
    ),
  );
  static pw.Widget _metric(String value, String label) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F4EFE5'),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    ),
  );
  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
