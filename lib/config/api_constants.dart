const String _baseApiUrl = 'https://efee.etf.unibl.org:8443/api/public/';
const String _announcements = 'oglasne-ploce/';
const String _announcementsDownload = 'oglasi/';
const String _download = '/download';
const String _schedule = 'raspored/';
const String _studyProgram = 'studijski-program/';
const String _year = '/godina/';
String getAnnouncementsUrl(String id) {
  return _baseApiUrl + _announcements + id;
}

String getAnnouncementDownloadUrl(String id) {
  return _baseApiUrl + _announcementsDownload + id + _download;
}

String getScheduleUrl(String studyProgramId, String yearId) {
  return _baseApiUrl +
      _schedule +
      _studyProgram +
      studyProgramId +
      _year +
      yearId;
}
