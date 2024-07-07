///validate the string color to avoid unsupported colors
String validateAndGetColor(String colorString) {
  if (colorString.startsWith('#')) return colorString;
  return colorToHex(colorString);
}

///Decide the color format type and parse to hex
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

///Parse RGB to valid hex string
String rgbToHex(String rgb) {
  rgb = rgb.replaceAll('rgb(', '').replaceAll(')', '');
  List<String> rgbValues = rgb.split(',');
  int r = int.parse(rgbValues[0].trim());
  int g = int.parse(rgbValues[1].trim());
  int b = int.parse(rgbValues[2].trim());
  return _toHex(r, g, b, 255);
}

///Parse RGBA to valid hex string
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

///Parse hsl to valid hex string
String hslToHex(String hsl) {
  hsl = hsl.replaceAll('hsl(', '').replaceAll(')', '');
  List<String> hslValues = hsl.split(',');
  double h = double.parse(hslValues[0].trim());
  double s = double.parse(hslValues[1].replaceAll('%', '').trim()) / 100;
  double l = double.parse(hslValues[2].replaceAll('%', '').trim()) / 100;
  List<int> rgb = _hslToRgb(h, s, l);
  return _toHex(rgb[0], rgb[1], rgb[2], 255);
}

///Parse hsla to valid hex string
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

///Ensure parse hsl to rgb string to make more simple convertion to hex
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

///Conver RGBA values to hex
String _toHex(int r, int g, int b, int a) {
  String hexR = r.toRadixString(16).padLeft(2, '0');
  String hexG = g.toRadixString(16).padLeft(2, '0');
  String hexB = b.toRadixString(16).padLeft(2, '0');
  String hexA = a.toRadixString(16).padLeft(2, '0');
  return '#$hexR$hexG$hexB$hexA';
}
