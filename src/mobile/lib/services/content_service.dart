import '../models/content_models.dart';
import 'api_client.dart';

class ContentService {
  final ApiClient _client;

  ContentService(this._client);

  /// Get latest news
  /// GET /news
  Future<List<NewsItem>> getLatestNews() async {
    try {
      final response = await _client.get('/news', requireAuth: false);

      if (response is List) {
        return response
            .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get regulations list
  /// GET /api/public/regulations
  Future<RegulationListResponse> getRegulations({String? searchTerm}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['search_term'] = searchTerm;
      }

      final response = await _client.get(
        '/api/public/regulations',
        queryParameters: queryParams,
        requireAuth: false,
      );

      return RegulationListResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Download regulation file
  /// GET /api/public/regulations?download=true&file_name=...
  Future<List<int>> downloadRegulation(String fileName) async {
    try {
      final response = await _client.downloadFile(
        '/api/public/regulations',
        queryParameters: {'download': 'true', 'file_name': fileName},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
