import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/node_ext.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_operation.dart';
import 'package:flutter_quill_delta_from_html/parser/html_utils.dart';
import 'package:flutter_quill_delta_from_html/parser/typedef/typedefs.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_quill_delta_from_html/parser/node_processor.dart';

/// Default implementation of `HtmlOperations` for converting common HTML to Delta operations.
///
/// This class provides default implementations for converting common HTML elements
/// like paragraphs, headers, lists, links, images, videos, code blocks, and blockquotes
/// into Delta operations.
class DefaultHtmlToOperations extends HtmlOperations {
  final CSSVarible? onDetectLineheightCssVariable;

  DefaultHtmlToOperations(
    this.onDetectLineheightCssVariable,
  );

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
      final styleAttributes = parseStyleAttribute(
        element.localName!,
        style,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
      final alignAttribute = parseStyleAttribute(
        element.localName!,
        styles2 ?? '',
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
      final dirAttribute = parseStyleAttribute(
        element.localName!,
        styles3 ?? '',
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
      processNode(
        node,
        inlineAttributes,
        delta,
        addSpanAttrs: true,
        customBlocks: customBlocks,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
      final styleAttributes = parseStyleAttribute(
        element.localName!,
        style ?? '',
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
      if (styleAttributes.containsKey('align')) {
        styleAttributes.remove('align');
      }
      inlineAttributes.addAll(styleAttributes);
    }
    final nodes = element.nodes;
    //this store into all nodes into a paragraph, and
    //ensure getting all attributes or tags into a paragraph
    for (final node in nodes) {
      processNode(
        node,
        inlineAttributes,
        delta,
        addSpanAttrs: false,
        customBlocks: customBlocks,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
      processNode(
        node,
        attributes,
        delta,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
      final styleAttributes = parseStyleAttribute(
        element.localName!,
        style,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
      final alignAttribute = parseStyleAttribute(
        element.localName!,
        styles2,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
      final dirAttribute = parseStyleAttribute(
        element.localName!,
        styles3,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
      processNode(
        node,
        attributes,
        delta,
        addSpanAttrs: true,
        removeTheseAttributesFromSpan: ['size'],
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
      final styleAttributes = parseStyleAttribute(
        element.localName!,
        style,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
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
        final blockAttrs = parseStyleAttribute(
          element.localName!,
          dataChecked,
          onDetectLineheightCssVariable: onDetectLineheightCssVariable,
        );
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
    final attributes = parseImageStyleAttribute(
      styles,
      element.getSafeAttribute('align'),
    );
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
      processNode(
        node,
        {},
        delta,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
    }

    delta.insert('\n', blockAttributes);

    return delta.toList();
  }

  @override
  List<Operation> codeblockToOp(dom.Element element) {
    final Delta delta = Delta();
    Map<String, dynamic> blockAttributes = {'code-block': true};

    for (final node in element.nodes) {
      processNode(
        node,
        {},
        delta,
        onDetectLineheightCssVariable: onDetectLineheightCssVariable,
      );
    }

    delta.insert('\n', blockAttributes);

    return delta.toList();
  }

  @override
  List<Operation> brToOp(dom.Element element) {
    return [Operation.insert('\n')];
  }

  @override
  List<Operation> tableToOp(
    dom.Element element, [
    bool transformTableAsEmbed = false,
  ]) {
    final Map<String, dynamic> table = <String, dynamic>{
      'headers': <String, dynamic>{},
      'rows': <String, dynamic>{},
    };
    final dom.Element? tBody = element.children.firstOrNull;
    if (transformTableAsEmbed) {
      int rowIndex = 0;
      for (final dom.Node node in (tBody ?? element).nodes) {
        final List<Operation> ops = <Operation>[];
        final bool isHeaderRow = node is dom.Element &&
            node.localName == 'tr' &&
            node.children.isNotEmpty &&
            node.children.firstOrNull?.localName == 'th';
        if (isHeaderRow) {
          int index = 0;
          final Map<String, dynamic> header = <String, dynamic>{};
          for (final dom.Element hNode in node.children) {
            if (hNode.text.isNotEmpty) {
              header['$index'] = hNode.text;
              index++;
            }
          }
          if (header.isNotEmpty) {
            table['headers'] = <String, dynamic>{
              ...header,
            };
          }
          continue;
        }
        if (node is! dom.Element && node.text != null) {
          ops.add(Operation.insert(node.text!));
          table['rows']['$rowIndex'] = <String>[
            ...ops.map<String>((
              Operation e,
            ) =>
                e.data!.toString()),
          ];
          rowIndex++;
        } else {
          final dom.Element nodeEl = node as dom.Element;
          if (nodeEl.localName == 'tr') {
            for (final dom.Element cellNodes in nodeEl.children) {
              final List<Operation> cellOps = cellNodes.localName == 'td'
                  ? paragraphToOp(cellNodes)
                  : divToOp(cellNodes);
              if (table['rows']['$rowIndex'] != null) {
                table['rows']['$rowIndex'].addAll(
                  cellOps
                      .map<String>((
                        Operation e,
                      ) =>
                          e.data!.toString())
                      .toList(),
                );
                continue;
              }
              table['rows']['$rowIndex'] = <String>[
                ...cellOps.map<String>((
                  Operation e,
                ) =>
                    e.data!.toString()),
              ];
            }
            rowIndex++;
          }
        }
      }
      return <Operation>[
        Operation.insert(<String, Map<String, dynamic>>{
          'table': table,
        })
      ];
    }

    final List<Operation> ops = <Operation>[];
    for (final dom.Node node in element.nodes) {
      if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final element = node as dom.Element;
        if (element.localName == 'td') {
          ops.addAll(paragraphToOp(element));
        } else {
          ops.addAll(divToOp(element));
        }
      }
    }

    return ops;
  }
}
