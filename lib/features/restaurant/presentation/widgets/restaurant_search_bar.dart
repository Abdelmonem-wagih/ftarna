import 'package:flutter/material.dart';

class RestaurantSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialQuery;

  const RestaurantSearchBar({
    super.key,
    required this.onSearch,
    this.initialQuery,
  });

  @override
  State<RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<RestaurantSearchBar> {
  late final TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _showClear = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search restaurants, cuisines...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _showClear
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSearch,
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_controller.text == value) {
              widget.onSearch(value);
            }
          });
        },
      ),
    );
  }
}
