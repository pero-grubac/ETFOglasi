import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
  ];

  /// No description provided for @settings.
  ///
  /// In sr, this message translates to:
  /// **'Podešavanja'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In sr, this message translates to:
  /// **'Obavještenja'**
  String get notifications;

  /// No description provided for @schedule.
  ///
  /// In sr, this message translates to:
  /// **'Raspored'**
  String get schedule;

  /// No description provided for @choseLanguage.
  ///
  /// In sr, this message translates to:
  /// **'Izaberite jezik'**
  String get choseLanguage;

  /// No description provided for @language.
  ///
  /// In sr, this message translates to:
  /// **'Jezik'**
  String get language;

  /// No description provided for @appTitle.
  ///
  /// In sr, this message translates to:
  /// **'ETF'**
  String get appTitle;

  /// No description provided for @firstYear.
  ///
  /// In sr, this message translates to:
  /// **'Prva godina'**
  String get firstYear;

  /// No description provided for @secondYear.
  ///
  /// In sr, this message translates to:
  /// **'Druga godina'**
  String get secondYear;

  /// No description provided for @thirdYear.
  ///
  /// In sr, this message translates to:
  /// **'Treća godina'**
  String get thirdYear;

  /// No description provided for @fourthYear.
  ///
  /// In sr, this message translates to:
  /// **'Četvrta godina'**
  String get fourthYear;

  /// No description provided for @secondCycle.
  ///
  /// In sr, this message translates to:
  /// **'Drugi ciklus'**
  String get secondCycle;

  /// No description provided for @thirdCycle.
  ///
  /// In sr, this message translates to:
  /// **'Treći ciklus'**
  String get thirdCycle;

  /// No description provided for @postgraduateStudy.
  ///
  /// In sr, this message translates to:
  /// **'Postdiplomski studij'**
  String get postgraduateStudy;

  /// No description provided for @finalThesis.
  ///
  /// In sr, this message translates to:
  /// **'Odbrane završnih radova'**
  String get finalThesis;

  /// No description provided for @classSchedule.
  ///
  /// In sr, this message translates to:
  /// **'Raspored nastave'**
  String get classSchedule;

  /// No description provided for @hallSchedule.
  ///
  /// In sr, this message translates to:
  /// **'Raspored zauzetosti sala'**
  String get hallSchedule;

  /// No description provided for @refresh.
  ///
  /// In sr, this message translates to:
  /// **'Osvježi'**
  String get refresh;

  /// No description provided for @monday.
  ///
  /// In sr, this message translates to:
  /// **'Ponedjeljak'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In sr, this message translates to:
  /// **'Utorak'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In sr, this message translates to:
  /// **'Srijeda'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In sr, this message translates to:
  /// **'Četvrtak'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In sr, this message translates to:
  /// **'Petak'**
  String get friday;

  /// No description provided for @noSchedule.
  ///
  /// In sr, this message translates to:
  /// **'Nema rasporeda'**
  String get noSchedule;

  /// No description provided for @noData.
  ///
  /// In sr, this message translates to:
  /// **'Nema podataka'**
  String get noData;

  /// No description provided for @selectSchedule.
  ///
  /// In sr, this message translates to:
  /// **'Izaberite raspored'**
  String get selectSchedule;

  /// No description provided for @teacher.
  ///
  /// In sr, this message translates to:
  /// **'Profesori'**
  String get teacher;

  /// No description provided for @room.
  ///
  /// In sr, this message translates to:
  /// **'Prostorije'**
  String get room;

  /// No description provided for @studyProgram.
  ///
  /// In sr, this message translates to:
  /// **'Studijski program'**
  String get studyProgram;

  /// No description provided for @year.
  ///
  /// In sr, this message translates to:
  /// **'Godina'**
  String get year;

  /// No description provided for @save.
  ///
  /// In sr, this message translates to:
  /// **'Sačuvaj'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In sr, this message translates to:
  /// **'Otkaži'**
  String get cancel;

  /// No description provided for @select.
  ///
  /// In sr, this message translates to:
  /// **'Izaberi'**
  String get select;

  /// No description provided for @noNotifications.
  ///
  /// In sr, this message translates to:
  /// **'Nema obavještenja'**
  String get noNotifications;

  /// No description provided for @selectDate.
  ///
  /// In sr, this message translates to:
  /// **'Izaberite datum'**
  String get selectDate;

  /// No description provided for @date.
  ///
  /// In sr, this message translates to:
  /// **'Datum'**
  String get date;

  /// No description provided for @attachment.
  ///
  /// In sr, this message translates to:
  /// **'Prilog'**
  String get attachment;

  /// No description provided for @signature.
  ///
  /// In sr, this message translates to:
  /// **'Potpis'**
  String get signature;

  /// No description provided for @theme.
  ///
  /// In sr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// Poruka o grešci za minimalnu dužinu notifikacije
  ///
  /// In sr, this message translates to:
  /// **'Minimalna dužina je {minutes} minuta'**
  String minDurationError({required Object minutes});

  /// Poruka kada je dužina automatski postavljena na minimum
  ///
  /// In sr, this message translates to:
  /// **'Dužina postavljena na {minutes} minuta zbog minimalnog zahtjeva'**
  String minDurationSet({required Object minutes});

  /// No description provided for @notAllowedNotification.
  ///
  /// In sr, this message translates to:
  /// **'Niste omogućili notifikacije.'**
  String get notAllowedNotification;

  /// No description provided for @error.
  ///
  /// In sr, this message translates to:
  /// **'Greška'**
  String get error;

  /// No description provided for @routeNotFound.
  ///
  /// In sr, this message translates to:
  /// **'Stranica nije pronađena'**
  String get routeNotFound;

  /// No description provided for @loadingError.
  ///
  /// In sr, this message translates to:
  /// **'Greška prilikom učitavanja podataka'**
  String get loadingError;

  /// No description provided for @tryAgain.
  ///
  /// In sr, this message translates to:
  /// **'Pokušaj ponovo'**
  String get tryAgain;

  /// No description provided for @offlineData.
  ///
  /// In sr, this message translates to:
  /// **'Nema konekcije – prikazani su sačuvani podaci'**
  String get offlineData;

  /// No description provided for @refreshFailed.
  ///
  /// In sr, this message translates to:
  /// **'Osvježavanje nije uspjelo'**
  String get refreshFailed;

  /// No description provided for @noScheduleSelected.
  ///
  /// In sr, this message translates to:
  /// **'Raspored nije izabran'**
  String get noScheduleSelected;

  /// No description provided for @showMore.
  ///
  /// In sr, this message translates to:
  /// **'Prikaži više'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In sr, this message translates to:
  /// **'Prikaži manje'**
  String get showLess;

  /// No description provided for @createdAt.
  ///
  /// In sr, this message translates to:
  /// **'Kreirano: {date}'**
  String createdAt({required String date});

  /// No description provided for @expiresAt.
  ///
  /// In sr, this message translates to:
  /// **'Istek: {date}'**
  String expiresAt({required String date});

  /// No description provided for @chooseDownloadLocation.
  ///
  /// In sr, this message translates to:
  /// **'Izaberite lokaciju za preuzimanje'**
  String get chooseDownloadLocation;

  /// No description provided for @downloadCancelled.
  ///
  /// In sr, this message translates to:
  /// **'Preuzimanje otkazano'**
  String get downloadCancelled;

  /// No description provided for @downloadSuccess.
  ///
  /// In sr, this message translates to:
  /// **'Fajl je uspješno preuzet'**
  String get downloadSuccess;

  /// No description provided for @downloadFailed.
  ///
  /// In sr, this message translates to:
  /// **'Preuzimanje fajla nije uspjelo'**
  String get downloadFailed;

  /// No description provided for @open.
  ///
  /// In sr, this message translates to:
  /// **'Otvori'**
  String get open;

  /// No description provided for @openFileFailed.
  ///
  /// In sr, this message translates to:
  /// **'Fajl nije moguće otvoriti'**
  String get openFileFailed;

  /// No description provided for @downloadFileTitle.
  ///
  /// In sr, this message translates to:
  /// **'Preuzimanje fajla'**
  String get downloadFileTitle;

  /// No description provided for @downloadFileQuestion.
  ///
  /// In sr, this message translates to:
  /// **'Da li želite da preuzmete fajl „{fileName}”?'**
  String downloadFileQuestion({required String fileName});

  /// No description provided for @download.
  ///
  /// In sr, this message translates to:
  /// **'Preuzmi'**
  String get download;

  /// No description provided for @settingsSaved.
  ///
  /// In sr, this message translates to:
  /// **'Podešavanja sačuvana'**
  String get settingsSaved;

  /// No description provided for @openSettings.
  ///
  /// In sr, this message translates to:
  /// **'Podešavanja'**
  String get openSettings;

  /// No description provided for @daysShort.
  ///
  /// In sr, this message translates to:
  /// **'d'**
  String get daysShort;

  /// No description provided for @hoursShort.
  ///
  /// In sr, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @minutesShort.
  ///
  /// In sr, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @notificationChannelName.
  ///
  /// In sr, this message translates to:
  /// **'Oglasi'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In sr, this message translates to:
  /// **'Obavještenja o novim oglasima'**
  String get notificationChannelDescription;

  /// Notification title
  ///
  /// In sr, this message translates to:
  /// **'{board}: novi oglasi ({count})'**
  String newAnnouncementsTitle({required String board, required int count});

  /// No description provided for @search.
  ///
  /// In sr, this message translates to:
  /// **'Pretraga'**
  String get search;

  /// No description provided for @noSearchResults.
  ///
  /// In sr, this message translates to:
  /// **'Nema rezultata pretrage'**
  String get noSearchResults;

  /// No description provided for @newBadge.
  ///
  /// In sr, this message translates to:
  /// **'Novo'**
  String get newBadge;

  /// No description provided for @share.
  ///
  /// In sr, this message translates to:
  /// **'Podijeli'**
  String get share;

  /// No description provided for @copyText.
  ///
  /// In sr, this message translates to:
  /// **'Kopiraj tekst'**
  String get copyText;

  /// No description provided for @copied.
  ///
  /// In sr, this message translates to:
  /// **'Tekst je kopiran'**
  String get copied;

  /// No description provided for @moreOptions.
  ///
  /// In sr, this message translates to:
  /// **'Više opcija'**
  String get moreOptions;

  /// No description provided for @unseenAnnouncements.
  ///
  /// In sr, this message translates to:
  /// **'Nepročitani oglasi: {count}'**
  String unseenAnnouncements({required int count});

  /// No description provided for @previousWeek.
  ///
  /// In sr, this message translates to:
  /// **'Prethodna sedmica'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In sr, this message translates to:
  /// **'Sljedeća sedmica'**
  String get nextWeek;

  /// No description provided for @themeLight.
  ///
  /// In sr, this message translates to:
  /// **'Svijetla'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In sr, this message translates to:
  /// **'Tamna'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In sr, this message translates to:
  /// **'Sistemska'**
  String get themeSystem;

  /// No description provided for @about.
  ///
  /// In sr, this message translates to:
  /// **'O aplikaciji'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In sr, this message translates to:
  /// **'Verzija {version}'**
  String appVersion({required String version});

  /// No description provided for @checkForUpdates.
  ///
  /// In sr, this message translates to:
  /// **'Provjeravaj nove verzije'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesDescription.
  ///
  /// In sr, this message translates to:
  /// **'Jednom sedmično, preko GitHub-a'**
  String get checkForUpdatesDescription;

  /// No description provided for @checkNow.
  ///
  /// In sr, this message translates to:
  /// **'Provjeri sada'**
  String get checkNow;

  /// No description provided for @upToDate.
  ///
  /// In sr, this message translates to:
  /// **'Imate najnoviju verziju'**
  String get upToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In sr, this message translates to:
  /// **'Provjera nove verzije nije uspjela'**
  String get updateCheckFailed;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In sr, this message translates to:
  /// **'Nova verzija'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In sr, this message translates to:
  /// **'Dostupna je verzija {version}. Preuzmite APK sa GitHub stranice i instalirajte ga preko postojeće aplikacije – podešavanja i podaci ostaju.'**
  String updateAvailableMessage({required String version});

  /// No description provided for @later.
  ///
  /// In sr, this message translates to:
  /// **'Kasnije'**
  String get later;

  /// No description provided for @reportProblem.
  ///
  /// In sr, this message translates to:
  /// **'Prijavi problem'**
  String get reportProblem;

  /// No description provided for @errorLog.
  ///
  /// In sr, this message translates to:
  /// **'Dnevnik grešaka'**
  String get errorLog;

  /// No description provided for @errorLogDescription.
  ///
  /// In sr, this message translates to:
  /// **'Greške se čuvaju samo na telefonu i nigdje se ne šalju. Možete ih kopirati uz prijavu problema.'**
  String get errorLogDescription;

  /// No description provided for @errorLogEmpty.
  ///
  /// In sr, this message translates to:
  /// **'Nema zabilježenih grešaka'**
  String get errorLogEmpty;

  /// No description provided for @copy.
  ///
  /// In sr, this message translates to:
  /// **'Kopiraj'**
  String get copy;

  /// No description provided for @clear.
  ///
  /// In sr, this message translates to:
  /// **'Obriši'**
  String get clear;

  /// No description provided for @errorLogCopied.
  ///
  /// In sr, this message translates to:
  /// **'Dnevnik grešaka je kopiran'**
  String get errorLogCopied;

  /// No description provided for @batteryTitle.
  ///
  /// In sr, this message translates to:
  /// **'Obavještenja ne stižu?'**
  String get batteryTitle;

  /// No description provided for @batteryMessage.
  ///
  /// In sr, this message translates to:
  /// **'Neki telefoni zaustavljaju aplikacije u pozadini radi uštede baterije. Isključite optimizaciju baterije za ovu aplikaciju.'**
  String get batteryMessage;

  /// No description provided for @batteryAllow.
  ///
  /// In sr, this message translates to:
  /// **'Isključi optimizaciju'**
  String get batteryAllow;

  /// No description provided for @moreInfo.
  ///
  /// In sr, this message translates to:
  /// **'Više informacija'**
  String get moreInfo;

  /// No description provided for @linkOpenFailed.
  ///
  /// In sr, this message translates to:
  /// **'Link nije moguće otvoriti'**
  String get linkOpenFailed;

  /// No description provided for @expiredBadge.
  ///
  /// In sr, this message translates to:
  /// **'Isteklo'**
  String get expiredBadge;

  /// No description provided for @errorOffline.
  ///
  /// In sr, this message translates to:
  /// **'Nema internet konekcije'**
  String get errorOffline;

  /// No description provided for @errorCertificate.
  ///
  /// In sr, this message translates to:
  /// **'Sigurna veza sa serverom fakulteta nije uspjela. Provjerite da su datum i vrijeme na telefonu tačni.'**
  String get errorCertificate;

  /// No description provided for @errorServer.
  ///
  /// In sr, this message translates to:
  /// **'Server fakulteta trenutno ne radi. Pokušajte kasnije.'**
  String get errorServer;

  /// No description provided for @addToCalendar.
  ///
  /// In sr, this message translates to:
  /// **'Dodaj u kalendar'**
  String get addToCalendar;

  /// No description provided for @calendarRepeatUntil.
  ///
  /// In sr, this message translates to:
  /// **'Ponavljaj do'**
  String get calendarRepeatUntil;

  /// No description provided for @calendarExportFailed.
  ///
  /// In sr, this message translates to:
  /// **'Izvoz u kalendar nije uspio'**
  String get calendarExportFailed;

  /// No description provided for @calendarFileSubject.
  ///
  /// In sr, this message translates to:
  /// **'Raspored nastave (kalendar)'**
  String get calendarFileSubject;

  /// No description provided for @bookmark.
  ///
  /// In sr, this message translates to:
  /// **'Sačuvaj'**
  String get bookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In sr, this message translates to:
  /// **'Ukloni iz sačuvanih'**
  String get removeBookmark;

  /// No description provided for @bookmarks.
  ///
  /// In sr, this message translates to:
  /// **'Sačuvani oglasi'**
  String get bookmarks;

  /// No description provided for @noBookmarks.
  ///
  /// In sr, this message translates to:
  /// **'Nemate sačuvanih oglasa.\nOglas sačuvajte iz menija ⋮ na kartici.'**
  String get noBookmarks;

  /// No description provided for @bookmarkSaved.
  ///
  /// In sr, this message translates to:
  /// **'Oglas je sačuvan'**
  String get bookmarkSaved;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In sr, this message translates to:
  /// **'Oglas je uklonjen iz sačuvanih'**
  String get bookmarkRemoved;

  /// No description provided for @bookmarkFailed.
  ///
  /// In sr, this message translates to:
  /// **'Čuvanje nije uspjelo'**
  String get bookmarkFailed;

  /// No description provided for @classReminder.
  ///
  /// In sr, this message translates to:
  /// **'Podsjetnik prije nastave'**
  String get classReminder;

  /// No description provided for @classReminderDescription.
  ///
  /// In sr, this message translates to:
  /// **'Za sačuvani raspored nastave'**
  String get classReminderDescription;

  /// No description provided for @classReminderNoSchedule.
  ///
  /// In sr, this message translates to:
  /// **'Prvo sačuvajte raspored nastave'**
  String get classReminderNoSchedule;

  /// No description provided for @classReminderMinutesBefore.
  ///
  /// In sr, this message translates to:
  /// **'{minutes} min prije'**
  String classReminderMinutesBefore({required int minutes});

  /// No description provided for @classReminderTitle.
  ///
  /// In sr, this message translates to:
  /// **'Za {minutes} min: {subject}'**
  String classReminderTitle({required int minutes, required String subject});

  /// No description provided for @classReminderChannelName.
  ///
  /// In sr, this message translates to:
  /// **'Podsjetnici za nastavu'**
  String get classReminderChannelName;

  /// No description provided for @classReminderChannelDescription.
  ///
  /// In sr, this message translates to:
  /// **'Obavještenje prije početka časa'**
  String get classReminderChannelDescription;

  /// No description provided for @widgetNoSchedule.
  ///
  /// In sr, this message translates to:
  /// **'Izaberite raspored nastave u aplikaciji'**
  String get widgetNoSchedule;

  /// No description provided for @widgetNoClasses.
  ///
  /// In sr, this message translates to:
  /// **'Nema nastave'**
  String get widgetNoClasses;

  /// No description provided for @widgetNow.
  ///
  /// In sr, this message translates to:
  /// **'Sada'**
  String get widgetNow;

  /// No description provided for @widgetUntil.
  ///
  /// In sr, this message translates to:
  /// **'do'**
  String get widgetUntil;

  /// No description provided for @widgetNext.
  ///
  /// In sr, this message translates to:
  /// **'Zatim'**
  String get widgetNext;

  /// No description provided for @widgetTomorrow.
  ///
  /// In sr, this message translates to:
  /// **'Sutra'**
  String get widgetTomorrow;

  /// No description provided for @widgetFree.
  ///
  /// In sr, this message translates to:
  /// **'Sada nema nastave'**
  String get widgetFree;

  /// No description provided for @widgetNoMoreToday.
  ///
  /// In sr, this message translates to:
  /// **'Danas nema više nastave'**
  String get widgetNoMoreToday;

  /// No description provided for @widgetNoClassesToday.
  ///
  /// In sr, this message translates to:
  /// **'Danas nema nastave'**
  String get widgetNoClassesToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsSrCyrl();
          case 'Latn':
            return AppLocalizationsSrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
