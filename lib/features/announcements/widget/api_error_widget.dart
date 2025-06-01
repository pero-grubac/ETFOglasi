import 'package:flutter/material.dart';

class ApiErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ApiErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Greška prilikom učitavanja podataka',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Pokušaj ponovo'),
          ),
        ],
      ),
    );
  }
}
