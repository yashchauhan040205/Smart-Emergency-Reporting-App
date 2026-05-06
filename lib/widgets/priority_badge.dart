import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../services/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final IncidentPriority priority;
  final bool compact;

  const PriorityBadge({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = getPriorityColor(priority);
    final bgColor = getPriorityBgColor(priority);
    final dummy = Incident(
      id: '',
      title: '',
      description: '',
      category: IncidentCategory.other,
      priority: priority,
      status: IncidentStatus.reported,
      location: '',
      reportedAt: DateTime.now(),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priority == IncidentPriority.critical)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(Icons.warning_rounded, size: 10, color: color),
            ),
          Text(
            dummy.priorityLabel.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
