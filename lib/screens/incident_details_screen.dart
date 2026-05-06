import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/app_theme.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailsScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<IncidentProvider>(
      builder: (ctx, provider, _) {
        Incident? incident;
        try { incident = provider.incidents.firstWhere((i) => i.id == incidentId); } catch (_) {}

        if (incident == null) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(title: const Text('Details')),
            body: const Center(child: Text('Incident not found')),
          );
        }

        final catColor = getCategoryColor(incident.category);
        final prColor  = getPriorityColor(incident.priority);
        final isCrit   = incident.priority == IncidentPriority.critical;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(getCategoryIcon(incident!.category), color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(incident.categoryLabel,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                            Text(incident.id,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                          ])),
                          _PriorityBadgeLight(priority: incident.priority),
                        ]),
                        const SizedBox(height: 10),
                        Text(incident.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Critical banner
                  if (isCrit)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.criticalBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.warning_rounded, color: AppColors.critical, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('CRITICAL INCIDENT — Requires Immediate Attention',
                            style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.w700, fontSize: 12))),
                      ]),
                    ),

                  // Status Timeline
                  _card(title: 'Response Status', icon: Icons.timeline_rounded,
                      child: _StatusTimeline(incident: incident)),
                  const SizedBox(height: 10),

                  // Details
                  _card(
                    title: 'Incident Details',
                    icon: Icons.info_outline_rounded,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _row('Category', incident.categoryLabel, valueColor: catColor),
                      _row('Priority', incident.priorityLabel, valueColor: prColor),
                      const Divider(height: 16, color: AppColors.divider),
                      const Text('Description',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(incident.description,
                          style: const TextStyle(color: AppColors.textPrimary, height: 1.5, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 10),

                  // Location
                  _card(title: 'Location', icon: Icons.place_rounded,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(incident.location,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13))),
                        ]),
                      )),
                  const SizedBox(height: 10),

                  // Reporter
                  _card(title: 'Reporter Information', icon: Icons.person_outline_rounded,
                      child: Column(children: [
                        _row('Reported By', incident.reportedBy),
                        _row('Reported At', DateFormat('MMM dd, yyyy  •  hh:mm a').format(incident.reportedAt)),
                        _row('Sync Status', incident.isSynced ? 'Synced ✓' : 'Pending sync',
                            valueColor: incident.isSynced ? AppColors.resolved : AppColors.high),
                      ])),
                  const SizedBox(height: 10),

                  // Responder
                  if (incident.assignedResponder != null)
                    _card(title: 'Assigned Responder', icon: Icons.emergency_share_rounded,
                        child: _row('Responder', incident.assignedResponder!,
                            valueColor: AppColors.accent)),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(title.toUpperCase(),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        Expanded(child: Text(value,
            style: TextStyle(color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 12))),
      ]),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Incident incident;
  const _StatusTimeline({required this.incident});

  @override
  Widget build(BuildContext context) {
    final statuses = IncidentStatus.values;
    final currentIdx = statuses.indexOf(incident.status);
    return Row(
      children: List.generate(statuses.length, (i) {
        final s = statuses[i];
        final active  = i <= currentIdx;
        final current = i == currentIdx;
        final color   = active ? getStatusColor(s) : AppColors.cardBorder;
        final label   = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
            priority:IncidentPriority.low,status:s,location:'',reportedAt:DateTime.now()).statusLabel;
        return Expanded(
          child: Row(children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: current ? 36 : 28, height: current ? 36 : 28,
                decoration: BoxDecoration(
                  color: active ? color.withValues(alpha: 0.12) : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: active ? color : AppColors.cardBorder,
                      width: current ? 2 : 1.5),
                ),
                child: Icon(getStatusIcon(s), color: active ? color : AppColors.textHint,
                    size: current ? 18 : 14),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(color: active ? color : AppColors.textHint, fontSize: 9,
                      fontWeight: current ? FontWeight.w700 : FontWeight.w400)),
            ]),
            if (i < statuses.length - 1)
              Expanded(child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i < currentIdx ? getStatusColor(statuses[i + 1]) : AppColors.cardBorder,
              )),
          ]),
        );
      }),
    );
  }
}

class _PriorityBadgeLight extends StatelessWidget {
  final IncidentPriority priority;
  const _PriorityBadgeLight({required this.priority});
  @override
  Widget build(BuildContext context) {
    final label = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
        priority:priority,status:IncidentStatus.reported,location:'',reportedAt:DateTime.now()).priorityLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(label.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}
