import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../components/custom/text_custom.dart';
import '../../components/forms/form_fiel.dart';
import '../../components/helper/error_message.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../components/helper/modal_success.dart';
import '../../domain/services/user_services/user_services.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _keyForm = GlobalKey<FormState>();
  final UserServices _userServices = UserServices();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _changePassword() async {
    if (_keyForm.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _userServices.updateUserPassword(
          oldPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          repeatedPassword: _confirmPasswordController.text,
        );

        // Mostrar modal de éxito
        modalSuccess(
          context,
          'Contraseña actualizada correctamente',
              () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      } catch (e) {
        errorMessageSnack(context, 'Error al cambiar contraseña: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value!.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 10.0),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorsAgrosig.primaryColor,
                size: 17,
              ),
              TextCustom(
                text: 'Volver',
                fontSize: 17,
                color: ColorsAgrosig.primaryColor,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
                : TextCustom(
              text: "Actualizar Contraseña",
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _keyForm,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: [
              const SizedBox(height: 20.0),

              /// Contraseña actual
              const TextCustom(
                text: 'Contraseña Actual',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _currentPasswordController,
                isPassword: _obscureCurrentPassword,
                validator: RequiredValidator(errorText: 'La contraseña actual es requerida'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              /// Nueva contraseña
              const TextCustom(
                text: 'Nueva Contraseña',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _newPasswordController,
                isPassword: _obscureNewPassword,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'La nueva contraseña es requerida'),
                  MinLengthValidator(8, errorText: 'Mínimo 8 caracteres'),
                ]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              /// Confirmar contraseña
              const TextCustom(
                text: 'Confirmar Contraseña',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _confirmPasswordController,
                isPassword: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40.0),

              /// Botón de actualizar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsAgrosig.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const TextCustom(
                    text: 'Actualizar Contraseña',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Por seguridad, debes ingresar tu contraseña actual para poder cambiarla.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}