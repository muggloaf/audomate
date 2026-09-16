import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_state.dart';
import '../supabase_config.dart';
import 'auth_screen.dart';
import 'home_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.store});
  final AuditStore store;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? syncedUserId;
  String? restoredProfileUserId;
  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const _MissingSupabaseConfiguration();
    }
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final user = snapshot.data?.session?.user;
        if (user == null) {
          syncedUserId = null;
          restoredProfileUserId = null;
          if (widget.store.activeUserId != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => widget.store.activateUser(null),
            );
          }
          return AuthScreen(store: widget.store);
        }
        if (widget.store.activeUserId != user.id) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.store.activateUser(user.id),
          );
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!widget.store.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (restoredProfileUserId != user.id) {
          restoredProfileUserId = user.id;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.store.restoreSignupProfile(
              user.userMetadata ?? const <String, dynamic>{},
              email: user.email,
            ),
          );
        }
        if (syncedUserId != user.id) {
          syncedUserId = user.id;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.store.syncNow(),
          );
        }
        return const HomeShell();
      },
    );
  }
}

class _MissingSupabaseConfiguration extends StatelessWidget {
  const _MissingSupabaseConfiguration();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 38,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Supabase configuration missing',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'For security, audomate cannot open the workspace without authentication. Launch it using the Audomate configuration.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
