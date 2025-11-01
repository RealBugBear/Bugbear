import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
  ];

  static Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      _lookupAppLocalizations(locale),
    );
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get appName;
  String get coreHeaderTitle;
  String get coreHeaderGoldenDayChip;
  String get coreHeaderSemanticsLabel;
  String coreHeaderSemanticsValue(int percent);
  String coreHeaderWindowSummary(String period, String percent);
  String coreHeaderWindowRange(String start, String end);
  String get coreWeekdayShortMonday;
  String get coreWeekdayShortTuesday;
  String get coreWeekdayShortWednesday;
  String get coreWeekdayShortThursday;
  String get coreWeekdayShortFriday;
  String get coreWeekdayShortSaturday;
  String get coreWeekdayShortSunday;
  String coreDaySemanticsDate(String date);
  String get coreDaySemanticsToday;
  String get coreDaySemanticsTrainingPlanned;
  String get coreDaySemanticsTrainingNotPlanned;
  String get coreDaySemanticsCompleted;
  String get coreDaySemanticsHasReflection;
  String get coreDayTapHint;
  String get coreDayLongPressHint;
  String get coreStatsPlannedLabel;
  String get coreStatsCompletedLabel;
  String get coreStatsReflectionsLabel;
  String coreSemanticsLabelValue(String label, String value);
  String get coreTrainingActionsLabel;
  String get coreTrainingStartButton;
  String get coreTrainingPlanNextWeekButton;
  String coreReflectionCardLabel(int count);
  String coreReflectionCardMessage(int count);
  String get coreReflectionCardHint;
  String get coreReflectionCardOpenButton;
  String coreDetailsTitle(String date);
  String get coreDetailsTrainingPlannedLabel;
  String get coreDetailsCompletedLabel;
  String get coreDetailsGoldenDayLabel;
  String get coreDetailsReflectionLabel;
  String get coreDetailsYes;
  String get coreDetailsNo;
  String get coreDetailsGoldenDayMarked;
  String get coreDetailsGoldenDayNotMarked;
  String get coreDetailsReflectionAvailable;
  String get coreDetailsReflectionMissing;
  String get coreDetailsReflectionTip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((Locale supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
    default:
      return AppLocalizationsEn();
  }
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appName => 'Free Base';

  @override
  String get coreHeaderTitle => 'This week';

  @override
  String get coreHeaderGoldenDayChip => 'Golden day spotted';

  @override
  String get coreHeaderSemanticsLabel => 'Weekly progress';

  @override
  String coreHeaderSemanticsValue(int percent) => 'Progress $percent percent';

  @override
  String coreHeaderWindowSummary(String period, String percent) =>
      '$period · $percent%';

  @override
  String coreHeaderWindowRange(String start, String end) => '$start – $end';

  @override
  String get coreWeekdayShortMonday => 'Mon';

  @override
  String get coreWeekdayShortTuesday => 'Tue';

  @override
  String get coreWeekdayShortWednesday => 'Wed';

  @override
  String get coreWeekdayShortThursday => 'Thu';

  @override
  String get coreWeekdayShortFriday => 'Fri';

  @override
  String get coreWeekdayShortSaturday => 'Sat';

  @override
  String get coreWeekdayShortSunday => 'Sun';

  @override
  String coreDaySemanticsDate(String date) => 'Day $date';

  @override
  String get coreDaySemanticsToday => 'today';

  @override
  String get coreDaySemanticsTrainingPlanned => 'training scheduled';

  @override
  String get coreDaySemanticsTrainingNotPlanned => 'no training scheduled';

  @override
  String get coreDaySemanticsCompleted => 'completed';

  @override
  String get coreDaySemanticsHasReflection => 'reflection available';

  @override
  String get coreDayTapHint => 'Tap for details';

  @override
  String get coreDayLongPressHint => 'Press and hold for details';

  @override
  String get coreStatsPlannedLabel => 'Scheduled';

  @override
  String get coreStatsCompletedLabel => 'Completed';

  @override
  String get coreStatsReflectionsLabel => 'Reflections pending';

  @override
  String coreSemanticsLabelValue(String label, String value) =>
      '$label: $value';

  @override
  String get coreTrainingActionsLabel => 'Training actions';

  @override
  String get coreTrainingStartButton => 'Start training';

  @override
  String get coreTrainingPlanNextWeekButton => 'Plan next week';

  @override
  String coreReflectionCardLabel(int count) => Intl.pluralLogic(
        count,
        locale: localeName,
        one: 'One reflection pending',
        other: '$count reflections pending',
      );

  @override
  String coreReflectionCardMessage(int count) => Intl.pluralLogic(
        count,
        locale: localeName,
        one: 'One reflection pending. Catch up now?',
        other: '$count reflections pending. Catch up now?',
      );

  @override
  String get coreReflectionCardHint => 'Tap to open reflection';

  @override
  String get coreReflectionCardOpenButton => 'Open';

  @override
  String coreDetailsTitle(String date) => 'Details for $date';

  @override
  String get coreDetailsTrainingPlannedLabel => 'Training scheduled';

  @override
  String get coreDetailsCompletedLabel => 'Completed';

  @override
  String get coreDetailsGoldenDayLabel => 'Golden day';

  @override
  String get coreDetailsReflectionLabel => 'Reflection';

  @override
  String get coreDetailsYes => 'Yes';

  @override
  String get coreDetailsNo => 'No';

  @override
  String get coreDetailsGoldenDayMarked => 'Marked';

  @override
  String get coreDetailsGoldenDayNotMarked => 'Not marked';

  @override
  String get coreDetailsReflectionAvailable => 'Available';

  @override
  String get coreDetailsReflectionMissing => 'Missing';

  @override
  String get coreDetailsReflectionTip => 'Tip: Reflection still pending.';
}

