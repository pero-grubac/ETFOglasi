// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get settings => 'Podešavanja';

  @override
  String get notifications => 'Obavještenja';

  @override
  String get schedule => 'Raspored';

  @override
  String get choseLanguage => 'Izaberite jezik';

  @override
  String get language => 'Jezik';

  @override
  String get appTitle => 'ETF';

  @override
  String get firstYear => 'Prva godina';

  @override
  String get secondYear => 'Druga godina';

  @override
  String get thirdYear => 'Treća godina';

  @override
  String get fourthYear => 'Četvrta godina';

  @override
  String get secondCycle => 'Drugi ciklus';

  @override
  String get thirdCycle => 'Treći ciklus';

  @override
  String get postgraduateStudy => 'Postdiplomski studij';

  @override
  String get finalThesis => 'Odbrane završnih radova';

  @override
  String get classSchedule => 'Raspored nastave';

  @override
  String get hallSchedule => 'Raspored zauzetosti sala';

  @override
  String get refresh => 'Osvježi';

  @override
  String get monday => 'Ponedjeljak';

  @override
  String get tuesday => 'Utorak';

  @override
  String get wednesday => 'Srijeda';

  @override
  String get thursday => 'Četvrtak';

  @override
  String get friday => 'Petak';

  @override
  String get noSchedule => 'Nema rasporeda';

  @override
  String get noData => 'Nema podataka';

  @override
  String get selectSchedule => 'Izaberite raspored';

  @override
  String get teacher => 'Profesori';

  @override
  String get room => 'Prostorije';

  @override
  String get studyProgram => 'Studijski program';

  @override
  String get year => 'Godina';

  @override
  String get save => 'Sačuvaj';

  @override
  String get cancel => 'Otkaži';

  @override
  String get select => 'Izaberi';

  @override
  String get noNotifications => 'Nema obavještenja';

  @override
  String get selectDate => 'Izaberite datum';

  @override
  String get date => 'Datum';

  @override
  String get attachment => 'Prilog';

  @override
  String get signature => 'Potpis';

  @override
  String get theme => 'Tema';

  @override
  String minDurationError({required Object minutes}) {
    return 'Minimalna dužina je $minutes minuta';
  }

  @override
  String minDurationSet({required Object minutes}) {
    return 'Dužina postavljena na $minutes minuta zbog minimalnog zahtjeva';
  }

  @override
  String get notAllowedNotification => 'Niste omogućili notifikacije.';

  @override
  String get error => 'Greška';

  @override
  String get routeNotFound => 'Stranica nije pronađena';

  @override
  String get loadingError => 'Greška prilikom učitavanja podataka';

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String get offlineData => 'Nema konekcije – prikazani su sačuvani podaci';

  @override
  String get refreshFailed => 'Osvježavanje nije uspjelo';

  @override
  String get noScheduleSelected => 'Raspored nije izabran';

  @override
  String get showMore => 'Prikaži više';

  @override
  String get showLess => 'Prikaži manje';

  @override
  String createdAt({required String date}) {
    return 'Kreirano: $date';
  }

  @override
  String expiresAt({required String date}) {
    return 'Istek: $date';
  }

  @override
  String get chooseDownloadLocation => 'Izaberite lokaciju za preuzimanje';

  @override
  String get downloadCancelled => 'Preuzimanje otkazano';

  @override
  String get downloadSuccess => 'Fajl je uspješno preuzet';

  @override
  String get downloadFailed => 'Preuzimanje fajla nije uspjelo';

  @override
  String get open => 'Otvori';

  @override
  String get openFileFailed => 'Fajl nije moguće otvoriti';

  @override
  String get downloadFileTitle => 'Preuzimanje fajla';

  @override
  String downloadFileQuestion({required String fileName}) {
    return 'Da li želite da preuzmete fajl „$fileName”?';
  }

  @override
  String get download => 'Preuzmi';

  @override
  String get settingsSaved => 'Podešavanja sačuvana';

  @override
  String get openSettings => 'Podešavanja';

  @override
  String get daysShort => 'd';

  @override
  String get hoursShort => 'h';

  @override
  String get minutesShort => 'min';

  @override
  String get notificationChannelName => 'Oglasi';

  @override
  String get notificationChannelDescription => 'Obavještenja o novim oglasima';

  @override
  String newAnnouncementsTitle({required String board, required int count}) {
    return '$board: novi oglasi ($count)';
  }

  @override
  String get search => 'Pretraga';

  @override
  String get noSearchResults => 'Nema rezultata pretrage';

  @override
  String get newBadge => 'Novo';

  @override
  String get share => 'Podijeli';

  @override
  String get copyText => 'Kopiraj tekst';

  @override
  String get copied => 'Tekst je kopiran';

  @override
  String get moreOptions => 'Više opcija';

  @override
  String unseenAnnouncements({required int count}) {
    return 'Nepročitani oglasi: $count';
  }

  @override
  String get previousWeek => 'Prethodna sedmica';

  @override
  String get nextWeek => 'Sljedeća sedmica';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get themeSystem => 'Sistemska';

  @override
  String get about => 'O aplikaciji';

  @override
  String appVersion({required String version}) {
    return 'Verzija $version';
  }

  @override
  String get checkForUpdates => 'Provjeravaj nove verzije';

  @override
  String get checkForUpdatesDescription => 'Jednom sedmično, preko GitHub-a';

  @override
  String get checkNow => 'Provjeri sada';

  @override
  String get upToDate => 'Imate najnoviju verziju';

  @override
  String get updateCheckFailed => 'Provjera nove verzije nije uspjela';

  @override
  String get updateAvailableTitle => 'Nova verzija';

  @override
  String updateAvailableMessage({required String version}) {
    return 'Dostupna je verzija $version. Preuzmite APK sa GitHub stranice i instalirajte ga preko postojeće aplikacije – podešavanja i podaci ostaju.';
  }

  @override
  String get later => 'Kasnije';

  @override
  String get reportProblem => 'Prijavi problem';

  @override
  String get errorLog => 'Dnevnik grešaka';

  @override
  String get errorLogDescription =>
      'Greške se čuvaju samo na telefonu i nigdje se ne šalju. Možete ih kopirati uz prijavu problema.';

  @override
  String get errorLogEmpty => 'Nema zabilježenih grešaka';

  @override
  String get copy => 'Kopiraj';

  @override
  String get clear => 'Obriši';

  @override
  String get errorLogCopied => 'Dnevnik grešaka je kopiran';

  @override
  String get batteryTitle => 'Obavještenja ne stižu?';

  @override
  String get batteryMessage =>
      'Neki telefoni zaustavljaju aplikacije u pozadini radi uštede baterije. Isključite optimizaciju baterije za ovu aplikaciju.';

  @override
  String get batteryAllow => 'Isključi optimizaciju';

  @override
  String get moreInfo => 'Više informacija';

  @override
  String get linkOpenFailed => 'Link nije moguće otvoriti';

  @override
  String get expiredBadge => 'Isteklo';

  @override
  String get errorOffline => 'Nema internet konekcije';

  @override
  String get errorCertificate =>
      'Sigurna veza sa serverom fakulteta nije uspjela. Provjerite da su datum i vrijeme na telefonu tačni.';

  @override
  String get errorServer =>
      'Server fakulteta trenutno ne radi. Pokušajte kasnije.';

  @override
  String get addToCalendar => 'Dodaj u kalendar';

  @override
  String get calendarRepeatUntil => 'Ponavljaj do';

  @override
  String get calendarExportFailed => 'Izvoz u kalendar nije uspio';

  @override
  String get calendarFileSubject => 'Raspored nastave (kalendar)';

  @override
  String get bookmark => 'Sačuvaj';

  @override
  String get removeBookmark => 'Ukloni iz sačuvanih';

  @override
  String get bookmarks => 'Sačuvani oglasi';

  @override
  String get noBookmarks =>
      'Nemate sačuvanih oglasa.\nOglas sačuvajte iz menija ⋮ na kartici.';

  @override
  String get bookmarkSaved => 'Oglas je sačuvan';

  @override
  String get bookmarkRemoved => 'Oglas je uklonjen iz sačuvanih';

  @override
  String get bookmarkFailed => 'Čuvanje nije uspjelo';

  @override
  String get classReminder => 'Podsjetnik prije nastave';

  @override
  String get classReminderDescription => 'Za sačuvani raspored nastave';

  @override
  String get classReminderNoSchedule => 'Prvo sačuvajte raspored nastave';

  @override
  String classReminderMinutesBefore({required int minutes}) {
    return '$minutes min prije';
  }

  @override
  String classReminderTitle({required int minutes, required String subject}) {
    return 'Za $minutes min: $subject';
  }

  @override
  String get classReminderChannelName => 'Podsjetnici za nastavu';

  @override
  String get classReminderChannelDescription =>
      'Obavještenje prije početka časa';

  @override
  String get widgetNoSchedule => 'Izaberite raspored nastave u aplikaciji';

  @override
  String get widgetNoClasses => 'Nema nastave';

  @override
  String get widgetNow => 'Sada';

  @override
  String get widgetUntil => 'do';

  @override
  String get widgetNext => 'Zatim';

  @override
  String get widgetTomorrow => 'Sutra';

  @override
  String get widgetFree => 'Sada nema nastave';

  @override
  String get widgetNoMoreToday => 'Danas nema više nastave';

  @override
  String get widgetNoClassesToday => 'Danas nema nastave';
}

