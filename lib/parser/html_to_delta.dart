import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
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

  /// Converts HTML tags to Delta operations based on defined rules.
  late HtmlOperations htmlToOp;

  /// Creates a new instance of HtmlToDelta.
  ///
  /// [htmlToOperations] defines how common HTML tags are converted to Delta operations.
  /// [customBlocks] allows adding custom rules for handling specific HTML tags.
  HtmlToDelta({
    HtmlOperations? htmlToOperations,
    this.customBlocks,
  }) {
    htmlToOp = htmlToOperations ?? DefaultHtmlToOperations();
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
  ///
  /// Returns:
  /// A Delta object representing the formatted content from HTML.
  ///
  /// Example:
  /// ```dart
  /// final delta = converter.convert('<p>Hello <strong>world</strong></p>');
  /// print(delta.toJson()); // Output: [{"insert":"Hello "},{"insert":"world","attributes":{"bold":true}},{"insert":"\n"}]
  /// ```
  Delta convert(String htmlText) {
    final Delta delta = Delta();
    final dom.Document $document = dparser.parse(htmlText);
    final dom.Element? $body = $document.body;
    final dom.Element? $html = $document.documentElement;

    // Determine nodes to process: <body>, <html>, or document nodes if neither is present
    final List<dom.Node> nodesToProcess = $body?.nodes ?? $html?.nodes ?? $document.nodes;

    for (var node in nodesToProcess) {
      //first just verify if the customBlocks aren't empty and then store on them to
      //validate if one of them make match with the current Node
      if (customBlocks != null && customBlocks!.isNotEmpty && node is dom.Element) {
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
      final List<Operation> operations = nodeToOperation(node, htmlToOp);
      if (operations.isNotEmpty) {
        for (final op in operations) {
          delta.insert(op.data, op.attributes);
        }
      }
    }
    //ensure insert a new line at the final to avoid any conflict with assertions
    delta.insert('\n');
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
  Delta convertDocument(dom.Document $document) {
    final Delta delta = Delta();
    final dom.Element? $body = $document.body;
    final dom.Element? $html = $document.documentElement;

    // Determine nodes to process: <body>, <html>, or document nodes if neither is present
    final List<dom.Node> nodesToProcess = $body?.nodes ?? $html?.nodes ?? $document.nodes;

    for (var node in nodesToProcess) {
      if (customBlocks != null && customBlocks!.isNotEmpty && node is dom.Element) {
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
      final List<Operation> operations = nodeToOperation(node, htmlToOp);
      if (operations.isNotEmpty) {
        for (final op in operations) {
          delta.insert(op.data, op.attributes);
        }
      }
    }
    //ensure insert a new line at the final to avoid any conflict with assertions
    delta.insert('\n');
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
  List<Operation> nodeToOperation(dom.Node node, HtmlOperations htmlToOp) {
    List<Operation> operations = [];
    if (node is dom.Text) {
      operations.add(Operation.insert(node.text.trim()));
    }
    if (node is dom.Element) {
      List<Operation> ops = htmlToOp.resolveCurrentElement(node);
      operations.addAll(ops);
    }

    return operations;
  }
}
