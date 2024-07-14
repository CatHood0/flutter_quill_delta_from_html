/// constant common line-height multiplier
const normalLineHeightMultiplier = 1.2;

/// Parses a CSS `line-height` value to a pixel value based on the specified [fontSize] and optional [rootFontSize].
///
/// Supports unitless values, percentages, pixels (`px`), ems (`em`), rems (`rem`), and the keyword `normal`.
/// Adjusts the parsed value to fit within the supported range of line heights: 1.0, 1.15, 1.5, and 2.0.
///
/// Parameters:
/// - [lineHeight]: The CSS `line-height` value to parse.
/// - [fontSize]: The font size to use for unit conversions. Defaults to 16.
/// - [rootFontSize]: The root font size, used for `rem` conversions. Defaults to [fontSize].
///
/// Returns:
/// The parsed `line-height` value as a double in pixels.
///
/// Examples:
/// ```dart
/// print(parseLineHeight('0.8'));   // 1.0
/// print(parseLineHeight('1.1'));   // 1.0
/// print(parseLineHeight('1.2'));   // 1.15
/// print(parseLineHeight('1.3'));   // 1.5
/// print(parseLineHeight('1.7'));   // 1.5
/// print(parseLineHeight('2.2'));   // 2.0
///
/// // Example with different units
/// print(parseLineHeight('120%'));  // 19.2 (16 * 1.2)
/// print(parseLineHeight('1.5em')); // 24.0 (16 * 1.5)
/// print(parseLineHeight('1.2rem')); // 19.2 (16 * 1.2)
/// ```
double parseLineHeight(String lineHeight,
    {double fontSize = 16, double rootFontSize = 16}) {
  // Convert line-height values
  double parsedValue;
  if (lineHeight.endsWith('px')) {
    parsedValue = double.parse(lineHeight.replaceAll('px', ''));
  } else if (lineHeight.endsWith('%')) {
    parsedValue =
        fontSize * (double.parse(lineHeight.replaceAll('%', '')) / 100);
  } else if (lineHeight.endsWith('rem')) {
    parsedValue = rootFontSize * double.parse(lineHeight.replaceAll('rem', ''));
  } else if (lineHeight.endsWith('em')) {
    parsedValue = fontSize * double.parse(lineHeight.replaceAll('em', ''));
  } else if (lineHeight == 'normal') {
    parsedValue = fontSize * normalLineHeightMultiplier;
  } else {
    parsedValue = fontSize * double.parse(lineHeight);
  }

  // Apply additional constraints
  if (parsedValue < 1.0) {
    parsedValue = 1.0;
  } else if (parsedValue > 1.0 && parsedValue < 1.15) {
    parsedValue = 1.0;
  } else if (parsedValue > 1.15 && parsedValue < 1.25) {
    parsedValue = 1.15;
  } else if (parsedValue > 1.25 && parsedValue < 1.5) {
    parsedValue = 1.5;
  } else if (parsedValue > 1.5 && parsedValue < 2.0) {
    parsedValue = 1.5;
  } else if (parsedValue > 2.0) {
    parsedValue = 2.0;
  }

  return parsedValue;
}
