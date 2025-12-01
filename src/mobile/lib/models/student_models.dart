class StudentCard {
  final int mssv;
  final String hoTen;
  final int khoaHoc;
  final String nganhHoc;
  final String? avatarFullUrl;

  StudentCard({
    required this.mssv,
    required this.hoTen,
    required this.khoaHoc,
    required this.nganhHoc,
    this.avatarFullUrl,
  });

  factory StudentCard.fromJson(Map<String, dynamic> json) {
    return StudentCard(
      mssv: json['mssv'] as int,
      hoTen: json['hoTen'] as String,
      khoaHoc: json['khoaHoc'] as int,
      nganhHoc: json['nganhHoc'] as String,
      avatarFullUrl: json['avatarFullUrl'] as String?,
    );
  }
}

class QuickGpa {
  final double gpa;
  final int soTinChiTichLuy;

  QuickGpa({required this.gpa, required this.soTinChiTichLuy});

  factory QuickGpa.fromJson(Map<String, dynamic> json) {
    return QuickGpa(
      gpa: (json['gpa'] as num).toDouble(),
      soTinChiTichLuy: json['soTinChiTichLuy'] as int,
    );
  }
}

class NextClass {
  final String maLop;
  final String tenMonHoc;
  final String tenGiangVien;
  final String thu;
  final int tietBatDau;
  final int tietKetThuc;
  final String phongHoc;
  final DateTime ngayHoc;
  final int countdownMinutes;

  NextClass({
    required this.maLop,
    required this.tenMonHoc,
    required this.tenGiangVien,
    required this.thu,
    required this.tietBatDau,
    required this.tietKetThuc,
    required this.phongHoc,
    required this.ngayHoc,
    required this.countdownMinutes,
  });

  factory NextClass.fromJson(Map<String, dynamic> json) {
    return NextClass(
      maLop: json['maLop'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      tenGiangVien: json['tenGiangVien'] as String,
      thu: json['thu'] as String,
      tietBatDau: json['tietBatDau'] as int,
      tietKetThuc: json['tietKetThuc'] as int,
      phongHoc: json['phongHoc'] as String,
      ngayHoc: DateTime.parse(json['ngayHoc'] as String),
      countdownMinutes: json['countdownMinutes'] as int,
    );
  }
}

class Grade {
  final String hocKy;
  final String maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final double? diemTongKet;

  Grade({
    required this.hocKy,
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    this.diemTongKet,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      hocKy: json['hocKy'] as String,
      maMonHoc: json['maMonHoc'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      soTinChi: json['soTinChi'] as int,
      diemTongKet: json['diemTongKet'] != null
          ? (json['diemTongKet'] as num).toDouble()
          : null,
    );
  }
}

class GradeListResponse {
  final List<Grade> grades;
  final String? message;

  GradeListResponse({required this.grades, this.message});

