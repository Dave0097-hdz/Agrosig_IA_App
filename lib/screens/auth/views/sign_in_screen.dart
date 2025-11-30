import 'dart:convert';
import 'package:agrosig_app/screens/auth/views/sing_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/helper/validate_form.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../components/toast/toats.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../../domain/services/auth_services/auth_services.dart';
import '../../../domain/services/notifications_services/firebase_messaging_service.dart';
import '../../home/home_screen.dart';
import '../../onboarding_plot/start_setup_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final FirebaseMessagingService _fmcService = FirebaseMessagingService();
  final _keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void clearForm() {
    _emailController.clear();
    _passwordController.clear();
  }

  bool isSigning = false;

  // Metodo para registrar token FMC despues del login
  Future<void> _registerFMCTokenAfterLogin() async {
    try {
      await _fmcService.registerTokenAfterLogin();
    } catch (e) {
      print('Error registrando token FMC después del login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.push(context, routeAgroSig(page: SignUpPage()));
          },
          child: Container(
            alignment: Alignment.center,
            child: const TextCustom(
              text: 'Registrarse',
              color: ColorsAgrosig.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 85,
        title: TextCustom(
          text: "Iniciar Sesión",
          color: ColorsAgrosig.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: isSigning ? null : _signInWithEmailPassword,
            child: Container(
              margin: const EdgeInsets.only(right: 15.0),
              alignment: Alignment.center,
              child: isSigning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorsAgrosig.primaryColor,
                      ),
                    )
                  : TextCustom(
                      text: 'Entrar',
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
            const SizedBox(height: 20.0),

            // Logo centrado
            Container(
              height: 160,
              child: Image.asset(
                'assets/images/logo_agrosig.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 25.0),

            // Título de bienvenida
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  TextCustom(
                    text: '¡Bienvenido!',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff14222E),
                  ),
                  const SizedBox(height: 8),
                  TextCustom(
                    text: 'Ingresa a tu cuenta de AgroSig',
                    textAlign: TextAlign.center,
                    color: Colors.grey[600]!,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40.0),

            // Campo de Email
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

            // Campo de Contraseña
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

            // Botón de Login
            _buildLoginButton(),

            const SizedBox(height: 25.0),

            // Enlace para registrarse
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextCustom(
                    text: '¿No tienes una cuenta? ',
                    fontSize: 16,
                    color: Colors.grey[600]!,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, routeAgroSig(page: SignUpPage())),
                    child: TextCustom(
                      text: 'Regístrate',
                      fontSize: 16,
                      color: ColorsAgrosig.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25.0),

            // Olvidé contraseña
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () => Navigator.push(
                    context, routeAgroSig(page: ResetPassword())),
                child: TextCustom(
                  text: '¿Olvidaste tu contraseña?',
                  fontSize: 16,
                  color: ColorsAgrosig.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

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

  Widget _buildLoginButton() {
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
            onTap: isSigning ? null : _signInWithEmailPassword,
            child: Center(
              child: isSigning
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
                        Icon(Icons.login_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Iniciar Sesión",
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

  Future<void> _signInWithEmailPassword() async {
    if (!_keyForm.currentState!.validate()) {
      showToast(message: 'Por favor, completa todos los campos correctamente');
      return;
    }

    setState(() {
      isSigning = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final response =
          await authServices.loginUser(email: email, password: password);

      if (response.resp == true ||
          response.msg.toLowerCase().contains('éxito') ||
          response.msg.toLowerCase().contains('success')) {
        showToast(message: '¡Bienvenido a AgroSig!');

        final token = await secureStorage.getAccessToken();
        final refreshToken = await secureStorage.getRefreshToken();
        final userId = await secureStorage.getUserId();

        if (token == null || refreshToken == null || userId == null) {
          throw Exception('Error: Los tokens no se guardaron correctamente');
        }

        // Registrar token FMC
        await _registerFMCTokenAfterLogin();

        // Obtener el perfil del usuario para verificar si tiene parcela configurada
        final userProfile = response.user;

        print('User configured_plot: ${userProfile.configured_plot}');

        if (userProfile.configured_plot) {
          Get.offAll(() => HomeScreen());
        } else {
          Get.offAll(() => StarSetupScreen());
        }

        clearForm();
      } else {
        showToast(message: response.msg);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      showToast(message: errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isSigning = false;
        });
      }
    }
  }
}
