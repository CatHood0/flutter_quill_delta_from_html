import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/html_utils.dart';
import 'package:flutter_quill_delta_from_html/parser/node_processor.dart';
import 'package:html/dom.dart' as dom;

import 'custom_html_part.dart';

/// Operations for converting supported HTML elements to Delta operations.
///
/// This abstract class defines methods for converting various HTML elements
/// into Delta operations, which are used for rich text editing.
abstract class HtmlOperations {
  List<CustomHtmlPart>? customBlocks;

  /// Resolves the current HTML element into Delta operations.
  ///
  /// Determines the type of HTML element and converts it into corresponding Delta operations.
  ///
  /// Parameters:
  /// - [element]: The HTML element to convert into Delta operations.
  ///
  /// Returns:
  /// A list of Delta operations corresponding to the HTML element.
  List<Operation> resolveCurrentElement(
    dom.Element element, [
    int indentLevel = 0,
    bool transformTableAsEmbed = false,
  ]) {
    List<Operation> ops = [];
    if (element.localName == null) {
      return ops..add(Operation.insert(element.text));
    }
    // Inlines
    //
    // the current element could be into a <li> then it's node can be
    // a <strong> or a <em>, or even a <span> then we first need to verify
    // if a inline an store into it to parse the attributes as we need
    if (isInline(element.localName!)) {
      final Delta delta = Delta();
      final Map<String, dynamic> attributes = {};
      if (element.isStrong) attributes['bold'] = true;
      if (element.isItalic) attributes['italic'] = true;
      if (element.isUnderline) attributes['underline'] = true;
      if (element.isStrike) attributes['strike'] = true;
      if (element.isSubscript) attributes['script'] = 'sub';
      if (element.isSuperscript) attributes['script'] = 'super';
      if (element.attributes.containsKey('style')) {
        final styleAttributes = parseStyleAttribute(
          element.localName!,
          element.attributes['style']!,
        );
        if (styleAttributes.containsKey('align')) {
          styleAttributes.remove('align');
        }
        attributes.addAll(styleAttributes);
      }
      for (final node in element.nodes) {
        processNode(node, attributes, delta, customBlocks: customBlocks);
      }
      ops.addAll(delta.toList());
    }
    // Blocks
    if (element.isBreakLine) ops.addAll(brToOp(element));
    if (element.isParagraph) ops.addAll(paragraphToOp(element));
    if (element.isHeader) ops.addAll(headerToOp(element));
    if (element.isList) ops.addAll(listToOp(element, indentLevel));
    if (element.isSpan) ops.addAll(spanToOp(element));
    if (element.isLink) ops.addAll(linkToOp(element));
    if (element.isImg) ops.addAll(imgToOp(element));
    if (element.isVideo) ops.addAll(videoToOp(element));
    if (element.isBlockquote) ops.addAll(blockquoteToOp(element));
    if (element.isCodeBlock) ops.addAll(codeblockToOp(element));
    if (element.isDivBlock) ops.addAll(divToOp(element));
    if (element.isTable) {
      ops.addAll(tableToOp(
        element,
        transformTableAsEmbed,
      ));
    }
    return ops;
  }

  /// Converts a `<br>` HTML element to Delta operations.
  List<Operation> brToOp(dom.Element element);

  /// Converts a header HTML element (`<h1>` to `<h6>`) to Delta operations.
  List<Operation> headerToOp(dom.Element element);

  /// Converts list HTML elements (`<ul>`, `<ol>`, `<li>`) to Delta operations.
  List<Operation> listToOp(dom.Element element, [int indentLevel = 0]);

  /// Converts a paragraph HTML element (`<p>`) to Delta operations.
  List<Operation> paragraphToOp(dom.Element element);

  /// Converts a link HTML element (`<a>`) to Delta operations.
  List<Operation> linkToOp(dom.Element element);

  /// Converts a span HTML element (`<span>`) to Delta operations.
  List<Operation> spanToOp(dom.Element element);

  /// Converts an image HTML element (`<img>`) to Delta operations.
  List<Operation> imgToOp(dom.Element element);

  /// Converts a video HTML element (`<video>`) to Delta operations.
  List<Operation> videoToOp(dom.Element element);

  /// Converts a code block HTML element (`<pre>`) to Delta operations.
  List<Operation> codeblockToOp(dom.Element element);

  /// Converts a blockquote HTML element (`<blockquote>`) to Delta operations.
  List<Operation> blockquoteToOp(dom.Element element);

  /// Converts a div HTML element (`<div>`) to Delta operations.
  List<Operation> divToOp(dom.Element element);

  /// Converts a table HTML element (`<table>`) to Delta operations.
  List<Operation> tableToOp(dom.Element element,
      [bool transformTableAsEmbed = false]);

  /// Sets custom HTML parts to extend the conversion capabilities.
  ///
  /// Parameters:
  /// - [customBlocks]: List of custom HTML parts to add.
  /// - [overrideCurrentBlocks]: Flag to override existing custom blocks.
  void setCustomBlocks(List<CustomHtmlPart> customBlocks,
      {bool overrideCurrentBlocks = false}) {
    if (this.customBlocks != null && !overrideCurrentBlocks) {
      this.customBlocks!.addAll(customBlocks);
      return;
    }
    this.customBlocks = [...customBlocks];
  }
}
