import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:continental/providers/language_provider.dart';
import 'package:continental/services/language_service.dart';
import 'actionable_provider.dart';
import 'actionable_repository.dart';

class ActionableScreen extends ConsumerStatefulWidget {
  const ActionableScreen({super.key});

  @override
  ConsumerState<ActionableScreen> createState() => _ActionableScreenState();
}

class _ActionableScreenState extends ConsumerState<ActionableScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when screen is displayed (in case returning from details page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(actionableDataProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionableDataAsync = ref.watch(actionableDataProvider);
    final languageCode = ref.watch(languageProvider);
    String t(String key) => LanguageService.translate(key, languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          t('Properties'),
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context, ref, t),
          Expanded(
            child: actionableDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              data: (items) => ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _ActionableListItem(item: items[index], translate: t);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref, String Function(String) t) {
    final selectedFilter = ref.watch(actionableFilterProvider);
    final searchQuery = ref.watch(actionableSearchQueryProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (query) {
              ref.read(actionableSearchQueryProvider.notifier).state = query;
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: t('Search For Tenants, Properties'),
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[900],
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        searchQuery,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ref.read(actionableSearchQueryProvider.notifier).state = '';
                        },
                        child: Icon(Icons.close, color: Colors.grey[400], size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _FilterChip(
              label: t('All'),
              isSelected: selectedFilter == 'All',
              onTap: () => ref.read(actionableFilterProvider.notifier).state = 'All',
            ),
            _FilterChip(
              label: t('Rental'),
              isSelected: selectedFilter == 'Rental',
              onTap: () => ref.read(actionableFilterProvider.notifier).state = 'Rental',
            ),
            _FilterChip(
              label: t('Off Plan'),
              isSelected: selectedFilter == 'Off Plan',
              onTap: () => ref.read(actionableFilterProvider.notifier).state = 'Off Plan',
            ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow[700] : Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// The new List Item Widget for this screen
class _ActionableListItem extends StatelessWidget {
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
  }
  final ActionableItem item;
  final String Function(String) translate;
  const _ActionableListItem({required this.item, required this.translate});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.greenAccent; // Green for paid
      case 'overdue':
        return Colors.redAccent; // Red for overdue
      case 'due':
      default:
        return Colors.yellow[700]!; // Yellow for due
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return translate('Paid');
      case 'overdue':
        return translate('Over Due');
      case 'due':
      default:
        return translate('Due');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        context.goNamed('details', pathParameters: {'itemId': item.id.toString()});
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _capitalizeFirst(item.propertyName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.type == ItemType.rental ? translate('Rental') : translate('Off Plan'),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _InfoColumn(title: translate('Name'), value: _capitalizeFirst(item.name)),
                const Spacer(),
                _InfoColumn(title: translate('Amount Due'), value: item.installmentsPending),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: _getStatusColor(item.status)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(item.status),
                        style: GoogleFonts.inter(
                            color: _getStatusColor(item.status), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[800], height: 1),
          ],
        ),
      ),
    );
  }
}

// Helper widget for info columns
class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}