const String _baseApiUrl = 'https://efee.etf.unibl.org:8443/api/public/';
const String _announcements = 'oglasne-ploce/';
const String _announcementsDownload = 'oglasi/';
const String _download = '/download';
const String _schedule = 'raspored/';
const String _studyProgram = 'studijski-program/';
const String _year = '/godina/';
const String _rooms = 'prostorije';
const String _teachers = 'nastavnici';
const String _studyProgramCode = 'octt-epg';
const String _yearCode = '/epg/';
const String _scheduleByRoom = 'po-prostoriji/';
const String _scheduleByTeacher = 'po-nastavniku/';
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

String getRoomUrl() {
  return _baseApiUrl + _rooms;
}

String getTeachersUrl() {
  return _baseApiUrl + _teachers;
}

String getStudyProgramsUrl() {
  return _baseApiUrl + _studyProgramCode;
}

String getMajorsUrl(String studyProgramId) {
  return _baseApiUrl + _studyProgramCode + _yearCode + studyProgramId;
}

String getScheduleByRoomUrl(String roomId) {
  return _baseApiUrl + _schedule + _scheduleByRoom + roomId;
}

String getScheduleByTeacherUrl(String teacherId) {
  return _baseApiUrl + _schedule + _scheduleByTeacher + teacherId;
}
