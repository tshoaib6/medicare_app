import '../network/api_client.dart';
import '../network/endpoints.dart';

class AdService {
  final ApiClient _client = ApiClient();

  /// Get active advertisements
  Future<Map<String, dynamic>> getActiveAds() async {
    final res = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.activeAds,
    );
    return res.data!;
  }

  /// Track ad impression
  Future<void> trackAdImpression(int adId) async {
    await _client.post(
      ApiEndpoints.adImpression(adId),
    );
  }

  /// Track ad click
  Future<void> trackAdClick(int adId) async {
    await _client.post(
      ApiEndpoints.adClick(adId),
    );
  }
}
