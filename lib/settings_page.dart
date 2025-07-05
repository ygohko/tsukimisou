/*
 * Copyright (c) 2025 Yasuaki Gohko
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_uis.dart';
import 'settings.dart';
import 'gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final bool fullScreen;
  
  SettingsPage({super.key, this.fullScreen = true});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _synchronizingHidden = false;

  @override
  void didChangeDependencied() async {
    final settings = Provider.of<Settings>(context, listen: false);
    final hidden = await settings.getSynchronizingHidden();
    setState(() {
        _synchronizingHidden = hidden;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    late final IconButton leading;
    if (widget.fullScreen) {
      leading = BackButton();
    } else {
      leading = CloseButton();
    }
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          Consumer<Settings>(
            builder: (context, settings, child) {
              return ListTile(
                title: Text(localizations.hideGoogleDriveSynchronization),
                trailing: Switch(
                  value: _synchronizingHidden,
                  onChanged: (bool value) async {
                    _synchronizingHidden = !_synchronizingHidden;
                    final settings = Provider.of<Settings>(context, listen: false);
                    await settings.setSynchronizingHidden(_synchronizingHidden);
                  },
                ),
                onTap: () async {
                  _synchronizingHidden = !_synchronizingHidden;
                  final settings = Provider.of<Settings>(context, listen: false);
                  await settings.setSynchronizingHidden(_synchronizingHidden);
                },
              );
            },
          ),
          ListTile(
            title: Text(localizations.about),
            onTap: () {
              // TODO: Implement functionality
            },
          ),
          ListTile(
            title: Text(localizations.privacyPolicy),
            onTap: _showPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() async {
    await launchUrl(
        Uri.parse('https://sites.gonypage.jp/home/tsukimisou/privacy-policy'));
    if (mounted) {
      if (!hasLargeScreen()) {
        Navigator.of(context).pop();
      }
    }
  }
}
