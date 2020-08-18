class Translation {
  final String text;
  final String detectedSourceLanguage;

  Translation({this.text, this.detectedSourceLanguage});

  factory Translation.fromJson(Map<String, dynamic> json) {
    final translations = json["translations"];
    assert(translations.length == 1);
    final translation = translations[0] as Map<String, Object>;
    return Translation(
      text: translation["text"],
      detectedSourceLanguage: translation["detected_source_language"],
    );
  }
}
