import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = provider.lecturerProfile;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Thông tin giảng viên'),
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: profile == null
          ? _buildLoading(isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile, isDark),
                  const SizedBox(height: 24),
                  _buildInfoSection('Thông tin cơ bản', [
                    _InfoRow('Mã giảng viên', profile.maGv),
                    _InfoRow('Họ và tên', profile.hoTen),
                    _InfoRow('Giới tính', profile.gioiTinh ?? 'N/A'),
                    _InfoRow('Ngày sinh', profile.ngaySinh != null
                        ? '${profile.ngaySinh!.day}/${profile.ngaySinh!.month}/${profile.ngaySinh!.year}'
                        : 'N/A'),
                    _InfoRow('Email', profile.email ?? 'N/A'),
                    _InfoRow('Số điện thoại', profile.soDienThoai ?? 'N/A'),
                  ], isDark),
                  const SizedBox(height: 16),
                  _buildInfoSection('Thông tin công tác', [
                    _InfoRow('Khoa', profile.khoa ?? 'N/A'),
                    _InfoRow('Bộ môn', profile.boMon ?? 'N/A'),
                    _InfoRow('Học vị', profile.hocVi ?? 'N/A'),
                    _InfoRow('Chức danh', profile.chucDanh ?? 'N/A'),
                    _InfoRow('Chuyên ngành', profile.chuyenNganh ?? 'N/A'),
                  ], isDark),
                  const SizedBox(height: 16),
                  _buildInfoSection('Thông tin cá nhân', [
                    _InfoRow('CCCD', profile.cccd ?? 'N/A'),
                    _InfoRow('Ngày cấp', profile.ngayCapCccd != null
                        ? '${profile.ngayCapCccd!.day}/${profile.ngayCapCccd!.month}/${profile.ngayCapCccd!.year}'
                        : 'N/A'),
                    _InfoRow('Nơi cấp', profile.noiCapCccd ?? 'N/A'),
                    _InfoRow('Dân tộc', profile.danToc ?? 'N/A'),
                    _InfoRow('Tôn giáo', profile.tonGiao ?? 'N/A'),
                    _InfoRow('Quốc tịch', profile.quocTich ?? 'N/A'),
                  ], isDark),
                  const SizedBox(height: 16),
                  _buildInfoSection('Địa chỉ', [
                    _InfoRow('Địa chỉ thường trú', profile.diaChiThuongTru ?? 'N/A'),
                    _InfoRow('Tỉnh/Thành phố', profile.tinhThanhPho ?? 'N/A'),
                    _InfoRow('Phường/Xã', profile.phuongXa ?? 'N/A'),
                  ], isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(dynamic profile, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppTheme.bluePrimary, AppTheme.bluePrimary.withAlpha(200)]
                  : [AppTheme.bluePrimary, AppTheme.blueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bluePrimary.withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: AppTheme.bluePrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.hoTen,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã GV: ${profile.maGv}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 14,
                      ),
                    ),
                    if (profile.chucDanh != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.chucDanh!,
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<_InfoRow> rows, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard.withAlpha(191) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(26) : AppTheme.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...rows.map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            row.label,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row.value,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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
