import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_delta_from_html/parser/pullquote_block_example.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlToDelta tests', () {
    test('Header with styles', () {
      const html = '<h3 style="text-align:right">Header example 3 <span><i>with</i> a spanned italic text</span></h3>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('Header example 3 ')
        ..insert('with', {'italic': true})
        ..insert(' a spanned italic text')
        ..insert('\n', {'align': 'right', 'header': 3})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph with link', () {
      const html = '<p>This is a <a href="https://example.com">link</a> to example.com</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a ')
        ..insert('link', {'link': 'https://example.com'})
        ..insert(' to example.com')
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph alignment', () {
      const html = '<p align="center">This is a paragraph example</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a paragraph example')
        ..insert('\n', {"align": "center"})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph to RTL', () {
      const html = '<p dir="rtl">This is a RTL paragraph example</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a RTL paragraph example')
        ..insert('\n', {"direction": "rtl"})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph alignment RTL with inline styles', () {
      const html =
          '<p align="center" dir="rtl" style="line-height: 1.5px;font-size: 15px;font-family: Tinos">This is a paragraph example</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a paragraph example', {"line-height": 1.5, "size": "15", "font": "Tinos"})
        ..insert('\n', {"align": "center", "direction": "rtl"})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph with spanned red text', () {
      const html = '<p>This is a <span style="background-color:rgb(255,255,255)">red text</span></p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a ')
        ..insert('red text', {'background': '#ffffffff'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph with subscript and superscript', () {
      const html = '<p>This is a paragraph that contains <sub>subscript</sub> and <sup>superscript</sup></p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a paragraph that contains ')
        ..insert('subscript', {'script': 'sub'})
        ..insert(' and ')
        ..insert('superscript', {'script': 'super'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Ordered list', () {
      const html = '<ol><li>First item</li><li>Second item</li></ol>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('First item')
        ..insert('\n', {'list': 'ordered'})
        ..insert('Second item')
        ..insert('\n', {'list': 'ordered'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Image', () {
      const html = '<p>This is an image:</p><img src="https://example.com/image.png" />';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is an image:')
        ..insert({'image': 'https://example.com/image.png'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Code block', () {
      const html = '<pre><code>console.log(\'Hello, world!\');</code></pre>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert("console.log('Hello, world!');\n", {'code-block': true})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Blockquote', () {
      const html = '<blockquote>This is a blockquote</blockquote>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a blockquote\n', {'blockquote': true})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Text with different styles', () {
      const html = '<p>This is <strong>bold</strong>, <em>italic</em>, and <u>underlined</u> text.</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is ')
        ..insert('bold', {'bold': true})
        ..insert(', ')
        ..insert('italic', {'italic': true})
        ..insert(', and ')
        ..insert('underlined', {'underline': true})
        ..insert(' text.')
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Combined styles and link', () {
      const html = '<p>This is a <strong><a href="https://example.com">bold link</a></strong> with text.</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a ')
        ..insert('bold link', {'bold': true, 'link': 'https://example.com'})
        ..insert(' with text.')
        ..insert('\n');

      expect(delta, expectedDelta);
    });
  });

  test('should convert custom <pullquote> block to Delta with custom attributes', () {
    const htmlText = '''
        <html>
          <body>
            <p>Regular paragraph before the custom block</p>
            <pullquote data-author="John Doe" data-style="italic">This is a custom pullquote</pullquote>
            <p>Regular paragraph after the custom block</p>
          </body>
        </html>
      ''';

    final customBlocks = [PullquoteBlock()];

    final converter = HtmlToDelta(customBlocks: customBlocks);
    final delta = converter.convert(htmlText);

    final expectedDelta = Delta()
      ..insert('Regular paragraph before the custom block')
      ..insert('Pullquote: "This is a custom pullquote" by John Doe', {'italic': true})
      ..insert('\n')
      ..insert('Regular paragraph after the custom block\n');

    expect(delta, equals(expectedDelta));
  });
}
