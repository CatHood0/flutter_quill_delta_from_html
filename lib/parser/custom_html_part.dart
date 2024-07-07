import 'package:flutter_quill/quill_delta.dart';
import 'package:html/dom.dart' as dom;

/// Interface for defining a custom block handler.
abstract class CustomHtmlPart {
  /// Determines if this custom block handler matches the given HTML element.
  bool matches(dom.Element element);

  /// Converts the HTML element into Delta operations.
  List<Operation> convert(dom.Element element,
      {Map<String, dynamic>? currentAttributes});
}
