import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

/// AcademicProvider handles fetching academic data like grades, tuition, training, content.
class AcademicProvider extends ChangeNotifier {
  final AuthService auth;
  AcademicProvider({required this.auth});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Grades
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> get grades => _grades;

  // Tuition
  Map<String, dynamic>? _tuition;
  Map<String, dynamic>? get tuition => _tuition;

  // Training points
  List<Map<String, dynamic>> _trainingPoints = [];
  List<Map<String, dynamic>> get trainingPoints => _trainingPoints;

  // Training program
  Map<String, dynamic>? _trainingProgram;
  Map<String, dynamic>? get trainingProgram => _trainingProgram;

  // Regulations
  String? _regulations;
  String? get regulations => _regulations;

  // Annual plan
  String? _planImageUrl;
  String? get planImageUrl => _planImageUrl;
  String? _planDescription;
  String? get planDescription => _planDescription;

  // Progress
  Map<String, dynamic>? _progress;
  Map<String, dynamic>? get progress => _progress;

  // --- Academic Plan Loading State for PlanScreen ---
  bool _isAcademicPlanLoading = false;
  bool get isAcademicPlanLoading => _isAcademicPlanLoading;

  /// Fetch grades
  Future<void> fetchGrades({String? semester}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching grades...', name: 'AcademicProvider');
      final uri = auth.buildUri('/grades');
      final queryParams = <String, String>{};
      if (semester != null && semester.isNotEmpty) queryParams['filter_by_semester'] = semester;
      final finalUri = queryParams.isNotEmpty ? uri.replace(queryParameters: queryParams) : uri;

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(finalUri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final gradesList = data['grades'] as List? ?? [];
        _grades = gradesList.map((e) => e as Map<String, dynamic>).toList();
        developer.log('Grades fetched: ${_grades.length}', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch grades: ${res?.statusCode}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching grades: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch tuition
  Future<void> fetchTuition() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching tuition...', name: 'AcademicProvider');
      final uri = auth.buildUri('/api/students/tuition');

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(uri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _tuition = data;
        developer.log('Tuition fetched', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch tuition: ${res?.statusCode}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching tuition: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch training points
  Future<void> fetchTrainingPoints({String? semester}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching training points...', name: 'AcademicProvider');
      final uri = auth.buildUri('/training-scores');
      final queryParams = <String, String>{};
      if (semester != null && semester.isNotEmpty) queryParams['filter_by_semester'] = semester;
      final finalUri = queryParams.isNotEmpty ? uri.replace(queryParameters: queryParams) : uri;

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(finalUri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final pointsList = data['trainingScores'] as List? ?? [];
        _trainingPoints = pointsList.map((e) => e as Map<String, dynamic>).toList();
        developer.log('Training points fetched: ${_trainingPoints.length}', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch training points: ${res?.statusCode}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching training points: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch training program
  Future<void> fetchTrainingProgram() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching training program...', name: 'AcademicProvider');
      // Assuming it's not implemented, or use a placeholder
      final uri = auth.buildUri('/api/students/training-program');

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(uri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _trainingProgram = data;
        developer.log('Training program fetched', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch training program: ${res?.statusCode}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching training program: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch regulations
  Future<void> fetchRegulations() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching regulations...', name: 'AcademicProvider');
      final uri = auth.buildUri('/api/public/regulations');

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(uri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as String;
        _regulations = data;
        developer.log('Regulations fetched', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch regulations: ${res?.statusCode}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching regulations: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch annual plan
  Future<void> fetchAnnualPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching annual plan...', name: 'AcademicProvider');
      final uri = auth.buildUri('/api/public/academic-plan');

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final entry = data.entries.first;
          _planDescription = entry.key;
          _planImageUrl = entry.value;
        } else {
          _planDescription = null;
          _planImageUrl = null;
        }
        developer.log('Annual plan fetched', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch annual plan: ${res.statusCode}', name: 'AcademicProvider');
        _planDescription = null;
        _planImageUrl = null;
      }
    } catch (e) {
      developer.log('Error fetching annual plan: $e', name: 'AcademicProvider');
      _planDescription = null;
      _planImageUrl = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch progress
  Future<void> fetchProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching progress...', name: 'AcademicProvider');
      final uri = auth.buildUri('/api/students/progress');

      final res = await _makeAuthenticatedRequest(
        requestFn: (token) => http.get(uri, headers: {'Authorization': 'Bearer $token'}),
      );

      if (res != null && res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _progress = data;
        developer.log('Progress fetched', name: 'AcademicProvider');
      } else {
        developer.log('Failed to fetch progress: ${res?.statusCode}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching progress: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAcademicPlan() async {
    _isAcademicPlanLoading = true;
    notifyListeners();
    try {
      await fetchAnnualPlan();
    } finally {
      _isAcademicPlanLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response?> _makeAuthenticatedRequest({
    required Future<http.Response> Function(String token) requestFn,
    int retryCount = 0,
  }) async {
    try {
      final token = await auth.getToken();
      if (token == null) {
        developer.log('No token available', name: 'AcademicProvider');
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
      developer.log('Authenticated request error: $e', name: 'AcademicProvider');
      return null;
    }
  }
}
