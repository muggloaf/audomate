import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/search_picker.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key, required this.project, required this.space});
  final AuditProject project;
  final SpaceAudit space;
  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  @override
  Widget build(BuildContext context) {
    final s = widget.space;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          TextButton(
            onPressed: () {
              if (!s.isComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Choose “No issues” or add at least one issue.',
                    ),
                  ),
                );
                return;
              }
              AuditScope.of(context).changed();
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Row(
            children: [
              const Icon(Icons.folder_outlined, color: forest, size: 19),
              const SizedBox(width: 7),
              Text(
                s.section,
                style: const TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextFormField(
            initialValue: s.owner,
            onChanged: (v) {
              s.owner = v;
              AuditScope.of(context).changed();
            },
            decoration: const InputDecoration(
              labelText: 'Owner / occupant (optional)',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                initialDate: s.inspectedAt ?? DateTime.now(),
              );
              if (!context.mounted) return;
              if (d != null) {
                setState(
                  () =>
                      s.inspectedAt = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        TimeOfDay.now().hour,
                        TimeOfDay.now().minute,
                      ),
                );
                AuditScope.of(context).changed();
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Inspection date',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                s.inspectedAt == null
                    ? 'Tap to record date'
                    : _date(s.inspectedAt!),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Inspection result',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              value: s.noIssues,
              activeColor: forest,
              title: const Text(
                'No issues observed',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Use this for the fast, all-clear path.'),
              onChanged:
                  (v) => setState(() {
                    s.noIssues = v;
                    if (v) s.findings.clear();
                    s.inspectedAt ??= DateTime.now();
                    AuditScope.of(context).changed();
                  }),
            ),
          ),
          if (!s.noIssues) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Issues observed',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${s.findings.length}',
                  style: const TextStyle(color: muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...s.findings.asMap().entries.map(
              (e) => _FindingCard(
                index: e.key,
                finding: e.value,
                onDelete:
                    () => setState(() {
                      AuditScope.of(context).queueFindingDeletion(e.value);
                      s.findings.removeAt(e.key);
                    }),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: forest),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _addFinding,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add an issue',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addFinding() async {
    final f = Finding(
      type: issueTypes.first,
      location: locations.first,
      severity: severities.first,
    );
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FindingEditor(finding: f),
    );
    if (ok == true) {
      setState(() {
        widget.space.noIssues = false;
        widget.space.inspectedAt ??= DateTime.now();
        widget.space.findings.add(f);
        AuditScope.of(context).changed();
      });
    }
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · ${TimeOfDay.fromDateTime(d).format(context)}';
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({
    required this.index,
    required this.finding,
    required this.onDelete,
  });
  final int index;
  final Finding finding;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => FindingEditor(finding: finding),
            ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF5E6DE),
                foregroundColor: const Color(0xFF9B5F43),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${finding.location} · ${finding.severity.split(' ·').first}',
                      style: const TextStyle(color: muted),
                    ),
                    if (finding.photos.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          '${finding.photos.length} photo${finding.photos.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: forest,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class FindingEditor extends StatefulWidget {
  const FindingEditor({super.key, required this.finding});
  final Finding finding;
  @override
  State<FindingEditor> createState() => _FindingEditorState();
}

class _FindingEditorState extends State<FindingEditor> {
  late final TextEditingController notes = TextEditingController(
    text: widget.finding.notes,
  );
  late final TextEditingController recommendation = TextEditingController(
    text: widget.finding.recommendation,
  );
  Future<void> addPhotos() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (r != null) {
      setState(() {
        for (final f in r.files) {
          if (f.bytes != null) {
            widget.finding.photos.add(PhotoData(bytes: f.bytes!, name: f.name));
          }
        }
      });
    }
  }

  Future<void> pickIssue() async {
    final store = AuditScope.of(context);
    final options = [
      ...issueTypes.where((v) => v != 'Other'),
      ...store.profile.customIssueTypes,
      'Other',
    ];
    final value = await showSearchPicker(
      context,
      title: 'Select issue type',
      options: options,
      selected: widget.finding.type,
    );
    if (!mounted || value == null) return;
    if (value == 'Other') {
      final controller = TextEditingController();
      final custom = await showDialog<String>(
        context: context,
        builder:
            (c) => AlertDialog(
              title: const Text('New issue type'),
              content: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Issue name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(c, controller.text.trim()),
                  child: const Text('Add'),
                ),
              ],
            ),
      );
      if (custom == null || custom.isEmpty || !mounted) return;
      if (!store.profile.customIssueTypes.any(
        (v) => v.toLowerCase() == custom.toLowerCase(),
      ))
        store.profile.customIssueTypes.add(custom);
      setState(() => widget.finding.type = custom);
      store.changed();
    } else {
      setState(() => widget.finding.type = value);
    }
  }

  Future<void> pickLocation() async {
    final value = await showSearchPicker(
      context,
      title: 'Select location',
      options: locations,
      selected: widget.finding.location,
    );
    if (value != null && mounted)
      setState(() => widget.finding.location = value);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      16,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Issue details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: pickIssue,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Issue type',
                suffixIcon: Icon(Icons.search),
              ),
              child: Text(widget.finding.type),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: pickLocation,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Location',
                suffixIcon: Icon(Icons.search),
              ),
              child: Text(widget.finding.location),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            value: widget.finding.severity,
            decoration: const InputDecoration(
              labelText: 'Rectification priority',
            ),
            items:
                severities
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
            onChanged: (v) => widget.finding.severity = v!,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observation / comments',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: recommendation,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Recommendation',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Evidence photos',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: addPhotos,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Add'),
              ),
            ],
          ),
          if (widget.finding.photos.isEmpty)
            Container(
              height: 90,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sand,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Add one or more photos',
                style: TextStyle(color: muted),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.finding.photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemBuilder:
                  (_, i) => Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          widget.finding.photos[i].bytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            color: Colors.white,
                            onPressed:
                                () => setState(() {
                                  final photo = widget.finding.photos[i];
                                  AuditScope.of(
                                    context,
                                  ).queuePhotoDeletion(photo);
                                  widget.finding.photos.removeAt(i);
                                }),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.finding.notes = notes.text.trim();
                widget.finding.recommendation = recommendation.text.trim();
                AuditScope.of(context).changed();
                Navigator.pop(context, true);
              },
              child: const Text('Save issue'),
            ),
          ),
        ],
      ),
    ),
  );
}
