import 'package:flutter/material.dart';

Future<String?> showSearchPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder:
      (_) => _SearchPicker(title: title, options: options, selected: selected),
);

class _SearchPicker extends StatefulWidget {
  const _SearchPicker({
    required this.title,
    required this.options,
    this.selected,
  });
  final String title;
  final List<String> options;
  final String? selected;
  @override
  State<_SearchPicker> createState() => _SearchPickerState();
}

class _SearchPickerState extends State<_SearchPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final values =
        widget.options
            .where((v) => v.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Type to search…',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: values.length,
                itemBuilder: (_, i) {
                  final value = values[i];
                  return ListTile(
                    title: Text(value),
                    trailing:
                        value == widget.selected
                            ? const Icon(Icons.check)
                            : null,
                    onTap: () => Navigator.pop(context, value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
