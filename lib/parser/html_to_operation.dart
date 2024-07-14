import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/html_utils.dart';
import 'package:html/dom.dart' as dom;
import 'custom_html_part.dart';
import 'package:flutter_quill_delta_from_html/parser/node_processor.dart';

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
  List<Operation> resolveCurrentElement(dom.Element element,
      [int indentLevel = 0]) {
    List<Operation> ops = [];
    if (element.localName == null)
      return ops..add(Operation.insert(element.text));
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

/// Default implementation of `HtmlOperations` for converting common HTML to Delta operations.
///
/// This class provides default implementations for converting common HTML elements
/// like paragraphs, headers, lists, links, images, videos, code blocks, and blockquotes
/// into Delta operations.
class DefaultHtmlToOperations extends HtmlOperations {
  DefaultHtmlToOperations();

  @override
  List<Operation> paragraphToOp(dom.Element element) {
    final Delta delta = Delta();
    final attributes = element.attributes;
    Map<String, dynamic> inlineAttributes = {};
    Map<String, dynamic> blockAttributes = {};
    // Process the style attribute
    if (attributes.containsKey('style') ||
        attributes.containsKey('align') ||
        attributes.containsKey('dir')) {
      final String style = attributes['style'] ?? '';
      final String? styles2 = attributes['align'];
      final String? styles3 = attributes['dir'];
      final styleAttributes = parseStyleAttribute(style);
      final alignAttribute = parseStyleAttribute(styles2 ?? '');
      final dirAttribute = parseStyleAttribute(styles3 ?? '');
      styleAttributes.addAll({...alignAttribute, ...dirAttribute});
      if (styleAttributes.containsKey('align') ||
          styleAttributes.containsKey('direction') ||
          styleAttributes.containsKey('indent')) {
        blockAttributes['align'] = styleAttributes['align'];
        blockAttributes['direction'] = styleAttributes['direction'];
        blockAttributes['indent'] = styleAttributes['indent'];
        styleAttributes.remove('align');
        styleAttributes.remove('direction');
        styleAttributes.remove('indent');
      }
      inlineAttributes.addAll(styleAttributes);
    }
    final nodes = element.nodes;
    //this store into all nodes into a paragraph, and
    //ensure getting all attributes or tags into a paragraph
    for (final node in nodes) {
      processNode(node, inlineAttributes, delta,
          addSpanAttrs: true, customBlocks: customBlocks);
    }
    if (blockAttributes.isNotEmpty) {
      blockAttributes.removeWhere((key, value) => value == null);
      delta.insert('\n', blockAttributes);
    }

    return delta.toList();
  }

  @override
  List<Operation> spanToOp(dom.Element element) {
    final Delta delta = Delta();
    final attributes = element.attributes;
    Map<String, dynamic> inlineAttributes = {};
    // Process the style attribute
    if (attributes.containsKey('style')) {
      final String? style = attributes['style'];
      final styleAttributes = parseStyleAttribute(style ?? '');
      if (styleAttributes.containsKey('align')) {
        styleAttributes.remove('align');
      }
      inlineAttributes.addAll(styleAttributes);
    }
    final nodes = element.nodes;
    //this store into all nodes into a paragraph, and
    //ensure getting all attributes or tags into a paragraph
    for (final node in nodes) {
      processNode(node, inlineAttributes, delta,
          addSpanAttrs: false, customBlocks: customBlocks);
    }

    return delta.toList();
  }

  @override
  List<Operation> linkToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> attributes = {};

    if (element.attributes.containsKey('href')) {
      attributes['link'] = element.attributes['href'];
    }

    final nodes = element.nodes;
    for (final node in nodes) {
      processNode(node, attributes, delta);
    }

    return delta.toList();
  }

  @override
  List<Operation> headerToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> attributes = {};
    Map<String, dynamic> blockAttributes = {};

    if (element.attributes.containsKey('style') ||
        element.attributes.containsKey('align') ||
        element.attributes.containsKey('dir')) {
      final String style = element.getSafeAttribute('style');
      final String styles2 = element.getSafeAttribute('align');
      final String styles3 = element.getSafeAttribute('dir');
      final styleAttributes = parseStyleAttribute(style);
      final alignAttribute = parseStyleAttribute(styles2);
      final dirAttribute = parseStyleAttribute(styles3);
      styleAttributes.addAll({...alignAttribute, ...dirAttribute});
      if (styleAttributes.containsKey('align') ||
          styleAttributes.containsKey('direction') ||
          styleAttributes.containsKey('indent')) {
        blockAttributes['align'] = styleAttributes['align'];
        blockAttributes['direction'] = styleAttributes['direction'];
        blockAttributes['indent'] = styleAttributes['indent'];
        styleAttributes.remove('align');
        styleAttributes.remove('direction');
        styleAttributes.remove('indent');
      }
      attributes.addAll(styleAttributes);
    }

    final headerLevel = element.localName ?? 'h1';
    blockAttributes['header'] = int.parse(headerLevel.substring(1));

    final nodes = element.nodes;
    for (final node in nodes) {
      processNode(node, attributes, delta);
    }
    // Ensure a newline is added at the end of the header with the correct attributes
    if (blockAttributes.isNotEmpty) {
      blockAttributes.removeWhere((key, value) => value == null);
      delta.insert('\n', blockAttributes);
    }
    return delta.toList();
  }

  @override
  List<Operation> divToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> attributes = {};

    if (element.attributes.containsKey('style')) {
      final String style = element.attributes['style']!;
      final styleAttributes = parseStyleAttribute(style);
      attributes.addAll(styleAttributes);
    }
    for (final node in element.nodes) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        delta.insert(node.text);
      } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final ops = resolveCurrentElement(node as dom.Element);
        for (final op in ops) {
          delta.insert(op.data, op.attributes);
        }
        if (node.isParagraph) {
          delta.insert('\n');
        }
      }
    }

    return delta.toList();
  }

  @override
  List<Operation> listToOp(dom.Element element, [int indentLevel = 0]) {
    final Delta delta = Delta();
    final tagName = element.localName ?? 'ul';
    final Map<String, dynamic> attributes = {};
    final List<dom.Element> items =
        element.children.where((child) => child.localName == 'li').toList();

    if (tagName == 'ul') {
      attributes['list'] = 'bullet';
    } else if (tagName == 'ol') {
      attributes['list'] = 'ordered';
    }
    var checkbox = element.querySelector('input[type="checkbox"]');
    if (checkbox != null) {
      // If a checkbox is found, determine if it's checked
      bool isChecked = checkbox.attributes.containsKey('checked');
      if (isChecked) {
        attributes['list'] = 'checked';
      } else {
        attributes['list'] = 'unchecked';
      }
    }
    bool ignoreBlockAttributesInsertion = false;
    for (final item in items) {
      ignoreBlockAttributesInsertion = false;
      int indent = indentLevel;
      if (checkbox == null) {
        final dataChecked = item.getSafeAttribute('data-checked');
        final blockAttrs = parseStyleAttribute(dataChecked);
        var isCheckList = item.localName == 'li' &&
            blockAttrs.isNotEmpty &&
            blockAttrs.containsKey('list');
        if (isCheckList) {
          attributes['list'] = blockAttrs['list'];
        }
      }
      // force always the max level indentation to be five
      if (indentLevel > 5) indentLevel = 5;
      if (indentLevel > 0) attributes['indent'] = indentLevel;
      for (final node in item.nodes) {
        if (node.nodeType == dom.Node.TEXT_NODE) {
          delta.insert(node.text);
        } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
          final element = node as dom.Element;
          List<Operation> ops = [];
          // if found, a element list, into another list, then this is a nested and must insert first the block attributes
          // to separate the current element from the nested list elements
          if (element.isList) {
            indent++;
            ignoreBlockAttributesInsertion = true;
            delta.insert('\n', attributes);
          }
          ops.addAll(resolveCurrentElement(element, indent));
          for (final op in ops) {
            delta.insert(op.data, op.attributes);
          }
        }
      }
      if (!ignoreBlockAttributesInsertion) {
        delta.insert('\n', attributes);
      }
    }

    return delta.toList();
  }

  @override
  List<Operation> imgToOp(dom.Element element) {
    final String src = element.getSafeAttribute('src');
    final String styles = element.getSafeAttribute('style');
    final attributes =
        parseImageStyleAttribute(styles, element.getSafeAttribute('align'));
    if (src.isNotEmpty) {
      return [
        Operation.insert(
          {'image': src},
          styles.isEmpty
              ? null
              : {
                  'style': attributes.entries
                      .map((entry) => '${entry.key}:${entry.value}')
                      .toList()
                      .join(';'),
                },
        )
      ];
    }
    return [];
  }

  @override
  List<Operation> videoToOp(dom.Element element) {
    final String? src = element.getAttribute('src');
    final String? sourceSrc = element.nodes
        .where((node) => node.nodeType == dom.Node.ELEMENT_NODE)
        .firstOrNull
        ?.attributes['src'];
    if (src != null && src.isNotEmpty ||
        sourceSrc != null && sourceSrc.isNotEmpty) {
      return [
        Operation.insert({'video': src ?? sourceSrc})
      ];
    }
    return [];
  }

  @override
  List<Operation> blockquoteToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> blockAttributes = {'blockquote': true};

    for (final node in element.nodes) {
      processNode(node, {}, delta);
    }

    delta.insert('\n', blockAttributes);

    return delta.toList();
  }

  @override
  List<Operation> codeblockToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> blockAttributes = {'code-block': true};

    for (final node in element.nodes) {
      processNode(node, {}, delta);
    }

    delta.insert('\n', blockAttributes);

    return delta.toList();
  }

  @override
  List<Operation> brToOp(dom.Element element) {
    return [Operation.insert('\n')];
  }
}
