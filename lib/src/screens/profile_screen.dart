import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_state.dart';
import '../models.dart';
import '../supabase_config.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> changePassword() async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Change password'),
            content: TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, controller.text),
                child: const Text('Update'),
              ),
            ],
          ),
    );
    if (password == null || password.length < 8 || !mounted) return;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } on AuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Delete account permanently?'),
            content: const Text(
              'This removes your account and, if you are the only organisation owner, its audit data and files. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Delete account'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await Supabase.instance.client.functions.invoke('delete-account');
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account deletion could not be completed. Please try again.',
            ),
          ),
        );
    }
  }

  Future<void> pick(bool signature) async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (r?.files.single.bytes == null || !mounted) return;
    final photo = PhotoData(
      bytes: r!.files.single.bytes!,
      name: r.files.single.name,
    );
    final p = AuditScope.of(context).profile;
    setState(() {
      if (signature) {
        p.signature = photo;
        p.signatureRemotePath = null;
      } else {
        p.letterhead = photo;
        p.letterheadRemotePath = null;
      }
    });
    AuditScope.of(context).changed();
  }

  @override
  Widget build(BuildContext context) {
    final p = AuditScope.of(context).profile;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const Text(
          'Report profile',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'These details are placed on every exported report.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _UploadCard(
                title: 'Letterhead',
                photo: p.letterhead,
                icon: Icons.branding_watermark_outlined,
                onTap: () => pick(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UploadCard(
                title: 'Signature',
                photo: p.signature,
                icon: Icons.draw_outlined,
                onTap: () => pick(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextFormField(
          initialValue: p.organisation,
          onChanged: (v) {
            p.organisation = v;
            AuditScope.of(context).changed();
          },
          decoration: const InputDecoration(labelText: 'Firm / organisation'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: p.name,
          onChanged: (v) {
            p.name = v;
            AuditScope.of(context).changed();
          },
          decoration: const InputDecoration(labelText: 'Engineer name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: p.designation,
          onChanged: (v) {
            p.designation = v;
            AuditScope.of(context).changed();
          },
          decoration: const InputDecoration(labelText: 'Designation'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: p.licence,
          onChanged: (v) {
            p.licence = v;
            AuditScope.of(context).changed();
          },
          decoration: const InputDecoration(
            labelText: 'Licence / registration number',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: p.phone,
          onChanged: (v) {
            p.phone = v;
            AuditScope.of(context).changed();
          },
          decoration: const InputDecoration(labelText: 'Phone (optional)'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: p.email,
          onChanged: (v) {
            p.email = v;
            AuditScope.of(context).changed();
          },
          decoration: const InputDecoration(labelText: 'Email (optional)'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            value: p.darkMode,
            title: const Text(
              'Dark mode',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            secondary: Icon(
              p.darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            onChanged: (v) {
              p.darkMode = v;
              AuditScope.of(context).changed();
            },
          ),
        ),
        if (SupabaseConfig.isConfigured) ...[
          const SizedBox(height: 20),
          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: changePassword,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined),
                  title: const Text('Delete account'),
                  textColor: Theme.of(context).colorScheme.error,
                  iconColor: Theme.of(context).colorScheme.error,
                  onTap: deleteAccount,
                ),
              ],
            ),
          ),
        ],
        if (SupabaseConfig.isConfigured) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.photo,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final PhotoData? photo;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 126,
        child:
            photo == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: forest, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Add $title',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                )
                : Padding(
                  padding: const EdgeInsets.all(9),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.memory(photo!.bytes, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    ),
  );
}
