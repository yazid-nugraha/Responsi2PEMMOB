import 'package:flutter/material.dart';

class LocationSearchField extends StatelessWidget {
  const LocationSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.hasText = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Cari nama kota (mis. Purwokerto, Jakarta)...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasText
            ? IconButton(
                onPressed: onClear,
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
    );
  }
}
