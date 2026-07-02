// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get tsukimisou => 'Tsukimisou';

  @override
  String get search => '検索';

  @override
  String showingMemos(
      Object shownMemosCount, Object memosCount, Object tagsCount) {
    return '$shownMemosCount件のメモを表示中\n全$memosCount件のメモと全$tagsCount個のタグ';
  }

  @override
  String get allMemos => 'すべてのメモ';

  @override
  String updated(Object dateTime) {
    return '更新: $dateTime';
  }

  @override
  String get unsynchronized => '未同期';

  @override
  String inArchive(Object name) {
    return 'アーカイブ $name内';
  }

  @override
  String get addAMemo => 'メモを追加';

  @override
  String get toCreateANewMemo => 'メモを追加ボタンを押して、新しいメモを作成してください';

  @override
  String get tags => 'タグ';

  @override
  String get googleDriveIntegration => 'Google Drive連携';

  @override
  String get synchronize => '同期';

  @override
  String get others => 'その他';

  @override
  String get settings => '設定';

  @override
  String get hideGoogleDriveIntegration => 'Google Drive連携を隠す';

  @override
  String get about => 'このアプリについて';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get synchronizing => '同期中...';

  @override
  String get dismiss => '表示しない';

  @override
  String get memoStoreIsLocked => 'メモストアがロックされています';

  @override
  String get memoStoreIsLockedByOtherDevice =>
      'メモストアが他のデバイスにロックされています。後ほど再度お試しください。';

  @override
  String get memoStoreIsStillLocked =>
      'メモストアはまだロックされていますが、他のデバイスが同期中ではないのなら強制的にロック解除することもできます。ロック解除しますか?';

  @override
  String get unlock => 'ロック解除';

  @override
  String get synchronizationWasFailed => '同期に失敗しました';

  @override
  String get couldNotSynchronizeWithGoogleDrive =>
      'メモストアのGoogle Driveとの同期ができませんでした。';

  @override
  String get thisMemoHasConflicts => 'このメモには衝突があります。';

  @override
  String get local => 'ローカル';

  @override
  String get cloud => 'クラウド';

  @override
  String get loadingWasFailed => '読み込みに失敗しました';

  @override
  String get couldNotLoadMemoStoreFromGoogleDrive =>
      'メモストアのGoogle Driveからの読み込みができませんでした。';

  @override
  String get savingWasFailed => '保存に失敗しました';

  @override
  String get couldNotSaveMemoStoreToLocalStorage =>
      'メモストアのローカルストレージへの保存ができませんでした。';

  @override
  String get couldNotSaveMemoStoreToGoogleDrive =>
      'メモストアのGoogle Driveへの保存ができませんでした。';

  @override
  String get memoStoreIsNotCompatible => 'メモストアに互換性がありません';

  @override
  String get memoStoreInTheLocalStorageIsNotCompatible =>
      'ローカルストレージ内のメモストアに互換性がありません。このアプリをアップデートすることで問題が解決するかもしれません。';

  @override
  String get memoStoreOnTheGoogleDriveIsNotCompatible =>
      'Google Drive上のメモストアに互換性がありません。このアプリをアップデートすることで問題が解決するかもしれません。';

  @override
  String get memoNotFound => 'メモが見つかりません';

  @override
  String get linkedMemoIsNotFound => 'リンク先のメモが見つかりません。';

  @override
  String get archiveNotFound => 'アーカイブがみつかりません';

  @override
  String get cloudNotLoadArchiveMemoStoreFromLocalStorage =>
      'アーカイブのメモストアのローカルストレージからの読み込みができませんでした。';

  @override
  String get unarchivingWasFailed => 'アーカイブ解除に失敗しました';

  @override
  String get couldNotUnarchiveMemo => 'メモのアーカイブ解除ができませんでした。';

  @override
  String boundTags(Object tags) {
    return 'タグ: $tags';
  }

  @override
  String name(Object name) {
    return '名前: $name';
  }

  @override
  String viewingMode(Object viewingMode) {
    return '表示モード: $viewingMode';
  }

  @override
  String get backToPreviousMemo => '前のメモに戻る';

  @override
  String get fullScreen => 'フルスクリーン';

  @override
  String get exitFullScreen => 'フルスクリーンを終了';

  @override
  String get share => '共有';

  @override
  String get delete => '削除';

  @override
  String get archive => 'アーカイブ';

  @override
  String get unarchive => 'アーカイブ解除';

  @override
  String get edit => '編集';

  @override
  String get sharedFromTsukimisou => 'Tukimisouからの共有';

  @override
  String get memoArchived => 'メモをアーカイブしました。';

  @override
  String get memoUnarchived => 'メモをアーカイブ解除しました。';

  @override
  String get memoDeleted => 'メモを削除しました。';

  @override
  String get confirm => '確認';

  @override
  String get deleteThisMemo => 'このメモを削除しますか?';

  @override
  String get thisActionCannotBeUndone => 'この操作は元に戻せません。';

  @override
  String get copyException => '例外をコピー';

  @override
  String get removeThisArchive => 'このアーカイブを削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get error => 'エラー';

  @override
  String get addANewMemo => '新しいメモを追加';

  @override
  String get editAMemo => 'メモを編集';

  @override
  String get save => '保存';

  @override
  String get discardThisChanges => 'この変更を破棄しますか?';

  @override
  String get modifyTheName => '名前を変更';

  @override
  String get enterTheMemoName => 'メモの名前を入力';

  @override
  String get nameAlreadyExists => 'この名前はすでにあります。';

  @override
  String get bindTags => 'タグ付け';

  @override
  String get addANewTag => '新しいタグを追加...';

  @override
  String get addANewTagTitle => '新しいタグを追加';

  @override
  String get enterATagName => 'タグ名を入力する';

  @override
  String get thatTagAlreadyExists => 'このタグはすでにあります。';

  @override
  String get canNotAddUnnamedTag => '名前のないタグは追加できません。';

  @override
  String get searchMemos => 'メモを検索';

  @override
  String get searchTitle => '検索';

  @override
  String get noMemosFound => 'メモが見つかりません';

  @override
  String get openAsUrl => 'URLとして開く';
}
