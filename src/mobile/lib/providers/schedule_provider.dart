import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/schedule_models.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

/// ScheduleProvider handles fetching class schedule, exam schedule, and personal events.
class ScheduleProvider extends ChangeNotifier {
  final AuthService auth;
  late final ApiClient _client;
  
  ScheduleProvider({required this.auth}) {
    _client = ApiClient(auth);
  }

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

      final queryParams = <String, String>{'view_mode': viewMode};
      if (filterByCourse != null && filterByCourse.isNotEmpty) queryParams['filter_by_course'] = filterByCourse;
      if (filterByLecturer != null && filterByLecturer.isNotEmpty) queryParams['filter_by_lecturer'] = filterByLecturer;

      final data = await _client.get('/api/student/schedule/classes', queryParameters: queryParams);

      if (data != null) {
        // ApiClient returns jsonDecode result (dynamic).
        // If the backend returns just list of classes or object? 
        // Based on original code: jsonDecode(res.body) as Map<String, dynamic>
        // Check if data is Map
        if (data is Map<String, dynamic>) {
           _schedule = ScheduleResponse.fromJson(data);
           developer.log('Classes fetched: ${_schedule?.classes.length ?? 0}', name: 'ScheduleProvider');
        }
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
      final queryParams = <String, dynamic>{};
      if (filterBySemester != null && filterBySemester.isNotEmpty) queryParams['filter_by_semester'] = filterBySemester;
      if (filterByGroup != null && filterByGroup.isNotEmpty) queryParams['filter_by_group'] = filterByGroup;

      final data = await _client.get('/api/student/schedule/exams', queryParameters: queryParams);

      if (data != null && data is Map<String, dynamic>) {
        _exams = ExamScheduleResponse.fromJson(data);
        developer.log('Exams fetched: ${_exams?.exams.length ?? 0}', name: 'ScheduleProvider');
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
      final body = request.toJson();
      final data = await _client.post('/api/student/schedule/personal', body: body);

      if (data != null && data is Map<String, dynamic>) {
        return PersonalEventResponse.fromJson(data);
      }
    } catch (e) {
      developer.log('Error creating personal event: $e', name: 'ScheduleProvider');
    }
    return null;
  }

  Future<PersonalEventResponse?> updatePersonalEvent(int eventId, PersonalEventUpdateRequest request) async {
    try {
      final body = request.toJson();
      final data = await _client.put('/api/student/schedule/personal/$eventId', body: body);

      if (data != null && data is Map<String, dynamic>) {
        return PersonalEventResponse.fromJson(data);
      }
    } catch (e) {
      developer.log('Error updating personal event: $e', name: 'ScheduleProvider');
    }
    return null;
  }

  Future<bool> deletePersonalEvent(int eventId) async {
    try {
      await _client.delete('/api/student/schedule/personal/$eventId');
      return true; // If no exception, delete succeeded
    } catch (e) {
      developer.log('Error deleting personal event: $e', name: 'ScheduleProvider');
    }
    return false;
  }

  /// Prefetch commonly used schedule data. Used by LoadingScreen.
  Future<void> prefetch({bool forceRefresh = false}) async {
    try {
      developer.log('ScheduleProvider: starting prefetch', name: 'ScheduleProvider');
      await Future.wait([
        fetchClasses(viewMode: 'week'),
        fetchExams(),
      ]);
      developer.log('ScheduleProvider: prefetch completed', name: 'ScheduleProvider');
    } catch (e) {
      developer.log('ScheduleProvider: prefetch error: $e', name: 'ScheduleProvider');
      rethrow;
    }
  }
}
