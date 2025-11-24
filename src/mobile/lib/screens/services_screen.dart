import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/animated_background.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Increased contrast: use a lighter slate-blue translucent card in dark mode
    // and a subtle white (10-20% opacity) stroke. In light mode keep white card but add faint stroke.
    final Color cardColor = isDark
        ? Color.fromRGBO(110, 123, 214, 0.22) // slate-blue translucent for dark mode
        : Colors.white;
    final Color strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.12) : Color.fromRGBO(0, 0, 0, 0.06);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // Animated background for dark mode matching HomeScreen
          if (isDark) const Positioned.fill(child: AnimatedBackground(isDark: true)),

          // Main scaffold content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(76),
              child: ClipRRect(
                // keep no rounded corners so it aligns with screen edges
                borderRadius: BorderRadius.zero,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    // Use elevated cardColor and a thin stroke to separate from background
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: strokeColor, width: 1),
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
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 20, // increased by 1 size (from 18 -> 20)
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.t('services_description'),
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
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
            body: SafeArea(
              child: SingleChildScrollView(
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
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildWidePlaceholderTile(context, isDark, loc, isLarge: true),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    int iconVariant = 0, // 0 = dark bg + primary-colored icon, 1 = pastel/gradient bg + white icon
    Gradient? iconGradient,
  }) {
    final fullWidth = MediaQuery.of(context).size.width - 20 * 2; // account for horizontal padding

    final displayTitle = title ?? loc.t('waiting_integration');
    final displaySubtitle = subtitle;
    final iconData = icon ?? Icons.miscellaneous_services_outlined;

    // Define tile colors here as well so this helper is self-contained
    final Color cardColor = isDark
        ? Color.fromRGBO(110, 123, 214, 0.22)
        : Colors.white;
    final Color strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.12) : Color.fromRGBO(0, 0, 0, 0.06);

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
      onTap: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(loc.t('coming_soon')),
          content: Text(displayTitle),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.t('close'))),
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
                    color: iconVariant == 0 ? Theme.of(context).colorScheme.primary : Colors.white,
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
                          // Title: strong white in dark mode, dark text in light mode
                          color: isDark ? Colors.white : Colors.black87,
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
                            color: isDark ? const Color(0xFFBFD8FF) : Colors.grey.shade600,
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
                  // Arrow color: use accent (primary) to invite action in both themes
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
