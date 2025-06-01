import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/major.dart';
import 'package:etf_oglasi/core/service/api_service.dart';

class MajorService {
  final ApiService service;

  MajorService({required this.service});

  Future<List<Major>> fetchMajors(String studyProgramId) async {
    return await service.fetchData<List<Major>>(
      url: getMajorsUrl(studyProgramId),
      fromJson: (json) {
        final List<dynamic> data = json;
        return data.map((item) => Major.fromJson(item)).toList();
      },
    );
  }
}
