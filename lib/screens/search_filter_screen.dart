import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/app_theme.dart';
import '../widgets/incident_card.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});
  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<IncidentProvider>();
    _ctrl.text = p.searchQuery;
    _ctrl.addListener(() => context.read<IncidentProvider>().setSearchQuery(_ctrl.text));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          TextButton.icon(
            onPressed: () { context.read<IncidentProvider>().clearFilters(); _ctrl.clear(); },
            icon: const Icon(Icons.clear_all_rounded, size: 16),
            label: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Column(children: [
        // Search bar
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search by ID, title, description, location...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () {
                      _ctrl.clear(); context.read<IncidentProvider>().setSearchQuery('');
                    })
                  : null,
            ),
          ),
        ),

        // Filters
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
          child: Consumer<IncidentProvider>(
            builder: (_, p, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _filterRow(label: 'Status', children: [
                _chip('All', p.filterStatus == null, () => p.setFilterStatus(null), AppColors.accent),
                ...IncidentStatus.values.map((s) {
                  final lbl = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
                      priority:IncidentPriority.low,status:s,location:'',reportedAt:DateTime.now()).statusLabel;
                  return _chip(lbl, p.filterStatus == s,
                      () => p.setFilterStatus(p.filterStatus == s ? null : s), getStatusColor(s));
                }),
              ]),
              const SizedBox(height: 6),
              _filterRow(label: 'Priority', children: [
                _chip('All', p.filterPriority == null, () => p.setFilterPriority(null), AppColors.accent),
                ...IncidentPriority.values.map((pr) {
                  final lbl = Incident(id:'',title:'',description:'',category:IncidentCategory.other,
                      priority:pr,status:IncidentStatus.reported,location:'',reportedAt:DateTime.now()).priorityLabel;
                  return _chip(lbl, p.filterPriority == pr,
                      () => p.setFilterPriority(p.filterPriority == pr ? null : pr), getPriorityColor(pr));
                }),
              ]),
              const SizedBox(height: 6),
              _filterRow(label: 'Category', children: [
                _chip('All', p.filterCategory == null, () => p.setFilterCategory(null), AppColors.accent),
                ...IncidentCategory.values.map((c) {
                  final lbl = Incident(id:'',title:'',description:'',category:c,
                      priority:IncidentPriority.low,status:IncidentStatus.reported,location:'',reportedAt:DateTime.now()).categoryLabel;
                  return _chip(lbl, p.filterCategory == c,
                      () => p.setFilterCategory(p.filterCategory == c ? null : c), getCategoryColor(c));
                }),
              ]),
            ]),
          ),
        ),

        const Divider(height: 1, color: AppColors.divider),

        // Results
        Expanded(
          child: Consumer<IncidentProvider>(
            builder: (_, p, __) {
              final results = p.incidents;
              if (results.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.search_off_rounded, size: 52, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('No matching incidents', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('Try a different keyword or clear filters',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ]));
              }
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                  child: Row(children: [
                    const Icon(Icons.filter_list_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${results.length} result${results.length != 1 ? 's' : ''} found',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                ),
                Expanded(child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 32),
                  itemCount: results.length,
                  itemBuilder: (_, i) => IncidentCard(incident: results[i]),
                )),
              ]);
            },
          ),
        ),
      ]),
    );
  }

  Widget _filterRow({required String label, required List<Widget> children}) {
    return Row(children: [
      SizedBox(width: 62, child: Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600))),
      Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: children))),
    ]);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? color : AppColors.cardBorder),
        ),
        child: Text(label,
            style: TextStyle(color: selected ? color : AppColors.textSecondary,
                fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}
