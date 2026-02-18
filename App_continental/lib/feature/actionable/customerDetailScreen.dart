// lib/customer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import 'package:continental/providers/language_provider.dart';
import 'package:continental/services/language_service.dart';
import 'actionable_repository.dart'; // Import for the provider and model
import 'package:continental/services/payments_service.dart';
import 'package:continental/services/occupants_service.dart';
import 'package:continental/feature/portfolio/portfolio_res.dart';
import 'package:intl/intl.dart';
import '../../widget/roi_graph_widget.dart';
import '../../services/dio_service.dart';
import '../../storage/token_storage.dart';
import '../../config/api_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final String itemId;
  const CustomerDetailsScreen({super.key, required this.itemId});

  // Helper method to open PDF files on Android/iOS
  Future<void> _openPdfFile(BuildContext context, String pdfUrl, String Function(String) translate) async {
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
            SnackBar(
              content: Text(translate('Downloading file...')),
              duration: const Duration(seconds: 2),
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
                content: Text(translate('Unable to open file: ${result.message}')),
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
              SnackBar(
                content: Text(translate('Unable to open file')),
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
            content: Text('${translate('Error opening file: ')}$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the .family provider by passing the itemId
    final detailsAsync = ref.watch(customerDetailsProvider(itemId));
    final occupantId = int.tryParse(itemId) ?? 0;
    final paymentsAsync = ref.watch(occupantPaymentsProvider(occupantId));
    final languageCode = ref.watch(languageProvider);
    final translate = (String key) => LanguageService.translate(key, languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (details) => Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, details),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 280.0), // Increased bottom padding for buttons and charges section
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            paymentsAsync.when(
                              loading: () => _buildRentalDetailsSection(details, null, translate),
                              error: (e, s) => _buildRentalDetailsSection(details, null, translate),
                              data: (payments) => _buildRentalDetailsSection(details, payments, translate),
                            ),
                            const SizedBox(height: 30),
                            _buildRentalAgreementSection(details, translate, context),
                            const SizedBox(height: 24),
                            // ROI Graph
                            ROIGraphWidget(
                              locality: details.locality,
                            ),
                            const SizedBox(height: 24),
                            // Payment Summary after Rental Agreement
                            paymentsAsync.when(
                              loading: () => const SizedBox(),
                              error: (e, s) => const SizedBox(),
                              data: (payments) => _buildPaymentSummaryTop(payments, details, translate),
                            ),
                            const SizedBox(height: 24),
                            paymentsAsync.when(
                              loading: () => const Center(child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              )),
                              error: (e, s) => Text('Failed to load payments', style: GoogleFonts.inter(color: Colors.redAccent)),
                              data: (payments) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(translate('Payment Timeline'), style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    ...payments.asMap().entries.map((entry) => _TimelineRow(payment: entry.value, itemId: itemId, index: entry.key + 1, propertyDetails: details)).toList(),
                                    const SizedBox(height: 24),
                                    // Charges section in 2x2 grid
                                    _buildChargesSection(details, translate),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Floating action buttons at the bottom
            _buildActionButtons(details, translate),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, CustomerDetails details) {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Colors.black,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: (){ Navigator.of(context).maybePop(); },
      ),
      title: Text('Details', style: GoogleFonts.inter( color: Colors.white)),
      flexibleSpace: FlexibleSpaceBar(
        // title: Text('Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              details.imageUrl,
              fit: BoxFit.cover,
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            // Property Name and Developer
            Positioned(
              bottom: 20,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_capitalizeFirst(details.propertyName), style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_capitalizeFirst(details.developerName.replaceFirst('By ', '')), style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        expandedTitleScale: 1.8,
      ),
    );
  }

  Widget _buildPaymentSummaryTop(List<PaymentItemDto> payments, CustomerDetails details, String Function(String) translate) {
    final currency = NumberFormat.currency(locale: 'en_US', symbol: 'AED ', decimalDigits: 0);
    
    // Check if property is Off-Plan
    final isOffPlan = details.propertyType.toLowerCase().contains('off') || 
                      details.propertyType.toLowerCase().contains('plan');
    
    // Calculate paid amount
    final paidPayments = payments.where((p) => p.status.toLowerCase() == 'paid').toList();
    final amountPaid = paidPayments.fold<num>(0, (sum, p) => sum + (p.emi ?? p.rent ?? 0));
    
    // Calculate pending amount based on property type
    num amountPending;
    if (isOffPlan && details.totalPrice != null && details.totalPrice! > 0) {
      // For Off-Plan: Amount Pending = Total Price - Amount Paid (defaults to totalPrice if no payments)
      amountPending = details.totalPrice! - amountPaid;
      if (amountPending < 0) amountPending = 0; // Ensure non-negative
    } else {
      // For Rental: Calculate from payments (total - paid)
      final totalAmount = payments.fold<num>(0, (sum, p) => sum + (p.emi ?? p.rent ?? 0));
      amountPending = totalAmount - amountPaid;
    }
    
    // Calculate overall status
    final status = _calculateOverallStatus(payments);
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
    // Calculate percentage paid (only for Off-Plan)
    String? percentageText;
    if (isOffPlan && details.totalPrice != null && details.totalPrice! > 0) {
      final percentagePaid = (amountPaid / details.totalPrice!) * 100;
      percentageText = '${percentagePaid.toStringAsFixed(1)}%';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translate('Payment Summary'), style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _SummaryInfo(title: translate('Amount Paid'), value: currency.format(amountPaid), color: Colors.greenAccent)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryInfo(title: translate('Amount Pending'), value: currency.format(amountPending), color: Colors.yellow[700]!)),
            ],
          ),
          // Show Total Price if available
          if (details.totalPrice != null && details.totalPrice! > 0) ...[
            const SizedBox(height: 16),
            // For Off-Plan: Show percentage next to Total Price in the same box
            if (isOffPlan && percentageText != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(translate('Total Price'), style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(
                          currency.format(details.totalPrice!),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(translate('Paid'), style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(
                          percentageText!,
                          style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              // For Rental: Show Property Price without percentage
              _SummaryInfo(title: translate('Property Price'), value: currency.format(details.totalPrice!), color: Colors.white),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Status', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalDetailsSection(CustomerDetails details, List<PaymentItemDto>? payments, String Function(String) translate) {
    // Calculate pending installments count
    int pendingCount = 0;
    if (payments != null && payments.isNotEmpty) {
      pendingCount = payments.where((p) => p.status.toLowerCase() != 'paid').length;
    }
    
    // Determine section title based on property type
    final isOffPlan = details.propertyType.toLowerCase().contains('off') || details.propertyType.toLowerCase().contains('plan');
    final sectionTitle = isOffPlan ? translate('Offplan Details') : translate('Rental Details');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoColumn(title: translate('Tenant Name'), value: _capitalizeFirst(details.tenantName)),
            _InfoColumn(title: translate('Installments Due'), value: pendingCount.toString()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoColumn(title: translate('Property Type'), value: details.propertyType),
            const SizedBox(), // Status removed from here, now at top
          ],
        ),
      ],
    );
  }

  String _calculateOverallStatus(List<PaymentItemDto> payments) {
    if (payments.isEmpty) return 'due';
    
    // Check if all payments are paid
    final allPaid = payments.every((p) => p.status.toLowerCase() == 'paid');
    if (allPaid) return 'paid';
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // Check for overdue payments (past due date and unpaid)
    bool hasOverdue = false;
    bool hasDue = false;
    
    for (var payment in payments) {
      if (payment.status.toLowerCase() == 'paid') continue;
      
      if (payment.paymentDate != null) {
        try {
          final paymentDate = DateTime.parse(payment.paymentDate!);
          final isPast = paymentDate.year < currentYear || 
                        (paymentDate.year == currentYear && paymentDate.month < currentMonth);
          
          if (isPast) {
            hasOverdue = true;
            break;
          } else {
            hasDue = true;
          }
        } catch (e) {
          // Skip if date parsing fails
        }
      } else {
        hasDue = true;
      }
    }
    
    if (hasOverdue) return 'overdue';
    if (hasDue) return 'due';
    return 'due';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.greenAccent;
      case 'overdue':
        return Colors.redAccent;
      case 'due':
      default:
        return Colors.yellow[700]!;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Over Due';
      case 'due':
      default:
        return 'Due';
    }
  }

  Widget _buildRentalAgreementSection(CustomerDetails details, String Function(String) translate, BuildContext context) {
    final isRental = details.propertyType.toLowerCase() == 'rental';
    final pdfUrl = isRental ? details.rentalAgreement : details.offplanAgreement;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate('Agreement'), style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: pdfUrl != null && pdfUrl.isNotEmpty
              ? () => _openPdfFile(context, pdfUrl, translate)
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: pdfUrl != null && pdfUrl.isNotEmpty
                  ? Border.all(color: Colors.yellow.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/images/pdf.svg', height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.pdfFileName,
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        details.pdfFileSize,
                        style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (pdfUrl != null && pdfUrl.isNotEmpty)
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

  Widget _buildChargesSection(CustomerDetails details, String Function(String) translate) {
    // Only show if at least one charge field has a value
    final hasCharges = details.dld != null || details.quood != null || details.otherCharges != null || details.penalties != null;
    
    if (!hasCharges) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('Charges'),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChargeCard(
                title: translate('DLD'),
                value: details.dld,
                itemId: itemId,
                fieldName: 'dld',
                translate: translate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChargeCard(
                title: translate('QUOOD'),
                value: details.quood,
                itemId: itemId,
                fieldName: 'quood',
                translate: translate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ChargeCard(
                title: translate('Other Charges'),
                value: details.otherCharges,
                itemId: itemId,
                fieldName: 'otherCharges',
                translate: translate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChargeCard(
                title: translate('Penalties'),
                value: details.penalties,
                itemId: itemId,
                fieldName: 'penalties',
                translate: translate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24), // Extra spacing at bottom of charges section
      ],
    );
  }

  Widget _buildActionButtons(CustomerDetails details, String Function(String) translate) {
    return Builder(
      builder: (context) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.black,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Edit and Delete buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.pushNamed('edit-property', pathParameters: {'itemId': itemId});
                          },
                          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                          label: Text(translate('Edit Property'), style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Show confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: Text(translate('Delete Property'), style: GoogleFonts.inter(color: Colors.white)),
                                content: Text(translate('Are you sure you want to delete this property? This action cannot be undone.'), style: GoogleFonts.inter(color: Colors.white70)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(translate('Cancel'), style: GoogleFonts.inter(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(translate('Delete'), style: GoogleFonts.inter(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final occupantsService = OccupantsService();
                              final success = await occupantsService.deleteOccupantRecord(int.parse(itemId));

                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(translate('Property deleted successfully')), backgroundColor: Colors.green),
                                  );
                                  context.pop(); // Go back to previous screen
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(translate('Failed to delete property')), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                          label: Text(translate('Delete'), style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Call button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final phoneNumber = details.phone;
                        if (phoneNumber.isNotEmpty) {
                          final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(translate('Unable to make phone call')), backgroundColor: Colors.red),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: Text(translate('Call the Tenant'), style: GoogleFonts.inter(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Reusable helper widget
class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SummaryInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryInfo({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ChargeCard extends ConsumerWidget {
  final String title;
  final int? value;
  final String itemId;
  final String fieldName; // 'dld', 'quood', 'otherCharges', 'penalties'
  final String Function(String) translate;
  
  const _ChargeCard({
    required this.title,
    this.value,
    required this.itemId,
    required this.fieldName,
    required this.translate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayValue = value != null ? 'AED $value' : '—';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 4),
              Text(displayValue, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.yellow, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showEditDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          translate('Edit') + ' $title',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: translate('Enter amount'),
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.yellow),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(translate('Cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = int.tryParse(controller.text.trim());
              
              // Validate input
              if (newValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(translate('Please enter a valid number')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final occupantsService = OccupantsService();
              
              // Build map with only the field being updated
              final updateMap = <String, int?>{};
              if (fieldName == 'dld') {
                updateMap['dld'] = newValue;
              } else if (fieldName == 'quood') {
                updateMap['quood'] = newValue;
              } else if (fieldName == 'otherCharges') {
                updateMap['otherCharges'] = newValue;
              } else if (fieldName == 'penalties') {
                updateMap['penalties'] = newValue;
              }
              
              final success = await occupantsService.updateCharges(
                int.parse(itemId),
                updateMap,
              );
              
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  // Invalidate and wait a bit for the backend to process
                  ref.invalidate(customerDetailsProvider(itemId));
                  
                  // Force a rebuild by waiting a moment
                  await Future.delayed(const Duration(milliseconds: 300));
                  
                  // Refresh again to ensure we get the latest data
                  ref.invalidate(customerDetailsProvider(itemId));
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(translate('Charges updated successfully')),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(translate('Failed to update charges')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
            child: Text(translate('Save'), style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends ConsumerWidget {
  final PaymentItemDto payment;
  final String itemId;
  final int index;
  final CustomerDetails? propertyDetails; // Add property details to check if OffPlan
  const _TimelineRow({required this.payment, required this.itemId, required this.index, this.propertyDetails});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
        return Colors.greenAccent;
      case 'overdue':
        return Colors.redAccent;
      case 'due':
      default:
        return Colors.yellow[700]!;
    }
  }

  // Check if payment is empty (no emi/rent value)
  bool _isPaymentEmpty() {
    final emi = payment.emi;
    final rent = payment.rent;
    return (emi == null || emi == 0) && (rent == null || rent == 0);
  }

  // Check if payment has details but not paid (has amount but status is not paid)
  bool _hasDetailsButNotPaid() {
    if (_isPaymentEmpty()) return false;
    return payment.status.toLowerCase() != 'paid';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = payment.emi ?? payment.rent ?? 0;
    final isOffPlan = propertyDetails?.propertyType.toLowerCase().contains('off') ?? 
                      payment.propertyType.toLowerCase().contains('off') ||
                      payment.propertyType.toLowerCase().contains('plan');
    final isEmpty = _isPaymentEmpty();
    final hasDetailsNotPaid = _hasDetailsButNotPaid();
    final isPaid = payment.status.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: _statusColor(payment.status), shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment $index', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_formatDate(payment), style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                if (amount > 0) ...[
                  const SizedBox(height: 4),
                  Text('AED ${amount.toStringAsFixed(0)}', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 11)),
                ],
              ],
            ),
          ),
          // Show different buttons based on payment state
          if (isPaid)
            Builder(
              builder: (context) {
                final languageCode = ref.watch(languageProvider);
                final translate = (String key) => LanguageService.translate(key, languageCode);
                // For paid payments, only show View button (Edit is available in the payment details page)
                return ElevatedButton(
                  onPressed: () {
                    context.pushNamed(
                      'payment-details',
                      pathParameters: {'paymentId': '${payment.id}'},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: BorderSide(color: _statusColor(payment.status)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(translate('View'), style: GoogleFonts.inter(color: _statusColor(payment.status), fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: _statusColor(payment.status), size: 16),
                    ],
                  ),
                );
              },
            )
          else if (hasDetailsNotPaid)
            // Green tick icon - payment has details but not paid yet
            Builder(
              builder: (context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.yellow, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.pushNamed(
                          'edit-payment',
                          pathParameters: {'itemId': itemId},
                          queryParameters: {
                            'paymentId': '${payment.id}',
                            'amount': '${amount}',
                            'status': payment.status,
                            'modeOfPayment': payment.modeOfPayment ?? 'online',
                            if (payment.paymentDate != null) 'paymentDate': payment.paymentDate!,
                            'propertyType': payment.propertyType,
                            if (payment.paymentProof != null && payment.paymentProof!.isNotEmpty) 'proofUrl': payment.paymentProof!,
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Green tick button - opens mark as paid
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.pushNamed(
                          'edit-payment',
                          pathParameters: {'itemId': itemId},
                          queryParameters: {
                            'paymentId': '${payment.id}',
                            'amount': '${amount}',
                            'status': payment.status,
                            'modeOfPayment': payment.modeOfPayment ?? 'online',
                            if (payment.paymentDate != null) 'paymentDate': payment.paymentDate!,
                            'propertyType': payment.propertyType,
                            if (payment.paymentProof != null && payment.paymentProof!.isNotEmpty) 'proofUrl': payment.paymentProof!,
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            )
          else
            // Empty payment - show Edit icon
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.yellow, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                context.pushNamed(
                  'edit-payment',
                  pathParameters: {'itemId': itemId},
                  queryParameters: {
                    'paymentId': '${payment.id}',
                    'amount': '0',
                    'status': payment.status,
                    'propertyType': payment.propertyType,
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

String _formatDate(PaymentItemDto p) {
  try {
    if (p.paymentDate == null) return '—';
    final dt = DateTime.tryParse(p.paymentDate!);
    if (dt == null) return '—';
    // Convert UTC to local time for proper display
    return DateFormat('dd/MM/yy').format(dt.toLocal());
  } catch (_) {
    return '—';
  }
}
