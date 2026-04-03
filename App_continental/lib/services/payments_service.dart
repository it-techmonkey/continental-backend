import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:continental/config/api_config.dart';
import 'package:continental/storage/token_storage.dart';

class PaymentItemDto {
  final int id;
  final int? occupantRecordId;
  final String? paymentDate; // ISO date string when payment is due/paid
  final String propertyName;
  final String name;
  final String status; // due | paid | overdue
  final String propertyType; // Rental | OffPlan
  final num? emi;
  final num? rent;
  final String? paymentProof;
  final String? modeOfPayment;
  final String? developerName;
  final String? createdAt;
  final String? updatedAt;

  PaymentItemDto(
      {required this.id,
      this.occupantRecordId,
      this.paymentDate,
      required this.propertyName,
      required this.name,
      required this.status,
      required this.propertyType,
      this.emi,
      this.rent,
      this.paymentProof,
      this.modeOfPayment,
      this.developerName,
      this.createdAt,
      this.updatedAt});

  factory PaymentItemDto.fromJson(Map<String, dynamic> json) {
    return PaymentItemDto(
      id: (json['id'] ?? 0) as int,
      occupantRecordId: json['occupantRecordId'] as int?,
      paymentDate: json['payment_date']?.toString(),
      propertyName: json['property_name'] ?? json['propertyName'] ?? '—',
      name: json['name'] ?? '—',
      status: (json['status'] ?? '').toString(),
      propertyType: json['property_type'] ?? json['propertyType'] ?? 'Rental',
      emi: (json['emi'] is num) ? json['emi'] : num.tryParse('${json['emi']}'),
      rent: (json['rent'] is num) ? json['rent'] : num.tryParse('${json['rent']}'),
      paymentProof: json['payment_proof'],
      modeOfPayment: json['mode_of_payment'],
      developerName: json['developer_name'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class PaymentDetailDto {
  final int id;
  final String propertyName;
  final String developerName;
  final String name;
  final String status;
  final String propertyType;
  final num? emi;
  final num? rent;
  final String? imageUrl;
  final String? rentalAgreement;
  final String? offplanAgreement;
  final String? completionDate;

  PaymentDetailDto({
    required this.id,
    required this.propertyName,
    required this.developerName,
    required this.name,
    required this.status,
    required this.propertyType,
    this.emi,
    this.rent,
    this.imageUrl,
    this.rentalAgreement,
    this.offplanAgreement,
    this.completionDate,
  });

  factory PaymentDetailDto.fromJson(Map<String, dynamic> json) {
    return PaymentDetailDto(
      id: json['id'] ?? 0,
      propertyName: json['property_name'] ?? '—',
      developerName: json['developer_name'] ?? '—',
      name: json['name'] ?? '—',
      status: json['status'] ?? '—',
      propertyType: json['property_type'] ?? 'Rental',
      emi: (json['emi'] is num) ? json['emi'] : num.tryParse('${json['emi']}'),
      rent: (json['rent'] is num) ? json['rent'] : num.tryParse('${json['rent']}'),
      imageUrl: json['image_url'],
      rentalAgreement: json['rental_agreement'],
      offplanAgreement: json['offplan_agreement'],
      completionDate: json['completion_date'],
    );
  }
}

class PaymentsService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 30),
  ));
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<PaymentItemDto>> fetchPayments({String? status, String? propertyType, bool dedupe = true}) async {
    final token = await _tokenStorage.getToken();
    final headers = ApiConfig.getAuthHeaders(token);
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (propertyType != null && propertyType.isNotEmpty) query['property_type'] = propertyType;
    if (!dedupe) query['dedupe'] = 'false';
    final response = await _dio.get('/payments', queryParameters: query.isEmpty ? null : query, options: Options(headers: headers));
    if (response.statusCode == 200) {
      final data = response.data['data'];
      final list = (data['payments'] ?? data) as List;
      return list.map((e) => PaymentItemDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<PaymentDetailDto?> fetchPaymentDetail(int id) async {
    final token = await _tokenStorage.getToken();
    final headers = ApiConfig.getAuthHeaders(token);
    final response = await _dio.get('/payments/$id', options: Options(headers: headers));
    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentDetailDto.fromJson(data);
    }
    return null;
  }

  Future<List<PaymentItemDto>> fetchPaymentsByOccupant(int occupantRecordId) async {
    final token = await _tokenStorage.getToken();
    final headers = ApiConfig.getAuthHeaders(token);
    final response = await _dio.get('/occupant-records/$occupantRecordId/payments', options: Options(headers: headers));
    if (response.statusCode == 200) {
      final data = response.data['data'];
      final list = (data['payments'] ?? data) as List;
      return list.map((e) => PaymentItemDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> markPaymentAsPaid(int paymentId) async {
    debugPrint('💰 [MARK_PAID] Marking payment $paymentId as paid');
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      final response = await _dio.put(
        '/payments/$paymentId',
        data: {'status': 'paid', 'payment_date': DateTime.now().toIso8601String()},
        options: Options(headers: headers),
      );
      debugPrint('✅ [MARK_PAID] Response status: ${response.statusCode}');
      debugPrint('📦 [MARK_PAID] Response data: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ [MARK_PAID] Error: $e');
      return false;
    }
  }

  Future<bool> updatePayment(
    int paymentId, {
    required String status,
    String? paymentDate,
    String? paymentProof,
    num? amount,
    String? propertyType,
    String? modeOfPayment,
  }) async {
    debugPrint('💰 [UPDATE_PAYMENT] Updating payment $paymentId');
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      final data = <String, dynamic>{'status': status};
      if (paymentDate != null) data['payment_date'] = paymentDate;
      if (paymentProof != null) data['payment_proof'] = paymentProof;
      if (modeOfPayment != null) data['mode_of_payment'] = modeOfPayment;
      
      // Add amount as emi or rent based on property type
      if (amount != null && propertyType != null) {
        final isOffPlan = propertyType.toLowerCase() == 'offplan';
        if (isOffPlan) {
          data['emi'] = amount.toInt();
        } else {
          data['rent'] = amount.toInt();
        }
      }
      
      final response = await _dio.put(
        '/payments/$paymentId',
        data: data,
        options: Options(headers: headers),
      );
      debugPrint('✅ [UPDATE_PAYMENT] Response status: ${response.statusCode}');
      debugPrint('📦 [UPDATE_PAYMENT] Response data: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ [UPDATE_PAYMENT] Error: $e');
      return false;
    }
  }
}


