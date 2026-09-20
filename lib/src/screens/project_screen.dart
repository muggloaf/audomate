import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../report_service.dart';
import '../theme.dart';
import 'audit_screen.dart';
import 'edit_project_screen.dart';

enum RoomSort { custom, name, newest, oldest, issues }

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key, required this.project});
  final AuditProject project;

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String query = '';
  final selectedIssues = <String>{};
  bool onlyNoIssues = false;
  RoomSort sort = RoomSort.custom;
  final collapsed = <String>{};

  AuditProject get project => widget.project;
  ProjectTemplate get projectTemplate =>
      AuditScope.of(context).profile.projectTemplates.firstWhere(
        (value) => value.id == project.projectType,
        orElse:
            () => ProjectTemplate(
              id: 'fallback',
              name: 'Other',
              spaceTemplates: [
                SpaceTemplate(id: 'space', name: 'Space', kind: 'Space'),
              ],
            ),
      );

  List<SpaceAudit> _roomsFor(String folderId) {
    final rooms =
        project.spaces.where((room) {
          if (room.sectionId != folderId) return false;
          final text = '${room.name} ${room.section}'.toLowerCase();
          if (query.isNotEmpty && !text.contains(query.toLowerCase())) {
            return false;
          }
          if (onlyNoIssues && !room.noIssues) return false;
          if (selectedIssues.isNotEmpty &&
              !selectedIssues.every(
                (tag) => room.findings.any((finding) => finding.type == tag),
              )) {
            return false;
          }
          return true;
        }).toList();
    rooms.sort(
      (a, b) => switch (sort) {
        RoomSort.custom => _customOrder(
          a.sortOrder,
          b.sortOrder,
          a.name,
          b.name,
        ),
        RoomSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        RoomSort.newest => (b.inspectedAt ?? DateTime(1900)).compareTo(
          a.inspectedAt ?? DateTime(1900),
        ),
        RoomSort.oldest => (a.inspectedAt ?? DateTime(9999)).compareTo(
          b.inspectedAt ?? DateTime(9999),
        ),
        RoomSort.issues => b.findings.length.compareTo(a.findings.length),
      },
    );
    return rooms;
  }

  int _customOrder(int left, int right, String leftName, String rightName) {
    final order = left.compareTo(right);
    return order != 0
        ? order
        : leftName.toLowerCase().compareTo(rightName.toLowerCase());
  }

  bool _folderMatches(AuditFolder folder) {
    if (query.isEmpty && selectedIssues.isEmpty && !onlyNoIssues) return true;
    if (folder.name.toLowerCase().contains(query.toLowerCase()) &&
        selectedIssues.isEmpty &&
        !onlyNoIssues) {
      return true;
    }
    if (_roomsFor(folder.id).isNotEmpty) return true;
    return project.folders.any(
      (child) => child.parentId == folder.id && _folderMatches(child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rootFolders =
        project.folders
            .where(
              (folder) => folder.parentId == null && _folderMatches(folder),
            )
            .toList()
          ..sort(
            (a, b) => _customOrder(a.sortOrder, b.sortOrder, a.name, b.name),
          );
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            tooltip: 'Project settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: project),
                ),
              );
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Export report',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _showReportOptions,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _deleteProject();
              if (value == 'arrange') _arrangeContents(null);
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: 'arrange',
                    child: Text('Arrange top-level spaces'),
                  ),
                  PopupMenuItem(value: 'delete', child: Text('Delete project')),
                ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFolder(),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Add space'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        children: [
          _Summary(project: project),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showSearch,
                  icon: const Icon(Icons.search),
                  label: Text(query.isEmpty ? 'Search' : 'Search active'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: Text(
                    selectedIssues.isEmpty &&
                            !onlyNoIssues &&
                            sort == RoomSort.custom
                        ? 'Filter'
                        : 'Filter active',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (rootFolders.isEmpty)
            _EmptyProject(onAdd: _addFolder)
          else
            ...rootFolders.map((folder) => _folderCard(folder, 0)),
        ],
      ),
    );
  }

  Widget _folderCard(AuditFolder folder, int depth) {
    final rooms = _roomsFor(folder.id);
    final children =
        project.folders
            .where(
              (value) => value.parentId == folder.id && _folderMatches(value),
            )
            .toList()
          ..sort(
            (a, b) => _customOrder(a.sortOrder, b.sortOrder, a.name, b.name),
          );
    final isCollapsed = collapsed.contains(folder.id);
    final node = Column(
      children: [
        ListTile(
          onTap:
              () => setState(
                () =>
                    isCollapsed
                        ? collapsed.remove(folder.id)
                        : collapsed.add(folder.id),
              ),
          leading: Icon(
            isCollapsed ? Icons.folder_outlined : Icons.folder_open_outlined,
            color: forest,
          ),
          title: Text(
            folder.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(_folderSummary(folder)),
          trailing: PopupMenuButton<String>(
            onSelected:
                (value) => switch (value) {
                  'room' => _addRoom(folder),
                  'child' => _addFolder(parent: folder),
                  'edit' => _editFolder(folder),
                  'arrange' => _arrangeContents(folder),
                  'delete' => _deleteFolder(folder),
                  _ => null,
                },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'room', child: Text('Add room')),
                  PopupMenuItem(
                    value: 'child',
                    child: Text('Add nested space'),
                  ),
                  PopupMenuItem(value: 'edit', child: Text('Edit space')),
                  PopupMenuItem(
                    value: 'arrange',
                    child: Text('Arrange contents'),
                  ),
                  PopupMenuItem(value: 'delete', child: Text('Delete space')),
                ],
          ),
        ),
        if (!isCollapsed) ...[
          if (rooms.isEmpty && children.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Empty space — add a room when ready.',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
              ),
            ),
          ...rooms.map((room) => _roomTile(folder, room)),
          ...children.map((child) => _folderCard(child, depth + 1)),
        ],
      ],
    );
    if (depth == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(clipBehavior: Clip.antiAlias, child: node),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      child: Card(clipBehavior: Clip.antiAlias, child: node),
    );
  }

  Widget _roomTile(AuditFolder folder, SpaceAudit room) => ListTile(
    contentPadding: const EdgeInsets.only(left: 32, right: 16),
    minLeadingWidth: 28,
    horizontalTitleGap: 12,
    leading: Icon(
      room.noIssues
          ? Icons.check_circle_outline
          : room.findings.isNotEmpty
          ? Icons.report_problem_outlined
          : Icons.meeting_room_outlined,
      color: room.findings.isNotEmpty ? const Color(0xFF9B5F43) : forest,
    ),
    title: Text(room.name),
    subtitle: Text(
      room.noIssues
          ? 'No issues'
          : room.findings.isEmpty
          ? 'Not inspected'
          : '${room.findings.length} issues',
    ),
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuditScreen(project: project, space: room),
        ),
      );
      if (mounted) setState(() {});
    },
    trailing: PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') _editRoom(folder, room);
        if (value == 'delete') _deleteRoom(room);
      },
      itemBuilder:
          (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit room')),
            PopupMenuItem(value: 'delete', child: Text('Delete room')),
          ],
    ),
  );

  String _folderSummary(AuditFolder folder) {
    final descendants = <String>{};
    void collect(String parentId) {
      for (final child in project.folders.where(
        (item) => item.parentId == parentId,
      )) {
        if (descendants.add(child.id)) collect(child.id);
      }
    }

    collect(folder.id);
    final roomCount =
        project.spaces
            .where(
              (room) =>
                  room.sectionId == folder.id ||
                  descendants.contains(room.sectionId),
            )
            .length;
    final parts = <String>[];
    if (descendants.isNotEmpty) {
      parts.add(
        '${descendants.length} ${descendants.length == 1 ? 'space' : 'spaces'}',
      );
    }
    if (roomCount > 0) {
      parts.add('$roomCount ${roomCount == 1 ? 'room' : 'rooms'}');
    }
    return parts.isEmpty
        ? '${folder.kind} · Empty'
        : '${folder.kind} · ${parts.join(', ')}';
  }

  Future<void> _showSearch() async {
    final controller = TextEditingController(text: query);
    final value = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Search this project'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Space or room name',
              ),
            ),
            actions: [
              if (query.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, ''),
                  child: const Text('Clear'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(dialogContext, controller.text.trim()),
                child: const Text('Search'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (value != null && mounted) setState(() => query = value);
  }

  Future<void> _showFilters() async {
    final options =
        {
            ...issueTypes.where((value) => value != 'Other'),
            ...AuditScope.of(context).profile.customIssueTypes,
          }.toList()
          ..sort();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => StatefulBuilder(
            builder:
                (context, update) => SafeArea(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * .78,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Filter and sort',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => update(() {
                                      selectedIssues.clear();
                                      onlyNoIssues = false;
                                      sort = RoomSort.custom;
                                    }),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DropdownButtonFormField<RoomSort>(
                            value: sort,
                            decoration: const InputDecoration(
                              labelText: 'Sort rooms',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: RoomSort.custom,
                                child: Text('Custom order'),
                              ),
                              DropdownMenuItem(
                                value: RoomSort.name,
                                child: Text('Name'),
                              ),
                              DropdownMenuItem(
                                value: RoomSort.newest,
                                child: Text('Newest inspection'),
                              ),
                              DropdownMenuItem(
                                value: RoomSort.oldest,
                                child: Text('Oldest inspection'),
                              ),
                              DropdownMenuItem(
                                value: RoomSort.issues,
                                child: Text('Most issues'),
                              ),
                            ],
                            onChanged: (value) => update(() => sort = value!),
                          ),
                        ),
                        CheckboxListTile(
                          value: onlyNoIssues,
                          title: const Text('No issues'),
                          subtitle: const Text(
                            'Only rooms marked as having no issues',
                          ),
                          onChanged:
                              (value) => update(() {
                                onlyNoIssues = value!;
                                if (onlyNoIssues) selectedIssues.clear();
                              }),
                        ),
                        const Divider(height: 1),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Issue types',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children:
                                options
                                    .map(
                                      (issue) => CheckboxListTile(
                                        value: selectedIssues.contains(issue),
                                        title: Text(issue),
                                        onChanged:
                                            (checked) => update(() {
                                              onlyNoIssues = false;
                                              checked!
                                                  ? selectedIssues.add(issue)
                                                  : selectedIssues.remove(
                                                    issue,
                                                  );
                                            }),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              child: const Text('Apply filters'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addFolder({AuditFolder? parent}) async {
    final name = TextEditingController();
    final templates =
        projectTemplate.spaceTemplates.isEmpty
            ? [SpaceTemplate(id: 'space', name: 'Space', kind: 'Space')]
            : projectTemplate.spaceTemplates;
    SpaceTemplate template = templates.first;
    final saved = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, update) => AlertDialog(
                  title: Text(
                    parent == null ? 'Add space' : 'Add nested space',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<SpaceTemplate>(
                        value: template,
                        decoration: const InputDecoration(
                          labelText: 'Template *',
                        ),
                        items:
                            templates
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => update(() => template = value!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: name,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Space name *',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          () => Navigator.pop(
                            dialogContext,
                            name.text.trim().isNotEmpty,
                          ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
    if (saved != true || !mounted) return;
    if (_duplicateFolder(name.text.trim(), parent?.id)) {
      _message('A space with this name already exists here.', error: true);
      return;
    }
    final folder = AuditFolder(
      name: name.text.trim(),
      kind: template.kind,
      parentId: parent?.id,
      sortOrder: _nextFolderOrder(parent?.id),
    );
    setState(() {
      _revealFolder(parent);
      project.folders.add(folder);
      collapsed.remove(folder.id);
      for (var index = 0; index < template.roomNames.length; index++) {
        final roomName = template.roomNames[index];
        project.spaces.add(
          SpaceAudit(
            name: roomName,
            section: folder.name,
            sectionId: folder.id,
            sortOrder: index,
          ),
        );
      }
    });
    AuditScope.of(context).changed();
    _message('${folder.name} added');
  }

  Future<void> _addRoom(AuditFolder folder) async {
    final name = TextEditingController();
    final saved = await _textDialog(
      'Add room to ${folder.name}',
      'Room name *',
      name,
    );
    if (!saved || !mounted) return;
    if (project.spaces.any(
      (room) =>
          room.sectionId == folder.id &&
          room.name.toLowerCase() == name.text.trim().toLowerCase(),
    )) {
      _message('Room names must be unique inside a space.', error: true);
      return;
    }
    setState(() {
      _revealFolder(folder);
      project.spaces.add(
        SpaceAudit(
          name: name.text.trim(),
          section: folder.name,
          sectionId: folder.id,
          sortOrder: _nextRoomOrder(folder.id),
        ),
      );
    });
    AuditScope.of(context).changed();
    _message('${name.text.trim()} added');
  }

  int _nextFolderOrder(String? parentId) {
    final siblings = project.folders.where(
      (folder) => folder.parentId == parentId,
    );
    var highest = -1;
    for (final folder in siblings) {
      if (folder.sortOrder > highest) highest = folder.sortOrder;
    }
    return highest + 1;
  }

  int _nextRoomOrder(String folderId) {
    final rooms = project.spaces.where((room) => room.sectionId == folderId);
    var highest = -1;
    for (final room in rooms) {
      if (room.sortOrder > highest) highest = room.sortOrder;
    }
    return highest + 1;
  }

  Future<void> _arrangeContents(AuditFolder? folder) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => _ArrangeContentsScreen(project: project, folder: folder),
      ),
    );
    if (mounted) setState(() {});
  }

  void _revealFolder(AuditFolder? folder) {
    // Newly-created empty items cannot satisfy issue filters, and a child
    // inside a collapsed ancestor is technically present but invisible. An
    // explicit add should always leave the user looking at what they added.
    query = '';
    selectedIssues.clear();
    onlyNoIssues = false;
    var current = folder;
    while (current != null) {
      collapsed.remove(current.id);
      final parentId = current.parentId;
      AuditFolder? parent;
      if (parentId != null) {
        for (final candidate in project.folders) {
          if (candidate.id == parentId) {
            parent = candidate;
            break;
          }
        }
      }
      current = parent;
    }
  }

  Future<void> _editFolder(AuditFolder folder) async {
    final name = TextEditingController(text: folder.name);
    if (!await _textDialog('Edit space', 'Space name *', name) || !mounted) {
      return;
    }
    if (_duplicateFolder(
      name.text.trim(),
      folder.parentId,
      exceptId: folder.id,
    )) {
      _message('A space with this name already exists here.', error: true);
      return;
    }
    setState(() {
      folder.name = name.text.trim();
      for (final room in project.spaces.where(
        (r) => r.sectionId == folder.id,
      )) {
        room.section = folder.name;
      }
    });
    AuditScope.of(context).changed();
    _message('Space updated');
  }

  Future<void> _editRoom(AuditFolder folder, SpaceAudit room) async {
    final name = TextEditingController(text: room.name);
    if (!await _textDialog('Edit room', 'Room name *', name) || !mounted) {
      return;
    }
    if (project.spaces.any(
      (other) =>
          other.id != room.id &&
          other.sectionId == folder.id &&
          other.name.toLowerCase() == name.text.trim().toLowerCase(),
    )) {
      _message('Room names must be unique inside a space.', error: true);
      return;
    }
    setState(() => room.name = name.text.trim());
    AuditScope.of(context).changed();
    _message('Room updated');
  }

  bool _duplicateFolder(String name, String? parentId, {String? exceptId}) =>
      project.folders.any(
        (folder) =>
            folder.id != exceptId &&
            folder.parentId == parentId &&
            folder.name.toLowerCase() == name.toLowerCase(),
      );

  Future<bool> _textDialog(
    String title,
    String label,
    TextEditingController controller,
  ) async {
    final value = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: label),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(
                      dialogContext,
                      controller.text.trim().isNotEmpty,
                    ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    return value ?? false;
  }

  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
      ) ??
      false;

  Future<void> _deleteRoom(SpaceAudit room) async {
    if (!await _confirm(
      'Delete ${room.name}?',
      'Its inspection, issues and photos will also be deleted.',
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => AuditScope.of(context).deleteSpace(project, room));
    _message('Room deleted');
  }

  Future<void> _deleteFolder(AuditFolder folder) async {
    final descendants = <String>{folder.id};
    var changed = true;
    while (changed) {
      changed = false;
      for (final candidate in project.folders) {
        if (candidate.parentId != null &&
            descendants.contains(candidate.parentId) &&
            descendants.add(candidate.id)) {
          changed = true;
        }
      }
    }
    final rooms =
        project.spaces
            .where((room) => descendants.contains(room.sectionId))
            .toList();
    if (!await _confirm(
      'Delete ${folder.name}?',
      'This deletes ${rooms.length} rooms and every nested space.',
    )) {
      return;
    }
    if (!mounted) return;
    final store = AuditScope.of(context);
    setState(() {
      for (final room in rooms) {
        store.deleteSpace(project, room);
      }
      for (final folderId in descendants) {
        store.queueFolderDeletion(folderId);
      }
      project.folders.removeWhere((item) => descendants.contains(item.id));
    });
    store.changed();
    _message('Space deleted');
  }

  Future<void> _deleteProject() async {
    if (!await _confirm(
      'Delete this project?',
      'All spaces, rooms, inspections, findings and cloud files will be deleted.',
    )) {
      return;
    }
    if (!mounted) return;
    AuditScope.of(context).deleteProject(project);
    Navigator.pop(context);
  }

  Future<void> _showReportOptions() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Export complete report'),
                  onTap: () => Navigator.pop(context, 'all'),
                ),
                ListTile(
                  enabled: selectedIssues.isNotEmpty || onlyNoIssues,
                  leading: const Icon(Icons.filter_alt_outlined),
                  title: const Text('Export current filters'),
                  onTap: () => Navigator.pop(context, 'filtered'),
                ),
              ],
            ),
          ),
    );
    if (choice == null || !mounted) return;
    await ReportService.share(
      project,
      AuditScope.of(context).profile,
      issueFilters: choice == 'filtered' ? selectedIssues : const {},
      noIssuesOnly: choice == 'filtered' && onlyNoIssues,
      issuesOnly: choice == 'filtered' && !onlyNoIssues,
    );
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}

