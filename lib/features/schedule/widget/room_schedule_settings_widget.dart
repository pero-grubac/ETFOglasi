import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/service/room_service.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/util/format_date.dart';

class RoomScheduleSettingsWidget extends ConsumerStatefulWidget {
  const RoomScheduleSettingsWidget({
    super.key,
    this.isSelect = true,
    this.shouldDatePick = true,
  });
  final bool isSelect;
  final bool shouldDatePick;
  static const String roomScheduleId = "roomScheduleId";
  @override
  ConsumerState<RoomScheduleSettingsWidget> createState() =>
      _RoomScheduleSettingsWidgetState();
}

class _RoomScheduleSettingsWidgetState
    extends ConsumerState<RoomScheduleSettingsWidget> {
  late RoomService _roomService;
  late Future<List<Room>> _rooms;
  bool _isLoading = true;
  String? _selectedRoomId;
  String? _generatedUrl;
  String? _errorMessage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _roomService = ref.read(roomServiceProvider);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final roomsFuture = _roomService.fetchRooms();
      setState(() {
        _rooms = roomsFuture;
        _selectedDate = getMondayOfWeek(DateTime.now());
        _generatedUrl = _selectedRoomId != null
            ? getRoomScheduleUrl(
                _selectedRoomId!,
                formatDate(_selectedDate!),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = getMondayOfWeek(picked);
        _generatedUrl = _selectedRoomId != null
            ? getRoomScheduleUrl(
                _selectedRoomId!,
                formatDate(_selectedDate!),
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
                                  if (widget.isSelect) {
                                    if (_selectedDate != null &&
                                        value != null) {
                                      _generatedUrl = getRoomScheduleUrl(
                                        value,
                                        formatDate(_selectedDate!),
                                      );
                                    }
                                  } else {
                                    _generatedUrl = _selectedRoomId;
                                  }
                                });
                              },
                            ),
                            if (widget.isSelect) ...[
                              const SizedBox(height: 16),
                              Text(
                                locale.date,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedDate != null
                                          ? formatDate(_selectedDate!)
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
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(locale.cancel),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (widget.isSelect) ...[
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: _generatedUrl != null
                                          ? () => Navigator.pop(
                                                context,
                                                ScheduleResult(
                                                  url: _generatedUrl!,
                                                  isSave: false,
                                                ),
                                              )
                                          : null,
                                      child: Text(locale.select),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 16),
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: _selectedRoomId != null
                                        ? () => Navigator.pop(
                                              context,
                                              ScheduleResult(
                                                url: _selectedRoomId!,
                                                isSave: true,
                                              ),
                                            )
                                        : null,
                                    child: Text(locale.save),
                                  ),
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
