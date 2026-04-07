import 'package:flutter/material.dart';

class DetailSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DetailSectionCard({super.key, required this.title, required this.children});

  static bool _includeChild(Widget w) {
    if (w is! SizedBox) return true;
    final h = w.height;
    return h == null || h != 0;
  }

  @override
  Widget build(BuildContext context) {
    final visible = children.where(_includeChild).toList();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.5,
              ),
            ),
            const Divider(height: 16),
            ...visible,
          ],
        ),
      ),
    );
  }
}
