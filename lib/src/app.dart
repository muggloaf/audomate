import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens/auth_gate.dart';
import 'supabase_config.dart';
import 'theme.dart';

class SiteSageApp extends StatefulWidget {
  const SiteSageApp({super.key, this.store});

  final AuditStore? store;
  @override
  State<SiteSageApp> createState() => _SiteSageAppState();
}

class _SiteSageAppState extends State<SiteSageApp> {
  late final AuditStore store = widget.store ?? AuditStore();

  @override
  void initState() {
    super.initState();
    if (!store.isReady) {
      store.initialize(userId: SupabaseConfig.client?.auth.currentUser?.id);
    }
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder:
        (context, _) => AuditScope(
          store: store,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'audomate',
            theme: buildTheme(),
            darkTheme: buildDarkTheme(),
            themeMode:
                store.profile.darkMode ? ThemeMode.dark : ThemeMode.light,
            home:
                store.isReady
                    ? AuthGate(store: store)
                    : const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
          ),
        ),
  );
}
