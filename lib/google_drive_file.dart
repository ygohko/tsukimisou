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

import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client_id.dart';

class GoogleDriveFile {
  final String _fileName;

  /// Constructs a Google Drive file.
  GoogleDriveFile(this._fileName);

  /// Writes contents as a string.
  Future<void> writeAsString(String contents) async {
    final client = _AuthenticatableClient();
    await client.authenticate();
    final driveApi = DriveApi(client);
    final result = await driveApi.files
        .list(q: 'name = "${_fileName}" and "root" in parents');
    final files = result.files;
    if (files != null) {
      for (var file in files) {
        final fileId = file.id;
        if (fileId != null) {
          await driveApi.files.delete(fileId);
        }
      }
    }

    final encoded = utf8.encode(contents);
    final stream = Future.value(encoded).asStream().asBroadcastStream();
    final media = Media(stream, encoded.length);
    final file = File();
    file.name = _fileName;
    await driveApi.files.create(file, uploadMedia: media);
    client.close();
  }

  /// Reads contents as a string.
  Future<String> readAsString() async {
    final client = _AuthenticatableClient();
    await client.authenticate();
    var string = '';
    final driveApi = DriveApi(client);
    final result = await driveApi.files
        .list(q: 'name = "${_fileName}" and "root" in parents');
    final files = result.files;
    if (files == null) {
      throw HttpException;
    }
    if (files.length < 1) {
      throw HttpException;
    }
    final fileId = files[0].id;
    if (fileId == null) {
      throw HttpException;
    }

    final media = await driveApi.files
        .get(fileId, downloadOptions: DownloadOptions.fullMedia) as Media;
    var values = <int>[];
    await media.stream.forEach((element) {
      values += element;
    });
    string = utf8.decode(values);
    print("string: ${string}");
    client.close();

    return string;
  }

  void _prompt(String url) async {
    await launch(url);
  }
}

class _AuthenticatableClient extends BaseClient {
  // TODO: Rename to publish.
  Map<String, String>? _headers = null;
  final Client _client = Client();

  static AccessToken? _accessToken = null;

  /// Send a request.
  Future<StreamedResponse> send(BaseRequest request) {
    final headers = _headers;
    if (headers != null) {
      request.headers.addAll(headers);
    }

    return _client.send(request);
  }

  /// Authenticate this client.
  Future<void> authenticate() async {
    final accessToken = _accessToken;
    if (accessToken != null) {
      final now = DateTime.now().toUtc();
      if (now.isBefore(accessToken.expiry)) {
        // Reuse the access token.
        _headers = {
          'Authorization': 'Bearer ${accessToken.data}',
          'X-Goog-AuthUser': '0'
        };

        return;
      }
    }

    final id = ClientId(getIdentifier(), getSecret());
    final scopes = [DriveApi.driveFileScope];
    var string = '';
    final credentials = await obtainAccessCredentialsViaUserConsent(
        id, scopes, this, (url) async {
      await launch(url);
    });
    _accessToken = credentials.accessToken;
    _headers = {
      'Authorization': 'Bearer ${credentials.accessToken.data}',
      'X-Goog-AuthUser': '0'
    };
  }

  /// Headers that is added when request is sent.
  void set headers(Map<String, String> headers) {
    _headers = headers;
  }
}
