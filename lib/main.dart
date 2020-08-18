import 'package:flutter/material.dart';

import 'package:deepl/screens/Home.dart';
import 'package:deepl/AuthCodeStorage.dart';

void main() async {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: AuthCodeStorage().read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Home(authCode: snapshot.data);
          } else {
            return Home();
          }
        },
      ),
    );
  }
}
