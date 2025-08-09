import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String? hotelName;
  final double? userLat;
  final double? userLng;

  const MapScreen({
    super.key,
    required this.lat,
    required this.lng,
    this.hotelName,
    this.userLat,
    this.userLng,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final htmlContent = '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <style>
    html,body{height:100%;margin:0;padding:0}
    #map{height:100%;width:100%}
    .info{position:absolute;bottom:20px;left:20px;right:20px;background:white;padding:15px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.2);z-index:1000;font-family:Arial,sans-serif}
    .coords{color:#666;font-size:12px;margin-top:5px}
    .title{font-weight:bold;margin-bottom:5px}
  </style>
</head>
<body>
  <div id="map"></div>
  <div class="info">
    <div class="title" id="hotelName">Vị trí khách sạn</div>
    <div class="coords" id="coords"></div>
    <div style="font-size:11px;color:#999;margin-top:8px">
      🗺️ OpenStreetMap - Bản đồ thế giới miễn phí
    </div>
  </div>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script>
    let map;
    
    function initMapFromFlutter(hotelLat, hotelLng, userLat, userLng) {
      try {
        console.log('Initializing Leaflet map - Hotel: ' + hotelLat + ',' + hotelLng + ', User: ' + userLat + ',' + userLng);
        
        // Initialize map
        if (userLat && userLng) {
          // If we have both locations, center between them
          const centerLat = (hotelLat + userLat) / 2;
          const centerLng = (hotelLng + userLng) / 2;
          map = L.map('map').setView([centerLat, centerLng], 13);
        } else {
          // Only hotel location
          map = L.map('map').setView([hotelLat, hotelLng], 15);
        }
        
        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors',
          maxZoom: 19
        }).addTo(map);
        
        // Add hotel marker (red)
        L.marker([hotelLat, hotelLng])
          .addTo(map)
          .bindPopup('🏨 Vị trí khách sạn')
          .openPopup();
        
        // Add user marker (blue) if provided
        if (userLat && userLng) {
          const userIcon = L.divIcon({
            className: 'user-marker',
            html: '<div style="background:#007bff;width:20px;height:20px;border-radius:50%;border:2px solid white;box-shadow:0 2px 4px rgba(0,0,0,0.3)"></div>',
            iconSize: [24, 24],
            iconAnchor: [12, 12]
          });
          
          L.marker([userLat, userLng], {icon: userIcon})
            .addTo(map)
            .bindPopup('📍 Vị trí của bạn<br/>Vạn Phúc Building');
            
          // Fit map to show both markers
          const group = L.featureGroup([
            L.marker([hotelLat, hotelLng]),
            L.marker([userLat, userLng])
          ]);
          map.fitBounds(group.getBounds().pad(0.1));
        }
        
        // Update coordinates
        document.getElementById('coords').innerText = 
          'Khách sạn: ' + hotelLat.toFixed(6) + ', ' + hotelLng.toFixed(6);
        
        console.log('Leaflet map initialized successfully');
      } catch (e) {
        console.error('Leaflet map error: ' + e);
        // Fallback to simple map
        document.getElementById('map').innerHTML = 
          '<div style="height:100%;background:#f0f0f0;display:flex;align-items:center;justify-content:center;color:#666">Không thể tải bản đồ</div>';
      }
    }

    // Set hotel name from Flutter
    function setHotelName(name) {
      document.getElementById('hotelName').innerText = name || 'Vị trí khách sạn';
    }

    console.log('Leaflet map loaded');
  </script>
</body>
</html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setOnConsoleMessage((msg) {
        debugPrint('JS console: ${msg.message}');
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => debugPrint('WebView page started: $url'),
        onPageFinished: (url) async {
          debugPrint('WebView page finished: $url');
          await Future.delayed(const Duration(milliseconds: 500));
          
          try {
            // Set hotel name
            final hotelName = widget.hotelName ?? 'Khách sạn';
            await _controller.runJavaScript('setHotelName("$hotelName");');
            
            // Initialize map with both locations
            final userLatStr = widget.userLat?.toString() ?? 'null';
            final userLngStr = widget.userLng?.toString() ?? 'null';
            await _controller.runJavaScript('initMapFromFlutter(${widget.lat}, ${widget.lng}, $userLatStr, $userLngStr);');
            debugPrint('Map initialized for ${widget.hotelName} at ${widget.lat}, ${widget.lng} with user location: ${widget.userLat}, ${widget.userLng}');
          } catch (e) {
            debugPrint('Map error: $e');
          }
        },
        onWebResourceError: (err) {
          debugPrint('Web resource error: ${err.description}');
        },
        // Chặn URL loading để debug
        onNavigationRequest: (NavigationRequest request) {
          debugPrint('Navigation request: ${request.url}');
          return NavigationDecision.navigate;
        },
      ))
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.hotelName ?? 'Bản đồ Goong')),
      body: WebViewWidget(controller: _controller),
    );
  }
}

