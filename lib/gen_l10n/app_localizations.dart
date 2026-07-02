import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ja')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Tsukimisou'**
  String get tsukimisou;

  /// Tooltip for search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Text for drawer header in home page
  ///
  /// In en, this message translates to:
  /// **'Showing {shownMemosCount} memos\nTotal {memosCount} memos and {tagsCount} tags'**
  String showingMemos(
      Object shownMemosCount, Object memosCount, Object tagsCount);

  /// Text for disable filtering list tile
  ///
  /// In en, this message translates to:
  /// **'All memos'**
  String get allMemos;

  /// Indicattion for update date and time
  ///
  /// In en, this message translates to:
  /// **'Updated: {dateTime}'**
  String updated(Object dateTime);

  /// Indicattion for memos that is not synchronized
  ///
  /// In en, this message translates to:
  /// **'Unsynchronized'**
  String get unsynchronized;

  /// Indicattion for memos that is archived
  ///
  /// In en, this message translates to:
  /// **'In archive {name}'**
  String inArchive(Object name);

  /// Tooltip for add a memo button
  ///
  /// In en, this message translates to:
  /// **'Add a memo'**
  String get addAMemo;

  /// Indicator text when there no memos in home page
  ///
  /// In en, this message translates to:
  /// **'To create a new memo, press Add a memo button'**
  String get toCreateANewMemo;

  /// Subtitle for tags group of drawer
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Subtitle for Google Drive integration group of drawer
  ///
  /// In en, this message translates to:
  /// **'Google Drive integration'**
  String get googleDriveIntegration;

  /// Text for synchronize list tile
  ///
  /// In en, this message translates to:
  /// **'Synchronize'**
  String get synchronize;

  /// Subtitle for others group of drawer
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// Text for settings list tile and app bar
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Text for hide Google Drive integration list tile
  ///
  /// In en, this message translates to:
  /// **'Hide Google Drive integration'**
  String get hideGoogleDriveIntegration;

  /// Text for about list tile
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Text for privacy policy list tile
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// Text for banner when shown in synchronizing.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing...'**
  String get synchronizing;

  /// Button text for dismiss button in synchronizing banner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Title for memo store locked error dialog.
  ///
  /// In en, this message translates to:
  /// **'Memo store is locked'**
  String get memoStoreIsLocked;

  /// Text for memo store locked error dialog.
  ///
  /// In en, this message translates to:
  /// **'Memo store is locked by other device. Please try again later.'**
  String get memoStoreIsLockedByOtherDevice;

  /// Text for memo store unlocking confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Memo store is still locked but if there are no synchronizing devices you can also force unlock. Do you want to unlock?'**
  String get memoStoreIsStillLocked;

  /// Text for unlock button
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Title for synchronization error dialog.
  ///
  /// In en, this message translates to:
  /// **'Synchronization was failed'**
  String get synchronizationWasFailed;

  /// Text for synchronization error dialog.
  ///
  /// In en, this message translates to:
  /// **'Could not synchronize with Google Drive.'**
  String get couldNotSynchronizeWithGoogleDrive;

  /// Text to indicate this memo has confilicts.
  ///
  /// In en, this message translates to:
  /// **'This memo has conflicts.'**
  String get thisMemoHasConflicts;

  /// Text for local markers
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// Text for cloud markers
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloud;

  /// Title for loading error dialog.
  ///
  /// In en, this message translates to:
  /// **'Loading was failed'**
  String get loadingWasFailed;

  /// Text for Google Drive loading error dialog.
  ///
  /// In en, this message translates to:
  /// **'Could not load memo store from Google Drive.'**
  String get couldNotLoadMemoStoreFromGoogleDrive;

  /// Title for saving error dialog.
  ///
  /// In en, this message translates to:
  /// **'Saving was failed'**
  String get savingWasFailed;

  /// Text for local saving error dialog.
  ///
  /// In en, this message translates to:
  /// **'Could not save memo store to local storage.'**
  String get couldNotSaveMemoStoreToLocalStorage;

  /// Text for Google Drive saving error dialog.
  ///
  /// In en, this message translates to:
  /// **'Could not save memo store to Google Drive.'**
  String get couldNotSaveMemoStoreToGoogleDrive;

  /// Title for local version error dialog.
  ///
  /// In en, this message translates to:
  /// **'Memo store is not compatible'**
  String get memoStoreIsNotCompatible;

  /// Text for local version error dialog.
  ///
  /// In en, this message translates to:
  /// **'Memo store in the local storage is not compatible. Updating this app may solve the issue.'**
  String get memoStoreInTheLocalStorageIsNotCompatible;

  /// No description provided for @memoStoreOnTheGoogleDriveIsNotCompatible.
  ///
  /// In en, this message translates to:
  /// **'Memo store on the Google Drive is not compatible. Updating this app may solve the issue.'**
  String get memoStoreOnTheGoogleDriveIsNotCompatible;

  /// Title for linked memo not found error dialog.
  ///
  /// In en, this message translates to:
  /// **'Memo not found'**
  String get memoNotFound;

  /// Text for linked memo not found error dialog.
  ///
  /// In en, this message translates to:
  /// **'Linked memo is not found.'**
  String get linkedMemoIsNotFound;

  /// Title for archive not found error dialog.
  ///
  /// In en, this message translates to:
  /// **'Archive not found'**
  String get archiveNotFound;

  /// Text for archive not found error dialog.
  ///
  /// In en, this message translates to:
  /// **'Could not load archive memo store from local storage.'**
  String get cloudNotLoadArchiveMemoStoreFromLocalStorage;

  /// Title for unarchiving failed error dialog.
  ///
  /// In en, this message translates to:
  /// **'Unarchiving was failed'**
  String get unarchivingWasFailed;

  /// Text for unarchiving failed error dialog.
  ///
  /// In en, this message translates to:
  /// **'Could not unarchive memo.'**
  String get couldNotUnarchiveMemo;

  /// Text for tags list tile
  ///
  /// In en, this message translates to:
  /// **'Tags: {tags}'**
  String boundTags(Object tags);

  /// Text for name list tile
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String name(Object name);

  /// Text for viewing mode list tile
  ///
  /// In en, this message translates to:
  /// **'Viewing mode: {viewingMode}'**
  String viewingMode(Object viewingMode);

  /// Tooltip for Back to previous memo button
  ///
  /// In en, this message translates to:
  /// **'Back to previous memo'**
  String get backToPreviousMemo;

  /// Tooltip for Full screen button
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get fullScreen;

  /// Tooltip for Exit full screen button
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get exitFullScreen;

  /// Tooltip for Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Tooltip for Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Tooltip for Archive button
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Tooltip for Unarchive button
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// Tooltip for Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Subject when sharing a memo
  ///
  /// In en, this message translates to:
  /// **'Shared from Tukimisou'**
  String get sharedFromTsukimisou;

  /// Snack bar text when memo is archived.
  ///
  /// In en, this message translates to:
  /// **'Memo archived.'**
  String get memoArchived;

  /// Snack bar text when memo is unarchived.
  ///
  /// In en, this message translates to:
  /// **'Memo unarchived.'**
  String get memoUnarchived;

  /// Snack bar text when memo is deleted.
  ///
  /// In en, this message translates to:
  /// **'Memo deleted.'**
  String get memoDeleted;

  /// Title for error dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Title for delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete this memo?'**
  String get deleteThisMemo;

  /// Text for dialog when showing before destructive actions.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// Text for Copy exception button
  ///
  /// In en, this message translates to:
  /// **'Copy exception'**
  String get copyException;

  /// Text for remove this archive button
  ///
  /// In en, this message translates to:
  /// **'Remove this archive'**
  String get removeThisArchive;

  /// Text for Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text for OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Title for editing page when editing a new memo
  ///
  /// In en, this message translates to:
  /// **'Add a new memo'**
  String get addANewMemo;

  /// Title for editing page when editing a existing memo
  ///
  /// In en, this message translates to:
  /// **'Edit a memo'**
  String get editAMemo;

  /// Tooltip for Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title for discard confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Discard this changes?'**
  String get discardThisChanges;

  /// Title for modify the name dialog
  ///
  /// In en, this message translates to:
  /// **'Modify the name'**
  String get modifyTheName;

  /// Hint text for memo name text field
  ///
  /// In en, this message translates to:
  /// **'Enter the memo name'**
  String get enterTheMemoName;

  /// Error text for memo name text field
  ///
  /// In en, this message translates to:
  /// **'Name already exists.'**
  String get nameAlreadyExists;

  /// Title for binding tags page
  ///
  /// In en, this message translates to:
  /// **'Bind tags'**
  String get bindTags;

  /// Text for list tile to add a new tag
  ///
  /// In en, this message translates to:
  /// **'Add a new tag...'**
  String get addANewTag;

  /// Title for tag adding dialog
  ///
  /// In en, this message translates to:
  /// **'Add a new tag'**
  String get addANewTagTitle;

  /// Decoration for tag text field
  ///
  /// In en, this message translates to:
  /// **'Enter a tag name'**
  String get enterATagName;

  /// Snack bar text when tag already exists
  ///
  /// In en, this message translates to:
  /// **'That tag already exists.'**
  String get thatTagAlreadyExists;

  /// Snack bar text when unnamed tag is to be added
  ///
  /// In en, this message translates to:
  /// **'Can not add unnamed tag.'**
  String get canNotAddUnnamedTag;

  /// Hint text for search text field
  ///
  /// In en, this message translates to:
  /// **'Search memos'**
  String get searchMemos;

  /// App bar title for searching page
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// Indicator text when memos are not found for searching page
  ///
  /// In en, this message translates to:
  /// **'No memos found'**
  String get noMemosFound;

  /// Text for Open as URL context menu item
  ///
  /// In en, this message translates to:
  /// **'Open as URL'**
  String get openAsUrl;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
