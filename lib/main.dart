import 'package:agrosig_app/components/theme/theme_notifier.dart';
import 'package:agrosig_app/components/theme/themes.dart';
import 'package:agrosig_app/controller/routers/routes.dart';
import 'package:agrosig_app/controller/splace_controller.dart';
import 'package:agrosig_app/domain/services/notifications_services/firebase_messaging_service.dart';
import 'package:agrosig_app/firebase_options.dart';
import 'package:agrosig_app/screens/into/into_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await FirebaseMessagingService().initialize();

  runApp(
      ProviderScope(child: MyApp())
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    SplaceController splaceController = Get.put(SplaceController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      title: 'AgroSig IA',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      getPages: pages,
      home: const IntoScreen(),
    );
  }
}