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

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import 'editing_page.dart';
import 'memo.dart';
import 'memo_store.dart';
import 'memo_store_loader.dart';
import 'viewing_page.dart';

class HomePage extends StatefulWidget {
  /// Creates a home page.
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _shownMemos = <Memo>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final memoStore = MemoStore.getInstance();
    return Scaffold(
      appBar: AppBar(
        title: Text('Tsukimisou'),
      ),
      body: ListView.builder(
          itemCount: memoStore.memos.length,
          itemBuilder: (context, i) {
            final memo = _shownMemos[(_shownMemos.length - 1) - i];
            final updated =
                DateTime.fromMillisecondsSinceEpoch(memo.lastModified)
                    .toString();
            return Card(
                child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(memo.text),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Updated: ${updated}'),
                      ),
                    ]),
              ),
              onTap: () {
                print('tapped ${memo.text}');
                _viewMemo(memo);
              },
            ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: 'Add a memo',
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Test Google Drive'),
              onTap: _testGoogleDrive,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    final memoStore = MemoStore.getInstance();
    final memoStoreLoader = await MemoStoreLoader.fromFileName(
        memoStore, 'TsukimisouMemoStore.json');
    try {
      await memoStoreLoader.execute();
    } on FileSystemException catch (exception) {
      // Load error
      // Do nothing for now
    }
    setState(() {
      _updateShownMemos();
    });
  }

  void _addMemo() async {
    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditingPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return OpenUpwardsPageTransitionsBuilder().buildTransitions(
            null, context, animation, secondaryAnimation, child);
      },
    ));
    setState(() {
      _updateShownMemos();
    });
  }

  void _viewMemo(Memo memo) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ViewingPage(memo: memo);
        },
      ),
    );
    setState(() {
      _updateShownMemos();
    });
  }

  void _testGoogleDrive() {
    final id = ClientId('clientID');
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
      final string = 'Hello, World!';
      final encoded = utf8.encode(string);
      final stream = Future.value(encoded).asStream().asBroadcastStream();
      final media = Media(stream, encoded.length);
      final file = File();
      file.name = 'test.txt';
      final result = await driveApi.files.create(file, uploadMedia: media);
      client.close();
    });
  }

  void _updateShownMemos() {
    final memoStore = MemoStore.getInstance();
    final memos = memoStore.memos;
    _shownMemos = [...memos];
    _shownMemos.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  }

  void _prompt(String url) async {
    final result = await canLaunch(url);
    if (result) {
      await launch(url);
    } else {
      // Launch failed
      throw IOException;
    }
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
