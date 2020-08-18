import 'dart:convert';

import 'package:http/http.dart' as http;
import 'models/Translation.dart';

Future<http.Response> authentication(String authKey) async {
  final response =
      await http.get('https://api.deepl.com/v2/usage?auth_key=$authKey');
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception(response.body);
  }
}

Future<Translation> translateText(
    String authKey, String text, String targetLang) async {
  final response = await http.post(
    'https://api.deepl.com/v2/translate',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    },
    body: {
      "auth_key": authKey,
      "text": text,
      "target_lang": targetLang,
    },
  );
  if (response.statusCode == 200) {
    return Translation.fromJson(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    throw Exception(response.body);
  }
}
