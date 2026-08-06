// lib/portfolio_repository.dart
import 'package:continental/feature/portfolio/portfolioPro.dart';
import 'package:flutter/foundation.dart';
import 'package:continental/config/api_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'portfolio_model.dart';
import 'package:continental/services/payments_service.dart';
import 'package:continental/services/occupants_service.dart';
import 'package:continental/services/dio_service.dart';

class PortfolioRepository {
  final PaymentsService _paymentsService;
  final OccupantsService _occupantsService;

  PortfolioRepository(this._paymentsService, this._occupantsService);

  // Fetch dashboard stats (this doesn't depend on filters)
  Future<DashboardStats> fetchStats() async {
    try {
      debugPrint('[PORTFOLIO] Fetching stats...');
      final data = await _occupantsService.fetchDashboardStats();
      debugPrint('[PORTFOLIO] Stats response: $data');
      Map<String, dynamic> statsJson = {};
      if (data != null) {
        statsJson = {
          'totalPropertiesRented': (data['total_properties_rented'] ?? 0)
              .toString(),
          'rentalsDue': (data['rentals_due'] ?? 0).toString(),
          'rentalAmountDue': 'AED ${_formatAmount(data['rental_amount_due'])}',
          'vacantProperties': (data['vacant_properties'] ?? 0).toString(),
          'totalOffPlanProperties': (data['total_off_plan_properties'] ?? 0)
              .toString(),
          'totalPropertyPrice':
              'AED ${_formatAmount(data['total_property_price'])}',
        };
      }
      return DashboardStats.fromJson(statsJson);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch portfolio items — shows ALL stored properties from the database
  Future<List<Map<String, dynamic>>> fetchPortfolioItems({
    required String filter,
    String searchQuery = '',
  }) async {
    try {
      // Fetch all occupant records from the database
      String? apiFilter;
      if (filter == 'Rental') apiFilter = 'Rental';
      if (filter == 'Off Plan') apiFilter = 'OffPlan';

      final allRecords = await _occupantsService.fetchAllOccupantRecords(
        propertyType: apiFilter,
      );

      // For each property, fetch its payments and calculate status
      final items = await Future.wait(
        allRecords.map((record) async {
          final allPayments = await _paymentsService.fetchPaymentsByOccupant(
            record.id,
          );

          final now = DateTime.now();
          final currentYear = now.year;
          final currentMonth = now.month;

          // Count pending installments (due/overdue, current month or earlier)
          int pendingCount = 0;
          for (var p in allPayments) {
            final status = p.status.toLowerCase();
            if (status == 'paid') continue;

            if (p.paymentDate == null) {
              pendingCount++;
              continue;
            }

            try {
              final paymentDate = DateTime.parse(p.paymentDate!).toLocal();
              if (paymentDate.year < currentYear ||
                  (paymentDate.year == currentYear &&
                      paymentDate.month <= currentMonth)) {
                pendingCount++;
              }
            } catch (e) {
              pendingCount++;
            }
          }

          // Calculate overall property status
          String status;
          if (allPayments.isEmpty) {
            status = 'due'; // New property with no payments yet
          } else {
            final hasOverdue = allPayments.any(
              (p) => p.status.toLowerCase() == 'overdue',
            );
            final allPaid = allPayments.every(
              (p) => p.status.toLowerCase() == 'paid',
            );
            if (hasOverdue) {
              status = 'overDue';
            } else if (allPaid) {
              status = 'completed';
            } else {
              status = 'due';
            }
          }

          return {
            'id': record.id,
            'propertyName': record.propertyName,
            'tenantName': record.name,
            'pendingAmount': pendingCount.toString(),
            'roi': '',
            'status': status,
          };
        }),
      );

      // Apply search filter if search query is provided
      final List<Map<String, dynamic>> typedItems = items
          .cast<Map<String, dynamic>>();
      List<Map<String, dynamic>> filteredItems = searchQuery.isNotEmpty
          ? typedItems.where((item) {
              final query = searchQuery.toLowerCase();
              return item['propertyName'].toString().toLowerCase().contains(
                    query,
                  ) ||
                  item['tenantName'].toString().toLowerCase().contains(query);
            }).toList()
          : typedItems;

      return filteredItems;
    } catch (e) {
      rethrow;
    }
  }

  String _formatAmount(dynamic value) {
    if (value == null) return '0';
    final num amount = (value is num)
        ? value
        : num.tryParse(value.toString()) ?? 0;
    if (amount.abs() >= 1000000) {
      final millions = amount / 1000000;
      // 1 decimal place, strip trailing .0
      final str = millions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '$str M';
    }
    final formatter = NumberFormat('#,##0');
    return formatter.format(amount);
  }
}

// Provider for the Repository itself
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final paymentsService = ref.read(paymentsServiceProvider);
  final occupantsService = ref.read(occupantsServiceProvider);
  return PortfolioRepository(paymentsService, occupantsService);
});

// Separate provider for stats (loads once)
final portfolioStatsProvider = FutureProvider<DashboardStats>((ref) {
  final portfolioRepository = ref.watch(portfolioRepositoryProvider);
  return portfolioRepository.fetchStats();
});

// Separate provider for portfolio items (reloads on filter/search change)
final portfolioItemsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final selectedFilter = ref.watch(selectedFilterProvider);
  final searchQuery = ref.watch(portfolioSearchQueryProvider);
  final portfolioRepository = ref.watch(portfolioRepositoryProvider);
  return portfolioRepository.fetchPortfolioItems(
    filter: selectedFilter,
    searchQuery: searchQuery,
  );
});
