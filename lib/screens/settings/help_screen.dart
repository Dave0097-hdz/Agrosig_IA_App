import 'package:agrosig_app/components/toast/toats.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/services/chats_services/chats_services.dart';
import '../../domain/services/user_services/user_services.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final CommentServices _commentServices = CommentServices();
  final UserServices _userServices = UserServices();

  bool _isLoading = false;
  bool _userDataLoaded = false;
  GoogleMapController? _mapController;

  // Coordenadas de la ubicación
  static const LatLng _center = LatLng(17.2019, -93.0114);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _addMarker();
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('ubicacion'),
          position: _center,
          infoWindow: const InfoWindow(
            title: 'Nuestra Ubicación',
            snippet: 'Tercera Nte. Pte., San Antonio, Rayón, Chis.',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userServices.getUserProfile();
      setState(() {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _userDataLoaded = true;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _nameController.text = "Usuario";
        _emailController.text = "usuario@ejemplo.com";
        _userDataLoaded = true;
      });
    }
  }

  Future<void> _sendComment() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, describe tu problema."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _commentServices.createComment(_descController.text.trim());

      if (response.success) {
        showToast(message: 'Comentario Enviado Correctamente');
        _descController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.message}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al enviar comentario: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // MÉTODO LEGACY QUE ESTÁ FUNCIONANDO
  Future<void> _launchUrlSimple(String url) async {
    try {
      print('Intentando abrir: $url');
      await launch(url, forceSafariVC: false, forceWebView: false);
      print('URL abierta exitosamente con método legacy');
    } catch (e) {
      print('Error al abrir URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir la URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método específico para correo electrónico
  Future<void> _openEmail() async {
    final String emailUrl = 'mailto:soporteayu@gmail.com?subject=Consulta/Soporte - Ayuda en la App&body=Hola, necesito ayuda con...';
    await _launchUrlSimple(emailUrl);
  }

  // Métodos específicos para redes sociales
  void _launchGithub() => _launchUrlSimple('https://github.com/Dave0097-hdz');
  void _launchInstagram() => _launchUrlSimple('https://instagram.com');
  void _launchFacebook() => _launchUrlSimple('https://facebook.com');
  void _launchTwitter() => _launchUrlSimple('https://twitter.com');

  // Método para Google Maps
  Future<void> _openMaps() async {
    // Primero intentar con aplicación nativa de Google Maps
    final String nativeUrl = 'comgooglemaps://?q=${_center.latitude},${_center.longitude}';
    final String webUrl = 'https://www.google.com/maps/search/?api=1&query=${_center.latitude},${_center.longitude}';

    try {
      await _launchUrlSimple(nativeUrl);
    } catch (e) {
      // Fallback a Google Maps web
      await _launchUrlSimple(webUrl);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descController.dispose();
    _commentServices.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Centro de Ayuda",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        shadowColor: Colors.black12,
      ),
      body: !_userDataLoaded
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6D927F)),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de información personal
            _buildPersonalInfoCard(),

            const SizedBox(height: 20),

            // Tarjeta de formulario de ayuda
            _buildHelpFormCard(),

            const SizedBox(height: 20),

            // Mapa de ubicación
            _buildLocationCard(),

            const SizedBox(height: 20),

            // Tarjeta de contacto simplificada
            _buildContactCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D927F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: Color(0xFF6D927F), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Tu Información",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Nombre", _nameController.text),
            const SizedBox(height: 12),
            _buildInfoRow("Correo", _emailController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpFormCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D927F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.help_outline, color: Color(0xFF6D927F), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "¿En qué podemos ayudarte?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Describe el problema o sugerencia que tienes",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildMessageField(),
            const SizedBox(height: 20),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF6D927F), size: 20),
                SizedBox(width: 8),
                Text(
                  "Nuestra Ubicación",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  initialCameraPosition: const CameraPosition(
                    target: _center,
                    zoom: 15,
                  ),
                  markers: _markers,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text(
                  "Abrir en Google Maps",
                  style: TextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.blue.shade400),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tercera Nte. Pte., San Antonio, 29740 Rayón, Chis.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de contacto simplificada
  Widget _buildContactCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D927F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.contact_support, color: Color(0xFF6D927F), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Contáctanos",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Correo electrónico simplificado
            _buildContactItem(
              Icons.email_outlined,
              "Correo Electrónico",
              "soporteayu@gmail.com",
              _openEmail,
            ),
            const SizedBox(height: 16),

            // Redes sociales simplificadas
            const Text(
              "Síguenos en redes sociales:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildSocialMediaSection(),
          ],
        ),
      ),
    );
  }

  // Widget de contacto simplificado
  Widget _buildContactItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6D927F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF6D927F), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // Sección de redes sociales simplificada
  Widget _buildSocialMediaSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 400;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialIcon(
              FontAwesomeIcons.github,
              "GitHub",
              _launchGithub,
              isSmallScreen,
            ),
            _buildSocialIcon(
              FontAwesomeIcons.instagram,
              "Instagram",
              _launchInstagram,
              isSmallScreen,
            ),
            _buildSocialIcon(
              FontAwesomeIcons.facebook,
              "Facebook",
              _launchFacebook,
              isSmallScreen,
            ),
            _buildSocialIcon(
              FontAwesomeIcons.twitter,
              "Twitter",
              _launchTwitter,
              isSmallScreen,
            ),
          ],
        );
      },
    );
  }

  // Ícono social simplificado
  Widget _buildSocialIcon(IconData icon, String tooltip, VoidCallback onTap, bool isSmallScreen) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 20 : 22,
            color: const Color(0xFF6D927F),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mensaje",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Describe detalladamente tu problema o sugerencia...",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6D927F), width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6D927F),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shadowColor: Colors.black26,
        ),
        onPressed: _isLoading ? null : _sendComment,
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 18),
            SizedBox(width: 8),
            Text(
              "Enviar Mensaje",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}