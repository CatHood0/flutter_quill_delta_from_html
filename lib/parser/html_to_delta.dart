import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_delta_from_html/parser/default_html_to_ops.dart';
import 'package:flutter_quill_delta_from_html/parser/extensions/string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as dparser;

/// Default converter for html to Delta
class HtmlToDelta {
  /// List of custom HTML parts to handle non-common HTML tags.
  ///
  /// These custom blocks define how to convert specific HTML tags into Delta operations.
  ///
  /// Example:
  /// ```dart
  /// final converter = HtmlToDelta(customBlocks: [
  ///   MyCustomHtmlPart(
  ///     matches: (element) => element.localName == 'my-custom-tag',
  ///     convert: (element) {
  ///       return [
  ///         Operation.insert({"custom-tag": element.text})
  ///       ];
  ///     },
  ///   ),
  /// ]);
  /// ```
  final List<CustomHtmlPart>? customBlocks;

  /// When a variable of CSS is detected, this is called
  /// to avoid just putting a default unwanted value.
  final CSSVarible? onDetectLineheightCssVariable;

  /// Converts HTML tags to Delta operations based on defined rules.
  late HtmlOperations htmlToOp;

  /// This is a list that must contains only the tag name
  /// of the all HTML Nodes (`<p>`, `<div>` or `<h1>`) that will be
  /// ignored and inserted as plain text
  ///
  /// # Example
  /// Assume that you want to ignore just HTML containers. Then just need
  /// to do something like this:
  /// __
  /// ```dart
  /// final List containerBlackList = ['div', 'section', 'article'];
  ///
  /// final converter = HtmlToDelta(blackNodesList: containerBlackList);
  /// final delta = converter.convert(<your_html>);
  /// ```
  final List<String> blackNodesList;

  /// Replace all new lines (\n) to `<br>`
  ///
  /// You will need to ensure of your html content **has not**
  /// wrapped into a `<html>` or `<body>` tags
  /// because this will replace all ones, without
  /// ensure if the tag to the left of the new line
  /// is a common tags (`<p>`,`<li>`,`<h1>`,etc) or a body tags
  final bool replaceNormalNewLinesToBr;

  /// Function to determine if a new line should be inserted after a node.
  final bool Function(String localName)? shouldInsertANewLine;

  /// Function to determine if a node is a block element.
  final bool Function(String localName)? isBlockValidator;

  /// Creates a new instance of HtmlToDelta.
  ///
  /// [htmlToOperations] defines how common HTML tags are converted to Delta operations.
  /// [customBlocks] allows adding custom rules for handling specific HTML tags.
  HtmlToDelta({
    HtmlOperations? htmlToOperations,
    this.blackNodesList = const [],
    this.customBlocks,
    this.shouldInsertANewLine,
    this.isBlockValidator,
    this.replaceNormalNewLinesToBr = false,
    this.onDetectLineheightCssVariable,
  }) {
    htmlToOp = htmlToOperations ??
        DefaultHtmlToOperations(onDetectLineheightCssVariable);
    //this part ensure to set the customBlocks passed at the constructor
    htmlToOp.setCustomBlocks(customBlocks ?? []);
  }

  /// Converts an HTML string into Delta operations.
  ///
  /// Converts the HTML string [htmlText] into Delta operations using QuillJS-compatible attributes.
  /// Custom blocks can be applied based on registered [customBlocks].
  ///
  /// Parameters:
  /// - [htmlText]: The HTML string to convert into Delta operations.
  /// - [transformTableAsEmbed]: Determine if the table will be inserted as an embed or a simple paragraph.
  ///
  /// Returns:
  /// A Delta object representing the formatted content from HTML.
  ///
  /// Example:
  /// ```dart
  /// final delta = converter.convert('<p>Hello <strong>world</strong></p>');
  /// print(delta.toJson()); // Output: [{"insert":"Hello "},{"insert":"world","attributes":{"bold":true}},{"insert":"\n"}]
  /// ```
  Delta convert(
    String htmlText, {
    bool transformTableAsEmbed = false,
  }) {
    final parsedText = htmlText
        .split('\n')
        .map(
          (e) => e.trim(),
        )
        .join()
        .removeAllNewLines;
    final Delta delta = Delta();
    final dom.Document $document = dparser.parse(replaceNormalNewLinesToBr
        ? parsedText.transformNewLinesToBrTag
        : parsedText);
    final dom.Element? $body = $document.body;
    final dom.Element? $html = $document.documentElement;

    // Determine nodes to process: <body>, <html>, or document nodes if neither is present
    final List<dom.Node> nodesToProcess =
        $body?.nodes ?? $html?.nodes ?? $document.nodes;

    for (int i = 0; i < nodesToProcess.length; i++) {
      dom.Node node = nodesToProcess[i];
      //first just verify if the customBlocks aren't empty and then store on them to
      //validate if one of them make match with the current Node
      if (customBlocks != null &&
          customBlocks!.isNotEmpty &&
          node is dom.Element) {
        for (CustomHtmlPart customBlock in customBlocks!) {
          if (customBlock.matches(node)) {
            final operations = customBlock.convert(node);
            operations.forEach((Operation op) {
              delta.insert(op.data, op.attributes);
            });
            continue;
          }
        }
      }
      final dom.Node? nextNode = nodesToProcess.elementAtOrNull(i + 1);

      bool nextIsBlock = nextNode is dom.Element ? nextNode.isBlock : false;
      if (isBlockValidator != null) {
        nextIsBlock = isBlockValidator?.call(nextNode is dom.Element
                ? nextNode.localName ?? 'no-localname'
                : 'text-node') ??
            false;
      }

      final List<Operation> operations = nodeToOperation(
        node,
        htmlToOp,
        nextIsBlock,
        transformTableAsEmbed,
      );

      if (operations.isNotEmpty) {
        for (final op in operations) {
          delta.insert(op.data, op.attributes);
        }
      }
      final bool? shouldInsertNewLine = shouldInsertANewLine?.call(
          node is dom.Element ? node.localName ?? 'no-localname' : 'text-node');
      if (shouldInsertNewLine != null && shouldInsertNewLine) {
        delta.insert('\n');
      }
    }
    //ensure insert a new line at the final to avoid any conflict with assertions
    if (delta.isNotEmpty) {
      final Operation lastOpdata = delta.last;
      final bool lastDataIsNotNewLine = lastOpdata.data.toString() != '\n';
      final bool hasAttributes = lastOpdata.attributes != null;
      if (lastDataIsNotNewLine && hasAttributes ||
          lastDataIsNotNewLine ||
          !lastDataIsNotNewLine && hasAttributes) {
        delta.insert('\n');
      }
    }
    return delta;
  }

