import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String? hotelName;

  const MapScreen({
    Key? key,
    required this.lat,
    required this.lng,
    this.hotelName,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          html, body, #map { height: 100%; margin: 0; padding: 0; }
        </style>
        <script 
          src="https://maps.goong.io/js/api.js?api_key=z6svPeZLdsuIowOpU7NUMsZXzEyHYNNMcA9xPfg3" 
          onload="initMap()">
        </script>
      </head>
      <body>
        <div id="map"></div>
        <script>
          function initMap() {
            if (typeof goongjs === 'undefined') {
              console.error('GoongJS not loaded');
              return;
            }
            var map = new goongjs.Map({
              container: 'map',
              style: 'https://tiles.goong.io/assets/goong_map_web.json',
              center: [${widget.lng}, ${widget.lat}],
              zoom: 15
            });
            new goongjs.Marker()
              .setLngLat([${widget.lng}, ${widget.lat}])
              .addTo(map);
          }
        </script>
      </body>
      </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
