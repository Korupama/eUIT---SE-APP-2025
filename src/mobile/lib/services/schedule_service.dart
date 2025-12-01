import '../models/schedule_models.dart';
import 'api_client.dart';

class ScheduleService {
  final ApiClient _client;

  ScheduleService(this._client);

  /// Get class schedule
  /// GET /api/student/schedule/classes
  /// viewMode: "day" | "week" | "month" | "all"
  Future<ScheduleResponse> getClassSchedule({
    String viewMode = 'week',
    String? filterByCourse,
    String? filterByLecturer,
  }) async {
    try {
      final queryParams = <String, dynamic>{'view_mode': viewMode};

      if (filterByCourse != null && filterByCourse.isNotEmpty) {
        queryParams['filter_by_course'] = filterByCourse;
      }

      if (filterByLecturer != null && filterByLecturer.isNotEmpty) {
        queryParams['filter_by_lecturer'] = filterByLecturer;
      }

      final response = await _client.get(
        '/api/student/schedule/classes',
        queryParameters: queryParams,
      );

      return ScheduleResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get exam schedule
  /// GET /api/student/schedule/exams
  /// filterByGroup: "GK" | "CK"
  Future<ExamScheduleResponse> getExamSchedule({
    String? filterBySemester,
    String? filterByGroup,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filterBySemester != null && filterBySemester.isNotEmpty) {
        queryParams['filter_by_semester'] = filterBySemester;
      }

      if (filterByGroup != null && filterByGroup.isNotEmpty) {
        queryParams['filter_by_group'] = filterByGroup;
      }

      final response = await _client.get(
        '/api/student/schedule/exams',
        queryParameters: queryParams,
      );

      return ExamScheduleResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Create personal event
  /// POST /api/student/schedule/personal
  Future<PersonalEventResponse> createPersonalEvent(
    PersonalEventRequest request,
  ) async {
    try {
      final response = await _client.post(
        '/api/student/schedule/personal',
        body: request.toJson(),
      );

      return PersonalEventResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update personal event
  /// PUT /api/student/schedule/personal/{event_id}
  Future<PersonalEventResponse> updatePersonalEvent(
    int eventId,
    PersonalEventUpdateRequest request,
  ) async {
    try {
      final response = await _client.put(
        '/api/student/schedule/personal/$eventId',
        body: request.toJson(),
      );

      return PersonalEventResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete personal event
  /// DELETE /api/student/schedule/personal/{event_id}
  Future<PersonalEventResponse> deletePersonalEvent(int eventId) async {
    try {
      final response = await _client.delete(
        '/api/student/schedule/personal/$eventId',
      );

      return PersonalEventResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
