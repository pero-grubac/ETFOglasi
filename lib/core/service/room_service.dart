import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/service/api_service.dart';

class RoomService {
  final ApiService service;

  RoomService({required this.service});

  Future<List<Room>> fetchRooms() async {
    return await service.fetchData<List<Room>>(
      url: getRoomUrl(),
      fromJson: (json) {
        final List<dynamic> data = json;
        return data.map((item) => Room.fromJson(item)).toList();
      },
    );
  }
}
