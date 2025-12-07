// route_error_screen.dart
import 'package:flutter/material.dart';

class RouteErrorScreen extends StatelessWidget {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const RouteErrorScreen({
    super.key,
    this.message = 'Something went wrong',
    this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Oops')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: theme.titleLarge),
            const SizedBox(height: 12),

            if (error != null) ...[
              Text('Error:', style: theme.titleMedium),
              const SizedBox(height: 4),
              SelectableText(
                error.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 12),
            ],

            if (stackTrace != null) ...[
              Text('Stack trace:', style: theme.titleMedium),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    stackTrace.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ] else
              const Spacer(),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Go back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}