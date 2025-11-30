import 'package:flutter/material.dart';
import '../../components/theme/colors_agrosig.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Política de Privacidad",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4772E6).withOpacity(0.1),
                  Color(0xFF6D927F).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.privacy_tip_outlined,
                    color: Color(0xFF4772E6),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Privacidad y Seguridad",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D4A3C),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Tu información está protegida con nosotros",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF4772E6).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.security_outlined,
                            color: Color(0xFF4772E6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Nuestro Compromiso con tu Privacidad",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Tarjetas de información
                    _buildPrivacyCard(
                      icon: Icons.collections_bookmark_outlined,
                      title: "1. Recopilación de Datos",
                      content: "Solo recopilamos información necesaria para la autenticación, análisis de uso y personalización de servicios. Nunca compartimos tus datos personales con terceros sin tu consentimiento.",
                      color: Color(0xFF6D927F),
                    ),

                    _buildPrivacyCard(
                      icon: Icons.analytics_outlined,
                      title: "2. Uso de la Información",
                      content: "Tus datos se utilizan únicamente para mejorar la experiencia en la aplicación, proporcionar servicios personalizados y cumplir con las funcionalidades ofrecidas en AgroSig.",
                      color: Color(0xFF4772E6),
                    ),

                    _buildPrivacyCard(
                      icon: Icons.enhanced_encryption,
                      title: "3. Almacenamiento y Seguridad",
                      content: "La información se guarda de forma segura usando encriptación avanzada (SecureStorage) y protocolos seguros HTTPS. Implementamos medidas de seguridad físicas y digitales para proteger tus datos.",
                      color: Color(0xFFFF6B35),
                    ),

                    _buildPrivacyCard(
                      icon: Icons.people_outlined,
                      title: "4. Derechos del Usuario",
                      content: "Puedes solicitar la eliminación, actualización o exportación de tus datos en cualquier momento desde tu cuenta o contactando a nuestro equipo de soporte. Tienes control total sobre tu información.",
                      color: Color(0xFF9C27B0),
                    ),

                    _buildPrivacyCard(
                      icon: Icons.support_agent_outlined,
                      title: "5. Contacto y Soporte",
                      content: "Si tienes dudas sobre nuestra política de privacidad o el manejo de tus datos, puedes escribirnos a: soporte@agrosig.com. Respondemos en un máximo de 24 horas.",
                      color: Color(0xFF00BCD4),
                    ),

                    const SizedBox(height: 20),

                    // Nota importante
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6D927F).withOpacity(0.1),
                            Color(0xFF4772E6).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF6D927F).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF6D927F),
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tu privacidad es nuestra prioridad",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D4A3C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "En AgroSig nos comprometemos a proteger tus datos y mantener tu información segura en todo momento.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Fecha de actualización
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.update_outlined,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Última actualización: Octubre 2025",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}