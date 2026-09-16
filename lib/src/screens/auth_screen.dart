import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../app_state.dart';
import '../widgets/brand_wordmark.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.store});
  final AuditStore store;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final organisation = TextEditingController();
  final designation = TextEditingController(text: 'Structural Engineer');
  final licence = TextEditingController();
  bool createAccount = false;
  bool busy = false;
  String? error;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      setState(
        () => error = 'Enter an email and a password of at least 6 characters.',
      );
      return;
    }
    if (createAccount &&
        [
          name,
          organisation,
          designation,
          licence,
        ].any((c) => c.text.trim().isEmpty)) {
      setState(() => error = 'Complete all professional details.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (createAccount) {
        final result = await Supabase.instance.client.auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {
            'full_name': name.text.trim(),
            'organisation_name': organisation.text.trim(),
            'designation': designation.text.trim(),
            'licence_number': licence.text.trim(),
          },
        );
        if (result.session != null) {
          await widget.store.activateUser(result.user!.id);
        }
        widget.store.profile.name = name.text.trim();
        widget.store.profile.organisation = organisation.text.trim();
        widget.store.profile.designation = designation.text.trim();
        widget.store.profile.licence = licence.text.trim();
        widget.store.changed();
        if (result.session == null && mounted) {
          setState(
            () =>
                error =
                    'Account created. Check your email to confirm it, then sign in.',
          );
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not connect. Your local audits remain safe.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const BrandWordmark(fontSize: 26),
                ),
                const SizedBox(height: 24),
                Text(
                  createAccount ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  createAccount
                      ? 'Your practice workspace will be created automatically.'
                      : 'Sign in to sync your audits securely.',
                  style: const TextStyle(color: muted, fontSize: 15),
                ),
                const SizedBox(height: 26),
                if (createAccount) ...[
                  TextField(
                    controller: name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Engineer name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: organisation,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Firm / organisation *',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: designation,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Designation *',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: licence,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Licence number *',
                      prefixIcon: Icon(Icons.verified_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  onSubmitted: (_) => submit(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color:
                            error!.startsWith('Account created')
                                ? forest
                                : Theme.of(context).colorScheme.error,
                        height: 1.35,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _AuthPrimaryButton(
                  busy: busy,
                  label: createAccount ? 'Create account' : 'Sign in',
                  onPressed: submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed:
                      busy
                          ? null
                          : () => setState(() {
                            createAccount = !createAccount;
                            error = null;
                          }),
                  child: Text(
                    createAccount
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    organisation.dispose();
    designation.dispose();
    licence.dispose();
    super.dispose();
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.busy,
    required this.label,
    required this.onPressed,
  });

  final bool busy;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: !busy,
    label: label,
    child: MouseRegion(
      cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: busy ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: busy ? forest.withValues(alpha: 0.7) : forest,
            borderRadius: BorderRadius.circular(9),
          ),
          child:
              busy
                  ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    ),
  );
}
