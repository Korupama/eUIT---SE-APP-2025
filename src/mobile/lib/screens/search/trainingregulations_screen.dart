import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';
import '../../utils/app_localizations.dart';

class TrainingRegulationsScreen extends StatefulWidget {
  const TrainingRegulationsScreen({super.key});

  @override
  State<TrainingRegulationsScreen> createState() =>
      _TrainingRegulationsScreenState();
}

class _TrainingRegulationsScreenState extends State<TrainingRegulationsScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    final regulations = provider.regulations;
    final isLoading = provider.isRegulationsLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? const Color.fromRGBO(30, 41, 59, 0.62)
        : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.10)
        : const Color.fromRGBO(0, 0, 0, 0.05);

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
          'Quy chế & Đào tạo',
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchSection(cardColor, strokeColor, isDark),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: strokeColor, width: 1),
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : regulations.isEmpty
                            ? Center(
                                child: Text(
                                  'Chưa có dữ liệu quy chế',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                itemBuilder: (context, index) {
                                  final item = regulations[index];
                                  return _RegulationTile(
                                    index: index,
                                    title: item.tenVanBan,
                                    date: item.ngayBanHanh,
                                    isDark: isDark,
                                    onTap: () => _openPdf(
                                      item.urlVanBan,
                                      item.tenVanBan,
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemCount: regulations.length,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(Color cardColor, Color strokeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: strokeColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm văn bản quy chế',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: (value) {
                context.read<AcademicProvider>().fetchRegulations(
                  searchTerm: value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPdf(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          body: PdfViewer.uri(Uri.parse(url)),
        ),
      ),
    );
  }
}

class _RegulationTile extends StatelessWidget {
  const _RegulationTile({
    required this.index,
    required this.title,
    required this.isDark,
    this.date,
    this.onTap,
  });

  final int index;
  final String title;
  final DateTime? date;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark
        ? const Color.fromRGBO(40, 50, 70, 0.8)
        : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}.',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _formatDate(date!),
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.picture_as_pdf_outlined,
              color: textColor.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
