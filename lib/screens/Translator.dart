import 'package:flutter/material.dart';

import 'package:deepl/models/Translation.dart';
import 'package:deepl/api.dart' as deepl;

class Translator extends StatefulWidget {
  final String authCode;
  final TextEditingController controller = TextEditingController();

  Translator({key, this.authCode}) : super(key: key);

  @override
  _TranslatorState createState() => _TranslatorState();
}

class _TranslatorState extends State<Translator> {
  Future<Translation> future;

  void _translateTextField() async {
    setState(() {
      future =
          deepl.translateText(widget.authCode, widget.controller.text, 'ja');
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
              onPressed: _translateTextField,
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
