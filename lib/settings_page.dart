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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';
import 'settings.dart';
import 'gen_l10n/app_localizations.dart';

/// Page to modify settings.
class SettingsPage extends StatefulWidget {
  final bool fullScreen;

  /// Create a settings page.
  const SettingsPage({super.key, this.fullScreen = true});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _synchronizingHidden = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final settings = Provider.of<Settings>(context, listen: false);
    final hidden = settings.getSynchronizingHidden();
    setState(() {
      _synchronizingHidden = hidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    late final IconButton leading;
    if (widget.fullScreen) {
      leading = const BackButton();
    } else {
      leading = const CloseButton();
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
                title: Text(localizations.hideGoogleDriveIntegration),
                trailing: Switch(
                  value: _synchronizingHidden,
                  onChanged: (bool value) {
                    _setSynchronizingHidden(value);
                  },
                ),
                onTap: () {
                  _setSynchronizingHidden(!_synchronizingHidden);
                },
              );
            },
          ),
          ListTile(
            title: Text(localizations.about),
            onTap: _showAbout,
          ),
          ListTile(
            title: Text(localizations.privacyPolicy),
            onTap: _showPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  void _setSynchronizingHidden(bool hidden) async {
    setState(() {
      _synchronizingHidden = hidden;
    });
    final settings = Provider.of<Settings>(context, listen: false);
    await settings.setSynchronizingHidden(_synchronizingHidden);
  }

  void _showAbout() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.licensesAdded) {
      _addLicenses();
      appState.licensesAdded = true;
    }
    final localizations = AppLocalizations.of(context)!;
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    showAboutDialog(
      context: context,
      applicationName: localizations.tsukimisou,
      applicationVersion: packageInfo.version,
      applicationIcon: const Image(
        image: AssetImage('assets/images/about_icon.png'),
      ),
      applicationLegalese: '(c) 2022 - 2025 Yasuaki Gohko',
    );
  }

  void _showPrivacyPolicy() async {
    await launchUrl(
        Uri.parse('https://sites.gonypage.jp/home/tsukimisou/privacy-policy'));
  }

  void _addLicenses() async {
    LicenseRegistry.addLicense(() async* {
      var text = await rootBundle.loadString('assets/licenses/noto_fonts.txt');
      yield LicenseEntryWithLineBreaks(
        ['Noto Fonts'],
        text,
      );
      text = await rootBundle.loadString('assets/licenses/tsukimisou.txt');
      yield LicenseEntryWithLineBreaks(
        ['Tsukimisou'],
        text,
      );
    });
  }
}
