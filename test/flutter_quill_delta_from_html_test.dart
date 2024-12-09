import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill_delta_from_html/parser/pullquote_block_example.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

void main() {
  group('HtmlToDelta tests', () {
    test('Header with styles', () {
      const html =
          '<h3 style="text-align:right">Header example 3 <span style="background-color: var(--fgColor-muted, var(--color-fg-muted));color: rgb(255,255,255);"><i>with</i> a spanned italic text</span></h3>';
      final converter = HtmlToDelta();
      // this Delta wont have background color attribute since that type syntax is not supported
      // so, just rgb will be passed between the other attributes
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('Header example 3 ')
        ..insert('with', {'color': '#FFFFFFFF', 'italic': true})
        ..insert(' a spanned italic text', {'color': '#FFFFFFFF'})
        ..insert('\n', {'align': 'right', 'header': 3})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph with link', () {
      const html =
          '<p>This is a <a href="https://example.com">link</a> to example.com</p>';
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

    test('Paragraph with different font-size unit type', () {
      const htmlSmall =
          '<p style="font-size: 0.75em">This is a paragraph example</p>';
      const htmlHuge =
          '<p style="font-size: 2.5em">This is a paragraph example 2</p>';
      const htmlLarge =
          '<p style="font-size: 1.5em">This is a paragraph example 3</p>';
      const htmlCustomSize =
          '<p style="font-size: 12pt">This is a paragraph example 4</p>';
      final converter = HtmlToDelta();
      final deltaSmall = converter.convert(htmlSmall);
      final deltaLarge = converter.convert(htmlLarge);
      final deltaHuge = converter.convert(htmlHuge);
      final deltaCustom = converter.convert(htmlCustomSize);

      final expectedDeltaSmall = Delta()
        ..insert('This is a paragraph example', {"size": "small"})
        ..insert('\n');

      final expectedDeltaHuge = Delta()
        ..insert('This is a paragraph example 2', {"size": "huge"})
        ..insert('\n');

      final expectedDeltaLarge = Delta()
        ..insert('This is a paragraph example 3', {"size": "large"})
        ..insert('\n');

      final expectedDeltaCustom = Delta()
        ..insert('This is a paragraph example 4', {"size": "15"})
        ..insert('\n');

      expect(deltaSmall, expectedDeltaSmall);
      expect(deltaLarge, expectedDeltaLarge);
      expect(deltaHuge, expectedDeltaHuge);
      expect(deltaCustom, expectedDeltaCustom);
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
        ..insert('This is a paragraph example',
            {"line-height": 1.5, "size": "15", "font": "Tinos"})
        ..insert('\n', {"align": "center", "direction": "rtl"})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph with spanned red text', () {
      const html =
          '<p>This is a <span style="background-color:rgb(255,255,255)">red text</span></p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a ')
        ..insert('red text', {'background': '#FFFFFFFF'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Paragraph with subscript and superscript', () {
      const html =
          '<p>This is a paragraph that contains <sub>subscript</sub> and <sup>superscript</sup></p>';
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

    test('Paragraph with a image child', () {
      const html =
          '<p>This is an image: <img align="center" style="width: 50px;height: 250px;margin: 5px;" src="https://example.com/image.png"/> example</p>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is an image: ')
        ..insert({'image': 'https://example.com/image.png'},
            {"style": "width:50px;height:250px;margin:5px;alignment:center"})
        ..insert(' example')
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

    test('Nested list', () {
      const html =
          '<ol><li>First <strong>item</strong><ul><li>SubItem <a href="https://www.google.com">1</a><ol><li>Sub 1.5</li></ol></li><li>SubItem 2</li></ul></li><li>Second item</li></ol>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('First ')
        ..insert('item', {"bold": true})
        ..insert('\n', {'list': 'ordered'})
        ..insert('SubItem ')
        ..insert('1', {'link': 'https://www.google.com'})
        ..insert('\n', {'list': 'bullet', 'indent': 1})
        ..insert('Sub 1.5')
        ..insert('\n', {'list': 'ordered', 'indent': 2})
        ..insert('SubItem 2')
        ..insert('\n', {'list': 'bullet', 'indent': 1})
        ..insert('Second item')
        ..insert('\n', {'list': 'ordered'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Complex Nested list', () {
      const html =
          """<ul><li>List item one </li><li>List item two with subitems: <ul><li>Subitem 1</li><li>Subitem 2</li></ul></li><li>Final list item</li></ul>""";
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('List item one ')
        ..insert('\n', {'list': 'bullet'})
        ..insert('List item two with subitems: ')
        ..insert('\n', {'list': 'bullet'})
        ..insert('Subitem 1')
        ..insert('\n', {'list': 'bullet', 'indent': 1})
        ..insert('Subitem 2')
        ..insert('\n', {'list': 'bullet', 'indent': 1})
        ..insert('Final list item')
        ..insert('\n', {'list': 'bullet'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Checklist', () {
      const html =
          '<ul><li data-checked="true">First item</li><li data-checked="false">Second item</li></ul>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('First item')
        ..insert('\n', {'list': 'checked'})
        ..insert('Second item')
        ..insert('\n', {'list': 'unchecked'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Image', () {
      const html =
          '<p>This is an image:</p><img src="https://example.com/image.png" />';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is an image:')
        ..insert({'image': 'https://example.com/image.png'})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Image with styles', () {
      const html =
          '<p>This is an image:</p><img align="center" style="width: 50px;height: 250px;margin: 5px;" src="https://example.com/image.png" />';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is an image:')
        ..insert({'image': 'https://example.com/image.png'},
            {"style": "width:50px;height:250px;margin:5px;alignment:center"})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Code block', () {
      const html = '<pre><code>console.log(\'Hello, world!\');</code></pre>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert("console.log('Hello, world!');")
        ..insert('\n', {'code-block': true})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Blockquote', () {
      const html = '<blockquote>This is a blockquote</blockquote>';
      final converter = HtmlToDelta();
      final delta = converter.convert(html);

      final expectedDelta = Delta()
        ..insert('This is a blockquote')
        ..insert('\n', {'blockquote': true})
        ..insert('\n');

      expect(delta, expectedDelta);
    });

    test('Text with different styles', () {
      const html =
          '<p>This is <strong>bold</strong>, <em>italic</em>, and <u>underlined</u> text.</p>';
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
      const html =
          '<p>This is a <strong><a href="https://example.com">bold link</a></strong> with text.</p>';
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

  test(
      'should convert custom <pullquote> block to Delta with custom attributes',
      () {
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
      ..insert('Pullquote: "This is a custom pullquote" by John Doe',
          {'italic': true})
      ..insert('\n')
      ..insert('Regular paragraph after the custom block\n');

    expect(delta, equals(expectedDelta));
  });

  test('Div with mixed content', () {
    const html =
        '<div><p>Paragraph inside div.</p><h1>Header inside div</h1><ul><li>List item 1</li><li data-checked="false">List item 2</li></ul></div>';

    const htmlReversed =
        '<div><h1>Paragraph inside div.</h1><p>Header inside div</p><ul><li>List item 1</li><li data-checked="false">List item 2</li></ul></div>';
    final converter = HtmlToDelta();
    final delta = converter.convert(html);
    final deltaReversed = converter.convert(htmlReversed);

    final expectedDelta = Delta()
      ..insert('Paragraph inside div.\nHeader inside div')
      ..insert('\n', {'header': 1})
      ..insert('List item 1')
      ..insert('\n', {'list': 'bullet'})
      ..insert('List item 2')
      ..insert('\n', {'list': 'unchecked'})
      ..insert('\n');

    final expectedDeltaRevered = Delta()
      ..insert('Paragraph inside div.')
      ..insert('\n', {'header': 1})
      ..insert('Header inside div\n')
      ..insert('List item 1')
      ..insert('\n', {'list': 'bullet'})
      ..insert('List item 2')
      ..insert('\n', {'list': 'unchecked'})
      ..insert('\n');

    expect(delta, expectedDelta);
    expect(deltaReversed, expectedDeltaRevered);
  });

  test('Paragraph with colors', () {
    const html =
        '<p><span style="color:#F06292FF">This is just pink </span><br/><br/><span style="color:#4DD0E1FF">This is just blue</span></p>';

    final converter = HtmlToDelta();
    final delta = converter.convert(html);

    final expectedDelta = Delta()
      ..insert('This is just pink ', {"color": "#F06292FF"})
      ..insert('\n\n')
      ..insert("This is just blue", {"color": "#4DD0E1FF"})
      ..insert('\n');

    expect(delta, expectedDelta);
  });
}
