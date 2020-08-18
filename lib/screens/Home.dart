import 'package:flutter/material.dart';

import 'package:deepl/AuthCodeStorage.dart';
import 'package:deepl/screens/Translator.dart';
import 'package:deepl/screens/Login.dart';

class Home extends StatefulWidget {
  final String authCode;

  Home({key, this.authCode}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

enum _Seen {
  login,
  main,
}

class _HomeState extends State<Home> {
  _Seen seen = _Seen.login;

  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authCode != null) {
      seen = _Seen.main;
    }
  }

  String _seenTitle() {
    switch (seen) {
      case _Seen.login:
        return '認証';
      case _Seen.main:
        return 'DeepL';
      default:
        throw Exception('unexpected seen: $seen');
    }
  }

  Widget _seenBody() {
    switch (seen) {
      case _Seen.login:
        return Login(onLogin: _handleLogin);
      case _Seen.main:
        return Translator(authCode: widget.authCode);
      default:
        throw Exception('unexpected seen: $seen');
    }
  }

  void _handleLogin(String authCode) {
    AuthCodeStorage().save(authCode);
    setState(() {
      seen = _Seen.main;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_seenTitle()),
      ),
      body: _seenBody(),
    );
  }
}
