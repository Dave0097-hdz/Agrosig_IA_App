import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerScreen({Key? key, required this.initialPosition}) : super(key: key);

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  double _currentZoom = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecciona la ubicacion de tu parcela',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                height: 36,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.check, size: 20),
                  label: Text(
                    'Registrar',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: _selectedLocation != null
                      ? () {
                    Navigator.pop(context, _selectedLocation);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: _currentZoom,
            ),
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
              });
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _currentZoom = position.zoom;
              });
            },
            markers: _selectedLocation == null
                ? {}
                : {
              Marker(
                markerId: MarkerId('selected-location'),
                position: _selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                infoWindow: InfoWindow(
                  title: 'Selected Location',
                  snippet: '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true, // Esto habilita los controles nativos
            zoomGesturesEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Controles de zoom personalizados (siempre visibles)
          Positioned(
            right: 16,
            top: 100, // Posición más abajo para no interferir con el mensaje informativo
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Botón de zoom in
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      onTap: () {
                        _mapController.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.add, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  // Botón de zoom out
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      onTap: () {
                        _mapController.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.remove, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón personalizado para mi ubicación (lado izquierdo)
          Positioned(
            bottom: 100,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'location_fab',
              child: _isLoadingLocation
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(Icons.my_location),
              onPressed: () async {
                setState(() {
                  _isLoadingLocation = true;
                });
                final position = await _getCurrentLocation();
                if (position != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(position),
                  );
                }
                setState(() {
                  _isLoadingLocation = false;
                });
              },
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              elevation: 2,
            ),
          ),

          // Indicador de selección en la parte inferior
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the map to change location',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mensaje cuando no hay selección
          if (_selectedLocation == null)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap on the map to select your plot location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<LatLng?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get current location: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }
}