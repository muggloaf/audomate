import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../report_service.dart';
import 'audit_screen.dart';
import 'edit_project_screen.dart';
import '../widgets/search_picker.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key, required this.project});
  final AuditProject project;
  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String query = '';
  String issueFilter = 'All';
  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final filtered =
        p.spaces
            .where(
              (s) =>
                  (query.isEmpty ||
                      '${s.name} ${s.section}'.toLowerCase().contains(
                        query.toLowerCase(),
                      )) &&
                  (issueFilter == 'All' ||
                      s.findings.any((f) => f.type == issueFilter)),
            )
            .toList();
    final sections = <String, List<SpaceAudit>>{};
    for (final s in filtered) {
      (sections[s.section] ??= []).add(s);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            tooltip: 'Project settings',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: p),
                ),
              );
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Export report',
            onPressed: () => _reportSheet(context),
            icon: const Icon(Icons.ios_share_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') _confirmDeleteProject();
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Delete project'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: forest,
        foregroundColor: Colors.white,
        onPressed: () => _addSpace(context),
        icon: const Icon(Icons.add),
        label: const Text('Add space'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: forest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.number,
                  style: const TextStyle(
                    color: Color(0xFFD7E5DC),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  p.site,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Stat(
                      value: '${p.completed}/${p.spaces.length}',
                      label: 'Audited',
                    ),
                    const SizedBox(width: 10),
                    _Stat(value: '${p.issueCount}', label: 'Issues'),
                    const SizedBox(width: 10),
                    _Stat(
                      value: '${(p.progress * 100).round()}%',
                      label: 'Complete',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search room, flat or building…',
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final store = AuditScope.of(context);
              final value = await showSearchPicker(
                context,
                title: 'Filter rooms by issue',
                options: [
                  'All',
                  ...issueTypes.where((v) => v != 'Other'),
                  ...store.profile.customIssueTypes,
                ],
                selected: issueFilter,
              );
              if (value != null && mounted) setState(() => issueFilter = value);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.filter_alt_outlined),
                suffixIcon: Icon(Icons.search),
                labelText: 'Issue filter',
              ),
              child: Text(issueFilter),
            ),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(child: Text('No matching spaces.')),
            ),
          ...sections.entries.map(
            (e) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        size: 19,
                        color: forest,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value.length} spaces',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ...e.value.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AuditScreen(project: p, space: s),
                            ),
                          );
                          setState(() {});
                        },
                        leading: CircleAvatar(
                          backgroundColor:
                              s.isComplete ? const Color(0xFFDCE8DC) : sand,
                          foregroundColor: s.isComplete ? forest : muted,
                          child: Icon(
                            s.noIssues
                                ? Icons.check
                                : s.findings.isNotEmpty
                                ? Icons.report_problem_outlined
                                : Icons.meeting_room_outlined,
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          s.noIssues
                              ? 'No issues reported'
                              : s.findings.isNotEmpty
                              ? '${s.findings.length} issue${s.findings.length == 1 ? '' : 's'} recorded'
                              : 'Not inspected',
                          style: TextStyle(
                            color:
                                s.findings.isNotEmpty
                                    ? const Color(0xFF9B5F43)
                                    : muted,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteSpace(s),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addSpace(BuildContext context) {
    final name = TextEditingController(),
        section = TextEditingController(text: 'Standalone spaces');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (c) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              22,
              20,
              MediaQuery.viewInsetsOf(c).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a space',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Room / flat / area name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: section,
                  decoration: const InputDecoration(
                    labelText: 'Folder / building',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (name.text.trim().isEmpty) return;
                      setState(
                        () => widget.project.spaces.add(
                          SpaceAudit(
                            name: name.text.trim(),
                            section:
                                section.text.trim().isEmpty
                                    ? 'Standalone spaces'
                                    : section.text.trim(),
                          ),
                        ),
                      );
                      AuditScope.of(context).changed();
                      Navigator.pop(c);
                    },
                    child: const Text('Add space'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDeleteSpace(SpaceAudit space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text('Delete ${space.name}?'),
            content: const Text(
              'This removes the room and all of its recorded issues and photos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted)
      setState(() => AuditScope.of(context).deleteSpace(widget.project, space));
  }

  Future<void> _confirmDeleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Delete this project?'),
            content: const Text(
              'All rooms, inspections, findings and cloud files belonging to this project will be deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      AuditScope.of(context).deleteProject(widget.project);
      Navigator.pop(context);
    }
  }

  void _reportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (c) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generate report',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Export the complete audit or a focused issue subsection.',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 18),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.description_outlined),
                    ),
                    title: const Text(
                      'Complete audit report',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('All spaces, observations and photos'),
                    onTap: () {
                      Navigator.pop(c);
                      ReportService.share(
                        widget.project,
                        AuditScope.of(context).profile,
                      );
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.filter_alt_outlined),
                    ),
                    title: const Text(
                      'Current filtered report',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      issueFilter == 'All'
                          ? 'All recorded issues'
                          : 'Only “$issueFilter” occurrences',
                    ),
                    onTap: () {
                      Navigator.pop(c);
                      ReportService.share(
                        widget.project,
                        AuditScope.of(context).profile,
                        issueFilter: issueFilter == 'All' ? null : issueFilter,
                        issuesOnly: true,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFD7E5DC), fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
