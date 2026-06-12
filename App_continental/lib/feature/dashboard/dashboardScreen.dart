import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
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

  Timer? _searchDebounce;
  bool _mapReady = false;
  String? _selectedKey;

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

  String _recordKey(PropertyRecord r) =>
      '${r.source.name}_${r.id ?? '${r.latitude}_${r.longitude}_${r.propertyName}'}';

  Future<ui.Image> _renderMarkerImage({
    required String text,
    required Color border,
    bool selected = false,
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
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    // Selection glow ring
    if (selected) {
      canvas.drawCircle(
        center,
        radius - 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = Colors.white,
      );
    }
    // Outer coloured ring
    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 9 : 6
        ..color = border,
    );
    // Inner white ring
    canvas.drawCircle(
      center,
      radius - 14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    // White fill
    canvas.drawCircle(center, radius - 19, Paint()..color = Colors.white);

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
    tp.layout(maxWidth: sz - 46);
    tp.paint(canvas, Offset((sz - tp.width) / 2, (sz - tp.height) / 2));

    return recorder.endRecording().toImage(diameter, diameter);
  }

  Color _markerBorderColor(PropertyRecord record) {
    if (record.source == PropertySource.catalog) {
      return const Color(0xFF8A8A8A); // neutral grey for market listings
    }
    final isRental = record.propertyType.toLowerCase() == 'rental';
    return isRental ? const Color(0xFF6C2BD9) : const Color(0xFFF7B500);
  }

  Future<ui.Image> _getOrBuildIcon(
      String key, String label, Color border, bool selected) async {
    if (_iconCache.containsKey(key)) return _iconCache[key]!;
    final img = await _renderMarkerImage(
        text: label, border: border, selected: selected);
    _iconCache[key] = img;
    return img;
  }

  void _fitMarkers(List<PropertyRecord> records) {
    final valid = records.where((r) => r.hasValidCoordinates).toList();
    if (valid.isEmpty || !_mapReady) return;

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

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        ref.read(mapsSearchProvider.notifier).setSearch(value.trim());
      }
    });
  }

  String _formatPrice(PropertyRecord record) {
    final compact = NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: 'AED ',
      decimalDigits: 1,
    );
    if (record.price != null) return compact.format(record.price);
    if (record.priceFrom != null && record.priceTo != null) {
      return '${compact.format(record.priceFrom)} – ${compact.format(record.priceTo)}';
    }
    if (record.priceFrom != null) {
      return 'From ${compact.format(record.priceFrom)}';
    }
    return '';
  }

  void _onMarkerTap(PropertyRecord record, String key) {
    setState(() => _selectedKey = key);
    _mapController.move(
      LatLng(record.latitude!, record.longitude!),
      _mapController.camera.zoom < 13 ? 13 : _mapController.camera.zoom,
    );
    _showPropertySheet(record);
  }

  void _showPropertySheet(PropertyRecord record) {
    final languageCode = ref.read(languageProvider);
    final t = (String key) => LanguageService.translate(key, languageCode);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1d1d1d),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) =>
          _PropertySheet(record: record, formatPrice: _formatPrice, t: t),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedKey = null);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(mapsFilterProvider);
    final mapsDataAsync = ref.watch(mapsDataProvider);
    final languageCode = ref.watch(languageProvider);
    final t = (String key) => LanguageService.translate(key, languageCode);

    // Re-frame the camera whenever the visible set of properties changes
    // (filter or search), so results are never off-screen.
    ref.listen<AsyncValue<PropertyMapData>>(mapsDataProvider, (prev, next) {
      final prevData = prev?.value;
      final nextData = next.value;
      if (nextData != null && !identical(prevData, nextData)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fitMarkers(nextData.records);
        });
      }
    });

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
                    onChanged: _onSearchChanged,
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          t('Could not load properties'),
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('Please check your connection and try again.'),
                          style: GoogleFonts.inter(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => ref.invalidate(mapsRawDataProvider),
                          icon: const Icon(Icons.refresh),
                          label: Text(t('Retry')),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (data) {
                  final validRecords = data.records
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
                            _mapReady = true;
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
                              final isApi =
                                  record.source == PropertySource.api;
                              final label = record.developerName.isNotEmpty
                                  ? _extractLabel(record.developerName)
                                  : _extractLabel(record.propertyName);
                              final key = _recordKey(record);
                              final selected = key == _selectedKey;
                              final border = _markerBorderColor(record);
                              final cacheKey =
                                  '${record.source.name}_${record.propertyType}_${selected ? 's' : 'n'}_$label'
                                      .toLowerCase();
                              // User's own properties stand out; catalog
                              // listings are smaller, selection is largest.
                              final size = selected
                                  ? 84.0
                                  : isApi
                                      ? 72.0
                                      : 56.0;

                              return Marker(
                                point: LatLng(
                                    record.latitude!, record.longitude!),
                                width: size,
                                height: size,
                                child: GestureDetector(
                                  onTap: () => _onMarkerTap(record, key),
                                  child: FutureBuilder<ui.Image>(
                                    future: _getOrBuildIcon(
                                        cacheKey, label, border, selected),
                                    builder: (context, snap) {
                                      if (!snap.hasData) {
                                        return Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: border,
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
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // ── Map controls ───────────────────────────────────
                      Positioned(
                        right: 10,
                        bottom: 140,
                        child: Column(
                          children: [
                            _MapButton(
                              icon: Icons.fullscreen,
                              tooltip: t('Show all properties'),
                              onTap: () => _fitMarkers(validRecords),
                            ),
                            const SizedBox(height: 10),
                            _MapButton(
                              icon: Icons.add,
                              onTap: () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _MapButton(
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
                              t('No properties match your search'),
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

// ── Property info bottom sheet ────────────────────────────────────────────
class _PropertySheet extends StatelessWidget {
  final PropertyRecord record;
  final String Function(PropertyRecord) formatPrice;
  final String Function(String) t;

  const _PropertySheet({
    required this.record,
    required this.formatPrice,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final isApi = record.source == PropertySource.api;
    final isRental = record.propertyType.toLowerCase() == 'rental';
    final price = formatPrice(record);
    final imageUrl =
        record.mapImageUrl?.replaceFirst('http://', 'https://');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.apartment,
                          color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              record.propertyName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              record.developerName,
              style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: isRental ? t('Rental') : t('Off Plan'),
                  color: isRental
                      ? const Color(0xFF6C2BD9)
                      : const Color(0xFFF7B500),
                  textColor: isRental ? Colors.white : Colors.black,
                ),
                if (isApi)
                  _Chip(
                    label: t('My Property'),
                    color: Colors.green[700]!,
                    textColor: Colors.white,
                  )
                else
                  _Chip(
                    label: t('Market Listing'),
                    color: Colors.grey[800]!,
                    textColor: Colors.white,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (record.location.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: Colors.grey[400], size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.location,
                      style: GoogleFonts.inter(
                          color: Colors.grey[300], fontSize: 14),
                    ),
                  ),
                ],
              ),
            if (price.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.sell_outlined, color: Colors.grey[400], size: 18),
                  const SizedBox(width: 6),
                  Text(
                    price,
                    style: GoogleFonts.inter(
                      color: Colors.yellow[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isApi && record.id != null) {
                    context.pushNamed('details', pathParameters: {
                      'itemId': record.id.toString(),
                    });
                  } else {
                    context.pushNamed('catalog-details', extra: record);
                  }
                },
                child: Text(
                  t('View Details'),
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _MapButton({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final button = Material(
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
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
