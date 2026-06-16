import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/ride_option.dart';
import '../providers/ride_provider.dart';
import '../../../../shared/widgets/primary_button.dart';

class ParcelDetailsScreen extends ConsumerStatefulWidget {
  const ParcelDetailsScreen({super.key});

  @override
  ConsumerState<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends ConsumerState<ParcelDetailsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contentsController = TextEditingController();

  String _weight = 'upto_5';
  bool _touchedName = false;
  bool _touchedPhone = false;
  bool _touchedContents = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;
  bool get _isPhoneValid => _phoneController.text.trim().length >= 10;
  bool get _isContentsValid => _contentsController.text.trim().isNotEmpty;
  bool get _isFormValid => _isNameValid && _isPhoneValid && _isContentsValid;

  void _handleConfirm() {
    if (!_isFormValid) return;
    
    // Mock a parcel ride option
    ref.read(rideOptionsProvider.notifier).update([
      const RideOption(
        type: 'parcel',
        name: 'Alo Parcel',
        description: 'Package delivery service',
        icon: 'inventory_2',
        seats: 1,
        available: true,
        eta: 5,
        fareEstimate: FareEstimate(
          baseFare: 40,
          distanceFare: 15,
          timeFare: 0,
          surgeMultiplier: 1,
          total: 80,
          currency: 'INR',
          distance: 5.0,
          duration: 15,
        ),
      )
    ]);

    ref.read(selectedRideTypeProvider.notifier).update('parcel');
    context.push('/payment-method');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Parcel Details', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Receiver Details', style: AppTextStyles.h3),
                const SizedBox(height: 16),

                // Name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Receiver Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: _touchedName && !_isNameValid ? "Please enter receiver's name" : null,
                  ),
                  onChanged: (v) => setState(() {}),
                  onTapOutside: (_) => setState(() => _touchedName = true),
                ),
                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: 'Receiver Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: _touchedPhone && !_isPhoneValid ? 'Please enter a valid 10-digit number' : null,
                    counterText: '',
                  ),
                  onChanged: (v) => setState(() {}),
                  onTapOutside: (_) => setState(() => _touchedPhone = true),
                ),
                const SizedBox(height: 32),

                Text('Parcel Details', style: AppTextStyles.h3),
                const SizedBox(height: 16),

                // Contents
                TextField(
                  controller: _contentsController,
                  decoration: InputDecoration(
                    hintText: 'What are you sending? (e.g. Documents, Keys)',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: _touchedContents && !_isContentsValid ? 'Please describe the parcel contents' : null,
                  ),
                  onChanged: (v) => setState(() {}),
                  onTapOutside: (_) => setState(() => _touchedContents = true),
                ),
                const SizedBox(height: 24),

                Text('Approximate Weight', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _weight = 'upto_5'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _weight == 'upto_5' ? AppColors.primaryGreenLight : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _weight == 'upto_5' ? AppColors.primaryGreen : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('Up to 5 kg', style: AppTextStyles.bodyMedium.copyWith(color: _weight == 'upto_5' ? AppColors.primaryGreen : AppColors.textPrimary, fontWeight: _weight == 'upto_5' ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _weight = '5_15'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _weight == '5_15' ? AppColors.primaryGreenLight : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _weight == '5_15' ? AppColors.primaryGreen : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('5 - 15 kg', style: AppTextStyles.bodyMedium.copyWith(color: _weight == '5_15' ? AppColors.primaryGreen : AppColors.textPrimary, fontWeight: _weight == '5_15' ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Parcel Photo (Optional)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // simulate picking image
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text('Tap to add photo', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Do not send cash, jewelry, or prohibited items. Driver may verify the contents before pickup.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: PrimaryButton(
              text: 'Confirm Booking',
              onPressed: _isFormValid ? _handleConfirm : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
