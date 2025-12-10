import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_background.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LecturerProvider>(context, listen: false);
      if (provider.lecturerProfile == null) {
        provider.fetchLecturerProfile();
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = provider.lecturerProfile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
            child: profile == null
                ? _buildLoading(isDark)
                : CustomScrollView(
                    slivers: [
                      _buildAppBar(profile, isDark),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildQuickActions(isDark),
                              const SizedBox(height: 20),
                              _buildInfoCard(
                                'Thông tin cơ bản',
                                Icons.person_outline,
                                [
                                  _InfoRow('Mã giảng viên', profile.maGv),
                                  _InfoRow('Họ và tên', profile.hoTen),
                                  _InfoRow(
                                    'Khoa/Bộ môn',
                                    profile.khoaBoMon ?? 'N/A',
                                  ),
                                  _InfoRow(
                                    'Ngày sinh',
                                    _formatDate(profile.ngaySinh),
                                  ),
                                  _InfoRow(
                                    'Nơi sinh',
                                    profile.noiSinh ?? 'N/A',
                                  ),
                                ],
                                isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                'Liên hệ',
                                Icons.contact_phone_outlined,
                                [
                                  _InfoRow(
                                    'Số điện thoại',
                                    profile.soDienThoai ?? 'N/A',
                                  ),
                                  _InfoRow('Email', profile.email ?? 'N/A'),
                                  _InfoRow(
                                    'Địa chỉ',
                                    profile.diaChiThuongTru ?? 'N/A',
                                  ),
                                  _InfoRow(
                                    'Phường/Xã',
                                    profile.phuongXa ?? 'N/A',
                                  ),
                                  _InfoRow(
                                    'Tỉnh/TP',
                                    profile.tinhThanhPho ?? 'N/A',
                                  ),
                                ],
                                isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                'Giấy tờ tùy thân',
                                Icons.badge_outlined,
                                [
                                  _InfoRow('CCCD', profile.cccd ?? 'N/A'),
                                  _InfoRow(
                                    'Ngày cấp',
                                    _formatDate(profile.ngayCapCccd),
                                  ),
                                  _InfoRow(
                                    'Nơi cấp',
                                    profile.noiCapCccd ?? 'N/A',
                                  ),
                                ],
                                isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                'Thông tin khác',
                                Icons.info_outline,
                                [
                                  _InfoRow('Dân tộc', profile.danToc ?? 'N/A'),
                                  _InfoRow(
                                    'Tôn giáo',
                                    profile.tonGiao ?? 'N/A',
                                  ),
                                ],
                                isDark,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(dynamic profile, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.bluePrimary.withOpacity(0.6),
                AppTheme.blueLight.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.bluePrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.hoTen,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mã GV: ${profile.maGv}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Center(
      child: SizedBox(
        width: 200,
        child: _buildActionButton(
          icon: Icons.edit,
          label: 'Cập nhật thông tin',
          onTap: () {
            // TODO: Implement update profile
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng đang phát triển'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          isDark: isDark,
          gradient: [Colors.blue.shade400, Colors.blue.shade600],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required List<Color> gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    List<_InfoRow> rows,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.darkCard.withOpacity(0.6),
                      AppTheme.darkCard.withOpacity(0.4),
                    ]
                  : [
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.5),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.bluePrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          row.label,
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          row.value,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? Colors.blue.shade300 : AppTheme.bluePrimary,
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
