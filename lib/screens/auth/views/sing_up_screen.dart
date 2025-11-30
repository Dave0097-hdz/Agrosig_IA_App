import 'dart:io';
import 'package:agrosig_app/screens/auth/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/helper/error_message.dart';
import '../../../components/helper/modal_success.dart';
import '../../../components/helper/validate_form.dart';
import '../../../components/picker/image_profile_picker.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../components/toast/toats.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../../domain/services/auth_services/auth_services.dart';
import '../../settings/privacy_policy_screen.dart';
import '../../settings/terms_conditions_screen.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _paternalSurnameController;
  late TextEditingController _maternalSurnameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  XFile? _selectedImage;

  final _keyForm = GlobalKey<FormState>();
  final secureStorage = SecureStorageAgroSig();

  bool isSigningUp = false;
  bool _isTermsAccepted = false;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _paternalSurnameController = TextEditingController();
    _maternalSurnameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalSurnameController.dispose();
    _maternalSurnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void clearForm() {
    _firstNameController.clear();
    _paternalSurnameController.clear();
    _maternalSurnameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _selectedImage = null;
      _isTermsAccepted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.push(context, routeAgroSig(page: SignInScreen()));
          },
          child: Container(
            alignment: Alignment.center,
            child: const TextCustom(
              text: 'Iniciar Sesión',
              color: ColorsAgrosig.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        title: TextCustom(
          text: "Crear Cuenta",
          color: ColorsAgrosig.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: isSigningUp ? null : _registerUser,
            child: Container(
              margin: const EdgeInsets.only(right: 15.0),
              alignment: Alignment.center,
              child: isSigningUp
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorsAgrosig.primaryColor,
                      ),
                    )
                  : TextCustom(
                      text: 'Guardar',
                      color: ColorsAgrosig.primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          )
        ],
      ),
      body: Form(
        key: _keyForm,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          children: [
            const SizedBox(height: 10.0),

            // Foto de perfil
            Align(
              alignment: Alignment.center,
              child: ProfileImagePicker(
                onImageSelected: (XFile? image) {
                  setState(() {
                    _selectedImage = image;
                  });
                },
                size: 120,
              ),
            ),

            const SizedBox(height: 25.0),

            // Título
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  TextCustom(
                    text: 'Crea Tu Cuenta',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff14222E),
                  ),
                  const SizedBox(height: 8),
                  TextCustom(
                    text: 'Completa tus datos para comenzar',
                    textAlign: TextAlign.center,
                    color: Colors.grey[600]!,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30.0),

            // Campo Nombre
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: 'Nombre',
                  color: Colors.grey[800]!,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                FormFieldAgro(
                  controller: _firstNameController,
                  hintText: 'Ingresa tu nombre',
                  validator:
                      RequiredValidator(errorText: 'El nombre es requerido'),
                  prefixIcon:
                      Icon(Icons.person_outline, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Campo Apellido Paterno
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: 'Apellido Paterno',
                  color: Colors.grey[800]!,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                FormFieldAgro(
                  controller: _paternalSurnameController,
                  hintText: 'Ingresa tu apellido paterno',
                  validator: RequiredValidator(
                      errorText: 'El apellido paterno es requerido'),
                  prefixIcon:
                      Icon(Icons.person_outlined, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Campo Apellido Materno
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: 'Apellido Materno',
                  color: Colors.grey[800]!,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                FormFieldAgro(
                  controller: _maternalSurnameController,
                  hintText: 'Ingresa tu apellido materno',
                  validator: RequiredValidator(
                      errorText: 'El apellido materno es requerido'),
                  prefixIcon:
                      Icon(Icons.person_outlined, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Campo Email
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: 'Correo Electrónico',
                  color: Colors.grey[800]!,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                FormFieldAgro(
                  controller: _emailController,
                  hintText: 'ejemplo@agrosig.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: validatedEmail,
                  prefixIcon:
                      Icon(Icons.email_outlined, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Campo Contraseña
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: 'Contraseña',
                  color: Colors.grey[800]!,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                FormFieldAgro(
                  controller: _passwordController,
                  hintText: '••••••••',
                  isPassword: true,
                  validator: passwordValidator,
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 25.0),

            // Checkbox de Términos y Política
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isTermsAccepted,
                    activeColor: ColorsAgrosig.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isTermsAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Términos y Condiciones',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          children: [
                            Text(
                              'He leído y acepto los ',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(
                                  () => const TermsAndConditionsScreen()),
                              child: Text(
                                'Términos y Condiciones',
                                style: TextStyle(
                                  color: ColorsAgrosig.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              ' y la ',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Get.to(() => const PrivacyPolicyScreen()),
                              child: Text(
                                'Política de Privacidad',
                                style: TextStyle(
                                  color: ColorsAgrosig.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25.0),

            // Botón de Registro
            _buildRegisterButton(),

            const SizedBox(height: 20.0),

            // Información de seguridad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsAgrosig.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: ColorsAgrosig.primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security_rounded,
                      color: ColorsAgrosig.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextCustom(
                      text:
                          'Tus datos están protegidos y nunca serán compartidos con terceros',
                      color: Colors.grey[600]!,
                      fontSize: 12,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: ColorsAgrosig.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorsAgrosig.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isSigningUp ? null : _registerUser,
            child: Center(
              child: isSigningUp
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Crear Cuenta",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (!_keyForm.currentState!.validate()) {
      showToast(message: 'Por favor, completa todos los campos correctamente');
      return;
    }

    if (!_isTermsAccepted) {
      showToast(
          message: 'Debes aceptar los Términos y Condiciones para continuar');
      return;
    }

    setState(() => isSigningUp = true);

    final firstName = _firstNameController.text.trim();
    final paternalSurname = _paternalSurnameController.text.trim();
    final maternalSurname = _maternalSurnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final imagePath = _selectedImage?.path;

    try {
      final response = await authServices.registerUser(
        firstName,
        paternalSurname,
        maternalSurname,
        imagePath,
        email,
        password,
      );

      if (response.resp) {
        showToast(
            message: response.msg.isNotEmpty
                ? response.msg
                : 'Usuario registrado exitosamente');

        modalSuccess(
          context,
          response.msg.isNotEmpty
              ? response.msg
              : 'Usuario registrado exitosamente',
          () {
            Get.offAll(() => SignInScreen());
            clearForm();
          },
        );
      } else {
        showToast(message: response.msg);
        _handleRegistrationError(response.msg);
      }
    } catch (e) {
      print('Register Error: $e');
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      showToast(message: errorMessage);
    } finally {
      if (mounted) {
        setState(() => isSigningUp = false);
      }
    }
  }

  void _handleRegistrationError(String errorMessage) {
    errorMessageSnack(context, errorMessage);
    if (errorMessage.toLowerCase().contains('email') ||
        errorMessage.toLowerCase().contains('usuario') ||
        errorMessage.toLowerCase().contains('exist') ||
        errorMessage.toLowerCase().contains('ya')) {
      Future.delayed(Duration(milliseconds: 500), () {
        FocusScope.of(context).requestFocus(FocusNode());
        _emailController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _emailController.text.length,
        );
      });
    }
  }
}
