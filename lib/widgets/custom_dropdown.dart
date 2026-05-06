import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../services/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final IconData Function(T) itemIcon;
  final Color Function(T) itemColor;
  final void Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.itemIcon,
    required this.itemColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.white,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: items.map((item) {
        final color = itemColor(item);
        return DropdownMenuItem<T>(
          value: item,
          child: Row(children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(itemIcon(item), color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Text(itemLabel(item), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ]),
        );
      }).toList(),
    );
  }
}
