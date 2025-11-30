import 'package:agrosig_app/screens/auth/views/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/boton/btn_agrosig.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/helper/validate_form.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../components/toast/toats.dart';
import 'check_email_screen.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.clear();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const TextCustom(
          text: 'Restablecer Contraseña',
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: ColorsAgrosig.primaryColor,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: ColorsAgrosig.primaryColor
          ),
          onPressed: () => Navigator.push(context, routeAgroSig(page: SignInScreen())),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            children: [
              // Header ilustrativo
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: ColorsAgrosig.primaryColor.withOpacity(0.8),
                    ),
                    const SizedBox(height: 20),
                    const TextCustom(
                      text: '¿Olvidaste tu contraseña?',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: ColorsAgrosig.primaryColor,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const TextCustom(
                text: 'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos instrucciones para restablecer tu contraseña.',
                maxLine: 4,
                color: Colors.grey,
                textAlign: TextAlign.center,
                fontSize: 15,
              ),
              const SizedBox(height: 40.0),

              // Campo de email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextCustom(
                      text: 'Correo Electrónico',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorsAgrosig.secundaryColor,
                    ),
                    const SizedBox(height: 8.0),
                    FormFieldAgro(
                      controller: _emailController,
                      hintText: 'ejemplo@correo.com',
                      validator: validatedEmail,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),

              // Botón de enviar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BtnAgrosig(
                  text: _isLoading ? 'Enviando...' : 'Enviar Instrucciones',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  onPressed: _isLoading ? null : _passwordReset,
                ),
              ),

              // Información adicional
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextCustom(
                  text: 'Te llegará un correo con un enlace para crear una nueva contraseña.',
                  maxLine: 3,
                  color: Colors.grey,
                  textAlign: TextAlign.center,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _passwordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim()
      );

      showToast(message: "Se ha enviado un mensaje a tu correo electrónico");
      Get.offAll(() => CheckEmailScreen());

    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const TextCustom(
                text: 'Error',
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
              content: TextCustom(
                text: e.message.toString(),
                fontSize: 16,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const TextCustom(
                    text: 'Aceptar',
                    color: ColorsAgrosig.primaryColor,
                  ),
                ),
              ],
            );
          }
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}