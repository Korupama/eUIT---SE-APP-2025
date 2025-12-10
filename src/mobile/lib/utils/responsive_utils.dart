import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive utilities for the app using flutter_screenutil.
///
/// Usage Examples:
/// ```dart
/// // Import in any widget file
/// import 'package:mobile/utils/responsive_utils.dart';
///
/// // Width & Height (scaled based on screen width)
/// Container(
///   width: 100.w,    // 100 logical pixels scaled
///   height: 50.h,    // 50 logical pixels scaled
///   padding: EdgeInsets.all(16.r), // radius-based scaling (min of w/h)
/// )
///
/// // Font sizes (scaled with optional minTextAdapt)
/// Text('Hello', style: TextStyle(fontSize: 16.sp))
///
/// // Using extension helpers
/// SizedBox(height: 20.verticalSpace)
/// SizedBox(width: 10.horizontalSpace)
///
/// // Responsive widgets
/// ResponsiveBuilder(
///   mobile: MobileLayout(),
///   tablet: TabletLayout(),
///   desktop: DesktopLayout(),
/// )
/// ```

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 1200;
  static const double tablet = 1500;
  static const double desktop = 1800;
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop }

/// Get current device type based on screen width
DeviceType getDeviceType(BuildContext context) {
  // Force mobile layout on all devices
  return DeviceType.mobile;
}

/// Check if current device is mobile
bool isMobile(BuildContext context) => true;

/// Check if current device is tablet
bool isTablet(BuildContext context) => false;

/// Check if current device is desktop
bool isDesktop(BuildContext context) => false;

/// Responsive builder widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    // Always return the mobile layout regardless of device size
    return mobile;
  }
}

/// Responsive value helper - returns different values based on screen size
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  final deviceType = getDeviceType(context);
  switch (deviceType) {
    case DeviceType.desktop:
      return desktop ?? tablet ?? mobile;
    case DeviceType.tablet:
      return tablet ?? mobile;
    case DeviceType.mobile:
      return mobile;
  }
}

/// Extension for responsive padding
extension ResponsivePadding on num {
  /// Symmetric horizontal padding
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble().w);

  /// Symmetric vertical padding
  EdgeInsets get verticalPadding =>
      EdgeInsets.symmetric(vertical: toDouble().h);

  /// All sides padding (uses .r for uniform scaling)
  EdgeInsets get allPadding => EdgeInsets.all(toDouble().r);
}

/// Extension for responsive SizedBox
extension ResponsiveSizedBox on num {
  /// Vertical spacing SizedBox
  SizedBox get verticalSpace => SizedBox(height: toDouble().h);

  /// Horizontal spacing SizedBox
  SizedBox get horizontalSpace => SizedBox(width: toDouble().w);
}

/// Extension for responsive BorderRadius
extension ResponsiveBorderRadius on num {
  /// Circular border radius
  BorderRadius get circularRadius => BorderRadius.circular(toDouble().r);

  /// Only top corners
  BorderRadius get topRadius => BorderRadius.only(
        topLeft: Radius.circular(toDouble().r),
        topRight: Radius.circular(toDouble().r),
      );

  /// Only bottom corners
  BorderRadius get bottomRadius => BorderRadius.only(
        bottomLeft: Radius.circular(toDouble().r),
        bottomRight: Radius.circular(toDouble().r),
      );
}

/// Common responsive text styles
class AppTextStyles {
  // Headings
  static TextStyle get h1 => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );

  // Body text
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      );

  // Caption & labels
  static TextStyle get caption => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get label => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get button => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      );
}

/// Common responsive spacing values
class AppSpacing {
  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 16.r;
  static double get lg => 24.r;
  static double get xl => 32.r;
  static double get xxl => 48.r;
}

/// Common responsive icon sizes
class AppIconSizes {
  static double get xs => 16.r;
  static double get sm => 20.r;
  static double get md => 24.r;
  static double get lg => 32.r;
  static double get xl => 48.r;
}
