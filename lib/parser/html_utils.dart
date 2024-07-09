import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:html/dom.dart' as dom;
import 'colors.dart';
import 'custom_html_part.dart';
import 'font_size_parser.dart';
import 'line_height_parser.dart';

///verify if the tag is from a inline html tag attribute
bool isInline(String tag) {
  return ["i", "em", "u", "ins", "s", "del", "b", "strong", "sub", "sup"].contains(tag);
}

///get all attributes from a tag, and parse to Delta attributes
Map<String, dynamic> parseStyleAttribute(String style) {
  Map<String, dynamic> attributes = {};
  if (style.isEmpty) return attributes;

  final styles = style.split(';');
  double? fontSize ;
  for (var style in styles) {
    final parts = style.split(':');
    if (parts.length == 2) {
      final key = parts[0].trim();
      final value = parts[1].trim();

      switch (key) {
        case 'text-align':
          attributes['align'] = value;
          break;
        case 'color':
          final color = validateAndGetColor(value);
          attributes['color'] = color;
          break;
        case 'background-color':
          final color = validateAndGetColor(value);
          attributes['background'] = color;
          break;
        case 'font-size':
          String? sizeToPass;
          //Those are the default values used by [vsc_quill_delta_to_html]
          if (value == '0.75em') {
            fontSize = 10;
            sizeToPass = 'small';
          } else if (value == '1.5em') {
            fontSize = 18;
            sizeToPass = 'large';
          } else if (value == '2.5em') {
            fontSize = 22;
            sizeToPass = 'huge';
          } else {
            try {
              final size = parseSizeToPx(value);
              if (size <= 10) {
                fontSize = 10;
                sizeToPass = 'small';
              } else {
                fontSize = size.floorToDouble();
                sizeToPass = '${size.floor()}';
              }
            } on UnsupportedError catch (e) {
              debugPrint(e.message);
              debugPrintStack(stackTrace: e.stackTrace);
              break;
            }
          }
          attributes['size'] = sizeToPass;
          break;
        case 'font-family':
          attributes['font'] = value;
          break;
        case 'line-height':
        final lineHeight = parseLineHeight(value, fontSize: fontSize ?? 16.0);
          attributes['line-height'] = lineHeight;
          break;
        default:
          break;
      }
    } else {
      switch (style) {
        case 'justify' || 'center' || 'left' || 'right':
          attributes['align'] = style;
        case 'rtl':
          attributes['direction'] = 'rtl';
        case 'true' || 'false':
          //then is check list
          if (style == 'true') {
            attributes['list'] = 'checked';
          } else {
            attributes['list'] = 'unchecked';
          }
          break;
        default:
          break;
      }
    }
  }

  return attributes;
}

///Store within the node getting text nodes, spans nodes, link nodes, and attributes to apply for the delta
///This only used store the inline attributes or tags into a <p> or a <h1> or <span> without insert block attributes
void processNode(
  dom.Node node,
  Map<String, dynamic> attributes,
  Delta delta, {
  bool addSpanAttrs = false,
  List<CustomHtmlPart>? customBlocks,
}) {
  if (node is dom.Text) {
    delta.insert(node.text, attributes.isEmpty ? null : attributes);
  } else if (node is dom.Element) {
    Map<String, dynamic> newAttributes = Map.from(attributes);
    if (node.isStrong) newAttributes['bold'] = true;
    if (node.isItalic) newAttributes['italic'] = true;
    if (node.isUnderline) newAttributes['underline'] = true;
    if (node.isStrike) newAttributes['strike'] = true;
    if (node.isSubscript) newAttributes['script'] = 'sub';
    if (node.isSuperscript) newAttributes['script'] = 'super';
    //use custom block since them can be into any html tag
    if (customBlocks != null && customBlocks.isNotEmpty) {
      for (var customBlock in customBlocks) {
        if (customBlock.matches(node)) {
          final operations = customBlock.convert(node, currentAttributes: newAttributes);
          operations.forEach((Operation op) {
            delta.insert(op.data, op.attributes);
          });
          continue;
        }
      }
    } else {
      ///the current node is <span>
      if (node.isSpan) {
        final spanAttributes = parseStyleAttribute(node.attributes['style'] ?? '');
        if (addSpanAttrs) {
          newAttributes.remove('align');
          newAttributes.remove('direction');
          newAttributes.addAll({...spanAttributes});
        }
      }

      ///the current node is <a>
      if (node.isLink) {
        final String? src = node.attributes['href'];
        if (src != null) {
          newAttributes['link'] = src;
        }
      }

      ///the current node is <br>
      if (node.isBreakLine) {
        newAttributes.remove('align');
        newAttributes.remove('direction');
        delta.insert('\n', newAttributes);
      }
    }

    ///Store on the nodes into the current one
    for (final child in node.nodes) {
      processNode(child, newAttributes, delta, addSpanAttrs: addSpanAttrs);
    }
  }
}
