import 'package:flutter/material.dart';
import '../custom/text_custom.dart';

void errorMessageSnack(BuildContext context, String error) {
  String cleanError = error.replaceAll('Exception: ', '');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextCustom(
              text: cleanError,
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(83, 180, 232, 1.0),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}