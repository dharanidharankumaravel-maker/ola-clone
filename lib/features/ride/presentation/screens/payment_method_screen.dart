import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/ride_provider.dart';
import '../../../../shared/widgets/primary_button.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  String _selectedPayment = 'cash';
  bool _isConfirming = false;

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _upiIdController = TextEditingController();

  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(useOlaMoneyProvider)) {
        setState(() => _selectedPayment = 'ola_money');
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String>{};
    
    if (_selectedPayment == 'card') {
      final cleanCard = _cardNumberController.text.replaceAll(' ', '');
      if (cleanCard.length < 15 || cleanCard.length > 16) {
        errors['cardNumber'] = 'Invalid card number';
      }
      if (_cardHolderController.text.trim().length < 3) {
        errors['cardHolder'] = 'Name is required';
      }
      if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(_expiryController.text)) {
        errors['expiry'] = 'Invalid expiry (MM/YY)';
      }
      if (_cvvController.text.length < 3 || _cvvController.text.length > 4) {
        errors['cvv'] = 'Invalid CVV';
      }
    } else if (_selectedPayment == 'upi') {
      if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(_upiIdController.text)) {
        errors['upiId'] = 'Invalid UPI ID format';
      }
    } else if (_selectedPayment == 'ola_money') {
      final finalFare = _getFinalFare();
      final walletBalance = 500.0; // Mock balance since user entity might not have it yet
      if (walletBalance < finalFare) {
        errors['olaMoney'] = 'Insufficient balance';
      }
    }

    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  double _getFinalFare() {
    final rideOptions = ref.read(rideOptionsProvider);
    final selectedRideType = ref.read(selectedRideTypeProvider);
    final useOlaMoney = ref.read(useOlaMoneyProvider);
    if (!useOlaMoney) {
      ref.read(useOlaMoneyProvider.notifier).update(true);
    }
    final promoDiscount = ref.read(promoDiscountProvider);
    final selectedOption = rideOptions.where((o) => o.type == selectedRideType).firstOrNull;
    return (selectedOption?.fareEstimate.total ?? 0) - promoDiscount;
  }

  void _handleConfirm() {
    if (!_validate()) return;

    setState(() => _isConfirming = true);
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      // Pushing to driver search will simulate matching.
      context.push('/driver-search');
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideOptions = ref.watch(rideOptionsProvider);
    final selectedRideType = ref.watch(selectedRideTypeProvider);
    final promoCode = ref.watch(promoCodeProvider);
    final promoDiscount = ref.watch(promoDiscountProvider);
    final selectedOption = rideOptions.where((o) => o.type == selectedRideType).firstOrNull;
    final finalFare = _getFinalFare();

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Payment Method', style: AppTextStyles.h3),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Fare Summary
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text('Total Fare Estimate', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('₹${finalFare.toStringAsFixed(0)}', style: AppTextStyles.h1),
                      const SizedBox(height: 8),
                      Text('for ${selectedOption?.name ?? 'Ride'}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                      if (promoCode != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('- ₹${promoDiscount.toStringAsFixed(0)} applied', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen)),
                            IconButton(
                              icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                              onPressed: () {
                                ref.read(promoCodeProvider.notifier).update(null);
                                ref.read(promoDiscountProvider.notifier).update(0.0);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo Removed')));
                              },
                            )
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Select a payment method', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 12),

                // Ola Money
                _buildOption(
                  'ola_money',
                  'Alo Money',
                  'Balance: ₹500', // Mocking balance for now
                  Icons.account_balance_wallet,
                  AppColors.primaryGreen,
                ),
                if (_errors['olaMoney'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 64, bottom: 8),
                    child: Text(_errors['olaMoney']!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                // Cash
                _buildOption(
                  'cash',
                  'Cash on Delivery',
                  'Pay driver after the ride ends',
                  Icons.money,
                  Colors.orange,
                ),

                // UPI
                _buildOption(
                  'upi',
                  'UPI',
                  'Pay directly from your bank',
                  Icons.qr_code,
                  Colors.purple,
                ),
                if (_selectedPayment == 'upi') ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 64, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildQuickSelect('GPay', 'user@okhdfcbank'),
                            const SizedBox(width: 8),
                            _buildQuickSelect('PhonePe', 'user@ybl'),
                            const SizedBox(width: 8),
                            _buildQuickSelect('Paytm', 'user@paytm'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _upiIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter UPI ID',
                            prefixIcon: const Icon(Icons.alternate_email, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            errorText: _errors['upiId'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Card
                _buildOption(
                  'card',
                  'Credit / Debit Card',
                  'Visa, MasterCard, RuPay',
                  Icons.credit_card,
                  Colors.blue,
                ),
                if (_selectedPayment == 'card') ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 64, right: 16, bottom: 16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Card Number',
                            prefixIcon: const Icon(Icons.credit_card, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            errorText: _errors['cardNumber'],
                          ),
                          onChanged: (val) {
                            // simple formatting
                            String text = val.replaceAll(' ', '');
                            if (text.length > 16) text = text.substring(0, 16);
                            String formatted = '';
                            for (int i = 0; i < text.length; i++) {
                              if (i > 0 && i % 4 == 0) formatted += ' ';
                              formatted += text[i];
                            }
                            _cardNumberController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cardHolderController,
                          decoration: InputDecoration(
                            hintText: 'Card Holder Name',
                            prefixIcon: const Icon(Icons.person, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            errorText: _errors['cardHolder'],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _expiryController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'MM/YY',
                                  prefixIcon: const Icon(Icons.calendar_month, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  errorText: _errors['expiry'],
                                ),
                                onChanged: (val) {
                                  String text = val.replaceAll('/', '');
                                  if (text.length > 4) text = text.substring(0, 4);
                                  if (text.length >= 2) {
                                    text = '${text.substring(0, 2)}/${text.substring(2)}';
                                  }
                                  _expiryController.value = TextEditingValue(
                                    text: text,
                                    selection: TextSelection.collapsed(offset: text.length),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'CVV',
                                  prefixIcon: const Icon(Icons.lock, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  errorText: _errors['cvv'],
                                ),
                                maxLength: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Confirm Booking',
                    onPressed: _handleConfirm,
                    isLoading: _isConfirming,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelect(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => _upiIdController.text = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildOption(String value, String title, String subtitle, IconData icon, Color color) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPayment = value;
        _errors.clear();
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color : AppColors.border, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
