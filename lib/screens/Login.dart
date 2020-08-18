import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:deepl/api.dart' as deepl;

typedef OnLoginCallback = void Function(String authCode);

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
