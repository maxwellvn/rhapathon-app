import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const DetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
  });

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
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
