import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import 'package:haogpt/generated/app_localizations.dart';

class StreetViewScreen extends StatefulWidget {
  final PlaceResult place;

  const StreetViewScreen({
    super.key,
    required this.place,
  });

  @override
  State<StreetViewScreen> createState() => _StreetViewScreenState();
}

class _StreetViewScreenState extends State<StreetViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Create Street View URL
    final streetViewUrl = _buildStreetViewUrl();
    // print('[Street View] WebView URL length: ${streetViewUrl.length}');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // print('[Street View] Page started loading: ${url.substring(0, 50)}...');
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (String url) {
            // print('[Street View] Page finished loading');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // print('[Street View] WebView error: ${error.description}');
            setState(() {
              isLoading = false;
              hasError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // print('[Street View] Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'StreetViewChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // print('[Street View] JS Message: ${message.message}');
        },
      )
      ..loadRequest(Uri.parse(streetViewUrl));
  }

  String _buildStreetViewUrl() {
    final lat = widget.place.latitude;
    final lng = widget.place.longitude;
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

    // Log for debugging
    // print('[Street View] Building URL with API key: ${apiKey.isNotEmpty ? 'Present' : 'Missing'}');
    // print('[Street View] Location: $lat, $lng');

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
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
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
        <div>Loading Street View...</div>
    </div>
    <div id="error" class="message" style="display: none;">
        <h3>Street View Not Available</h3>
        <p>This location may not have Street View coverage.</p>
    </div>
    
    <script>
        console.log('Starting Street View initialization...');
        console.log('API Key present: ${apiKey.isNotEmpty ? 'Yes' : 'No'}');
        console.log('Location: $lat, $lng');
        
        function initStreetView() {
            console.log('Google Maps API loaded, creating Street View...');
            
            try {
                const panorama = new google.maps.StreetViewPanorama(
                    document.getElementById('street-view'),
                    {
                        position: { lat: $lat, lng: $lng },
                        pov: { heading: 0, pitch: 0 },
                        zoom: 1,
                        addressControl: false,
                        linksControl: true,
                        panControl: true,
                        enableCloseButton: false,
                        zoomControl: true,
                        fullscreenControl: false,
                        motionTracking: false,
                        motionTrackingControl: false,
                        showRoadLabels: true
                    }
                );
                
                console.log('Street View panorama created');
                
                panorama.addListener('status_changed', function() {
                    const status = panorama.getStatus();
                    console.log('Street View status:', status);
                    
                    document.getElementById('loading').style.display = 'none';
                    
                    if (status === 'OK') {
                        console.log('Street View loaded successfully');
                    } else {
                        console.log('Street View failed to load:', status);
                        document.getElementById('error').style.display = 'block';
                    }
                });
                
                setTimeout(function() {
                    if (document.getElementById('loading').style.display !== 'none') {
                        console.log('Timeout reached, hiding loading...');
                        document.getElementById('loading').style.display = 'none';
                        if (panorama.getStatus() !== 'OK') {
                            document.getElementById('error').style.display = 'block';
                        }
                    }
                }, 8000);
                
            } catch (error) {
                console.error('Error creating Street View:', error);
                document.getElementById('loading').style.display = 'none';
                document.getElementById('error').style.display = 'block';
            }
        }
        
        window.gm_authFailure = function() {
            console.error('Google Maps API authentication failed');
            document.getElementById('loading').style.display = 'none';
            document.getElementById('error').innerHTML = '<h3>API Error</h3><p>Please check your API key.</p>';
            document.getElementById('error').style.display = 'block';
        };
    </script>
    
    <script async defer 
        src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initStreetView"
        onerror="console.error('Failed to load Google Maps API'); document.getElementById('loading').style.display = 'none'; document.getElementById('error').style.display = 'block';">
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
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: settings.getScaledFontSize(24),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Street View',
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
                    fontSize: settings.getScaledFontSize(12),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              // Share button
              IconButton(
                onPressed: () => _shareStreetView(),
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: settings.getScaledFontSize(20),
                ),
              ),
              // Open in external app button
              IconButton(
                onPressed: () => _openExternalStreetView(),
                icon: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                  size: settings.getScaledFontSize(20),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // WebView
              WebViewWidget(controller: controller),

              // Loading indicator
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Street View...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: settings.getScaledFontSize(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Error state
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
                          size: settings.getScaledFontSize(64),
                        ),
                        SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.streetViewNotAvailable,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: settings.getScaledFontSize(20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.streetViewNoCoverage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: settings.getScaledFontSize(14),
                          ),
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _initializeWebView(),
                              icon: Icon(Icons.refresh),
                              label: Text(AppLocalizations.of(context)!.retry),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5856D6),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => _openExternalStreetView(),
                              icon: Icon(Icons.open_in_new),
                              label: Text(AppLocalizations.of(context)!.openExternal),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
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

  void _shareStreetView() {
    final streetViewUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.place.latitude},${widget.place.longitude}';

    // You can implement sharing logic here
    // For now, we'll just show a snackbar with the URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.streetViewUrlCopied),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openExternalStreetView() async {
    final streetViewUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.place.latitude},${widget.place.longitude}&heading=0&pitch=0&fov=80';

    try {
      final Uri url = Uri.parse(streetViewUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotOpenStreetView),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
