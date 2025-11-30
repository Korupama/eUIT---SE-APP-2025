import '../models/service_models.dart';
import 'api_client.dart';

class ServiceApiService {
  final ApiClient _client;

  ServiceApiService(this._client);

  // ============ Confirmation Letter ============

  /// Request confirmation letter
  /// POST /api/service/confirmation-letter
  Future<ConfirmationLetterResponse> requestConfirmationLetter(
    ConfirmationLetterRequest request,
  ) async {
    try {
      final response = await _client.post(
        '/api/service/confirmation-letter',
        body: request.toJson(),
      );

      return ConfirmationLetterResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get confirmation letter history
  /// GET /api/service/confirmation-letter/history
  Future<List<ConfirmationLetterHistory>> getConfirmationLetterHistory() async {
    try {
      final response = await _client.get(
        '/api/service/confirmation-letter/history',
      );

      if (response is List) {
        return response
            .map(
              (e) =>
                  ConfirmationLetterHistory.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ Language Certificate ============

  /// Submit language certificate
  /// POST /api/service/language-certificate (multipart)
  Future<Map<String, dynamic>> submitLanguageCertificate({
    required String certificateType,
    required double score,
    required DateTime issueDate,
    DateTime? expiryDate,
    required String filePath,
  }) async {
    try {
      final fields = <String, String>{
        'certificateType': certificateType,
        'score': score.toString(),
        'issueDate': issueDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      };

      if (expiryDate != null) {
        fields['expiryDate'] = expiryDate.toIso8601String().split('T')[0];
      }

      final response = await _client.postMultipart(
        '/api/service/language-certificate',
        fields: fields,
        files: {'file': filePath},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get language certificate history
  /// GET /api/service/language-certificate/history
  Future<List<LanguageCertificateHistory>>
  getLanguageCertificateHistory() async {
    try {
      final response = await _client.get(
        '/api/service/language-certificate/history',
      );

      if (response is List) {
        return response
            .map(
              (e) => LanguageCertificateHistory.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ============ Parking Pass ============

  /// Register parking pass
  /// POST /api/service/parking-pass
  Future<ParkingPassResponse> registerParkingPass(
    ParkingPassRequest request,
  ) async {
    try {
      final response = await _client.post(
        '/api/service/parking-pass',
        body: request.toJson(),
      );

      return ParkingPassResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ============ Appeal ============

  /// Submit appeal
  /// POST /api/service/appeal
  Future<AppealResponse> submitAppeal(AppealRequest request) async {
    try {
      final response = await _client.post(
        '/api/service/appeal',
        body: request.toJson(),
      );

      return AppealResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ============ Tuition Extension ============

  /// Request tuition extension
  /// POST /api/service/tuition-extension (multipart)
  Future<TuitionExtensionResponse> requestTuitionExtension({
    required String reason,
    required DateTime desiredTime,
    String? supportingDocsPath,
  }) async {
    try {
      final fields = <String, String>{
        'reason': reason,
        'desiredTime': desiredTime.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD
      };

      final files = <String, String>{};
      if (supportingDocsPath != null) {
        files['supportingDocs'] = supportingDocsPath;
      }

      final response = await _client.postMultipart(
        '/api/service/tuition-extension',
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      return TuitionExtensionResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update tuition extension
  /// PUT /api/service/tuition-extension/{request_id} (multipart)
  Future<TuitionExtensionResponse> updateTuitionExtension({
    required int requestId,
    String? reason,
    DateTime? desiredTime,
    String? supportingDocsPath,
  }) async {
    try {
      final fields = <String, String>{};
      if (reason != null) {
        fields['reason'] = reason;
      }
      if (desiredTime != null) {
        fields['desiredTime'] = desiredTime.toIso8601String().split('T')[0];
      }

      final files = <String, String>{};
      if (supportingDocsPath != null) {
        files['supportingDocs'] = supportingDocsPath;
      }

      final response = await _client.putMultipart(
        '/api/service/tuition-extension/$requestId',
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );

      return TuitionExtensionResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
