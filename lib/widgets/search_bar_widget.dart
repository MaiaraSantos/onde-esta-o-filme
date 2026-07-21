import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final String initialValue;

  const SearchBarWidget({
    super.key,
    this.initialValue = '',
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    ref.read(searchQueryProvider.notifier).state = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: (_) => _triggerSearch(),
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Pesquise por filmes ou séries...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textColorSecondary),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textColorSecondary),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                    _triggerSearch();
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                  ),
                  onPressed: _triggerSearch,
                  child: const Text('Buscar'),
                ),
              ),
            ],
          ),
        ),
        onChanged: (val) {
          // Permite habilitar/desabilitar o botão limpar em tempo real
          setState(() {});
        },
      ),
    );
  }
}
