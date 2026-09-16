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
  final keyForm = GlobalKey<FormState>();
  final name = TextEditingController();
  final site = TextEditingController();
  final number = TextEditingController(text: 'SA-${DateTime.now().year}-');
  final section = TextEditingController(text: 'Main Building');
  final count = TextEditingController(text: '10');
  final prefix = TextEditingController(text: 'Room');
  PhotoData? cover;

  Future<void> pickCover() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (r?.files.single.bytes != null) {
      setState(
        () =>
            cover = PhotoData(
              bytes: r!.files.single.bytes!,
              name: r.files.single.name,
            ),
      );
    }
  }

  void create() {
    if (!keyForm.currentState!.validate()) return;
    final n = int.tryParse(count.text) ?? 1;
    final sectionId = newId();
    final spaces = List.generate(
      n,
      (i) => SpaceAudit(
        name: '${prefix.text.trim()} ${i + 1}',
        section: section.text.trim(),
        sectionId: sectionId,
      ),
    );
    final p = AuditProject(
      number: number.text.trim(),
      name: name.text.trim(),
      site: site.text.trim(),
      createdAt: DateTime.now(),
      spaces: spaces,
      coverPhoto: cover,
    );
    AuditScope.of(context).addProject(p);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ProjectScreen(project: p)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New audit project')),
    body: Form(
      key: keyForm,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          InkWell(
            onTap: pickCover,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 155,
              decoration: BoxDecoration(
                color: sand,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDDD9CF)),
              ),
              child:
                  cover == null
                      ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: forest,
                            size: 32,
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
                        borderRadius: BorderRadius.circular(17),
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
            decoration: const InputDecoration(labelText: 'Project name'),
            validator:
                (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Enter a project name'
                        : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: site,
            decoration: const InputDecoration(labelText: 'Site address'),
            maxLines: 2,
            validator:
                (v) => v == null || v.trim().isEmpty ? 'Enter the site' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: number,
            decoration: const InputDecoration(labelText: 'Project number'),
            validator:
                (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Enter a project number'
                        : null,
          ),
          const SizedBox(height: 24),
          const Text(
            'Add spaces quickly',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            'Create a building/floor folder and its rooms. More can be added later.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: section,
            decoration: const InputDecoration(
              labelText: 'Folder / building / wing',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: prefix,
                  decoration: const InputDecoration(labelText: 'Space label'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: count,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Count'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 1 || n > 500 ? '1–500' : null;
                  },
                ),
              ),
            ],
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
