import 'dart:io';
import 'package:agrosig_app/screens/settings/privacy_policy_screen.dart';
import 'package:agrosig_app/screens/settings/terms_conditions_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/animations/animation_route.dart';
import '../../components/custom/text_custom.dart';
import '../../components/item_account.dart';
import '../../components/picker/image_profile_picker.dart';
import '../../components/toast/toats.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../domain/models/user/user_model.dart';
import '../../domain/services/auth_services/auth_services.dart';
import '../../domain/services/user_services/user_services.dart';
import '../auth/views/sign_in_screen.dart';
import 'change_password_screen.dart';
import 'edit_parcel_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SecureStorageAgroSig _secureStorageAgroSig = SecureStorageAgroSig();
  final UserServices _userServices = UserServices();
  final AuthServices _authServices = AuthServices();
  User? _user;
  bool _isLoading = true;
  bool _isUpdatingImage = false;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadUserData() async {
    try {
      _safeSetState(() {
        _isLoading = true;
      });

      final user = await _userServices.getUserProfile();
      _safeSetState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _handleImageSelection(File image) async {
    _safeSetState(() {
      _isUpdatingImage = true;
    });

    try {
      final updatedUser = await _userServices.updateProfileImage(image);
      _safeSetState(() {
        _user = updatedUser;
        _isUpdatingImage = false;
      });
      showToast(message: 'Imagen de perfil actualizada correctamente');
    } catch (e) {
      _safeSetState(() {
        _isUpdatingImage = false;
      });
      _showErrorSnackBar('Error al actualizar imagen: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header con avatar y información
                  _buildProfileHeader(),
                  const SizedBox(height: 32.0),
                  // Sección de cuenta
                  _buildAccountSection(),
                  const SizedBox(height: 24.0),
                  // Sección personal
                  _buildPersonalSection(),
                  const SizedBox(height: 24.0),
                  // Botón de cerrar sesión
                  _buildSignOutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileImagePicker(
            onImageSelected: (XFile? image) async {
              if (image != null) {
                await _handleImageSelection(File(image.path));
              }
            },
            currentImageUrl:
                _user?.image_user != null && _user!.image_user!.isNotEmpty
                    ? _userServices.getImageUrl(_user!.image_user)
                    : null,
            showEditIcon: true,
            size: 150,
            isUpdating: _isUpdatingImage,
          ),
          const SizedBox(height: 20),
          _buildUserName(),
          const SizedBox(height: 8),
          _buildUserEmail(),
          const SizedBox(height: 16),
          _buildUserRole(),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return Column(
      children: [
        Text(
          _user != null ? _formatUserName() : 'Nombre de Usuario',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildUserEmail() {
    return Text(
      _user?.email ?? 'correo@ejemplo.com',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.grey.shade600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUserRole() {
    final role = _user?.role_id == 1 ? 'Administrador' : 'Usuario';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color:
            _user?.role_id == 1 ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _user?.role_id == 1
              ? Colors.orange.shade200
              : Colors.blue.shade200,
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _user?.role_id == 1
              ? Colors.orange.shade700
              : Colors.blue.shade700,
        ),
      ),
    );
  }

  String _formatUserName() {
    if (_user == null) return '';

    final names = [
      _user!.first_name,
      _user!.paternal_surname,
      _user!.maternal_surname,
    ].where((name) => name.isNotEmpty).toList();

    return names.join(' ');
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ItemAccount(
                  text: 'Configuración del perfil',
                  icon: Icons.person_outline,
                  colorIcon: 0xff01C58C,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      routeAgroSig(page: EditProfileScreen()),
                    ).then((value) {
                      _loadUserData();
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Cambiar contraseña',
                  icon: Icons.lock_outline,
                  colorIcon: 0xff1B83F5,
                  onPressed: () => Navigator.push(
                    context,
                    routeAgroSig(page: ChangePasswordScreen()),
                  ).then((value) {
                    _loadUserData();
                  }),
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Modificar Parcela',
                  icon: Icons.map_rounded,
                  colorIcon: 0xFF357B25,
                  onPressed: () => Navigator.push(
                    context,
                    routeAgroSig(page: EditParcelScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                    text: 'Política de Privacidad',
                    icon: Icons.lock_outline_rounded,
                    colorIcon: 0xFF6F767E,
                    onPressed: () => Navigator.push(
                        context, routeAgroSig(page: PrivacyPolicyScreen()))),
                ItemAccount(
                    text: 'Términos y condiciones',
                    icon: Icons.description_outlined,
                    colorIcon: 0xff458bff,
                    onPressed: () => Navigator.push(context,
                        routeAgroSig(page: TermsAndConditionsScreen()))),
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Centro de ayuda',
                  icon: Icons.help_outline,
                  colorIcon: 0xff4772e6,
                  onPressed: () => Navigator.push(
                    context,
                    routeAgroSig(page: HelpScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ItemAccount(
          text: 'Cerrar sesión',
          icon: Icons.logout,
          colorIcon: 0xFFFF6A55,
          onPressed: _performLogout,
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red.shade600,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _executeLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executeLogout() async {
    try {
      final userId = await _secureStorageAgroSig.getUserId();

      if (userId != null) {
        await _authServices.logout();
      }

      Get.offAll(() => SignInScreen());
    } catch (e) {
      print('Error durante logout: $e');
      await _secureStorageAgroSig.clearAllData();
      Get.offAll(() => SignInScreen());
    }
  }
}
