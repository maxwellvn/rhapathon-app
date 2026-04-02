import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getDetail(widget.id);
      if (res['success'] == true) {
        setState(() { _data = res['data'] as Map<String, dynamic>; _loading = false; });
      } else {
        setState(() { _error = res['message'] ?? 'Not found'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Attendee Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A1A2E)))
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _buildDetail(),
      ),
    );
  }

  Widget _buildDetail() {
    final d = _data!;

    final title     = d['title'] as String? ?? '';
    final firstName = d['first_name'] as String? ?? '';
    final lastName  = d['last_name'] as String? ?? '';
    final fullName  = '$title $firstName $lastName'.trim();

    final email      = d['email'] as String? ?? '';
    final phone      = d['phone'] as String? ?? '';
    final kcUser     = d['kingschat_username'] as String? ?? '';
    final zone       = d['zone_name'] as String? ?? '';
    final network    = d['network_name'] as String? ?? '';
    final church     = d['church_name'] as String? ?? '';
    final group      = d['group_name'] as String? ?? '';
    final affType    = d['affiliation_type'] as String? ?? '';
    final lang       = d['language_preference'] as String? ?? '';
    final onsite     = d['onsite_participation'] as String? ?? '';
    final createdAt  = d['created_at'] as String? ?? '';
    final feedback   = d['feedback'] as String? ?? '';
    final regId      = d['id'] as String? ?? '';

    final selectedDays = (d['selected_days'] as List?)?.cast<String>() ?? [];
    final sessions     = d['sessions'] as Map<String, dynamic>? ?? {};

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF1A1A2E),
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        if (kcUser.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(kcUser,
                              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w500)),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Registered: $createdAt',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // QR Code
          if (regId.isNotEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Registration QR Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: QrImageView(
                        data: regId,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1A1A2E),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: $regId',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Contact info
          _Section(title: 'Contact Information', children: [
            _InfoRow(label: 'Email', value: email, copyable: true),
            _InfoRow(label: 'Phone', value: phone, copyable: true),
            _InfoRow(label: 'KingsChat', value: kcUser),
            _InfoRow(label: 'Language', value: lang.toUpperCase()),
          ]),

          const SizedBox(height: 12),

          // Church / Affiliation
          _Section(title: 'Church / Affiliation', children: [
            _InfoRow(label: 'Type', value: _capitalize(affType)),
            _InfoRow(label: 'Zone', value: zone),
            _InfoRow(label: 'Network', value: network),
            _InfoRow(label: 'Church', value: church),
            _InfoRow(label: 'Group', value: group),
          ]),

          const SizedBox(height: 12),

          // Event attendance
          _Section(title: 'Event Attendance', children: [
            _InfoRow(label: 'Onsite', value: _capitalize(onsite)),
            if (selectedDays.isNotEmpty)
              _InfoRow(
                label: 'Days',
                value: selectedDays.map(_capitalize).join(', '),
              ),
          ]),

          // Sessions per day
          if (sessions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(
              title: 'Sessions',
              children: sessions.entries.map((e) {
                final dayName = _capitalize(e.key);
                final sess = (e.value as List?)?.cast<String>() ?? [];
                if (sess.isEmpty) return const SizedBox.shrink();
                return _InfoRow(label: dayName, value: sess.map(_capitalize).join(', '));
              }).toList(),
            ),
          ],

          // Feedback
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(title: 'Feedback', children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(feedback, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
              ),
            ]),
          ],

          const SizedBox(height: 12),

          // Registration ID
          _Section(title: 'Registration', children: [
            _InfoRow(label: 'ID', value: regId, copyable: true),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final visible = children.where((w) => w is! SizedBox || (w as SizedBox).height != 0).toList();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 0.5)),
            const Divider(height: 16),
            ...visible,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  const _InfoRow({required this.label, required this.value, this.copyable = false});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: copyable
                  ? () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              child: Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: copyable ? TextDecoration.underline : null,
                  decorationColor: Colors.grey.shade400,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
