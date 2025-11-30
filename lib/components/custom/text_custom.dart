import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextCustom extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextOverflow textOverflow;
  final int? maxLine;
  final TextAlign textAlign;
  final double? height;

  const TextCustom({
    required this.text,
    this.fontSize = 18,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textOverflow = TextOverflow.visible,
    this.maxLine,
    this.textAlign = TextAlign.left,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ?? (isDark ? Colors.white : Colors.black);

    return Text(
      text,
      overflow: textOverflow,
      maxLines: maxLine,
      textAlign: textAlign,
      style: GoogleFonts.getFont(
        'Roboto',
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }
}