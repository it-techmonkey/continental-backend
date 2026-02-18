// lib/actionable_repository.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'actionable_provider.dart'; // Import our models and filter provider
import 'package:continental/services/payments_service.dart';
import 'package:continental/services/occupants_service.dart';
import 'package:intl/intl.dart';

class ActionableRepository {
  final PaymentsService _paymentsService = PaymentsService();
  final OccupantsService _occupantsService = OccupantsService();

  Future<List<ActionableItem>> fetchActionableItems({required String filter, String searchQuery = ''}) async {
    // Map filter to property_type for backend
    String? propertyTypeFilter;
    if (filter == 'Rental') {
      propertyTypeFilter = 'Rental';
    } else if (filter == 'Off Plan') {
      propertyTypeFilter = 'OffPlan';
    }
    // If filter is 'All', propertyTypeFilter remains null to fetch all properties
    
    print('🔍 [FILTER] Requested filter: $filter, propertyTypeFilter: $propertyTypeFilter, searchQuery: $searchQuery');
    
    // Fetch all occupant records (properties) instead of filtering by payments
    final occupants = await _occupantsService.fetchAllOccupantRecords(propertyType: propertyTypeFilter);
    print('📊 [FILTER] Received ${occupants.length} properties');
    
    // Calculate status and pending amount for each property
    final items = await Future.wait(occupants.map((occupant) async {
      // Get all payments for this occupant
      final allOccupantPayments = await _paymentsService.fetchPaymentsByOccupant(occupant.id);
      
      // Calculate total amount for due/overdue installments (exclude paid)
      num pendingAmount = 0;
      String calculatedStatus = 'due';
      
      if (allOccupantPayments.isNotEmpty) {
        // Calculate pending amount
        pendingAmount = allOccupantPayments.fold<num>(0, (sum, p) {
          final status = p.status.toLowerCase();
          // Exclude paid payments
          if (status == 'paid') return sum;
          
          // Count all unpaid payments (due or overdue), regardless of date
          // For off-plan properties with empty payments, amount will be 0
          final amount = p.rent ?? p.emi ?? 0;
          return sum + amount;
        });
        
        // Calculate status from first unpaid payment (or first payment if all are paid)
        final unpaidPayments = allOccupantPayments.where((p) => p.status.toLowerCase() != 'paid').toList();
        if (unpaidPayments.isNotEmpty) {
          calculatedStatus = await _calculatePaymentStatus(unpaidPayments.first);
        } else {
          // All payments are paid
          calculatedStatus = 'paid';
        }
      } else {
        // No payments yet - default to 'due' for new properties
        calculatedStatus = 'due';
      }
      
      // Format amount as currency
      final currency = NumberFormat.currency(locale: 'en_US', symbol: 'AED ', decimalDigits: 0);
      
      return ActionableItem(
        id: occupant.id,
        propertyName: occupant.propertyName,
        name: occupant.name,
        installmentsPending: pendingAmount > 0 ? currency.format(pendingAmount) : 'AED 0',
        status: calculatedStatus,
        type: occupant.propertyType.toLowerCase() == 'offplan' ? ItemType.offPlan : ItemType.rental,
      );
    }));
    
    print('📊 [FILTER] Processed ${items.length} items');
    
    // Apply search filter if search query is provided
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final filteredItems = items.where((item) {
        return item.propertyName.toLowerCase().contains(query) ||
               item.name.toLowerCase().contains(query);
      }).toList();
      print('🔍 [SEARCH] After search filter: ${filteredItems.length} items');
      return filteredItems;
    }
    
