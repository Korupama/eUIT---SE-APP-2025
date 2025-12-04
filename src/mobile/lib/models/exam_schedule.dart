class ExamSchedule {
  final String id;
  final String maMon;
  final String tenMon;
  final String nhom;
  final String loaiThi; // giuaky, cuoiky
  final DateTime ngayThi;
  final String gioBatDau;
  final String gioKetThuc;
  final String phong;
  final String toaNha;
  final int siSo;
  final String vaiTro; // coithi, chamthi
  final String? ghiChu;

  ExamSchedule({
    required this.id,
    required this.maMon,
    required this.tenMon,
    required this.nhom,
    required this.loaiThi,
    required this.ngayThi,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.phong,
    required this.toaNha,
    required this.siSo,
    required this.vaiTro,
    this.ghiChu,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      id: json['id'] as String,
      maMon: json['maMon'] as String,
      tenMon: json['tenMon'] as String,
      nhom: json['nhom'] as String,
      loaiThi: json['loaiThi'] as String,
      ngayThi: DateTime.parse(json['ngayThi'] as String),
      gioBatDau: json['gioBatDau'] as String,
      gioKetThuc: json['gioKetThuc'] as String,
      phong: json['phong'] as String,
      toaNha: json['toaNha'] as String,
      siSo: json['siSo'] as int,
      vaiTro: json['vaiTro'] as String,
      ghiChu: json['ghiChu'] as String?,
    );
  }

  String get loaiThiLabel {
    switch (loaiThi) {
      case 'giuaky':
        return 'Giữa kỳ';
      case 'cuoiky':
        return 'Cuối kỳ';
      default:
        return loaiThi;
    }
  }

  String get vaiTroLabel {
    switch (vaiTro) {
      case 'coithi':
        return 'Coi thi';
      case 'chamthi':
        return 'Chấm thi';
      default:
        return vaiTro;
    }
  }

  String get dateString {
    return '${ngayThi.day.toString().padLeft(2, '0')}/${ngayThi.month.toString().padLeft(2, '0')}/${ngayThi.year}';
  }

  String get timeRange {
    return '$gioBatDau - $gioKetThuc';
  }

  String get location {
    return '$phong - $toaNha';
  }

  bool get isUpcoming {
    return ngayThi.isAfter(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return ngayThi.year == now.year &&
        ngayThi.month == now.month &&
        ngayThi.day == now.day;
  }

  int get daysUntil {
    final now = DateTime.now();
    final difference = ngayThi.difference(
      DateTime(now.year, now.month, now.day),
    );
    return difference.inDays;
  }
}
