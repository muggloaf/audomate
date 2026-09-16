# audomate

A local-first structural-audit application built with Flutter and Supabase.

## Local database

Audomate uses a per-user Drift/SQLite database as its offline source of truth.
Existing `audomate_user_*.json` snapshots are imported automatically the first
time the matching user database opens. The JSON file is deliberately retained
as a recovery backup after a successful import.

After changing tables in `lib/src/local_database.dart`, regenerate bindings:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Flutter Web requires the checked-in `web/sqlite3.wasm` and
`web/drift_worker.dart.js` files. They match sqlite3 2.9.4 and Drift 2.30.0.
