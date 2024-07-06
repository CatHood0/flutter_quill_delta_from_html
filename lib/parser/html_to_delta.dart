import 'package:flutter_quill/quill_delta.dart';

///Default converter for html to Delta
///By now is a [experimental] API and must not be used on
///Production code since is too far to be stable and usable for devs
class HtmlToDelta {
  final String htmlText;
  final Operation? Function(HtmlNode node)? customTagCallback;

  HtmlToDelta({
    required this.htmlText,
    this.customTagCallback,
  });
  
  Delta convert() {
    return Delta()..insert(htmlText);
  }
}

/// This class represents a html node
/// with it's attributes to make more simple store on them
class HtmlNode {
  final String startTag;
  final Map<String, dynamic> params;
  final String endTag;
  final String content;

  HtmlNode({
    required this.startTag,
    required this.params,
    required this.endTag,
    required this.content,
  });
}
