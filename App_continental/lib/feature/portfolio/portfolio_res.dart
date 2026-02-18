// lib/portfolio_repository.dart
import 'package:continental/feature/portfolio/portfolioPro.dart';
import 'package:dio/dio.dart';
import 'package:continental/config/api_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:continental/storage/token_storage.dart';
import 'portfolio_model.dart';
import 'package:continental/services/payments_service.dart';

class PortfolioRepository {
  final Dio _dio = Dio();
  final TokenStorage _tokenStorage = TokenStorage();
  final PaymentsService _paymentsService = PaymentsService();

  // Fetch dashboard stats (this doesn't depend on filters)
  Future<DashboardStats> fetchStats() async {
    try {
      final url = '${ApiConfig.baseUrl}/occupant-records/dashboard';
      print('[PORTFOLIO] Fetching stats: GET ' + url);
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      print('[PORTFOLIO] Status: ${response.statusCode}');
      if (response.data != null) {
        print('[PORTFOLIO] Response: ${response.data}');
      }
      Map<String, dynamic> statsJson = {};
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        statsJson = {
          'totalPropertiesRented': (data['total_properties_rented'] ?? 0).toString(),
          'rentalsDue': (data['rentals_due'] ?? 0).toString(),
          'rentalAmountDue': 'AED ${_formatAmount(data['rental_amount_due'])}',
          'vacantProperties': (data['vacant_properties'] ?? 0).toString(),
          'totalOffPlanProperties': (data['total_off_plan_properties'] ?? 0).toString(),
          'totalPropertyPrice': 'AED ${_formatAmount(data['total_property_price'])}',
        };
      }
      return DashboardStats.fromJson(statsJson);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch portfolio items (this depends on filter and search)
  Future<List<Map<String, dynamic>>> fetchPortfolioItems({required String filter, String searchQuery = ''}) async {
    try {
      // Fetch payments to collect: due + overdue (deduped per occupant by backend)
      final overdue = await _paymentsService.fetchPayments(status: 'overdue');
      final due = await _paymentsService.fetchPayments(status: 'due');
      final payments = [...overdue, ...due];
      final filtered = payments.where((p) {
        if (filter == 'Rental') return p.propertyType.toLowerCase() == 'rental';
        if (filter == 'Off Plan') return p.propertyType.toLowerCase() == 'offplan';
        return true;
      }).toList();

      // Group by occupant first
      final Map<int, List<PaymentItemDto>> groupedPayments = {};
      for (var p in filtered) {
        final id = p.occupantRecordId ?? p.id;
        if (!groupedPayments.containsKey(id)) {
          groupedPayments[id] = [];
        }
        groupedPayments[id]!.add(p);
      }

      // Calculate correct status and count for each unique occupant
      final items = await Future.wait(groupedPayments.entries.map((entry) async {
        final firstPayment = entry.value.first;
        final calculatedStatus = await _calculatePaymentStatus(firstPayment);
        
        // Get all payments for this occupant
        final allOccupantPayments = await _paymentsService.fetchPaymentsByOccupant(entry.key);
        
        // Count ONLY due/overdue installments (exclude paid and upcoming months)
        final now = DateTime.now();
        final currentYear = now.year;
        final currentMonth = now.month;
        
        final pendingCount = allOccupantPayments.where((p) {
          final status = p.status.toLowerCase();
          // Exclude paid payments
          if (status == 'paid') return false;
          
          // Only count payments that are due now or overdue (current month or earlier)
          if (p.paymentDate != null) {
            try {
              final paymentDate = DateTime.parse(p.paymentDate!).toLocal();
              // Include if payment date is current month or earlier
              return paymentDate.year < currentYear || 
                     (paymentDate.year == currentYear && paymentDate.month <= currentMonth);
            } catch (e) {
              return false;
            }
          }
          return false;
        }).length;
        
        return {
          'id': entry.key, // Use occupantRecordId for navigation
          'propertyName': firstPayment.propertyName,
          'tenantName': firstPayment.name,
          'pendingAmount': pendingCount.toString(), // Count instead of amount
          'roi': '',
          'status': calculatedStatus,
        };
      }));

      // Filter out items with no pending installments (count is 0)
      final itemsWithPending = items.where((item) {
        return item['pendingAmount'] != '0';
      }).toList();

      // Apply search filter if search query is provided
      final filteredItems = searchQuery.isNotEmpty
          ? itemsWithPending.where((item) {
              final query = searchQuery.toLowerCase();
              return item['propertyName'].toString().toLowerCase().contains(query) ||
                     item['tenantName'].toString().toLowerCase().contains(query);
            }).toList()
          : itemsWithPending;

      return filteredItems;
    } catch (e) {
      rethrow;
    }
  }

  String _formatAmount(dynamic value) {
    if (value == null) return '0';
    final num amount = (value is num) ? value : num.tryParse(value.toString()) ?? 0;
    if (amount.abs() >= 1000000) {
      final millions = amount / 1000000;
      // 1 decimal place, strip trailing .0
      final str = millions.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '$str M';
    }
    final formatter = NumberFormat('#,##0');
    return formatter.format(amount);
  }

  /// Calculate payment status based on user's logic:
  /// - If paid → "completed" (green)
  /// - If current month passed AND previous months unpaid → "overDue" (red)
  /// - If current month passed but previous months paid → "due" (yellow)
  Future<String> _calculatePaymentStatus(PaymentItemDto payment) async {
    // If already paid, return completed
    if (payment.status.toLowerCase() == 'paid') {
      return 'completed';
    }

    // If already overdue, return overdue
    if (payment.status.toLowerCase() == 'overdue') {
      return 'overDue';
    }

    // If status is "due", check previous months
    if (payment.status.toLowerCase() == 'due' && payment.occupantRecordId != null) {
      try {
        // Fetch all payments for this occupant
        final allPayments = await _paymentsService.fetchPaymentsByOccupant(payment.occupantRecordId!);
        
        if (allPayments.isEmpty) return 'due';

        final now = DateTime.now();
        final currentYear = now.year;
        final currentMonth = now.month;

        // Parse current payment date (convert from UTC to local)
        DateTime? currentPaymentDate;
        if (payment.paymentDate != null) {
          try {
            currentPaymentDate = DateTime.parse(payment.paymentDate!).toLocal();
          } catch (e) {
            // If date parsing fails, default to due
            return 'due';
          }
        }

        // Check if current month payment date has passed
        bool currentMonthPassed = false;
        if (currentPaymentDate != null) {
          currentMonthPassed = currentPaymentDate.isBefore(now) || 
                              (currentPaymentDate.year == currentYear && currentPaymentDate.month < currentMonth);
        }

        if (!currentMonthPassed) {
          return 'due'; // Current month hasn't passed yet
        }

        // Check if there are any unpaid payments before current month
        bool hasPreviousUnpaid = false;
        for (var p in allPayments) {
          if (p.id == payment.id) continue; // Skip current payment
          
          final status = p.status.toLowerCase();
          if (status != 'paid') {
            // Check if this payment is before current month (convert from UTC to local)
            if (p.paymentDate != null) {
              try {
                final pDate = DateTime.parse(p.paymentDate!).toLocal();
                if (pDate.year < currentYear || 
                    (pDate.year == currentYear && pDate.month < currentMonth)) {
                  hasPreviousUnpaid = true;
                  break;
                }
              } catch (e) {
                // Skip if date parsing fails
              }
            }
          }
        }

        // If previous months have unpaid payments → overdue
        // Otherwise → due (only current month)
        return hasPreviousUnpaid ? 'overDue' : 'due';
      } catch (e) {
        print('[PORTFOLIO] Error calculating status for payment ${payment.id} (occupant ${payment.occupantRecordId}): $e');
        if (e is DioException) {
             print('[PORTFOLIO] Request URL: ${e.requestOptions.path}');
             print('[PORTFOLIO] Response Data: ${e.response?.data}');
             print('[PORTFOLIO] Response Headers: ${e.response?.headers}');
        }
        return 'due'; // Default to due on error
      }
    }

    // Default to due
    return 'due';
  }

}

// Provider for the Repository itself (no change)
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository();
});


// Separate provider for stats (loads once)
final portfolioStatsProvider = FutureProvider<DashboardStats>((ref) {
  final portfolioRepository = ref.watch(portfolioRepositoryProvider);
  return portfolioRepository.fetchStats();
});

// Separate provider for portfolio items (reloads on filter/search change)
final portfolioItemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final selectedFilter = ref.watch(selectedFilterProvider);
  final searchQuery = ref.watch(portfolioSearchQueryProvider);
  final portfolioRepository = ref.watch(portfolioRepositoryProvider);
  return portfolioRepository.fetchPortfolioItems(filter: selectedFilter, searchQuery: searchQuery);
});