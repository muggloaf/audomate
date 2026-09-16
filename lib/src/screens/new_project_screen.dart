import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import 'project_screen.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final site = TextEditingController();
  final number = TextEditingController(text: 'SA-${DateTime.now().year}-');
  ProjectTemplate? template;
  PhotoData? cover;

  Future<void> pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result?.files.single.bytes == null || !mounted) return;
    setState(
      () =>
          cover = PhotoData(
            bytes: result!.files.single.bytes!,
            name: result.files.single.name,
          ),
    );
  }

  void create() {
    if (!formKey.currentState!.validate()) return;
    final store = AuditScope.of(context);
    final duplicate = store.projects.any(
      (project) =>
          project.number.toLowerCase() == number.text.trim().toLowerCase() ||
          (project.name.toLowerCase() == name.text.trim().toLowerCase() &&
              project.site.toLowerCase() == site.text.trim().toLowerCase()),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Project number must be unique, and the same name cannot be reused at the same address.',
          ),
        ),
      );
      return;
    }
    final project = AuditProject(
      number: number.text.trim(),
      name: name.text.trim(),
      site: site.text.trim(),
      createdAt: DateTime.now(),
      spaces: [],
      folders: [],
      coverPhoto: cover,
      projectType: template!.id,
    );
    store.addProject(project);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ProjectScreen(project: project)),
    );
  }

  @override
  void dispose() {
    name.dispose();
    site.dispose();
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = AuditScope.of(context).profile.projectTemplates;
    template ??= templates.isEmpty ? null : templates.first;
    return Scaffold(
      appBar: AppBar(title: const Text('New audit project')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            InkWell(
              onTap: pickCover,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 155,
                decoration: BoxDecoration(
                  color: sand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDE3DF)),
                ),
                child:
                    cover == null
                        ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: forest,
                              size: 30,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add project cover photo',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Used on the report cover',
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.memory(
                            cover!.bytes,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Project details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Project name *'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: site,
              decoration: const InputDecoration(labelText: 'Site address *'),
              maxLines: 2,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: number,
              decoration: const InputDecoration(labelText: 'Project number *'),
              validator: _required,
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<ProjectTemplate>(
              value: template,
              decoration: const InputDecoration(
                labelText: 'Institution / project type *',
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
              validator:
                  (value) =>
                      value == null ? 'Create a project template first' : null,
              onChanged: (value) => setState(() => template = value),
            ),
            const SizedBox(height: 7),
            const Text(
              'Templates suggest useful space types. Add buildings, flats and rooms after creating the project.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: create,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Create project'),
            ),
          ],
        ),
      ),
    );
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}
