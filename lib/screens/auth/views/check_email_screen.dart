import 'dart:io';
import 'package:agrosig_app/screens/auth/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/boton/btn_agrosig.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/theme/colors_agrosig.dart';

class CheckEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contenido principal
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono principal
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorsAgrosig.primaryColor.withOpacity(.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          FontAwesomeIcons.envelopeOpenText,
                          size: 70,
                          color: ColorsAgrosig.primaryColor
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // Título
                    const TextCustom(
                      text: 'Revisa tu correo',
                      textAlign: TextAlign.center,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ColorsAgrosig.primaryColor,
                    ),
                    const SizedBox(height: 20.0),

                    // Descripción
                    const TextCustom(
                      text: 'Hemos enviado las instrucciones para recuperar tu contraseña a tu correo electrónico.',
                      maxLine: 3,
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 50.0),

                    // Botón de abrir app de email
                    SizedBox(
                      width: double.infinity,
                      child: BtnAgrosig(
                        text: 'Abrir aplicación de correo',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        onPressed: () async {
                          if (Platform.isAndroid) {
                            final intent = AndroidIntent(
                              action: 'android.intent.action.MAIN',
                              category: 'android.intent.category.APP_EMAIL',
                              flags: [
                                Flag.FLAG_ACTIVITY_NEW_TASK,
                                Flag.FLAG_ACTIVITY_CLEAR_TOP,
                              ],
                            );
                            await intent.launch();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 25.0),

                    // Botón de saltar
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          routeAgroSig(page: SignInScreen())
                      ),
                      child: const TextCustom(
                        text: 'Omitir, confirmaré más tarde',
                        color: ColorsAgrosig.primaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // Información adicional en la parte inferior
              Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(height: 8),
                    TextCustom(
                      text: '¿No recibiste el correo? Revisa tu carpeta de spam o solicita otro enlace.',
                      color: Colors.grey,
                      maxLine: 3,
                      textAlign: TextAlign.center,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}