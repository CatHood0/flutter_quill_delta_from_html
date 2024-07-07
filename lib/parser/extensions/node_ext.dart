import 'package:html/dom.dart';

///DOM Node extension to make more easy call certain operations or validations
extension NodeExt on Element {
  ///Ensure to detect italic html tags
  bool get isItalic => localName == 'em' || localName == 'i';

  ///Ensure to detect bold html tags
  bool get isStrong => localName == 'strong' || localName == 'b';

  ///Ensure to detect underline html tags
  bool get isUnderline => localName == 'ins' || localName == 'u';

  ///Ensure to detect strikethrough html tags
  bool get isStrike => localName == 's' || localName == 'del';

  ///Ensure to detect p html tags
  bool get isParagraph => localName == 'p';

  ///Ensure to detect sub html tags
  bool get isSubscript => localName == 'sub';

  ///Ensure to detect sup html tags
  bool get isSuperscript => localName == 'sup';

  ///Ensure to detect br html tags
  bool get isBreakLine => localName == 'br';

  ///Ensure to detect span html tags
  bool get isSpan => localName == 'span';

  ///Ensure to detect h(1-6) html tags
  bool get isHeader =>
      localName != null && localName!.contains(RegExp('h[1-6]'));

  ///Ensure to detect img html tags
  bool get isImg => localName == 'img';

  ///Ensure to detect li,ul,ol,<input type=checkbox> html tags
  bool get isList =>
      localName == 'li' ||
      localName == 'ul' ||
      localName == 'ol' ||
      querySelector('input[type="checkbox"]') != null;

  ///Ensure to detect video html tags
  bool get isVideo => localName == 'video' || localName == 'iframe';

  ///Ensure to detect a html tags
  bool get isLink => localName == 'a';

  ///Ensure to detect blockquote html tags
  bool get isBlockquote => localName == 'blockquote';

  ///Ensure to detect pre,code html tags
  bool get isCodeBlock => localName == 'pre' || localName == 'code';
}
