import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/grades_detail.dart';
import '../models/student_models.dart';
import '../models/auth_models.dart';

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

  // Training scores (typed response for screens expecting TrainingScoreListResponse)
  TrainingScoreListResponse? _trainingScores;
  TrainingScoreListResponse? get trainingScores => _trainingScores;

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

  // Student profile
  StudentProfile? _studentProfile;
  StudentProfile? get studentProfile => _studentProfile;

  // === Cache flags to avoid redundant network calls ===
  bool _gradesCached = false;
  bool _tuitionCached = false;
  bool _trainingPointsCached = false;
  bool _trainingScoresCached = false;
  bool _trainingProgramCached = false;
  bool _regulationsCached = false;
  bool _annualPlanCached = false;
  bool _progressCached = false;
  bool _gradeDetailsCached = false;
  bool _studentProfileCached = false;

  /// Clear provider cache and data (call on logout)
  void clearCache() {
    _gradesCached = false;
    _tuitionCached = false;
    _trainingPointsCached = false;
    _trainingScoresCached = false;
    _trainingProgramCached = false;
    _regulationsCached = false;
    _annualPlanCached = false;
    _progressCached = false;
    _gradeDetailsCached = false;
    _studentProfileCached = false;

    _grades = [];
    _tuition = null;
    _trainingPoints = [];
    _trainingScores = null;
    _trainingProgram = null;
    _regulations = null;
    _planImageUrl = null;
    _planDescription = null;
    _progress = null;
    _gradeDetails = null;
    _studentProfile = null;

    notifyListeners();
  }

  /// Fetch grades (list)
  Future<void> fetchGrades({String? semester, bool forceRefresh = false}) async {
    if (_gradesCached && !forceRefresh && (semester == null || semester.isEmpty)) {
      developer.log('fetchGrades: returning cached data', name: 'AcademicProvider');
      return;
    }

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
        _gradesCached = (semester == null || semester.isEmpty);
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
  Future<void> fetchTuition({bool forceRefresh = false}) async {
    if (_tuitionCached && !forceRefresh) {
      developer.log('fetchTuition: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching tuition...', name: 'AcademicProvider');
      final data = await _client.get('/api/students/tuition');

      if (data != null && data is Map<String, dynamic>) {
        _tuition = data;
        _tuitionCached = true;
        developer.log('Tuition fetched', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching tuition: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch training scores (typed)
  Future<void> fetchTrainingScores({String? filterBySemester, bool forceRefresh = false}) async {
    if (_trainingScoresCached && !forceRefresh && (filterBySemester == null || filterBySemester.isEmpty)) {
      developer.log('fetchTrainingScores: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching training scores...', name: 'AcademicProvider');
      final queryParams = <String, String>{};
      if (filterBySemester != null && filterBySemester.isNotEmpty) {
        queryParams['filter_by_semester'] = filterBySemester;
      }

      final data = await _client.get('/training-scores', queryParameters: queryParams);

      if (data != null && data is Map<String, dynamic>) {
        _trainingScores = TrainingScoreListResponse.fromJson(data);
        // also keep the raw trainingPoints list for other usages
        final pointsList = data['trainingScores'] as List? ?? [];
        _trainingPoints = pointsList.map((e) => e as Map<String, dynamic>).toList();
        _trainingScoresCached = (filterBySemester == null || filterBySemester.isEmpty);
        developer.log('Training scores fetched: ${_trainingScores?.trainingScores.length}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching training scores: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch training points
  Future<void> fetchTrainingPoints({String? semester, bool forceRefresh = false}) async {
    if (_trainingPointsCached && !forceRefresh && (semester == null || semester.isEmpty)) {
      developer.log('fetchTrainingPoints: returning cached data', name: 'AcademicProvider');
      return;
    }

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
        if (semester == null || semester.isEmpty) _trainingPointsCached = true;
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
  Future<void> fetchTrainingProgram({bool forceRefresh = false}) async {
    if (_trainingProgramCached && !forceRefresh) {
      developer.log('fetchTrainingProgram: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching training program...', name: 'AcademicProvider');
      final data = await _client.get('/api/students/training-program');

      if (data != null && data is Map<String, dynamic>) {
        _trainingProgram = data;
        _trainingProgramCached = true;
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
  Future<void> fetchRegulations({bool forceRefresh = false}) async {
    if (_regulationsCached && !forceRefresh) {
      developer.log('fetchRegulations: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching regulations...', name: 'AcademicProvider');
      final data = await _client.get('/api/public/regulations');

      if (data != null && data is String) {
        _regulations = data;
        _regulationsCached = true;
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
  Future<void> fetchAnnualPlan({bool forceRefresh = false}) async {
    if (_annualPlanCached && !forceRefresh) {
      developer.log('fetchAnnualPlan: returning cached data', name: 'AcademicProvider');
      return;
    }

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
          _annualPlanCached = true;
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
  Future<void> fetchProgress({bool forceRefresh = false}) async {
    if (_progressCached && !forceRefresh) {
      developer.log('fetchProgress: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching progress...', name: 'AcademicProvider');
      final data = await _client.get('/api/students/progress');

      if (data != null && data is Map<String, dynamic>) {
        _progress = data;
        _progressCached = true;
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
  Future<void> fetchGradeDetails({bool forceRefresh = false}) async {
    if (_gradeDetailsCached && !forceRefresh) {
      developer.log('fetchGradeDetails: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching grade details...', name: 'AcademicProvider');
      final data = await _client.get('/grades/details');

      if (data != null && data is Map<String, dynamic>) {
        _gradeDetails = GradesDetailResponse.fromJson(data);
        _gradeDetailsCached = true;
        // Log the number of semesters; fall back to 0 if null to avoid printing 'null'.
        developer.log('Grade details fetched: ${_gradeDetails?.semesters.length ?? 0}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching grade details: $e', name: 'AcademicProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch student profile
  Future<void> fetchStudentProfile({bool forceRefresh = false}) async {
    if (_studentProfileCached && !forceRefresh) {
      developer.log('fetchStudentProfile: returning cached data', name: 'AcademicProvider');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      developer.log('Fetching student profile...', name: 'AcademicProvider');
      final data = await _client.get('/api/auth/profile');

      if (data != null && data is Map<String, dynamic>) {
        _studentProfile = StudentProfile.fromJson(data);
        _studentProfileCached = true;
        developer.log('Student profile fetched: ${_studentProfile?.hoTen}', name: 'AcademicProvider');
      }
    } catch (e) {
      developer.log('Error fetching student profile: $e', name: 'AcademicProvider');
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

  /// Prefetch commonly used academic data. Intended to be called at app start or after login.
  Future<void> prefetch({bool forceRefresh = false}) async {
    try {
      developer.log('AcademicProvider: starting prefetch', name: 'AcademicProvider');
      await Future.wait([
        fetchGradeDetails(forceRefresh: forceRefresh),
        fetchGrades(forceRefresh: forceRefresh),
        fetchTrainingPoints(forceRefresh: forceRefresh),
        fetchProgress(forceRefresh: forceRefresh),
        fetchTuition(forceRefresh: forceRefresh),
        fetchTrainingProgram(forceRefresh: forceRefresh),
        fetchRegulations(forceRefresh: forceRefresh),
        fetchAnnualPlan(forceRefresh: forceRefresh),
        fetchStudentProfile(forceRefresh: forceRefresh),
      ]);
      developer.log('AcademicProvider: prefetch completed', name: 'AcademicProvider');
    } catch (e) {
      developer.log('AcademicProvider: prefetch error: $e', name: 'AcademicProvider');
      rethrow;
    }
  }
}
