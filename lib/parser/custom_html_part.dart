import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:html/dom.dart' as dom;

/// Interface for defining a custom block handler for HTML to Delta conversion.
abstract class CustomHtmlPart {
  /// Determines if this custom block handler matches the given HTML element.
  ///
  /// Implement this method to specify the conditions under which this handler
  /// should be used to convert an HTML element to Delta operations.
  ///
  /// Parameters:
  /// - [element]: The HTML element to evaluate.
  ///
  /// Returns:
  /// `true` if this handler should be used for the given HTML element, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// class MyCustomBlock implements CustomHtmlPart {
  ///   bool matches(dom.Element element) {
  ///     return element.localName == 'div' && element.classes.contains('my-custom-class');
  ///   }
  /// }
  /// ```
  bool matches(dom.Element element);

  /// Converts the HTML element into Delta operations.
  ///
  /// Implement this method to convert the matched HTML element into a list of Delta operations.
  ///
  /// Parameters:
  /// - [element]: The HTML element to convert.
  /// - [currentAttributes]: Optional. The current attributes to apply to the Delta operations.
  ///
  /// Returns:
  /// A list of Delta operations representing the converted content of the HTML element.
  ///
  /// Example:
  /// ```dart
  /// class MyCustomBlock implements CustomHtmlPart {
  ///   List<Operation> convert(dom.Element element, {Map<String, dynamic>? currentAttributes}) {
  ///     // Conversion logic here
  ///   }
  /// }
  /// ```
  List<Operation> convert(dom.Element element,
      {Map<String, dynamic>? currentAttributes});
}