class _ArrangeContentsScreen extends StatefulWidget {
  const _ArrangeContentsScreen({required this.project, required this.folder});

  final AuditProject project;
  final AuditFolder? folder;

  @override
  State<_ArrangeContentsScreen> createState() => _ArrangeContentsScreenState();
}

class _ArrangeContentsScreenState extends State<_ArrangeContentsScreen> {
  int _compare(int left, int right, String leftName, String rightName) {
    final result = left.compareTo(right);
    return result != 0
        ? result
        : leftName.toLowerCase().compareTo(rightName.toLowerCase());
  }

  List<AuditFolder> get _folders =>
      widget.project.folders
          .where((item) => item.parentId == widget.folder?.id)
          .toList()
        ..sort((a, b) => _compare(a.sortOrder, b.sortOrder, a.name, b.name));

  List<SpaceAudit> get _rooms =>
      widget.project.spaces
          .where((item) => item.sectionId == widget.folder?.id)
          .toList()
        ..sort((a, b) => _compare(a.sortOrder, b.sortOrder, a.name, b.name));

  void _reorderFolders(int oldIndex, int newIndex) {
    final items = _folders;
    if (newIndex > oldIndex) newIndex--;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    for (var index = 0; index < items.length; index++) {
      items[index].sortOrder = index;
    }
    AuditScope.of(context).changed();
    setState(() {});
  }

