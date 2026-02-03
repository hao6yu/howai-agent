import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';

class StreetViewModal extends StatefulWidget {
  final PlaceResult place;

  const StreetViewModal({
    super.key,
    required this.place,
  });

  @override
  State<StreetViewModal> createState() => _StreetViewModalState();
}

class _StreetViewModalState extends State<StreetViewModal> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final streetViewUrl = _buildStreetViewUrl();
    // print('[Street View Modal] WebView URL length: ${streetViewUrl.length}');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // print('[Street View Modal] Page started loading');
            if (mounted) {
              setState(() {
                isLoading = true;
                hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            // print('[Street View Modal] Page finished loading');
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // print('[Street View Modal] WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(streetViewUrl));
  }

  String _buildStreetViewUrl() {
    final lat = widget.place.latitude;
    final lng = widget.place.longitude;
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    // print('[Street View Modal] Building URL for: ${widget.place.name}');
    // print('[Street View Modal] Location: $lat, $lng');

    final html = '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <title>Street View</title>
    <style>
        body { 
            margin: 0; 
            padding: 0; 
            height: 100vh; 
            overflow: hidden; 
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            background: #000;
        }
        #street-view { 
            width: 100%; 
            height: 100%; 
            background: #000;
        }
        .message { 
            position: absolute; 
            top: 50%; 
            left: 50%; 
            transform: translate(-50%, -50%);
            text-align: center;
            color: white;
            z-index: 1000;
        }
        .spinner {
            border: 2px solid #333;
            border-top: 2px solid #fff;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            animation: spin 1s linear infinite;
            margin: 0 auto 8px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div id="street-view"></div>
    <div id="loading" class="message">
        <div class="spinner"></div>
        <div style="font-size: 14px;">Loading...</div>
    </div>
    <div id="error" class="message" style="display: none;">
        <div style="font-size: 16px; margin-bottom: 8px;">📸</div>
        <div style="font-size: 14px;">Street View not available</div>
    </div>
    
    <script>
        console.log('Street View Modal initialization...');
        
        function initStreetView() {
            console.log('Google Maps API loaded');
            
            try {
                const panorama = new google.maps.StreetViewPanorama(
                    document.getElementById('street-view'),
                    {
                        position: { lat: $lat, lng: $lng },
                        pov: { heading: 0, pitch: 0 },
                        zoom: 1,
                        addressControl: false,
                        linksControl: false,
                        panControl: false,
                        enableCloseButton: false,
                        zoomControl: false,
                        fullscreenControl: false,
                        motionTracking: false,
                        motionTrackingControl: false,
                        showRoadLabels: false
                    }
                );
                
                panorama.addListener('status_changed', function() {
                    const status = panorama.getStatus();
                    console.log('Street View status:', status);
                    
                    document.getElementById('loading').style.display = 'none';
                    
                    if (status !== 'OK') {
                        document.getElementById('error').style.display = 'block';
                    }
                });
                
                setTimeout(function() {
                    if (document.getElementById('loading').style.display !== 'none') {
                        document.getElementById('loading').style.display = 'none';
                        if (panorama.getStatus() !== 'OK') {
                            document.getElementById('error').style.display = 'block';
                        }
                    }
                }, 6000);
                
            } catch (error) {
                console.error('Error creating Street View:', error);
                document.getElementById('loading').style.display = 'none';
                document.getElementById('error').style.display = 'block';
            }
        }
        
        window.gm_authFailure = function() {
            console.error('Google Maps API authentication failed');
            document.getElementById('loading').style.display = 'none';
            document.getElementById('error').innerHTML = '<div style="font-size: 16px; margin-bottom: 8px;">🔑</div><div style="font-size: 14px;">API Key Error</div>';
            document.getElementById('error').style.display = 'block';
        };
    </script>
    
    <script async defer 
        src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initStreetView">
    </script>
</body>
</html>
    ''';

    return 'data:text/html;charset=utf-8,' + Uri.encodeComponent(html);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final defaultHeight = screenHeight * 0.6;
        final expandedHeight = screenHeight * 0.85;

        return Container(
          height: isExpanded ? expandedHeight : defaultHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar and header
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Header row
                    Row(
                      children: [
                        // Street View icon
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.streetview,
                            color: Colors.blue,
                            size: settings.getScaledFontSize(20),
                          ),
                        ),

                        SizedBox(width: 12),

                        // Place info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.streetView,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: settings.getScaledFontSize(18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.place.name,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: settings.getScaledFontSize(14),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Expand/contract button
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          icon: Icon(
                            isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.white.withOpacity(0.8),
                            size: settings.getScaledFontSize(20),
                          ),
                        ),

                        // External link button
                        IconButton(
                          onPressed: () => _openExternalStreetView(),
                          icon: Icon(
                            Icons.open_in_new,
                            color: Colors.white.withOpacity(0.8),
                            size: settings.getScaledFontSize(20),
                          ),
                        ),

                        // Close button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Colors.white.withOpacity(0.8),
                            size: settings.getScaledFontSize(20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Street View content
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // WebView
                      WebViewWidget(controller: controller),

                      // Loading overlay
                      if (isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.8),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context)!.loadingStreetView,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: settings.getScaledFontSize(14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Error overlay
                      if (hasError && !isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.9),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.streetview_rounded,
                                  color: Colors.white.withOpacity(0.6),
                                  size: settings.getScaledFontSize(48),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.streetViewNotAvailable,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: settings.getScaledFontSize(16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.streetViewNoCoverage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: settings.getScaledFontSize(12),
                                  ),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _openExternalStreetView(),
                                  icon: Icon(Icons.open_in_new, size: 16),
                                  label: Text(AppLocalizations.of(context)!.openExternal),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                ),
                              ],
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
      },
    );
  }

  void _openExternalStreetView() async {
    final streetViewUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.place.latitude},${widget.place.longitude}';

    try {
      final Uri url = Uri.parse(streetViewUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open external Street View'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Function to show the Street View modal
void showStreetViewModal(BuildContext context, PlaceResult place) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    builder: (context) => StreetViewModal(place: place),
  );
}
