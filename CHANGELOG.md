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
