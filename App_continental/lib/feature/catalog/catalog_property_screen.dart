import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/property_map_model.dart';
import '../../providers/language_provider.dart';
import '../../services/language_service.dart';

/// Read-only detail page for market listings bundled in the offline catalog.
/// These properties do not exist in the backend, so everything shown here is
/// rendered from the catalog JSON carried on the [PropertyRecord].
class CatalogPropertyScreen extends ConsumerWidget {
  final PropertyRecord record;

  const CatalogPropertyScreen({super.key, required this.record});

  Map<String, dynamic> get _item => record.properties ?? const {};

  List<String> get _photoUrls {
    final urls = <String>[];
    final cover = _item['cover'];
    if (cover is Map && cover['src'] is String) {
      urls.add(cover['src'] as String);
    }
    final photos = _item['photos'];
    if (photos is List) {
      for (final p in photos) {
        if (p is Map && p['src'] is String) {
          urls.add(p['src'] as String);
        }
      }
    }
    return urls
        .map((u) => u.replaceFirst('http://', 'https://'))
        .toSet()
        .toList();
  }

  Map<String, dynamic>? get _totals {
    final stats = _item['statistics'];
    if (stats is Map && stats['total'] is Map) {
      return (stats['total'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  Map<String, dynamic>? get _units {
    final stats = _item['statistics'];
    if (stats is Map && stats['units'] is Map) {
      return (stats['units'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  String _unitTypeLabel(String code, String Function(String) t) {
    final n = int.tryParse(code);
    if (n == null) return code;
    final bedrooms = n - 110;
    if (bedrooms <= 0) return t('Studio');
    return '$bedrooms ${t(bedrooms == 1 ? 'Bedroom' : 'Bedrooms')}';
  }

  String _formatCompact(num? value) {
    if (value == null) return '—';
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: 'AED ',
      decimalDigits: 1,
    ).format(value);
  }

  String? _completionDate() {
    final raw = _item['construction_inspection_date']?.toString();
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateFormat('MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(languageProvider);
    final t = (String key) => LanguageService.translate(key, languageCode);

    final photos = _photoUrls;
    final totals = _totals;
    final units = _units;
    final completion = _completionDate();
    final constructionPercent =
        num.tryParse('${_item['construction_percent']}');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          record.propertyName,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photos.isNotEmpty) _PhotoCarousel(urls: photos),
            const SizedBox(height: 16),
            Text(
              record.propertyName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${t('By')} ${record.developerName}',
              style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  label: t('Off Plan'),
                  color: const Color(0xFFF7B500),
                  textColor: Colors.black,
                ),
                _Badge(
                  label: t('Market Listing'),
                  color: Colors.grey[800]!,
                  textColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 20),

            // ── Price range ────────────────────────────────────────────
            if (record.priceFrom != null || record.priceTo != null)
              _InfoCard(
                title: t('Price Range'),
                child: Text(
                  '${_formatCompact(record.priceFrom)} – ${_formatCompact(record.priceTo)}',
                  style: GoogleFonts.inter(
                    color: Colors.yellow[600],
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // ── Construction progress ──────────────────────────────────
            if (constructionPercent != null || completion != null)
              _InfoCard(
                title: t('Construction'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (constructionPercent != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (constructionPercent / 100)
                                    .clamp(0.0, 1.0)
                                    .toDouble(),
                                minHeight: 8,
                                backgroundColor: Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.yellow[700]!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${constructionPercent.toStringAsFixed(0)}%',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (completion != null)
                      Text(
                        '${t('Estimated completion')}: $completion',
                        style: GoogleFonts.inter(
                            color: Colors.grey[300], fontSize: 13),
                      ),
                  ],
                ),
              ),

            // ── Project totals ─────────────────────────────────────────
            if (totals != null)
              _InfoCard(
                title: t('Project Overview'),
                child: Column(
                  children: [
                    if (totals['units_count'] != null)
                      _DetailRow(
                          label: t('Total Units'),
                          value: '${totals['units_count']}'),
                    if (totals['count'] != null)
                      _DetailRow(
                          label: t('Available Units'),
                          value: '${totals['count']}'),
                    if (totals['units_max_floor'] != null)
                      _DetailRow(
                          label: t('Floors'),
                          value: '${totals['units_max_floor']}'),
                    if (totals['price_m2_from'] is num)
                      _DetailRow(
                        label: t('Price per m²'),
                        value:
                            '${_formatCompact(totals['price_m2_from'] as num)} – ${_formatCompact(totals['price_m2_to'] is num ? totals['price_m2_to'] as num : null)}',
                      ),
                  ],
                ),
              ),

            // ── Unit types ─────────────────────────────────────────────
            if (units != null && units.isNotEmpty)
              _InfoCard(
                title: t('Available Unit Types'),
                child: Column(
                  children: (units.entries.toList()
                        ..sort((a, b) => a.key.compareTo(b.key)))
                      .map((entry) {
                    final u = entry.value;
                    if (u is! Map) return const SizedBox.shrink();
                    final priceFrom =
                        u['price_from'] is num ? u['price_from'] as num : null;
                    final areaFrom = u['area_from'];
                    final areaTo = u['area_to'];
                    final area = (areaFrom is num && areaTo is num)
                        ? '${areaFrom.toStringAsFixed(0)}–${areaTo.toStringAsFixed(0)} m²'
                        : null;
                    return _DetailRow(
                      label: _unitTypeLabel(entry.key, t),
                      value: [
                        if (area != null) area,
                        if (priceFrom != null)
                          '${t('from')} ${_formatCompact(priceFrom)}',
                      ].join(' · '),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  final List<String> urls;

  const _PhotoCarousel({required this.urls});

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                widget.urls[i],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child:
                        Icon(Icons.apartment, color: Colors.grey, size: 48),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.urls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.urls.length,
              (i) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? Colors.yellow[700] : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1d),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
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
