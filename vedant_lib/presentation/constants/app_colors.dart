import 'package:flutter/material.dart';

class AppColors {
  // Light Theme - Updated to Blue
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF1F2937);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardForeground = Color(0xFF1F2937);
  static const Color lightPopover = Color(0xFFFFFFFF);
  static const Color lightPopoverForeground = Color(0xFF1F2937);
  static const Color lightPrimary = Color(0xFF1E40AF); // Blue instead of black
  static const Color lightPrimaryForeground = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFEFF6FF);
  static const Color lightSecondaryForeground = Color(0xFF1E40AF);
  static const Color lightMuted = Color(0xFFF3F4F6);
  static const Color lightMutedForeground = Color(0xFF6B7280);
  static const Color lightAccent = Color(0xFFDEBEF9);
  static const Color lightAccentForeground = Color(0xFF1F2937);
  static const Color lightDestructive = Color(0xFFDC2626);
  static const Color lightDestructiveForeground = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightInput = Color(0x00000000);
  static const Color lightInputBackground = Color(0xFFF9FAFB);
  static const Color lightSwitchBackground = Color(0xFFD1D5DB);
  static const Color lightRing = Color(0xFF3B82F6);

  // Dark Theme
  static const Color darkBackground = Color(0xFF251F3D);
  static const Color darkForeground = Color(0xFFF5F5F7);
  static const Color darkCard = Color(0xFF251F3D);
  static const Color darkCardForeground = Color(0xFFF5F5F7);
  static const Color darkPopover = Color(0xFF251F3D);
  static const Color darkPopoverForeground = Color(0xFFF5F5F7);
  static const Color darkPrimary = Color(0xFFF5F5F7);
  static const Color darkPrimaryForeground = Color(0xFF3D3B52);
  static const Color darkSecondary = Color(0xFF443E5C);
  static const Color darkSecondaryForeground = Color(0xFFF5F5F7);
  static const Color darkMuted = Color(0xFF443E5C);
  static const Color darkMutedForeground = Color(0xFFB4B0C3);
  static const Color darkAccent = Color(0xFF443E5C);
  static const Color darkAccentForeground = Color(0xFFF5F5F7);
  static const Color darkDestructive = Color(0xFF6B3D52);
  static const Color darkDestructiveForeground = Color(0xFFA49C9C);
  static const Color darkBorder = Color(0xFF443E5C);
  static const Color darkInput = Color(0xFF443E5C);
  static const Color darkRing = Color(0xFF6F6B80);
  static const Color darkSurface = Color(0xFF3D3B52);

  // Sidebar colors
  static const Color lightSidebar = Color(0xFFFCFCFD);
  static const Color lightSidebarForeground = Color(0xFF251F3D);
  static const Color lightSidebarPrimary = Color(0xFF030213);
  static const Color lightSidebarPrimaryForeground = Color(0xFFFCFCFD);
  static const Color lightSidebarAccent = Color(0xFFF7F5FB);
  static const Color lightSidebarAccentForeground = Color(0xFF3D3B52);
  static const Color lightSidebarBorder = Color(0xFFEBE8F0);

  static const Color darkSidebar = Color(0xFF3D3B52);
  static const Color darkSidebarForeground = Color(0xFFF5F5F7);
  static const Color darkSidebarPrimary = Color(0xFF488FF3);
  static const Color darkSidebarPrimaryForeground = Color(0xFFF5F5F7);
  static const Color darkSidebarAccent = Color(0xFF443E5C);
  static const Color darkSidebarAccentForeground = Color(0xFFF5F5F7);
  static const Color darkSidebarBorder = Color(0xFF443E5C);

  // Chart colors
  static const Color chart1Light = Color(0xFFF59E0B);
  static const Color chart2Light = Color(0xFF06B6D4);
  static const Color chart3Light = Color(0xFF8B5CF6);
  static const Color chart4Light = Color(0xFFD4D4D8);
  static const Color chart5Light = Color(0xFFEAB308);

  static const Color chart1Dark = Color(0xFF7C3AED);
  static const Color chart2Dark = Color(0xFFB1D4FF);
  static const Color chart3Dark = Color(0xFFEAB308);
  static const Color chart4Dark = Color(0xFFA855F7);
  static const Color chart5Dark = Color(0xFFFA8072);

  // Status colors
  static const Color statusNormal = Color(0xFF10B981);
  static const Color statusOverloaded = Color(0xFFF59E0B);
  static const Color statusCritical = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 9999.0;
}

class AppFontSizes {
  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double base = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 30.0;
  static const double display1 = 36.0;
  static const double display2 = 48.0;
}

class AppFontWeights {
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
