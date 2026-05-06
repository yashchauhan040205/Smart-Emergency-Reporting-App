import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/app_theme.dart';
import '../widgets/incident_card.dart';
import 'report_incident_screen.dart';
import 'search_filter_screen.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});
  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('All Incidents'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchFilterScreen()))),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Critical'), Tab(text: 'Resolved')],
        ),
      ),
      body: Consumer<IncidentProvider>(
        builder: (_, p, __) => TabBarView(
          controller: _tab,
          children: [
            _list(p.incidents),
            _list(p.incidents.where((i) => i.status != IncidentStatus.resolved).toList()),
            _list(p.incidents.where((i) => i.priority == IncidentPriority.critical).toList()),
            _list(p.incidents.where((i) => i.status == IncidentStatus.resolved).toList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIncidentScreen())),
        backgroundColor: AppColors.critical,
        icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
        label: const Text('Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _list(List<Incident> items) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle_outline_rounded, size: 52, color: AppColors.textHint),
        const SizedBox(height: 12),
        const Text('No incidents here', style: TextStyle(color: AppColors.textSecondary)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => IncidentCard(incident: items[i]),
    );
  }
}
