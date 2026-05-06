import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import '../services/app_theme.dart';
import '../screens/incident_details_screen.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final prColor  = getPriorityColor(incident.priority);
    final catColor = getCategoryColor(incident.category);
    final isCrit   = incident.priority == IncidentPriority.critical;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incidentId: incident.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCrit ? AppColors.critical.withValues(alpha: 0.4) : AppColors.cardBorder,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: [
          // Priority bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: prColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
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
                  Text(incident.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(incident.id,
                      style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                ])),
                _PriorityBadge(priority: incident.priority),
              ]),
              const SizedBox(height: 8),
              Text(incident.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.place_outlined, size: 12, color: AppColors.textHint),
                const SizedBox(width: 3),
                Expanded(child: Text(incident.location,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _StatusBadge(status: incident.status),
                if (!incident.isSynced) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.highBg,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.high.withValues(alpha: 0.3)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.cloud_off_rounded, size: 9, color: AppColors.high),
                      SizedBox(width: 3),
                      Text('Offline', style: TextStyle(color: AppColors.high, fontSize: 9, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
                const Spacer(),
                Text(_ago(incident.reportedAt),
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return DateFormat('MMM dd').format(dt);
  }
}

class _PriorityBadge extends StatelessWidget {
  final IncidentPriority priority;
  const _PriorityBadge({required this.priority});
  @override
  Widget build(BuildContext context) {
    final c = getPriorityColor(priority);
    final bg = getPriorityBgColor(priority);
    final label = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
        priority:priority,status:IncidentStatus.reported,location:'',reportedAt:DateTime.now()).priorityLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: 0.5))),
      child: Text(label.toUpperCase(),
          style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IncidentStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final c = getStatusColor(status);
    final label = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
        priority:IncidentPriority.low,status:status,location:'',reportedAt:DateTime.now()).statusLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(getStatusIcon(status), size: 10, color: c),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
