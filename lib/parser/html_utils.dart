import 'package:flutter_quill_delta_from_html/parser/indent_parser.dart';

import 'colors.dart';
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
  return ["i", "em", "u", "ins", "s", "del", "b", "strong", "sub", "sup"]
      .contains(tag);
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
          if (color != null) {
            attributes['color'] = color;
          }
          break;
        case 'background-color':
          final color = validateAndGetColor(value);
          if (color != null) {
            attributes['background'] = color;
          }
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
            } on UnsupportedError {
              //ignore error
              break;
            }
          }
          attributes['size'] = sizeToPass;
          break;
        case 'font-family':
          attributes['font'] = value;
          break;
        case 'line-height':
          try {
            final lineHeight =
                parseLineHeight(value, fontSize: fontSize ?? 16.0);
            attributes['line-height'] = lineHeight;
          } catch (e) {
            //ignore error (i.e. 'line-height: inherit;')
          }
          break;
        case 'font-style':
          if (value == 'italic') {
            attributes['italic'] = true;
          }
          break;
        case 'text-decoration':
          if (value == 'underline') {
            attributes['underline'] = true;
          }
          break;
        case 'font-weight':
          if (value == 'bold') {
            attributes['bold'] = true;
          }
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

/// Parses a CSS `<img>` style attribute string into Delta attributes.
///
/// Converts CSS styles (like 'width', 'height', 'margin') from [style]
/// into Quill Delta attributes suitable for image rich text formatting.
///
/// Parameters:
/// - [style]: The CSS style attribute string to parse.
///
/// Returns:
/// A map of Delta attributes derived from the CSS styles.
///
/// Example:
/// ```dart
/// final style = 'width: 50px; height: 250px;';
/// print(parseStyleAttribute(style)); // Output: {'width': '50px', 'height': '250px'}
/// ```
Map<String, dynamic> parseImageStyleAttribute(String style, String align) {
  Map<String, dynamic> attributes = {};

  final styles = style.split(';');
  for (var style in styles) {
    final parts = style.split(':');
    if (parts.length == 2) {
      final key = parts[0].trim();
      final value = parts[1].trim();

      switch (key) {
        case 'width':
          attributes['width'] = value;
          break;
        case 'height':
          attributes['height'] = value;
          break;
        case 'margin':
          attributes['margin'] = value;
          break;
        default:
          // Ignore other styles
          break;
      }
    }
  }

  if (align.isNotEmpty) attributes['alignment'] = align;
  return attributes;
}
