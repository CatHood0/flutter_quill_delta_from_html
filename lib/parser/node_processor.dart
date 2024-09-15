import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:html/dom.dart' as dom;

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
  List<String>? removeTheseAttributesFromSpan,
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
          final operations =
              customBlock.convert(node, currentAttributes: newAttributes);
          operations.forEach((Operation op) {
            delta.insert(op.data, op.attributes);
          });
          continue;
        }
      }
    } else {
      // Handle <span> tags
      if (node.isSpan) {
        final spanAttributes =
            parseStyleAttribute(node.getSafeAttribute('style'));
        if (addSpanAttrs) {
          newAttributes.remove('align');
          newAttributes.remove('direction');
          newAttributes.remove('indent');
          if (removeTheseAttributesFromSpan != null &&
              removeTheseAttributesFromSpan.isNotEmpty) {
            for (final attr in removeTheseAttributesFromSpan) {
              newAttributes.remove(attr);
            }
          }
          newAttributes = {...spanAttributes, ...newAttributes};
        }
      }

      // Handle <img> tags
      if (node.isImg) {
        final String src = node.attributes['src'] ?? '';
        final String styles = node.attributes['style'] ?? '';
        final String align = node.attributes['align'] ?? '';
        final attributes = parseImageStyleAttribute(styles, align);
        if (src.isNotEmpty) {
          delta.insert(
            {'image': src},
            styles.isEmpty
                ? null
                : {
                    'style': attributes.entries
                        .map((entry) => '${entry.key}:${entry.value}')
                        .toList()
                        .join(';'),
                  },
          );
        }
      }

      // Handle <video> tags
      if (node.isVideo) {
        final String? src = node.getAttribute('src');
        final String? sourceSrc = node.nodes
            .where((node) => node.nodeType == dom.Node.ELEMENT_NODE)
            .firstOrNull
            ?.attributes['src'];
        if (src != null && src.isNotEmpty ||
            sourceSrc != null && sourceSrc.isNotEmpty) {
          delta.insert({'video': src ?? sourceSrc});
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
        delta.insert('\n');
      }
    }

    // Recursively process child nodes
    for (final child in node.nodes) {
      processNode(child, newAttributes, delta, addSpanAttrs: addSpanAttrs);
    }
  }
}
