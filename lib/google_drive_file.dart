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

class GoogleDriveFile {
  final String _fileName;

  GoogleDriveFile(this._fileName);

  Future<void> writeAsString(String contents) async {
    final id = ClientId('clientID', 'secret');
    final scopes = [DriveApi.driveFileScope];
    final client = _GoogleAuthClient();
    obtainAccessCredentialsViaUserConsent(id, scopes, client, (url) {
        _prompt(url);
    }).then((credentials) async {
        client.headers = {
          'Authorization': 'Bearer ${credentials.accessToken.data}',
          'X-Goog-AuthUser': '0'
        };
        final driveApi = DriveApi(client);
        final encoded = utf8.encode(contents);
        final stream = Future.value(encoded).asStream().asBroadcastStream();
        final media = Media(stream, encoded.length);
        final file = File();
        file.name = _fileName;
        final result = await driveApi.files.create(file, uploadMedia: media);
        client.close();
    });
  }

  Future<void> test() async {
    final id = ClientId('clientID', 'secret');
    final scopes = [DriveApi.driveFileScope];
    final client = _GoogleAuthClient();
    obtainAccessCredentialsViaUserConsent(id, scopes, client, (url) {
        _prompt(url);
    }).then((credentials) async {
        client.headers = {
          'Authorization': 'Bearer ${credentials.accessToken.data}',
          'X-Goog-AuthUser': '0'
        };
        final driveApi = DriveApi(client);
        final result = await driveApi.files.list(corpora: 'user', q: 'TsukimisouMemoStore.json');
        final files = result.files;
        if (files == null) {
          return;
        }
        for (var file in files) {
          print('file name: ${file.name}');
        }
        client.close();
    });
  }

  void _prompt(String url) async {
    await launch(url);
  }
}

class _GoogleAuthClient extends BaseClient {
  Map<String, String>? _headers = null;
  final Client _client = Client();

  Future<StreamedResponse> send(BaseRequest request) {
    final headers = _headers;
    if (headers != null) {
      request.headers.addAll(headers);
    }

    return _client.send(request);
  }

  void set headers(Map<String, String> headers) {
    _headers = headers;
  }
}
