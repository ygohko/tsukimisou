/*
 * Copyright (c) 2022 Yasuaki Gohko
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
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client_id.dart';
import 'extensions.dart';

class GoogleDriveFile {
  final String _fileName;

  /// Constructs a Google Drive file.
  GoogleDriveFile(this._fileName);

  /// Writes contents as a string.
  Future<void> writeAsString(String contents) async {
    late _AuthenticatableClient client;
    const platform = LocalPlatform();
    if (platform.isDesktop) {
      client = _AuthenticatableDesktopClient();
    } else {
      client = _AuthenticatableMobileClient();
    }
    await client.authenticate();
    final driveApi = DriveApi(client);
    var directoryId = await _directoryId(driveApi);
    // Make a directory if it is not found.
    directoryId ??= await _createDirectory(driveApi);
    final fileIds = await _fileIds(driveApi, _fileName);
    for (var fileId in fileIds) {
      // Delete old files.
      await driveApi.files.delete(fileId);
    }

    final encoded = utf8.encode(contents);
    final stream = Future.value(encoded).asStream().asBroadcastStream();
    final media = Media(stream, encoded.length);
    final file = File();
    file.name = _fileName;
    file.parents = <String>[directoryId];
    await driveApi.files.create(file, uploadMedia: media);
    client.close();
  }

  /// Reads contents as a string.
  Future<String> readAsString() async {
    late _AuthenticatableClient client;
    const platform = LocalPlatform();
    if (platform.isDesktop) {
      client = _AuthenticatableDesktopClient();
    } else {
      client = _AuthenticatableMobileClient();
    }
    await client.authenticate();
    final driveApi = DriveApi(client);
    // Find a file
    final fileIds = await _fileIds(driveApi, _fileName);
    if (fileIds.isEmpty) {
      // File not found.
      throw const HttpException('File not found.');
    }

    final media = await driveApi.files
        .get(fileIds[0], downloadOptions: DownloadOptions.fullMedia) as Media;
    var values = <int>[];
    await media.stream.forEach((element) {
      values += element;
    });
    final string = utf8.decode(values);
    client.close();

    return string;
  }

  /// Reads contents as a string with locking.
  Future<String> readAsStringLocked() async {
    late _AuthenticatableClient client;
    const platform = LocalPlatform();
    if (platform.isDesktop) {
      client = _AuthenticatableDesktopClient();
    } else {
      client = _AuthenticatableMobileClient();
    }
    await client.authenticate();
    final lockedFileName = '$_fileName.locked';
    final driveApi = DriveApi(client);
    // Find a file.
    final fileIds = await _fileIds(driveApi, _fileName);
    if (fileIds.isEmpty) {
      // Find a locked file.
      final lockedFileIds = await _fileIds(driveApi, lockedFileName);
      if (lockedFileIds.isEmpty) {
        // File not found.
        throw FileNotFoundException('File not found.');
      } else {
        // File locked.
        throw FileLockedException('File locked.');
      }
    }

    // Rename a file to lock
    final file = File(name: lockedFileName);
    await driveApi.files.update(file, fileIds[0]);
    final media = await driveApi.files
        .get(fileIds[0], downloadOptions: DownloadOptions.fullMedia) as Media;
    var values = <int>[];
    await media.stream.forEach((element) {
      values += element;
    });
    final string = utf8.decode(values);
    // Rename a file to unlock.
    final aFile = File(name: _fileName);
    await driveApi.files.update(aFile, fileIds[0]);
    client.close();

    return string;
  }

  /// Unlock this file.
  Future<void> unlock() async {
    late _AuthenticatableClient client;
    const platform = LocalPlatform();
    if (platform.isDesktop) {
      client = _AuthenticatableDesktopClient();
    } else {
      client = _AuthenticatableMobileClient();
    }
    await client.authenticate();
    final lockedFileName = '$_fileName.locked';
    final driveApi = DriveApi(client);
    // Find a file.
    final lockedFileIds = await _fileIds(driveApi, lockedFileName);
    if (lockedFileIds.isEmpty) {
      // File not found.
      throw FileNotFoundException('File not found.');
    }

    // Rename a file to unlock.
    final file = File(name: _fileName);
    await driveApi.files.update(file, lockedFileIds[0]);
    client.close();
  }

  Future<String> _createDirectory(DriveApi driveApi) async {
    var file = File();
    file.name = 'Tsukimisou';
    file.mimeType = "application/vnd.google-apps.folder";
    file = await driveApi.files.create(file);

    return file.id!;
  }

  static Future<String?> _directoryId(DriveApi driveApi) async {
    var result = await driveApi.files.list(
        q: 'name = "Tsukimisou" and "root" in parents and trashed = false');
    var files = result.files;
    if (files == null) {
      throw const HttpException('API does not return directories.');
    }
    if (files.isEmpty) {
      return null;
    }
    final directoryId = files[0].id;
    if (directoryId == null) {
      return null;
    }

    return directoryId;
  }

  static Future<List<String>> _fileIds(
      DriveApi driveApi, String fileName) async {
    final directoryId = await _directoryId(driveApi);
    if (directoryId == null) {
      return <String>[];
    }
    final result = await driveApi.files.list(
        q: 'name = "$fileName" and "$directoryId" in parents and trashed = false');
    final files = result.files;
    if (files == null) {
      throw const HttpException('API does not return files.');
    }
    var fileIds = <String>[];
    for (final file in files) {
      final fileId = file.id;
      if (fileId != null) {
        fileIds.add(fileId);
      }
    }

    return fileIds;
  }
}

class _AuthenticatableClient extends BaseClient {
  Map<String, String>? _headers;
  final Client _client = Client();

  /// Sends a request.
  @override
  Future<StreamedResponse> send(BaseRequest request) {
    final headers = _headers;
    if (headers != null) {
      request.headers.addAll(headers);
    }

    return _client.send(request);
  }

  /// Authenticates this client.
  Future<void> authenticate() async {
    throw UnimplementedError();
  }

  /// Updates headers
  void updateHeaders(String accessTokenData) {
    _headers = {
      'Authorization': 'Bearer $accessTokenData',
      'X-Goog-AuthUser': '0'
    };
  }

  /// Headers that is added when request is sent.
  set headers(Map<String, String> headers) {
    _headers = headers;
  }
}

class _AuthenticatableDesktopClient extends _AuthenticatableClient {
  static AccessToken? _accessToken;

  /// Authenticates this client.
  @override
  Future<void> authenticate() async {
    final accessToken = _accessToken;
    if (accessToken != null) {
      final now = DateTime.now().toUtc();
      if (now.isBefore(accessToken.expiry)) {
        // Reuse the access token.
        updateHeaders(accessToken.data);

        return;
      }
    }

    const storage = FlutterSecureStorage();
    final savedData = await storage.read(key: 'accessTokenData');
    final savedExpiry = await storage.read(key: 'accessTokenExpiry');
    if (savedData != null && savedExpiry != null) {
      final expiry =
          DateTime.fromMillisecondsSinceEpoch(int.parse(savedExpiry)).toUtc();
      final now = DateTime.now().toUtc();
      if (now.isBefore(expiry)) {
        // Create access token from secure storage.
        _accessToken = AccessToken('Bearer', savedData, expiry);
        updateHeaders(savedData);

        return;
      }
    }

    // Try to refresh credentials
    final id = ClientId(getIdentifier(), getSecret());
    final scopes = [DriveApi.driveFileScope];
    final savedRefreshToken = await storage.read(key: 'refreshToken');
    if (savedRefreshToken != null && savedData != null && savedExpiry != null) {
      final expiry =
          DateTime.fromMillisecondsSinceEpoch(int.parse(savedExpiry)).toUtc();
      final accessToken = AccessToken('Bearer', savedData, expiry);
      final accessCredentials =
          AccessCredentials(accessToken, savedRefreshToken, scopes);
      try {
        final newCredentials =
            await refreshCredentials(id, accessCredentials, this);
        _accessToken = newCredentials.accessToken;
        updateHeaders(newCredentials.accessToken.data);
        _storeCredentials(storage, newCredentials);

        return;
      } on Exception catch (exception) {
        // Refresh failed. Try next step.
      }
    }

    // Obtain access credentials.
    try {
      final credentials = await obtainAccessCredentialsViaUserConsent(
          id, scopes, this, (url) async {
        await launchUrl(Uri.parse(url));
      });
      _accessToken = credentials.accessToken;
      updateHeaders(credentials.accessToken.data);
      _storeCredentials(storage, credentials);
    } on Exception catch (exception) {
      throw AuthenticationException('Failed to obtain access credentials.');
    }
  }

  void _storeCredentials(
      FlutterSecureStorage storage, AccessCredentials credentials) async {
    await storage.write(
        key: 'accessTokenData', value: credentials.accessToken.data);
    await storage.write(
        key: 'accessTokenExpiry',
        value:
            credentials.accessToken.expiry.millisecondsSinceEpoch.toString());
    await storage.write(key: 'refreshToken', value: credentials.refreshToken);
  }
}

class _AuthenticatableMobileClient extends _AuthenticatableClient {
  static GoogleSignIn? _signIn;

  /// Authenticates this client.
  @override
  Future<void> authenticate() async {
    var signIn = _signIn;
    if (signIn != null) {
      final account = signIn.currentUser;
      if (account == null) {
        throw AuthenticationException('Failed to sign in to Google.');
      }
      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;
      if (accessToken == null) {
        throw AuthenticationException('Failed to sign in to Google.');
      }
      updateHeaders(accessToken);

      return;
    }

    _signIn = GoogleSignIn(scopes: [DriveApi.driveFileScope]);
    signIn = _signIn;
    if (signIn == null) {
      throw AuthenticationException('Failed to sign in to Google.');
    }
    try {
      var account = await signIn.signInSilently();
      account ??= await signIn.signIn();
      if (account == null) {
        throw AuthenticationException('Failed to sign in to Google.');
      }
      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;
      if (accessToken == null) {
        throw AuthenticationException('Failed to sign in to Google.');
      }
      updateHeaders(accessToken);
    } on Exception catch (exception) {
      throw AuthenticationException('Failed to sign in to Google.');
    }
  }
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);
}

class FileNotFoundException extends HttpException {
  FileNotFoundException(String message, {Uri? uri}) : super(message, uri: uri);
}

class FileLockedException extends HttpException {
  FileLockedException(String message, {Uri? uri}) : super(message, uri: uri);
}
