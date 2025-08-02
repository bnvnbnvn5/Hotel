import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final double lat;
  final double lng;
  final String? hotelName;
  const MapScreen({Key? key, required this.lat, required this.lng, this.hotelName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 16,
    );
    return Scaffold(
      appBar: AppBar(title: Text(hotelName ?? 'Vị trí khách sạn')),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: {
          Marker(
            markerId: MarkerId('hotel'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: hotelName),
          ),
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
} 