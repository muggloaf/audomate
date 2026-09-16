import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = AuditScope.of(context).profile.projectTemplates;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('New template'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
        itemCount: templates.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Templates',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Project structures and their available spaces.',
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
            );
          }
          final template = templates[index - 1];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              leading: const Icon(
                Icons.dashboard_customize_outlined,
                color: forest,
              ),
              title: Text(
                template.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${template.spaceTemplates.length} space ${template.spaceTemplates.length == 1 ? 'type' : 'types'}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemplateDetailScreen(template: template),
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final name = await _ask(context, 'New project template', 'Template name');
    if (name == null || !context.mounted) return;
    final store = AuditScope.of(context);
    if (store.profile.projectTemplates.any(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    )) {
      _message(context, 'A template with that name already exists.');
      return;
    }
    final template = ProjectTemplate(
      id: newId(),
      name: name,
      spaceTemplates: [],
    );
    store.profile.projectTemplates.add(template);
    store.changed();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplateDetailScreen(template: template),
      ),
    );
  }
}

class TemplateDetailScreen extends StatefulWidget {
  const TemplateDetailScreen({super.key, required this.template});
  final ProjectTemplate template;
  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  ProjectTemplate get template => widget.template;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(template.name),
      actions: [
        IconButton(
          tooltip: 'Edit template',
          onPressed: _rename,
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addSpace,
      icon: const Icon(Icons.add),
      label: const Text('Add space type'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        Text(
          'Space templates',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'These appear when adding a space inside this type of project.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 18),
        if (template.spaceTemplates.isEmpty)
          const _Empty(
            text: 'No space templates yet. Add one when you are ready.',
          )
        else
          ...template.spaceTemplates.map(
            (space) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  leading: const Icon(
                    Icons.account_tree_outlined,
                    color: forest,
                  ),
                  title: Text(
                    space.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    space.roomNames.isEmpty
                        ? space.kind
                        : '${space.kind} · ${space.roomNames.length} suggested rooms',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => SpaceTemplateDetailScreen(
                              parent: template,
                              space: space,
                            ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete project template'),
        ),
      ],
    ),
  );

  Future<void> _rename() async {
    final name = await _ask(
      context,
      'Edit project template',
      'Template name',
      initial: template.name,
    );
    if (name == null || !mounted) return;
    setState(() => template.name = name);
    AuditScope.of(context).changed();
  }

  Future<void> _addSpace() async {
    final name = await _ask(context, 'New space template', 'Space type name');
    if (name == null || !mounted) return;
    if (template.spaceTemplates.any(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    )) {
      _message(context, 'That space type already exists here.');
      return;
    }
    final space = SpaceTemplate(
      id: newId(),
      name: name,
      kind: name,
      roomNames: [],
    );
    setState(() => template.spaceTemplates.add(space));
    AuditScope.of(context).changed();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SpaceTemplateDetailScreen(parent: template, space: space),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    if (!await _confirm(
      context,
      'Delete ${template.name}?',
      'Existing projects will not be changed.',
    ))
      {return;}
    if (!mounted) return;
    AuditScope.of(context).profile.projectTemplates.remove(template);
    AuditScope.of(context).changed();
    Navigator.pop(context);
  }
}

class SpaceTemplateDetailScreen extends StatefulWidget {
  const SpaceTemplateDetailScreen({
    super.key,
    required this.parent,
    required this.space,
  });
  final ProjectTemplate parent;
  final SpaceTemplate space;
  @override
  State<SpaceTemplateDetailScreen> createState() =>
      _SpaceTemplateDetailScreenState();
}

class _SpaceTemplateDetailScreenState extends State<SpaceTemplateDetailScreen> {
  SpaceTemplate get space => widget.space;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(space.name),
      actions: [
        IconButton(
          tooltip: 'Edit space template',
          onPressed: _rename,
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addRoom,
      icon: const Icon(Icons.add),
      label: const Text('Add suggested room'),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        Text(
          'Suggested rooms',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Tap a room to edit it. Empty spaces remain valid and are saved.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 18),
        if (space.roomNames.isEmpty)
          const _Empty(
            text:
                'No suggested rooms. This template can still create an empty space.',
          )
        else
          ...space.roomNames.map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.meeting_room_outlined,
                    color: forest,
                  ),
                  title: Text(room),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openRoom(room),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete space template'),
        ),
      ],
    ),
  );

  Future<void> _rename() async {
    final name = await _ask(
      context,
      'Edit space template',
      'Name',
      initial: space.name,
    );
    if (name == null || !mounted) return;
    setState(() {
      space.name = name;
      space.kind = name;
    });
    AuditScope.of(context).changed();
  }

  Future<void> _addRoom() async {
    final name = await _ask(context, 'Add suggested room', 'Room name');
    if (name == null || !mounted) return;
    if (space.roomNames.any(
      (item) => item.toLowerCase() == name.toLowerCase(),
    )) {
      _message(context, 'That room already exists.');
      return;
    }
    setState(() => space.roomNames.add(name));
    AuditScope.of(context).changed();
  }

  Future<void> _openRoom(String room) async {
    final value = await _ask(
      context,
      'Edit suggested room',
      'Room name',
      initial: room,
    );
    if (value == null || !mounted) return;
    final delete = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Save room'),
            content: const Text(
              'Save the new name, or delete this suggested room.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (delete == null || !mounted) return;
    final index = space.roomNames.indexOf(room);
    if (delete) {
      if (!await _confirm(
        context,
        'Delete $room?',
        'This only changes the template.',
      )) {
        return;
      }
      if (!mounted) return;
      space.roomNames.removeAt(index);
    } else {
      space.roomNames[index] = value;
    }
    setState(() {});
    AuditScope.of(context).changed();
  }

  Future<void> _delete() async {
    if (!await _confirm(
      context,
      'Delete ${space.name}?',
      'Existing project spaces will not be changed.',
    )) {
      return;
    }
    if (!mounted) return;
    widget.parent.spaceTemplates.remove(space);
    AuditScope.of(context).changed();
    Navigator.pop(context);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(text, style: const TextStyle(color: muted, height: 1.4)),
  );
}

Future<String?> _ask(
  BuildContext context,
  String title,
  String label, {
  String initial = '',
}) => showDialog<String>(
  context: context,
  builder: (_) => _TemplateTextDialog(
    title: title,
    label: label,
    initial: initial,
  ),
);

class _TemplateTextDialog extends StatefulWidget {
  const _TemplateTextDialog({
    required this.title,
    required this.label,
    required this.initial,
  });

  final String title;
  final String label;
  final String initial;

  @override
  State<_TemplateTextDialog> createState() => _TemplateTextDialogState();
}

class _TemplateTextDialogState extends State<_TemplateTextDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(labelText: '${widget.label} *'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Continue')),
    ],
  );

  void _submit() {
    final value = controller.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }
}

Future<bool> _confirm(BuildContext context, String title, String body) async =>
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

void _message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
