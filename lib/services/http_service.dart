import 'dart:io';
import 'package:http/http.dart' as http;

/// Service for HTTP operations
class HttpService {
  HttpService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Download JSON from URL
  /// Supports both HTTP(S) URLs and local file:// URLs
  Future<String> downloadJson(String url) async {
    try {
      final uri = Uri.parse(url);

      // Handle local file:// URLs
      if (uri.scheme == 'file') {
        final filePath = uri.toFilePath();
        final file = File(filePath);

        if (!await file.exists()) {
          throw HttpException('File not found: $filePath');
        }

        return await file.readAsString();
      }

      // Handle HTTP(S) URLs
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw HttpException(
          'Failed to download: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Network error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Custom HTTP exception
class HttpException implements Exception {
  HttpException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
