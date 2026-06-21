// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tsukimisou => 'Tsukimisou';

  @override
  String get search => 'Search';

  @override
  String showingMemos(
      Object shownMemosCount, Object memosCount, Object tagsCount) {
    return 'Showing $shownMemosCount memos\nTotal $memosCount memos and $tagsCount tags';
  }

  @override
  String get allMemos => 'All memos';

  @override
  String updated(Object dateTime) {
    return 'Updated: $dateTime';
  }

  @override
  String get unsynchronized => 'Unsynchronized';

  @override
  String get addAMemo => 'Add a memo';

  @override
  String get toCreateANewMemo =>
      'To create a new memo, press Add a memo button';

  @override
  String get tags => 'Tags';

  @override
  String get googleDriveIntegration => 'Google Drive integration';

  @override
  String get synchronize => 'Synchronize';

  @override
  String get others => 'Others';

  @override
  String get settings => 'Settings';

  @override
  String get hideGoogleDriveIntegration => 'Hide Google Drive integration';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get synchronizing => 'Synchronizing...';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get memoStoreIsLocked => 'Memo store is locked';

  @override
  String get memoStoreIsLockedByOtherDevice =>
      'Memo store is locked by other device. Please try again later.';

  @override
  String get memoStoreIsStillLocked =>
      'Memo store is still locked but if there are no synchronizing devices you can also force unlock. Do you want to unlock?';

  @override
  String get unlock => 'Unlock';

  @override
  String get synchronizationWasFailed => 'Synchronization was failed';

  @override
  String get couldNotSynchronizeWithGoogleDrive =>
      'Could not synchronize with Google Drive.';

  @override
  String get thisMemoHasConflicts => 'This memo has conflicts.';

  @override
  String get local => 'Local';

  @override
  String get cloud => 'Cloud';

  @override
  String get loadingWasFailed => 'Loading was failed';

  @override
  String get couldNotLoadMemoStoreFromGoogleDrive =>
      'Could not load memo store from Google Drive.';

  @override
  String get savingWasFailed => 'Saving was failed';

  @override
  String get couldNotSaveMemoStoreToLocalStorage =>
      'Could not save memo store to local storage.';

  @override
  String get couldNotSaveMemoStoreToGoogleDrive =>
      'Could not save memo store to Google Drive.';

  @override
  String get memoStoreIsNotCompatible => 'Memo store is not compatible';

  @override
  String get memoStoreInTheLocalStorageIsNotCompatible =>
      'Memo store in the local storage is not compatible. Updating this app may solve the issue.';

  @override
  String get memoStoreOnTheGoogleDriveIsNotCompatible =>
      'Memo store on the Google Drive is not compatible. Updating this app may solve the issue.';

  @override
  String get memoNotFound => 'Memo not found';

  @override
  String get linkedMemoIsNotFound => 'Linked memo is not found.';

  @override
  String get archiveNotFound => 'Archive not found';

  @override
  String get cloudNotLoadArchiveMemoStoreFromLocalStorage =>
      'Could not load archive memo store from local storage.';

  @override
  String boundTags(Object tags) {
    return 'Tags: $tags';
  }

  @override
  String name(Object name) {
    return 'Name: $name';
  }

  @override
  String viewingMode(Object viewingMode) {
    return 'Viewing mode: $viewingMode';
  }

  @override
  String get backToPreviousMemo => 'Back to previous memo';

  @override
  String get fullScreen => 'Full screen';

  @override
  String get exitFullScreen => 'Exit full screen';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get archive => 'Archive';

  @override
  String get edit => 'Edit';

  @override
  String get sharedFromTsukimisou => 'Shared from Tukimisou';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteThisMemo => 'Delete this memo?';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get copyException => 'Copy exception';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get addANewMemo => 'Add a new memo';

  @override
  String get editAMemo => 'Edit a memo';

  @override
  String get save => 'Save';

  @override
  String get discardThisChanges => 'Discard this changes?';

  @override
  String get modifyTheName => 'Modify the name';

  @override
  String get enterTheMemoName => 'Enter the memo name';

  @override
  String get nameAlreadyExists => 'Name already exists.';

  @override
  String get bindTags => 'Bind tags';

  @override
  String get addANewTag => 'Add a new tag...';

  @override
  String get addANewTagTitle => 'Add a new tag';

  @override
  String get enterATagName => 'Enter a tag name';

  @override
  String get thatTagAlreadyExists => 'That tag already exists.';

  @override
  String get canNotAddUnnamedTag => 'Can not add unnamed tag.';

  @override
  String get searchMemos => 'Search memos';

  @override
  String get searchTitle => 'Search';

  @override
  String get noMemosFound => 'No memos found';

  @override
  String get openAsUrl => 'Open as URL';
}
