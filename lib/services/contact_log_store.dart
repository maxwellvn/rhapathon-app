import 'api_service.dart';

class ContactRecord {
  final bool contacted;
  final String? outcome;
  final String notes;
  final DateTime updatedAt;

  const ContactRecord({
    this.contacted = false,
    this.outcome,
    this.notes = '',
    required this.updatedAt,
  });

  factory ContactRecord.fromJson(Map<String, dynamic> j) {
    final u = j['updatedAt'] ?? j['updated_at'];
    return ContactRecord(
      contacted: j['contacted'] == true,
      outcome: j['outcome'] as String?,
      notes: j['notes'] as String? ?? '',
      updatedAt: DateTime.tryParse(u?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Remote-only persistence via [contact_outreach.php] (MySQL).
class ContactLogStore {
  ContactLogStore._();

  static Future<ContactRecord?> fetch(String registrationId) async {
    try {
      final raw = await ApiService.contactOutreachGet(registrationId);
      if (raw == null) return null;
      return ContactRecord.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, ContactRecord>> fetchBatch(List<String> registrationIds) async {
    if (registrationIds.isEmpty) return {};
    try {
      final batch = await ApiService.contactOutreachBatch(registrationIds);
      return batch.map((k, v) => MapEntry(k, ContactRecord.fromJson(v)));
    } catch (_) {
      return {};
    }
  }

  static Future<void> save(String registrationId, ContactRecord record) async {
    await ApiService.contactOutreachUpsert(registrationId, {
      'contacted': record.contacted,
      'outcome': record.outcome,
      'notes': record.notes,
      'updated_at': record.updatedAt.toIso8601String(),
    });
  }
}

abstract final class ContactOutcomes {
  static const reached = 'reached';
  static const noAnswer = 'no_answer';
  static const voicemail = 'voicemail';
  static const wrongNumber = 'wrong_number';
  static const callbackRequested = 'callback_requested';
  static const declined = 'declined';
  static const other = 'other';

  static const Map<String, String> labels = {
    reached: 'Reached',
    noAnswer: 'No answer',
    voicemail: 'Voicemail / left message',
    wrongNumber: 'Wrong number',
    callbackRequested: 'Callback requested',
    declined: 'Declined / not interested',
    other: 'Other',
  };

  static String? labelFor(String? key) =>
      key == null || key.isEmpty ? null : labels[key];
}
