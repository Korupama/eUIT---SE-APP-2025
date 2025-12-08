import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../models/auth_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AcademicProvider>();
      if (provider.studentProfile == null) {
        provider.fetchStudentProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC);
    final card = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('profile_title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AcademicProvider>().fetchStudentProfile(forceRefresh: true);
            },
          ),
        ],
      ),
      backgroundColor: bg,
      body: Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          final profile = provider.studentProfile;

          if (provider.isLoading && profile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin hồ sơ',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchStudentProfile(forceRefresh: true);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ HEADER CARD ĐƯỢC CENTER GIỮA MÀN HÌNH
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _buildHeaderCard(profile, isDark, card, textColor),
                  ),
                ),

                const SizedBox(height: 24),

                // Personal Information
                _buildSectionTitle('Thông tin cá nhân', isDark),
                const SizedBox(height: 12),
                _buildPersonalInfoCard(profile, isDark, card),

                const SizedBox(height: 24),

                // Academic Information
                _buildSectionTitle('Thông tin học tập', isDark),
                const SizedBox(height: 12),
                _buildAcademicInfoCard(profile, isDark, card),

                const SizedBox(height: 24),

                // Family Information
                _buildSectionTitle('Thông tin gia đình', isDark),
                const SizedBox(height: 12),
                _buildFamilyInfoCard(profile, isDark, card),

                const SizedBox(height: 24),

                // Contact Information
                _buildSectionTitle('Thông tin liên hệ', isDark),
                const SizedBox(height: 12),
                _buildContactInfoCard(profile, isDark, card),

                const SizedBox(height: 24),

                // Bank Information
                if (profile.maNganHang != null || profile.tenNganHang != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Thông tin ngân hàng', isDark),
                      const SizedBox(height: 12),
                      _buildBankInfoCard(profile, isDark, card),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Emergency Contact
                if (profile.thongTinNguoiCanBaoTin != null || profile.soDienThoaiBaoTin != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Người cần báo tin', isDark),
                      const SizedBox(height: 12),
                      _buildEmergencyContactCard(profile, isDark, card),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(StudentProfile profile, bool isDark, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.bluePrimary,
            backgroundImage: profile.anhTheUrl != null
                ? NetworkImage(profile.anhTheUrl!)
                : null,
            child: profile.anhTheUrl == null
                ? Text(
              profile.hoTen.split(' ').map((s) => s[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            profile.hoTen,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // MSSV
          Text(
            'MSSV: ${profile.mssv}',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          // Birth date
          if (profile.ngaySinh != null)
            Text(
              'Ngày sinh: ${_formatDate(profile.ngaySinh!)}',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPersonalInfoCard(StudentProfile profile, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow('Ngành học', profile.nganhHoc ?? 'Chưa cập nhật'),
          _buildInfoRow('Khóa học', profile.khoaHoc?.toString() ?? 'Chưa cập nhật'),
          _buildInfoRow('Lớp sinh hoạt', profile.lopSinhHoat ?? 'Chưa cập nhật'),
          _buildInfoRow('Nơi sinh', profile.noiSinh ?? 'Chưa cập nhật'),
          if (profile.cccd != null) _buildInfoRow('CCCD', profile.cccd!),
          if (profile.ngayCapCccd != null)
            _buildInfoRow('Ngày cấp CCCD', _formatDate(profile.ngayCapCccd!)),
          if (profile.noiCapCccd != null) _buildInfoRow('Nơi cấp CCCD', profile.noiCapCccd!),
          _buildInfoRow('Dân tộc', profile.danToc ?? 'Chưa cập nhật'),
          _buildInfoRow('Tôn giáo', profile.tonGiao ?? 'Chưa cập nhật'),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoCard(StudentProfile profile, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (profile.quaTrinhHocTapCongTac != null)
            _buildInfoRow('Quá trình học tập', profile.quaTrinhHocTapCongTac!),
          if (profile.thanhTich != null)
            _buildInfoRow('Thành tích', profile.thanhTich!),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoCard(StudentProfile profile, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Father's info
          if (profile.hoTenCha != null || profile.sdtCha != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin cha',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (profile.hoTenCha != null) _buildInfoRow('Họ tên', profile.hoTenCha!),
                if (profile.quocTichCha != null) _buildInfoRow('Quốc tịch', profile.quocTichCha!),
                if (profile.danTocCha != null) _buildInfoRow('Dân tộc', profile.danTocCha!),
                if (profile.tonGiaoCha != null) _buildInfoRow('Tôn giáo', profile.tonGiaoCha!),
                if (profile.sdtCha != null) _buildInfoRow('Số điện thoại', profile.sdtCha!),
                if (profile.emailCha != null) _buildInfoRow('Email', profile.emailCha!),
                if (profile.congViecCha != null) _buildInfoRow('Nghề nghiệp', profile.congViecCha!),
                const SizedBox(height: 16),
              ],
            ),

          // Mother's info
          if (profile.hoTenMe != null || profile.sdtMe != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin mẹ',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (profile.hoTenMe != null) _buildInfoRow('Họ tên', profile.hoTenMe!),
                if (profile.quocTichMe != null) _buildInfoRow('Quốc tịch', profile.quocTichMe!),
                if (profile.danTocMe != null) _buildInfoRow('Dân tộc', profile.danTocMe!),
                if (profile.tonGiaoMe != null) _buildInfoRow('Tôn giáo', profile.tonGiaoMe!),
                if (profile.sdtMe != null) _buildInfoRow('Số điện thoại', profile.sdtMe!),
                if (profile.emailMe != null) _buildInfoRow('Email', profile.emailMe!),
                if (profile.congViecMe != null) _buildInfoRow('Nghề nghiệp', profile.congViecMe!),
              ],
            ),

          // Guardian info
          if (profile.hoTenNgh != null || profile.sdtNgh != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Thông tin người giám hộ',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (profile.hoTenNgh != null) _buildInfoRow('Họ tên', profile.hoTenNgh!),
                if (profile.quocTichNgh != null) _buildInfoRow('Quốc tịch', profile.quocTichNgh!),
                if (profile.danTocNgh != null) _buildInfoRow('Dân tộc', profile.danTocNgh!),
                if (profile.tonGiaoNgh != null) _buildInfoRow('Tôn giáo', profile.tonGiaoNgh!),
                if (profile.sdtNgh != null) _buildInfoRow('Số điện thoại', profile.sdtNgh!),
                if (profile.emailNgh != null) _buildInfoRow('Email', profile.emailNgh!),
                if (profile.congViecNgh != null) _buildInfoRow('Nghề nghiệp', profile.congViecNgh!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(StudentProfile profile, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (profile.soDienThoai != null) _buildInfoRow('Số điện thoại', profile.soDienThoai!),
          if (profile.emailCaNhan != null) _buildInfoRow('Email cá nhân', profile.emailCaNhan!),
          if (profile.diaChiThuongTru != null) _buildInfoRow('Địa chỉ thường trú', profile.diaChiThuongTru!),
          if (profile.tinhThanhPho != null) _buildInfoRow('Tỉnh/Thành phố', profile.tinhThanhPho!),
          if (profile.phuongXa != null) _buildInfoRow('Phường/Xã', profile.phuongXa!),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard(StudentProfile profile, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (profile.maNganHang != null) _buildInfoRow('Mã ngân hàng', profile.maNganHang!),
          if (profile.tenNganHang != null) _buildInfoRow('Tên ngân hàng', profile.tenNganHang!),
          if (profile.soTaiKhoan != null) _buildInfoRow('Số tài khoản', profile.soTaiKhoan!),
          if (profile.chiNhanh != null) _buildInfoRow('Chi nhánh', profile.chiNhanh!),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(StudentProfile profile, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (profile.thongTinNguoiCanBaoTin != null)
            _buildInfoRow('Họ tên', profile.thongTinNguoiCanBaoTin!),
          if (profile.soDienThoaiBaoTin != null)
            _buildInfoRow('Số điện thoại', profile.soDienThoaiBaoTin!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}
