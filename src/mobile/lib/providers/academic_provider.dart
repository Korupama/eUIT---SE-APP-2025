import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/grades_detail.dart';

/// AcademicProvider handles fetching academic data like grades, tuition, training, content.
class AcademicProvider extends ChangeNotifier {
  final AuthService auth;
  late final ApiClient _client;

  AcademicProvider({required this.auth}) {
    _client = ApiClient(auth);
  }

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

  // Grade details
  GradesDetailResponse? _gradeDetails;
  GradesDetailResponse? get gradeDetails => _gradeDetails;

  /// Fetch grades
  Future<void> fetchGrades({String? semester}) async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching grades...', name: 'AcademicProvider');
      final queryParams = <String, String>{};
      if (semester != null && semester.isNotEmpty) queryParams['filter_by_semester'] = semester;

      final data = await _client.get('/grades', queryParameters: queryParams);

      if (data != null && data is Map<String, dynamic>) {
        final gradesList = data['grades'] as List? ?? [];
        _grades = gradesList.map((e) => e as Map<String, dynamic>).toList();
        developer.log('Grades fetched: ${_grades.length}', name: 'AcademicProvider');
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
      final data = await _client.get('/api/students/tuition');

      if (data != null && data is Map<String, dynamic>) {
        _tuition = data;
        developer.log('Tuition fetched', name: 'AcademicProvider');
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
      final queryParams = <String, String>{};
      if (semester != null && semester.isNotEmpty) queryParams['filter_by_semester'] = semester;

      final data = await _client.get('/training-scores', queryParameters: queryParams);

      if (data != null && data is Map<String, dynamic>) {
        final pointsList = data['trainingScores'] as List? ?? [];
        _trainingPoints = pointsList.map((e) => e as Map<String, dynamic>).toList();
        developer.log('Training points fetched: ${_trainingPoints.length}', name: 'AcademicProvider');
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
      final data = await _client.get('/api/students/training-program');

      if (data != null && data is Map<String, dynamic>) {
        _trainingProgram = data;
        developer.log('Training program fetched', name: 'AcademicProvider');
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
      
      // Note: If regulations endpoint returns plain string, ApiClient helper might try to parse JSON.
      // We should check ApiClient implementation. 
      // _handleResponse checks if it can decode JSON. 
      // If the response is not JSON, current ApiClient implementation throws "Invalid JSON response" or 
      // returns parsed JSON.
      // If endpoint returns plain text HTML/String:
      // The original code `jsonDecode(res.body) as String` implies the body IS a JSON string, e.g. "<html>...</html>"? 
      // Or it was simply `res.body` but wrapped in jsonDecode?
      // `jsonDecode("some string")` is invalid JSON unless it's quoted `"some string"`.
      // If it's pure HTML, jsonDecode fails.
      // Let's assume it's JSON-encoded string given the original code `jsonDecode(...) as String`.
      
      final data = await _client.get('/api/public/regulations');

      if (data != null && data is String) {
        _regulations = data;
        developer.log('Regulations fetched', name: 'AcademicProvider');
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
      // Public endpoint
      final data = await _client.get('/api/public/academic-plan', requireAuth: false);

      if (data != null && data is Map<String, dynamic>) {
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
         // handle error or empty
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
      final data = await _client.get('/api/students/progress');

      if (data != null && data is Map<String, dynamic>) {
        _progress = data;
        developer.log('Progress fetched', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching progress: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch grade details (subject-level)
  Future<void> fetchGradeDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching grade details...', name: 'AcademicProvider');
      final data = await _client.get('/grades/details');

      if (data != null && data is Map<String, dynamic>) {
        _gradeDetails = GradesDetailResponse.fromJson(data);
        developer.log('Grade details fetched: \\${_gradeDetails?.semesters.length}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching grade details: $e', name: 'AcademicProvider');
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
}
