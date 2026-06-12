import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../config/api_config.dart';
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
  final MapController _mapController = MapController();
  static const LatLng _dubaiCenter = LatLng(25.2048, 55.2708);

  // Cache for rendered marker images
  final Map<String, ui.Image> _iconCache = {};

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
  }

  String _extractLabel(String developerName) {
    if (developerName.isEmpty) return '';
    final words = developerName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    final word = (words.length > 1 && words[0].toLowerCase() == 'dubai')
        ? words[1]
        : words[0];
    return _capitalizeFirst(word);
  }

  Future<ui.Image> _renderMarkerImage({
    required String text,
    required Color background,
    required Color border,
    int diameter = 180,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final sz = diameter.toDouble();
    final center = Offset(sz / 2, sz / 2);
    final radius = sz / 2;

    // Shadow
    canvas.drawCircle(
      center,
      radius - 3,
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    // Outer coloured ring
    canvas.drawCircle(
      center,
      radius - 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = border,
    );
    // Inner white ring
    canvas.drawCircle(
      center,
      radius - 11,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.9),
    );
    // White fill
    canvas.drawCircle(center, radius - 16, Paint()..color = Colors.white);

    // Label text
    final truncated = text.length > 15 ? text.substring(0, 15) : text;
    final tp = TextPainter(
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
    tp.layout(maxWidth: sz - 42);
    tp.paint(canvas, Offset((sz - tp.width) / 2, (sz - tp.height) / 2));

    return recorder.endRecording().toImage(diameter, diameter);
  }

  Future<ui.Image> _getOrBuildIcon(String key, String label, bool isRental) async {
    if (_iconCache.containsKey(key)) return _iconCache[key]!;
    final bg = isRental ? const Color(0xFF6C2BD9) : const Color(0xFFF7B500);
    final border = isRental ? const Color(0xFFB896FF) : const Color(0xFFFFE08A);
    final img = await _renderMarkerImage(text: label, background: bg, border: border);
    _iconCache[key] = img;
    return img;
  }

  void _fitMarkers(List<PropertyRecord> records) {
    final valid = records.where((r) => r.hasValidCoordinates).toList();
    if (valid.isEmpty) return;

    var minLat = valid.first.latitude!;
    var maxLat = valid.first.latitude!;
    var minLng = valid.first.longitude!;
    var maxLng = valid.first.longitude!;

    for (final r in valid) {
      if (r.latitude! < minLat) minLat = r.latitude!;
      if (r.latitude! > maxLat) maxLat = r.latitude!;
      if (r.longitude! < minLng) minLng = r.longitude!;
      if (r.longitude! > maxLng) maxLng = r.longitude!;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat - 0.01, minLng - 0.01),
          LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(mapsFilterProvider);
    final mapsDataAsync = ref.watch(mapsDataProvider);
    final languageCode = ref.watch(languageProvider);
    final t = (String key) => LanguageService.translate(key, languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('A Product By Torodo Group'),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: t('Search for Properties'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) =>
                        ref.read(mapsSearchProvider.notifier).setSearch(v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterButton(
                          label: t('All'),
                          isSelected: currentFilter == 'All',
                          onTap: () => ref
                              .read(mapsFilterProvider.notifier)
                              .setFilter('All'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterButton(
                          label: t('Rental'),
                          isSelected: currentFilter == 'Rental',
                          onTap: () => ref
                              .read(mapsFilterProvider.notifier)
                              .setFilter('Rental'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterButton(
                          label: t('Off Plan'),
                          isSelected: currentFilter == 'Off Plan',
                          onTap: () => ref
                              .read(mapsFilterProvider.notifier)
                              .setFilter('Off Plan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Map ─────────────────────────────────────────────────────
            Expanded(
              child: mapsDataAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error loading map',
                          style: GoogleFonts.inter(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(err.toString(),
                          style: GoogleFonts.inter(color: Colors.grey),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                data: (data) {
                  final validRecords = (data?.records ?? [])
                      .where((r) => r.hasValidCoordinates)
                      .toList();

                  final initialCenter = validRecords.isNotEmpty
                      ? LatLng(validRecords.first.latitude!,
                          validRecords.first.longitude!)
                      : _dubaiCenter;

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: initialCenter,
                          initialZoom: 12,
                          backgroundColor: const Color(0xFF1d1d1d),
                          onMapReady: () {
                            if (validRecords.length > 1) {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () => _fitMarkers(validRecords),
                              );
                            }
                          },
                        ),
                        children: [
                          // MapTiler dark style tiles
                          TileLayer(
                            urlTemplate:
                                'https://api.maptiler.com/maps/dataviz-dark/{z}/{x}/{y}.png?key=${ApiConfig.mapTilerApiKey}',
                            userAgentPackageName: 'com.continental.app',
                            tileDisplay: const TileDisplay.fadeIn(),
                          ),
                          // Property markers
                          MarkerLayer(
                            markers: validRecords.map((record) {
                              final isRental =
                                  record.propertyType.toLowerCase() == 'rental';
                              final label = record.developerName.isNotEmpty
                                  ? _extractLabel(record.developerName)
                                  : _extractLabel(record.propertyName);
                              final cacheKey =
                                  '${isRental ? 'r' : 'o'}_$label'.toLowerCase();

                              return Marker(
                                point: LatLng(
                                    record.latitude!, record.longitude!),
                                width: 72,
                                height: 72,
                                child: GestureDetector(
                                  onTap: () {
                                    if (record.id != null) {
                                      context.goNamed('details',
                                          pathParameters: {
                                            'itemId': record.id.toString()
                                          });
                                    }
                                  },
                                  child: Tooltip(
                                    message:
                                        '${record.propertyName}\n${record.developerName}',
                                    child: FutureBuilder<ui.Image>(
                                      future: _getOrBuildIcon(
                                          cacheKey, label, isRental),
                                      builder: (context, snap) {
                                        if (!snap.hasData) {
                                          return Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isRental
                                                  ? const Color(0xFF6C2BD9)
                                                  : const Color(0xFFF7B500),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                          );
                                        }
                                        return RawImage(
                                          image: snap.data,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // ── Zoom controls ──────────────────────────────────
                      Positioned(
                        right: 10,
                        bottom: 140,
                        child: Column(
                          children: [
                            _ZoomButton(
                              icon: Icons.add,
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _ZoomButton(
                              icon: Icons.remove,
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── No properties overlay ──────────────────────────
                      if (validRecords.isEmpty)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No properties with valid locations',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
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

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
