class Document {
  final String id;
  final String tieuDe;
  final String? moTa;
  final String maMon;
  final String tenMon;
  final String loaiTaiLieu; // slide, baitap, dethi, tailieu
  final String duongDan;
  final String? urlPreview;
  final int dungLuong; // bytes
  final DateTime ngayTao;
  final DateTime ngayCapNhat;
  final int luotXem;
  final int luotTai;
  final List<String>? tags;

  Document({
    required this.id,
    required this.tieuDe,
    this.moTa,
    required this.maMon,
    required this.tenMon,
    required this.loaiTaiLieu,
    required this.duongDan,
    this.urlPreview,
    required this.dungLuong,
    required this.ngayTao,
    required this.ngayCapNhat,
    this.luotXem = 0,
    this.luotTai = 0,
    this.tags,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      tieuDe: json['tieuDe'] as String,
      moTa: json['moTa'] as String?,
      maMon: json['maMon'] as String,
      tenMon: json['tenMon'] as String,
      loaiTaiLieu: json['loaiTaiLieu'] as String,
      duongDan: json['duongDan'] as String,
      urlPreview: json['urlPreview'] as String?,
      dungLuong: json['dungLuong'] as int,
      ngayTao: DateTime.parse(json['ngayTao'] as String),
      ngayCapNhat: DateTime.parse(json['ngayCapNhat'] as String),
      luotXem: json['luotXem'] as int? ?? 0,
      luotTai: json['luotTai'] as int? ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  String get fileType {
    final ext = duongDan.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'Word';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      case 'xls':
      case 'xlsx':
        return 'Excel';
      case 'zip':
      case 'rar':
        return 'Archive';
      default:
        return ext.toUpperCase();
    }
  }

  String get formattedSize {
    if (dungLuong < 1024) {
      return '$dungLuong B';
    } else if (dungLuong < 1024 * 1024) {
      return '${(dungLuong / 1024).toStringAsFixed(1)} KB';
    } else if (dungLuong < 1024 * 1024 * 1024) {
      return '${(dungLuong / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(dungLuong / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String get typeLabel {
    switch (loaiTaiLieu) {
      case 'slide':
        return 'Slide bài giảng';
      case 'baitap':
        return 'Bài tập';
      case 'dethi':
        return 'Đề thi';
      case 'tailieu':
        return 'Tài liệu tham khảo';
      default:
        return loaiTaiLieu;
    }
  }
}
