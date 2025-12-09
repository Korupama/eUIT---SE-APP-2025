import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class RegulationsListScreen extends StatefulWidget {
  const RegulationsListScreen({super.key});

  @override
  State<RegulationsListScreen> createState() => _RegulationsListScreenState();
}

class _RegulationsListScreenState extends State<RegulationsListScreen> {
  static const List<Map<String, String>> _items = [
    {
      'title': '01. Quyết định về việc ban hành Quy chế đào tạo theo học chế tín chỉ',
      'url': 'https://daa.uit.edu.vn/01-quyet-dinh-ve-viec-ban-hanh-quy-che-dao-tao-theo-hoc-che-tin-chi'
    },
    {
      'title': '02. Quyết định về việc ban hành Qui định về công tác giáo trình',
      'url': 'https://daa.uit.edu.vn/thongbao/02-quyet-dinh-ve-viec-ban-hanh-qui-dinh-ve-cong-tac-giao-trinh'
    },
    {
      'title': '03. Quyết định về việc ban hành Quy chế văn bằng chứng chỉ',
      'url': 'https://daa.uit.edu.vn/03-quyet-dinh-ve-viec-ban-hanh-quy-che-van-bang-chung-chi'
    },
    {
      'title': '04. Quyết định về việc ban hành Quy định về hệ tài năng',
      'url': 'https://daa.uit.edu.vn/04-quyet-dinh-ve-viec-ban-hanh-quy-dinh-ve-he-tai-nang'
    },
    {
      'title': '05. Quy định đào tạo ngoại ngữ đối với hệ đại học chính quy',
      'url': 'https://daa.uit.edu.vn/05-quy-dinh-dao-tao-ngoai-ngu-doi-voi-he-dai-hoc-chinh-quy-cua-truong-dhcntt'
    },
    {
      'title': '06. Quyết định về việc ban hành Quy định về khóa luận tốt nghiệp cho SV hệ CQ',
      'url': 'https://daa.uit.edu.vn/06-quyet-dinh-ve-viec-ban-hanh-quy-dinh-ve-khoa-luan-tot-nghiep-cho-sv-he-cq'
    },
    {
      'title': '07. Quyết định về việc ban hành Quy định tổ chức thi tập trung các môn học hệ ĐHCQ',
      'url': 'https://daa.uit.edu.vn/07-quyet-dinh-ve-viec-ban-hanh-quy-dinh-chuc-thi-tap-trung-cac-mon-hoc-he-dhcq'
    },
    {
      'title': '08. Quyết định về việc ban hành Quy trình báo nghỉ dạy, dạy bù',
      'url': 'https://daa.uit.edu.vn/thongbao/08-quyet-dinh-ve-viec-ban-hanh-quy-trinh-bao-nghi-day-day-bu'
    },
    {
      'title': '09. Quyết định về việc ban hành Quy chế đào tạo cho sinh viên hệ đào tạo từ xa',
      'url': 'https://daa.uit.edu.vn/09-quyet-dinh-ve-viec-ban-hanh-quy-che-dao-tao-cho-sinh-vien-he-dao-tao-tu-xa-trinh-do-dai-hoc'
    },
    {
      'title': '10. Quyết định về việc ban hành Quy trình đánh giá, cập nhật CTĐT',
      'url': 'https://daa.uit.edu.vn/thongbao/10-quyet-dinh-ve-viec-ban-hanh-quy-trinh-danh-gia-cap-nhat-ctdt-trinh-do-dhsdh'
    },
    {
      'title': '11. Quyết định về việc ban hành Quy định về việc mở ngành đào tạo',
      'url': 'https://daa.uit.edu.vn/thongbao/11-quyet-dinh-ve-viec-ban-hanh-quy-dinh-ve-viec-mo-nganh-dao-tao'
    },
    {
      'title': '12. Quyết định về việc ban hành Quy định về đào tạo chương trình Chất lượng cao',
      'url': 'https://daa.uit.edu.vn/thongbao/12-quyet-dinh-ve-viec-ban-hanh-quy-dinh-ve-dao-tao-chuong-trinh-chat-luong-cao'
    },
    {
      'title': '14. Qui định cách đặt mã môn học',
      'url': 'https://daa.uit.edu.vn/thongbao/14-qui-dinh-cach-dat-ma-mon-hoc'
    },
    {
      'title': '15. Qui định về giảng viên và trợ giảng môn học',
      'url': 'https://daa.uit.edu.vn/15-qui-dinh-ve-giang-vien-giang-vien-va-tro-giang-mon-hoc'
    },
    {
      'title': '16. Thời điểm và mức thu học phí gia hạn',
      'url': 'https://daa.uit.edu.vn/thongbao/16-thoi-diem-va-muc-thu-hoc-phi-gia-han-doi-voi-sinh-vien-he-dai-hoc-chinh-quy'
    },
    {
      'title': '17. Quy định về chính sách hỗ trợ công bố khoa học',
      'url': 'https://daa.uit.edu.vn/thongbao/17-quy-dinh-ve-chinh-sach-ho-tro-cong-bo-khoa-hoc'
    },
    {
      'title': '18. Quy trình phân công cán bộ coi thi',
      'url': 'https://daa.uit.edu.vn/thongbao/18-quy-trinh-phan-cong-can-bo-coi-thi-cho-cac-dot-thi-tap-trung-he-dai-hoc-chinh-quy'
    },
    {
      'title': '19. Quy trình nộp khoá luận tốt nghiệp sau khi bảo vệ',
      'url': 'https://daa.uit.edu.vn/thongbao/19-quy-trinh-nop-khoa-luan-tot-nghiep-sau-khi-bao-ve-truoc-hoi-dong-bao-ve-khoa-luan-tot'
    },
    {
      'title': '20. Quy định chương trình tiên tiến',
      'url': 'https://daa.uit.edu.vn/20-quy-dinh-chuong-trinh-tien-tien'
    },
    {
      'title': '21. Hướng dẫn Thang phân loại nhận thức, kỹ năng, thái độ',
      'url': 'https://daa.uit.edu.vn/thongbao/21-huong-dan-thang-phan-loai-nhan-thuc-ky-nang-thai-do-su-dung-tai-truong-dai-hoc-cong-nghe'
    },
    {
      'title': '22. Quy định về việc tổ chức dạy – học ngoài giờ hành chính',
      'url': 'https://daa.uit.edu.vn/thongbao/22-quy-dinh-ve-viec-chuc-day-hoc-ngoai-gio-hanh-chinh-doi-voi-cac-hoc-phan-trong-chuong'
    },
    {
      'title': '23. Quy định tạm thời về đào tạo liên thông',
      'url': 'https://daa.uit.edu.vn/thongbao/23-quy-dinh-tam-thoi-ve-dao-tao-lien-thong-tu-trinh-do-dai-hoc-len-trinh-do-thac-si-he'
    },
    {
      'title': '24. Quy định dạy và học theo phương thức trực tuyến và kết hợp',
      'url': 'https://daa.uit.edu.vn/thongbao/24-quyet-dinh-ve-viec-ban-hanh-quy-dinh-day-va-hoc-theo-phuong-thuc-truc-tuyen-va-phuong'
    },
    {
      'title': '25. Quy định tổ chức đánh giá kết quả học tập trực tuyến',
      'url': 'https://daa.uit.edu.vn/thongbao/25-quy-dinh-chuc-danh-gia-ket-qua-hoc-tap-theo-hinh-thuc-truc-tuyen'
    },
    {
      'title': '26. Quy định mời giảng viên thỉnh giảng từ doanh nghiệp',
      'url': 'https://daa.uit.edu.vn/thongbao/26-quy-dinh-moi-giang-vien-thinh-giang-tu-doanh-nghiep'
    },
    {
      'title': '27. Hướng dẫn đăng ký học phần cho sinh viên',
      'url': 'https://daa.uit.edu.vn/27-huong-dan-dang-ky-hoc-phan-cho-sinh-vien'
    },
    {
      'title': '28. Quy định đào tạo song ngành trình độ đại học',
      'url': 'https://daa.uit.edu.vn/28-quy-dinh-dao-tao-song-nganh-trinh-do-dai-hoc-he-chinh-quy'
    },
    {
      'title': '29. Quy định về đồ án tốt nghiệp tại doanh nghiệp',
      'url': 'https://daa.uit.edu.vn/29-quy-dinh-ve-do-tot-nghiep-tai-doanh-nghiep'
    },
    {
      'title': '30. Hướng dẫn chuyển đổi hệ thống tín chỉ sang Châu Âu',
      'url': 'https://daa.uit.edu.vn/30-huong-dan-chuyen-doi-he-thong-tin-chi-sang-he-thong-tich-luy-va-chuyen-doi-tin-chi-cua-chau-au'
    },
    {
      'title': '31. Quy chế tuyển sinh đại học chính quy',
      'url': 'https://daa.uit.edu.vn/31-quy-che-tuyen-sinh-dai-hoc-chinh-quy'
    },
    {
      'title': '32. Quy trình cảnh báo sinh viên về kết quả đăng ký học phần',
      'url': 'https://daa.uit.edu.vn/32-quy-trinh-canh-bao-sinh-vien-he-dai-hoc-chinh-quy-ve-ket-qua-dang-ky-hoc-phan-va-ket-qua-hoc-tap'
    },
    {
      'title': '33. Quy chế tuyển sinh hình thức đào tạo từ xa',
      'url': 'https://daa.uit.edu.vn/33-quy-che-tuyen-sinh-hinh-thuc-dao-tao-tu-xa-trinh-do-dai-hoc'
    },
    {
      'title': '34. Quy trình chuyển sinh viên từ chính quy sang từ xa',
      'url': 'https://daa.uit.edu.vn/34-quy-trinh-chuyen-sinh-vien-tu-hinh-thuc-dao-tao-chinh-quy-sang-hinh-thuc-dao-tao-tu-xa'
    },
    {
      'title': '35. Quy trình công nhận tín chỉ',
      'url': 'https://daa.uit.edu.vn/35-quy-trinh-cong-nhan-tin-chi-trong-dao-tao-dai-hoc-cua-truong-dai-hoc-cong-nghe-thong-tin'
    },
    {
      'title': '36. Quy định về Đồ án tốt nghiệp',
      'url': 'https://daa.uit.edu.vn/36-quy-dinh-ve-do-tot-nghiep'
    },
    {
      'title': '37. Quy định quản lý chương trình liên kết đào tạo với nước ngoài',
      'url': 'https://daa.uit.edu.vn/37-ban-hanh-quy-dinh-chuc-quan-ly-chuong-trinh-lien-ket-dao-tao-voi-nuoc-ngoai-trinh-do-dai-hoc-tai'
    },
    {
      'title': '38. Quy trình xử lý học vụ sinh viên đại học chính quy',
      'url': 'https://daa.uit.edu.vn/38-quy-trinh-xu-ly-hoc-vu-sinh-vien-dai-hoc-chinh-quy'
    },
    {
      'title': '39. Quy định về Liêm chính học thuật',
      'url': 'https://daa.uit.edu.vn/39quy-dinh-ve-liem-chinh-hoc-thuat-tai-truong-dai-hoc-cong-nghe-thong-tin'
    },
    {
      'title': '40. Biểu mẫu khóa luận tốt nghiệp dành cho Sinh viên',
      'url': 'https://daa.uit.edu.vn/bieu-mau-khoa-luan-tot-nghiep-danh-cho-sinh-vien'
    },
    {
      'title': '41. Quy chế, Quy định đào tạo đại học của Bộ GDĐT',
      'url': 'https://daa.uit.edu.vn/quy-che-quy-dinh-dao-tao-dai-hoc-cua-bo-gddt'
    },
  ];

