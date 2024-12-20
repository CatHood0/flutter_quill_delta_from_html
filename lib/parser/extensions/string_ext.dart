extension StringExt on String {
  String get transformNewLinesToBrTag => replaceAll('\n', '<br>');
  String get removeAllNewLines => replaceAll('\n', '');
}
