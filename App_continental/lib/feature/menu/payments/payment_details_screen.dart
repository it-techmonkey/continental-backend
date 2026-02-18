// lib/payment_details_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For the PDF icon
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import 'payment_details_provider.dart';
import '../../../storage/token_storage.dart';
import '../../../config/api_config.dart';

class PaymentDetailsScreen extends ConsumerWidget {
  final String paymentId;
  const PaymentDetailsScreen({super.key, required this.paymentId});

  // Helper method to open PDF files on Android/iOS
  Future<void> _openPdfFile(BuildContext context, String pdfUrl) async {
    try {
      // Ensure URL is absolute
      final uri = Uri.parse(pdfUrl);
      final isAbsolute = uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
      final fullUrl = isAbsolute ? pdfUrl : '${ApiConfig.baseUrl.replaceAll('/api', '')}$pdfUrl';

      // First, try to open directly with url_launcher (works for public S3 URLs)
      final directUri = Uri.parse(fullUrl);
      if (await canLaunchUrl(directUri)) {
        // Try to open directly first
        try {
          await launchUrl(directUri, mode: LaunchMode.externalApplication);
          return; // Successfully opened
        } catch (e) {
          // If direct open fails, proceed to download
          print('Direct open failed, trying download: $e');
        }
      }

      // For Android and iOS, download and open the file locally
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Show loading indicator
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading file...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final fileName = fullUrl.split('/').last.split('?').first;
        // Ensure filename has .pdf extension if missing
        final safeFileName = fileName.endsWith('.pdf') || fileName.contains('.') 
            ? fileName 
            : '$fileName.pdf';
        final filePath = '${tempDir.path}/$safeFileName';

        // Download file using Dio with proper configuration
        final dio = Dio();
        final tokenStorage = TokenStorage();
        final token = await tokenStorage.getToken();
        
        // Configure Dio options
        dio.options.followRedirects = true;
        dio.options.maxRedirects = 5;
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 30);
        
        // Add authorization header if token exists and URL is not S3 (S3 URLs are usually public)
        if (token != null && token.isNotEmpty && !fullUrl.contains('s3.amazonaws.com') && !fullUrl.contains('s3.')) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }

        // Download the file
        await dio.download(fullUrl, filePath);

        // Open the downloaded file
        final result = await OpenFilex.open(filePath);
        
        if (context.mounted) {
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to open file: ${result.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // For web, use url_launcher
        if (await canLaunchUrl(directUri)) {
          await launchUrl(directUri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open file'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(paymentDetailsProvider(paymentId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Payment Details', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (details) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(details),
            const SizedBox(height: 32),
            _buildDetailsGrid(details),
            const SizedBox(height: 32),
            _buildPaymentProofSection(context, details),
            const SizedBox(height: 32),
            _buildEditPaymentButton(context, details),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PaymentDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(details.propertyName, style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(details.developerName, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16)),
      ],
    );
  }

  Widget _buildDetailsGrid(PaymentDetails details) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoColumn(title: 'Property Type', value: details.propertyType),
            _InfoColumn(title: 'Installment Number', value: details.installmentNumber),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoColumn(title: 'Installment Amount', value: details.installmentAmount),
            _InfoColumn(title: 'Installment Date', value: details.installmentDate),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoColumn(title: 'Mode of Payment', value: details.modeOfPayment),
            _InfoColumn(title: 'Paid Date', value: details.paidDate),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentProofSection(BuildContext context, PaymentDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Proof', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: details.paymentProofUrl != null && details.paymentProofUrl!.isNotEmpty
              ? () => _openPdfFile(context, details.paymentProofUrl!)
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: details.paymentProofUrl != null && details.paymentProofUrl!.isNotEmpty
                  ? Border.all(color: Colors.yellow.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/images/pdf.svg', height: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.paymentProofFile,
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(details.paymentProofSize, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                if (details.paymentProofUrl != null && details.paymentProofUrl!.isNotEmpty)
                  const Icon(Icons.arrow_forward_ios, color: Colors.yellow, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(details.agreementValidity, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildEditPaymentButton(BuildContext context, PaymentDetails details) {
    // Parse payment date from installmentDate or paidDate
    DateTime? paymentDate;
    try {
      if (details.paidDate != '—' && details.paidDate.isNotEmpty) {
        // Format is dd/MM/yy, need to parse it
        final parts = details.paidDate.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse('20${parts[2]}'); // Assuming 20xx
          paymentDate = DateTime(year, month, day);
        }
      }
    } catch (e) {
      print('Error parsing payment date: $e');
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to edit payment page with all existing data
          context.pushNamed(
            'edit-payment',
            pathParameters: {'itemId': '${details.occupantRecordId}'},
            queryParameters: {
              'paymentId': '${details.paymentId}',
              'amount': '${details.amount}',
              'status': details.status,
              'modeOfPayment': details.modeOfPayment != '—' ? details.modeOfPayment : 'online',
              if (paymentDate != null)
                'paymentDate': paymentDate.toIso8601String(),
              if (details.paymentProofUrl != null && details.paymentProofUrl!.isNotEmpty)
                'proofUrl': details.paymentProofUrl!,
              'propertyType': details.propertyType,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          details.status.toLowerCase() == 'paid' ? 'Edit Payment' : 'Mark as Paid / Edit Payment',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// Reusable helper widget for displaying info
class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}