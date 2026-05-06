import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/app_theme.dart';
import 'incident_details_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Consumer<IncidentProvider>(
            builder: (_, p, __) => IconButton(
              icon: Icon(p.isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: p.isOnline ? AppColors.low : AppColors.high),
              tooltip: p.isOnline ? 'Online — tap to go offline' : 'Offline — tap to go online',
              onPressed: () {
                p.setOnlineStatus(!p.isOnline);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(p.isOnline
                      ? '✓ Online — ${p.unsyncedIncidents} incident(s) synced'
                      : '⚠ Offline mode enabled'),
                  backgroundColor: p.isOnline ? AppColors.resolved : AppColors.high,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ));
              },
            ),
          ),
        ],
      ),
      body: Consumer<IncidentProvider>(
        builder: (_, provider, __) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // Stats
            _SectionLabel(title: 'Overview', icon: Icons.bar_chart_rounded),
            const SizedBox(height: 8),
            Row(children: [
              _Stat(label: 'Total',    value: provider.totalIncidents,    color: AppColors.accent,    icon: Icons.assessment_rounded),
              const SizedBox(width: 8),
              _Stat(label: 'Active',   value: provider.activeIncidents,   color: AppColors.inProgress, icon: Icons.pending_rounded),
              const SizedBox(width: 8),
              _Stat(label: 'Resolved', value: provider.resolvedIncidents, color: AppColors.resolved,  icon: Icons.check_circle_rounded),
              const SizedBox(width: 8),
              _Stat(label: 'Critical', value: provider.criticalIncidents, color: AppColors.critical,  icon: Icons.warning_rounded,
                  highlight: provider.criticalIncidents > 0),
            ]),
            const SizedBox(height: 16),

            // Priority Distribution
            if (provider.totalIncidents > 0) ...[
              _SectionLabel(title: 'Priority Distribution', icon: Icons.donut_large_rounded),
              const SizedBox(height: 8),
              _PriorityChart(provider: provider),
              const SizedBox(height: 16),
            ],

            // Active Incidents
            _SectionLabel(title: 'Active Incidents — Manage', icon: Icons.manage_search_rounded),
            const SizedBox(height: 8),

            ...provider.incidents
                .where((i) => i.status != IncidentStatus.resolved)
                .map((i) => _AdminCard(incident: i, provider: provider)),

            if (provider.incidents.where((i) => i.status != IncidentStatus.resolved).isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Column(children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.resolved),
                  const SizedBox(height: 8),
                  const Text('All incidents resolved!',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ]),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionLabel({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 15, color: AppColors.accent),
    const SizedBox(width: 6),
    Text(title.toUpperCase(),
        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
  ]);
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool highlight;
  const _Stat({required this.label, required this.value, required this.color, required this.icon, this.highlight = false});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.08) : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: highlight ? color.withValues(alpha: 0.4) : AppColors.cardBorder),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text('$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ]),
    ),
  );
}

class _PriorityChart extends StatelessWidget {
  final IncidentProvider provider;
  const _PriorityChart({required this.provider});
  @override
  Widget build(BuildContext context) {
    final total = provider.totalIncidents;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: [
        _Bar('Critical', provider.criticalIncidents, total, AppColors.critical),
        const SizedBox(height: 8),
        _Bar('High',     provider.highIncidents,     total, AppColors.high),
        const SizedBox(height: 8),
        _Bar('Medium',   provider.mediumIncidents,   total, AppColors.medium),
        const SizedBox(height: 8),
        _Bar('Low',      provider.lowIncidents,      total, AppColors.low),
      ]),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _Bar(this.label, this.count, this.total, this.color);
  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Row(children: [
      SizedBox(width: 60, child: Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    ]);
  }
}

class _AdminCard extends StatelessWidget {
  final Incident incident;
  final IncidentProvider provider;
  const _AdminCard({required this.incident, required this.provider});

  @override
  Widget build(BuildContext context) {
    final catColor = getCategoryColor(incident.category);
    final prColor  = getPriorityColor(incident.priority);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incidentId: incident.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: incident.priority == IncidentPriority.critical
                ? AppColors.critical.withValues(alpha: 0.3) : AppColors.cardBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Column(children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(getCategoryIcon(incident.category), color: catColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(incident.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(incident.id, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: getPriorityBgColor(incident.priority),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: prColor.withValues(alpha: 0.4)),
                ),
                child: Text(incident.priorityLabel.toUpperCase(),
                    style: TextStyle(color: prColor, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Column(children: [
              // Status update
              Row(children: [
                const Text('Status:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(width: 8),
                ...IncidentStatus.values.map((s) {
                  final active = incident.status == s;
                  final sc = getStatusColor(s);
                  final lbl = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
                      priority:IncidentPriority.low,status:s,location:'',reportedAt:DateTime.now()).statusLabel;
                  return GestureDetector(
                    onTap: () => provider.updateStatus(incident.id, s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: active ? sc.withValues(alpha: 0.12) : AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: active ? sc : AppColors.cardBorder),
                      ),
                      child: Text(lbl,
                          style: TextStyle(color: active ? sc : AppColors.textSecondary,
                              fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  );
                }),
              ]),
              const SizedBox(height: 8),
              // Assign responder
              Row(children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(
                  incident.assignedResponder ?? 'Unassigned',
                  style: TextStyle(
                    color: incident.assignedResponder != null ? AppColors.accent : AppColors.textHint,
                    fontSize: 11,
                    fontWeight: incident.assignedResponder != null ? FontWeight.w600 : FontWeight.w400,
                  ),
                )),
                GestureDetector(
                  onTap: () => _assignDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Assign', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _assignDialog(BuildContext context) {
    final ctrl = TextEditingController(text: incident.assignedResponder ?? '');
    final responders = ['Dr. Smith', 'Nurse Johnson', 'Fire Unit Alpha', 'Security Team A', 'First Aid Team', 'Electrical Team', 'Campus Police'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Assign Responder', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Responder Name', prefixIcon: Icon(Icons.person_rounded)),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6,
            children: responders.map((r) => ActionChip(
              label: Text(r, style: const TextStyle(fontSize: 11)),
              onPressed: () => ctrl.text = r,
            )).toList(),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) await provider.assignResponder(incident.id, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
