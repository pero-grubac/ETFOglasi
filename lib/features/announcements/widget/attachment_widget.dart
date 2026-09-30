import 'dart:io';

import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/gen/app_localizations.dart';

class AttachmentWidget extends ConsumerStatefulWidget {
  final Announcement announcement;
  final Color color;

  const AttachmentWidget({
    super.key,
    required this.announcement,
    required this.color,
  });

  @override
  ConsumerState<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends ConsumerState<AttachmentWidget> {
  bool _isDownloading = false;

  // The API has a single download endpoint per announcement, so the first
  // attachment's name is used for the file.
  OglasPrilog get _attachment => widget.announcement.oglasPrilozi.first;

  void _showSnackBar(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
            : null,
      ),
    );
  }

  Future<void> _handleDownload() async {
    final locale = AppLocalizations.of(context);
    final confirmed = await _confirmDownload(locale);
    if (!confirmed || !mounted) return;

    setState(() => _isDownloading = true);
    try {
      final bytes = await ref
          .read(announcementServiceProvider)
          .downloadAttachment(widget.announcement.id.toString());
      // Never trust a server-provided name as a path.
      final fileName = path.basename(_attachment.originalniNaziv);

      // Keep a private copy that can always be opened, regardless of where
      // the user saves the file (scoped storage).
      final tempDir = await getTemporaryDirectory();
      final openablePath = path.join(tempDir.path, fileName);
      await File(openablePath).writeAsBytes(bytes);

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: locale.chooseDownloadLocation,
        fileName: fileName,
        bytes: bytes,
      );
      if (savedPath == null) {
        _showSnackBar(locale.downloadCancelled);
        return;
      }

      _showSnackBar(
        locale.downloadSuccess,
        actionLabel: locale.open,
        onActionPressed: () => _openFile(openablePath, locale),
      );
    } catch (e) {
      debugPrint('Attachment download failed: $e');
      _showSnackBar(locale.downloadFailed);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _openFile(String filePath, AppLocalizations locale) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        _showSnackBar(locale.openFileFailed);
      }
    } catch (_) {
      _showSnackBar(locale.openFileFailed);
    }
  }

  Future<bool> _confirmDownload(AppLocalizations locale) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(locale.downloadFileTitle),
            content: Text(
              locale.downloadFileQuestion(
                fileName: _attachment.originalniNaziv,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(locale.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(locale.download),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    return InkWell(
      onTap: _isDownloading ? null : _handleDownload,
      child: Row(
        children: [
          _isDownloading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.color,
                  ),
                )
              : Icon(Icons.attach_file, size: 16, color: widget.color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${locale.attachment}: ${_attachment.originalniNaziv}',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.color,
                decoration: TextDecoration.underline,
                decorationColor: widget.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
