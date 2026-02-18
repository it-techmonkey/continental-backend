import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/maps_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/language_service.dart';
import '../../models/property_map_model.dart';

class Dashboardscreen extends ConsumerStatefulWidget {
  const Dashboardscreen({super.key});

  @override
  ConsumerState<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends ConsumerState<Dashboardscreen> {
  GoogleMapController? _mapController;
  final LatLng _dubaiCenter = const LatLng(25.2048, 55.2708); // Dubai coordinates
  BitmapDescriptor? _rentalIcon;
  BitmapDescriptor? _offPlanIcon;
  static const String _darkMapStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
    {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e0e0e"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]}
  ]
  ''';

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _generateMarkerIcons();
  }

  Future<void> _generateMarkerIcons() async {
    // icons are generated per marker with text; keep base fallback colors
    _rentalIcon = await _buildCircleMarkerIconWithText(
      text: '',
      background: const Color(0xFF6C2BD9),
      border: const Color(0xFFB896FF),
    );
    _offPlanIcon = await _buildCircleMarkerIconWithText(
      text: '',
      background: const Color(0xFFF7B500),
      border: const Color(0xFFFFE08A),
    );
    if (mounted) setState(() {});
  }

  // Draws a circular marker with a text label (lowercased, truncated)
  Future<BitmapDescriptor> _buildCircleMarkerIconWithText({
    required String text,
    required Color background,
    required Color border,
    int diameter = 180,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(diameter.toDouble(), diameter.toDouble());

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer soft shadow ring
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawCircle(center, radius - 3, shadowPaint);

    // Primary colored ring
    final primaryRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = border;
    canvas.drawCircle(center, radius - 7, primaryRing);

    // Secondary light ring to mimic double border
    final secondaryRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(center, radius - 11, secondaryRing);

    // Inner fill (white like the reference)
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - 16, innerPaint);

    // Text label - use text as-is (already capitalized when passed)
    final truncated = text.length > 15 ? text.substring(0, 15) : text;
    final textPainter = TextPainter(
      text: TextSpan(
        text: truncated,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 27,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    );
    textPainter.layout(maxWidth: size.width - 42);
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    // Record to image
    final image = await recorder.endRecording().toImage(diameter, diameter);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  final Map<String, BitmapDescriptor> _labelIconCache = {};

  void _ensureLabelIcon(String key, String displayText, bool isRental) async {
    if (_labelIconCache.containsKey(key)) return;
    final bg = isRental ? const Color(0xFF6C2BD9) : const Color(0xFFF7B500);
    final border = isRental ? const Color(0xFFB896FF) : const Color(0xFFFFE08A);
    // Use the capitalized display text for the icon, but truncate if needed
    final truncatedDisplay = displayText.length > 15 ? displayText.substring(0, 15) : displayText;
    final icon = await _buildCircleMarkerIconWithText(text: truncatedDisplay, background: bg, border: border);
    _labelIconCache[key] = icon;
    if (mounted) setState(() {});
  }

  // Helper function to extract the appropriate word from developer name
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
  }

  String _extractLabelFromDeveloperName(String developerName) {
    if (developerName.isEmpty) return '';
    
    final words = developerName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    
    String result;
    // If first word is "dubai" (case insensitive), take the second word
    if (words.length > 1 && words[0].toLowerCase() == 'dubai') {
      result = words[1];
    } else {
      // Otherwise, return the first word
      result = words[0];
    }
    
    // Capitalize the first letter
    return _capitalizeFirst(result);
  }

  Set<Marker> _buildMarkers(List<PropertyRecord> records) {
    final markers = <Marker>{};
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      
      if (!record.hasValidCoordinates) continue;
      
      // Different icons for Rental vs Off Plan
      final isRental = record.propertyType.toLowerCase() == 'rental';
      
      // Extract label from developer name or property name
      String labelText;
      if (record.developerName.isNotEmpty) {
        labelText = _extractLabelFromDeveloperName(record.developerName);
      } else {
        // Apply same logic to property name if developer name is empty
        labelText = _extractLabelFromDeveloperName(record.propertyName);
      }
      
      // Use lowercase for cache key, but keep capitalized version for display
      final labelLower = labelText.toLowerCase();
      final key = labelLower.length > 15 ? labelLower.substring(0, 15) : labelLower;
      // Ensure generation in background with capitalized text for display
      _ensureLabelIcon(key, labelText, isRental);
      final icon = _labelIconCache[key] ?? (isRental ? (_rentalIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)) : (_offPlanIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)));

      markers.add(
        Marker(
          markerId: MarkerId('property_$i'),
          position: LatLng(record.latitude!, record.longitude!),
          infoWindow: InfoWindow(
            title: record.propertyName,
            snippet: '${record.developerName}\n${record.propertyType}',
          ),
          icon: icon,
          onTap: () {
            if (record.id != null) {
              context.goNamed('details', pathParameters: {'itemId': record.id.toString()});
            }
          },
        ),
      );
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(mapsFilterProvider);
    final mapsDataAsync = ref.watch(mapsDataProvider);
    final languageCode = ref.watch(languageProvider);
    final translate = (String key) => LanguageService.translate(key, languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Branding Text
                  Text(
                    translate('A Product By Torodo Group'),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: translate('Search for Properties'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(mapsSearchProvider.notifier).setSearch(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _FilterButton(
                          label: translate('All'),
                          isSelected: currentFilter == 'All',
                          onTap: () {
                            ref.read(mapsFilterProvider.notifier).setFilter('All');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterButton(
                          label: translate('Rental'),
                          isSelected: currentFilter == 'Rental',
                          onTap: () {
                            ref.read(mapsFilterProvider.notifier).setFilter('Rental');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterButton(
                          label: translate('Off Plan'),
                          isSelected: currentFilter == 'Off Plan',
                          onTap: () {
                            ref.read(mapsFilterProvider.notifier).setFilter('Off Plan');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Map Section
            Expanded(
              child: mapsDataAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading map',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        style: GoogleFonts.inter(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (data) {
                  if (data == null || data.records.isEmpty) {
                    return Center(
                      child: Text(
                        'No properties found',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    );
                  }

                  // Filter records with valid coordinates
                  final validRecords = data.records
                      .where((r) => r.hasValidCoordinates)
                      .toList();

                  if (validRecords.isEmpty) {
                    return Center(
                      child: Text(
                        'No properties with valid locations',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: validRecords.isNotEmpty
                              ? LatLng(
                                  validRecords.first.latitude!,
                                  validRecords.first.longitude!,
                                )
                              : _dubaiCenter,
                          zoom: 15.0,
                        ),
                        markers: _buildMarkers(validRecords),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        mapToolbarEnabled: true,
                        compassEnabled: true,
                        liteModeEnabled: false,
                        buildingsEnabled: true,
                    onMapCreated: (GoogleMapController controller) async {
                      _mapController = controller;
                      print('🗺️ Map created successfully!');
                      print('🗺️ Map controller initialized');
                      await controller.setMapStyle(_darkMapStyle);
                      
                      // Force a camera update to trigger tile loading
                      await Future.delayed(const Duration(milliseconds: 300));
                      
                      if (validRecords.isNotEmpty && validRecords.first.hasValidCoordinates) {
                        final firstRecord = validRecords.first;
                        await controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                firstRecord.latitude!,
                                firstRecord.longitude!,
                              ),
                              zoom: 14.0,
                            ),
                          ),
                        );
                        print('📸 Camera moved to first property');
                      }
                      
                      // Fit all markers in view after a delay
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (validRecords.isNotEmpty) {
                        print('📍 Fitting ${validRecords.length} markers in view');
                        _fitMarkersInView(validRecords);
                      }
                    },
                        onTap: (LatLng location) {
                          print('🔍 Map tapped at: ${location.latitude}, ${location.longitude}');
                        },
                      ),
                      // Custom Zoom Controls
                      Positioned(
                        right: 10,
                        bottom: 140,
                        child: Column(
                          children: [
                            // Zoom In Button
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Zoom Out Button
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.remove, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitMarkersInView(List<PropertyRecord> records) {
    if (_mapController == null || records.isEmpty) return;

    final bounds = records
        .where((r) => r.hasValidCoordinates)
        .map((r) => LatLng(r.latitude!, r.longitude!))
        .toList();

    if (bounds.isEmpty) return;

    double minLat = bounds.first.latitude;
    double maxLat = bounds.first.latitude;
    double minLng = bounds.first.longitude;
    double maxLng = bounds.first.longitude;

    for (var point in bounds) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        100.0,
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[700] : Colors.grey[800],
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
