import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../components/animations/animation_route.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../components/theme/theme_notifier.dart';
import '../home/home_screen.dart';
import 'message_screen.dart';

class IAOnbording extends ConsumerStatefulWidget {
  const IAOnbording({Key? key}) : super(key: key);

  @override
  _IAOnbordingState createState() => _IAOnbordingState();
}

class _IAOnbordingState extends ConsumerState<IAOnbording> {

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : ColorsAgrosig.primaryColor,
            size: 20,
          ),
          onPressed: (){
            Navigator.push(
                context,
                routeAgroSig(page: HomeScreen()
                )
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            Row(
              children: [
                Image.asset(
                  'assets/images/gpt-robot.png',
                  color: isDarkMode ? Colors.white : null,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Asistente IA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onTap: (){
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorsAgrosig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '¡Bienvenido!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorsAgrosig.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu Asistente de IA',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Con este software, puedes hacer preguntas y recibir artículos utilizando nuestro asistente de inteligencia artificial',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    height: 1.5,
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorsAgrosig.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/onboarding.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, 
                      routeAgroSig(page: MessageScreen())
                  );
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsAgrosig.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    elevation: 3,
                    shadowColor: ColorsAgrosig.primaryColor.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Comenzar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}