/// The translations for Serbian, using the Cyrillic script (`sr_Cyrl`).
class AppLocalizationsSrCyrl extends AppLocalizationsSr {
  AppLocalizationsSrCyrl() : super('sr_Cyrl');

  @override
  String get settings => 'Подешавања';

  @override
  String get notifications => 'Обавјештења';

  @override
  String get schedule => 'Распоред';

  @override
  String get choseLanguage => 'Изаберите језик';

  @override
  String get language => 'Језик';

  @override
  String get appTitle => 'ЕТФ';

  @override
  String get firstYear => 'Прва година';

  @override
  String get secondYear => 'Друга година';

  @override
  String get thirdYear => 'Трећа година';

  @override
  String get fourthYear => 'Четврта година';

  @override
  String get secondCycle => 'Други циклус';

  @override
  String get thirdCycle => 'Трећи циклус';

  @override
  String get postgraduateStudy => 'Постдипломски студиј';

  @override
  String get finalThesis => 'Одбране завршних радова';

  @override
  String get classSchedule => 'Распоред наставе';

  @override
  String get hallSchedule => 'Распоред заузетости сала';

  @override
  String get refresh => 'Освјежи';

  @override
  String get monday => 'Понедјељак';

  @override
  String get tuesday => 'Уторак';

  @override
  String get wednesday => 'Сриједа';