    return items;
  }

  /// Calculate payment status based on user's logic:
  /// - If paid → "paid" (green)
  /// - If current month passed AND previous months unpaid → "overdue" (red)
  /// - If current month passed but previous months paid → "due" (yellow)
  Future<String> _calculatePaymentStatus(PaymentItemDto payment) async {
    // If already paid, return paid
    if (payment.status.toLowerCase() == 'paid') {
      return 'paid';
    }

    // If already overdue, return overdue
    if (payment.status.toLowerCase() == 'overdue') {
      return 'overdue';
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
        return hasPreviousUnpaid ? 'overdue' : 'due';
      } catch (e) {
        print('[ACTIONABLE] Error calculating status: $e');
        return 'due'; // Default to due on error
      }
    }

    // Default to due
    return 'due';
  }

  // Dummy data removed; using real API

  Future<CustomerDetails> fetchItemDetails({required String itemId}) async {
    final id = int.tryParse(itemId) ?? 0;
    final dto = await _occupantsService.fetchOccupantDetail(id);
    if (dto == null) {
      throw Exception('Failed to load occupant details');
    }
    final pending = dto.emi ?? dto.rent ?? 0;
    final isRental = dto.propertyType.toLowerCase() == 'rental';
    print('📊 [DETAILS] Property: ${dto.propertyName}');
    print('📊 [DETAILS] Locality: ${dto.locality}');
    print('📊 [DETAILS] Home Type: ${dto.homeType}');
    print('📊 [DETAILS] Property Type: ${dto.propertyType}');
    print('📊 [DETAILS] Price: ${dto.price}');
    print('📊 [DETAILS] DLD: ${dto.dld}');
    print('📊 [DETAILS] QUOOD: ${dto.quood}');
    print('📊 [DETAILS] Other Charges: ${dto.otherCharges}');
    print('📊 [DETAILS] Penalties: ${dto.penalties}');
    return CustomerDetails(
      propertyName: dto.propertyName,
      developerName: 'By ${dto.developerName}',
      imageUrl: dto.imageUrl ?? 'https://picsum.photos/800/400',
      tenantName: dto.name,
      phone: dto.phone, // Added phone to CustomerDetails
      installmentsPending: pending.toString(),
      propertyType: isRental ? 'Rental' : 'Off Plan',
      locality: dto.locality,
      homeType: dto.homeType,
      totalPrice: dto.price,
      status: '—',
      amountPaid: '—',
      amountPending: 'AED $pending',
      pdfFileName: isRental ? 'Rental Agreement' : 'Offplan Agreement',
      pdfFileSize: '',
      agreementValidity: dto.completionDate != null ? 'Completion ${dto.completionDate}' : '',
      rentalAgreement: dto.rentalAgreement,
      offplanAgreement: dto.offplanAgreement,
      dld: dto.dld,
      quood: dto.quood,
      otherCharges: dto.otherCharges,
      penalties: dto.penalties,
    );
  }
  
  // Removed dummy fallback

}

// --- Riverpod Providers ---
final actionableRepoProvider = Provider((ref) => ActionableRepository());

final actionableDataProvider = FutureProvider<List<ActionableItem>>((ref) {
  final filter = ref.watch(actionableFilterProvider);
  final searchQuery = ref.watch(actionableSearchQueryProvider);
  final repo = ref.watch(actionableRepoProvider);
  return repo.fetchActionableItems(filter: filter, searchQuery: searchQuery);
});
// Payments timeline for an occupant
final occupantPaymentsProvider = FutureProvider.family<List<PaymentItemDto>, int>((ref, occupantId) {
  final svc = PaymentsService();
  return svc.fetchPaymentsByOccupant(occupantId);
});


// lib/actionable_repository.dart
// ... existing imports and code

// --- NEW DATA MODEL ---
@immutable
class CustomerDetails {
  final String propertyName;
  final String developerName;
  final String imageUrl;
  final String tenantName;
  final String phone; // Added phone field
  final String installmentsPending;
  final String propertyType;
  final String? locality;
  final String? homeType;
  final num? totalPrice;
  final String status;
  final String amountPaid;
  final String amountPending;
  final String pdfFileName;
  final String pdfFileSize;
  final String agreementValidity;
  final String? rentalAgreement;
  final String? offplanAgreement;
  final int? dld;
  final int? quood;
  final int? otherCharges;
  final int? penalties;

  const CustomerDetails({
    required this.propertyName, required this.developerName, required this.imageUrl,
    required this.tenantName, required this.phone, required this.installmentsPending, required this.propertyType,
    this.locality, this.homeType, this.totalPrice, required this.status, required this.amountPaid, required this.amountPending,
    required this.pdfFileName, required this.pdfFileSize, required this.agreementValidity,
    this.rentalAgreement, this.offplanAgreement,
    this.dld, this.quood, this.otherCharges, this.penalties,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      propertyName: json['propertyName'], developerName: json['developerName'],
      imageUrl: json['imageUrl'], tenantName: json['tenantName'],
      phone: json['phone'] ?? '', // Added phone parsing
      installmentsPending: json['installmentsPending'], propertyType: json['propertyType'],
      locality: json['locality'], homeType: json['homeType'], totalPrice: json['totalPrice'], status: json['status'], amountPaid: json['amountPaid'],
      amountPending: json['amountPending'], pdfFileName: json['pdfFileName'],
      pdfFileSize: json['pdfFileSize'], agreementValidity: json['agreementValidity'],
      rentalAgreement: json['rentalAgreement'],
      offplanAgreement: json['offplanAgreement'],
      dld: json['dld'],
      quood: json['quood'],
      otherCharges: json['otherCharges'],
      penalties: json['penalties'],
    );
  }
}


final customerDetailsProvider = FutureProvider.family<CustomerDetails, String>((ref, itemId) {
  final repo = ref.watch(actionableRepoProvider);
  return repo.fetchItemDetails(itemId: itemId);
});