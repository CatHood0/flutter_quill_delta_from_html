import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_operation.dart';
import 'package:html/dom.dart' as dom;

///verify if the tag is from a inline html tag attribute
bool isInline(String tag) {
  return ["i", "em", "u", "ins", "s", "del", "b", "strong", "sub", "sup"].contains(tag);
}

///get all attributes from a tag, and parse to Delta attributes
///_By now just are supported font-size,font-family and line-height_
Map<String, dynamic> parseStyleAttribute(String style) {
  Map<String, dynamic> attributes = {};
  if (style.isEmpty) return attributes;

  final styles = style.split(';');
  for (var style in styles) {
    final parts = style.split(':');
    if (parts.length == 2) {
      final key = parts[0].trim();
      final value = parts[1].trim();

      switch (key) {
        case 'text-align':
          attributes['align'] = value;
          break;
        case 'font-size':
          attributes['size'] = value;
          break;
        case 'font-family':
          attributes['font'] = value;
          break;
        case 'line-height':
          attributes['line-height'] = value;
          break;
        default:
          break;
      }
    }
  }

  return attributes;
}

List<Operation> nodeToOperation(
  dom.Node node,
  HtmlOperations htmlToOp, [
  List<Operation>? Function(dom.Element element)? customTagCallback,
]) {
  List<Operation> operations = [];
  if (node is dom.Text) {
    operations.add(Operation.insert(node.text.trim()));
  }
  if (node is dom.Element) {
    List<Operation>? ops = htmlToOp.resolveCurrentElement(node) ?? customTagCallback?.call(node);
    operations.addAll(ops ?? []);
  }

  return operations;
}

///Store within the node getting text nodes, spans nodes, link nodes, and attributes to apply for the delta
void processNode(dom.Node node, Map<String, dynamic> attributes, Delta delta, {bool insertOnSpan = false}) {
  if (node is dom.Text) {
    delta.insert(node.text, attributes.isEmpty ? null : attributes);
  } else if (node is dom.Element) {
    Map<String, dynamic> newAttributes = Map.from(attributes);
    if (node.isStrong) newAttributes['bold'] = true;
    if (node.isItalic) newAttributes['italic'] = true;
    if (node.isUnderline) newAttributes['underline'] = true;
    if (node.isStrike) newAttributes['strike'] = true;

    if (node.isSpan) {
      final spanAttributes = parseStyleAttribute(node.attributes['style'] ?? '');
      if (insertOnSpan) {
        newAttributes.remove('align');
        delta.insert(node.text, {...newAttributes, ...spanAttributes});
      }
    }
    if (node.isLink) {
      final String? src = node.attributes['href'];
      if (src != null) {
        newAttributes['link'] = src;
      }
    }
    if (node.isBreakLine) {
      newAttributes.remove('align');
      delta.insert('\n', newAttributes);
    }
    for (final child in node.nodes) {
      processNode(child, newAttributes, delta, insertOnSpan: insertOnSpan);
    }
  }
}
