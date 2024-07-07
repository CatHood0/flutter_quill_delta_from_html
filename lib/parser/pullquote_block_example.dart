import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:html/dom.dart' as dom;

class PullquoteBlock extends CustomHtmlPart {
  @override
  bool matches(dom.Element element) {
    return element.localName == 'pullquote';
  }

  @override
  List<Operation> convert(dom.Element element, {Map<String, dynamic>? currentAttributes}) {
    final Delta delta = Delta();
    final Map<String, dynamic> attributes = currentAttributes != null ? Map.from(currentAttributes) : {};

    final author = element.attributes['data-author'];
    final style = element.attributes['data-style'];

    String text = 'Pullquote: "${element.text}"';
    if (author != null) {
      text += ' by $author';
    }

    if (style != null && style.toLowerCase() == 'italic') {
      attributes['italic'] = true;
    }

    delta.insert(text, attributes);
    delta.insert('\n');

    return delta.toList();
  }
}
