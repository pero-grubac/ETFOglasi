import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn')
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
  /// **'Izaberite rasporeda'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr': {
  switch (locale.scriptCode) {
    case 'Cyrl': return AppLocalizationsSrCyrl();
case 'Latn': return AppLocalizationsSrLatn();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'sr': return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
