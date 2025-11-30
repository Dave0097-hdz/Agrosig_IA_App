import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/boton/btn_navbar.dart';
import '../../components/widgets/widget_chatbot_card.dart';
import '../../components/widgets/widget_location_header.dart';
import '../../components/widgets/widget_task_secction.dart';
import '../../components/widgets/widget_view_carrusel.dart';
import '../../components/widgets/widget_weather_card.dart';
import '../../components/widgets/widget_weekly_summary.dart';
import '../activitys/activitys_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/setting_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPageContent(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ActivitysScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const SettingsPage();
      default:
        return const Center(child: Text('Página Desconocida'));
    }
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LocationHeader(
          onNotificationTap: () {
            _onNavItemTapped(2);
          },
        ),
        const SizedBox(height: 20),
        WeatherCard(),
        const SizedBox(height: 16),
        IAChatbotCard(),
        const SizedBox(height: 24),
        ViewCarousel(
          onActivitySelected: () {
            _onNavItemTapped(1);
          },
        ),
        const SizedBox(height: 24),
        TasksToDoSection(
          onActivitySelected: () {
            _onNavItemTapped(1);
          },
        ),
        const SizedBox(height: 24),
        WeeklySummaryWidget(),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
      body: SafeArea(
        child: _getPageContent(_selectedIndex),
      ),
    );
  }
}