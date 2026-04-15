import 'package:flutter/material.dart';

import '../../services/contact_log_store.dart';

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ContactRecord? contact;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.item,
    required this.onTap,
    this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final title = item['title'] as String? ?? '';
    final firstName = item['first_name'] as String? ?? '';
    final lastName = item['last_name'] as String? ?? '';
    final fullName = '$title $firstName $lastName'.trim();
    final email = item['email'] as String? ?? '';
    final phone = item['phone'] as String? ?? '';
    final kcUser = item['kingschat_username'] as String? ?? '';
    final zone = item['zone_name'] as String? ?? '';
    final church = item['church_name'] as String? ?? '';
    final lang = item['language_preference'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1A1A2E),
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (contact != null && contact!.hasReachedOut) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ContactOutcomes.labelFor(contact!.outcome) ??
                                  (contact!.notes.trim().isNotEmpty ? 'Notes saved' : 'Reached out'),
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    if (email.isNotEmpty)
                      Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    if (phone.isNotEmpty)
                      Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    if (kcUser.isNotEmpty)
                      Text(
                        kcUser,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (zone.isNotEmpty || church.isNotEmpty)
                      Text(
                        [zone, church].where((s) => s.isNotEmpty).join(' · '),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lang.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lang.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
