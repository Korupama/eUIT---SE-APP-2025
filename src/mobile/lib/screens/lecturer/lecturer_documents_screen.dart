import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/lecturer_provider.dart';
import '../../models/document.dart';
import '../../widgets/animated_background.dart';

class LecturerDocumentsScreen extends StatefulWidget {
  const LecturerDocumentsScreen({super.key});

  @override
  State<LecturerDocumentsScreen> createState() =>
      _LecturerDocumentsScreenState();
}

class _LecturerDocumentsScreenState extends State<LecturerDocumentsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _selectedMaMon;
  String? _selectedLoaiTaiLieu;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LecturerProvider>(context, listen: false).fetchDocuments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          CustomScrollView(
            slivers: [
              _buildAppBar(isDark),
              SliverToBoxAdapter(child: _buildFilters(isDark)),
              _buildDocumentsList(isDark),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildUploadButton(isDark),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E2746) : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Tài liệu giảng dạy',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E2746).withOpacity(0.5),
                      const Color(0xFF2A3F7D).withOpacity(0.5),
                    ]
                  : [
                      Colors.white.withOpacity(0.6),
                      const Color(0xFFE3F2FD).withOpacity(0.6),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E2746).withOpacity(0.7),
                  const Color(0xFF2A3F7D).withOpacity(0.7),
                ]
              : [
                  Colors.white.withOpacity(0.75),
                  const Color(0xFFE3F2FD).withOpacity(0.75),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Search box
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tài liệu...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips for document types
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Tất cả', _selectedLoaiTaiLieu == null, () {
                setState(() {
                  _selectedLoaiTaiLieu = null;
                });
                _applyFilters();
              }, isDark),
              _buildFilterChip(
                'Slide',
                _selectedLoaiTaiLieu == 'slide',
                () {
                  setState(() {
                    _selectedLoaiTaiLieu = 'slide';
                  });
                  _applyFilters();
                },
                isDark,
                icon: Icons.slideshow,
              ),
              _buildFilterChip(
                'Bài tập',
                _selectedLoaiTaiLieu == 'baitap',
                () {
                  setState(() {
                    _selectedLoaiTaiLieu = 'baitap';
                  });
                  _applyFilters();
                },
                isDark,
                icon: Icons.assignment,
              ),
              _buildFilterChip(
                'Đề thi',
                _selectedLoaiTaiLieu == 'dethi',
                () {
                  setState(() {
                    _selectedLoaiTaiLieu = 'dethi';
                  });
                  _applyFilters();
                },
                isDark,
                icon: Icons.quiz,
              ),
              _buildFilterChip(
                'Tài liệu',
                _selectedLoaiTaiLieu == 'tailieu',
                () {
                  setState(() {
                    _selectedLoaiTaiLieu = 'tailieu';
                  });
                  _applyFilters();
                },
                isDark,
                icon: Icons.menu_book,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    VoidCallback onTap,
    bool isDark, {
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                )
              : null,
          color: selected
              ? null
              : (isDark ? const Color(0xFF0A0E21) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(bool isDark) {
    return Consumer<LecturerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildShimmerCard(isDark),
                childCount: 4,
              ),
            ),
          );
        }

        var documents = provider.documents;

        // Apply search filter
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          documents = documents.where((doc) {
            return doc.tieuDe.toLowerCase().contains(searchText) ||
                doc.moTa?.toLowerCase().contains(searchText) == true ||
                doc.maMon.toLowerCase().contains(searchText) ||
                doc.tenMon.toLowerCase().contains(searchText);
          }).toList();
        }

        if (documents.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState(isDark));
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final document = documents[index];
              return _buildDocumentGridCard(document, isDark);
            }, childCount: documents.length),
          ),
        );
      },
    );
  }

  Widget _buildDocumentGridCard(Document document, bool isDark) {
    final typeColor = _getTypeColor(document.loaiTaiLieu);
    final fileIcon = _getFileIcon(document.fileType);

    return GestureDetector(
      onTap: () => _viewDocument(document),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E2746), const Color(0xFF2A3F7D)]
                : [Colors.white, const Color(0xFFE3F2FD)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.7),
                  isDark
                      ? Colors.white.withOpacity(0.02)
                      : Colors.white.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File icon and type badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [typeColor.withOpacity(0.8), typeColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(fileIcon, color: Colors.white, size: 28),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, size: 20),
                              SizedBox(width: 8),
                              Text('Chia sẻ'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download, size: 20),
                              SizedBox(width: 8),
                              Text('Tải xuống'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _handleMenuAction(value, document),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Flexible(
                  child: Text(
                    document.tieuDe,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Course
                Text(
                  document.maMon,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                // Stats
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${document.luotXem}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.download_outlined,
                      size: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${document.luotTai}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Size
                Text(
                  document.formattedSize,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentListCard(Document document, bool isDark) {
    final typeColor = _getTypeColor(document.loaiTaiLieu);
    final fileIcon = _getFileIcon(document.fileType);

    return GestureDetector(
      onTap: () => _viewDocument(document),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E2746), const Color(0xFF2A3F7D)]
                : [Colors.white, const Color(0xFFE3F2FD)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.7),
                    isDark
                        ? Colors.white.withOpacity(0.02)
                        : Colors.white.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  // File icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [typeColor.withOpacity(0.8), typeColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(fileIcon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.tieuDe,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${document.maMon} - ${document.tenMon}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: typeColor.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                document.typeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              document.formattedSize,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${document.luotXem}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.download_outlined,
                              size: 14,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${document.luotTai}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('Chia sẻ'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 8),
                            Text('Tải xuống'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value, document),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E2746), const Color(0xFF2A3F7D)]
              : [Colors.white, const Color(0xFFE3F2FD)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tài liệu',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để tải lên tài liệu mới',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(bool isDark) {
    return FloatingActionButton.extended(
      onPressed: _showUploadDialog,
      icon: const Icon(Icons.upload_file),
      label: const Text('Tải lên'),
      backgroundColor: const Color(0xFF2196F3),
      foregroundColor: Colors.white,
      elevation: 8,
    );
  }

  Color _getTypeColor(String loaiTaiLieu) {
    switch (loaiTaiLieu) {
      case 'slide':
        return const Color(0xFF2196F3); // Blue
      case 'baitap':
        return const Color(0xFFFF9800); // Orange
      case 'dethi':
        return const Color(0xFFF44336); // Red
      case 'tailieu':
        return const Color(0xFF4CAF50); // Green
      default:
        return Colors.grey;
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'WORD':
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'POWERPOINT':
      case 'PPT':
      case 'PPTX':
        return Icons.slideshow;
      case 'EXCEL':
      case 'XLS':
      case 'XLSX':
        return Icons.table_chart;
      case 'ARCHIVE':
      case 'ZIP':
      case 'RAR':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _applyFilters() {
    Provider.of<LecturerProvider>(
      context,
      listen: false,
    ).fetchDocuments(maMon: _selectedMaMon, loaiTaiLieu: _selectedLoaiTaiLieu);
  }

  void _viewDocument(Document document) {
    // TODO: Implement document viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mở tài liệu: ${document.tieuDe}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleMenuAction(String action, Document document) {
    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chia sẻ tài liệu: ${document.tieuDe}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang tải xuống: ${document.tieuDe}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        break;
      case 'delete':
        _confirmDelete(document);
        break;
    }
  }

  void _confirmDelete(Document document) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2746) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận xóa',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa tài liệu "${document.tieuDe}"?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<LecturerProvider>(
                context,
                listen: false,
              ).deleteDocument(document.id);

              if (!mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa tài liệu'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E2746) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Tải lên tài liệu',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(height: 16),
              Text(
                'Chức năng tải lên tài liệu sẽ được cập nhật sau',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
