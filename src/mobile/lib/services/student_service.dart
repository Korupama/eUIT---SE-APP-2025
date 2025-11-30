import '../models/student_models.dart';
import 'api_client.dart';

class StudentService {
  final ApiClient _client;

  StudentService(this._client);

  /// Get student card info
  /// GET /card
  Future<StudentCard> getStudentCard() async {
    try {
      final response = await _client.get('/card');
      return StudentCard.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get quick GPA
  /// GET /quickgpa
  Future<QuickGpa> getQuickGpa() async {
    try {
      final response = await _client.get('/quickgpa');
      return QuickGpa.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get next class
  /// GET /nextclass
  Future<NextClass?> getNextClass() async {
    try {
      final response = await _client.get('/nextclass');
      if (response == null) return null;
      return NextClass.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException && e.statusCode == 204) {
        return null; // No upcoming classes
      }
      rethrow;
    }
  }

  /// Get grades
  /// GET /grades
  Future<GradeListResponse> getGrades({String? filterBySemester}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filterBySemester != null && filterBySemester.isNotEmpty) {
        queryParams['filter_by_semester'] = filterBySemester;
      }

      final response = await _client.get(
        '/grades',
        queryParameters: queryParams,
      );

      return GradeListResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed transcript
  /// GET /grades/details
  Future<TranscriptOverview> getDetailedTranscript({
    String? filterBySemester,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filterBySemester != null && filterBySemester.isNotEmpty) {
        queryParams['filter_by_semester'] = filterBySemester;
      }

      final response = await _client.get(
        '/grades/details',
        queryParameters: queryParams,
      );

      return TranscriptOverview.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get training scores
  /// GET /training-scores
  Future<TrainingScoreListResponse> getTrainingScores({
    String? filterBySemester,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filterBySemester != null && filterBySemester.isNotEmpty) {
        queryParams['filter_by_semester'] = filterBySemester;
      }

      final response = await _client.get(
        '/training-scores',
        queryParameters: queryParams,
      );

      return TrainingScoreListResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get tuition information
  /// GET /api/students/tuition
  Future<TotalTuition> getTuition({String? filterByYear}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filterByYear != null && filterByYear.isNotEmpty) {
        queryParams['filter_by_year'] = filterByYear;
      }

      final response = await _client.get(
        '/api/students/tuition',
        queryParameters: queryParams,
      );

      return TotalTuition.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get training progress
  /// GET /api/students/progress
  Future<ProgressTracking> getTrainingProgress() async {
    try {
      final response = await _client.get('/api/students/progress');
      return ProgressTracking.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get academic plan
  /// GET /api/public/academic-plan
  Future<Map<String, String>> getAcademicPlan() async {
    try {
      final response = await _client.get(
        '/api/public/academic-plan',
        requireAuth: false,
      );
      return Map<String, String>.from(response as Map);
    } catch (e) {
      rethrow;
    }
  }
}
