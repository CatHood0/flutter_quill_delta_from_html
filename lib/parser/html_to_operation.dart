import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/html_utils.dart';
import 'package:html/dom.dart' as dom;
import 'custom_html_part.dart';

///HtmlOperations are a class that contains all necessary methods for
///Convert html (the supported ones) to valid operations for delta
abstract class HtmlOperations {
  final List<CustomHtmlPart>? customBlocks;
  const HtmlOperations({this.customBlocks});

  ///Use this method to add full logic for comparate which type html tag is the current item on loop
  List<Operation> resolveCurrentElement(dom.Element element) {
    List<Operation> ops = [];
    if (element.localName == null) return ops;
    //inlines
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
    //blocks
    if (element.isBreakLine) ops.addAll(brToOp(element));
    if (element.isParagraph) ops.addAll(paragraphToOp(element));
    if (element.isHeader) ops.addAll(headerToOp(element));
    if (element.isList) ops.addAll(listToOp(element));
    if (element.isSpan) ops.addAll(spanToOp(element));
    if (element.isLink) ops.addAll(linkToOp(element));
    if (element.isImg) ops.addAll(imgToOp(element));
    if (element.isVideo) ops.addAll(videoToOp(element));
    if (element.isBlockquote) ops.addAll(blockquoteToOp(element));
    if (element.isCodeBlock) ops.addAll(codeblockToOp(element));
    return ops;
  }

  ///Add a new line by default
  List<Operation> brToOp(dom.Element element);

  ///Used when detect a header html tag
  List<Operation> headerToOp(dom.Element element);

  ///Used when detect a list html tag (ul, li, ol,<input type="checkbox">)
  List<Operation> listToOp(dom.Element element);

  ///Used when detect a paragraph html tag <p>
  List<Operation> paragraphToOp(dom.Element element);

  ///Used when detect a link html tag <a>
  List<Operation> linkToOp(dom.Element element);

  ///Used when detect a link html tag <span>
  List<Operation> spanToOp(dom.Element element);

  ///Used when detect a link html tag <img>
  List<Operation> imgToOp(dom.Element element);

  ///Used when detect a link html tag <video>
  List<Operation> videoToOp(dom.Element element);

  ///Used when detect a link html tag <pre>
  List<Operation> codeblockToOp(dom.Element element);

  ///Used when detect a link html tag <blockquote>
  List<Operation> blockquoteToOp(dom.Element element);
}

///Represents a default implementation of this package to parse html to operation
class DefaultHtmlToOperations extends HtmlOperations {
  const DefaultHtmlToOperations({super.customBlocks});

  @override
  List<Operation> paragraphToOp(dom.Element element) {
    final Delta delta = Delta();
    final attributes = element.attributes;
    Map<String, dynamic> inlineAttributes = {};
    Map<String, dynamic> blockAttributes = {};
    // Process the style attribute
    if (attributes.containsKey('style')) {
      final String style = element.attributes['style']!;
      final styleAttributes = parseStyleAttribute(style);
      if (styleAttributes.containsKey('align')) {
        blockAttributes['align'] = styleAttributes['align'];
        styleAttributes.remove('align');
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
      final String style = element.attributes['style'] ?? '';
      final styleAttributes = parseStyleAttribute(style);
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

    if (element.attributes.containsKey('style')) {
      final String style = element.attributes['style']!;
      final styleAttributes = parseStyleAttribute(style);
      if (styleAttributes.containsKey('align')) {
        blockAttributes['align'] = styleAttributes['align'];
        styleAttributes.remove('align');
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
    delta.insert('\n', blockAttributes);
    return delta.toList();
  }

  @override
  List<Operation> listToOp(dom.Element element) {
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
    for (final item in items) {
      for (final node in item.nodes) {
        if (node.nodeType == dom.Node.TEXT_NODE) {
          delta.insert(node.text);
        } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
          final ops = resolveCurrentElement(node as dom.Element);
          for (final op in ops) {
            delta.insert(op.data, op.attributes);
          }
        }
      }
      delta.insert('\n', attributes);
    }

    return delta.toList();
  }

  @override
  List<Operation> imgToOp(dom.Element element) {
    final String src = element.attributes['src'] ?? '';
    if (src.isNotEmpty) {
      return [
        Operation.insert({'image': src})
      ];
    }
    return [];
  }

  @override
  List<Operation> videoToOp(dom.Element element) {
    final String src = element.attributes['src'] ?? '';
    if (src.isNotEmpty) {
      return [
        Operation.insert('\n'),
        Operation.insert({'video': src})
      ];
    }
    return [];
  }

  @override
  List<Operation> blockquoteToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> attributes = {'blockquote': true};

    for (final node in element.nodes) {
      processNode(node, attributes, delta);
    }

    delta.insert('\n', attributes);

    return delta.toList();
  }

  @override
  List<Operation> codeblockToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> attributes = {'code-block': true};

    for (final node in element.nodes) {
      processNode(node, attributes, delta);
    }

    delta.insert('\n', attributes);

    return delta.toList();
  }

  @override
  List<Operation> brToOp(dom.Element element) {
    return [Operation.insert('\n')];
  }
}