class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe() : super('de');

  @override
  String get appName => 'Free Base';

  @override
  String get coreHeaderTitle => 'Diese Woche';

  @override
  String get coreHeaderGoldenDayChip => 'Golden Day gesichtet';

  @override
  String get coreHeaderSemanticsLabel => 'Wochenfortschritt';

  @override
  String coreHeaderSemanticsValue(int percent) =>
      'Fortschritt $percent Prozent';

  @override
  String coreHeaderWindowSummary(String period, String percent) =>
      '$period · $percent%';

  @override
  String coreHeaderWindowRange(String start, String end) => '$start – $end';

  @override
  String get coreWeekdayShortMonday => 'Mo';

  @override
  String get coreWeekdayShortTuesday => 'Di';

  @override
  String get coreWeekdayShortWednesday => 'Mi';

  @override
  String get coreWeekdayShortThursday => 'Do';

  @override
  String get coreWeekdayShortFriday => 'Fr';

  @override
  String get coreWeekdayShortSaturday => 'Sa';

  @override
  String get coreWeekdayShortSunday => 'So';

  @override
  String coreDaySemanticsDate(String date) => 'Tag $date';

  @override
  String get coreDaySemanticsToday => 'heute';

  @override
  String get coreDaySemanticsTrainingPlanned => 'Training geplant';

  @override
  String get coreDaySemanticsTrainingNotPlanned => 'Kein Training geplant';

  @override
  String get coreDaySemanticsCompleted => 'abgeschlossen';

  @override
  String get coreDaySemanticsHasReflection => 'Reflexion vorhanden';

  @override
  String get coreDayTapHint => 'Tippen für Details';

  @override
  String get coreDayLongPressHint => 'Gedrückt halten für Details';

  @override
  String get coreStatsPlannedLabel => 'Geplant';

  @override
  String get coreStatsCompletedLabel => 'Abgeschlossen';

  @override
  String get coreStatsReflectionsLabel => 'Reflexion offen';

  @override
  String coreSemanticsLabelValue(String label, String value) =>
      '$label: $value';

  @override
  String get coreTrainingActionsLabel => 'Training Aktionen';

  @override
  String get coreTrainingStartButton => 'Training starten';

  @override
  String get coreTrainingPlanNextWeekButton => 'Nächste Woche planen';

  @override
  String coreReflectionCardLabel(int count) => Intl.pluralLogic(
        count,
        locale: localeName,
        one: 'Eine Reflexion ausstehend',
        other: '$count Reflexionen ausstehend',
      );

  @override
  String coreReflectionCardMessage(int count) => Intl.pluralLogic(
        count,
        locale: localeName,
        one: 'Eine Reflexion ausstehend. Jetzt nachbereiten?',
        other: '$count Reflexionen ausstehend. Jetzt nachbereiten?',
      );

  @override
  String get coreReflectionCardHint => 'Tippen um Reflexion zu öffnen';

  @override
  String get coreReflectionCardOpenButton => 'Öffnen';

  @override
  String coreDetailsTitle(String date) => 'Details für $date';

  @override
  String get coreDetailsTrainingPlannedLabel => 'Training geplant';

  @override
  String get coreDetailsCompletedLabel => 'Abgeschlossen';

  @override
  String get coreDetailsGoldenDayLabel => 'Golden Day';

  @override
  String get coreDetailsReflectionLabel => 'Reflexion';

  @override
  String get coreDetailsYes => 'Ja';

  @override
  String get coreDetailsNo => 'Nein';

  @override
  String get coreDetailsGoldenDayMarked => 'Markiert';

  @override
  String get coreDetailsGoldenDayNotMarked => 'Nicht markiert';

  @override
  String get coreDetailsReflectionAvailable => 'Vorhanden';

  @override
  String get coreDetailsReflectionMissing => 'Fehlt';

  @override
  String get coreDetailsReflectionTip => 'Tipp: Reflexion noch ausstehend.';
}
