import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Opens a searchable chooser over a list that arrives from the network.
///
/// [load] is called with the current search text — empty means the whole list,
/// which is what the endpoint answers when `q` is left out. [label] is the row
/// text, since what a list holds differs by feature.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required String Function(T option) label,
  required Future<List<T>> Function(String locale, String? query) load,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) =>
      _OptionSheet<T>(title: title, label: label, load: load),
);

class _OptionSheet<T> extends StatefulWidget {
  const _OptionSheet({
    required this.title,
    required this.label,
    required this.load,
  });

  final String title;
  final String Function(T option) label;
  final Future<List<T>> Function(String locale, String? query) load;

  @override
  State<_OptionSheet<T>> createState() => _OptionSheetState<T>();
}

class _OptionSheetState<T> extends State<_OptionSheet<T>> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<T>? _options;
  bool _isLoading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // The language the list is asked for lives in an inherited widget, which a
    // state object cannot read before its first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _query('');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// The list endpoint searches by name, so a keystroke is a new request; the
  /// short wait keeps a typed phrase from firing one per letter.
  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query(_search.text);
    });
  }

  Future<void> _query(String text) async {
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _isLoading = true;
      _failed = false;
    });

    List<T>? options;
    try {
      options = await widget.load(locale, text.trim());
    } catch (_) {
      options = null;
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _failed = options == null;
      _options = options ?? _options;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('option-search'),
              controller: _search,
              autofocus: true,
              onChanged: (_) => _onTextChanged(),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(child: _body(l10n, theme)),
          ],
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, ThemeData theme) {
    Widget message(String text) => Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
    );

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // A list that failed to load keeps whatever was last on screen, so an error
    // is reported instead of showing the empty state the search never returned.
    if (_failed) return message(l10n.placesError);

    final options = _options;
    if (options == null || options.isEmpty) return message(l10n.searchEmpty);

    return ListView(
      shrinkWrap: true,
      children: [
        for (final option in options)
          ListTile(
            title: Text(widget.label(option)),
            onTap: () => Navigator.of(context).pop<T>(option),
          ),
      ],
    );
  }
}
