## 1.5.3

* Feat: support to detect line height css variable and setting custom values
* Feat: Add support for italic, underline, line-through and bold from CSS styling by @lecuivre-alban in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/29
* Refactor: Safely access 'last' element in operations by @nikiforosper in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/28
* Feat: CSS named color support by @SlickSlime in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/27
* Fix: line-height css variable issue [#21](https://github.com/CatHood0/flutter_quill_delta_from_html/issues/21)

## New Contributors
* @lecuivre-alban made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/29
* @nikiforosper made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/28
* @SlickSlime made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/27

## 1.5.2

* Feat: Handle table tags / handle line-height exceptions (i.e. inherit) by @mtallenca in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/25

## 1.5.1

* Feat: add `isBlockValidator` for Block Override decision [#23](https://github.com/CatHood0/flutter_quill_delta_from_html/pull/23)

## 1.5.0

* Feat: added a new way to insert a newline after a type of htmltag

## 1.4.5

* Fix: paragraph wrong breaks and weird trim() of some text elements by @CatHood0 in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/15

**Full Changelog**: https://github.com/CatHood0/flutter_quill_delta_from_html/compare/V-1.4.3...V-1.4.5

## 1.4.3

* Textcolor on paste of clipboard text showing wrong color by @SC8885 in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/13

## New Contributors
* @SC8885 made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/13

## 1.4.2

* chore(deps): improve dependencies constraints for compatibility by @EchoEllet in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/11
* Added exception handling to color parsing by @mtallenca in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/12

## New Contributors
* @EchoEllet made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/11
* @mtallenca made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/12

**Full Changelog**: https://github.com/CatHood0/flutter_quill_delta_from_html/compare/V-1.4.1...V-1.4.2

## 1.4.1

* Fix: header elements with children spans ignore the attributes that can be into its own spans
* Fix: removed unnecessary exception when unsupported color is detected 
* Feat: added `blackNodesList` into `HtmlToDelta` class to ignore certain nodes

## 1.4.0

* feat: made text trimming optional by @raimkulovr in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/7
* feat: ability to replace new lines to `<br>`

## New Contributors
* @raimkulovr made their first contribution in https://github.com/CatHood0/flutter_quill_delta_from_html/pull/7

## 1.3.13

* Chore: updated dependencies

## 1.3.12

* Fix: always add a new line without checking the last operation

## 1.3.11

* Fix: package use flutter dependency
* Fix: removed sdk flutter ref from pubspec.yaml since package doesn't depend on flutter
* Fix: repository and issue_tracker wrong url 
* Chore: removed unnecessary prints on html_utils

## 1.3.1

* Feat: support for video and image as a child node of any tag 
* Chore: moved `processNode` to it's own file called `node_processor` to make more easy read all logic into it
* Fix: new lines contains empty attributes

## 1.3.0

* Feat: added support for padding-left and padding-right
* Feat: added support for image styles and align
* Chore: removed support for `<iframe>`
* Fix: code-block isn't parsed as a block
* Fix: blockquote isn't parsed as a block

## 1.2.8

* Fix: indent level is invalid for Delta format

## 1.2.7

* Fix: inline attributes were not detected properly 
* Fix: reverted change from V-1.2.2 where was removed inline attrs validations 

## 1.2.6

* Feat: added support for nested lists

## 1.2.5

* Feat: added support for div

## 1.2.4

* Fix: font-size is parsed wrong by unsupported unit type 
* Feat: added support for more unit types
* doc: added more general documentation 

## 1.2.3

* doc(README): added more documentation about CustomHtmlPart
* doc: added more doc comments about general functionalities of the classes and methods

## 1.2.2

* Feat: added support for data-checked attribute for `<li>`  tags
* Fix: removed duplicated getting inline attributes at resolveCurrentElement

## 1.2.1

* Feat: added support for align attribute (a different way of align the text, like: text-align)
* Fix: Line-height is not pasted as double

## 1.2.0

* Chore: removed flutter_quill dependency to use only required parts of it
* Fix: HtmlOperations doesn't pass the customBlocks from HtmlToDelta

## 1.1.8

* Fix: README bad code ref, and better documentation
* Chore: new custom block example and test for it

## 1.1.7

* Fix: removed unused vars 

## 1.1.6

* Fix: README bad code references

## 1.1.5

* Feat: added support for subscript and superscript
* Feat: added support for color and background-color
* Feat: added support for custom blocks 
* Feat: added support for custom parsed `DOM Document` using `HtmlToDelta.convertDocument(DOMDocument)`
* Chore: improved README 
* Chore: improved documentation about project
* Chore: now `resolveCurrentElement` was moved to the interface to give the same functionality to all implementations

## 1.1.0

* Added support for fully attributes (could be partially bugged)
* Added an interface for create custom render tags
* Added tests for several cases

## 1.0.0

* Starting point.
