import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'data.dart';

class IntoScreen extends StatefulWidget {
  const IntoScreen({super.key});

  @override
  State<IntoScreen> createState() => _IntoScreenState();
}

class _IntoScreenState extends State<IntoScreen> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _lottieController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _lottieController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _lottieController.forward();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              Colors.grey[900]!,
              Colors.grey[800]!,
              Colors.grey[700]!,
            ]
                : [
              Colors.white,
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Espacio superior
                const Spacer(flex: 1),

                // Animación principal
                Expanded(
                  flex: 4,
                  child: AnimatedBuilder(
                    animation: _lottieController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Lottie.asset(
                            'assets/animation/1.json',
                            width: size.width * 0.6,
                            height: size.width * 0.6,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.low,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Título con animación
                AnimatedBuilder(
                  animation: _lottieController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                        child: Column(
                          children: [
                            Text(
                              "AGROSIG",
                              style: TextStyle(
                                fontSize: size.width * 0.08,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Descripción
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _lottieController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                "Aplicación diseñada para ser una herramienta integral y personalizada que ayuda a los agricultores a optimizar sus cultivos.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Línea divisoria elegante
                              Container(
                                width: 100,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.grey[400]!,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Sección institucional
                Expanded(
                  flex: 1,
                  child: AnimatedBuilder(
                    animation: _lottieController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              "UTSELVA",
                              style: TextStyle(
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Proyecto Integrador",
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Logo inferior
                AnimatedBuilder(
                  animation: _lottieController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Image.asset(
                          collageLogo,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              "AGROSIG",
                              style: TextStyle(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}