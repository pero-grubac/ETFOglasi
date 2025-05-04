import 'package:etf_oglasi/features/announcements/data/model/announcement.dart';
import 'package:etf_oglasi/features/announcements/data/service/announcement_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:etf_oglasi/features/announcements/constants/strings.dart';

class AttachmentWidget extends StatefulWidget {
  final Announcement announcement;

  const AttachmentWidget({super.key, required this.announcement});

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  bool _isDownloading = false;

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleDownload() async {
    final confirmed = await _confirmDownload();
    if (!confirmed || !mounted) return;

    try {
      if (await Permission.storage.request().isGranted) {
        setState(() {
          _isDownloading = true;
        });
        try {
          String? selectedDirectory =
              await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Izaberite lokaciju za preuzimanje',
          );
          if (!mounted) return;

          if (selectedDirectory == null) {
            _showSnackBar('Preuzimanje otkazano');
            return;
          }

          final prilog = widget.announcement.oglasPrilozi.first;
          final filePath = '$selectedDirectory/${prilog.originalniNaziv}';

          final announcementService = AnnouncementService();
          await announcementService.download(
            widget.announcement.id.toString(),
            customPath: filePath,
          );

          _showSnackBar('File downloaded successfully');
        } catch (e) {
          _showSnackBar('Failed to download file: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isDownloading = false;
            });
          }
        }
      } else {
        _showSnackBar('Permisija odbijena');
      }
    } catch (e) {
      _showSnackBar('Greska: $e');
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
    return InkWell(
      onTap: _isDownloading ? null : _handleDownload,
      child: Row(
        children: [
          _isDownloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.attach_file,
                  size: 16, color: theme.colorScheme.onSurface),
          const SizedBox(width: 4),
          Text(
            AnnouncementStrings.attachment,
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
