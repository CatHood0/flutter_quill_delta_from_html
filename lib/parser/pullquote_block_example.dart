import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:html/dom.dart' as dom;

/// Custom block handler for '<pullquote>' HTML elements.
///
/// This class handles conversion of '<pullquote>' elements in HTML to Delta operations
/// for use in Flutter Quill. It detects '<pullquote>' elements and converts them into
/// formatted text with optional attributes.
class PullquoteBlock extends CustomHtmlPart {
  /// Determines if the given HTML element matches the '<pullquote>' block criteria.
  ///
  /// Parameters:
  /// - [element]: The HTML element to evaluate.
  ///
  /// Returns:
  /// `true` if the element matches the '<pullquote>' block criteria (has localName '<pullquote>'),
  /// otherwise `false`.
  @override
  bool matches(dom.Element element) {
    return element.localName == 'pullquote';
  }

  /// Converts a 'pullquote' HTML element into Delta operations.
  ///
  /// Parameters:
  /// - [element]: The 'pullquote' HTML element to convert.
  /// - [currentAttributes]: Optional map of current attributes to apply to the Delta operation.
  ///
  /// Returns:
  /// A list of Delta operations representing the converted 'pullquote' element.
  ///
  /// Example:
  /// ```dart
  /// final element = dom.Element.html('<pullquote data-author="John Doe">This is a pullquote</pullquote>');
  /// final operations = PullquoteBlock().convert(element);
  /// ```
  @override
  List<Operation> convert(dom.Element element, {Map<String, dynamic>? currentAttributes}) {
    final Delta delta = Delta();
    final Map<String, dynamic> attributes = currentAttributes != null ? Map.from(currentAttributes) : {};

    final author = element.attributes['data-author'];
    final style = element.attributes['data-style'];

    // Build the text content of the pullquote
    String text = 'Pullquote: "${element.text}"';
    if (author != null) {
      text += ' by $author';
    }

    // Apply formatting based on 'data-style' attribute
    if (style != null && style.toLowerCase() == 'italic') {
      attributes['italic'] = true;
    }

    // Insert the formatted text into Delta operations
    delta.insert(text, attributes);
    delta.insert('\n'); // Ensure a newline after the pullquote

    return delta.toList();
  }
}
