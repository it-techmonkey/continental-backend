// lib/payments_screen.dart
import 'package:continental/feature/menu/payments/payment_list_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    // Invalidate the provider when screen loads to fetch fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(paymentsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Payments', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildSearchHeader(ref),
          Expanded(
            child: paymentsAsync.when(
              // The ".when" will re-render the shimmer or the list when data re-fetches
              loading: () => const _ShimmerList(), // A nice loading effect
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              data: (payments) => payments.isEmpty
                  ? Center(child: Text('No payments found.', style: GoogleFonts.inter(color: Colors.grey)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        return _PaymentListItem(payment: payments[index]);
                      },
                      separatorBuilder: (context, index) => Divider(color: Colors.grey[900]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (query) {
                ref.read(paymentSearchQueryProvider.notifier).state = query;
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search For Properties',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.grey[800]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // const SizedBox(width: 12),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: IconButton(
          //     icon: Icon(CupertinoIcons.slider_horizontal_3, color: Colors.grey[800]),
          //     onPressed: () {
          //       // TODO: Implement filter functionality
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}

// Reusable list item widget
class _PaymentListItem extends StatelessWidget {
  final Payment payment;
  const _PaymentListItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed('payment-details', pathParameters: {'paymentId': payment.id.toString()});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(payment.propertyName, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Amount', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
                  Text(payment.amount, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chevron_right, color: Colors.white),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    payment.type == PaymentType.rental ? 'Rental' : 'Off Plan',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A simple shimmer loading widget for a better UX
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}