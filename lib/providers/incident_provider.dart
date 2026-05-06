import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/incident_model.dart';

class IncidentProvider extends ChangeNotifier {
  static const String _boxName = 'incidents';
  late Box<Incident> _box;
  bool _isInitialized = false;

  List<Incident> _incidents = [];
  bool _isOnline = true;

  // Filter state
  String _searchQuery = '';
  IncidentStatus? _filterStatus;
  IncidentPriority? _filterPriority;
  IncidentCategory? _filterCategory;

  List<Incident> get incidents => _sortedIncidents;
  bool get isOnline => _isOnline;
  String get searchQuery => _searchQuery;
  IncidentStatus? get filterStatus => _filterStatus;
  IncidentPriority? get filterPriority => _filterPriority;
  IncidentCategory? get filterCategory => _filterCategory;
  bool get isInitialized => _isInitialized;

  // Dashboard stats
  int get totalIncidents => _incidents.length;
  int get activeIncidents =>
      _incidents.where((i) => i.status != IncidentStatus.resolved).length;
  int get resolvedIncidents =>
      _incidents.where((i) => i.status == IncidentStatus.resolved).length;
  int get criticalIncidents =>
      _incidents.where((i) => i.priority == IncidentPriority.critical).length;
  int get highIncidents =>
      _incidents.where((i) => i.priority == IncidentPriority.high).length;
  int get mediumIncidents =>
      _incidents.where((i) => i.priority == IncidentPriority.medium).length;
  int get lowIncidents =>
      _incidents.where((i) => i.priority == IncidentPriority.low).length;
  int get unsyncedIncidents =>
      _incidents.where((i) => !i.isSynced).length;

  List<Incident> get _sortedIncidents {
    List<Incident> filtered = List.from(_incidents);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((i) =>
              i.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              i.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              i.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              i.location.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply filters
    if (_filterStatus != null) {
      filtered = filtered.where((i) => i.status == _filterStatus).toList();
    }
    if (_filterPriority != null) {
      filtered = filtered.where((i) => i.priority == _filterPriority).toList();
    }
    if (_filterCategory != null) {
      filtered = filtered.where((i) => i.category == _filterCategory).toList();
    }

    // Sort by priority + time
    filtered.sort((a, b) {
      int priorityCompare = a.priorityOrder.compareTo(b.priorityOrder);
      if (priorityCompare != 0) return priorityCompare;
      return b.reportedAt.compareTo(a.reportedAt);
    });

    return filtered;
  }

  Future<void> initialize() async {
    _box = await Hive.openBox<Incident>(_boxName);
    _loadFromHive();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadFromHive() {
    _incidents = _box.values.toList();
    notifyListeners();
  }

  Future<String> addIncident({
    required String title,
    required String description,
    required IncidentCategory category,
    required IncidentPriority priority,
    required String location,
    String reportedBy = 'User',
  }) async {
    final id = 'INC-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final incident = Incident(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: IncidentStatus.reported,
      location: location,
      reportedAt: DateTime.now(),
      isSynced: _isOnline,
      reportedBy: reportedBy,
    );

    await _box.put(id, incident);
    _incidents.add(incident);
    notifyListeners();
    return id;
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    final incident = _box.get(id);
    if (incident == null) return;

    final updated = incident.copyWith(status: status);
    await _box.put(id, updated);
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) _incidents[index] = updated;
    notifyListeners();
  }

  Future<void> assignResponder(String id, String responder) async {
    final incident = _box.get(id);
    if (incident == null) return;

    final updated = incident.copyWith(assignedResponder: responder);
    await _box.put(id, updated);
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) _incidents[index] = updated;
    notifyListeners();
  }

  Future<void> updatePriority(String id, IncidentPriority priority) async {
    final incident = _box.get(id);
    if (incident == null) return;

    final updated = incident.copyWith(priority: priority);
    await _box.put(id, updated);
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) _incidents[index] = updated;
    notifyListeners();
  }

  Future<void> deleteIncident(String id) async {
    await _box.delete(id);
    _incidents.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Incident? getById(String id) {
    return _incidents.firstWhere((i) => i.id == id, orElse: () => throw StateError('Not found'));
  }

  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (isOnline) _syncPending();
    notifyListeners();
  }

  Future<void> _syncPending() async {
    final unsynced = _incidents.where((i) => !i.isSynced).toList();
    for (final incident in unsynced) {
      final updated = incident.copyWith(isSynced: true);
      await _box.put(incident.id, updated);
      final index = _incidents.indexWhere((i) => i.id == incident.id);
      if (index != -1) _incidents[index] = updated;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(IncidentStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterPriority(IncidentPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setFilterCategory(IncidentCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterPriority = null;
    _filterCategory = null;
    notifyListeners();
  }

  // Seed demo data
  Future<void> seedDemoData() async {
    if (_incidents.isNotEmpty) return;
    final demos = [
      Incident(
        id: 'INC-DEMO0001',
        title: 'Medical Emergency - Block A',
        description: 'Student collapsed near library entrance, requires immediate assistance.',
        category: IncidentCategory.medical,
        priority: IncidentPriority.critical,
        status: IncidentStatus.inProgress,
        location: 'Block A, Library Entrance',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        assignedResponder: 'Dr. Smith',
        isSynced: true,
        reportedBy: 'John Doe',
      ),
      Incident(
        id: 'INC-DEMO0002',
        title: 'Fire Alert - Cafeteria',
        description: 'Smoke detected near kitchen area in the main cafeteria.',
        category: IncidentCategory.fire,
        priority: IncidentPriority.high,
        status: IncidentStatus.reported,
        location: 'Main Cafeteria, Kitchen',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 32)),
        isSynced: true,
        reportedBy: 'Staff',
      ),
      Incident(
        id: 'INC-DEMO0003',
        title: 'Suspicious Activity - Parking',
        description: 'Unknown individual loitering near vehicles for extended period.',
        category: IncidentCategory.security,
        priority: IncidentPriority.medium,
        status: IncidentStatus.reported,
        location: 'Parking Lot B',
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        isSynced: true,
        reportedBy: 'Security Guard',
      ),
      Incident(
        id: 'INC-DEMO0004',
        title: 'Slip and Fall - Corridor',
        description: 'Wet floor caused a student to slip. Minor injuries reported.',
        category: IncidentCategory.accident,
        priority: IncidentPriority.low,
        status: IncidentStatus.resolved,
        location: 'Corridor 3, Floor 2',
        reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
        assignedResponder: 'First Aid Team',
        isSynced: true,
        reportedBy: 'Teacher',
      ),
      Incident(
        id: 'INC-DEMO0005',
        title: 'Power Outage - Lab',
        description: 'Complete power failure in computer lab during exam.',
        category: IncidentCategory.other,
        priority: IncidentPriority.high,
        status: IncidentStatus.inProgress,
        location: 'Computer Lab, Block C',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        assignedResponder: 'Electrical Team',
        isSynced: true,
        reportedBy: 'Lab Instructor',
      ),
    ];

    for (final incident in demos) {
      await _box.put(incident.id, incident);
      _incidents.add(incident);
    }
    notifyListeners();
  }
}
