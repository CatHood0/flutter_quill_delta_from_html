# Flutter Quill Delta from HTML

This is a **Dart** package that converts **HTML** input into Quill **Delta** format, which is used in the `flutter_quill` package. This allows developers to easily convert `HTML` content to a format that can be displayed and edited using the **Quill rich text** editor in Flutter applications.

**This package** supports the conversion of a wide range of **HTML** tags and attributes into their corresponding **Delta** operations, ensuring that your **HTML** content is accurately represented in the **Quill editor**.

## Supported tags

```html
    <!--Text Formatting-->
        <b>, <strong>: Bold text 
        <i>, <em>: Italic text
        <u>, <ins>: Underlined text
        <s>, <del>: Strikethrough text
        <sup>: Superscript text
        <sub>: Subscript text

    <!--Headings-->
        <h1> to <h6>: Headings of various levels

    <!--Lists and nested ones-->
        <ul>: Unordered lists
        <ol>: Ordered lists
        <li>: List items
        <li data-checked="true">: Check lists 
        <input type="checkbox">: Another alternative to make a check lists

    <!--Links-->
        <a>: Hyperlinks with support for the href attribute

    <!--Images-->
        <img>: Images with support for the src

    <!--div-->
        <div>: HTML tag containers
        
    <!--Videos -->
        <iframe>, <video>: Videos with support for the src

    <!--Blockquotes-->
        <blockquote>: Block quotations

    <!--Code Blocks-->
        <pre>, <code>: Code blocks

    <!--Text Alignment, inline text align and direction-->
        <p style="text-align:left|center|right|justify">: Paragraph style alignment
        <p align="left|center|right|justify">: Paragraph alignment
        <p dir="rtl">: Paragraph direction 

    <!--Text attributes-->
        <p style="line-height: 1.0px;font-size: 12px;font-family: Times New Roman;color:#ffffff">: Inline attributes
    
    <!--Custom Blocks-->
        <pullquote data-author="john">: Custom html

```

## Not supported tags

```html
  <!--Text indent-->
  <p style="padding: 10px"> 
```

## Getting Started

Add the dependency to your pubspec.yaml:

```yaml
dependencies:
  flutter_quill_delta_from_html: ^1.2.8
```

Then, import the package and use it in your Flutter application:

```dart
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

void main() {
  String htmlContent = "<p>Hello, <b>world</b>!</p>";
  var delta = HtmlToDelta().convert(htmlContent);
/*
   { "insert": "hello, " },
   { "insert": "world", "attributes": {"bold": true} },
   { "insert": "!" },
   { "insert": "\n" }
*/
}
```

## Creating your own `CustomHtmlPart` (alternative to create `CustomBlockEmbeds` from custom html)

First you need to define your own `CustomHtmlPart`

```dart
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:html/dom.dart' as dom;

/// Custom block handler for <pullquote> elements.
class PullquoteBlock extends CustomHtmlPart {
  @override
  bool matches(dom.Element element) {
    //you can put here the validation that you want
    //
    // To detect a <p>, you just need to do something like: 
    // element.localName == 'p'
    return element.localName == 'pullquote';
  }

  @override
  List<Operation> convert(dom.Element element, {Map<String, dynamic>? currentAttributes}) {
    final Delta delta = Delta();
    final Map<String, dynamic> attributes = currentAttributes != null ? Map.from(currentAttributes) : {};

    // Extract custom attributes from the <pullquote> element
    // The attributes represents the data into a html tag
    // at this point, <pullquote> should have these attributes
    //
    // <pullquote data-author="John Doe" data-style="italic">
    // These attributes can be optional, so do you need to ensure to not use "!" 
    // to avoid any null conflict
    final author = element.attributes['data-author'];
    final style = element.attributes['data-style'];

    // Apply custom attributes to the Delta operations
    if (author != null) {
      delta.insert('Pullquote: "${element.text}" by $author', attributes);
    } else {
      delta.insert('Pullquote: "${element.text}"', attributes);
    }

    if (style != null && style.toLowerCase() == 'italic') {
      attributes['italic'] = true;
    }

    delta.insert('\n', attributes);

    return delta.toList();
  }
}
```

After, put your `PullquoteBlock` to `HtmlToDelta` using the param `customBlocks`

```dart
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

void main() {
  // Example HTML snippet
  final htmlText = '''
    <html>
      <body>
        <p>Regular paragraph before the custom block</p>
        <pullquote data-author="John Doe" data-style="italic">This is a custom pullquote</pullquote>
        <p>Regular paragraph after the custom block</p>
      </body>
    </html>
  ''';

  // Registering the custom block
  final customBlocks = [PullquoteBlock()];

  // Initialize HtmlToDelta with the HTML text and custom blocks
  final converter = HtmlToDelta(customBlocks: customBlocks);

  // Convert HTML to Delta operations
  final delta = converter.convert(htmlText);
/*
This should be resulting delta
  {"insert": "Regular paragraph before the custom block"},
  {"insert": "Pullquote: \"This is a custom pullquote\" by John Doe", "attributes": {"italic": true}},
  {"insert": "\n"},
  {"insert": "Regular paragraph after the custom block\n"}
*/
}
```

## HtmlOperations

The `HtmlOperations` class is designed to streamline the conversion process from `HTML` to `Delta` operations, accommodating a wide range of `HTML` structures and attributes commonly used in web content.

To utilize `HtmlOperations`, extend this class and implement the methods necessary to handle specific `HTML` elements. Each method corresponds to a different `HTML` tag or element type and converts it into Delta operations suitable for use with `QuillJS`.

```dart
abstract class HtmlOperations {
  ///custom blocks are passed internally by HtmlToDelta
  List<CustomHtmlPart>? customBlocks;

  //You don't need to override this method 
  //as it simply calls the other methods 
  //to detect the type of HTML tag
  List<Operation> resolveCurrentElement(dom.Element element, [int indentLevel = 0]);

  List<Operation> brToOp(dom.Element element);
  List<Operation> headerToOp(dom.Element element);
  List<Operation> listToOp(dom.Element element, [int indentLevel = 0]);
  List<Operation> paragraphToOp(dom.Element element);
  List<Operation> linkToOp(dom.Element element);
  List<Operation> spanToOp(dom.Element element);
  List<Operation> imgToOp(dom.Element element);
  List<Operation> videoToOp(dom.Element element);
  List<Operation> codeblockToOp(dom.Element element);
  List<Operation> blockquoteToOp(dom.Element element);
}
```

## Contributions

If you find a bug or want to add a new feature, please open an issue or submit a pull request on the [GitHub repository](https://github.com/CatHood0/flutter_quill_delta_from_html).

This project is licensed under the MIT License - see the [LICENSE](https://github.com/CatHood0/flutter_quill_delta_from_html/blob/Main/LICENSE) file for details.