  List<Map<String, String>> _filtered = List<Map<String, String>>.empty(growable: true);
  String _query = '';

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_items);
  }

  Future<void> _openUrl(BuildContext context, String urlStr) async {
    final uri = Uri.parse(urlStr);
    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Mở trang thất bại'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Không thể mở trang. Vui lòng sao chép link và dán vào trình duyệt:'),
              const SizedBox(height: 12),
              SelectableText(urlStr, style: const TextStyle(color: Colors.blue)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: urlStr));
                Navigator.of(c).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép link vào clipboard!')),
                  );
                }
              },
              child: const Text('Sao chép link'),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  void _filterItems(String q) {
    setState(() {
      _query = q;
      final lower = q.trim().toLowerCase();
      if (lower.isEmpty) {
        _filtered = List.from(_items);
      } else {
        _filtered = _items.where((it) {
          final title = (it['title'] ?? '').toLowerCase();
          final url = (it['url'] ?? '').toLowerCase();
          return title.contains(lower) || url.contains(lower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quy định'),
        backgroundColor: isDark ? const Color(0xFF1E2746) : AppTheme.bluePrimary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm quy định hoặc url...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _filterItems(''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _filterItems,
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy quy định phù hợp.',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      return ListTile(
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['url'] ?? ''),
                        isThreeLine: (item['title'] ?? '').length > 60,
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _openUrl(context, item['url'] ?? ''),
                        ),
                        onTap: () => _openUrl(context, item['url'] ?? ''),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _filtered.length,
                  ),
          ),
        ],
      ),
    );
  }
}
