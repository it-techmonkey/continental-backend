import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import '../portfolio/addProperty/addPropertyScreen.dart';
import '../../services/s3_upload_service.dart';
import '../../services/payments_service.dart';
import '../../services/occupants_service.dart';
import 'actionable_repository.dart';
import 'actionable_repository.dart' as actionable;
import '../portfolio/portfolio_res.dart'; // For portfolioDataProvider
import '../menu/payments/payment_details_provider.dart'; // For paymentDetailsProvider

class EditPaymentScreen extends ConsumerStatefulWidget {
  final int paymentId;
  final num amount;
  final String status;
  final String? currentProofUrl;
  final int occupantRecordId;
  final String? modeOfPayment;
  final String? paymentDate;
  final String? propertyType;

  const EditPaymentScreen({
    super.key,
    required this.paymentId,
    required this.amount,
    required this.status,
    this.currentProofUrl,
    required this.occupantRecordId,
    this.modeOfPayment,
    this.paymentDate,
    this.propertyType,
  });

  @override
  ConsumerState<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends ConsumerState<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPaymentMode;
  DateTime? _selectedDate;
  String? _paymentProofUrl;
  String? _propertyType; // Store property type to know if it's rental or offplan
  num? _totalPrice; // Store total price for OffPlan to calculate remaining amount
  num? _remainingAmount; // Remaining amount that can be allocated
  final S3UploadService _s3Service = S3UploadService();

  @override
  void initState() {
    super.initState();
    // Use existing status if provided, otherwise default to "due" (user can save without marking as paid)
    _selectedStatus = widget.status;
    
    // Fetch property details to get total price for remaining amount calculation
    _fetchPropertyDetails();
    
    // Use existing payment mode if provided, otherwise default to "online"
    _selectedPaymentMode = widget.modeOfPayment ?? 'online';
    
    // Use existing payment date if provided, otherwise use current date
    if (widget.paymentDate != null) {
      try {
        _selectedDate = DateTime.parse(widget.paymentDate!);
      } catch (e) {
        print('Error parsing payment date: $e');
        _selectedDate = DateTime.now();
      }
    } else {
      _selectedDate = DateTime.now();
    }
    
    // Use existing proof URL if provided
    _paymentProofUrl = widget.currentProofUrl;
    
    // Initialize amount with current value (use empty string if 0 or empty payment)
    _amountController.text = widget.amount > 0 ? widget.amount.toStringAsFixed(0) : '';
    
    // Add listener to recalculate remaining amount when user types
    _amountController.addListener(_updateRemainingAmount);
    
    // Use provided property type or fetch it
    if (widget.propertyType != null) {
      _propertyType = widget.propertyType;
    } else {
      // Fetch property type from payment to determine if it's rental or offplan
      _fetchPaymentDetails();
    }
  }

