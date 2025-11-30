class NewsItem {
  final String tieuDe;
  final String url;
  final DateTime ngayDang;

  NewsItem({required this.tieuDe, required this.url, required this.ngayDang});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      tieuDe: json['tieuDe'] as String,
      url: json['url'] as String,
      ngayDang: DateTime.parse(json['ngayDang'] as String),
    );
  }
}

class Regulation {
  final String tenVanBan;
  final String urlVanBan;
  final DateTime? ngayBanHanh;

  Regulation({
    required this.tenVanBan,
    required this.urlVanBan,
    this.ngayBanHanh,
  });

  factory Regulation.fromJson(Map<String, dynamic> json) {
    return Regulation(
      tenVanBan: json['tenVanBan'] as String,
      urlVanBan: json['urlVanBan'] as String,
      ngayBanHanh: json['ngayBanHanh'] != null
          ? DateTime.tryParse(json['ngayBanHanh'] as String)
          : null,
    );
  }
}

class RegulationListResponse {
  final List<Regulation> regulations;
  final String? message;

  RegulationListResponse({required this.regulations, this.message});

  factory RegulationListResponse.fromJson(Map<String, dynamic> json) {
    return RegulationListResponse(
      regulations: (json['regulations'] as List)
          .map((e) => Regulation.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}
