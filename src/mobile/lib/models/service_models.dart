class ConfirmationLetterRequest {
  final String purpose;

  ConfirmationLetterRequest({required this.purpose});

  Map<String, dynamic> toJson() => {'purpose': purpose};
}

class ConfirmationLetterResponse {
  final int serialNumber;
  final String expiryDate;

  ConfirmationLetterResponse({
    required this.serialNumber,
    required this.expiryDate,
  });

  factory ConfirmationLetterResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmationLetterResponse(
      serialNumber: json['serialNumber'] as int,
      expiryDate: json['expiryDate'] as String,
    );
  }
}

class ConfirmationLetterHistory {
  final int serialNumber;
  final String purpose;
  final String expiryDate;
  final String requestedAt;

  ConfirmationLetterHistory({
    required this.serialNumber,
    required this.purpose,
    required this.expiryDate,
    required this.requestedAt,
  });

  factory ConfirmationLetterHistory.fromJson(Map<String, dynamic> json) {
    return ConfirmationLetterHistory(
      serialNumber: json['serialNumber'] as int,
      purpose: json['purpose'] as String,
      expiryDate: json['expiryDate'] as String,
      requestedAt: json['requestedAt'] as String,
    );
  }
}

class LanguageCertificateHistory {
  final int id;
  final String certificateType;
  final double score;
  final String issueDate;
  final String? expiryDate;
  final String status;
  final String? filePath;
  final String createdAt;

  LanguageCertificateHistory({
    required this.id,
    required this.certificateType,
    required this.score,
    required this.issueDate,
    this.expiryDate,
    required this.status,
    this.filePath,
    required this.createdAt,
  });

  factory LanguageCertificateHistory.fromJson(Map<String, dynamic> json) {
    return LanguageCertificateHistory(
      id: json['id'] as int,
      certificateType: json['certificateType'] as String,
      score: (json['score'] as num).toDouble(),
      issueDate: json['issueDate'] as String,
      expiryDate: json['expiryDate'] as String?,
      status: json['status'] as String,
      filePath: json['filePath'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}

class ParkingPassRequest {
  final String? licensePlate;
  final String vehicleType; // "bicycle" | "motorbike"
  final int registrationMonths;

  ParkingPassRequest({
    this.licensePlate,
    required this.vehicleType,
    required this.registrationMonths,
  });

  Map<String, dynamic> toJson() => {
    if (licensePlate != null) 'licensePlate': licensePlate,
    'vehicleType': vehicleType,
    'registrationMonths': registrationMonths,
  };
}

class ParkingPassResponse {
  final int id;
  final String licensePlate;
  final String vehicleType;
  final String registeredAt;
  final String expiryDate;

  ParkingPassResponse({
    required this.id,
    required this.licensePlate,
    required this.vehicleType,
    required this.registeredAt,
    required this.expiryDate,
  });

  factory ParkingPassResponse.fromJson(Map<String, dynamic> json) {
    return ParkingPassResponse(
      id: json['id'] as int,
      licensePlate: json['licensePlate'] as String,
      vehicleType: json['vehicleType'] as String,
      registeredAt: json['registeredAt'] as String,
      expiryDate: json['expiryDate'] as String,
    );
  }
}

class AppealRequest {
  final String courseId;
  final String reason;
  final String paymentMethod; // "cash" | "banking" | "momo" | "vnpay"

  AppealRequest({
    required this.courseId,
    required this.reason,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'reason': reason,
    'paymentMethod': paymentMethod,
  };
}

class AppealResponse {
  final int id;
  final String courseId;
  final String reason;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String createdAt;
  final String message;

  AppealResponse({
    required this.id,
    required this.courseId,
    required this.reason,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    required this.message,
  });

  factory AppealResponse.fromJson(Map<String, dynamic> json) {
    return AppealResponse(
      id: json['id'] as int,
      courseId: json['courseId'] as String,
      reason: json['reason'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      message: json['message'] as String,
    );
  }
}

class TuitionExtensionResponse {
  final int id;
  final String reason;
  final String desiredTime;
  final String? supportingDocs;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String message;

  TuitionExtensionResponse({
    required this.id,
    required this.reason,
    required this.desiredTime,
    this.supportingDocs,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.message,
  });

  factory TuitionExtensionResponse.fromJson(Map<String, dynamic> json) {
    return TuitionExtensionResponse(
      id: json['id'] as int,
      reason: json['reason'] as String,
      desiredTime: json['desiredTime'] as String,
      supportingDocs: json['supportingDocs'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      message: json['message'] as String,
    );
  }
}