  void _updateRemainingAmount() {
    // Recalculate remaining amount when user types
    if (_propertyType != null && 
        (_propertyType!.toLowerCase().contains('off') || _propertyType!.toLowerCase().contains('plan')) &&
        _totalPrice != null) {
      // Recalculate by fetching all payments
      _calculateRemainingAmount();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentDetails() async {
    try {
      final payments = await PaymentsService().fetchPayments(dedupe: false);
      final payment = payments.firstWhere((p) => p.id == widget.paymentId);
      setState(() {
        _propertyType = payment.propertyType; // Store property type
      });
    } catch (e) {
      print('Error fetching payment details: $e');
    }
  }

  Future<void> _fetchPropertyDetails() async {
    try {
      final occupantsService = OccupantsService();
      final property = await occupantsService.fetchOccupantDetail(widget.occupantRecordId);
      if (property != null) {
        setState(() {
          _propertyType = property.propertyType;
          _totalPrice = property.price; // For OffPlan
          
          // Calculate remaining amount for OffPlan
          if (_propertyType != null && 
              (_propertyType!.toLowerCase().contains('off') || _propertyType!.toLowerCase().contains('plan')) &&
              _totalPrice != null) {
            // Fetch all payments to calculate remaining
            _calculateRemainingAmount();
          }
        });
      }
    } catch (e) {
      print('Error fetching property details: $e');
    }
  }

  Future<void> _calculateRemainingAmount() async {
    try {
      final paymentsService = PaymentsService();
      final allPayments = await paymentsService.fetchPaymentsByOccupant(widget.occupantRecordId);
      
      // Get current amount from controller (what user is typing)
      final amountText = _amountController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '');
      final currentAmount = num.tryParse(amountText) ?? 0;
      
      // Calculate total allocated amount (sum of all payment amounts except current payment)
      num totalAllocated = 0;
      for (var p in allPayments) {
        if (p.id != widget.paymentId) {
          final amount = p.emi ?? p.rent ?? 0;
          totalAllocated += amount;
        }
      }
      
      // Add current amount being entered/edited
      totalAllocated += currentAmount;
      
      // Remaining = total price - total allocated
      if (_totalPrice != null) {
        setState(() {
          _remainingAmount = _totalPrice! - totalAllocated;
        });
      }
    } catch (e) {
      print('Error calculating remaining amount: $e');
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      // Parse amount from controller
      final amountText = _amountController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '');
      final newAmount = num.tryParse(amountText);
      
      if (newAmount == null || newAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
        );
        return;
      }

      try {
        // For OffPlan: Check if amount exceeds remaining amount
        if (_propertyType != null && 
            (_propertyType!.toLowerCase().contains('off') || _propertyType!.toLowerCase().contains('plan')) &&
            _remainingAmount != null &&
            newAmount > _remainingAmount!) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Amount exceeds remaining balance. Remaining: AED ${_remainingAmount!.toStringAsFixed(0)}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Get old payment amount before updating (use 0 if empty)
        final oldAmount = widget.amount > 0 ? widget.amount : 0;
        final amountDifference = newAmount - oldAmount;

        // Update payment - allow saving with "due" status (user can save without marking as paid)
        final success = await PaymentsService().updatePayment(
          widget.paymentId,
          status: _selectedStatus ?? 'due', // Allow "due" status for saving details
          paymentDate: _selectedDate!.toIso8601String(),
          paymentProof: _paymentProofUrl, // Can be null
          amount: newAmount, // Pass the edited amount
          propertyType: _propertyType, // Pass property type to determine emi vs rent
          modeOfPayment: _selectedPaymentMode, // Pass payment mode
        );

        if (mounted) {
          if (success) {
            // Only update property total price if amount changed AND it's not an empty payment being filled
            // For OffPlan: Don't update total price when user fills in empty payments
            // For Rental: Update rent if amount changed
            if (amountDifference != 0 && _propertyType != null) {
              final isOffPlan = _propertyType!.toLowerCase().contains('off') || 
                                _propertyType!.toLowerCase().contains('plan');
              // For OffPlan: Don't update total price (it's fixed, payments are allocated from it)
              // For Rental: Update rent if needed
              if (!isOffPlan) {
                await _updatePropertyPrice(amountDifference);
              }
            }

            // Refresh the payments list in customer details
            ref.invalidate(occupantPaymentsProvider(widget.occupantRecordId));
            // Refresh portfolio items to reflect payment status changes
            ref.invalidate(portfolioItemsProvider);
            // Refresh customer details if needed
            ref.invalidate(customerDetailsProvider(widget.occupantRecordId.toString()));
            // Refresh payment details if we're coming from payment details page
            ref.invalidate(paymentDetailsProvider(widget.paymentId.toString()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment updated successfully'), backgroundColor: Colors.green),
            );
            context.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update payment'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _updatePropertyPrice(num amountDifference) async {
    try {
      // Fetch current property details
      final occupantsService = OccupantsService();
      final property = await occupantsService.fetchOccupantDetail(widget.occupantRecordId);
      
      if (property == null) {
        print('⚠️ [UPDATE_PROPERTY_PRICE] Property not found');
        return;
      }

      final isOffPlan = _propertyType!.toLowerCase().contains('off') || 
                        _propertyType!.toLowerCase().contains('plan');
      
      final updateData = <String, dynamic>{};
      
      if (isOffPlan) {
        // For OffPlan: update total price
        final currentPrice = property.price ?? 0;
        final newPrice = (currentPrice + amountDifference).toInt();
        if (newPrice > 0) {
          updateData['price'] = newPrice;
          print('💰 [UPDATE_PROPERTY_PRICE] Updating OffPlan price: $currentPrice -> $newPrice (diff: $amountDifference)');
        }
      } else {
        // For Rental: update rent
        final currentRent = property.rent ?? 0;
        final newRent = (currentRent + amountDifference).toInt();
        if (newRent > 0) {
          updateData['rent'] = newRent;
          print('💰 [UPDATE_PROPERTY_PRICE] Updating Rental rent: $currentRent -> $newRent (diff: $amountDifference)');
        }
      }

      if (updateData.isNotEmpty) {
        final updateSuccess = await occupantsService.updateOccupantRecord(widget.occupantRecordId, updateData);
        if (updateSuccess) {
          print('✅ [UPDATE_PROPERTY_PRICE] Property price updated successfully');
        } else {
          print('❌ [UPDATE_PROPERTY_PRICE] Failed to update property price');
        }
      }
    } catch (e) {
      print('❌ [UPDATE_PROPERTY_PRICE] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_US', symbol: 'AED ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: Text('Edit Payment', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Amount', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(currency.format(widget.amount > 0 ? widget.amount : 0), style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Date', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(DateFormat('dd/MM/yy').format(_selectedDate!), style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Show remaining amount for OffPlan
                if (_propertyType != null && 
                    (_propertyType!.toLowerCase().contains('off') || _propertyType!.toLowerCase().contains('plan')) &&
                    _remainingAmount != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Remaining Amount', style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                        Text(
                          currency.format(_remainingAmount!),
                          style: GoogleFonts.inter(color: Colors.yellow[700], fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Payment Amount (editable)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Amount', style: GoogleFonts.inter(color: Colors.grey[400])),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'AED',
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.yellow)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter amount';
                          }
                          final amountText = value.trim().replaceAll(RegExp(r'[^0-9.]'), '');
                          final amount = num.tryParse(amountText);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          // For OffPlan: Check if amount exceeds remaining
                          if (_propertyType != null && 
                              (_propertyType!.toLowerCase().contains('off') || _propertyType!.toLowerCase().contains('plan')) &&
                              _remainingAmount != null &&
                              amount > _remainingAmount!) {
                            return 'Amount exceeds remaining: ${currency.format(_remainingAmount!)}';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Payment Date
                _CustomDatePickerField(
                  label: 'Payment Date',
                  initialDate: _selectedDate!,
                  onDateSelected: (date) => setState(() => _selectedDate = date),
                ),

                // Status dropdown (allow "due" or "paid")
                _CustomDropdownField(
                  label: 'Payment Status',
                  value: _selectedStatus,
                  items: ['due', 'paid'],
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),

                // Mode of Payment
                _CustomDropdownField(
                  label: 'Mode Of Payment',
                  value: _selectedPaymentMode,
                  items: ['online', 'cash', 'cheque'],
                  onChanged: (v) => setState(() => _selectedPaymentMode = v),
                ),

                const SizedBox(height: 16),

                // Payment Proof Upload
                _buildPaymentProofUpload(),

                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildPaymentProofUpload() {
    return _PaymentProofUploadField(
      proofUrl: _paymentProofUrl,
      onTap: () async {
        // Allow both images and PDFs
        final result = await _s3Service.pickFile(
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading file...'), duration: Duration(seconds: 1)),
          );
          final file = File(result.files.single.path!);
          final fileName = result.files.single.name;
          final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                         fileName.toLowerCase().endsWith('.jpeg') || 
                         fileName.toLowerCase().endsWith('.png');
          
          final url = isImage
              ? await _s3Service.uploadImage(
                  imageFile: file,
                  uploadType: 'payment-proof',
                  fileName: fileName,
                )
              : await _s3Service.uploadFile(
                  file: file,
                  uploadType: 'payment-proof',
                  fileName: fileName,
                );
          
          if (mounted) {
            setState(() => _paymentProofUrl = url);
            if (url != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File uploaded!'), backgroundColor: Colors.green),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload failed'), backgroundColor: Colors.red),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildConfirmButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
          child: ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            _selectedStatus?.toLowerCase() == 'paid' ? 'Mark as Paid' : 'Save Payment Details',
            style: GoogleFonts.inter(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// Payment Proof Upload Widget (matches the reference image)
class _PaymentProofUploadField extends StatelessWidget {
  final String? proofUrl;
  final VoidCallback onTap;

  const _PaymentProofUploadField({this.proofUrl, required this.onTap});

  bool _isImage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') || 
           lowerUrl.endsWith('.jpeg') || 
           lowerUrl.endsWith('.png') || 
           lowerUrl.endsWith('.gif') ||
           lowerUrl.endsWith('.webp');
  }

  bool _isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'File';
    } catch (e) {
      return 'File';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = proofUrl != null && proofUrl!.isNotEmpty && _isImage(proofUrl!);
    final isPdf = proofUrl != null && proofUrl!.isNotEmpty && _isPdf(proofUrl!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Proof', style: GoogleFonts.inter(color: Colors.grey[400])),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: proofUrl == null || proofUrl!.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 8),
                      Text('Upload PDF, PNG or JPEG', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14)),
                      Text('Files Upto 20 MB', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
                    ],
                  )
                : isImage
                    ? Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                proofUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stack) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.red, size: 40),
                                    const SizedBox(height: 8),
                                    Text('Failed to load image', style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text('Proof uploaded', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/images/pdf.svg', height: 50, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _getFileName(proofUrl!),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text('Proof uploaded', style: GoogleFonts.inter(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

// Date Picker Field
class _CustomDatePickerField extends StatelessWidget {
  final String label;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomDatePickerField({
    required this.label,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    String displayDate = DateFormat('yyyy-MM-dd').format(initialDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(data: ThemeData.dark(), child: child!);
                },
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(displayDate, style: GoogleFonts.inter(color: Colors.white)),
                  const Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dropdown Field
class _CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _CustomDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400])),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children: items.map((item) => ListTile(
                    title: Text(item.toUpperCase(), style: GoogleFonts.inter(color: Colors.white)),
                    onTap: () {
                      onChanged(item);
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value?.toUpperCase() ?? 'Type', style: GoogleFonts.inter(color: Colors.white)),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

