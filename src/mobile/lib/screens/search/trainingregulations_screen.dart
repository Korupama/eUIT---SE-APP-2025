import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';
import '../../utils/app_localizations.dart';
import '../../theme/app_theme.dart';

// Backend configuration
// Thay '10.0.2.2' bằng IP của máy chạy backend nếu cần (vd: '192.168.1.100')
const String BACKEND_BASE_URL = 'http://10.0.2.2:5128';

// Normalize Vietnamese strings by removing diacritics for search matching
String _stripDiacritics(String s) {
  if (s.isEmpty) return s;
  const map = {
    'à': 'a',
    'á': 'a',
    'ạ': 'a',
    'ả': 'a',
    'ã': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ậ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ặ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',

    'À': 'A',
    'Á': 'A',
    'Ạ': 'A',
    'Ả': 'A',
    'Ã': 'A',
    'Â': 'A',
    'Ầ': 'A',
    'Ấ': 'A',
    'Ậ': 'A',
    'Ẩ': 'A',
    'Ẫ': 'A',
    'Ă': 'A',
    'Ằ': 'A',
    'Ắ': 'A',
    'Ặ': 'A',
    'Ẳ': 'A',
    'Ẵ': 'A',

    'è': 'e',
    'é': 'e',
    'ẹ': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ệ': 'e',
    'ể': 'e',
    'ễ': 'e',
    'È': 'E',
    'É': 'E',
    'Ẹ': 'E',
    'Ẻ': 'E',
    'Ẽ': 'E',
    'Ê': 'E',
    'Ề': 'E',
    'Ế': 'E',
    'Ệ': 'E',
    'Ể': 'E',
    'Ễ': 'E',

    'ì': 'i',
    'í': 'i',
    'ị': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'Ì': 'I',
    'Í': 'I',
    'Ị': 'I',
    'Ỉ': 'I',
    'Ĩ': 'I',

    'ò': 'o',
    'ó': 'o',
    'ọ': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ộ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ợ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'Ò': 'O',
    'Ó': 'O',
    'Ọ': 'O',
    'Ỏ': 'O',
    'Õ': 'O',
    'Ô': 'O',
    'Ồ': 'O',
    'Ố': 'O',
    'Ộ': 'O',
    'Ổ': 'O',
    'Ỗ': 'O',
    'Ơ': 'O',
    'Ờ': 'O',
    'Ớ': 'O',
    'Ợ': 'O',
    'Ở': 'O',
    'Ỡ': 'O',

    'ù': 'u',
    'ú': 'u',
    'ụ': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ự': 'u',
    'ử': 'u',
    'ữ': 'u',
    'Ù': 'U',
    'Ú': 'U',
    'Ụ': 'U',
    'Ủ': 'U',
    'Ũ': 'U',
    'Ư': 'U',
    'Ừ': 'U',
    'Ứ': 'U',
    'Ự': 'U',
    'Ử': 'U',
    'Ữ': 'U',

    'ỳ': 'y',
    'ý': 'y',
    'ỵ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'Ỳ': 'Y',
    'Ý': 'Y',
    'Ỵ': 'Y',
    'Ỷ': 'Y',
    'Ỹ': 'Y',

    'đ': 'd',
    'Đ': 'D',
  };

  var out = StringBuffer();
  for (var ch in s.split('')) {
    out.write(map[ch] ?? ch);
  }
  return out.toString();
}

class TrainingRegulationsScreen extends StatefulWidget {
  const TrainingRegulationsScreen({super.key});

  @override
  State<TrainingRegulationsScreen> createState() =>
      _TrainingRegulationsScreenState();
}

class _TrainingRegulationsScreenState extends State<TrainingRegulationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchRegulations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(BuildContext context, String urlStr) async {
    // Replace localhost → emulator IP
    String fixedUrl = urlStr.replaceFirst("http://localhost", "http://10.0.2.2");

    // Encode space + unicode
    final uri = Uri.parse(Uri.encodeFull(fixedUrl));

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở file PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterItems(String q) {
    setState(() {
      _query = q;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterItems('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    final allRegulations = provider.regulations;
    final isLoading = provider.isRegulationsLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter regulations based on search query
    List<dynamic> filteredRegulations = allRegulations;
    if (_query.isNotEmpty) {
      final lower = _query.trim().toLowerCase();
      final normQuery = _stripDiacritics(lower);
      filteredRegulations = allRegulations.where((item) {
        final title = (item.tenVanBan ?? '').toLowerCase();
        final normTitle = _stripDiacritics(title);
        return normTitle.contains(normQuery);
      }).toList();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Use the shared animated background so appearance matches other screens
          Positioned.fill(
            child: IgnorePointer(child: AnimatedBackground(isDark: isDark)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header similar to regulations_list_screen
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.darkCard : Colors.white)
                        .withOpacity(0.7),
                    border: Border(
                      bottom: BorderSide(
                        color:
                            (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder)
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
                          Icons.rule_folder,
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
                              'Quy chế',
                              style: AppTheme.headingMedium.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Danh sách văn bản quy chế đào tạo',
                              style: AppTheme.bodyMedium.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm quy định...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.white,
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterItems,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                // List area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredRegulations.isEmpty
                        ? Center(
                            child: Text(
                              _query.isEmpty
                                  ? 'Chưa có dữ liệu quy chế'
                                  : 'Không tìm thấy quy định phù hợp.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemBuilder: (context, index) {
                              final item = filteredRegulations[index];
                              final title = item.tenVanBan ?? '';
                              final url = item.urlVanBan ?? '';
                              DateTime? date;
                              try {
                                date = item.ngayBanHanh;
                              } catch (_) {}
                              return Card(
                                color:
                                    (isDark ? AppTheme.darkCard : Colors.white)
                                        .withOpacity(0.85),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: date != null
                                      ? Text(
                                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        )
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    color: AppTheme.bluePrimary,
                                    onPressed: () => _openUrl(context, url),
                                  ),
                                  onTap: () => _openUrl(context, url),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemCount: filteredRegulations.length,
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
}
