import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // returns current DateTime (separate function for easier testing/overriding)
  DateTime now() => DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AcademicProvider>().fetchAcademicPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    String? imageUrl = provider.planImageUrl;
    final isLoading = provider.isAcademicPlanLoading ?? false;
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://student.uit.edu.vn$imageUrl';
    }
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
          'Kế hoạch đào tạo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (imageUrl == null || imageUrl.isEmpty)
              ? Center(
                  child: Text(
                    'Chưa có dữ liệu kế hoạch đào tạo',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Text(
                          'Không thể tải hình ảnh kế hoạch',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
