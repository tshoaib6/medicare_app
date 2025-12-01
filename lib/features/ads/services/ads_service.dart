import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

/// Ads Service - Handles all advertisement related APIs
/// Following the exact API specification from the documentation
class AdsService {
  final ApiClient _apiClient = ApiClient();

  // =============================================================================
  // ADS APIs
  // =============================================================================

  /// GET /api/v1/ads/active - Get Active Ads
  Future<Map<String, dynamic>> getActiveAds() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.activeAds,
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to get active ads: $e');
    }
  }

  /// POST /api/v1/ads/{id}/impression - Track Ad Impression
  Future<Map<String, dynamic>> trackAdImpression(int adId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.adImpression(adId),
        data: {},
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to track ad impression: $e');
    }
  }

  /// POST /api/v1/ads/{id}/click - Track Ad Click
  Future<Map<String, dynamic>> trackAdClick(int adId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.adClick(adId),
        data: {},
      );

      if (response.data == null) {
        throw Exception('No response received from server');
      }

      return response.data!;
    } catch (e) {
      throw Exception('Failed to track ad click: $e');
    }
  }

  // =============================================================================
  // CONVENIENCE METHODS - Automatic Tracking
  // =============================================================================

  /// Automatically track impression when ad is displayed
  Future<void> onAdDisplayed(int adId) async {
    try {
      await trackAdImpression(adId);
    } catch (e) {
      // Silent fail for ad tracking
      print('Failed to track ad impression: $e');
    }
  }

  /// Automatically track click when ad is tapped
  Future<void> onAdClicked(int adId) async {
    try {
      await trackAdClick(adId);
    } catch (e) {
      // Silent fail for ad tracking
      print('Failed to track ad click: $e');
    }
  }
}
