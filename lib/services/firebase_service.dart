import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';

/// Firebase Firestore service for real-time incident sync.
/// Used by IncidentProvider when online.
class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'incidents';

  // ── Upload incident to Firestore ─────────────────────────────────────────
  static Future<void> uploadIncident(Incident incident) async {
    await _db.collection(_collection).doc(incident.id).set({
      'id':                incident.id,
      'title':             incident.title,
      'description':       incident.description,
      'category':          incident.category.index,
      'priority':          incident.priority.index,
      'status':            incident.status.index,
      'location':          incident.location,
      'reportedBy':        incident.reportedBy,
      'reportedAt':        Timestamp.fromDate(incident.reportedAt),
      'assignedResponder': incident.assignedResponder,
      'isSynced':          true,
      'updatedAt':         FieldValue.serverTimestamp(),
    });
  }

  // ── Fetch all incidents (one-time) ───────────────────────────────────────
  static Future<List<Incident>> fetchAll() async {
    final snap = await _db.collection(_collection)
        .orderBy('reportedAt', descending: true)
        .get();
    return snap.docs.map((d) => _fromMap(d.data())).toList();
  }

  // ── Real-time stream ─────────────────────────────────────────────────────
  static Stream<List<Incident>> incidentStream() {
    return _db.collection(_collection)
        .orderBy('reportedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromMap(d.data())).toList());
  }

  // ── Update status ────────────────────────────────────────────────────────
  static Future<void> updateStatus(String id, IncidentStatus status) async {
    await _db.collection(_collection).doc(id).update({
      'status':    status.index,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Assign responder ─────────────────────────────────────────────────────
  static Future<void> assignResponder(String id, String responder) async {
    await _db.collection(_collection).doc(id).update({
      'assignedResponder': responder,
      'updatedAt':         FieldValue.serverTimestamp(),
    });
  }

  // ── Delete ───────────────────────────────────────────────────────────────
  static Future<void> deleteIncident(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // ── Map → Incident ───────────────────────────────────────────────────────
  static Incident _fromMap(Map<String, dynamic> data) {
    return Incident(
      id:                data['id'] ?? '',
      title:             data['title'] ?? '',
      description:       data['description'] ?? '',
      category:          IncidentCategory.values[data['category'] ?? 0],
      priority:          IncidentPriority.values[data['priority'] ?? 0],
      status:            IncidentStatus.values[data['status'] ?? 0],
      location:          data['location'] ?? '',
      reportedBy:        data['reportedBy'] ?? 'Anonymous',
      reportedAt:        (data['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedResponder: data['assignedResponder'],
      isSynced:          data['isSynced'] ?? false,
    );
  }
}
