/// Validates and retrieves the color string in hexadecimal format.
///
/// If [colorString] starts with '#', it's assumed to be already in hexadecimal format.
/// Otherwise, attempts to convert [colorString] to hexadecimal format using supported color formats.
/// Throws [ArgumentError] if the color format is not supported.
///
/// Parameters:
/// - [colorString]: The input color string to validate and convert.
///
/// Returns:
/// The validated color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(validateAndGetColor('#ff0000')); // Output: #ff0000
/// print(validateAndGetColor('rgb(255, 0, 0)')); // Output: #ff0000
/// print(validateAndGetColor('hsl(0, 100%, 50%)')); // Output: #ff0000
/// ```
String validateAndGetColor(String colorString) {
  //verify if the color already is a hex
  if (colorString.startsWith('#')) return colorString;
  return colorToHex(colorString);
}

/// Decides the color format type and converts it to hexadecimal format.
///
/// Detects the type of color from [color] and calls the corresponding conversion function:
/// - If [color] starts with 'rgb(', converts it using [rgbToHex].
/// - If [color] starts with 'rgba(', converts it using [rgbaToHex].
/// - If [color] starts with 'hsl(', converts it using [hslToHex].
/// - If [color] starts with 'hsla(', converts it using [hslaToHex].
/// Throws [ArgumentError] if the color format is not supported.
///
/// Parameters:
/// - [color]: The input color string to convert to hexadecimal format.
///
/// Returns:
/// The converted color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(colorToHex('rgb(255, 0, 0)')); // Output: #ff0000
/// print(colorToHex('hsla(0, 100%, 50%, 0.5)')); // Output: #ff0000
/// ```
String colorToHex(String color) {
  // Detectar el tipo de color y llamar a la función correspondiente
  if (color.startsWith('rgb(')) {
    return rgbToHex(color);
  } else if (color.startsWith('rgba(')) {
    return rgbaToHex(color);
  } else if (color.startsWith('hsl(')) {
    return hslToHex(color);
  } else if (color.startsWith('hsla(')) {
    return hslaToHex(color);
  } else {
    throw ArgumentError('color format not supported: $color');
  }
}


/// Parses an RGB color string to a valid hexadecimal color string.
///
/// Converts the RGB color format string [rgb] (e.g., 'rgb(255, 0, 0)') to its hexadecimal representation.
///
/// Parameters:
/// - [rgb]: The RGB color string to convert to hexadecimal format.
///
/// Returns:
/// The converted color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(rgbToHex('rgb(255, 0, 0)')); // Output: #ff0000
/// ```
String rgbToHex(String rgb) {
  rgb = rgb.replaceAll('rgb(', '').replaceAll(')', '');
  List<String> rgbValues = rgb.split(',');
  int r = int.parse(rgbValues[0].trim());
  int g = int.parse(rgbValues[1].trim());
  int b = int.parse(rgbValues[2].trim());
  return _toHex(r, g, b, 255);
}

/// Parses an RGBA color string to a valid hexadecimal color string.
///
/// Converts the RGBA color format string [rgba] (e.g., 'rgba(255, 0, 0, 0.5)') to its hexadecimal representation.
///
/// Parameters:
/// - [rgba]: The RGBA color string to convert to hexadecimal format.
///
/// Returns:
/// The converted color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(rgbaToHex('rgba(255, 0, 0, 0.5)')); // Output: #ff000080
/// ```
String rgbaToHex(String rgba) {
  rgba = rgba.replaceAll('rgba(', '').replaceAll(')', '');
  List<String> rgbaValues = rgba.split(',');
  int r = int.parse(rgbaValues[0].trim());
  int g = int.parse(rgbaValues[1].trim());
  int b = int.parse(rgbaValues[2].trim());
  double a = double.parse(rgbaValues[3].trim());
  int alpha = (a * 255).round();
  return _toHex(r, g, b, alpha);
}

