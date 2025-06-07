import 'dart:io';

import 'package:etf_oglasi/core/model/api/announcement.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/gen/app_localizations.dart';

class AttachmentWidget extends ConsumerStatefulWidget {
  final Announcement announcement;

  const AttachmentWidget({super.key, required this.announcement});

  @override
  ConsumerState<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends ConsumerState<AttachmentWidget> {
  bool _isDownloading = false;
  late AnnouncementService _announcementService;
  @override
  void initState() {
    super.initState();
    _announcementService = ref.read(announcementServiceProvider);
  }

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
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  Future<bool> _checkStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<void> _handleDownload() async {
    final confirmed = await _confirmDownload();
    if (!confirmed || !mounted) return;

    try {
      setState(() {
        _isDownloading = true;
      });
      try {
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Izaberite lokaciju za preuzimanje',
        );
        if (!mounted) return;

        if (selectedDirectory == null) {
          _showSnackBar('Preuzimanje otkazano');
          return;
        }

        final segments = selectedDirectory
            .split('/')
            .where((segment) => segment.isNotEmpty)
            .toList();
        final uniqueSegments = <String>[];
        final seen = <String>{};
        for (var segment in segments) {
          if (seen.add(segment)) {
            uniqueSegments.add(segment);
          }
        }
        selectedDirectory = '/${uniqueSegments.join('/')}';

        final directory = Directory(selectedDirectory);
        if (!await directory.exists()) {
          _showSnackBar('Direktorijum ne postoji');
          return;
        }

        final prilog = widget.announcement.oglasPrilozi.first;

        final downloadPath = await _announcementService.download(
            widget.announcement.id.toString(),
            selectedDirectory,
            prilog.originalniNaziv);

        _showSnackBar(
          'File downloaded successfully',
          actionLabel: 'Open',
          onActionPressed: () async {
            try {
              if (!await _checkStoragePermission()) {
                _showSnackBar('Dozvola za otvaranje fajlova nije odobrena.');
                return;
              }
              final result = await OpenFilex.open(downloadPath);
              if (result.type != ResultType.done) {
                _showSnackBar('Failed to open file');
              }
            } catch (e) {
              _showSnackBar('Error opening file');
            }
          },
        );
      } catch (e) {
        print('error $e');
        _showSnackBar('Failed to download file: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Greška: $e');
    }
  }

  Future<bool> _confirmDownload() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Preuzimanje fajla'),
            content: const Text('Da li želite da preuzmete ovaj fajl?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Otkaži'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Preuzmi'),
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
                    color: theme.colorScheme.onSurface,
                  ),
                )
              : Icon(
                  Icons.attach_file,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
          const SizedBox(width: 4),
          Text(
            locale!.attachment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
