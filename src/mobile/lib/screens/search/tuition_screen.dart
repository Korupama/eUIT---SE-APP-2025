import 'package:flutter/material.dart';

class TuitionScreen extends StatefulWidget {
  const TuitionScreen({super.key});

  @override
  State<TuitionScreen> createState() => _TuitionScreenState();
}

class _TuitionScreenState extends State<TuitionScreen> {
  final List<Map<String, dynamic>> tuitionHistory = [
    {
      'semester': 'Học kỳ 2 2023-2024',
      'amount': '15.000.000 đ',
      'deadline': '2024-08-01',
      'status': 'unpaid', // unpaid or paid
    },
    {
      'semester': 'Học kỳ 1 2023-2024',
      'amount': '15.000.000 đ',
      'deadline': '2024-02-01',
      'status': 'paid',
    },
    {
      'semester': 'Học kỳ 2 2022-2023',
      'amount': '14.500.000 đ',
      'deadline': '2023-08-01',
      'status': 'paid',
    },
    {
      'semester': 'Học kỳ 1 2022-2023',
      'amount': '14.500.000 đ',
      'deadline': '2023-02-01',
      'status': 'paid',
    },
  ];

  int get totalUnpaid {
    int total = 0;
    for (var item in tuitionHistory) {
      if (item['status'] == 'unpaid') {
        String amount = item['amount'].replaceAll(RegExp(r'[^\d]'), '');
        total += int.parse(amount);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông tin học phí',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              _buildBalanceCard(),

              SizedBox(height: 24),

              // History Title
              Text(
                'Hóa đơn & Lịch sử giao dịch',
                style: TextStyle(
                  color: Colors.white,
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
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFFEF4444).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFFEF4444),
              size: 28,
            ),
          ),

          SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số dư hiện tại',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cần thanh toán ${_formatCurrency(totalUnpaid)}',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vui lòng thanh toán các khoản phí chưa hoàn thành trước hạn.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTuitionHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'HỌC KỲ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'SỐ TIỀN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'HẠN CHÓT',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TRẠNG THÁI',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'HÀNH ĐỘNG',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ...tuitionHistory.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == tuitionHistory.length - 1;

            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Semester
                  Expanded(
                    flex: 2,
                    child: Text(
                      item['semester'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Amount
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['amount'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Deadline
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['deadline'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Status
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item['status'] == 'paid'
                              ? Color(0xFF10B981).withOpacity(0.2)
                              : Color(0xFFEF4444).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['status'] == 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán',
                          style: TextStyle(
                            color: item['status'] == 'paid'
                                ? Color(0xFF10B981)
                                : Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // Action
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _handlePaymentAction(item['semester'], item['status']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item['status'] == 'paid'
                              ? Color(0xFF3B82F6)
                              : Color(0xFF8B5CF6),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          item['status'] == 'paid' ? 'Thanh toán' : 'Thanh toán',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    String str = amount.toString();
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

    return '$result đ';
  }

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