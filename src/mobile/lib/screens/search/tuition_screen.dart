import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/app_localizations.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';

class TuitionScreen extends StatefulWidget {
  const TuitionScreen({super.key});

  @override
  State<TuitionScreen> createState() => _TuitionScreenState();
}

class _TuitionScreenState extends State<TuitionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchTuition();
    });
  }

  Map<String, dynamic>? get tuitionData {
    return context.watch<AcademicProvider>().tuition;
  }

  int get totalFee => tuitionData?['tongHocPhi'] ?? 0;
  int get totalPaid => tuitionData?['tongDaDong'] ?? 0;
  int get totalUnpaid => tuitionData?['tongConLai'] ?? 0;

  List<Map<String, dynamic>> get tuitionHistory {
    final list = tuitionData?['chiTietHocPhi'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double navBarHeight = 0 + bottomInset;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).t('tuition_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + navBarHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    _buildBalanceCard(),

                    SizedBox(height: 24),

                    // History Title
                    Text(
                      AppLocalizations.of(context).t('tuition_history_title'),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Tuition History Table
                    _buildTuitionHistoryTable(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: strokeColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(239, 68, 68, 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFEF4444),
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).t('tuition_total_fee_label'),
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatCurrency(totalFee),
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                        SizedBox(width: 4),
                        Text('Đã đóng: ', style: TextStyle(color: Color.fromRGBO(255,255,255,0.7), fontSize: 13)),
                        Text(_formatCurrency(totalPaid), style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                        SizedBox(width: 4),
                        Text('Còn lại: ', style: TextStyle(color: Color.fromRGBO(255,255,255,0.7), fontSize: 13)),
                        Text(_formatCurrency(totalUnpaid), style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTuitionHistoryTable() {
    final history = tuitionHistory;
    if (history.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
      final strokeColor = isDark ? const Color.fromRGBO(255,255,255,0.10) : const Color.fromRGBO(0,0,0,0.05);
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: strokeColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(AppLocalizations.of(context).t('tuition_no_data'), style: TextStyle(color: isDark ? Color.fromRGBO(255,255,255,0.5) : Colors.black54)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color.fromRGBO(30,41,59,0.62) : const Color.fromRGBO(255,255,255,0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? const Color.fromRGBO(255,255,255,0.10) : const Color.fromRGBO(0,0,0,0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color.fromRGBO(255,255,255,0.1) : const Color.fromRGBO(0,0,0,0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(AppLocalizations.of(context).t('tuition_table_col_semester'), style: TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text(AppLocalizations.of(context).t('tuition_table_col_credits'), style: TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text(AppLocalizations.of(context).t('tuition_table_col_fee'), style: TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text(AppLocalizations.of(context).t('tuition_table_col_paid'), style: TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text(AppLocalizations.of(context).t('tuition_table_col_unpaid'), style: TextStyle(color: Color.fromRGBO(255,255,255,0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...history.asMap().entries.map((entry) {
            final item = entry.value;
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(255,255,255,0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(item['hocKy'] ?? 'Unknown', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Text((item['soTinChi'] ?? 0).toString(), style: TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)),
                  Expanded(flex: 3, child: Text(_formatCurrency(item['hocPhi'] ?? 0), style: TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)),
                  Expanded(flex: 3, child: Text(_formatCurrency(item['daDong'] ?? 0), style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(flex: 3, child: Text(_formatCurrency(item['soTienConLai'] ?? 0), style: TextStyle(color: (item['soTienConLai'] ?? 0) > 0 ? Color(0xFFEF4444) : Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0 đ';
    int value = 0;
    if (amount is int) value = amount;
    if (amount is double) value = amount.toInt();
    if (amount is String) value = int.tryParse(amount) ?? 0;
    String str = value.abs().toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    if (value < 0) result = '-$result';
    return '$result đ';
  }

  // ignore: unused_element
  void _handlePaymentAction(String semester, String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'paid'
              ? 'Xem chi tiết thanh toán $semester'
              : 'Thanh toán học phí $semester',
        ),
        backgroundColor: status == 'paid' ? Color(0xFF3B82F6) : Color(0xFF8B5CF6),
        duration: Duration(seconds: 2),
      ),
    );
  }
}