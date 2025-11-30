import 'package:flutter/material.dart';
import '../custom/text_custom.dart';

void modalPictureRegister({
  required BuildContext ctx,
  VoidCallback? onPressedChange,
  VoidCallback? onPressedTake,
}) {
  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
    ),
    builder: (context) => Wrap(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: -5.0),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextCustom(
                text: 'Seleccionar foto de perfil',
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Elegir de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  onPressedChange?.call();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text('Tomar una foto'),
                onTap: () {
                  Navigator.pop(context);
                  onPressedTake?.call();
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: TextCustom(
                  text: 'Cancelar',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}