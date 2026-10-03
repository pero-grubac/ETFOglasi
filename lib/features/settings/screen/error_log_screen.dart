import 'dart:io';

import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/gen/app_localizations.dart';

class ErrorLogScreen extends ConsumerStatefulWidget {
  static const id = 'error_log_screen';
  const ErrorLogScreen({super.key});

  @override
  ConsumerState<ErrorLogScreen> createState() => _ErrorLogScreenState();
}

class _ErrorLogScreenState extends ConsumerState<ErrorLogScreen> {
  late Future<List<ErrorLogEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = ref.read(errorLogProvider).read();
  }

  /// The log as plain text, with the app and Android version on top.
  Future<String> _reportText(List<ErrorLogEntry> entries) async {
    String version;
    try {
      version = await ref.read(appVersionProvider.future);
    } catch (_) {
      version = '?';
    }
    return [
      'ETF Oglasi $version',
      Platform.operatingSystemVersion,
      '',
      for (final entry in entries.reversed) '$entry\n',
    ].join('\n');
  }

  Future<void> _copy(List<ErrorLogEntry> entries) async {
    final locale = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: await _reportText(entries)));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(locale.errorLogCopied)));
  }

  Future<void> _share(List<ErrorLogEntry> entries) async {
    await SharePlus.instance.share(
      ShareParams(text: await _reportText(entries), subject: 'ETF Oglasi log'),
    );
  }

  Future<void> _clear() async {
    await ref.read(errorLogProvider).clear();
    if (!mounted) return;
    setState(() => _entries = Future.value([]));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<ErrorLogEntry>>(
      future: _entries,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <ErrorLogEntry>[];
        final hasEntries = entries.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(locale.errorLog),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: locale.copy,
                onPressed: hasEntries ? () => _copy(entries) : null,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: locale.share,
                onPressed: hasEntries ? () => _share(entries) : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: locale.clear,
                onPressed: hasEntries ? _clear : null,
              ),
            ],
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      locale.errorLogDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (!hasEntries)
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Center(child: Text(locale.errorLogEmpty)),
                      ),
                    // Newest first.
                    for (final entry in entries.reversed)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            entry.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
