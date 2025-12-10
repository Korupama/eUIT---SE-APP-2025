import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/animated_background.dart';
import 'package:flutter/services.dart';

class TrainingProgramScreen extends StatefulWidget {
  const TrainingProgramScreen({super.key});

  @override
  State<TrainingProgramScreen> createState() => _TrainingProgramScreenState();
}

class _TrainingProgramScreenState extends State<TrainingProgramScreen> {
  // Map of year -> list of programs
  final Map<String, List<Map<String, String>>> trainingPrograms = {
    'Khóa 20 - 2025': [
      {
        'name': 'Cử nhân ngành Kỹ thuật Phần mềm (Áp dụng từ khóa 20 - 2025)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-ky-thuat-phan-mem-ap-dung-tu-khoa-20-2025',
      },
      {
        'name':
            'Cử nhân ngành Mạng máy tính và An toàn thông tin (Chương trình liên kết với ĐH Birmingham City) (Áp dụng từ khóa 20-2025)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-mang-may-tinh-va-an-toan-thong-tin-chuong-trinh-lien-ket-voi-dh-birmingham-city-ap-dung-tu-khoa-20-2025',
      },
      {
        'name':
            'Cử nhân ngành Kỹ thuật Hệ thống Máy tính (Chương trình liên kết với Trường Đại học Newcastle - Liên bang Úc) (Áp dụng từ khóa 20 - 2025)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-ky-thuat-he-thong-may-tinh-chuong-trinh-lien-ket-voi-truong-dai-hoc-newcastle-lien-bang-uc-ap-dung-tu-khoa-20-2025',
      },
      {
        'name':
            'Cử nhân ngành Truyền thông đa phương tiện (Áp dụng từ khóa 20 - 2025)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-truyen-thong-da-phuong-tien-ap-dung-tu-khoa-20-2025',
      },
    ],
    'Khóa 19 - 2024': [
      {
        'name': 'Cử nhân ngành Công nghệ Thông tin (Áp dụng từ Khoá 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-cong-nghe-thong-tin-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành Hệ thống Thông tin (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-he-thong-thong-tin-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành Khoa học Máy tính (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-khoa-hoc-may-tinh-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành Trí tuệ Nhân tạo (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-tri-tue-nhan-tao-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành Kỹ thuật Máy tính (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-ky-thuat-may-tinh-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành Thiết kế Vi mạch (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-thiet-ke-vi-mach-ap-dung-tu-khoa-19-2024',
      },
      {
        'name':
            'Cử nhân ngành Mạng máy tính và Truyền thông dữ liệu (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-mang-may-tinh-va-truyen-thong-du-lieu-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành An toàn Thông tin (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-an-toan-thong-tin-ap-dung-tu-khoa-19-2024',
      },
      {
        'name': 'Cử nhân ngành Thương mại điện tử (Áp dụng từ Khoá 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-thuong-mai-dien-tu-ap-dung-tu-khoa-19-2024',
      },
      {
        'name':
            'Chương trình đào tạo song ngành ngành Thương mại điện tử (Áp dụng từ Khoá 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/chuong-trinh-dao-tao-song-nganh-thuong-mai-dien-tu-ap-dung-tu-khoa-19-2024',
      },
      {
        'name':
            'Cử nhân khoa học ngành Khoa học Dữ liệu (Áp dụng từ khóa 19 - 2024)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-khoa-hoc-nganh-khoa-hoc-du-lieu-ap-dung-tu-khoa-19-2024',
      },
    ],
    'Khóa 18 - 2023': [
      {
        'name':
            'Chương trình tiên tiến ngành Hệ thống Thông tin (Áp dụng từ khóa 18 - 2023)',
        'url':
            'https://daa.uit.edu.vn/content/chuong-trinh-tien-tien-nganh-he-thong-thong-tin-ap-dung-tu-khoa-18-2023',
      },
      {
        'name':
            'Cử nhân ngành Khoa học Máy tính (Chương trình liên kết với ĐH Birmingham City) (Áp dụng từ khóa 18 - 2023)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-khoa-hoc-may-tinh-chuong-trinh-lien-ket-voi-dh-birmingham-city-ap-dung-tu-khoa-18-2023',
      },
    ],
    'Khóa 17 - 2022': [
      {
        'name': 'Cử nhân ngành Công nghệ Thông tin (Áp dụng từ khóa 17 - 2022)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-cong-nghe-thong-tin-ap-dung-tu-khoa-17-2022',
      },
    ],
    'Khóa 16 - 2021': [
      {
        'name': 'Cử nhân ngành Hệ thống Thông tin (Áp dụng từ khóa 16 - 2021)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-he-thong-thong-tin-ap-dung-tu-khoa-16-2021',
      },
    ],
    'Khóa 15 - 2020': [
      {
        'name': 'Cử nhân ngành Khoa học Máy tính (Áp dụng từ khóa 15 - 2020)',
        'url':
            'https://daa.uit.edu.vn/content/cu-nhan-nganh-khoa-hoc-may-tinh-ap-dung-tu-khoa-15-2020',
      },
    ],
  };

  

  String? expandedYear;

  Future<void> _launchURL(String urlStr) async {
    const platform = MethodChannel('com.example.mobile/browser');
    try {
      await platform.invokeMethod('openUrl', {'url': urlStr});
    } catch (e) {
      // Fallback to url_launcher if platform channel fails
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlStr';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.t('training_program_title'),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: trainingPrograms.entries.map((entry) {
                    final year = entry.key;
                    final programs = entry.value;
                    final isExpanded = expandedYear == year;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color.fromRGBO(30, 41, 59, 0.62)
                            : const Color.fromRGBO(255, 255, 255, 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color.fromRGBO(255, 255, 255, 0.10)
                              : const Color.fromRGBO(0, 0, 0, 0.05),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header - Clickable to expand/collapse
                          InkWell(
                            onTap: () {
                              setState(() {
                                expandedYear = isExpanded ? null : year;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    color: const Color(0xFF4FFFED),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      year,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expanded list of programs
                          if (isExpanded)
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: programs.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03),
                                ),
                                itemBuilder: (context, index) {
                                  final program = programs[index];
                                  return InkWell(
                                    onTap: () => _launchURL(program['url']!),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              program['name']!,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.black87,
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.open_in_new,
                                            size: 18,
                                            color: const Color(0xFF4FFFED),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