  factory GradeListResponse.fromJson(Map<String, dynamic> json) {
    return GradeListResponse(
      grades: (json['grades'] as List)
          .map((e) => Grade.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

class SubjectGradeDetail {
  final String hocKy;
  final String maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final int? trongSoQuaTrinh;
  final int? trongSoGiuaKi;
  final int? trongSoThucHanh;
  final int? trongSoCuoiKi;
  final double? diemQuaTrinh;
  final double? diemGiuaKi;
  final double? diemThucHanh;
  final double? diemCuoiKi;
  final double? diemTongKet;

  SubjectGradeDetail({
    required this.hocKy,
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
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

  factory SubjectGradeDetail.fromJson(Map<String, dynamic> json) {
    return SubjectGradeDetail(
      hocKy: json['hocKy'] as String,
      maMonHoc: json['maMonHoc'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      soTinChi: json['soTinChi'] as int,
      trongSoQuaTrinh: json['trongSoQuaTrinh'] as int?,
      trongSoGiuaKi: json['trongSoGiuaKi'] as int?,
      trongSoThucHanh: json['trongSoThucHanh'] as int?,
      trongSoCuoiKi: json['trongSoCuoiKi'] as int?,
      diemQuaTrinh: json['diemQuaTrinh'] != null
          ? (json['diemQuaTrinh'] as num).toDouble()
          : null,
      diemGiuaKi: json['diemGiuaKi'] != null
          ? (json['diemGiuaKi'] as num).toDouble()
          : null,
      diemThucHanh: json['diemThucHanh'] != null
          ? (json['diemThucHanh'] as num).toDouble()
          : null,
      diemCuoiKi: json['diemCuoiKi'] != null
          ? (json['diemCuoiKi'] as num).toDouble()
          : null,
      diemTongKet: json['diemTongKet'] != null
          ? (json['diemTongKet'] as num).toDouble()
          : null,
    );
  }
}

class SemesterTranscript {
  final String hocKy;
  final List<SubjectGradeDetail> subjects;
  final double? semesterGpa;

  SemesterTranscript({
    required this.hocKy,
    required this.subjects,
    this.semesterGpa,
  });

  factory SemesterTranscript.fromJson(Map<String, dynamic> json) {
    return SemesterTranscript(
      hocKy: json['hocKy'] as String,
      subjects: (json['subjects'] as List)
          .map((e) => SubjectGradeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      semesterGpa: json['semesterGpa'] != null
          ? (json['semesterGpa'] as num).toDouble()
          : null,
    );
  }
}

class TranscriptOverview {
  final double overallGpa;
  final int accumulatedCredits;
  final List<SemesterTranscript> semesters;

  TranscriptOverview({
    required this.overallGpa,
    required this.accumulatedCredits,
    required this.semesters,
  });

  factory TranscriptOverview.fromJson(Map<String, dynamic> json) {
    return TranscriptOverview(
      overallGpa: (json['overallGpa'] as num).toDouble(),
      accumulatedCredits: json['accumulatedCredits'] as int,
      semesters: (json['semesters'] as List)
          .map((e) => SemesterTranscript.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrainingScore {
  final String hocKy;
  final int tongDiem;
  final String xepLoai;
  final String tinhTrang;

  TrainingScore({
    required this.hocKy,
    required this.tongDiem,
    required this.xepLoai,
    required this.tinhTrang,
  });

  factory TrainingScore.fromJson(Map<String, dynamic> json) {
    return TrainingScore(
      hocKy: json['hocKy'] as String,
      tongDiem: json['tongDiem'] as int,
      xepLoai: json['xepLoai'] as String,
      tinhTrang: json['tinhTrang'] as String,
    );
  }
}

class TrainingScoreListResponse {
  final List<TrainingScore> trainingScores;
  final String? message;

  TrainingScoreListResponse({required this.trainingScores, this.message});

  factory TrainingScoreListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingScoreListResponse(
      trainingScores: (json['trainingScores'] as List)
          .map((e) => TrainingScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

class TuitionDetail {
  final String hocKy;
  final int soTinChi;
  final int hocPhi;
  final int noHocKyTruoc;
  final int daDong;
  final int soTienConLai;

  TuitionDetail({
    required this.hocKy,
    required this.soTinChi,
    required this.hocPhi,
    required this.noHocKyTruoc,
    required this.daDong,
    required this.soTienConLai,
  });

  factory TuitionDetail.fromJson(Map<String, dynamic> json) {
    return TuitionDetail(
      hocKy: json['hocKy'] as String,
      soTinChi: json['soTinChi'] as int,
      hocPhi: json['hocPhi'] as int,
      noHocKyTruoc: json['noHocKyTruoc'] as int,
      daDong: json['daDong'] as int,
      soTienConLai: json['soTienConLai'] as int,
    );
  }
}

class TotalTuition {
  final int tongHocPhi;
  final int tongDaDong;
  final int tongConLai;
  final List<TuitionDetail> chiTietHocPhi;

  TotalTuition({
    required this.tongHocPhi,
    required this.tongDaDong,
    required this.tongConLai,
    required this.chiTietHocPhi,
  });

  factory TotalTuition.fromJson(Map<String, dynamic> json) {
    return TotalTuition(
      tongHocPhi: json['tongHocPhi'] as int,
      tongDaDong: json['tongDaDong'] as int,
      tongConLai: json['tongConLai'] as int,
      chiTietHocPhi: (json['chiTietHocPhi'] as List)
          .map((e) => TuitionDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GroupProgress {
  final String groupName;
  final int completedCredits;
  final double gpa;

  GroupProgress({
    required this.groupName,
    required this.completedCredits,
    required this.gpa,
  });

  factory GroupProgress.fromJson(Map<String, dynamic> json) {
    return GroupProgress(
      groupName: json['groupName'] as String,
      completedCredits: json['completedCredits'] as int,
      gpa: (json['gpa'] as num).toDouble(),
    );
  }
}

class GraduationProgress {
  final int totalCreditsRequired;
  final int totalCreditsCompleted;
  final double completionPercentage;

  GraduationProgress({
    required this.totalCreditsRequired,
    required this.totalCreditsCompleted,
    required this.completionPercentage,
  });

  factory GraduationProgress.fromJson(Map<String, dynamic> json) {
    return GraduationProgress(
      totalCreditsRequired: json['totalCreditsRequired'] as int,
      totalCreditsCompleted: json['totalCreditsCompleted'] as int,
      completionPercentage: (json['completionPercentage'] as num).toDouble(),
    );
  }
}

class ProgressTracking {
  final List<GroupProgress> progressByGroup;
  final GraduationProgress graduationProgress;

  ProgressTracking({
    required this.progressByGroup,
    required this.graduationProgress,
  });

  factory ProgressTracking.fromJson(Map<String, dynamic> json) {
    return ProgressTracking(
      progressByGroup: (json['progressByGroup'] as List)
          .map((e) => GroupProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      graduationProgress: GraduationProgress.fromJson(
        json['graduationProgress'] as Map<String, dynamic>,
      ),
    );
  }
}
