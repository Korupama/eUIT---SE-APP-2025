class ScheduleClass {
  final String hocKy;
  final String maMonHoc;
  final String tenMonHoc;
  final String maLop;
  final int soTinChi;
  final String maGiangVien;
  final String tenGiangVien;
  final String thu;
  final int? tietBatDau;
  final int? tietKetThuc;
  final int? cachTuan;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;
  final String? phongHoc;
  final int? siSo;
  final String? hinhThucGiangDay;
  final String? ghiChu;

  ScheduleClass({
    required this.hocKy,
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.maLop,
    required this.soTinChi,
    required this.maGiangVien,
    required this.tenGiangVien,
    required this.thu,
    this.tietBatDau,
    this.tietKetThuc,
    this.cachTuan,
    this.ngayBatDau,
    this.ngayKetThuc,
    this.phongHoc,
    this.siSo,
    this.hinhThucGiangDay,
    this.ghiChu,
  });

  factory ScheduleClass.fromJson(Map<String, dynamic> json) {
    return ScheduleClass(
      hocKy: json['hocKy'] as String,
      maMonHoc: json['maMonHoc'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      maLop: json['maLop'] as String,
      soTinChi: json['soTinChi'] as int,
      maGiangVien: json['maGiangVien'] as String,
      tenGiangVien: json['tenGiangVien'] as String,
      thu: json['thu'] as String,
      tietBatDau: json['tietBatDau'] as int?,
      tietKetThuc: json['tietKetThuc'] as int?,
      cachTuan: json['cachTuan'] as int?,
      ngayBatDau: json['ngayBatDau'] != null
          ? DateTime.tryParse(json['ngayBatDau'] as String)
          : null,
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.tryParse(json['ngayKetThuc'] as String)
          : null,
      phongHoc: json['phongHoc'] as String?,
      siSo: json['siSo'] as int?,
      hinhThucGiangDay: json['hinhThucGiangDay'] as String?,
      ghiChu: json['ghiChu'] as String?,
    );
  }
}

class ScheduleResponse {
  final List<ScheduleClass> classes;
  final String? message;

  ScheduleResponse({required this.classes, this.message});

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      classes: (json['classes'] as List)
          .map((e) => ScheduleClass.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

class ExamSchedule {
  final String maMonHoc;
  final String tenMonHoc;
  final String maLop;
  final String maGiangVien;
  final String tenGiangVien;
  final DateTime ngayThi;
  final String caThi;
  final String? phongThi;
  final String? hinhThucThi;
  final String gkCk;
  final int soTinChi;

  ExamSchedule({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.maLop,
    required this.maGiangVien,
    required this.tenGiangVien,
    required this.ngayThi,
    required this.caThi,
    this.phongThi,
    this.hinhThucThi,
    required this.gkCk,
    required this.soTinChi,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      maMonHoc: json['maMonHoc'] as String,
      tenMonHoc: json['tenMonHoc'] as String,
      maLop: json['maLop'] as String,
      maGiangVien: json['maGiangVien'] as String,
      tenGiangVien: json['tenGiangVien'] as String,
      ngayThi: DateTime.parse(json['ngayThi'] as String),
      caThi: json['caThi'] as String,
      phongThi: json['phongThi'] as String?,
      hinhThucThi: json['hinhThucThi'] as String?,
      gkCk: json['gkCk'] as String,
      soTinChi: json['soTinChi'] as int,
    );
  }
}

class ExamScheduleResponse {
  final List<ExamSchedule> exams;
  final String? message;

  ExamScheduleResponse({required this.exams, this.message});

  factory ExamScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ExamScheduleResponse(
      exams: (json['exams'] as List)
          .map((e) => ExamSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

class PersonalEventRequest {
  final String eventName;
  final DateTime time;
  final String? location;
  final String? description;

  PersonalEventRequest({
    required this.eventName,
    required this.time,
    this.location,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'time': time.toIso8601String(),
    if (location != null) 'location': location,
    if (description != null) 'description': description,
  };
}

class PersonalEventUpdateRequest {
  final String? eventName;
  final DateTime? time;
  final String? location;
  final String? description;

  PersonalEventUpdateRequest({
    this.eventName,
    this.time,
    this.location,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    if (eventName != null) 'eventName': eventName,
    if (time != null) 'time': time!.toIso8601String(),
    if (location != null) 'location': location,
    if (description != null) 'description': description,
  };
}

class PersonalEvent {
  final int eventId;
  final String eventName;
  final DateTime time;
  final String? location;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalEvent({
    required this.eventId,
    required this.eventName,
    required this.time,
    this.location,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonalEvent.fromJson(Map<String, dynamic> json) {
    return PersonalEvent(
      eventId: json['eventId'] as int,
      eventName: json['eventName'] as String,
      time: DateTime.parse(json['time'] as String),
      location: json['location'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class PersonalEventConflict {
  final bool hasConflict;
  final String conflictType; // "class" | "exam"
  final String conflictDetails;

  PersonalEventConflict({
    required this.hasConflict,
    required this.conflictType,
    required this.conflictDetails,
  });

  factory PersonalEventConflict.fromJson(Map<String, dynamic> json) {
    return PersonalEventConflict(
      hasConflict: json['hasConflict'] as bool,
      conflictType: json['conflictType'] as String,
      conflictDetails: json['conflictDetails'] as String,
    );
  }
}

class PersonalEventResponse {
  final bool success;
  final String message;
  final PersonalEvent? event;
  final PersonalEventConflict? conflict;

  PersonalEventResponse({
    required this.success,
    required this.message,
    this.event,
    this.conflict,
  });

  factory PersonalEventResponse.fromJson(Map<String, dynamic> json) {
    return PersonalEventResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      event: json['event'] != null
          ? PersonalEvent.fromJson(json['event'] as Map<String, dynamic>)
          : null,
      conflict: json['conflict'] != null
          ? PersonalEventConflict.fromJson(
              json['conflict'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
