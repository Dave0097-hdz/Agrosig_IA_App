import 'package:agrosig_app/components/animations/animation_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/gemeni_ia/ia_onbording_screen.dart';
import '../../controller/provider/notification_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Barra de navegación principal
          Row(
            children: [
              // Inicio
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: "Inicio",
                  index: 0,
                ),
              ),
              // Tareas
              Expanded(
                child: _buildNavItem(
                  icon: Icons.list_alt_outlined,
                  activeIcon: Icons.list_alt,
                  label: "Actividades",
                  index: 1,
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: _buildNotificationNavItem(unreadCount),
              ),
              // Ajustes
              Expanded(
                child: _buildNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: "Ajustes",
                  index: 3,
                ),
              ),
            ],
          ),

          // Botón Central Flotante
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 28,
            top: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  routeAgroSig(page: IAOnbording())
                );
              },
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF2E7D32),
                      Color(0xFF1B5E20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green[800]!.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.green[500]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_sharp,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationNavItem(int unreadCount) {
    bool isSelected = currentIndex == 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(2),
        splashColor: Colors.green.withOpacity(0.1),
        highlightColor: Colors.green.withOpacity(0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? Icons.notifications : Icons.notifications_outlined,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                  size: 24,
                ),
                // Badge para notificaciones no leídas
                if (unreadCount > 0) ...[
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5757), Color(0xFFC20808)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Notificaciones",
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    bool isSelected = currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.green.withOpacity(0.1),
        highlightColor: Colors.green.withOpacity(0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}