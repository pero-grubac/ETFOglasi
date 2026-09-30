import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';

/// A dropdown whose items come from [future]. A `null` future shows a
/// disabled dropdown (e.g. while a parent selection is missing).
class FutureDropdown<T> extends StatelessWidget {
  const FutureDropdown({
    super.key,
    required this.future,
    required this.hint,
    required this.value,
    required this.valueOf,
    required this.labelOf,
    required this.onChanged,
  });

  final Future<List<T>>? future;
  final String hint;
  final String? value;
  final String Function(T item) valueOf;
  final String Function(T item) labelOf;
  final ValueChanged<String?> onChanged;

  Widget _dropdown(BuildContext context, List<T> items) {
    final colorScheme = Theme.of(context).colorScheme;
    final values = items.map(valueOf).toSet();
    return DropdownButton<String>(
      hint: Text(hint),
      value: values.contains(value) ? value : null,
      isExpanded: true,
      dropdownColor: colorScheme.primaryContainer,
      style: TextStyle(color: colorScheme.onSurface),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(
            value: valueOf(item),
            child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: items.isEmpty ? null : onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = this.future;
    if (future == null) return _dropdown(context, const []);

    final locale = AppLocalizations.of(context);
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: LinearProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text(
            '$hint: ${locale.loadingError}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) return Text('$hint: ${locale.noData}');
        return _dropdown(context, items);
      },
    );
  }
}
