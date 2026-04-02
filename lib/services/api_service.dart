import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl   = 'https://liveaudience.rhapathon.org';
  static const String apiKey    = 'rhapaton_search_2026';

  // KingsChat OAuth — implicit flow, no client secret
  static const String kcClientId    = '619b30ea-a682-47fb-b90f-5b8e780b89ca';
  static const String kcCallbackUrl = '$baseUrl/api/kc_mobile_callback.php';

  /// Build the KingsChat auth URL directly — no server round-trip needed.
  static String buildAuthUrl() {
    final params = Uri(queryParameters: {
      'client_id'     : kcClientId,
      'scopes'        : 'profile',
      'redirect_uri'  : kcCallbackUrl,
      'response_type' : 'token',
      'post_redirect' : 'true',
    }).query;
    return 'https://accounts.kingsch.at/?$params';
  }

  /// Decode user info from the JWT access token payload (no network call).
  static Map<String, dynamic> decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      // Base64url → base64
      String b64 = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      // Pad to multiple of 4
      while (b64.length % 4 != 0) { b64 += '='; }
      final decoded = utf8.decode(base64Decode(b64));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Try to fetch the KingsChat profile via our server.
  /// Returns null on any failure — caller should fall back to JWT payload.
  static Future<Map<String, dynamic>?> tryVerifyToken(String token) async {
    try {
      final uri = Uri.parse('$baseUrl/api/kc_auth.php?action=verify');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': token}),
      ).timeout(const Duration(seconds: 8));

      final body = res.body.trim();
      if (!body.startsWith('{')) return null;

      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['success'] != true) return null;
      return data['user'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> search(
    String query, {
    int limit = 50,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$baseUrl/api/search_registrations.php').replace(
      queryParameters: {
        'q': query,
        'limit': '$limit',
        'offset': '$offset',
        'api_key': apiKey,
      },
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> getDetail(String id) async {
    final uri = Uri.parse('$baseUrl/api/search_registrations.php').replace(
      queryParameters: {'action': 'detail', 'id': id, 'api_key': apiKey},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return _decode(res);
  }

  // ─── helper ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> _decode(http.Response res) {
    final body = res.body.trim();
    if (!body.startsWith('{') && !body.startsWith('[')) {
      throw Exception(
        'Server HTTP ${res.statusCode}: ${body.substring(0, body.length.clamp(0, 120))}',
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