  @override
  String get thursday => 'Четвртак';

  @override
  String get friday => 'Петак';

  @override
  String get noSchedule => 'Нема распореда';

  @override
  String get noData => 'Нема података';

  @override
  String get selectSchedule => 'Изаберите распоред';

  @override
  String get teacher => 'Професори';

  @override
  String get room => 'Просторије';

  @override
  String get studyProgram => 'Студијски програм';

  @override
  String get year => 'Година';

  @override
  String get save => 'Сачувај';

  @override
  String get cancel => 'Откажи';

  @override
  String get select => 'Изабери';

  @override
  String get noNotifications => 'Нема обавјештења';

  @override
  String get selectDate => 'Изаберите датум';

  @override
  String get date => 'Датум';

  @override
  String get attachment => 'Прилог';

  @override
  String get signature => 'Потпис';

  @override
  String get theme => 'Тема';

  @override
  String minDurationError({required Object minutes}) {
    return 'Минимална дужина је $minutes минута';
  }

  @override
  String minDurationSet({required Object minutes}) {
    return 'Дужина постављена на $minutes минута због минималног захтјева';
  }

  @override
  String get notAllowedNotification => 'Нисте омогућили нотификације.';

  @override
  String get error => 'Грешка';

  @override
  String get routeNotFound => 'Страница није пронађена';

  @override
  String get loadingError => 'Грешка приликом учитавања података';

  @override
  String get tryAgain => 'Покушај поново';

