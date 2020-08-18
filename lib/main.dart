import 'dart:async';

import 'package:deepl/models/Translation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AuthCodeStorage.dart';
import 'api.dart' as deepl;
import 'models/Translation.dart';

void main() async {
  runApp(App());
}

typedef OnLoginCallback = void Function(String authCode);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const title = 'DeepL';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: AuthCodeStorage().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DeepLHome(authCode: snapshot.data);
          } else {
            return DeepLHome();
          }
        },
      ),
    );
  }
}

class DeepLHome extends StatefulWidget {
  final String authCode;

  DeepLHome({key, this.authCode}) : super(key: key);

  @override
  _DeepLHomeState createState() => _DeepLHomeState();
}

enum Seen {
  login,
  main,
}

class _DeepLHomeState extends State<DeepLHome> {
  Seen seen = Seen.login;

  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authCode != null) {
      seen = Seen.main;
    }
  }

  String _seenTitle() {
    switch (seen) {
      case Seen.login:
        return '認証';
      case Seen.main:
        return 'DeepL';
      default:
        throw Exception('unexpected seen: $seen');
    }
  }

  Widget _seenBody() {
    switch (seen) {
      case Seen.login:
        return Login(onLogin: _handleLogin);
      case Seen.main:
        return DeepLTranslator(authCode: widget.authCode);
      default:
        throw Exception('unexpected seen: $seen');
    }
  }

  void _handleLogin(String authCode) {
    AuthCodeStorage().save(authCode);
    setState(() {
      seen = Seen.main;
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

class Login extends StatefulWidget {
  final OnLoginCallback onLogin;

  Login({Key key, this.onLogin}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controller = TextEditingController(text: '');
  Future<http.Response> future;

  @override
  initState() {
    super.initState();
  }

  _handleSubmitted(String code) {
    setState(() {
      future = deepl.authentication(code);
    });
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: 'auth_code',
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        onSubmitted: _handleSubmitted,
        decoration: _buildInputDecoration(),
      ),
    );
  }

  Widget _buildSuccess() {
    Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        widget.onLogin(controller.text);
      },
    );
    return Icon(Icons.done, color: Colors.green);
  }

  Widget _buildAuthError() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('認証に失敗しました')
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(),
              if (snapshot.connectionState == ConnectionState.waiting)
                CircularProgressIndicator(),
              if (snapshot.connectionState == ConnectionState.done)
                snapshot.hasError ? _buildAuthError() : _buildSuccess(),
            ],
          );
        },
      ),
    );
  }
}

class DeepLTranslator extends StatefulWidget {
  final String authCode;
  final TextEditingController controller = TextEditingController();

  DeepLTranslator({key, this.authCode}) : super(key: key);

  @override
  _DeepLTranslatorState createState() => _DeepLTranslatorState();
}

class _DeepLTranslatorState extends State<DeepLTranslator> {
  Future<Translation> future;

  void translateTextField() async {
    setState(() {
      future =
          deepl.translateText(widget.authCode, widget.controller.text, "ja");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            TextField(
              controller: widget.controller,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            RaisedButton(
              onPressed: translateTextField,
              child: Text('翻訳'),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              CircularProgressIndicator(),
            if (snapshot.hasData) Text(snapshot.data.text),
          ],
        );
      },
    );
  }
}
