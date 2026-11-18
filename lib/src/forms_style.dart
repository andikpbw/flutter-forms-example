import 'package:flutter/material.dart';

/// Comprehensive visual theme and layout customization for `forms_example` widgets.
///
/// Includes 6 turnkey studio presets:
/// - [FormsStyle.modernIndigo]
/// - [FormsStyle.cyberDark]
/// - [FormsStyle.glassAurora]
/// - [FormsStyle.emeraldMinimal]
/// - [FormsStyle.sunsetWarm]
/// - [FormsStyle.softNeumorphic]
@immutable
class FormsStyle {
  /// Creates a custom [FormsStyle].
  const FormsStyle({
    this.backgroundColor = const Color(0xFFF8FAFC),
    this.cardColor = const Color(0xFFFFFFFF),
    this.fieldFillColor = const Color(0xFFF1F5F9),
    this.fieldFocusedFillColor = const Color(0xFFFFFFFF),
    this.primaryColor = const Color(0xFF4F46E5),
    this.secondaryColor = const Color(0xFF7C3AED),
    this.successColor = const Color(0xFF10B981),
    this.warningColor = const Color(0xFFF59E0B),
    this.errorColor = const Color(0xFFEF4444),
    this.textColor = const Color(0xFF0F172A),
    this.subtitleColor = const Color(0xFF64748B),
    this.hintColor = const Color(0xFF94A3B8),
    this.borderColor = const Color(0xFFE2E8F0),
    this.borderRadius = 14.0,
    this.cardBorderRadius = 20.0,
    this.borderWidth = 1.4,
    this.focusedBorderWidth = 2.0,
    this.fieldSpacing = 16.0,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    this.animationDuration = const Duration(milliseconds: 220),
    this.isDark = false,
    this.showValidationIcon = true,
    this.boxShadows = const <BoxShadow>[
      BoxShadow(
        color: Color(0x0D0F172A),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
    ],
  });

  /// Crisp SaaS light theme with electric indigo (`#4F46E5`) and violet accents.
  factory FormsStyle.modernIndigo() => const FormsStyle();

  /// Sleek dark obsidian theme with neon cyan (`#00F5D4`) and violet (`#A855F7`) glow.
  factory FormsStyle.cyberDark() => const FormsStyle(
        backgroundColor: Color(0xFF070A12),
        cardColor: Color(0xFF0F172A),
        fieldFillColor: Color(0xFF1E293B),
        fieldFocusedFillColor: Color(0xFF131D31),
        primaryColor: Color(0xFF00F5D4),
        secondaryColor: Color(0xFFA855F7),
        successColor: Color(0xFF10B981),
        warningColor: Color(0xFFFBBF24),
        errorColor: Color(0xFFF43F5E),
        textColor: Color(0xFFF8FAFC),
        subtitleColor: Color(0xFF94A3B8),
        hintColor: Color(0xFF64748B),
        borderColor: Color(0xFF334155),
        borderRadius: 14.0,
        cardBorderRadius: 22.0,
        isDark: true,
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      );

  /// Frosted midnight aurora palette with sky blue (`#38BDF8`) and indigo accents.
  factory FormsStyle.glassAurora() => const FormsStyle(
        backgroundColor: Color(0xFF0B1120),
        cardColor: Color(0xFF15203B),
        fieldFillColor: Color(0xFF1E2D4F),
        fieldFocusedFillColor: Color(0xFF23355D),
        primaryColor: Color(0xFF38BDF8),
        secondaryColor: Color(0xFF818CF8),
        successColor: Color(0xFF34D399),
        warningColor: Color(0xFFFBBF24),
        errorColor: Color(0xFFFB7185),
        textColor: Color(0xFFF1F5F9),
        subtitleColor: Color(0xFF94A3B8),
        hintColor: Color(0xFF64748B),
        borderColor: Color(0xFF334977),
        borderRadius: 16.0,
        cardBorderRadius: 24.0,
        isDark: true,
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Color(0x4D020617),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      );

  /// Clean fintech light theme with forest emerald (`#059669`) and teal accents.
  factory FormsStyle.emeraldMinimal() => const FormsStyle(
        backgroundColor: Color(0xFFF0FDF4),
        cardColor: Color(0xFFFFFFFF),
        fieldFillColor: Color(0xFFF8FAFC),
        fieldFocusedFillColor: Color(0xFFFFFFFF),
        primaryColor: Color(0xFF059669),
        secondaryColor: Color(0xFF0D9488),
        successColor: Color(0xFF16A34A),
        warningColor: Color(0xFFD97706),
        errorColor: Color(0xFFDC2626),
        textColor: Color(0xFF064E3B),
        subtitleColor: Color(0xFF475569),
        hintColor: Color(0xFF94A3B8),
        borderColor: Color(0xFFD1FAE5),
        borderRadius: 12.0,
        cardBorderRadius: 18.0,
        isDark: false,
      );

  /// Warm coral (`#F97316`) and rose (`#EC4899`) consumer lifestyle theme.
  factory FormsStyle.sunsetWarm() => const FormsStyle(
        backgroundColor: Color(0xFFFFF7ED),
        cardColor: Color(0xFFFFFFFF),
        fieldFillColor: Color(0xFFFFF1F2),
        fieldFocusedFillColor: Color(0xFFFFFFFF),
        primaryColor: Color(0xFFF97316),
        secondaryColor: Color(0xFFEC4899),
        successColor: Color(0xFF10B981),
        warningColor: Color(0xFFF59E0B),
        errorColor: Color(0xFFE11D48),
        textColor: Color(0xFF1E1B4B),
        subtitleColor: Color(0xFF64748B),
        hintColor: Color(0xFF94A3B8),
        borderColor: Color(0xFFFED7AA),
        borderRadius: 16.0,
        cardBorderRadius: 22.0,
        isDark: false,
      );

  /// Tactile soft-UI neumorphic surface with subtle dual shadows and royal blue accents.
  factory FormsStyle.softNeumorphic() => const FormsStyle(
        backgroundColor: Color(0xFFE2E8F0),
        cardColor: Color(0xFFEDF2F7),
        fieldFillColor: Color(0xFFE2E8F0),
        fieldFocusedFillColor: Color(0xFFF8FAFC),
        primaryColor: Color(0xFF2563EB),
        secondaryColor: Color(0xFF6366F1),
        successColor: Color(0xFF059669),
        warningColor: Color(0xFFD97706),
        errorColor: Color(0xFFDC2626),
        textColor: Color(0xFF1E293B),
        subtitleColor: Color(0xFF475569),
        hintColor: Color(0xFF94A3B8),
        borderColor: Color(0xFFCBD5E1),
        borderRadius: 14.0,
        cardBorderRadius: 20.0,
        isDark: false,
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Color(0xFFFFFFFF),
            blurRadius: 12,
            offset: Offset(-5, -5),
          ),
          BoxShadow(
            color: Color(0x3364748B),
            blurRadius: 14,
            offset: Offset(6, 6),
          ),
        ],
      );

  /// Outer scaffold/canvas background color.
  final Color backgroundColor;

  /// Elevated form card container background color.
  final Color cardColor;

  /// Default resting fill color for input fields.
  final Color fieldFillColor;

  /// Input field fill color when focused.
  final Color fieldFocusedFillColor;

  /// Primary brand accent color for active borders, progress bars, and CTAs.
  final Color primaryColor;

  /// Secondary accent color used in gradients and badges.
  final Color secondaryColor;

  /// Color used for valid field indicators and strong password levels.
  final Color successColor;

  /// Color used for fair/warning indicators.
  final Color warningColor;

  /// Color used for validation errors and weak password levels.
  final Color errorColor;

  /// Primary text color for field values and headings.
  final Color textColor;

  /// Secondary text color for labels, subtitles, and helper text.
  final Color subtitleColor;

  /// Placeholder hint text color.
  final Color hintColor;

  /// Default resting border color for fields and cards.
  final Color borderColor;

  /// Corner radius for individual input fields and chips.
  final double borderRadius;

  /// Corner radius for outer form cards.
  final double cardBorderRadius;

  /// Resting border stroke width.
  final double borderWidth;

  /// Focused or error border stroke width.
  final double focusedBorderWidth;

  /// Vertical spacing between consecutive form fields.
  final double fieldSpacing;

  /// Inner padding applied to input containers.
  final EdgeInsetsGeometry contentPadding;

  /// Transition duration for focus, validation, and step animations.
  final Duration animationDuration;

  /// Whether this theme uses a dark luminance palette.
  final bool isDark;

  /// Whether validated fields display a trailing check/error status icon.
  final bool showValidationIcon;

  /// Elevation shadows applied to form card containers.
  final List<BoxShadow> boxShadows;

  /// Primary accent gradient derived from [primaryColor] and [secondaryColor].
  LinearGradient get accentGradient => LinearGradient(
        colors: <Color>[primaryColor, secondaryColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// Creates a copy of this [FormsStyle] with selectively overridden properties.
  FormsStyle copyWith({
    Color? backgroundColor,
    Color? cardColor,
    Color? fieldFillColor,
    Color? fieldFocusedFillColor,
    Color? primaryColor,
    Color? secondaryColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? textColor,
    Color? subtitleColor,
    Color? hintColor,
    Color? borderColor,
    double? borderRadius,
    double? cardBorderRadius,
    double? borderWidth,
    double? focusedBorderWidth,
    double? fieldSpacing,
    EdgeInsetsGeometry? contentPadding,
    Duration? animationDuration,
    bool? isDark,
    bool? showValidationIcon,
    List<BoxShadow>? boxShadows,
  }) {
    return FormsStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      fieldFillColor: fieldFillColor ?? this.fieldFillColor,
      fieldFocusedFillColor:
          fieldFocusedFillColor ?? this.fieldFocusedFillColor,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      textColor: textColor ?? this.textColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      hintColor: hintColor ?? this.hintColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      fieldSpacing: fieldSpacing ?? this.fieldSpacing,
      contentPadding: contentPadding ?? this.contentPadding,
      animationDuration: animationDuration ?? this.animationDuration,
      isDark: isDark ?? this.isDark,
      showValidationIcon: showValidationIcon ?? this.showValidationIcon,
      boxShadows: boxShadows ?? this.boxShadows,
    );
  }
}
