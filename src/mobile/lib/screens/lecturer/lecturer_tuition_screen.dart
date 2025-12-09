import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerTuitionScreen - Tra cứu học phí sinh viên
class LecturerTuitionScreen extends StatefulWidget {
  const LecturerTuitionScreen({super.key});

  @override
  State<LecturerTuitionScreen> createState() => _LecturerTuitionScreenState();
}

class _LecturerTuitionScreenState extends State<LecturerTuitionScreen> {
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  List<Map<String, dynamic>> _tuitionData = [];
  bool _isLoading = false;
  bool _useMock = true; // allow quick mock testing

  @override
  void dispose() {
    _mssvController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _searchTuition() async {
    if (_mssvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập MSSV'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // If mock mode enabled, return local mock data for quick UI testing
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _tuitionData = _getMockDetails();
        _isLoading = false;
      });
      return;
    }

    try {
      final provider = context.read<LecturerProvider>();
      final data = await provider.fetchTuition(
        studentId: _mssvController.text,
        semester: _semesterController.text.isNotEmpty
            ? _semesterController.text
            : null,
      );

      if (!mounted) return;

      setState(() {
        _tuitionData = data;
        _isLoading = false;
      });

      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin học phí'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                _buildSearchForm(isDark),
                Expanded(
                  child: _isLoading
                      ? _buildShimmerLoading(isDark)
                      : _buildTuitionList(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                .withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payment_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tra cứu học phí',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Xem thông tin học phí sinh viên',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _mssvController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'MSSV *',
              hintText: 'Nhập mã số sinh viên',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor:
                  (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _semesterController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'Học kỳ (tùy chọn)',
              hintText: 'VD: HK1_2023-2024',
              prefixIcon: const Icon(Icons.calendar_today),
              filled: true,
              fillColor:
                  (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dùng mock dữ liệu',
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Switch(
                value: _useMock,
                onChanged: (v) => setState(() => _useMock = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _searchTuition,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Tra cứu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTuitionList(bool isDark) {
    if (_tuitionData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nhập MSSV để tra cứu học phí',
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _tuitionData.length,
      itemBuilder: (context, index) {
        final tuition = _tuitionData[index];
        return _buildTuitionCard(tuition, isDark);
      },
    );
  }

  Widget _buildTuitionCard(Map<String, dynamic> tuition, bool isDark) {
    String _getString(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        if (tuition.containsKey(k) && tuition[k] != null) return tuition[k].toString();
      }
      return fallback;
    }

    num _parseNumber(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      final s = v.toString();
      final cleaned = s.replaceAll(RegExp(r"[^0-9.-]"), '');
      return num.tryParse(cleaned) ?? 0;
    }

    num _getNum(List<String> keys) {
      for (final k in keys) {
        if (tuition.containsKey(k) && tuition[k] != null) return _parseNumber(tuition[k]);
      }
      return 0;
    }

    final hocKy = _getString(['hocKy', 'hoc_ky', 'hocky', 'hocKyName'], '');
    final soTinChi = _getNum(['soTinChi', 'so_tin_chi']);
    final hocPhi = _getNum(['hocPhi', 'hoc_phi', 'hocPhi', 'hocPhi', 'hocphi', 'tongHocPhi']);
    final noHocKyTruoc = _getNum(['noHocKyTruoc', 'no_hoc_ky_truoc']);
    final daDong = _getNum(['daDong', 'da_dong']);
    final conLai = _getNum(['soTienConLai', 'so_tien_con_lai', 'soTienConLai']) == 0
        ? (hocPhi - daDong)
        : _getNum(['soTienConLai', 'so_tien_con_lai', 'soTienConLai']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hocKy.isNotEmpty ? hocKy : 'Học kỳ',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // show nothing on right or could show status if available
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Số tín chỉ', soTinChi.toString(), isDark),
                const SizedBox(height: 8),
                _buildInfoRow('Học phí', _formatCurrency(hocPhi), isDark),
                if (noHocKyTruoc != 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Nợ học kỳ trước', _formatCurrency(noHocKyTruoc), isDark),
                ],
                const SizedBox(height: 8),
                _buildInfoRow('Đã đóng', _formatCurrency(daDong), isDark, valueColor: Colors.green),
                const SizedBox(height: 8),
                _buildInfoRow('Còn lại', _formatCurrency(conLai), isDark, valueColor: conLai > 0 ? Colors.red : Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} VNĐ';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã đóng':
      case 'paid':
        return Colors.green;
      case 'chưa đóng':
      case 'unpaid':
        return Colors.red;
      case 'đóng một phần':
      case 'partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            height: 150,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockDetails() {
    return [
      {
        'hocKy': '2023-2024_1',
        'soTinChi': 18,
        'hocPhi': 18174009,
        'noHocKyTruoc': 0,
        'daDong': 0,
        'soTienConLai': 18174009
      },
      {
        'hocKy': '2023-2024_2',
        'soTinChi': 15,
        'hocPhi': 14916098,
        'noHocKyTruoc': 18174009,
        'daDong': 0,
        'soTienConLai': 33090107
      },
      {
        'hocKy': '2024-2025_1',
        'soTinChi': 15,
        'hocPhi': 15032241,
        'noHocKyTruoc': 33090107,
        'daDong': 48293620,
        'soTienConLai': -171272
      },
    ];
  }
}
