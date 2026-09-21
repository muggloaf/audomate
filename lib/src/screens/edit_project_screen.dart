import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({super.key, required this.project});
  final AuditProject project;
  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late final number = TextEditingController(text: widget.project.number);
  late final name = TextEditingController(text: widget.project.name);
  late final site = TextEditingController(text: widget.project.site);
  late final preamble = TextEditingController(text: widget.project.preamble);
  late final conclusion = TextEditingController(
    text: widget.project.conclusion,
  );
  Future<void> pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result?.files.single.bytes != null) {
      setState(
        () =>
            widget.project.coverPhoto = PhotoData(
              bytes: result!.files.single.bytes!,
              name: result.files.single.name,
            ),
      );
    }
  }

  void save() {
    if (name.text.trim().isEmpty ||
        number.text.trim().isEmpty ||
        site.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name, address and project number are required.'),
        ),
      );
      return;
    }
    final duplicate = AuditScope.of(context).projects.any(
      (project) =>
          project.id != widget.project.id &&
          (project.number.toLowerCase() == number.text.trim().toLowerCase() ||
              (project.name.toLowerCase() == name.text.trim().toLowerCase() &&
                  project.site.toLowerCase() ==
                      site.text.trim().toLowerCase())),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That project number or name/address already exists.'),
        ),
      );
      return;
    }
    widget.project.number = number.text.trim();
    widget.project.name = name.text.trim();
    widget.project.site = site.text.trim();
    widget.project.preamble = preamble.text.trim();
    widget.project.conclusion = conclusion.text.trim();
    AuditScope.of(context).changed();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Project settings')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        InkWell(
          onTap: pickCover,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              color: sand,
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                widget.project.coverPhoto == null
                    ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: forest,
                          size: 30,
                        ),
                        SizedBox(height: 8),
                        Text('Add project photo'),
                      ],
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        widget.project.coverPhoto!.bytes,
                        fit: BoxFit.cover,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Project name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: number,
          decoration: const InputDecoration(labelText: 'Project number'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: site,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Site address'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: preamble,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Report preamble'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: conclusion,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Report conclusion'),
        ),
        const SizedBox(height: 22),
        FilledButton(onPressed: save, child: const Text('Save changes')),
      ],
    ),
  );
}