  @override
  String get offlineData => 'Нема конекције – приказани су сачувани подаци';

  @override
  String get refreshFailed => 'Освјежавање није успјело';

  @override
  String get noScheduleSelected => 'Распоред није изабран';

  @override
  String get showMore => 'Прикажи више';

  @override
  String get showLess => 'Прикажи мање';

  @override
  String createdAt({required String date}) {
    return 'Креирано: $date';
  }

  @override
  String expiresAt({required String date}) {
    return 'Истек: $date';
  }

  @override
  String get chooseDownloadLocation => 'Изаберите локацију за преузимање';

  @override
  String get downloadCancelled => 'Преузимање отказано';

  @override
  String get downloadSuccess => 'Фајл је успјешно преузет';

  @override
  String get downloadFailed => 'Преузимање фајла није успјело';

  @override
  String get open => 'Отвори';

  @override
  String get openFileFailed => 'Фајл није могуће отворити';

  @override
  String get downloadFileTitle => 'Преузимање фајла';

  @override
  String downloadFileQuestion({required String fileName}) {
    return 'Да ли желите да преузмете фајл „$fileName”?';
  }

  @override
  String get download => 'Преузми';

  @override
  String get settingsSaved => 'Подешавања сачувана';

  @override
  String get openSettings => 'Подешавања';

  @override
  String get daysShort => 'д';

  @override
  String get hoursShort => 'ч';

  @override
  String get minutesShort => 'мин';

  @override
  String get notificationChannelName => 'Огласи';

  @override
  String get notificationChannelDescription => 'Обавјештења о новим огласима';

  @override
  String newAnnouncementsTitle({required String board, required int count}) {
    return '$board: нови огласи ($count)';
  }

  @override
  String get search => 'Претрага';

  @override
  String get noSearchResults => 'Нема резултата претраге';

  @override
  String get newBadge => 'Ново';

  @override
  String get share => 'Подијели';

  @override
  String get copyText => 'Копирај текст';

  @override
  String get copied => 'Текст је копиран';

  @override
  String get moreOptions => 'Више опција';

  @override
  String unseenAnnouncements({required int count}) {
    return 'Непрочитани огласи: $count';
  }

  @override
  String get previousWeek => 'Претходна седмица';

  @override
  String get nextWeek => 'Сљедећа седмица';

  @override
  String get themeLight => 'Свијетла';

  @override
  String get themeDark => 'Тамна';

  @override
  String get themeSystem => 'Системска';

  @override
  String get about => 'О апликацији';

  @override
  String appVersion({required String version}) {
    return 'Верзија $version';
  }

  @override
  String get checkForUpdates => 'Провјеравај нове верзије';

  @override
  String get checkForUpdatesDescription => 'Једном седмично, преко GitHub-а';

  @override
  String get checkNow => 'Провјери сада';

  @override
  String get upToDate => 'Имате најновију верзију';

  @override
  String get updateCheckFailed => 'Провјера нове верзије није успјела';

  @override
  String get updateAvailableTitle => 'Нова верзија';

  @override
  String updateAvailableMessage({required String version}) {
    return 'Доступна је верзија $version. Преузмите APK са GitHub странице и инсталирајте га преко постојеће апликације – подешавања и подаци остају.';
  }

  @override
  String get later => 'Касније';

  @override
  String get reportProblem => 'Пријави проблем';

  @override
  String get errorLog => 'Дневник грешака';

  @override
  String get errorLogDescription =>
      'Грешке се чувају само на телефону и нигдје се не шаљу. Можете их копирати уз пријаву проблема.';

  @override
  String get errorLogEmpty => 'Нема забиљежених грешака';

  @override
  String get copy => 'Копирај';

  @override
  String get clear => 'Обриши';

  @override
  String get errorLogCopied => 'Дневник грешака је копиран';

  @override
  String get batteryTitle => 'Обавјештења не стижу?';

  @override
  String get batteryMessage =>
      'Неки телефони заустављају апликације у позадини ради уштеде батерије. Искључите оптимизацију батерије за ову апликацију.';

  @override
  String get batteryAllow => 'Искључи оптимизацију';

