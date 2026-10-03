// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get schedule => 'Schedule';

  @override
  String get choseLanguage => 'Choose a language';

  @override
  String get language => 'Language';

  @override
  String get appTitle => 'ETF';

  @override
  String get firstYear => 'First year';

  @override
  String get secondYear => 'Second year';

  @override
  String get thirdYear => 'Third year';

  @override
  String get fourthYear => 'Fourth year';

  @override
  String get secondCycle => 'Second cycle';

  @override
  String get thirdCycle => 'Third cycle';

  @override
  String get postgraduateStudy => 'Postgraduate studies';

  @override
  String get finalThesis => 'Final thesis defences';

  @override
  String get classSchedule => 'Class schedule';

  @override
  String get hallSchedule => 'Room schedule';

  @override
  String get refresh => 'Refresh';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get noSchedule => 'No schedule';

  @override
  String get noData => 'No data';

  @override
  String get selectSchedule => 'Choose a schedule';

  @override
  String get teacher => 'Teachers';

  @override
  String get room => 'Rooms';

  @override
  String get studyProgram => 'Study programme';

  @override
  String get year => 'Year';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get select => 'Select';

  @override
  String get noNotifications => 'No announcements';

  @override
  String get selectDate => 'Choose a date';

  @override
  String get date => 'Date';

  @override
  String get attachment => 'Attachment';

  @override
  String get signature => 'Signed';

  @override
  String get theme => 'Theme';

  @override
  String minDurationError({required Object minutes}) {
    return 'The minimum interval is $minutes minutes';
  }

  @override
  String minDurationSet({required Object minutes}) {
    return 'Interval set to $minutes minutes, the minimum';
  }

  @override
  String get notAllowedNotification => 'Notifications are not allowed.';

  @override
  String get error => 'Error';

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get loadingError => 'Could not load the data';

  @override
  String get tryAgain => 'Try again';

  @override
  String get offlineData => 'No connection – showing saved data';

  @override
  String get refreshFailed => 'Refresh failed';

  @override
  String get noScheduleSelected => 'No schedule chosen';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String createdAt({required String date}) {
    return 'Posted: $date';
  }

  @override
  String expiresAt({required String date}) {
    return 'Expires: $date';
  }

  @override
  String get chooseDownloadLocation => 'Choose where to save the file';

  @override
  String get downloadCancelled => 'Download cancelled';

  @override
  String get downloadSuccess => 'File downloaded';

  @override
  String get downloadFailed => 'Could not download the file';

  @override
  String get open => 'Open';

  @override
  String get openFileFailed => 'Could not open the file';

  @override
  String get downloadFileTitle => 'Download file';

  @override
  String downloadFileQuestion({required String fileName}) {
    return 'Do you want to download “$fileName”?';
  }

  @override
  String get download => 'Download';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get openSettings => 'Settings';

  @override
  String get daysShort => 'd';

  @override
  String get hoursShort => 'h';

  @override
  String get minutesShort => 'min';

  @override
  String get notificationChannelName => 'Announcements';

  @override
  String get notificationChannelDescription =>
      'Notifications about new announcements';

  @override
  String newAnnouncementsTitle({required String board, required int count}) {
    return '$board: new announcements ($count)';
  }

  @override
  String get search => 'Search';

  @override
  String get noSearchResults => 'No results';

  @override
  String get newBadge => 'New';

  @override
  String get share => 'Share';

  @override
  String get copyText => 'Copy text';

  @override
  String get copied => 'Text copied';

  @override
  String get moreOptions => 'More options';

  @override
  String unseenAnnouncements({required int count}) {
    return 'Unread announcements: $count';
  }

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get about => 'About';

  @override
  String appVersion({required String version}) {
    return 'Version $version';
  }

  @override
  String get checkForUpdates => 'Check for new versions';

  @override
  String get checkForUpdatesDescription => 'Once a week, on GitHub';

  @override
  String get checkNow => 'Check now';

  @override
  String get upToDate => 'You have the latest version';

  @override
  String get updateCheckFailed => 'Could not check for a new version';

  @override
  String get updateAvailableTitle => 'New version';

  @override
  String updateAvailableMessage({required String version}) {
    return 'Version $version is available. Download the APK from GitHub and install it over the current app – your settings and data stay.';
  }

  @override
  String get later => 'Later';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get errorLog => 'Error log';

  @override
  String get errorLogDescription =>
      'Errors are kept only on this phone and are never sent anywhere. You can copy them into a problem report.';

  @override
  String get errorLogEmpty => 'No errors recorded';

  @override
  String get copy => 'Copy';

  @override
  String get clear => 'Clear';

  @override
  String get errorLogCopied => 'Error log copied';

  @override
  String get batteryTitle => 'Notifications not arriving?';

  @override
  String get batteryMessage =>
      'Some phones stop apps in the background to save battery. Turn off battery optimisation for this app.';

  @override
  String get batteryAllow => 'Turn off optimisation';

  @override
  String get moreInfo => 'More info';

  @override
  String get linkOpenFailed => 'Could not open the link';

  @override
  String get expiredBadge => 'Expired';

  @override
  String get errorOffline => 'No internet connection';

  @override
  String get errorCertificate =>
      'Could not connect securely to the faculty server. Check that the date and time on your phone are correct.';

  @override
  String get errorServer =>
      'The faculty server is not working right now. Try again later.';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get calendarRepeatUntil => 'Repeat until';

  @override
  String get calendarExportFailed => 'Could not export to the calendar';

  @override
  String get calendarFileSubject => 'Class schedule (calendar)';

  @override
  String get bookmark => 'Save';

  @override
  String get removeBookmark => 'Remove from saved';

  @override
  String get bookmarks => 'Saved announcements';

  @override
  String get noBookmarks =>
      'No saved announcements.\nSave one from the ⋮ menu on its card.';

  @override
  String get bookmarkSaved => 'Announcement saved';

  @override
  String get bookmarkRemoved => 'Removed from saved';

  @override
  String get bookmarkFailed => 'Could not save';

  @override
  String get classReminder => 'Reminder before class';

  @override
  String get classReminderDescription => 'For the saved class schedule';

  @override
  String get classReminderNoSchedule => 'Save a class schedule first';

  @override
  String classReminderMinutesBefore({required int minutes}) {
    return '$minutes min before';
  }

  @override
  String classReminderTitle({required int minutes, required String subject}) {
    return 'In $minutes min: $subject';
  }

  @override
  String get classReminderChannelName => 'Class reminders';

  @override
  String get classReminderChannelDescription =>
      'A notification before each class';

  @override
  String get widgetNoSchedule => 'Choose a class schedule in the app';

  @override
  String get widgetNoClasses => 'No classes';

  @override
  String get widgetNow => 'Now';

  @override
  String get widgetUntil => 'until';

  @override
  String get widgetNext => 'Next';

  @override
  String get widgetTomorrow => 'Tomorrow';

  @override
  String get widgetFree => 'No class now';

  @override
  String get widgetNoMoreToday => 'No more classes today';

  @override
  String get widgetNoClassesToday => 'No classes today';
}
