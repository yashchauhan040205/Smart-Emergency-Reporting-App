import 'package:flutter/material.dart';
import '../models/incident_model.dart';

class AppColors {
  // ── Light Sober Palette ──────────────────────────
  static const Color surface    = Color(0xFFF4F6F9);
  static const Color background = Color(0xFFFFFFFF);
  static const Color card       = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E8EF);

  // App primary
  static const Color primary      = Color(0xFF1E3A5F);  // Deep navy
  static const Color primaryLight = Color(0xFF2D5A8E);
  static const Color accent       = Color(0xFF2563EB);  // Professional blue

  // Priority
  static const Color critical   = Color(0xFFDC2626);
  static const Color criticalBg = Color(0xFFFEF2F2);
  static const Color high       = Color(0xFFEA580C);
  static const Color highBg     = Color(0xFFFFF7ED);
  static const Color medium     = Color(0xFFCA8A04);
  static const Color mediumBg   = Color(0xFFFFFBEB);
  static const Color low        = Color(0xFF16A34A);
  static const Color lowBg      = Color(0xFFF0FDF4);

  // Status
  static const Color reported   = Color(0xFF6B7280);
  static const Color inProgress = Color(0xFF2563EB);
  static const Color resolved   = Color(0xFF16A34A);

  // Category
  static const Color medical   = Color(0xFFEF4444);
  static const Color fire      = Color(0xFFF97316);
  static const Color security  = Color(0xFF7C3AED);
  static const Color accident  = Color(0xFFF59E0B);
  static const Color natural   = Color(0xFF10B981);
  static const Color other     = Color(0xFF6B7280);

  // Text
  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color divider       = Color(0xFFE5E7EB);
  static const Color white         = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.primaryLight,
        surface: AppColors.card,
        error: AppColors.critical,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.critical),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIconColor: AppColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xAAFFFFFF),
        indicatorColor: Colors.white,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontSize: 13),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Color Helper Functions ───────────────────────────────────────────────────

Color getPriorityColor(IncidentPriority p) {
  switch (p) {
    case IncidentPriority.critical: return AppColors.critical;
    case IncidentPriority.high:     return AppColors.high;
    case IncidentPriority.medium:   return AppColors.medium;
    case IncidentPriority.low:      return AppColors.low;
  }
}

Color getPriorityBgColor(IncidentPriority p) {
  switch (p) {
    case IncidentPriority.critical: return AppColors.criticalBg;
    case IncidentPriority.high:     return AppColors.highBg;
    case IncidentPriority.medium:   return AppColors.mediumBg;
    case IncidentPriority.low:      return AppColors.lowBg;
  }
}

Color getStatusColor(IncidentStatus s) {
  switch (s) {
    case IncidentStatus.reported:   return AppColors.reported;
    case IncidentStatus.inProgress: return AppColors.inProgress;
    case IncidentStatus.resolved:   return AppColors.resolved;
  }
}

Color getCategoryColor(IncidentCategory c) {
  switch (c) {
    case IncidentCategory.medical:   return AppColors.medical;
    case IncidentCategory.fire:      return AppColors.fire;
    case IncidentCategory.security:  return AppColors.security;
    case IncidentCategory.accident:  return AppColors.accident;
    case IncidentCategory.natural:   return AppColors.natural;
    case IncidentCategory.other:     return AppColors.other;
  }
}

IconData getCategoryIcon(IncidentCategory c) {
  switch (c) {
    case IncidentCategory.medical:   return Icons.medical_services_rounded;
    case IncidentCategory.fire:      return Icons.local_fire_department_rounded;
    case IncidentCategory.security:  return Icons.shield_rounded;
    case IncidentCategory.accident:  return Icons.car_crash_rounded;
    case IncidentCategory.natural:   return Icons.thunderstorm_rounded;
    case IncidentCategory.other:     return Icons.report_rounded;
  }
}

IconData getStatusIcon(IncidentStatus s) {
  switch (s) {
    case IncidentStatus.reported:   return Icons.flag_outlined;
    case IncidentStatus.inProgress: return Icons.autorenew_rounded;
    case IncidentStatus.resolved:   return Icons.check_circle_rounded;
  }
}