  @override
  String get moreInfo => 'Више информација';

  @override
  String get linkOpenFailed => 'Линк није могуће отворити';

  @override
  String get expiredBadge => 'Истекло';

  @override
  String get errorOffline => 'Нема интернет конекције';

  @override
  String get errorCertificate =>
      'Сигурна веза са сервером факултета није успјела. Провјерите да су датум и вријеме на телефону тачни.';

  @override
  String get errorServer =>
      'Сервер факултета тренутно не ради. Покушајте касније.';

  @override
  String get addToCalendar => 'Додај у календар';

  @override
  String get calendarRepeatUntil => 'Понављај до';

  @override
  String get calendarExportFailed => 'Извоз у календар није успио';

  @override
  String get calendarFileSubject => 'Распоред наставе (календар)';

  @override
  String get bookmark => 'Сачувај';

  @override
  String get removeBookmark => 'Уклони из сачуваних';

  @override
  String get bookmarks => 'Сачувани огласи';

  @override
  String get noBookmarks =>
      'Немате сачуваних огласа.\nОглас сачувајте из менија ⋮ на картици.';

  @override
  String get bookmarkSaved => 'Оглас је сачуван';

  @override
  String get bookmarkRemoved => 'Оглас је уклоњен из сачуваних';

  @override
  String get bookmarkFailed => 'Чување није успјело';

  @override
  String get classReminder => 'Подсјетник прије наставе';

  @override
  String get classReminderDescription => 'За сачувани распоред наставе';

  @override
  String get classReminderNoSchedule => 'Прво сачувајте распоред наставе';

  @override
  String classReminderMinutesBefore({required int minutes}) {
    return '$minutes мин прије';
  }

  @override
  String classReminderTitle({required int minutes, required String subject}) {
    return 'За $minutes мин: $subject';
  }

  @override
  String get classReminderChannelName => 'Подсјетници за наставу';

  @override
  String get classReminderChannelDescription =>
      'Обавјештење прије почетка часа';

  @override
  String get widgetNoSchedule => 'Изаберите распоред наставе у апликацији';

  @override
  String get widgetNoClasses => 'Нема наставе';

  @override
  String get widgetNow => 'Сада';

  @override
  String get widgetUntil => 'до';

  @override
  String get widgetNext => 'Затим';

  @override
  String get widgetTomorrow => 'Сутра';

  @override
  String get widgetFree => 'Сада нема наставе';

  @override
  String get widgetNoMoreToday => 'Данас нема више наставе';

  @override
  String get widgetNoClassesToday => 'Данас нема наставе';
}

/// The translations for Serbian, using the Latin script (`sr_Latn`).
class AppLocalizationsSrLatn extends AppLocalizationsSr {
  AppLocalizationsSrLatn() : super('sr_Latn');

  @override
  String get settings => 'Podešavanja';

  @override
  String get notifications => 'Obavještenja';

  @override
  String get schedule => 'Raspored';

  @override
  String get choseLanguage => 'Izaberite jezik';

  @override
  String get language => 'Jezik';

  @override
  String get appTitle => 'ETF';

  @override
  String get firstYear => 'Prva godina';

  @override
  String get secondYear => 'Druga godina';

  @override
  String get thirdYear => 'Treća godina';

  @override
  String get fourthYear => 'Četvrta godina';

  @override
  String get secondCycle => 'Drugi ciklus';

  @override
  String get thirdCycle => 'Treći ciklus';

  @override
  String get postgraduateStudy => 'Postdiplomski studij';

  @override
  String get finalThesis => 'Odbrane završnih radova';

  @override
  String get classSchedule => 'Raspored nastave';

  @override
  String get hallSchedule => 'Raspored zauzetosti sala';

  @override
  String get refresh => 'Osvježi';

  @override
  String get monday => 'Ponedjeljak';

  @override
  String get tuesday => 'Utorak';

  @override
  String get wednesday => 'Srijeda';

  @override
  String get thursday => 'Četvrtak';

  @override
  String get friday => 'Petak';

  @override
  String get noSchedule => 'Nema rasporeda';

  @override
  String get noData => 'Nema podataka';

