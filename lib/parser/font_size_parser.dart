// constant centimeters multiplier
const double cmSizeMultiplier = 37.7952755906;
// constant millimeters multiplier
const double mmSizeMultiplier = 3.7795275591;
// constant inches multiplier
const double inchSizeMultiplier = 96;
// constant points multiplier
const double pointSizeMultiplier = 1.3333333333;
// constant picas multiplier
const double picasSizeMultiplier = 16;

/// Converts various CSS units to pixels (px).
///
/// This function supports the following units:
/// - `px` (pixels)
/// - `cm` (centimeters)
/// - `mm` (millimeters)
/// - `in` (inches)
/// - `pt` (points)
/// - `pc` (picas)
/// - `em` (relative to the font-size of the element)
/// - `rem` (relative to the font-size of the root element)
///
/// For relative units (`em` and `rem`), you need to provide the font-size of the
/// relevant context. The default font-size is 16 pixels.
///
/// Example usage:
/// ```dart
/// print(convertToPx('2cm'));  // 75.5905511812
/// print(convertToPx('10mm')); // 37.7952755906
/// print(convertToPx('1in'));  // 96.0
/// print(convertToPx('12pt')); // 16.0
/// print(convertToPx('1pc'));  // 16.0
/// print(convertToPx('2em', fontSize: 18.0));  // 36.0
/// print(convertToPx('2rem', rootFontSize: 20.0));  // 40.0
/// ```
///
/// [value] is the CSS value to be converted, e.g., '2cm', '10mm', etc.
/// [fontSize] is the font-size of the current element, used for `em` units.
/// [rootFontSize] is the font-size of the root element, used for `rem` units.
///
/// Returns the equivalent value in pixels.
double parseSizeToPx(
  String value, {
  double fontSizeEmMultiplier = 16.0,
  double rootFontSizeRemMultiplier = 16.0,
}) {
  // Extract the unit from the value string.
  final unit = value.replaceAll(RegExp(r'[0-9.]'), '');

  // Extract the numeric part of the value string.
  final number =
      double.tryParse(value.replaceAll(RegExp(r'[a-z%]'), '')) ?? 0.0;

  // Convert the numeric value to pixels based on the unit.
  switch (unit) {
    case 'px':
      return number;
    case 'cm':
      return number * cmSizeMultiplier;
    case 'mm':
      return number * mmSizeMultiplier;
    case 'in':
      return number * inchSizeMultiplier;
    case 'pt':
      return number * pointSizeMultiplier;
    case 'pc':
      return number * picasSizeMultiplier;
    case 'em':
      return number * fontSizeEmMultiplier;
    case 'rem':
      return number * rootFontSizeRemMultiplier;
    default:
      throw UnsupportedError('Unit not supported: $unit');
  }
}
