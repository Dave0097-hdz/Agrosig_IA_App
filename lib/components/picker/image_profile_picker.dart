import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../custom/text_custom.dart';
import '../theme/colors_agrosig.dart';

class ProfileImagePicker extends StatefulWidget {
  final Function(XFile?) onImageSelected;
  final String? currentImageUrl;
  final bool showEditIcon;
  final double size;
  final bool isUpdating;

  const ProfileImagePicker({
    Key? key,
    required this.onImageSelected,
    this.currentImageUrl,
    this.showEditIcon = true,
    this.size = 120,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<bool> _checkAndRequestPermission(ImageSource source) async {
    try {
      Permission permission;

      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else {
        if (Platform.isAndroid) {
          // Para Android, verificamos la versión
          if (await Permission.storage.isGranted) {
            permission = Permission.storage;
          } else if (await Permission.photos.isGranted) {
            permission = Permission.photos;
          } else {
            // Solicitamos storage primero (compatibilidad con versiones anteriores)
            permission = Permission.storage;
          }
        } else {
          // Para iOS
          permission = Permission.photos;
        }
      }

      // Verificar si ya tenemos permiso
      if (await permission.isGranted) {
        return true;
      }

      // Solicitar permiso
      final status = await permission.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
        return false;
      } else {
        _showPermissionDeniedSnackbar();
        return false;
      }
    } catch (e) {
      print('Error en permisos: $e');
      _showErrorSnackbar('Error al verificar permisos');
      return false;
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Permisos Requeridos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Para seleccionar imágenes necesitas habilitar los permisos de cámara y almacenamiento. Por favor, ve a Configuración > Aplicaciones > AgroSig > Permisos y habilita los permisos necesarios.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text(
                'Abrir Configuración',
                style: TextStyle(
                  color: ColorsAgrosig.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Permiso denegado. No se puede acceder a la función.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Configuración',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Verificar permisos primero
      final hasPermission = await _checkAndRequestPermission(source);
      if (!hasPermission) {
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        widget.onImageSelected(_imageFile);
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      _showErrorSnackbar('Error al seleccionar la imagen: ${e.toString()}');
    }
  }

  void _handleImageSelection() {
    if (widget.isUpdating) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seleccionar imagen de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade300),
                _buildOptionButton(
                  icon: Icons.photo_library,
                  title: 'Galería',
                  subtitle: 'Seleccionar de la galería',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                _buildOptionButton(
                  icon: Icons.photo_camera,
                  title: 'Cámara',
                  subtitle: 'Tomar una foto',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Avatar principal
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsAgrosig.primaryColor.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildImageContent(),
              ),
            ),

            // Overlay de carga
            if (widget.isUpdating)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),

            // Botón de editar
            if (widget.showEditIcon && !widget.isUpdating)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _handleImageSelection,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4772E6), Color(0xFF1B83F5)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Texto para cambiar foto
        if (!widget.isUpdating)
          GestureDetector(
            onTap: _handleImageSelection,
            child: Text(
              widget.currentImageUrl != null &&
                      widget.currentImageUrl!.isNotEmpty
                  ? 'Cambiar foto de perfil'
                  : 'Agregar foto de perfil',
              style: TextStyle(
                color: ColorsAgrosig.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    // Si hay una imagen temporal seleccionada
    if (_imageFile != null) {
      return Image.file(
        File(_imageFile!.path),
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    // Si hay una imagen del servidor
    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      return Image.network(
        widget.currentImageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    // Imagen por defecto
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/dummy-profile.png',
      fit: BoxFit.cover,
      width: widget.size,
      height: widget.size,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade100,
          child: Icon(
            Icons.person,
            size: widget.size * 0.4,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }
}