  void _reorderRooms(int oldIndex, int newIndex) {
    final items = _rooms;
    if (newIndex > oldIndex) newIndex--;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    for (var index = 0; index < items.length; index++) {
      items[index].sortOrder = index;
    }
    AuditScope.of(context).changed();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final folders = _folders;
    final rooms = _rooms;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.folder == null
                ? 'Arrange project spaces'
                : 'Arrange ${widget.folder!.name}',
          ),
        ),
        body: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Drag the handle to choose the order used in this project and its report.',
                style: TextStyle(color: muted),
              ),
            ),
            const TabBar(tabs: [Tab(text: 'Spaces'), Tab(text: 'Rooms')]),
            Expanded(
              child: TabBarView(
                children: <Widget>[_folderList(folders), _roomList(rooms)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _folderList(List<AuditFolder> folders) {
    if (folders.isEmpty) return _emptyList('No nested spaces to arrange yet.');
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      buildDefaultDragHandles: false,
      itemCount: folders.length,
      onReorder: _reorderFolders,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return Card(
          key: ValueKey(folder.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.folder_outlined, color: forest),
            title: Text(folder.name),
            subtitle: Text(folder.kind),
            trailing: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle_rounded),
            ),
          ),
        );
      },
    );
  }

  Widget _roomList(List<SpaceAudit> rooms) {
    if (rooms.isEmpty) return _emptyList('No rooms to arrange yet.');
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      buildDefaultDragHandles: false,
      itemCount: rooms.length,
      onReorder: _reorderRooms,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          key: ValueKey(room.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.meeting_room_outlined, color: forest),
            title: Text(room.name),
            trailing: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle_rounded),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyList(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, style: const TextStyle(color: muted)),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.project});
  final AuditProject project;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ink,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.number,
          style: const TextStyle(
            color: brandGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(project.site, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 14),
        Text(
          '${project.folders.length} spaces · ${project.spaces.length} rooms · ${project.issueCount} issues',
          style: const TextStyle(color: Color(0xFFB5BDB9), fontSize: 13),
        ),
      ],
    ),
  );
}

class _EmptyProject extends StatelessWidget {
  const _EmptyProject({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 42),
    child: Column(
      children: [
        const Icon(Icons.account_tree_outlined, size: 42, color: muted),
        const SizedBox(height: 10),
        const Text(
          'No spaces yet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Start with a building, wing, flat, floor or standalone space.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add first space'),
        ),
      ],
    ),
  );
}
