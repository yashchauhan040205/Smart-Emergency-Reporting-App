import 'package:hive/hive.dart';

part 'incident_model.g.dart';

@HiveType(typeId: 0)
enum IncidentStatus {
  @HiveField(0)
  reported,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  resolved,
}

@HiveType(typeId: 1)
enum IncidentPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  critical,
}

@HiveType(typeId: 2)
enum IncidentCategory {
  @HiveField(0)
  medical,
  @HiveField(1)
  fire,
  @HiveField(2)
  security,
  @HiveField(3)
  accident,
  @HiveField(4)
  natural,
  @HiveField(5)
  other,
}

@HiveType(typeId: 3)
class Incident extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  IncidentCategory category;

  @HiveField(4)
  IncidentPriority priority;

  @HiveField(5)
  IncidentStatus status;

  @HiveField(6)
  String location;

  @HiveField(7)
  DateTime reportedAt;

  @HiveField(8)
  String? assignedResponder;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  String reportedBy;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.location,
    required this.reportedAt,
    this.assignedResponder,
    this.isSynced = false,
    this.reportedBy = 'Anonymous',
  });

  String get priorityLabel {
    switch (priority) {
      case IncidentPriority.low:
        return 'Low';
      case IncidentPriority.medium:
        return 'Medium';
      case IncidentPriority.high:
        return 'High';
      case IncidentPriority.critical:
        return 'Critical';
    }
  }

  String get categoryLabel {
    switch (category) {
      case IncidentCategory.medical:
        return 'Medical';
      case IncidentCategory.fire:
        return 'Fire';
      case IncidentCategory.security:
        return 'Security';
      case IncidentCategory.accident:
        return 'Accident';
      case IncidentCategory.natural:
        return 'Natural Disaster';
      case IncidentCategory.other:
        return 'Other';
    }
  }

  String get statusLabel {
    switch (status) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  int get priorityOrder {
    switch (priority) {
      case IncidentPriority.critical:
        return 0;
      case IncidentPriority.high:
        return 1;
      case IncidentPriority.medium:
        return 2;
      case IncidentPriority.low:
        return 3;
    }
  }

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    IncidentCategory? category,
    IncidentPriority? priority,
    IncidentStatus? status,
    String? location,
    DateTime? reportedAt,
    String? assignedResponder,
    bool? isSynced,
    String? reportedBy,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      reportedAt: reportedAt ?? this.reportedAt,
      assignedResponder: assignedResponder ?? this.assignedResponder,
      isSynced: isSynced ?? this.isSynced,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }
}
