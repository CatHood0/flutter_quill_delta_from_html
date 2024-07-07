import 'package:html/dom.dart';

extension NodeExt on Element {
  bool get isItalic => localName == 'em' || localName == 'i';
  bool get isStrong => localName == 'strong' || localName == 'b';
  bool get isUnderline => localName == 'ins' || localName == 'u';
  bool get isStrike => localName == 's' || localName == 'del';
  bool get isParagraph => localName == 'p';
  bool get isBreakLine => localName == 'br';
  bool get isSpan => localName == 'span';
  bool get isHeader => localName != null && localName!.contains(RegExp('h[1-6]'));
  bool get isImg => localName == 'img';
  bool get isList =>
      localName == 'li' || localName == 'ul' || localName == 'ol' || querySelector('input[type="checkbox"]') != null;
  bool get isVideo => localName == 'video' || localName == 'iframe';
  bool get isLink => localName == 'a';
  bool get isBlockquote => localName == 'blockquote';
  bool get isCodeBlock => localName == 'pre' || localName == 'code';
}
