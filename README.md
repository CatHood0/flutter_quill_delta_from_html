# Flutter Quill Delta from HTML

flutter_quill_delta_from_html is a Dart package that converts HTML input into Quill Delta format, which is used in the flutter_quill package. This allows developers to easily convert HTML content to a format that can be displayed and edited using the Quill rich text editor in Flutter applications.
Features

**This package** supports the conversion of a wide range of HTML tags and attributes into their corresponding Delta operations, ensuring that your HTML content is accurately represented in the Quill editor.
Supported HTML Tags and Attributes

The following HTML tags and their attributes will be supported:

```html
    Text Formatting
        <b>, <strong>: Bold text
        <i>, <em>: Italic text
        <u>, <ins>: Underlined text
        <s>, <del>: Strikethrough text
        <sup>: Superscript text
        <sub>: Subscript text

    Headings
        <h1> to <h6>: Headings of various levels

    Lists
        <ul>: Unordered lists
        <ol>: Ordered lists
        <li>: List items

    Links
        <a>: Hyperlinks with support for the href attribute

    Images
        <img>: Images with support for the src, alt, and width attributes

    Videos 
        <iframe>, <video>: Videos with support for the src

    Blockquotes
        <blockquote>: Block quotations

    Code Blocks
        <code>: Code blocks

    Text Alignment
        <p align="left|center|right|justify">: Paragraph alignment

    Text attributes
        <span style="line-height: 1.0;font-size: 12;font-family: Times New Roman">: Span attributes
```

Getting Started

To start using flutter_quill_delta_from_html, add it to your pubspec.yaml:

```yaml
dependencies:
  flutter_quill_delta_from_html: ^1.0.0
```

Then, import the package and use it in your Flutter application:

```dart
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

void main() {
  String htmlContent = "<p>Hello, <b>world</b>!</p>";
  var delta = DeltaFromHTML().convert(htmlContent);
  print(delta); // [ { "insert": "hello, " }, { "insert": "world", "attributes": {"bold": true} }, { "insert": "!" }, { "insert": "\n" } ]
}
```

_For now the API is experimental and just to be sure, it's better use other already 
tested alternatives, such as the original implementation of `flutter_quill`, where it also 
allows obtaining `Delta` from a `HTML` input_

Contributions

Contributions are welcome! If you find a bug or want to add a new feature, please open an issue or submit a pull request on the GitHub repository.

This project is licensed under the MIT License - see the LICENSE file for details.
