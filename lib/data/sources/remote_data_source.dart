import 'package:compound_calculator/core/constants.dart';
import 'package:compound_calculator/services/http_service.dart';

/// Remote data source for downloading profiles
class RemoteDataSource {
  RemoteDataSource({HttpService? httpService})
      : _httpService = httpService ?? HttpService();
  final HttpService _httpService;

  /// Download profiles JSON from the default URL
  Future<String> downloadProfiles() async {
    return _httpService.downloadJson(AppConstants.profilesJsonUrl);
  }

  /// Download profiles JSON from a custom URL
  Future<String> downloadProfilesFromUrl(String url) async {
    return _httpService.downloadJson(url);
  }

  void dispose() {
    _httpService.dispose();
  }
}
