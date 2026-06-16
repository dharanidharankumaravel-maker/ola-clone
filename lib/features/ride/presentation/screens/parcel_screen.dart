import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../../../shared/widgets/primary_button.dart';

class ParcelScreen extends ConsumerStatefulWidget {
  const ParcelScreen({super.key});

  @override
  ConsumerState<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends ConsumerState<ParcelScreen> {
  String _activeSegment = 'send';

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ALO ', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900)),
            Text('PARCEL', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.normal)),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Segments
          Row(
            children: [
              Expanded(
                child: _buildSegment('send', 'Send Parcel', 'Send within city limit'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSegment('receive', 'Receive Parcel', 'Get parcel within city limit'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Send or Receive Parcel', style: AppTextStyles.h3),
          const SizedBox(height: 16),

          // Address Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildAddressRow(
                  label: 'Collect from:',
                  address: locationState.pickup?.shortAddress,
                  iconText: 'A',
                  color: AppColors.primaryGreen,
                  onTap: () => context.push('/destination-search'),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.border,
                  margin: const EdgeInsets.only(left: 3.5),
                  alignment: Alignment.centerLeft,
                ),
                _buildAddressRow(
                  label: 'Deliver to:',
                  address: locationState.destination?.shortAddress,
                  iconText: 'B',
                  color: Colors.red,
                  onTap: () => context.push('/destination-search'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Specifications
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fit these specifications:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSpecItem(Icons.scale, 'Parcel weighs 20kg or less'),
                _buildSpecItem(Icons.warning, 'No illegal, alcoholic or restricted items'),
                _buildSpecItem(Icons.inventory_2, 'Item should fit in a backpack'),
                _buildSpecItem(Icons.wine_bar, 'Avoid sending high value & fragile items'),
              ],
            ),
          ),

          const SizedBox(height: 32),
          if (locationState.pickup != null && locationState.destination != null)
            PrimaryButton(
              text: 'Book Parcel',
              onPressed: () {
                context.push('/parcel-details');
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSegment(String id, String title, String subtitle) {
    final isActive = _activeSegment == id;
    return GestureDetector(
      onTap: () => setState(() => _activeSegment = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.textPrimary : AppColors.border, width: isActive ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                if (isActive)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
                    child: Icon(Icons.check, size: 10, color: AppColors.bgSurface),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow({required String label, String? address, required String iconText, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              alignment: Alignment.center,
              child: Text(iconText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    if (address == null) const Icon(Icons.add, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address ?? 'Tap to add address', style: AppTextStyles.caption.copyWith(color: address != null ? AppColors.textPrimary : AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: AppColors.primaryGreenLight, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
