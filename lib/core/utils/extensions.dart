import 'package:flutter/material.dart';

import '../values/colors.dart';


extension ResponsiveText on double {

  double textPercent(BuildContext context) {
    return MediaQuery.of(context).size.width / 100 * (this / 3);
  }
}

extension ResponsiveWidth on double {
  double get widthPercent =>
      (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width *
          (this / 100));
  double get textPercentage =>
      (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width /
          100 *
          (this / 3));
}

Color hexStringToColor(String hexString) {
  // Extract the hex part of the string
  final hexRegex = RegExp(r"([0-9a-fA-F]+)");
  final match = hexRegex.firstMatch(hexString);

  if (match != null) {
    // Parse the hex string to an integer
    int hexColor = int.parse(match.group(0)!, radix: 16);

    // Create a Color object from the parsed integer
    return Color(hexColor);
  } else {
    throw FormatException("Invalid hexadecimal color string: $hexString");
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();

      if (hexString.length == 7) {
        // Remove the '#' and add 'ff' for 7-character hex strings
        buffer.write('ff');
      }

      buffer.write(hexString.replaceFirst('#', ''));

      final hexValue = int.parse(buffer.toString(), radix: 16);

      return Color(hexValue);
    } catch (e) {
      throw FormatException('Invalid hex value: $hexString');
    }
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.value.toRadixString(16).padLeft(2, '0')}'
      '${green.value.toRadixString(16).padLeft(2, '0')}'
      '${blue.value.toRadixString(16).padLeft(2, '0')}';
}
