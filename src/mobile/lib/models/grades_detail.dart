// Models for grades details response

class SubjectDetail {
  final String hocKy;
  final String maMonHoc;
  final String tenMonHoc;
  final int? soTinChi;
  final double? trongSoQuaTrinh;
  final double? trongSoGiuaKi;
  final double? trongSoThucHanh;
  final double? trongSoCuoiKi;
  final double? diemQuaTrinh;
  final double? diemGiuaKi;
  final double? diemThucHanh;
  final double? diemCuoiKi;
  final double? diemTongKet;

  SubjectDetail({
    required this.hocKy,
    required this.maMonHoc,
    required this.tenMonHoc,
    this.soTinChi,
    this.trongSoQuaTrinh,
    this.trongSoGiuaKi,
    this.trongSoThucHanh,
    this.trongSoCuoiKi,
    this.diemQuaTrinh,
    this.diemGiuaKi,
    this.diemThucHanh,
    this.diemCuoiKi,
    this.diemTongKet,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return SubjectDetail(
      hocKy: json['hocKy'] as String? ?? '',
      maMonHoc: json['maMonHoc'] as String? ?? '',
      tenMonHoc: json['tenMonHoc'] as String? ?? '',
      soTinChi: _toInt(json['soTinChi']),
      trongSoQuaTrinh: _toDouble(json['trongSoQuaTrinh']),
      trongSoGiuaKi: _toDouble(json['trongSoGiuaKi']),
      trongSoThucHanh: _toDouble(json['trongSoThucHanh']),
      trongSoCuoiKi: _toDouble(json['trongSoCuoiKi']),
      diemQuaTrinh: _toDouble(json['diemQuaTrinh']),
      diemGiuaKi: _toDouble(json['diemGiuaKi']),
      diemThucHanh: _toDouble(json['diemThucHanh']),
      diemCuoiKi: _toDouble(json['diemCuoiKi']),
      diemTongKet: _toDouble(json['diemTongKet']),
    );
  }

  Map<String, dynamic> toJson() => {
        'hocKy': hocKy,
        'maMonHoc': maMonHoc,
        'tenMonHoc': tenMonHoc,
        'soTinChi': soTinChi,
        'trongSoQuaTrinh': trongSoQuaTrinh,
        'trongSoGiuaKi': trongSoGiuaKi,
        'trongSoThucHanh': trongSoThucHanh,
        'trongSoCuoiKi': trongSoCuoiKi,
        'diemQuaTrinh': diemQuaTrinh,
        'diemGiuaKi': diemGiuaKi,
        'diemThucHanh': diemThucHanh,
        'diemCuoiKi': diemCuoiKi,
        'diemTongKet': diemTongKet,
      };
}

class SemesterDetail {
  final String hocKy;
  final double? semesterGpa;
  final List<SubjectDetail> subjects;

  SemesterDetail({required this.hocKy, this.semesterGpa, required this.subjects});

  factory SemesterDetail.fromJson(Map<String, dynamic> json) {
    final subs = (json['subjects'] as List?) ?? [];
    return SemesterDetail(
      hocKy: json['hocKy'] as String? ?? '',
      semesterGpa: json['semesterGpa'] == null ? null : (json['semesterGpa'] is num ? (json['semesterGpa'] as num).toDouble() : double.tryParse(json['semesterGpa'].toString())),
      subjects: subs.map((e) => SubjectDetail.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'hocKy': hocKy,
        'semesterGpa': semesterGpa,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };
}

class GradesDetailResponse {
  final double? overallGpa;
  final int? accumulatedCredits;
  final List<SemesterDetail> semesters;

  GradesDetailResponse({this.overallGpa, this.accumulatedCredits, required this.semesters});

  factory GradesDetailResponse.fromJson(Map<String, dynamic> json) {
    final sems = (json['semesters'] as List?) ?? [];
    return GradesDetailResponse(
      overallGpa: json['overallGpa'] == null ? null : (json['overallGpa'] is num ? (json['overallGpa'] as num).toDouble() : double.tryParse(json['overallGpa'].toString())),
      accumulatedCredits: json['accumulatedCredits'] == null ? null : (json['accumulatedCredits'] is num ? (json['accumulatedCredits'] as num).toInt() : int.tryParse(json['accumulatedCredits'].toString())),
      semesters: sems.map((e) => SemesterDetail.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'overallGpa': overallGpa,
        'accumulatedCredits': accumulatedCredits,
        'semesters': semesters.map((s) => s.toJson()).toList(),
      };
}

