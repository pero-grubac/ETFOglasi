const String _baseApiUrl = 'https://efee.etf.unibl.org:8443/api/public/';
const String _announcements = 'oglasne-ploce/';
const String _announcementsDownload = 'oglasi/';
const String _download = '/download';
String getAnnouncementsUrl(String id) {
  return _baseApiUrl + _announcements + id;
}

String getAnnouncementDownload(String id) {
  return _baseApiUrl  +_announcementsDownload + id + _download;
}
