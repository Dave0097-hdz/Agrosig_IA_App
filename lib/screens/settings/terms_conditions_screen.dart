import 'package:agrosig_app/screens/settings/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import '../../components/animations/animation_route.dart';
import '../../data/local_secure/secure_storage.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final VoidCallback? onTermsAccepted;

  const TermsAndConditionsScreen({Key? key, this.onTermsAccepted}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _isChecked = false;
  bool _isAtBottom = false;
  bool _isLoading = false;
  bool _hasNavigated = false;
  final ScrollController _scrollController = ScrollController();
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkExistingAcceptance();
  }

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isAtBottom = true;
      });
    }
  }

  Future<void> _checkExistingAcceptance() async {
    try {
      final alreadyAccepted = await _secureStorage.isPolicyAccepted();
      if (alreadyAccepted && mounted) {
        setState(() {
          _isChecked = true;
          _isAtBottom = true;
        });
      }
    } catch (e) {
      print('Error checking existing acceptance: $e');
    }
  }

  Future<void> _saveAcceptance() async {
    try {
      await _secureStorage.setPolicyAccepted(true);
      print('✅ Terms and conditions accepted and saved to secure storage');
    } catch (e) {
      print('❌ Error saving terms acceptance: $e');
      throw Exception('No se pudo guardar la aceptación de términos');
    }
  }

  Future<void> _handleAcceptance() async {
    if (!_isChecked || !_isAtBottom || _isLoading || _hasNavigated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _saveAcceptance();

      if (mounted) {
        _hasNavigated = true;

        // Mostrar snackbar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Términos y condiciones aceptados correctamente'),
            backgroundColor: Color(0xFF6D927F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Esperar un poco para que el usuario vea el mensaje
        await Future.delayed(Duration(milliseconds: 1500));

        // Llamar al callback si existe
        if (widget.onTermsAccepted != null) {
          widget.onTermsAccepted!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasNavigated = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showAcceptanceDialog() {
    if (!_isChecked || !_isAtBottom || _isLoading || _hasNavigated) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
                        color: Color(0xFF6D927F).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.thumb_up_outlined,
                        color: Color(0xFF6D927F),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Confirmar Aceptación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¿Estás seguro de que deseas aceptar los Términos y Condiciones de AgroSig?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                              setDialogState(() {});
                              await _handleAcceptance();
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6D927F),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              'Aceptar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          "Términos y Condiciones",
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
          // Header con gradiente (mantener igual)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6D927F).withOpacity(0.1),
                  Color(0xFF4772E6).withOpacity(0.05),
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
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 15),
                const Text(
                  "AgroSig",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D4A3C),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Plataforma de Gestión Agrícola Inteligente",
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y progreso
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF6D927F).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Color(0xFF6D927F),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Términos y Condiciones de Uso",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  LinearProgressIndicator(
                    value: _isAtBottom ? 1.0 : _scrollController.hasClients
                        ? (_scrollController.offset / _scrollController.position.maxScrollExtent)
                        : 0.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6D927F)),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 20),

                  // Contenedor de términos
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Bienvenido a AgroSig"),
                              _buildParagraph(
                                  "Al descargar, acceder o utilizar esta Aplicación, usted acepta quedar sujeto a los presentes "
                                      "Términos y Condiciones de Uso. Si no está de acuerdo, le recomendamos no utilizar la Aplicación."
                              ),

                              _buildSectionTitle("1. Uso de la Aplicación"),
                              _buildParagraph(
                                  "El usuario se compromete a utilizar la Aplicación únicamente para fines legales, personales y conforme a la normativa aplicable. "
                                      "Queda prohibido el uso indebido, la reproducción o distribución no autorizada del contenido de la aplicación."
                              ),

                              // ... (resto del contenido igual)

                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6D927F).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF6D927F).withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  "Última actualización: Octubre 2025",
                                  style: TextStyle(
                                    color: Color(0xFF6D927F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Checkbox
                  GestureDetector(
                    onTap: _isLoading ? null : () {
                      if (_isAtBottom) {
                        setState(() {
                          _isChecked = !_isChecked;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Por favor, lee todos los términos antes de aceptar'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isAtBottom ? Colors.grey.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isAtBottom ? Colors.grey.shade200 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _isChecked ? Color(0xFF6D927F) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _isChecked ? Color(0xFF6D927F) : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: _isChecked
                                ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "He leído y acepto los Términos y Condiciones",
                              style: TextStyle(
                                fontSize: 14,
                                color: _isAtBottom ?
                                (_isLoading ? Colors.grey.shade500 : Colors.grey.shade800)
                                    : Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.push(context, routeAgroSig(page: PrivacyPolicyScreen()));
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Color(0xFF6D927F)),
                          ),
                          child: Text(
                            "Política de Privacidad",
                            style: TextStyle(
                              color: Color(0xFF6D927F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_isChecked && _isAtBottom && !_isLoading && !_hasNavigated)
                                ? Color(0xFF6D927F)
                                : Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          onPressed: (_isChecked && _isAtBottom && !_isLoading && !_hasNavigated)
                              ? _showAcceptanceDialog
                              : null,
                          child: _isLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            "Aceptar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
    text,
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2D4A3C),
    )));
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}