/// Parses an HSL color string to a valid hexadecimal color string.
///
/// Converts the HSL color format string [hsl] (e.g., 'hsl(0, 100%, 50%)') to its hexadecimal representation.
///
/// Parameters:
/// - [hsl]: The HSL color string to convert to hexadecimal format.
///
/// Returns:
/// The converted color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(hslToHex('hsl(0, 100%, 50%)')); // Output: #ff0000
/// ```
String hslToHex(String hsl) {
  hsl = hsl.replaceAll('hsl(', '').replaceAll(')', '');
  List<String> hslValues = hsl.split(',');
  double h = double.parse(hslValues[0].trim());
  double s = double.parse(hslValues[1].replaceAll('%', '').trim()) / 100;
  double l = double.parse(hslValues[2].replaceAll('%', '').trim()) / 100;
  List<int> rgb = _hslToRgb(h, s, l);
  return _toHex(rgb[0], rgb[1], rgb[2], 255);
}

/// Parses an HSLA color string to a valid hexadecimal color string.
///
/// Converts the HSLA color format string [hsla] (e.g., 'hsla(0, 100%, 50%, 0.5)') to its hexadecimal representation.
///
/// Parameters:
/// - [hsla]: The HSLA color string to convert to hexadecimal format.
///
/// Returns:
/// The converted color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(hslaToHex('hsla(0, 100%, 50%, 0.5)')); // Output: #ff000080
/// ```
String hslaToHex(String hsla) {
  hsla = hsla.replaceAll('hsla(', '').replaceAll(')', '');
  List<String> hslaValues = hsla.split(',');
  double h = double.parse(hslaValues[0].trim());
  double s = double.parse(hslaValues[1].replaceAll('%', '').trim()) / 100;
  double l = double.parse(hslaValues[2].replaceAll('%', '').trim()) / 100;
  double a = double.parse(hslaValues[3].trim());
  int alpha = (a * 255).round();
  List<int> rgb = _hslToRgb(h, s, l);
  return _toHex(rgb[0], rgb[1], rgb[2], alpha);
}

/// Converts HSL (Hue, Saturation, Lightness) values to RGB (Red, Green, Blue) values.
///
/// Converts the HSL color values [h], [s], and [l] to RGB values.
///
/// Parameters:
/// - [h]: Hue value (0-360).
/// - [s]: Saturation value (0-1).
/// - [l]: Lightness value (0-1).
///
/// Returns:
/// A list of integers representing the RGB values ([red, green, blue]).
///
/// Example:
/// ```dart
/// print(_hslToRgb(0, 1.0, 0.5)); // Output: [255, 0, 0] (Equivalent to #ff0000)
/// ```
List<int> _hslToRgb(double h, double s, double l) {
  double c = (1 - (2 * l - 1).abs()) * s;
  double x = c * (1 - ((h / 60) % 2 - 1).abs());
  double m = l - c / 2;
  double r = 0, g = 0, b = 0;

  if (h >= 0 && h < 60) {
    r = c;
    g = x;
  } else if (h >= 60 && h < 120) {
    r = x;
    g = c;
  } else if (h >= 120 && h < 180) {
    g = c;
    b = x;
  } else if (h >= 180 && h < 240) {
    g = x;
    b = c;
  } else if (h >= 240 && h < 300) {
    r = x;
    b = c;
  } else if (h >= 300 && h < 360) {
    r = c;
    b = x;
  }

  int red = ((r + m) * 255).round();
  int green = ((g + m) * 255).round();
  int blue = ((b + m) * 255).round();

  return [red, green, blue];
}


/// Converts RGB (Red, Green, Blue) values to a hexadecimal color string.
///
/// Converts the RGB values [r], [g], [b], and optional [a] (alpha) to a hexadecimal color string.
///
/// Parameters:
/// - [r]: Red value (0-255).
/// - [g]: Green value (0-255).
/// - [b]: Blue value (0-255).
/// - [a]: Alpha value (0-255), optional. Defaults to 255 (fully opaque).
///
/// Returns:
/// The converted color string in hexadecimal format.
///
/// Example:
/// ```dart
/// print(_toHex(255, 0, 0, 255)); // Output: #ff0000
/// ```
String _toHex(int r, int g, int b, int a) {
  String hexR = r.toRadixString(16).padLeft(2, '0');
  String hexG = g.toRadixString(16).padLeft(2, '0');
  String hexB = b.toRadixString(16).padLeft(2, '0');
  String hexA = a.toRadixString(16).padLeft(2, '0');
  return '#$hexR$hexG$hexB$hexA';
}
