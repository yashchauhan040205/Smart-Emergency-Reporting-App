import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../services/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final IncidentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    final dummy = Incident(
      id: '',
      title: '',
      description: '',
      category: IncidentCategory.other,
      priority: IncidentPriority.low,
      status: status,
      location: '',
      reportedAt: DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getStatusIcon(status), size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            dummy.statusLabel,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
