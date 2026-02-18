// lib/portfolio_screen.dart
import 'package:continental/feature/portfolio/portfolio_model.dart';
import 'package:continental/feature/portfolio/portfolio_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:continental/providers/language_provider.dart';
import 'package:continental/services/language_service.dart';
import 'portfolioPro.dart'; 




class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(portfolioStatsProvider);
    final itemsAsync = ref.watch(portfolioItemsProvider);
    final languageCode = ref.watch(languageProvider);
    final translate = (String key) => LanguageService.translate(key, languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (stats) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDashboardHeader(translate),
                    const SizedBox(height: 12),
                    _buildStatsGrid(stats: stats, translate: translate),
                    const SizedBox(height: 12),
                    _buildPortfolioHeader(context, translate),
                    const SizedBox(height: 12),
                    _buildSearchAndFilters(context, ref, translate),
                    const SizedBox(height: 12),
                    itemsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (items) {
                        final portfolioItems = items.map((item) => PortfolioItem.fromJson(item)).toList();
                        return _buildPortfolioList(items: portfolioItems, translate: translate);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Header: "Dashboard" and Logo
  Widget _buildDashboardHeader(String Function(String) translate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          translate('Dashboard'),
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SvgPicture.asset('assets/images/appLogo.svg', height: 30),
      ],
    );
  }

  // Grid of statistics cards
  Widget _buildStatsGrid({required DashboardStats stats, required String Function(String) translate}) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.0,
      children:  [
        _StatCard(title: translate('Total Properties Rented'), value: stats.totalPropertiesRented),
        _StatCard(title: translate('Rentals Due'), value: stats.rentalsDue),
        _StatCard(title: translate('Rental Amount Due'), value: stats.rentalAmountDue),
        _StatCard(title: translate('Vacant Properties'), value: stats.vacantProperties),
        _StatCard(title: translate('Total Off Plan Properties'), value: stats.totalOffPlanProperties),
        _StatCard(title: translate('Total Property Price'), value: stats.totalPropertyPrice, valueColor: Colors.greenAccent),
      ],
    );
  }

  // Header: "Portfolio" and "+ Add" button
  Widget _buildPortfolioHeader(BuildContext context, String Function(String) translate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          translate('Portfolio'),
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: () {
             context.pushNamed('add-property');
          },
          icon: const Icon(Icons.add, color: Colors.black),
          label: Text(
            translate('Add'),
            style: GoogleFonts.inter(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
      ],
    );
  }

  // Search bar and filter chips
  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref, String Function(String) translate) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final searchQuery = ref.watch(portfolioSearchQueryProvider);

    return Column(
      children: [
        TextField(
          onChanged: (query) {
            ref.read(portfolioSearchQueryProvider.notifier).state = query;
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: translate('Search For Tenants, Properties'),
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
                        ref.read(portfolioSearchQueryProvider.notifier).state = '';
                      },
                      child: Icon(Icons.close, color: Colors.grey[400], size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FilterChip(
              label: translate('All'),
              isSelected: selectedFilter == 'All',
              onTap: () => ref.read(selectedFilterProvider.notifier).state = 'All',
            ),
            _FilterChip(
              label: translate('Rental'),
              isSelected: selectedFilter == 'Rental',
              onTap: () => ref.read(selectedFilterProvider.notifier).state = 'Rental',
            ),
            _FilterChip(
              label: translate('Off Plan'),
              isSelected: selectedFilter == 'Off Plan',
              onTap: () => ref.read(selectedFilterProvider.notifier).state = 'Off Plan',
            ),
          ],
        ),
      ],
    );
  }

  // The list of portfolio items
  Widget _buildPortfolioList({required List<PortfolioItem> items, required String Function(String) translate}) {
    // In a real app, this data would come from an API
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            translate('No properties found'),
            style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _PortfolioListItem(
          id: item.id,
          propertyName: item.propertyName,
          tenantName: item.tenantName,
          pendingAmount: item.pendingAmount,
          roi: item.roi,
          status: item.status,
          translate: translate,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
                color: valueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Reusable widget for the filter chips
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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

class _PortfolioListItem extends StatelessWidget {
  final int id;
  final String propertyName;
  final String tenantName;
  final String pendingAmount;
  final String roi;
  final PortfolioStatus status;
  final String Function(String) translate;

  const _PortfolioListItem({
    required this.id,
    required this.propertyName,
    required this.tenantName,
    required this.pendingAmount,
    required this.roi,
    required this.status,
    required this.translate,
  });

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
  }

  Color _getStatusColor() {
    switch (status) {
      case PortfolioStatus.overDue:
        return Colors.redAccent; // Red for overdue
      case PortfolioStatus.completed:
        return Colors.greenAccent; // Green for paid
      case PortfolioStatus.due:
        return Colors.yellow[700]!; // Yellow for due
    }
  }

  String _getStatusText() {
    switch (status) {
      case PortfolioStatus.overDue:
        return translate('Over Due');
      case PortfolioStatus.completed:
        return translate('Paid');
      case PortfolioStatus.due:
        return translate('Due');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed('details', pathParameters: {'itemId': id.toString()});
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _capitalizeFirst(propertyName),
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: _getStatusColor()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: GoogleFonts.inter(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _InfoColumn(title: translate('Tenant Name'), value: _capitalizeFirst(tenantName))),
                      const SizedBox(width: 8),
                      Expanded(child: _InfoColumn(title: translate('Installments Due'), value: pendingAmount)),
                      if (roi.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(child: _InfoColumn(title: translate('ROI'), value: roi)),
                      ],
                    ],
                  )
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }
}

// Helper widget for the info columns in the portfolio list item
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
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}