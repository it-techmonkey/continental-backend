// lib/payment_details_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:continental/services/payments_service.dart';
import 'package:intl/intl.dart';

// --- 1. Data Model ---
@immutable
class PaymentDetails {
  final String propertyName;
  final String developerName;
  final String propertyType;
  final String installmentNumber;
  final String installmentAmount;
  final String installmentDate;
  final String paidDate;
  final String modeOfPayment;
  final String paymentProofFile;
  final String paymentProofSize;
  final String? paymentProofUrl; // Full URL for editing
  final String agreementValidity;
  final String status;
  final int paymentId;
  final int occupantRecordId;
  final num amount;

  const PaymentDetails({
    required this.propertyName,
    required this.developerName,
    required this.propertyType,
    required this.installmentNumber,
    required this.installmentAmount,
    required this.installmentDate,
    required this.paidDate,
    required this.modeOfPayment,
    required this.paymentProofFile,
    required this.paymentProofSize,
    this.paymentProofUrl,
    required this.agreementValidity,
    required this.status,
    required this.paymentId,
    required this.occupantRecordId,
    required this.amount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      propertyName: json['propertyName'],
      developerName: json['developerName'],
      propertyType: json['propertyType'],
      installmentNumber: json['installmentNumber'],
      installmentAmount: json['installmentAmount'],
      installmentDate: json['installmentDate'],
      paidDate: json['paidDate'],
      modeOfPayment: json['modeOfPayment'],
      paymentProofFile: json['paymentProofFile'],
      paymentProofSize: json['paymentProofSize'],
      paymentProofUrl: json['paymentProofUrl'],
      agreementValidity: json['agreementValidity'],
      status: json['status'] ?? 'due',
      paymentId: json['paymentId'] ?? 0,
      occupantRecordId: json['occupantRecordId'] ?? 0,
      amount: json['amount'] ?? 0,
    );
  }
}

// --- 2. Repository ---
class PaymentDetailsRepository {
  final PaymentsService _paymentsService = PaymentsService();

  Future<PaymentDetails> fetchPaymentDetails({required String paymentId}) async {
    print("Fetching details for payment ID: '$paymentId'...");
    
    final id = int.tryParse(paymentId) ?? 0;
    if (id == 0) {
      throw Exception('Invalid payment ID');
    }
    
    // Fetch all payments for this occupant to calculate installment number
    final allPayments = await _paymentsService.fetchPayments(dedupe: false);
    
    // Find the specific payment
    final payment = allPayments.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Payment not found'),
    );
    
    if (payment.occupantRecordId == null) {
      throw Exception('Missing occupant record ID');
    }
    
    // Fetch all payments for this occupant, sorted by due date
    final occupantPayments = allPayments
        .where((p) => p.occupantRecordId == payment.occupantRecordId)
        .toList();
    
    // Sort by payment_date to get the correct order
    occupantPayments.sort((a, b) {
      if (a.paymentDate == null) return 1;
      if (b.paymentDate == null) return -1;
      try {
        final dateA = DateTime.parse(a.paymentDate!);
        final dateB = DateTime.parse(b.paymentDate!);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });
    
    // Find the installment number (1-based index)
    final installmentNumber = occupantPayments.indexOf(payment) + 1;
    
    // Format dates
    final currency = NumberFormat.currency(locale: 'en_US', symbol: 'AED ', decimalDigits: 0);
    final amount = payment.emi ?? payment.rent ?? 0;
    
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '—';
      try {
        final date = DateTime.parse(dateStr);
        // Convert UTC to local time for proper display
        final localDate = date.toLocal();
        return '${localDate.day}/${localDate.month}/${localDate.year.toString().substring(2)}';
      } catch (e) {
        return dateStr;
      }
    }
    
    // Get payment proof filename and full URL
    String paymentProofFile = 'No proof uploaded';
    String paymentProofSize = '—';
    String? paymentProofUrl; // Store full URL for editing
    if (payment.paymentProof != null && payment.paymentProof!.isNotEmpty) {
      paymentProofUrl = payment.paymentProof; // Store full URL
      final urlParts = payment.paymentProof!.split('/');
      paymentProofFile = urlParts.last;
      paymentProofSize = '2.5 MB'; // Default size, backend doesn't provide this
    }
    
    // Get agreement validity (for now, default text)
    final agreementValidity = payment.propertyType.toLowerCase() == 'rental'
        ? 'Agreement Valid till 20th Oct 2027'
        : 'Completion: 20th Oct 2027';
    
    return PaymentDetails(
      propertyName: payment.propertyName,
      developerName: payment.developerName ?? 'By Unknown',
      propertyType: payment.propertyType,
      installmentNumber: installmentNumber.toString(),
      installmentAmount: currency.format(amount),
      installmentDate: formatDate(payment.paymentDate),
      paidDate: formatDate(payment.paymentDate),
      modeOfPayment: payment.modeOfPayment ?? '—',
      paymentProofFile: paymentProofFile,
      paymentProofSize: paymentProofSize,
      paymentProofUrl: paymentProofUrl, // Include full URL
      agreementValidity: agreementValidity,
      status: payment.status,
      paymentId: payment.id,
      occupantRecordId: payment.occupantRecordId!,
      amount: amount,
    );
  }
}

// --- 3. Riverpod Providers ---
final paymentDetailsRepoProvider = Provider((ref) => PaymentDetailsRepository());

final paymentDetailsProvider = FutureProvider.family<PaymentDetails, String>((ref, paymentId) {
  final repo = ref.watch(paymentDetailsRepoProvider);
  return repo.fetchPaymentDetails(paymentId: paymentId);
});