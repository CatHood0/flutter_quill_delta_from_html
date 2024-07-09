import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/html_utils.dart';
import 'package:html/dom.dart' as dom;
import 'custom_html_part.dart';

///HtmlOperations are a class that contains all necessary methods for
///Convert html (the supported ones) to valid operations for delta
abstract class HtmlOperations {
  List<CustomHtmlPart>? customBlocks;

  ///Use this method to add full logic for comparate which type html tag is the current item on loop
  ///By default this just verify and call the others methods, and override it is optional
  List<Operation> resolveCurrentElement(dom.Element element) {
    List<Operation> ops = [];
    if (element.localName == null) return ops;
    //inlines
    //the current element could be into a <li> then it's node can be
    //a <strong> or a <em>, or even a <span> then we first need to verify
    //if a inline an store into it to parse the attributes as we need
    if (isInline(element.localName!)) {
      final Delta delta = Delta();
      final Map<String, dynamic> attributes = {};
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

  void setCustomBlocks(List<CustomHtmlPart> customBlocks, {bool overrideCurrentBlocks = false}) {
    if (this.customBlocks != null && !overrideCurrentBlocks) {
      this.customBlocks!.addAll(customBlocks);
      return;
    }
    this.customBlocks = [...customBlocks];
  }
}

///Default implementation of this package to parse common html to operation
class DefaultHtmlToOperations extends HtmlOperations {
  DefaultHtmlToOperations();

  @override
  List<Operation> paragraphToOp(dom.Element element) {
    final Delta delta = Delta();
    final attributes = element.attributes;
    Map<String, dynamic> inlineAttributes = {};
    Map<String, dynamic> blockAttributes = {};
    // Process the style attribute
    if (attributes.containsKey('style') || attributes.containsKey('align') || attributes.containsKey('dir')) {
      final String style = attributes['style'] ?? '';
      final String? styles2 = attributes['align'];
      final String? styles3 = attributes['dir'];
      final styleAttributes = parseStyleAttribute(style);
      final alignAttribute = parseStyleAttribute(styles2 ?? '');
      final dirAttribute = parseStyleAttribute(styles3 ?? '');
      styleAttributes.addAll({...alignAttribute, ...dirAttribute});
      if (styleAttributes.containsKey('align') || styleAttributes.containsKey('direction')) {
        blockAttributes['align'] = styleAttributes['align'];
        blockAttributes['direction'] = styleAttributes['direction'];
        styleAttributes.remove('align');
        styleAttributes.remove('direction');
      }
      inlineAttributes.addAll(styleAttributes);
    }
    final nodes = element.nodes;
    //this store into all nodes into a paragraph, and
    //ensure getting all attributes or tags into a paragraph
    for (final node in nodes) {
      processNode(node, inlineAttributes, delta, addSpanAttrs: true, customBlocks: customBlocks);
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
      processNode(node, inlineAttributes, delta, addSpanAttrs: false, customBlocks: customBlocks);
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
      final String style = element.attributes['style'] ?? '';
      final String? styles2 = element.attributes['align'];
      final String? styles3 = element.attributes['dir'];
      final styleAttributes = parseStyleAttribute(style);
      final alignAttribute = parseStyleAttribute(styles2 ?? '');
      final dirAttribute = parseStyleAttribute(styles3 ?? '');
      styleAttributes.addAll({...alignAttribute, ...dirAttribute});
      if (styleAttributes.containsKey('align') || styleAttributes.containsKey('direction')) {
        blockAttributes['align'] = styleAttributes['align'];
        blockAttributes['direction'] = styleAttributes['direction'];
        styleAttributes.remove('align');
        styleAttributes.remove('direction');
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
  List<Operation> listToOp(dom.Element element) {
    final Delta delta = Delta();
    final tagName = element.localName ?? 'ul';
    final Map<String, dynamic> attributes = {};
    final List<dom.Element> items = element.children.where((child) => child.localName == 'li').toList();

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
      if (checkbox == null) {
        final dataChecked = item.attributes['data-checked'] ?? '';
        final blockAttrs = parseStyleAttribute(dataChecked);
        var isCheckList = item.localName == 'li' && blockAttrs.isNotEmpty && blockAttrs.containsKey('list');
        if (isCheckList) {
          attributes['list'] = blockAttrs['list'];
        }
      }
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
    final String sourceSrc =
        element.nodes.where((node) => node.nodeType == dom.Node.ELEMENT_NODE).firstOrNull?.attributes['src'] ?? '';
    if (src.isNotEmpty) {
      return [
        Operation.insert('\n'),
        Operation.insert({'video': src})
      ];
    }
    if (sourceSrc.isNotEmpty) {
      return [
        Operation.insert('\n'),
        Operation.insert({'video': sourceSrc})
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
