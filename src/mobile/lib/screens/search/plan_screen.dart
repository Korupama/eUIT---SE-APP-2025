import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';

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
    final isLoading = provider.isAcademicPlanLoading;
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://student.uit.edu.vn$imageUrl';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

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
          'Kế hoạch đào tạo',
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
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : (imageUrl == null || imageUrl.isEmpty)
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: strokeColor, width: 1),
                            ),
                            child: Text(
                              'Chưa có dữ liệu kế hoạch đào tạo',
                              style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: strokeColor, width: 1),
                            ),
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Text(
                                  'Không thể tải hình ảnh kế hoạch',
                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)),
                                ),
                              ),
                            ),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
