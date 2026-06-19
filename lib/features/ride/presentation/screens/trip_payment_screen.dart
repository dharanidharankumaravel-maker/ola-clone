import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ride_provider.dart';

class TripPaymentScreen extends ConsumerStatefulWidget {
  const TripPaymentScreen({super.key});

  @override
  ConsumerState<TripPaymentScreen> createState() => _TripPaymentScreenState();
}

class _TripPaymentScreenState extends ConsumerState<TripPaymentScreen> {
  bool _isProcessing = false;
  bool _paymentCompleted = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    final currentRide = ref.read(currentRideProvider);
    final promoDiscount = ref.read(promoDiscountProvider);
    
    if (currentRide != null) {
      final double baseTotal = currentRide.fareEstimate.total - promoDiscount;
      final double finalFare = baseTotal + (currentRide.tipAmount ?? 0.0);

      // Simulate payment delay
      await Future.delayed(const Duration(seconds: 2));

      if (currentRide.paymentMethod == 'ola_money') {
        final user = ref.read(authProvider).value;
        if (user != null) {
          ref.read(authProvider.notifier).updateUser(
            user.copyWith(walletBalance: user.walletBalance - finalFare)
          );
        }
        ref.read(walletTransactionProvider.notifier).addTransaction(
          WalletTransaction(
            id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
            amount: finalFare,
            type: 'debit',
            description: 'Ride to ${currentRide.destination.shortAddress}',
            createdAt: DateTime.now(),
          )
        );
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _paymentCompleted = true;
        });
        
        final promoDiscount = ref.read(promoDiscountProvider);
        final baseTotal = currentRide.fareEstimate.total - promoDiscount;
        final updatedFareEstimate = currentRide.fareEstimate.copyWith(total: baseTotal);
        final completedRide = currentRide.copyWith(
          status: 'completed',
          fareEstimate: updatedFareEstimate,
        );
        
        // Add to history now so it's not lost if user skips feedback
        ref.read(rideHistoryProvider.notifier).addRide(completedRide);
        ref.read(currentRideProvider.notifier).setCurrentRide(completedRide);

        // Move to feedback screen shortly after payment completes
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.pushReplacement('/driver-feedback');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRide = ref.watch(currentRideProvider);
    final promoDiscount = ref.watch(promoDiscountProvider);

    if (currentRide == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final double baseTotal = currentRide.fareEstimate.total - promoDiscount;
    final double finalFare = baseTotal + (currentRide.tipAmount ?? 0.0);
    
    String paymentMethodDisplay = 'Alo Money';
    String helperText = 'Amount will be deducted from your Alo Money wallet.';
    
    if (currentRide.paymentMethod == 'cash') {
      paymentMethodDisplay = 'Cash';
      helperText = 'Please pay the driver in cash.';
    } else if (currentRide.paymentMethod == 'upi') {
      paymentMethodDisplay = 'UPI';
      helperText = 'Please complete the UPI payment using your preferred app.';
    } else if (currentRide.paymentMethod == 'card') {
      paymentMethodDisplay = 'Card';
      helperText = 'Amount will be charged to your saved card.';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_paymentCompleted) ...[
                const Icon(Icons.payment, size: 80, color: AppColors.primaryGreen)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
                const SizedBox(height: 32),
                Text('Payment Due', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                Text('₹${finalFare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                const SizedBox(height: 8),
                Text('via $paymentMethodDisplay', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                
                const SizedBox(height: 48),
                
                Text(helperText, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text(currentRide.paymentMethod == 'cash' ? 'Payment Done' : 'Pay Now', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                const Icon(Icons.check_circle, size: 100, color: AppColors.primaryGreen)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),
                Text('Payment Successful!', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                Text('Proceeding to feedback...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ],
            ),
          ),
        ),
      ),
    ));
  }
}
