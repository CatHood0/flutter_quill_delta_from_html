import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as dparser;

/// Default converter for html to Delta
class HtmlToDelta {
  ///Defines all custom blocks for non common html tags
  final List<CustomHtmlPart>? customBlocks;

  ///Defines how will be builded the common tags to Delta Operations
  late HtmlOperations htmlToOp;

  HtmlToDelta({
    HtmlOperations? htmlToOperations,
    this.customBlocks,
  }) {
    htmlToOp = htmlToOperations ?? DefaultHtmlToOperations();
    htmlToOp.setCustomBlocks(customBlocks ?? []);
  }

  /// Converts HTML text into Delta operations.
  ///
  /// Takes an HTML string [htmlText] and converts it into Delta operations using
  /// QuillJS-compatible attributes. Custom blocks can be applied based on registered
  /// [customBlocks]. Returns a Delta object representing the formatted content
  Delta convert(String htmlText) {
    final Delta delta = Delta();
    final dom.Document $document = dparser.parse(htmlText);
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

  /// Converts a full DOM document [document] into Delta operations.
  ///
  /// Processes the entire DOM document [document] and converts its nodes into Delta
  /// operations using QuillJS-compatible attributes. Custom blocks can be applied
  /// based on registered [customBlocks]. Returns a Delta object representing the
  /// formatted content.
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

  /// Converts a single DOM [node] into Delta operations using [htmlToOp].
  ///
  /// Processes a single DOM node [node] and converts it into Delta operations
  /// using the provided [htmlToOp] instance. Returns a list of Operation objects
  /// representing the formatted content
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
