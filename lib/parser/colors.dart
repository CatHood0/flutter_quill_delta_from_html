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
/// print(validateAndGetColor('red')); // Output: #ff0000
/// ```
String? validateAndGetColor(String colorString) {
  //verify if the color already is a hex
  if (colorString.startsWith('#')) return colorString;
  try {
    return colorToHex(colorString);
  } catch (_) {
    return null;
  }
}

/// Decides the color format type and converts it to hexadecimal format.
///
/// Detects the type of color from [color] and calls the corresponding conversion function:
/// - If [color] starts with 'rgb(', converts it using [rgbToHex].
/// - If [color] starts with 'rgba(', converts it using [rgbaToHex].
/// - If [color] starts with 'hsl(', converts it using [hslToHex].
/// - If [color] starts with 'hsla(', converts it using [hslaToHex].
/// - Otherwise, treats it as a color name and converts it using [colorNameToHex].
/// 
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
/// print(colorToHex('red')); // Output: #ff0000
/// ```
String? colorToHex(String color) {
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
    return colorNameToHex(color);
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
  return '#$hexA$hexR$hexG$hexB'.toUpperCase();
}

/// Converts a color name to its hexadecimal representation.
/// 
/// If the color name is not found in the predefined map, it throws an [ArgumentError].
/// 
/// Parameters:
/// - [colorName]: The name of the color to convert to hexadecimal format.
/// 
/// Returns:
/// The hexadecimal representation of the color name.
/// 
/// Example:
/// ```dart
/// print(colorNameToHex('red')); // Output: #FF0000
/// print(colorNameToHex('blue')); // Output: #0000FF
/// ```
String colorNameToHex(String colorName) {
  // Normalize the color name to lowercase
  String normalizedColorName = colorName.toLowerCase();

  // Check if the color name exists in the map
  if (_colorNameToHexMap.containsKey(normalizedColorName)) {
    return _colorNameToHexMap[normalizedColorName]!;
  } else {
    throw ArgumentError('Color name "$colorName" is not supported.');
  }
}

