import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared layout tokens for safe area, spacing, and responsive shells.
class AppLayout {
  AppLayout._();

  static const Size designSize = Size(375, 812);

  static const double minTextScale = 0.9;
  static const double maxTextScale = 1.1;

  static double get horizontalPadding => 20.w;
  static double get cardRadius => 16.r;
  static double get buttonRadius => 12.r;
  static double get ctaHeight => 52.h;
  static double get homeBottomNavPadding => 120.h;
  static double get standaloneBottomPadding => 32.h;

  static double bottomPadding({required bool embedded}) =>
      embedded ? homeBottomNavPadding : standaloneBottomPadding;

  static const Set<String> fullBleedRoutes = {
    '/splash',
    '/video-call',
    '/voice-call',
    '/welcome',
  };

  static bool isFullBleedRoute(String path) {
    final normalized = path.split('?').first;
    return fullBleedRoutes.contains(normalized);
  }

  static bool isHomeRoute(String path) {
    final normalized = path.split('?').first;
    return normalized == '/home';
  }

  /// Clamps accessibility text scale for the app shell.
  static TextScaler clampTextScaler(TextScaler scaler) {
    var max = maxTextScale;
    if (max <= minTextScale) {
      max = minTextScale + 0.01;
    }
    return scaler.clamp(
      minScaleFactor: minTextScale,
      maxScaleFactor: max,
    );
  }

  /// Material date/time pickers clamp [TextScaler] again internally. Reset the
  /// inherited scaler first to avoid `maxScale > minScale` assertion failures
  /// when the app applies its own text-scale clamp in [main.dart].
  static Widget datePickerBuilder(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: child,
    );
  }

  static EdgeInsets screenPadding({
    bool embedded = false,
    double top = 0,
    double bottomExtra = 0,
  }) {
    return EdgeInsets.fromLTRB(
      horizontalPadding,
      top,
      horizontalPadding,
      bottomPadding(embedded: embedded) + bottomExtra,
    );
  }

  static PreferredSizeWidget appBar({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = false,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      title: subtitle == null || subtitle.isEmpty
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0C0C1C),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0C0C1C),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 11.sp,
                    color: const Color(0xFF656565),
                  ),
                ),
              ],
            ),
    );
  }
}
