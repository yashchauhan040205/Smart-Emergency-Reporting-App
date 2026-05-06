import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../services/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/custom_dropdown.dart';
import 'incident_details_screen.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});
  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _locCtrl   = TextEditingController();
  final _nameCtrl  = TextEditingController();

  IncidentCategory _category = IncidentCategory.medical;
  IncidentPriority _priority = IncidentPriority.medium;
  bool _submitting = false;
  bool _gpsLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _locCtrl.dispose();   _nameCtrl.dispose();
    super.dispose();
  }

  // ── Real GPS ────────────────────────────────────────────────────────────
  Future<void> _getGPS() async {
    setState(() => _gpsLoading = true);
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() { _locCtrl.text = loc; _gpsLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('📍 $loc'),
        backgroundColor: AppColors.resolved,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final provider = context.read<IncidentProvider>();
    try {
      final id = await provider.addIncident(
        title:       _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category:    _category,
        priority:    _priority,
        location:    _locCtrl.text.trim(),
        reportedBy:  _nameCtrl.text.trim().isEmpty ? 'Anonymous' : _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSuccess(id, provider.isOnline);
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), backgroundColor: AppColors.critical));
    }
  }

  void _showSuccess(String id, bool isOnline) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          CircleAvatar(radius: 30, backgroundColor: AppColors.lowBg,
              child: const Icon(Icons.check_rounded, color: AppColors.resolved, size: 34)),
          const SizedBox(height: 14),
          const Text('Incident Reported!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
            child: Text(id, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          Text(isOnline ? 'Report submitted & synced.' : 'Saved offline. Will sync when online.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Done'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incidentId: id)));
              },
              child: const Text('View Details'))),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = _priority == IncidentPriority.critical;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Report Incident'),
        actions: [
          Consumer<IncidentProvider>(
            builder: (_, p, __) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text(p.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(fontSize: 11, color: p.isOnline ? AppColors.resolved : AppColors.high)),
                avatar: Icon(p.isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    size: 14, color: p.isOnline ? AppColors.resolved : AppColors.high),
                backgroundColor: p.isOnline ? AppColors.lowBg : AppColors.highBg,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Critical warning banner
            if (isCritical)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.criticalBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
                ),
                child: const Row(children: [
                  Icon(Icons.warning_rounded, color: AppColors.critical, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('CRITICAL — Emergency services will be alerted immediately.',
                      style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.w600, fontSize: 12))),
                ]),
              ),

            _sectionLabel('Incident Details'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *', hintText: 'e.g., Medical Emergency at Block A',
                  prefixIcon: Icon(Icons.title_rounded)),
              validator: (v) => (v == null || v.trim().length < 5) ? 'Minimum 5 characters' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description *', hintText: 'Describe what happened...',
                  prefixIcon: Icon(Icons.description_rounded), alignLabelWithHint: true),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Minimum 10 characters' : null,
            ),
            const SizedBox(height: 16),

            _sectionLabel('Category & Priority'),
            const SizedBox(height: 8),
            CustomDropdown<IncidentCategory>(
              label: 'Category *',
              icon: Icons.category_rounded,
              value: _category,
              items: IncidentCategory.values,
              itemLabel: (c) => _catLabel(c),
              itemIcon: (c) => getCategoryIcon(c),
              itemColor: (c) => getCategoryColor(c),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),

            // Priority buttons
            const Text('Priority Level *',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: IncidentPriority.values.map((p) {
                final selected = _priority == p;
                final color    = getPriorityColor(p);
                final bg       = getPriorityBgColor(p);
                final label    = _prLabel(p);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? bg : AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? color : AppColors.cardBorder,
                            width: selected ? 1.5 : 1),
                      ),
                      child: Column(children: [
                        Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14, color: selected ? color : AppColors.textHint),
                        const SizedBox(height: 3),
                        Text(label, style: TextStyle(
                            color: selected ? color : AppColors.textSecondary,
                            fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _sectionLabel('Location'),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: TextFormField(
                  controller: _locCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'Type address or use GPS',
                    prefixIcon: Icon(Icons.place_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                ),
              ),
              const SizedBox(width: 8),
              // GPS button
              GestureDetector(
                onTap: _gpsLoading ? null : _getGPS,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _gpsLoading ? AppColors.surface : AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: _gpsLoading
                      ? const Padding(padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                      : const Icon(Icons.my_location_rounded, color: AppColors.accent, size: 22),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            const Text('Tap the GPS button to auto-fetch your real location via browser',
                style: TextStyle(color: AppColors.textHint, fontSize: 11)),
            const SizedBox(height: 16),

            _sectionLabel('Reporter Info'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Your Name (Optional)',
                  hintText: 'Leave blank for anonymous',
                  prefixIcon: Icon(Icons.person_outline_rounded)),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCritical ? AppColors.critical : AppColors.accent,
                  disabledBackgroundColor: AppColors.cardBorder,
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(isCritical ? Icons.warning_rounded : Icons.send_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(isCritical ? 'REPORT CRITICAL INCIDENT' : 'Submit Report',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) => Text(title,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w600, letterSpacing: 0.6));

  String _catLabel(IncidentCategory c) {
    switch (c) {
      case IncidentCategory.medical:  return 'Medical';
      case IncidentCategory.fire:     return 'Fire';
      case IncidentCategory.security: return 'Security';
      case IncidentCategory.accident: return 'Accident';
      case IncidentCategory.natural:  return 'Natural Disaster';
      case IncidentCategory.other:    return 'Other';
    }
  }

  String _prLabel(IncidentPriority p) {
    switch (p) {
      case IncidentPriority.low:      return 'Low';
      case IncidentPriority.medium:   return 'Medium';
      case IncidentPriority.high:     return 'High';
      case IncidentPriority.critical: return 'Critical';
    }
  }
}
