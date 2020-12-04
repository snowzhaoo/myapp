// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:myapp/layout/adaptive.dart';
import 'package:myapp/studies/rally/app.dart';
import 'package:myapp/studies/rally/colors.dart';
import 'package:myapp/studies/rally/data.dart';
import 'package:myapp/data/gallery_options.dart';
import 'package:myapp/pages/about.dart' as about;
import 'package:myapp/l10n/gallery_localizations.dart';

class SettingLocal extends StatefulWidget {
  @override 
   _SettingLocal createState() => _SettingLocal();
 
}
class _SettingLocal extends State<SettingLocal> {

  bool flag = false;
  @override
  Widget build(BuildContext context) {

  flag = GalleryOptions.of(context).locale == Locale('en') ? false : true;

  final options = GalleryOptions.of(context);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,      
        children: [
        _SettingsItem('English/中文'),
        Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
          child: 
            Switch(
                value: this.flag,
                activeColor: Colors.white,
                inactiveTrackColor: Colors.black,
                onChanged: (value) {
                  Locale locale = value ? Locale('zh', 'CN') : Locale('en');
                  GalleryOptions.update(
                    context,
                    options.copyWith(locale: locale),
                  );

                  setState(() {
                    this.flag = value;
                  });
                },
              ),
        ),
      ],
    );
  }
}

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {

    return FocusTraversalGroup(
      child: Container(
        padding: EdgeInsets.only(top: isDisplayDesktop(context) ? 24 : 0),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (String title
                in DummyDataService.getSettingsTitles(context)) ...[
              _SettingsItem(title),
              const Divider(
                color: RallyColors.dividerColor,
                height: 1,
              )
            ],
            SettingLocal(),
            
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final options = GalleryOptions.of(context);
    return FlatButton(
      textColor: Colors.white,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Text(title),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(RallyApp.loginRoute);
      },
    );
  }
}

// class SettingsAbout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return _SettingsLink(
//       title: GalleryLocalizations.of(context).settingsAbout,
//       icon: Icons.info_outline,
//       onTap: () {
//         about.showAboutDialog(context: context);
//       },
//     );
//   }
// }

class _SettingsLink extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback onTap;

  _SettingsLink({this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
      final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
  }
}
