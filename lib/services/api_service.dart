import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = 'https://liveaudience.rhapathon.org';

  static String get apiKey => AppConfig.apiKey;

  // KingsChat OAuth — implicit flow, no client secret
  static String get kcClientId => AppConfig.kcClientId;
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
    if (apiKey.isEmpty) {
      throw Exception('Search is not configured.');
    }
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
    if (apiKey.isEmpty) {
      throw Exception('Search is not configured.');
    }
    final uri = Uri.parse('$baseUrl/api/search_registrations.php').replace(
      queryParameters: {'action': 'detail', 'id': id, 'api_key': apiKey},
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    return _decode(res);
  }

  // ─── Contact outreach (stored in liveaudience DB) ────────────────────────

  /// GET one row, or null if not found / error.
  static Future<Map<String, dynamic>?> contactOutreachGet(String registrationId) async {
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('$baseUrl/api/contact_outreach.php').replace(
      queryParameters: {
        'api_key': apiKey,
        'action': 'get',
        'id': registrationId,
      },
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) return null;
    final data = body['data'];
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// GET many rows keyed by registration id.
  static Future<Map<String, Map<String, dynamic>>> contactOutreachBatch(
    List<String> registrationIds,
  ) async {
    if (apiKey.isEmpty || registrationIds.isEmpty) return {};
    final uri = Uri.parse('$baseUrl/api/contact_outreach.php').replace(
      queryParameters: {
        'api_key': apiKey,
        'action': 'batch',
        'ids': registrationIds.join(','),
      },
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) return {};
    final data = body['data'];
    if (data is! Map) return {};
    return data.map(
      (k, v) => MapEntry(
        k.toString(),
        Map<String, dynamic>.from(v as Map),
      ),
    );
  }

  /// Upsert outreach row (same API key as search).
  static Future<void> contactOutreachUpsert(
    String registrationId,
    Map<String, dynamic> payload,
  ) async {
    if (apiKey.isEmpty) {
      throw Exception('Search is not configured.');
    }
    final uri = Uri.parse('$baseUrl/api/contact_outreach.php').replace(
      queryParameters: {'api_key': apiKey},
    );
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({
            'registration_id': registrationId,
            ...payload,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final body = res.body.trim();
    if (!body.startsWith('{') && !body.startsWith('[')) {
      throw Exception(
        'HTTP ${res.statusCode}: expected JSON from contact_outreach.php (is it deployed?).',
      );
    }
    final map = jsonDecode(body) as Map<String, dynamic>;
    if (map['success'] != true) {
      throw Exception(map['message']?.toString() ?? 'Contact outreach save failed');
    }
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
