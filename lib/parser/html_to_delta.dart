import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/html_utils.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as dparser;

import 'html_to_operation.dart';

/// Default converter for html to Delta
/// By now is an [experimental] API and must not be used in
/// Production code since it is too far from being stable and usable for devs
class HtmlToDelta {
  ///by now is not used 
  final List<Operation>? Function(dom.Element element)? customTagCallback;
  final HtmlOperations htmlToOp;

  HtmlToDelta({
    this.htmlToOp = const DefaultHtmlToOperations(),
    this.customTagCallback,
  });

  Delta convert(String htmlText) {
    final Delta delta = Delta();
    final dom.Document $document = dparser.parse(htmlText);
    final dom.Element? $body = $document.body;
    final dom.Element? $html = $document.documentElement;

    // Determine nodes to process: <body>, <html>, or document nodes if neither is present
    final List<dom.Node> nodesToProcess = $body?.nodes ?? $html?.nodes ?? $document.nodes;

    for (var node in nodesToProcess) {
      final List<Operation> operations = nodeToOperation(node, htmlToOp, customTagCallback);
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
}
