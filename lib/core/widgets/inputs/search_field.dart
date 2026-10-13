import 'dart:async';

import 'package:flutter/material.dart';
import 'package:buzzer_app/core/constants/app_durations.dart';

/// Search input with debounced query callback and clear button.
class SearchField extends StatefulWidget {
  const SearchField({
    required this.onSearch,
    super.key,
    this.hintText = 'Search...',
    this.debounceDuration = AppDurations.searchDebounce,
    this.controller,
  });

  final ValueChanged<String> onSearch;
  final String hintText;
  final Duration debounceDuration;
  final TextEditingController? controller;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClear) {
      setState(() => _showClear = hasText);
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch(_controller.text.trim());
    });
  }

  void _clearSearch() {
    _controller.clear();
    _debounceTimer?.cancel();
    widget.onSearch('');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _showClear
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: _clearSearch,
              )
            : null,
      ),
    );
  }
}
