import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/ui/widget/future_dropdown.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/core/util/format_date.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_result.dart';
import 'package:etf_oglasi/features/schedule/widget/schedule_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

/// Picks a room for the hall occupancy schedule.
///
/// Pops with the room id; "Select" also returns the chosen week.
class RoomScheduleSettingsWidget extends ConsumerStatefulWidget {
  const RoomScheduleSettingsWidget({super.key, this.isSelect = true});

  final bool isSelect;

  @override
  ConsumerState<RoomScheduleSettingsWidget> createState() =>
      _RoomScheduleSettingsWidgetState();
}

class _RoomScheduleSettingsWidgetState
    extends ConsumerState<RoomScheduleSettingsWidget> {
  late final Future<List<Room>> _rooms;
  String? _selectedRoomId;
  DateTime _selectedWeek = defaultScheduleWeek(DateTime.now());

  @override
  void initState() {
    super.initState();
    _rooms = ref.read(scheduleOptionsServiceProvider).fetchRooms();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeek,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedWeek = getMondayOfWeek(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final roomId = _selectedRoomId;

    return ScheduleSettingsDialog(
      showSelect: widget.isSelect,
      onSelect: roomId != null
          ? () => Navigator.pop(
              context,
              ScheduleResult(url: roomId, isSave: false, week: _selectedWeek),
            )
          : null,
      onSave: roomId != null
          ? () => Navigator.pop(
              context,
              ScheduleResult(url: roomId, isSave: true),
            )
          : null,
      children: [
        FutureDropdown<Room>(
          future: _rooms,
          hint: locale.room,
          value: _selectedRoomId,
          valueOf: (room) => room.id.toString(),
          labelOf: (room) => room.naziv,
          onChanged: (value) => setState(() => _selectedRoomId = value),
        ),
        if (widget.isSelect) ...[
          Text(
            locale.date,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDate(_selectedWeek),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: _selectDate,
                child: Text(locale.selectDate),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
