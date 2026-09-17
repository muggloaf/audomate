# audomate

Local-first structural audit software for creating, documenting, and reporting building inspections. audomate simplifies the process of auditing buildings - be it for a school, hospital, housing society, or more - by helping engineers easily document issues, monitor them, and generate structured reports all at once.

## The Problem

Structural inspection teams often need to capture findings room-by-room, attach photos, and issue professional reports while working across unstable network conditions. In practice, this creates friction:

- field notes and media can be spread across disconnected tools,
- report preparation can duplicate data entry,
- and intermittent connectivity can interrupt cloud-first workflows.

## The Solution

audomate keeps inspection work local-first and project-structured, then syncs when possible.

It models audits around:

- **Projects**: site-level audit records with metadata and cover media
- **Spaces/rooms**: nested structures (for example building → floor → flat → room)
- **Findings**: issue type, location, severity, notes, and recommendation
- **Photos**: attachments on findings and report/profile assets
- **Templates**: reusable project and space templates (including suggested room names)
- **Profiles**: engineer and organisation details used in exported reports
- **Reports**: PDF report generation and sharing from current project data

## How it works

1. **Create a project** with number, name, site, type/template, and optional cover photo.
2. **Build the inspection structure** using folders/spaces and room entries.
3. **Record inspection outcomes** by marking no-issue rooms or adding findings with severity, notes, and photos.
4. **Review and filter data** with search/sort/filter tools across projects and within project trees.
5. **Export reports to PDF** as complete, filtered, or issue-focused deliverables.
6. **Sync in background (optional at runtime)** after authenticated Supabase sign-in; local storage remains the source of truth and sync retries failed operations.

## Features

- Offline-first, per-user persistence using **Drift + SQLite**
- One-time import of legacy `audomate_user_*.json` snapshots into relational storage
- Legacy JSON snapshots are retained after import for recovery backup
- Project, folder, room, finding, profile, and media modeling
- Photo attachments for findings, project covers, report letterhead, and signatures
- Reusable project/space templates with custom template editing
- Search/sort for projects; search/filter/sort and issue filtering within project views
- Cross-project issue browsing
- Branded PDF report generation/sharing with filtered export modes
- Supabase authentication-gated workspace access
- Background push/pull sync with queued deletes and retry/backoff behavior when connectivity fails

## Tech stack

| Area | Technology |
| --- | --- |
| App framework | Flutter (Dart) |
| Local persistence | Drift (`drift`, `drift_flutter`) + SQLite |
| Cloud/auth/sync | Supabase (`supabase_flutter`) |
| Reports | `pdf`, `printing` |
| Media/files | `image_picker`, `file_picker` |
| Local storage paths | `path_provider` |
| IDs | `uuid` |

<hr>

made for my dad, who's a structural engineer! :)
