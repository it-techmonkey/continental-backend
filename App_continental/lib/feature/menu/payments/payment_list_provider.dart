// lib/payments_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';
import 'package:continental/services/payments_service.dart';
import 'package:intl/intl.dart';

enum PaymentType { offPlan, rental }

@immutable
class Payment {
  final int id;
  final int? occupantRecordId;
  final String name;
  final String propertyName;
  final String amount;
  final PaymentType type;
  final String paymentDate;
  final String? paymentProof;
  final String? modeOfPayment;
  final String? developerName;
  final String? updatedAt;

  const Payment({
    required this.id,
    this.occupantRecordId,
    required this.name,
    required this.propertyName,
    required this.amount,
    required this.type,
    required this.paymentDate,
    this.paymentProof,
    this.modeOfPayment,
    this.developerName,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      occupantRecordId: json['occupantRecordId'],
      name: json['name'],
      propertyName: json['propertyName'],
      amount: json['amount'],
      type: json['type'].toLowerCase() == 'rental' ? PaymentType.rental : PaymentType.offPlan,
      paymentDate: json['paymentDate'] ?? '',
      paymentProof: json['paymentProof'],
      modeOfPayment: json['modeOfPayment'],
      developerName: json['developerName'],
      updatedAt: json['updatedAt'],
    );
  }
}

// --- 2. Repository ---
class PaymentsRepository {
  final PaymentsService _paymentsService = PaymentsService();

  Future<List<Payment>> fetchPayments({String searchQuery = ''}) async {
    print("Fetching paid payments with query: '$searchQuery'...");
    
    // Fetch all payments with status 'paid'
    final allPayments = await _paymentsService.fetchPayments(status: 'paid', dedupe: false);
    
    // Convert to Payment model and format amount
    final currency = NumberFormat.currency(locale: 'en_US', symbol: 'AED ', decimalDigits: 0);
    final payments = allPayments.map((p) {
      final amount = p.emi ?? p.rent ?? 0;
      return Payment(
        id: p.id,
        occupantRecordId: p.occupantRecordId,
        name: p.name,
        propertyName: p.propertyName,
        amount: currency.format(amount),
        type: p.propertyType.toLowerCase() == 'rental' ? PaymentType.rental : PaymentType.offPlan,
        paymentDate: p.paymentDate ?? '',
        paymentProof: p.paymentProof,
        modeOfPayment: p.modeOfPayment,
        developerName: p.developerName,
        updatedAt: p.updatedAt,
      );
    }).toList();
    
    // Sort by updated_at (most recent first) - this shows when payment was marked as paid
    payments.sort((a, b) {
      // Use updated_at for sorting as it reflects when payment was marked as paid
      final dateStrA = a.updatedAt ?? a.paymentDate;
      final dateStrB = b.updatedAt ?? b.paymentDate;
      
      if (dateStrA.isEmpty) return 1;
      if (dateStrB.isEmpty) return -1;
      
      try {
        final dateA = DateTime.parse(dateStrA);
        final dateB = DateTime.parse(dateStrB);
        return dateB.compareTo(dateA); // Most recent first (descending order)
      } catch (e) {
        return 0;
      }
    });
    
    // Filter by search query if provided
    if (searchQuery.isNotEmpty) {
      return payments
          .where((payment) =>
              payment.propertyName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              payment.name
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    
    return payments;
  }
}

// --- 3. Riverpod Providers ---

// Provider for the search query state
final paymentSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider for the repository
final paymentsRepoProvider = Provider((ref) => PaymentsRepository());

// FutureProvider that fetches and filters the data
final paymentsProvider = FutureProvider<List<Payment>>((ref) {
  final searchQuery = ref.watch(paymentSearchQueryProvider);
  final repo = ref.watch(paymentsRepoProvider);
  return repo.fetchPayments(searchQuery: searchQuery);
});