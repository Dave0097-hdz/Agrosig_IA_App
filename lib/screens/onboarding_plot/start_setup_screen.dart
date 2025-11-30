import 'dart:ffi';
import 'package:agrosig_app/screens/onboarding_plot/setting_plot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../domain/services/firebase_service/google_services.dart';
import '../../domain/services/auth_services/auth_services.dart';
import '../auth/views/sign_in_screen.dart';

class StarSetupScreen extends StatefulWidget {
  const StarSetupScreen({super.key});

  @override
  _StarSetupScreen createState() => _StarSetupScreen();
}

class _StarSetupScreen extends State<StarSetupScreen> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final AuthServices _userServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          Image.asset(
            'assets/images/farm_background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          // Overlay gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // LOGO - Manteniendo TU configuración exacta
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 120,
                          backgroundImage: AssetImage('assets/images/logo_agrosig.png'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título AGROSIG
                  Text(
                    "AGROSIG",
                    style: TextStyle(
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Tarjeta de información principal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado de la tarjeta
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.eco_rounded, // Icono de planta en lugar de tractor
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Campo de Tomates",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "Listo para configurar",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Grid de información
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                              icon: Icons.health_and_safety_rounded,
                              title: "Salud del Cultivo",
                              value: "Excelente",
                              color: Colors.green,
                            ),
                            _buildInfoItem(
                              icon: Icons.calendar_today_rounded,
                              title: "Fecha de Siembra",
                              value: "12/01/2024",
                              color: Colors.blue,
                            ),
                            _buildInfoItem(
                              icon: Icons.schedule_rounded,
                              title: "Tiempo Cosecha",
                              value: "~4 Meses",
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Sección de bienvenida y configuración
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "¡Comencemos a Configurar Tu Granja!",
                          style: TextStyle(
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Hola, vamos a comenzar a trabajar en la configuración de tu granja para que puedas obtener información detallada con la ayuda de nuestra IA.",
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 25),

                        // Botón principal
                        _buildStartButton(),

                        const SizedBox(height: 15),

                        // Opción de configurar después
                        _buildSetLaterOption(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green[700]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Get.to(() => SettingPlotScreen());
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.leaf, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Comenzar Configuración",
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

  Widget _buildSetLaterOption() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _performLogout,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Configurar más tarde",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      final userId = await secureStorage.getUserId();

      if (userId != null) {
        await _userServices.logout();
      }

      // Cerrar sesión en Firebase si es necesario
      await _firebaseAuthService.signOut();

      // Redirigir a la pantalla de login
      Get.offAll(() => SignInScreen());

    } catch (e) {
      print('Error durante logout: $e');
      // Asegurar limpieza incluso con errores
      await secureStorage.clearAllData();
      await _firebaseAuthService.signOut();
      Get.offAll(() => SignInScreen());
    }
  }
}