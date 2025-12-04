import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import 'student_confirmation_screen.dart';
import 'parking_monthly_screen.dart';
import 'certificate_confirmation_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Suggested dark palette (can be tuned):
    // Background: #0F172A, Card: #1E293B, Primary text: #F8FAFC, Secondary text: #94A3B8, Accent: #38BDF8
    // final Color darkCardBase = const Color(0xFF1E293B);

    // (AppBar uses transparent background; per-tile card/stroke colors are defined inside the tile builder)

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(76),
            child: ClipRRect(
              // keep no rounded corners so it aligns with screen edges
              borderRadius: BorderRadius.zero,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  // Make AppBar background transparent so the animated background shows through
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: false,
                    toolbarHeight: 76,
                    titleSpacing: 20,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 6), // nudge title down slightly to mimic old header spacing
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.t('services'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20, // increased by 1 size (from 18 -> 20)
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.t('services_description'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // Placeholder service tiles: now each tile combines two previous horizontal tiles (full-width cards)
                Column(
                  children: List.generate(6, (index) {
                    // All tiles should use the same compact sizing as the first one (isLarge: true)
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWidePlaceholderTile(
                          context,
                          isDark,
                          loc,
                          title: 'Đăng ký giấy xác nhận sinh viên',
                          subtitle: 'Phòng Công tác Sinh viên',
                          icon: Icons.description_outlined,
                          isLarge: true,
                          iconVariant: 0,
                          orderIndex: index,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StudentConfirmationScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWidePlaceholderTile(
                          context,
                          isDark,
                          loc,
                          title: 'Đăng ký Vé tháng gửi xe máy',
                          subtitle: 'Phòng Dữ liệu & Công nghệ thông tin',
                          icon: Icons.local_parking_rounded,
                          isLarge: true,
                          iconVariant: 0,
                          orderIndex: index,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ParkingMonthlyScreen(),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (index == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWidePlaceholderTile(
                          context,
                          isDark,
                          loc,
                          title: 'Đăng ký Xác nhận chứng chỉ',
                          subtitle: 'Phòng Đào tạo Đại học / VPCCTĐB',
                          icon: Icons.document_scanner_outlined,
                          isLarge: true,
                          iconVariant: 0,
                          orderIndex: index,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CertificateConfirmationScreen()),
                            );
                          },
                        ),
                      );
                    }

                    // Fourth tile: 'Đăng ký Phúc khảo'
                    if (index == 3) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWidePlaceholderTile(
                          context,
                          isDark,
                          loc,
                          title: 'Đăng ký Phúc khảo',
                          subtitle: 'Phòng Đào tạo Đại học / VPCCTĐB',
                          icon: Icons.edit_document,
                          isLarge: true,
                          iconVariant: 0,
                          orderIndex: index,
                        ),
                      );
                    }

                    // Fifth tile: 'Đăng ký bảng điểm'
                    if (index == 4) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWidePlaceholderTile(
                          context,
                          isDark,
                          loc,
                          title: 'Đăng ký Bảng điểm',
                          subtitle: 'Phòng Đào tạo Đại học / VPCCTĐB',
                          icon: Icons.receipt_long,
                          isLarge: true,
                          iconVariant: 0,
                          orderIndex: index,
                        ),
                      );
                    }

                    // Sixth tile: 'Đăng ký Giấy giới thiệu'
                    if (index == 5) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWidePlaceholderTile(
                          context,
                          isDark,
                          loc,
                          title: 'Đăng ký Giấy giới thiệu',
                          subtitle: 'Phòng Đào tạo Đại học / VPCCTĐB',
                          icon: Icons.assignment_ind,
                          isLarge: true,
                          iconVariant: 0,
                          orderIndex: index,
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildWidePlaceholderTile(context, isDark, loc, isLarge: true, orderIndex: index),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New: wide placeholder tile that spans the full content width (combines two horizontal tiles)
  Widget _buildWidePlaceholderTile(
    BuildContext context,
    bool isDark,
    AppLocalizations loc, {
    String? title,
    String? subtitle,
    IconData? icon,
    bool isLarge = false,
    int iconVariant = 0,
    Gradient? iconGradient,
    int orderIndex = -1,
    VoidCallback? onTap,
  }) {
    final fullWidth = MediaQuery.of(context).size.width - 20 * 2; // account for horizontal padding

    final displayTitle = title ?? loc.t('waiting_integration');
    final displaySubtitle = subtitle;
    final iconData = icon ?? Icons.miscellaneous_services_outlined;

    // Define tile colors here as well so this helper is self-contained
    // Reuse the suggested palette from build()
    final Color darkPrimaryText = const Color(0xFFF8FAFC);
    final Color darkSecondaryText = const Color(0xFF94A3B8);
    final Color defaultAccent = const Color(0xFF38BDF8);

    // Card color and stroke for tiles (local to this helper)
    // Use semi-transparent card backgrounds so the blurred/animated background shows through.
    // Dark: deep blue-gray with ~62% opacity. Light: white with slight transparency to soften edges.
    final Color cardColor = isDark ? Color.fromRGBO(30, 41, 59, 0.62) : Color.fromRGBO(255, 255, 255, 0.9);
    // Stroke remains subtle; slightly reduce dark stroke to avoid harsh lines on top of blurred background.
    final Color strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.10) : Color.fromRGBO(0, 0, 0, 0.5);

    // Determine stripe/icon/arrow colors:
    // Use a per-index palette so each tile gets its own distinctive color
    final List<Color> palette = [
      const Color(0xFF2F6BFF), // blue
      const Color(0xFF38BDF8), // sky
      const Color(0xFFF472B6), // pink
      const Color(0xFF7C3AED), // purple
      const Color(0xFF22C55E), // green
      const Color(0xFFF59E0B), // amber
    ];

    final bool hasIndex = orderIndex >= 0 && orderIndex < 10000; // simple guard
    final Color stripeColor = hasIndex ? palette[orderIndex % palette.length] : defaultAccent;

    // Helper to apply opacity when needed. Use the new r/g/b/a channels to avoid deprecated accessors.
    Color applyOpacity(Color c, double opacity) {
      // Convert color channels (r/g/b/a are 0.0..1.0) to 0..255 integers
      final int r = (c.r * 255.0).round() & 0xff;
      final int g = (c.g * 255.0).round() & 0xff;
      final int b = (c.b * 255.0).round() & 0xff;
      // Combine original alpha with requested opacity (preserve existing transparency)
      final int a = (c.a * opacity * 255.0).round() & 0xff;
      return Color.fromARGB(a, r, g, b);
    }

    // Adjust sizes. When isLarge==true we make the surrounding wrapper only slightly taller than the icon box
    final baseIconBoxSize = 56.0; // standard icon box size
    final iconBoxSize = baseIconBoxSize; // keep icon box consistent
    final paddingAll = isLarge ? 8.0 : 12.0;
    // For compact (isLarge) wrapper: height = iconBox + vertical padding + small offset
    final tileHeight = isLarge ? (iconBoxSize + paddingAll * 2 + 6.0) : 120.0;
    final iconSize = 32.0;
    final titleFontSize = isLarge ? 15.0 : 15.0;
    final titleWeight = isLarge ? FontWeight.w700 : FontWeight.w700;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ??
          () => showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(loc.t('coming_soon')),
                  content: Text(displayTitle),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(loc.t('close'))),
                  ],
                ),
              ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: fullWidth,
            height: tileHeight,
            padding: EdgeInsets.all(paddingAll),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: strokeColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Colored stripe (alternating by order or default accent)
                Container(
                  width: 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: applyOpacity(stripeColor, 0.95),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: iconVariant == 0
                        ? (isDark ? Color.fromRGBO(0, 0, 0, 0.28) : Color.fromRGBO(0, 0, 0, 0.08))
                        : null,
                    gradient: iconVariant == 1 ? iconGradient : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    size: iconSize,
                    // For variant 0 use stripeColor to color the icon; variant 1 keeps white
                    color: iconVariant == 0 ? stripeColor : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: TextStyle(
                          // Title: strong primary text in dark mode, dark text in light mode
                          color: isDark ? darkPrimaryText : Colors.black87,
                          fontSize: titleFontSize,
                          fontWeight: titleWeight,
                        ),
                      ),
                      if (displaySubtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          displaySubtitle,
                          style: TextStyle(
                            // Subtitle: use a light silver-blue in dark mode for hierarchy and readability
                            color: isDark ? darkSecondaryText : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  // Arrow color: use stripeColor to invite action
                  color: stripeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
