import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding_plot/setting_plot_screen.dart';

var pages = [
  GetPage(
    name: "/homepage",
    page: () => HomeScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/profile",
    page: () => HomeScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/setup",
    page: () => SettingPlotScreen(),
    transition: Transition.rightToLeft,
  ),
];