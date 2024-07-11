import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/indent_parser.dart';
import 'package:html/dom.dart' as dom;
import 'colors.dart';
import 'custom_html_part.dart';
import 'font_size_parser.dart';
import 'line_height_parser.dart';

/// Checks if the given [tag] corresponds to an inline HTML element.
///
/// Inline elements include: 'i', 'em', 'u', 'ins', 's', 'del', 'b', 'strong', 'sub', 'sup'.
///
/// Parameters:
/// - [tag]: The HTML tag name to check.
///
/// Returns:
/// `true` if [tag] is an inline element, `false` otherwise.
bool isInline(String tag) {
  return ["i", "em", "u", "ins", "s", "del", "b", "strong", "sub", "sup"].contains(tag);
}

/// Parses a CSS style attribute string into Delta attributes.
///
/// Converts CSS styles (like 'text-align', 'color', 'font-size', etc.) from [style]
/// into Quill Delta attributes suitable for rich text formatting.
///
/// Parameters:
/// - [style]: The CSS style attribute string to parse.
///
/// Returns:
/// A map of Delta attributes derived from the CSS styles.
///
/// Example:
/// ```dart
/// final style = 'color: #ff0000; font-size: 16px;';
/// print(parseStyleAttribute(style)); // Output: {'color': '#ff0000', 'size': '16'}
/// ```
Map<String, dynamic> parseStyleAttribute(String style) {
  Map<String, dynamic> attributes = {};
  if (style.isEmpty) return attributes;

  final styles = style.split(';');
  double? fontSize;

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
        case 'padding-left' || 'padding-right':
          final indentation = parseToIndent(value);
          if (indentation != 0) {
            attributes['indent'] = indentation;
          }
          break;
        case 'font-size':
          String? sizeToPass;

          // Handle default values used by [vsc_quill_delta_to_html]
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
          // Treat as check list
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

/// Processes a DOM [node], converting it into Quill Delta operations.
///
/// Recursively processes the DOM nodes, converting text nodes, inline styles,
/// links, and custom HTML blocks into Quill Delta operations.
///
/// Parameters:
/// - [node]: The DOM node to process.
/// - [attributes]: The current Delta attributes to apply.
/// - [delta]: The Delta object to push operations into.
/// - [addSpanAttrs]: Whether to add attributes from <span> tags.
/// - [customBlocks]: Optional list of custom HTML block definitions.
///
/// Example:
/// ```dart
/// final htmlNode = dom.Element.tag('p')..append(dom.Text('Hello, <strong><em>World</em></strong>!'));
/// final delta = Delta();
/// processNode(htmlNode, {}, delta);
/// print(delta.toJson()); // Output: [{"insert": "Hello, "}, {"insert": "World", "attributes": {"italic": true, "bold": true}}, {"insert": "!"}]
/// ```
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

    // Apply inline styles based on tag type
    if (node.isStrong) newAttributes['bold'] = true;
    if (node.isItalic) newAttributes['italic'] = true;
    if (node.isUnderline) newAttributes['underline'] = true;
    if (node.isStrike) newAttributes['strike'] = true;
    if (node.isSubscript) newAttributes['script'] = 'sub';
    if (node.isSuperscript) newAttributes['script'] = 'super';

    // Use custom block definitions if provided
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
      // Handle <span> tags
      if (node.isSpan) {
        final spanAttributes = parseStyleAttribute(node.attributes['style'] ?? '');
        if (addSpanAttrs) {
          newAttributes.remove('align');
          newAttributes.remove('direction');
          newAttributes.remove('indent');
          newAttributes.addAll(spanAttributes);
        }
      }

      // Handle <a> tags (links)
      if (node.isLink) {
        final String? src = node.attributes['href'];
        if (src != null) {
          newAttributes.remove('indent');
          newAttributes['link'] = src;
        }
      }

      // Handle <br> tags (line breaks)
      if (node.isBreakLine) {
        newAttributes.remove('align');
        newAttributes.remove('direction');
        newAttributes.remove('indent');
        delta.insert('\n', newAttributes);
      }
    }

    // Recursively process child nodes
    for (final child in node.nodes) {
      processNode(child, newAttributes, delta, addSpanAttrs: addSpanAttrs);
    }
  }
}
