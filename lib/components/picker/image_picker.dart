import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/modal_picture.dart';

class ImagePickerFrave extends StatefulWidget {
  const ImagePickerFrave({super.key});

  @override
  State<ImagePickerFrave> createState() => _ImagePickerFraveState();
}

class _ImagePickerFraveState extends State<ImagePickerFrave> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _showImagePickerModal() {
    modalPictureRegister(
      ctx: context,
      onPressedChange: () async {
        Navigator.pop(context);
        await _pickImage(ImageSource.gallery);
      },
      onPressedTake: () async {
        Navigator.pop(context);
        await _pickImage(ImageSource.camera);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(style: BorderStyle.solid, color: Colors.grey[200]!),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: _showImagePickerModal,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : const AssetImage('assets/img/dummy-profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
