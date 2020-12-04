// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:myapp/data/gallery_options.dart';
import 'package:myapp/l10n/gallery_localizations.dart';
import 'package:myapp/layout/adaptive.dart';
import 'package:myapp/layout/image_placeholder.dart';
import 'package:myapp/layout/text_scale.dart';
import 'package:myapp/studies/rally/app.dart';
import 'package:myapp/studies/rally/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:typed_data';   
import 'package:web3dart/web3dart.dart';
// import 'dart:convert' as convert;

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode blankNode = FocusNode();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ApplyTextOptions(
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: SafeArea(

          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(blankNode);
            },
            child: _MainView(
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
          )
          
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MainView extends StatelessWidget {
  const _MainView({
    Key key,
    this.usernameController,
    this.passwordController,
  }) : super(key: key);

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  void _login(BuildContext context) {
    Navigator.of(context).pushNamed(RallyApp.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    List<Widget> listViewChildren;

    if (isDesktop) {
      final desktopMaxWidth = 400.0 + 100.0 * (cappedTextScale(context) - 1);
      listViewChildren = [
        _UsernameInput(
          maxWidth: desktopMaxWidth,
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          maxWidth: desktopMaxWidth,
          passwordController: passwordController,
        ),
        _LoginButton(
          maxWidth: desktopMaxWidth,
          onTap: () {
            _login(context);
          },
        ),
      ];
    } else {
      listViewChildren = [
        const _SmallLogo(),
        _PasswordInput(
          passwordController: passwordController,
        ),
        _ThumbButton(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String keystore = prefs.getString('keystore');

            if (keystore == null) {
              var random = new Random.secure();
              Credentials credentials = EthPrivateKey.createRandom(random);
              var address = await credentials.extractAddress();

              random = new Random.secure();
              Wallet wallet = Wallet.createNew(credentials, "password", random);

              await prefs.setString('keystore', wallet.toJson());
              await prefs.setString('address', address.hex);

              print('create'); 
            } else {
              // Wallet wallet = Wallet.fromJson(keystore, this.passwordController.text);
              //{"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"bca51655fefc10553b4517caa3291b8f"},"ciphertext":"15cd206ce8e76e612e5a520d7edecabf96610bdf4306424a5b96e82e20aca091","kdf":"scrypt","kdfparams":{"dklen":32,"n":8192,"r":8,"p":1,"salt":"514da3c93c8fedb07573dedb22116bd55036fc0a3dec698c758e3e747a40e853"},"mac":"51aea965da9037575a11fc3320c90831ac4c63b7d533b0c645cc2cf344657c36"},"id":"1d6d1d11-ee92-4047-816f-73d6b2e17566","version":3}
              Wallet wallet = Wallet.fromJson(keystore, "password");
              Credentials unlocked = wallet.privateKey;
              var address = await unlocked.extractAddress();
              await prefs.setString('address', address.hex);
              print(address);
            }
            _login(context);
          },
        ),
      ];
    }

    return Column(
      children: [
        if (isDesktop) const _TopBar(),
        Expanded(
          child: Align(
            alignment: isDesktop ? Alignment.center : Alignment.topCenter,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: listViewChildren,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(width: 30);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  height: 80,
                  child: FadeInImagePlaceholder(
                    image:
                        const AssetImage('logo.png', package: 'rally_assets'),
                    placeholder: LayoutBuilder(builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxHeight,
                      );
                    }),
                  ),
                ),
              ),
              spacing,
              Text(
                GalleryLocalizations.of(context).rallyLoginLoginToRally,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontSize: 35 / reducedTextScale(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                GalleryLocalizations.of(context).rallyLoginNoAccount,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              spacing,
              _BorderButton(
                text: GalleryLocalizations.of(context).rallyLoginSignUp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallLogo extends StatelessWidget {
  const _SmallLogo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: SizedBox(
        height: 160,
        child: ExcludeSemantics(
          child: FadeInImagePlaceholder(
            image: AssetImage('logo.png', package: 'rally_assets'),
            placeholder: SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({
    Key key,
    this.maxWidth,
    this.usernameController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: GalleryLocalizations.of(context).rallyLoginUsername,
          ),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    Key key,
    this.maxWidth,
    this.passwordController,
  }) : super(key: key);

  final double maxWidth;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: GalleryLocalizations.of(context).rallyLoginPassword,
          ),
          obscureText: true,
        ),
      ),
    );
  }
}

class _ThumbButton extends StatefulWidget {
  _ThumbButton({
    @required this.onTap,
  });

  final VoidCallback onTap;

  @override
  _ThumbButtonState createState() => _ThumbButtonState();
}

class _ThumbButtonState extends State<_ThumbButton> {
  BoxDecoration borderDecoration;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: GalleryLocalizations.of(context).rallyLoginLabelLogin,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Focus(
          onKey: (node, event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                widget.onTap();
                return true;
              }
            }
            return false;
          },
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() {
                borderDecoration = BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                );
              });
            } else {
              setState(() {
                borderDecoration = null;
              });
            }
          },
          child: Container(
            decoration: borderDecoration,
            height: 120,
            child: ExcludeSemantics(
              child: Image.asset(
                'thumb.png',
                package: 'rally_assets',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    Key key,
    @required this.onTap,
    this.maxWidth,
  }) : super(key: key);

  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: RallyColors.buttonColor),
            const SizedBox(width: 12),
            Text(GalleryLocalizations.of(context).rallyLoginRememberMe),
            const Expanded(child: SizedBox.shrink()),
            _FilledButton(
              text: GalleryLocalizations.of(context).rallyLoginButtonLogin,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BorderButton extends StatelessWidget {
  const _BorderButton({Key key, @required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      borderSide: const BorderSide(color: RallyColors.buttonColor),
      color: RallyColors.buttonColor,
      highlightedBorderColor: RallyColors.buttonColor,
      focusColor: RallyColors.buttonColor.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textColor: Colors.white,
      onPressed: () {
        Navigator.of(context).pushNamed(RallyApp.homeRoute);
      },
      child: Text(text),
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({Key key, @required this.text, @required this.onTap})
      : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: RallyColors.buttonColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          const Icon(Icons.lock),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}
