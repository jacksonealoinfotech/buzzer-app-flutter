import 'package:flutter/material.dart';
import 'package:buzzer_app/core/theme/app_colors.dart';

/// Semantic status colors (Success, Warning, Info, Destructive) theme extension.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  static const light = SemanticColors(
    success: AppColors.success,
    onSuccess: AppColors.onSuccess,
    warning: AppColors.warning,
    onWarning: AppColors.onWarning,
    info: AppColors.info,
    onInfo: AppColors.onInfo,
  );

  static const dark = SemanticColors(
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF00390E),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF4E2600),
    info: Color(0xFF4FC3F7),
    onInfo: Color(0xFF003548),
  );

  @override
  ThemeExtension<SemanticColors> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  ThemeExtension<SemanticColors> lerp(
    covariant ThemeExtension<SemanticColors>? other,
    double t,
  ) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
    );
  }
}

/// Brand gradient presets theme extension.
@immutable
class AppGradients extends ThemeExtension<AppGradients> {
  const AppGradients({
    required this.primaryGradient,
    required this.secondaryGradient,
  });

  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;

  static const light = AppGradients(
    primaryGradient: LinearGradient(
      colors: [AppColors.lightPrimary, AppColors.lightSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    secondaryGradient: LinearGradient(
      colors: [AppColors.lightSecondary, Color(0xFF90E0EF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const dark = AppGradients(
    primaryGradient: LinearGradient(
      colors: [AppColors.darkPrimary, AppColors.darkSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    secondaryGradient: LinearGradient(
      colors: [AppColors.darkSecondary, Color(0xFF0077B6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  @override
  ThemeExtension<AppGradients> copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
  }) {
    return AppGradients(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
    );
  }

  @override
  ThemeExtension<AppGradients> lerp(
    covariant ThemeExtension<AppGradients>? other,
    double t,
  ) {
    if (other is! AppGradients) return this;
    return AppGradients(
      primaryGradient:
          LinearGradient.lerp(primaryGradient, other.primaryGradient, t) ??
          primaryGradient,
      secondaryGradient:
          LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t) ??
          secondaryGradient,
    );
  }
}

/// Elevation shadow styling theme extension.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({
    required this.small,
    required this.medium,
    required this.large,
  });

  final List<BoxShadow> small;
  final List<BoxShadow> medium;
  final List<BoxShadow> large;

  static const light = AppShadows(
    small: [
      BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
    medium: [
      BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
    ],
    large: [
      BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 8)),
    ],
  );

  static const dark = AppShadows(
    small: [
      BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
    medium: [
      BoxShadow(color: Color(0x4D000000), blurRadius: 10, offset: Offset(0, 4)),
    ],
    large: [
      BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8)),
    ],
  );

  @override
  ThemeExtension<AppShadows> copyWith({
    List<BoxShadow>? small,
    List<BoxShadow>? medium,
    List<BoxShadow>? large,
  }) {
    return AppShadows(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  ThemeExtension<AppShadows> lerp(
    covariant ThemeExtension<AppShadows>? other,
    double t,
  ) {
    if (other is! AppShadows) return this;
    return AppShadows(
      small: BoxShadow.lerpList(small, other.small, t) ?? small,
      medium: BoxShadow.lerpList(medium, other.medium, t) ?? medium,
      large: BoxShadow.lerpList(large, other.large, t) ?? large,
    );
  }
}