/// A map of color names to their hexadecimal representations.
///
/// Source: https://www.w3.org/TR/css-color-4/#named-colors
Map<String, String> _colorNameToHexMap = {
  "aliceblue": "#f0f8ff",
  "antiquewhite": "#faebd7",
  "aqua": "#00ffff",
  "aquamarine": "#7fffd4",
  "azure": "#f0ffff",
  "beige": "#f5f5dc",
  "bisque": "#ffe4c4",
  "black": "#000000",
  "blanchedalmond": "#ffebcd",
  "blue": "#0000ff",
  "blueviolet": "#8a2be2",
  "brown": "#a52a2a",
  "burlywood": "#deb887",
  "cadetblue": "#5f9ea0",
  "chartreuse": "#7fff00",
  "chocolate": "#d2691e",
  "coral": "#ff7f50",
  "cornflowerblue": "#6495ed",
  "cornsilk": "#fff8dc",
  "crimson": "#dc143c",
  "cyan": "#00ffff",
  "darkblue": "#00008b",
  "darkcyan": "#008b8b",
  "darkgoldenrod": "#b8860b",
  "darkgray": "#a9a9a9",
  "darkgreen": "#006400",
  "darkgrey": "#a9a9a9",
  "darkkhaki": "#bdb76b",
  "darkmagenta": "#8b008b",
  "darkolivegreen": "#556b2f",
  "darkorange": "#ff8c00",
  "darkorchid": "#9932cc",
  "darkred": "#8b0000",
  "darksalmon": "#e9967a",
  "darkseagreen": "#8fbc8f",
  "darkslateblue": "#483d8b",
  "darkslategray": "#2f4f4f",
  "darkslategrey": "#2f4f4f",
  "darkturquoise": "#00ced1",
  "darkviolet": "#9400d3",
  "deeppink": "#ff1493",
  "deepskyblue": "#00bfff",
  "dimgray": "#696969",
  "dimgrey": "#696969",
  "dodgerblue": "#1e90ff",
  "firebrick": "#b22222",
  "floralwhite": "#fffaf0",
  "forestgreen": "#228b22",
  "fuchsia": "#ff00ff",
  "gainsboro": "#dcdcdc",
  "ghostwhite": "#f8f8ff",
  "gold": "#ffd700",
  "goldenrod": "#daa520",
  "gray": "#808080",
  "green": "#008000",
  "greenyellow": "#adff2f",
  "grey": "#808080",
  "honeydew": "#f0fff0",
  "hotpink": "#ff69b4",
  "indianred": "#cd5c5c",
  "indigo": "#4b0082",
  "ivory": "#fffff0",
  "khaki": "#f0e68c",
  "lavender": "#e6e6fa",
  "lavenderblush": "#fff0f5",
  "lawngreen": "#7cfc00",
  "lemonchiffon": "#fffacd",
  "lightblue": "#add8e6",
  "lightcoral": "#f08080",
  "lightcyan": "#e0ffff",
  "lightgoldenrodyellow": "#fafad2",
  "lightgray": "#d3d3d3",
  "lightgreen": "#90ee90",
  "lightgrey": "#d3d3d3",
  "lightpink": "#ffb6c1",
  "lightsalmon": "#ffa07a",
  "lightseagreen": "#20b2aa",
  "lightskyblue": "#87cefa",
  "lightslategray": "#778899",
  "lightslategrey": "#778899",
  "lightsteelblue": "#b0c4de",
  "lightyellow": "#ffffe0",
  "lime": "#00ff00",
  "limegreen": "#32cd32",
  "linen": "#faf0e6",
  "magenta": "#ff00ff",
  "maroon": "#800000",
  "mediumaquamarine": "#66cdaa",
  "mediumblue": "#0000cd",
  "mediumorchid": "#ba55d3",
  "mediumpurple": "#9370db",
  "mediumseagreen": "#3cb371",
  "mediumslateblue": "#7b68ee",
  "mediumspringgreen": "#00fa9a",
  "mediumturquoise": "#48d1cc",
  "mediumvioletred": "#c71585",
  "midnightblue": "#191970",
  "mintcream": "#f5fffa",
  "mistyrose": "#ffe4e1",
  "moccasin": "#ffe4b5",
  "navajowhite": "#ffdead",
  "navy": "#000080",
  "oldlace": "#fdf5e6",
  "olive": "#808000",
  "olivedrab": "#6b8e23",
  "orange": "#ffa500",
  "orangered": "#ff4500",
  "orchid": "#da70d6",
  "palegoldenrod": "#eee8aa",
  "palegreen": "#98fb98",
  "paleturquoise": "#afeeee",
  "palevioletred": "#db7093",
  "papayawhip": "#ffefd5",
  "peachpuff": "#ffdab9",
  "peru": "#cd853f",
  "pink": "#ffc0cb",
  "plum": "#dda0dd",
  "powderblue": "#b0e0e6",
  "purple": "#800080",
  "rebeccapurple": "#663399",
  "red": "#ff0000",
  "rosybrown": "#bc8f8f",
  "royalblue": "#4169e1",
  "saddlebrown": "#8b4513",
  "salmon": "#fa8072",
  "sandybrown": "#f4a460",
  "seagreen": "#2e8b57",
  "seashell": "#fff5ee",
  "sienna": "#a0522d",
  "silver": "#c0c0c0",
  "skyblue": "#87ceeb",
  "slateblue": "#6a5acd",
  "slategray": "#708090",
  "slategrey": "#708090",
  "snow": "#fffafa",
  "springgreen": "#00ff7f",
  "steelblue": "#4682b4",
  "tan": "#d2b48c",
  "teal": "#008080",
  "thistle": "#d8bfd8",
  "tomato": "#ff6347",
  "turquoise": "#40e0d0",
  "violet": "#ee82ee",
  "wheat": "#f5deb3",
  "white": "#ffffff",
  "whitesmoke": "#f5f5f5",
  "yellow": "#ffff00",
  "yellowgreen": "#9acd32"
};
