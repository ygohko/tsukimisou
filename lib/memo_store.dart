/*
 * Copyright (c) 2022, 2026 Yasuaki Gohko
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'annotations.dart';
import 'memo.dart';

typedef ArchiveMemoStoreRequiredCallback = Future<MemoStore> Function(
    String name);

class ArchiveNotFoundException implements Exception {
  /// Message of this exception.
  final String message;

  /// Archive name that is not found.
  final String? name;

  /// Cause exception.
  final Exception? causeException;

  /// Cause stack trace.
  final StackTrace? causeStackTrace;

  /// Creates a archive not found exception.
  ArchiveNotFoundException(this.message,
      {this.name, this.causeException, this.causeStackTrace});

  @override
  String toString() {
    return 'ArchiveNotFoundException: $message, name: $name, causeException: $causeException, causeStackTrace: $causeStackTrace';
  }
}

class NotArchivedException implements Exception {
  /// Message of this exception.
  final String message;

  /// Archive name that is not found.
  final String? name;

  /// Cause exception.
  final Exception? causeException;

  /// Cause stack trace.
  final StackTrace? causeStackTrace;

  /// Creates a not archived exception.
  NotArchivedException(this.message,
      {this.name, this.causeException, this.causeStackTrace});

  @override
  String toString() {
    return 'NotArchivedException: $message, name: $name, causeException: $causeException, causeStackTrace: $causeStackTrace';
  }
}

class CallbackNotSetError extends Error {
  /// Message of this error.
  final String message;

  /// Creates a callback not set error.
  CallbackNotSetError(this.message);

  @override
  String toString() {
    return 'CallbackNotSetError: $message, stackTrace: $stackTrace';
  }
}

class MemoStore extends ChangeNotifier {
  /// Memos that are stored in this memo store.
  var memos = <Memo>[];

  /// Memo IDs that are removed.
  var removedMemoIds = <String>[];

  /// Epoch milliseconds from last merged.
  var lastMerged = 0;

  /// Hashes of archive memo stores.
  var archiveHashes = <String, String>{};

  /// Archive memo stores.
  @doNotSerialize
  var archiveMemoStores = <String, MemoStore>{};

  ArchiveMemoStoreRequiredCallback? _onArchiveMemoStoreRequired;

  /// Adds a memo to this memo store.
  void addMemo(Memo memo) {
    memos.add(memo);
    notifyListeners();
  }

  /// Removes a memo from this memo store.
  void removeMemo(Memo memo) {
    if (!memos.contains(memo)) {
      return;
    }
    if (!removedMemoIds.contains(memo.id)) {
      removedMemoIds.add(memo.id);
    }
    memos.remove(memo);
    notifyListeners();
  }

  /// Archives a memo.
  Future<MemoStore> archiveMemo(Memo memo) async {
    final lastModified = DateTime.fromMillisecondsSinceEpoch(memo.lastModified);
    final archiveName = lastModified.year.toString();
    MemoStore? archiveMemoStore;
    if (archiveHashes.containsKey(archiveName)) {
      archiveMemoStore = archiveMemoStores[archiveName];
      if (archiveMemoStore == null) {
        final callback = _onArchiveMemoStoreRequired;
        if (callback == null) {
          throw CallbackNotSetError('onArchiveMemoStoreRequired is not set.');
        }
        try {
          archiveMemoStore = await callback(archiveName);
        } on Exception catch (exception, stackTrace) {
          throw ArchiveNotFoundException('Could not find archive memo store.',
              name: archiveName,
              causeException: exception,
              causeStackTrace: stackTrace);
        }
        archiveMemoStores[archiveName] = archiveMemoStore;
      }
    } else {
      archiveMemoStore = MemoStore();
      archiveMemoStores[archiveName] = archiveMemoStore;
    }

    memo.archiveName = archiveName;
    archiveMemoStore.addMemo(memo);
    archiveHashes[archiveName] = archiveMemoStore.hash;
    removeMemo(memo);
    notifyListeners();

    return archiveMemoStore;
  }

  /// Unarchives a memo.
  Future<MemoStore> unarchiveMemo(Memo memo) async {
    final archiveName = memo.archiveName;
    if (archiveName == null) {
      throw NotArchivedException('This memo is not archived.');
    }
    var archiveMemoStore = archiveMemoStores[archiveName];
    if (archiveMemoStore == null) {
      final callback = _onArchiveMemoStoreRequired;
      if (callback == null) {
        throw CallbackNotSetError('onArchiveMemoStoreRequired is not set.');
      }
      archiveMemoStore = await callback(archiveName);
      archiveMemoStores[archiveName] = archiveMemoStore;
    }

    archiveMemoStore.removeMemo(memo);
    memo.archiveName = null;
    addMemo(memo);
    archiveHashes[archiveName] = archiveMemoStore.hash;
    notifyListeners();

    return archiveMemoStore;
  }

  /// Clears memos from this memo store.
  void clearMemos() {
    memos.clear();
    notifyListeners();
  }

  /// Removes a archive from this memo store.
  void removeArchive(String name) {
    if (archiveHashes.containsKey(name)) {
      archiveHashes.remove(name);
    }
    if (archiveMemoStores.containsKey(name)) {
      archiveMemoStores.remove(name);
    }
    notifyListeners();
  }

  /// Marks as changed.
  void markAsChanged() {
    notifyListeners();
  }

  /// Copy this memo store.
  MemoStore copy() {
    final result = MemoStore();
    for (final memo in memos) {
      result.memos.add(memo.copy());
    }
    result.removedMemoIds = [...removedMemoIds];
    result.lastMerged = lastMerged;
    result.archiveHashes = {...archiveHashes};
    archiveMemoStores.forEach((key, value) {
      result.archiveMemoStores[key] = value.copy();
    });

    return result;
  }

  /// Returns a JSON serializable object.
  dynamic toSerializable() {
    final serializableMemos = [];
    for (var i = 0; i < memos.length; i++) {
      serializableMemos.add(memos[i].toSerializable());
    }
    return {
      'version': 4,
      'memos': serializableMemos,
      'lastMerged': lastMerged,
      'removedMemoIds': removedMemoIds,
      'archiveHashes': archiveHashes,
    };
  }

  /// Memo that has given ID.
  Memo? memoFromId(String id) {
    for (var memo in memos) {
      if (memo.id == id) {
        return memo;
      }
    }

    return null;
  }

  /// Memo that has given name.
  Memo? memoFromName(String name) {
    for (var memo in memos) {
      if (memo.name == name) {
        return memo;
      }
    }

    return null;
  }

  /// Archive that has given name.
  Future<MemoStore> archiveMemoStore(String name) async {
    if (!archiveHashes.containsKey(name)) {
      throw ArchiveNotFoundException('Archive not found');
    }

    var archiveMemoStore = archiveMemoStores[name];
    if (archiveMemoStore == null) {
      final callback = _onArchiveMemoStoreRequired;
      if (callback == null) {
        throw CallbackNotSetError('onArchiveMemoStoreRequired is not set.');
      }
      archiveMemoStore = await callback(name);
      archiveMemoStores[name] = archiveMemoStore;
    }

    return archiveMemoStore;
  }

  /// Archive that has given name.
  MemoStore? archiveMemoStoreIfLoaded(String name) {
    if (!archiveHashes.containsKey(name)) {
      throw ArchiveNotFoundException('Archive not found');
    }

    return archiveMemoStores[name];
  }

  /// Tags bound for memos
  List<String> get tags {
    var tags = <String>[];
    for (final memo in memos) {
      for (final tag in memo.tags) {
        if (!tags.contains(tag)) {
          tags.add(tag);
        }
      }
    }

    return tags;
  }

  /// Returns a hash of this memo store.
  String get hash {
    final jsonString = json.encode(toSerializable());
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  set onArchiveMemoStoreRequired(ArchiveMemoStoreRequiredCallback? callback) {
    _onArchiveMemoStoreRequired = callback;
  }
}
