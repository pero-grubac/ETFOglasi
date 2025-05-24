import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/service/api/room_service.dart';
import 'package:etf_oglasi/core/util/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../config/api_constants.dart';

class RoomScheduleSettingsWidget extends StatefulWidget {
  const RoomScheduleSettingsWidget({super.key});

  @override
  State<RoomScheduleSettingsWidget> createState() =>
      _RoomScheduleSettingsWidgetState();
}

class _RoomScheduleSettingsWidgetState
    extends State<RoomScheduleSettingsWidget> {
  final RoomService _roomService = getIt<RoomService>();
  late Future<List<Room>> _rooms;
  bool _isLoading = true;
  String? _selectedRoomId;
  String? _generatedUrl;
  String? _errorMessage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final roomsFuture = _roomService.fetchRooms();
      setState(() {
        _rooms = roomsFuture;
        _selectedDate = _getMondayOfWeek(DateTime.now());
        _generatedUrl = _selectedRoomId != null
            ? getRoomScheduleUrl(
                _selectedRoomId!,
                _formatDate(_selectedDate!),
              )
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _rooms = Future.value([]);
        _isLoading = false;
      });
    }
  }

  List<DropdownMenuItem<String>> _buildRoomItems(List<Room> rooms) {
    return rooms.map((room) {
      return DropdownMenuItem<String>(
        value: room.id.toString(),
        child: Text(room.naziv),
      );
    }).toList();
  }

  Widget _buildDropdown<T>(
    Future<List<T>> future,
    String hint,
    String? value,
    List<DropdownMenuItem<String>> Function(List<T>) itemBuilder,
    void Function(String?) onChanged,
  ) {
    final locale = AppLocalizations.of(context);

    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Text(locale!.noData);
        }
        final items = itemBuilder(snapshot.data!);
        return DropdownButton<String>(
          hint: Text(hint),
          value: value,
          isExpanded: true,
          dropdownColor: colorScheme.primaryContainer,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
          focusColor: colorScheme.primaryContainer,
          items: items.isNotEmpty
              ? items
              : [DropdownMenuItem(child: Text(locale!.noData))],
          onChanged: onChanged,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  DateTime _getMondayOfWeek(DateTime date) {
    final int dayOfWeek = date.weekday;
    final int daysToSubtract = dayOfWeek - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = _getMondayOfWeek(picked);
        _generatedUrl = _selectedRoomId != null
            ? getRoomScheduleUrl(
                _selectedRoomId!,
                _formatDate(_selectedDate!),
              )
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Card(
        elevation: 8.0,
        color: colorScheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      minWidth: 280,
                    ),
                    child: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale!.selectSchedule,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _buildDropdown<Room>(
                              _rooms,
                              locale.room,
                              _selectedRoomId,
                              _buildRoomItems,
                              (value) {
                                setDialogState(() {
                                  _selectedRoomId = value;
                                  if (_selectedDate != null && value != null) {
                                    _generatedUrl = getRoomScheduleUrl(
                                      value,
                                      _formatDate(_selectedDate!),
                                    );
                                  } else {
                                    _generatedUrl = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              locale.date,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? _formatDate(_selectedDate!)
                                        : locale.selectDate,
                                    style: TextStyle(
                                      color: _selectedDate != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text(locale.selectDate),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(locale.save),
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(locale.cancel),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _generatedUrl != null
                                      ? () =>
                                          Navigator.pop(context, _generatedUrl)
                                      : null,
                                  child: Text(locale.select),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
