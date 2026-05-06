import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/app_theme.dart';
// import '../services/auth_service.dart'; // Uncomment after Firebase setup
import 'incident_list_screen.dart';
import 'incident_details_screen.dart';
import 'admin_dashboard_screen.dart';
import 'report_incident_screen.dart';
import 'search_filter_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    IncidentListScreen(),
    AdminDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Bottom Navigation ───────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded,    label: 'Home',      index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.list_alt_rounded, label: 'Incidents', index: 1, current: currentIndex, onTap: onTap),
              // Centre FAB
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReportIncidentScreen())),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.critical,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.critical.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0,4))],
                        ),
                        child: const Icon(Icons.add_alert_rounded, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'Admin',  index: 2, current: currentIndex, onTap: onTap),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchFilterScreen())),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                      SizedBox(height: 2),
                      Text('Search', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final void Function(int) onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 22),
              const SizedBox(height: 2),
              Text(label,
                style: TextStyle(
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Tab ───────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentProvider>(
      builder: (ctx, provider, _) => CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Response',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          Text('Campus Safety System',
                            style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11)),
                        ],
                      ),
                    ),
                    _LiveOnlineBadge(),
                    const SizedBox(width: 8),
                    // Logout button
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // await AuthService.signOut(); // Uncomment after Firebase
                                  Navigator.pushAndRemoveUntil(context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      (_) => false);
                                },
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(provider: provider),
                  const SizedBox(height: 16),
                  if (provider.criticalIncidents > 0) ...[
                    _SectionTitle(title: 'Critical Alerts', icon: Icons.warning_rounded, color: AppColors.critical),
                    const SizedBox(height: 8),
                    ...provider.incidents
                        .where((i) => i.priority == IncidentPriority.critical && i.status != IncidentStatus.resolved)
                        .take(3)
                        .map((i) => _CriticalAlertTile(incident: i)),
                    const SizedBox(height: 16),
                  ],
                  _SectionTitle(title: 'Quick Actions', icon: Icons.bolt_rounded, color: AppColors.accent),
                  const SizedBox(height: 8),
                  _QuickActions(),
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'Recent Incidents', icon: Icons.history_rounded, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  if (provider.incidents.isEmpty)
                    _EmptyState()
                  else
                    ...provider.incidents.take(5).map((i) => _RecentTile(incident: i)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widgets ────────────────────────────────────────────────────────────────────

class _LiveOnlineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentProvider>(
      builder: (_, p, __) => GestureDetector(
        onTap: () {
          p.setOnlineStatus(!p.isOnline);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(p.isOnline ? '✓ Online — syncing pending reports' : '⚠ Offline mode — reports saved locally'),
            backgroundColor: p.isOnline ? AppColors.resolved : AppColors.high,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.isOnline ? AppColors.low : AppColors.high, width: 1),
          ),
          child: Row(children: [
            Icon(p.isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 12, color: p.isOnline ? AppColors.low : AppColors.high),
            const SizedBox(width: 4),
            Text(p.isOnline ? 'Online' : 'Offline',
                style: TextStyle(color: p.isOnline ? AppColors.low : AppColors.high, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final IncidentProvider provider;
  const _StatsRow({required this.provider});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(label: 'Total',    value: provider.totalIncidents,    color: AppColors.accent,    icon: Icons.assessment_rounded),
      const SizedBox(width: 8),
      _StatCard(label: 'Active',   value: provider.activeIncidents,   color: AppColors.inProgress, icon: Icons.pending_rounded),
      const SizedBox(width: 8),
      _StatCard(label: 'Resolved', value: provider.resolvedIncidents, color: AppColors.resolved,  icon: Icons.check_circle_rounded),
      const SizedBox(width: 8),
      _StatCard(label: 'Critical', value: provider.criticalIncidents, color: AppColors.critical,  icon: Icons.warning_rounded,
          highlight: provider.criticalIncidents > 0),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool highlight;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: highlight ? color.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: highlight ? color.withValues(alpha: 0.4) : AppColors.cardBorder),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text('$value', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionTitle({required this.title, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 6),
      Text(title.toUpperCase(),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    ]);
  }
}

class _CriticalAlertTile extends StatelessWidget {
  final Incident incident;
  const _CriticalAlertTile({required this.incident});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incidentId: incident.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.criticalBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_rounded, color: AppColors.critical, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(incident.title, style: const TextStyle(color: AppColors.critical, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(incident.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.critical, size: 16),
        ]),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.add_alert_rounded, label: 'Report', color: AppColors.critical,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIncidentScreen()))),
      (icon: Icons.list_alt_rounded, label: 'All Incidents', color: AppColors.inProgress,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncidentListScreen()))),
      (icon: Icons.admin_panel_settings_rounded, label: 'Admin', color: AppColors.security,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()))),
      (icon: Icons.search_rounded, label: 'Search', color: AppColors.accent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchFilterScreen()))),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.0,
      children: actions.map((a) => GestureDetector(
        onTap: a.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: a.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: a.color.withValues(alpha: 0.2)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(a.icon, color: a.color, size: 18),
            const SizedBox(width: 6),
            Text(a.label, style: TextStyle(color: a.color, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      )).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(children: [
        Icon(Icons.shield_outlined, size: 48, color: AppColors.textHint),
        const SizedBox(height: 10),
        const Text('No incidents reported', style: TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final Incident incident;
  const _RecentTile({required this.incident});
  @override
  Widget build(BuildContext context) {
    final catColor = getCategoryColor(incident.category);
    final prColor  = getPriorityColor(incident.priority);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incidentId: incident.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(children: [
          Container(width: 3, height: 36,
              decoration: BoxDecoration(color: prColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Icon(getCategoryIcon(incident.category), color: catColor, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(incident.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(incident.categoryLabel, style: TextStyle(color: catColor, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _PriorityPill(priority: incident.priority),
            const SizedBox(height: 2),
            Text(_timeAgo(incident.reportedAt),
                style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return DateFormat('MMM dd').format(dt);
  }
}

class _PriorityPill extends StatelessWidget {
  final IncidentPriority priority;
  const _PriorityPill({required this.priority});
  @override
  Widget build(BuildContext context) {
    final c = getPriorityColor(priority);
    final bg = getPriorityBgColor(priority);
    final label = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
        priority:priority,status:IncidentStatus.reported,location:'',reportedAt:DateTime.now()).priorityLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
