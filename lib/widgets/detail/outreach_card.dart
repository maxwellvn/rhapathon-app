import 'package:flutter/material.dart';

import '../../services/contact_log_store.dart';

class OutreachCard extends StatelessWidget {
  final bool saving;
  final bool contacted;
  final String? outcomeValue;
  final TextEditingController notesController;
  final FocusNode notesFocusNode;
  final ValueChanged<bool> onContactedChanged;
  final ValueChanged<String?> onOutcomeChanged;
  final VoidCallback onSave;

  const OutreachCard({
    super.key,
    required this.saving,
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
    const navy = Color(0xFF1A1A2E);
    const gold = Color(0xFFD4AF37);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: navy.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_callback_outlined, size: 20, color: navy.withValues(alpha: 0.85)),
                    const SizedBox(width: 8),
                    const Text(
                      'Outreach',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: navy,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  title: const Text('Marked as contacted', style: TextStyle(fontSize: 14)),
                  value: contacted,
                  activeThumbColor: navy,
                  activeTrackColor: gold,
                  onChanged: saving ? null : onContactedChanged,
                ),
                if (contacted) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Contact outcome',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    alignment: Alignment.centerLeft,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: outcomeValue,
                        isExpanded: true,
                        isDense: true,
                        borderRadius: BorderRadius.circular(8),
                        hint: Text('Select outcome…', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        style: const TextStyle(fontSize: 13, color: navy, fontWeight: FontWeight.w500),
                        icon: Icon(Icons.expand_more, size: 20, color: Colors.grey.shade700),
                        items: ContactOutcomes.labels.entries
                            .map(
                              (e) => DropdownMenuItem<String?>(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(fontSize: 13)),
                              ),
                            )
                            .toList(),
                        onChanged: saving ? null : onOutcomeChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    focusNode: notesFocusNode,
                    enabled: !saving,
                    minLines: 2,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: notesFocusNode.unfocus,
                    onSubmitted: (_) => notesFocusNode.unfocus(),
                    style: const TextStyle(fontSize: 13, height: 1.4),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Notes (optional)',
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: saving ? null : onSave,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A2E)),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save_outlined, size: 18),
                              SizedBox(width: 6),
                              Text('Save'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (saving)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.45)),
              ),
            ),
        ],
      ),
    );
  }
}
