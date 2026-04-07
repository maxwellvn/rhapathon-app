import 'package:flutter/material.dart';

/// Dark strip with search field under the app bar.
class AttendeeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  const AttendeeSearchBar({
    super.key,
    required this.controller,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: controller,
        onChanged: onQueryChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name, email, phone, KingsChat...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.6)),
                  onPressed: () {
                    controller.clear();
                    onQueryChanged('');
                  },
                )
              : null,
          fillColor: Colors.white.withValues(alpha: 0.1),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
        ),
      ),
    );
  }
}
