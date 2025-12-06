import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/schedule_models.dart';
import '../services/auth_service.dart';

/// ScheduleProvider handles fetching class schedule, exam schedule, and personal events.
class ScheduleProvider extends ChangeNotifier {
  final AuthService auth;
  ScheduleProvider({required this.auth});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ScheduleResponse? _schedule;
  ScheduleResponse? get schedule => _schedule;

  ExamScheduleResponse? _exams;
  ExamScheduleResponse? get exams => _exams;

  /// Fetch class schedule
  Future<void> fetchClasses({String viewMode = 'week', String? filterByCourse, String? filterByLecturer}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching student classes...', name: 'ScheduleProvider');

      // Follow QuickGPA-style pattern: explicit token check and http.get
      final token = await auth.getToken();
      if (token == null || token.isEmpty) {
        developer.log('ScheduleProvider: No token available; aborting fetchClasses', name: 'ScheduleProvider');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final uri = auth.buildUri('/api/student/schedule/classes');
      final queryParams = <String, String>{'view_mode': viewMode};
      if (filterByCourse != null && filterByCourse.isNotEmpty) queryParams['filter_by_course'] = filterByCourse;
      if (filterByLecturer != null && filterByLecturer.isNotEmpty) queryParams['filter_by_lecturer'] = filterByLecturer;
      final finalUri = uri.replace(queryParameters: queryParams);

      developer.log('ScheduleProvider: Calling $finalUri', name: 'ScheduleProvider');

      final res = await http.get(finalUri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _schedule = ScheduleResponse.fromJson(data);
        developer.log('Classes fetched: ${_schedule?.classes.length ?? 0}', name: 'ScheduleProvider');
      } else if (res.statusCode == 401) {
        // Unauthorized - token likely expired. Clear it so UX can re-authenticate.
        developer.log('ScheduleProvider: Unauthorized (401) while fetching classes. Deleting token.', name: 'ScheduleProvider');
        await auth.deleteToken();
      } else {
        developer.log('Failed to fetch classes: ${res.statusCode}', name: 'ScheduleProvider');
      }
    } catch (e) {
      developer.log('Error fetching classes: $e', name: 'ScheduleProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch exam schedule
  Future<void> fetchExams({String? filterBySemester, String? filterByGroup}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching exam schedule...', name: 'ScheduleProvider');
      final uri = auth.buildUri('/api/student/schedule/exams');
      final queryParams = <String, String>{};
      if (filterBySemester != null && filterBySemester.isNotEmpty) queryParams['filter_by_semester'] = filterBySemester;
      if (filterByGroup != null && filterByGroup.isNotEmpty) queryParams['filter_by_group'] = filterByGroup;
      final finalUri = queryParams.isNotEmpty ? uri.replace(queryParameters: queryParams) : uri;

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(finalUri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _exams = ExamScheduleResponse.fromJson(data);
        developer.log('Exams fetched: ${_exams?.exams.length ?? 0}', name: 'ScheduleProvider');
      } else {
        developer.log('Failed to fetch exams: ${res?.statusCode}', name: 'ScheduleProvider');
      }
    } catch (e) {
      developer.log('Error fetching exams: $e', name: 'ScheduleProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create personal event
  Future<PersonalEventResponse?> createPersonalEvent(PersonalEventRequest request) async {
    try {
      final uri = auth.buildUri('/api/student/schedule/personal');
      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.post(uri, headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }, body: jsonEncode(request.toJson())),
      );

      if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return PersonalEventResponse.fromJson(data);
      }
    } catch (e) {
      developer.log('Error creating personal event: $e', name: 'ScheduleProvider');
    }
    return null;
  }

  Future<PersonalEventResponse?> updatePersonalEvent(int eventId, PersonalEventUpdateRequest request) async {
    try {
      final uri = auth.buildUri('/api/student/schedule/personal/$eventId');
      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.put(uri, headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }, body: jsonEncode(request.toJson())),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return PersonalEventResponse.fromJson(data);
      }
    } catch (e) {
      developer.log('Error updating personal event: $e', name: 'ScheduleProvider');
    }
    return null;
  }

  Future<bool> deletePersonalEvent(int eventId) async {
    try {
      final uri = auth.buildUri('/api/student/schedule/personal/$eventId');
      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.delete(uri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) return true;
    } catch (e) {
      developer.log('Error deleting personal event: $e', name: 'ScheduleProvider');
    }
    return false;
  }

  Future<http.Response?> _makeAuthenticatedRequest({
    required Future<http.Response> Function(String token) requestFn,
    int retryCount = 0,
  }) async {
    try {
      final token = await auth.getToken();
      if (token == null) {
        developer.log('No token available', name: 'ScheduleProvider');
        return null;
      }

      final response = await requestFn(token);

      if (response.statusCode == 401 && retryCount == 0) {
        final newToken = await auth.refreshAccessToken();
        if (newToken != null) {
          return await _makeAuthenticatedRequest(requestFn: requestFn, retryCount: retryCount + 1);
        } else {
          await auth.logout();
          return null;
        }
      }

      return response;
    } catch (e) {
      developer.log('Authenticated request error: $e', name: 'ScheduleProvider');
      return null;
    }
  }
}