  /// Converts a full DOM document into Delta operations.
  ///
  /// Processes the entire DOM document [$document] and converts its nodes into Delta operations.
  /// Custom blocks can be applied based on registered [customBlocks].
  ///
  /// Parameters:
  /// - [$document]: The DOM document to convert into Delta operations.
  ///
  /// Returns:
  /// A Delta object representing the formatted content from the DOM document.
  ///
  /// Example:
  /// ```dart
  /// final document = dparser.parse('<p>Hello <strong>world</strong></p>');
  /// final delta = converter.convertDocument(document);
  /// print(delta.toJson()); // Output: [{"insert":"Hello "},{"insert":"world","attributes":{"bold":true}},{"insert":"\n"}]
  /// ```
  Delta convertDocument(
    dom.Document $document, {
    bool transformTableAsEmbed = false,
  }) {
    final Delta delta = Delta();
    final dom.Element? $body = $document.body;
    final dom.Element? $html = $document.documentElement;

    // Determine nodes to process: <body>, <html>, or document nodes if neither is present
    final List<dom.Node> nodesToProcess =
        $body?.nodes ?? $html?.nodes ?? $document.nodes;

    for (int i = 0; i < nodesToProcess.length; i++) {
      dom.Node node = nodesToProcess[i];
      if (customBlocks != null &&
          customBlocks!.isNotEmpty &&
          node is dom.Element) {
        for (var customBlock in customBlocks!) {
          if (customBlock.matches(node)) {
            final operations = customBlock.convert(node);
            operations.forEach((Operation op) {
              delta.insert(op.data, op.attributes);
            });
            continue;
          }
        }
      }
      final dom.Node? nextNode = nodesToProcess.elementAtOrNull(i + 1);
      bool nextIsBlock = nextNode == null
          ? false
          : nextNode is! dom.Element
              ? false
              : nextNode.isBlock;
      if (isBlockValidator != null) {
        nextIsBlock = isBlockValidator?.call(nextNode is dom.Element
                ? nextNode.localName ?? 'no-localname'
                : 'text-node') ??
            false;
      }
      final List<Operation> operations = nodeToOperation(
        node,
        htmlToOp,
        nextIsBlock,
        transformTableAsEmbed,
      );
      if (operations.isNotEmpty) {
        for (final op in operations) {
          delta.insert(op.data, op.attributes);
        }
      }
      final bool? shouldInsertNewLine = shouldInsertANewLine?.call(
          node is dom.Element ? node.localName ?? 'no-localname' : 'text-node');
      if (shouldInsertNewLine != null && shouldInsertNewLine) {
        delta.insert('\n');
      }
    }
    //ensure insert a new line at the final to avoid any conflict with assertions
    final Operation lastOpdata = delta.last;
    final bool lastDataIsNotNewLine = lastOpdata.data.toString() != '\n';
    final bool hasAttributes = lastOpdata.attributes != null;
    if (lastDataIsNotNewLine && hasAttributes ||
        lastDataIsNotNewLine ||
        !lastDataIsNotNewLine && hasAttributes) {
      delta.insert('\n');
    }
    return delta;
  }

  /// Converts a single DOM node into Delta operations using [htmlToOp].
  ///
  /// Processes a single DOM [node] and converts it into Delta operations using the provided [htmlToOp] instance.
  ///
  /// Parameters:
  /// - [node]: The DOM node to convert into Delta operations.
  ///
  /// Returns:
  /// A list of Operation objects representing the formatted content of the node.
  ///
  /// Example:
  /// ```dart
  /// final node = dparser.parseFragment('<strong>Hello</strong>');
  /// final operations = converter.nodeToOperation(node.firstChild!, converter.htmlToOp);
  /// print(operations); // Output: [Operation{insert: "Hello", attributes: {bold: true}}]
  /// ```
  List<Operation> nodeToOperation(
    dom.Node node,
    HtmlOperations htmlToOp, [
    bool nextIsBlock = false,
    bool transformTableAsEmbed = false,
  ]) {
    List<Operation> operations = [];
    if (node is dom.Text) {
      operations.add(Operation.insert(node.text));
    }
    if (node is dom.Element) {
      if (blackNodesList.contains(node.localName)) {
        if (nextIsBlock) operations.add(Operation.insert('\n'));
        operations.add(Operation.insert(node.text));
        return operations;
      }
      List<Operation> ops = htmlToOp.resolveCurrentElement(
        node,
        0,
        transformTableAsEmbed,
      );
      operations.addAll(ops);
      // Check if the nextElement is a block AND if the last
      // operation already has a new line, this would otherwise
      // create a double new line
      if (nextIsBlock && operations.lastOrNull?.data != '\n') {
        operations.add(Operation.insert('\n'));
      }
    }

    return operations;
  }
}