  @override
  String get selectSchedule => 'Izaberite raspored';

  @override
  String get teacher => 'Profesori';

  @override
  String get room => 'Prostorije';

  @override
  String get studyProgram => 'Studijski program';

  @override
  String get year => 'Godina';

  @override
  String get save => 'Sačuvaj';

  @override
  String get cancel => 'Otkaži';

  @override
  String get select => 'Izaberi';

  @override
  String get noNotifications => 'Nema obavještenja';

  @override
  String get selectDate => 'Izaberite datum';

  @override
  String get date => 'Datum';

  @override
  String get attachment => 'Prilog';

  @override
  String get signature => 'Potpis';

  @override
  String get theme => 'Tema';

  @override
  String minDurationError({required Object minutes}) {
    return 'Minimalna dužina je $minutes minuta';
  }

  @override
  String minDurationSet({required Object minutes}) {
    return 'Dužina postavljena na $minutes minuta zbog minimalnog zahtjeva';
  }

  @override
  String get notAllowedNotification => 'Niste omogućili notifikacije.';

  @override
  String get error => 'Greška';

  @override
  String get routeNotFound => 'Stranica nije pronađena';

  @override
  String get loadingError => 'Greška prilikom učitavanja podataka';

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String get offlineData => 'Nema konekcije – prikazani su sačuvani podaci';

  @override
  String get refreshFailed => 'Osvježavanje nije uspjelo';

  @override
  String get noScheduleSelected => 'Raspored nije izabran';

  @override
  String get showMore => 'Prikaži više';

  @override
  String get showLess => 'Prikaži manje';

  @override
  String createdAt({required String date}) {
    return 'Kreirano: $date';
  }

  @override
  String expiresAt({required String date}) {
    return 'Istek: $date';
  }

  @override
  String get chooseDownloadLocation => 'Izaberite lokaciju za preuzimanje';

  @override
  String get downloadCancelled => 'Preuzimanje otkazano';

  @override
  String get downloadSuccess => 'Fajl je uspješno preuzet';

  @override
  String get downloadFailed => 'Preuzimanje fajla nije uspjelo';

  @override
  String get open => 'Otvori';

  @override
  String get openFileFailed => 'Fajl nije moguće otvoriti';

  @override
  String get downloadFileTitle => 'Preuzimanje fajla';

  @override
  String downloadFileQuestion({required String fileName}) {
    return 'Da li želite da preuzmete fajl „$fileName”?';
  }

  @override
  String get download => 'Preuzmi';

  @override
  String get settingsSaved => 'Podešavanja sačuvana';

  @override
  String get openSettings => 'Podešavanja';

  @override
  String get daysShort => 'd';

  @override
  String get hoursShort => 'h';

  @override
  String get minutesShort => 'min';

  @override
  String get notificationChannelName => 'Oglasi';

  @override
  String get notificationChannelDescription => 'Obavještenja o novim oglasima';

  @override
  String newAnnouncementsTitle({required String board, required int count}) {
    return '$board: novi oglasi ($count)';
  }

  @override
  String get search => 'Pretraga';

  @override
  String get noSearchResults => 'Nema rezultata pretrage';

  @override
  String get newBadge => 'Novo';

  @override
  String get share => 'Podijeli';

  @override
  String get copyText => 'Kopiraj tekst';

  @override
  String get copied => 'Tekst je kopiran';

  @override
  String get moreOptions => 'Više opcija';

  @override
  String unseenAnnouncements({required int count}) {
    return 'Nepročitani oglasi: $count';
  }

  @override
  String get previousWeek => 'Prethodna sedmica';

  @override
  String get nextWeek => 'Sljedeća sedmica';

  @override
  String get themeLight => 'Svijetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get themeSystem => 'Sistemska';

  @override
  String get about => 'O aplikaciji';

  @override
  String appVersion({required String version}) {
    return 'Verzija $version';
  }

  @override
  String get checkForUpdates => 'Provjeravaj nove verzije';

  @override
  String get checkForUpdatesDescription => 'Jednom sedmično, preko GitHub-a';

  @override
  String get checkNow => 'Provjeri sada';

