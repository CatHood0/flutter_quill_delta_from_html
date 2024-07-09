import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:html/dom.dart' as dom;

/// Interface for defining a custom block handler.
abstract class CustomHtmlPart {
  /// Determines if this custom block handler matches the given HTML element.
  /// If you want to detect, by example, a `<div>` you need to make something like
  /// `element.localName == 'div'` 
  /// And this just will match with any `<div>` tag
  bool matches(dom.Element element);

  /// Converts the `HTML` element into `Delta` operations.
  /// It's called when `matches` return true
  List<Operation> convert(dom.Element element,
      {Map<String, dynamic>? currentAttributes});
}
