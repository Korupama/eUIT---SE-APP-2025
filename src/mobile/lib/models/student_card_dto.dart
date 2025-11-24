// filepath: lib/models/student_card_dto.dart

class StudentCardDto {
  final int? mssv;
  final String? hoTen;
  final int? khoaHoc;
  final String? nganhHoc;
  final String? avatarFullUrl;

  StudentCardDto({this.mssv, this.hoTen, this.khoaHoc, this.nganhHoc, this.avatarFullUrl});

  factory StudentCardDto.fromJson(Map<String, dynamic> json) {
    return StudentCardDto(
      mssv: json['mssv'] is int ? json['mssv'] as int : (json['mssv'] != null ? int.tryParse(json['mssv'].toString()) : null),
      hoTen: json['hoTen']?.toString(),
      khoaHoc: json['khoaHoc'] is int ? json['khoaHoc'] as int : (json['khoaHoc'] != null ? int.tryParse(json['khoaHoc'].toString()) : null),
      nganhHoc: json['nganhHoc']?.toString(),
      avatarFullUrl: json['avatarFullUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mssv': mssv,
        'hoTen': hoTen,
        'khoaHoc': khoaHoc,
        'nganhHoc': nganhHoc,
        'avatarFullUrl': avatarFullUrl,
      };
}