  @override
  String get upToDate => 'Imate najnoviju verziju';

  @override
  String get updateCheckFailed => 'Provjera nove verzije nije uspjela';

  @override
  String get updateAvailableTitle => 'Nova verzija';

  @override
  String updateAvailableMessage({required String version}) {
    return 'Dostupna je verzija $version. Preuzmite APK sa GitHub stranice i instalirajte ga preko postojeće aplikacije – podešavanja i podaci ostaju.';
  }

  @override
  String get later => 'Kasnije';

  @override
  String get reportProblem => 'Prijavi problem';

  @override
  String get errorLog => 'Dnevnik grešaka';

  @override
  String get errorLogDescription =>
      'Greške se čuvaju samo na telefonu i nigdje se ne šalju. Možete ih kopirati uz prijavu problema.';

  @override
  String get errorLogEmpty => 'Nema zabilježenih grešaka';

  @override
  String get copy => 'Kopiraj';

  @override
  String get clear => 'Obriši';

  @override
  String get errorLogCopied => 'Dnevnik grešaka je kopiran';

  @override
  String get batteryTitle => 'Obavještenja ne stižu?';

  @override
  String get batteryMessage =>
      'Neki telefoni zaustavljaju aplikacije u pozadini radi uštede baterije. Isključite optimizaciju baterije za ovu aplikaciju.';

  @override
  String get batteryAllow => 'Isključi optimizaciju';

  @override
  String get moreInfo => 'Više informacija';

  @override
  String get linkOpenFailed => 'Link nije moguće otvoriti';

  @override
  String get expiredBadge => 'Isteklo';

  @override
  String get errorOffline => 'Nema internet konekcije';

  @override
  String get errorCertificate =>
      'Sigurna veza sa serverom fakulteta nije uspjela. Provjerite da su datum i vrijeme na telefonu tačni.';

  @override
  String get errorServer =>
      'Server fakulteta trenutno ne radi. Pokušajte kasnije.';

  @override
  String get addToCalendar => 'Dodaj u kalendar';

  @override
  String get calendarRepeatUntil => 'Ponavljaj do';

  @override
  String get calendarExportFailed => 'Izvoz u kalendar nije uspio';

  @override
  String get calendarFileSubject => 'Raspored nastave (kalendar)';

  @override
  String get bookmark => 'Sačuvaj';

  @override
  String get removeBookmark => 'Ukloni iz sačuvanih';

  @override
  String get bookmarks => 'Sačuvani oglasi';

  @override
  String get noBookmarks =>
      'Nemate sačuvanih oglasa.\nOglas sačuvajte iz menija ⋮ na kartici.';

  @override
  String get bookmarkSaved => 'Oglas je sačuvan';

  @override
  String get bookmarkRemoved => 'Oglas je uklonjen iz sačuvanih';

  @override
  String get bookmarkFailed => 'Čuvanje nije uspjelo';

  @override
  String get classReminder => 'Podsjetnik prije nastave';

  @override
  String get classReminderDescription => 'Za sačuvani raspored nastave';

  @override
  String get classReminderNoSchedule => 'Prvo sačuvajte raspored nastave';

  @override
  String classReminderMinutesBefore({required int minutes}) {
    return '$minutes min prije';
  }

  @override
  String classReminderTitle({required int minutes, required String subject}) {
    return 'Za $minutes min: $subject';
  }

  @override
  String get classReminderChannelName => 'Podsjetnici za nastavu';

  @override
  String get classReminderChannelDescription =>
      'Obavještenje prije početka časa';

  @override
  String get widgetNoSchedule => 'Izaberite raspored nastave u aplikaciji';

  @override
  String get widgetNoClasses => 'Nema nastave';

  @override
  String get widgetNow => 'Sada';

  @override
  String get widgetUntil => 'do';

  @override
  String get widgetNext => 'Zatim';

  @override
  String get widgetTomorrow => 'Sutra';

  @override
  String get widgetFree => 'Sada nema nastave';

  @override
  String get widgetNoMoreToday => 'Danas nema više nastave';

  @override
  String get widgetNoClassesToday => 'Danas nema nastave';
}
