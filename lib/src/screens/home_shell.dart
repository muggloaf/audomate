import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/brand_wordmark.dart';
import 'new_project_screen.dart';
import 'profile_screen.dart';
import 'project_screen.dart';
import 'templates_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (index) {
          1 => const TemplatesScreen(),
          2 => const ProfileScreen(),
          _ => const ProjectsView(),
        },
      ),
      floatingActionButton:
          index == 0
              ? FloatingActionButton.extended(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewProjectScreen(),
                      ),
                    ),
                icon: const Icon(Icons.add),
                label: const Text('New project'),
              )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_outlined),
            selectedIcon: Icon(Icons.dashboard_customize),
            label: 'Templates',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

enum ProjectSort { newest, oldest, name, projectNumber }

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  String query = '';
  ProjectSort sort = ProjectSort.newest;

  @override
  Widget build(BuildContext context) {
    final store = AuditScope.of(context);
    final projects =
        store.projects.where((project) {
          final text =
              '${project.name} ${project.site} ${project.number}'.toLowerCase();
          return text.contains(query.toLowerCase());
        }).toList();
    projects.sort(
      (a, b) => switch (sort) {
        ProjectSort.newest => b.createdAt.compareTo(a.createdAt),
        ProjectSort.oldest => a.createdAt.compareTo(b.createdAt),
        ProjectSort.name => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
        ProjectSort.projectNumber => a.number.toLowerCase().compareTo(
          b.number.toLowerCase(),
        ),
      },
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF303633)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrandWordmark(fontSize: 22),
                      SizedBox(height: 5),
                      Text(
                        'Structural audit companion',
                        style: TextStyle(
                          color: Color(0xFFAAB3AE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      store.syncError != null
                          ? 'Sync failed — tap to retry'
                          : store.isSyncing
                          ? 'Syncing…'
                          : store.pendingSync
                          ? 'Waiting to sync'
                          : 'All changes synced',
                  onPressed:
                      store.isSyncing
                          ? null
                          : () async {
                            await store.syncNow();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  store.syncError == null
                                      ? 'Synced to cloud'
                                      : 'Could not sync: ${store.syncError}',
                                ),
                              ),
                            );
                          },
                  icon:
                      store.isSyncing
                          ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(
                            store.syncError != null
                                ? Icons.cloud_off_outlined
                                : store.pendingSync
                                ? Icons.cloud_upload_outlined
                                : Icons.cloud_done_outlined,
                            color:
                                store.syncError != null
                                    ? Theme.of(context).colorScheme.error
                                    : brandGreen,
                          ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Good ${DateTime.now().hour < 12 ? 'morning' : 'evening'},',
            style: const TextStyle(fontSize: 15, color: muted),
          ),
          const Text(
            'Ready for the next inspection?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (value) => setState(() => query = value.trim()),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search projects',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<ProjectSort>(
                  value: sort,
                  decoration: const InputDecoration(labelText: 'Sort'),
                  items: const [
                    DropdownMenuItem(
                      value: ProjectSort.newest,
                      child: Text('Newest'),
                    ),
                    DropdownMenuItem(
                      value: ProjectSort.oldest,
                      child: Text('Oldest'),
                    ),
                    DropdownMenuItem(
                      value: ProjectSort.name,
                      child: Text('Name'),
                    ),
                    DropdownMenuItem(
                      value: ProjectSort.projectNumber,
                      child: Text('Number'),
                    ),
                  ],
                  onChanged: (value) => setState(() => sort = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent projects',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${projects.length} total',
                style: const TextStyle(color: muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _ProjectCard(project: projects[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});
  final AuditProject project;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProjectScreen(project: project)),
          ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: sand,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      project.coverPhoto == null
                          ? const Icon(
                            Icons.apartment_rounded,
                            color: forest,
                            size: 28,
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              project.coverPhoto!.bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.site,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: muted, height: 1.25),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        project.number,
                        style: const TextStyle(
                          color: forest,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: muted),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: project.progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFE7E5DC),
                color: forest,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Text(
                  '${project.completed} of ${project.spaces.length} spaces audited',
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const Spacer(),
                if (project.issueCount > 0)
                  Text(
                    '${project.issueCount} issues',
                    style: const TextStyle(
                      color: Color(0xFF9B5F43),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class IssuesView extends StatefulWidget {
  const IssuesView({super.key});
  @override
  State<IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<IssuesView> {
  String filter = 'All issues';
  @override
  Widget build(BuildContext context) {
    final projects = AuditScope.of(context).projects;
    final rows =
        <({AuditProject project, SpaceAudit space, Finding finding})>[];
    for (final p in projects) {
      for (final s in p.spaces) {
        for (final f in s.findings) {
          if (filter == 'All issues' || f.type == filter) {
            rows.add((project: p, space: s, finding: f));
          }
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Issue register',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            'Find every occurrence across all projects.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: filter,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.filter_list_rounded),
              labelText: 'Filter by issue',
            ),
            items:
                ['All issues', ...issueTypes]
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
            onChanged: (v) => setState(() => filter = v!),
          ),
          const SizedBox(height: 14),
          Expanded(
            child:
                rows.isEmpty
                    ? const Center(child: Text('No matching issues found.'))
                    : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final r = rows[i];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF5E6DE),
                              foregroundColor: const Color(0xFF9B5F43),
                              child: const Icon(Icons.priority_high_rounded),
                            ),
                            title: Text(
                              r.finding.type,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${r.space.name} · ${r.space.section}\n${r.project.name}',
                                style: const TextStyle(height: 1.35),
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
