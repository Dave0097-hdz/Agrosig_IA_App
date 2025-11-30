import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/activitys/activitys_screen.dart';
import '../../screens/crop/crop_screen.dart';
import '../../screens/production_batch/production_batch_screen.dart';
import '../../screens/weather/weather_screen.dart';

final selectedCropIdProvider = StateProvider<int>((ref) => 1);

class ViewCarousel extends ConsumerStatefulWidget {
  final VoidCallback? onActivitySelected;

  const ViewCarousel({
    super.key,
    this.onActivitySelected,
  });

  @override
  ConsumerState<ViewCarousel> createState() => _ViewCarouselState();
}

class _ViewCarouselState extends ConsumerState<ViewCarousel> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<ViewCarouselItem> _carouselItems = [
      ViewCarouselItem(
        title: "Meteorología",
        imagePath: "assets/images/meteorologia_1.png",
        iconBgColor: Colors.grey[300]!,
        page: const WeatherScreen(),
      ),
      ViewCarouselItem(
        title: "Cultivos",
        imagePath: "assets/images/campo.png",
        iconBgColor: Colors.grey[300]!,
        page: const CropScreen(),
      ),
      ViewCarouselItem(
        title: "Actividad",
        imagePath: "assets/images/agregar_tarea.png",
        iconBgColor: Colors.grey[300]!,
        page: ActivitysScreen(),
        isActivity: true, // Marcamos esta como actividad
      ),
      ViewCarouselItem(
        title: "Producción",
        imagePath: "assets/images/produccion.png",
        iconBgColor: Colors.grey[300]!,
        page: const ProductionBatchScreen(),
      ),
    ];

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Accesos Rápidos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == _carouselItems.length - 1 ? 0 : 16,
                  ),
                  child: ViewCarouselItemCard(
                    item: _carouselItems[index],
                    isSelected: _selectedIndex == index,
                    onActivitySelected: widget.onActivitySelected,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ViewCarouselItem {
  final String title;
  final String imagePath;
  final Color iconBgColor;
  final Widget page;
  final bool isActivity;

  ViewCarouselItem({
    required this.title,
    required this.imagePath,
    required this.iconBgColor,
    required this.page,
    this.isActivity = false,
  });
}

class ViewCarouselItemCard extends StatefulWidget {
  final ViewCarouselItem item;
  final bool isSelected;
  final VoidCallback? onActivitySelected;

  const ViewCarouselItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    this.onActivitySelected,
  });

  @override
  State<ViewCarouselItemCard> createState() => _ViewCarouselItemCardState();
}

class _ViewCarouselItemCardState extends State<ViewCarouselItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: widget.isSelected
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: widget.isSelected || _isHovered
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isSelected ? Colors.white : widget.item.iconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? Border.all(color: Colors.green, width: 1)
                    : null,
              ),
              child: Center(
                child: Image.asset(
                  widget.item.imagePath,
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            Text(
              widget.item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.isSelected ? Colors.green : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered
                      ? Colors.green
                      : (widget.isSelected ? Colors.green : Colors.grey[300]),
                  foregroundColor: widget.isSelected || _isHovered ? Colors.white : Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (widget.item.isActivity && widget.onActivitySelected != null) {
                    // Si es actividad y tenemos callback, lo usamos
                    widget.onActivitySelected!();
                  } else {
                    // Para otras pantallas, navegamos normalmente
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => widget.item.page),
                    );
                  }
                },
                child: const Text(
                  'Acceder',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}