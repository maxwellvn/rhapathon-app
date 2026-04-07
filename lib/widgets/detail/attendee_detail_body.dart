import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'detail_formatting.dart';
import 'detail_info_row.dart';
import 'detail_section_card.dart';
import 'outreach_card.dart';

class AttendeeDetailBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool outreachSaving;
  final bool contacted;
  final String? outcomeValue;
  final TextEditingController notesController;
  final FocusNode notesFocusNode;
  final ValueChanged<bool> onContactedChanged;
  final ValueChanged<String?> onOutcomeChanged;
  final VoidCallback onSave;

  const AttendeeDetailBody({
    super.key,
    required this.data,
    required this.outreachSaving,
    required this.contacted,
    required this.outcomeValue,
    required this.notesController,
    required this.notesFocusNode,
    required this.onContactedChanged,
    required this.onOutcomeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final d = data;
    final title = d['title'] as String? ?? '';
    final firstName = d['first_name'] as String? ?? '';
    final lastName = d['last_name'] as String? ?? '';
    final fullName = '$title $firstName $lastName'.trim();

    final email = d['email'] as String? ?? '';
    final phone = d['phone'] as String? ?? '';
    final kcUser = d['kingschat_username'] as String? ?? '';
    final zone = d['zone_name'] as String? ?? '';
    final network = d['network_name'] as String? ?? '';
    final church = d['church_name'] as String? ?? '';
    final group = d['group_name'] as String? ?? '';
    final affType = d['affiliation_type'] as String? ?? '';
    final lang = d['language_preference'] as String? ?? '';
    final onsite = d['onsite_participation'] as String? ?? '';
    final createdAt = d['created_at'] as String? ?? '';
    final feedback = d['feedback'] as String? ?? '';
    final regId = d['id'] as String? ?? '';

    final selectedDays = (d['selected_days'] as List?)?.cast<String>() ?? [];
    final sessions = d['sessions'] as Map<String, dynamic>? ?? {};

    final bottomInset = MediaQuery.of(context).padding.bottom;
    const cap = capitalizeAttendeeLabel;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          if (kcUser.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              kcUser,
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
            DetailSectionCard(
              title: 'Contact Information',
              children: [
                DetailInfoRow(label: 'Email', value: email, copyable: true),
                DetailInfoRow(label: 'Phone', value: phone, copyable: true),
                DetailInfoRow(label: 'KingsChat', value: kcUser),
                DetailInfoRow(label: 'Language', value: lang.toUpperCase()),
              ],
            ),
            const SizedBox(height: 12),
            OutreachCard(
              saving: outreachSaving,
              contacted: contacted,
              outcomeValue: outcomeValue,
              notesController: notesController,
              notesFocusNode: notesFocusNode,
              onContactedChanged: onContactedChanged,
              onOutcomeChanged: onOutcomeChanged,
              onSave: onSave,
            ),
            const SizedBox(height: 12),
            DetailSectionCard(
              title: 'Church / Affiliation',
              children: [
                DetailInfoRow(label: 'Type', value: cap(affType)),
                DetailInfoRow(label: 'Zone', value: zone),
                DetailInfoRow(label: 'Network', value: network),
                DetailInfoRow(label: 'Church', value: church),
                DetailInfoRow(label: 'Group', value: group),
              ],
            ),
            const SizedBox(height: 12),
            DetailSectionCard(
              title: 'Event Attendance',
              children: [
                DetailInfoRow(label: 'Onsite', value: cap(onsite)),
                if (selectedDays.isNotEmpty)
                  DetailInfoRow(
                    label: 'Days',
                    value: selectedDays.map(cap).join(', '),
                  ),
              ],
            ),
            if (sessions.isNotEmpty) ...[
              const SizedBox(height: 12),
              DetailSectionCard(
                title: 'Sessions',
                children: sessions.entries.map((e) {
                  final dayName = cap(e.key);
                  final sess = (e.value as List?)?.cast<String>() ?? [];
                  if (sess.isEmpty) return const SizedBox.shrink();
                  return DetailInfoRow(label: dayName, value: sess.map(cap).join(', '));
                }).toList(),
              ),
            ],
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              DetailSectionCard(
                title: 'Registration feedback',
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(feedback, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            DetailSectionCard(
              title: 'Registration',
              children: [
                DetailInfoRow(label: 'ID', value: regId, copyable: true),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
