import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/ride_provider.dart';

class ParcelScreen extends ConsumerStatefulWidget {
  const ParcelScreen({super.key});

  @override
  ConsumerState<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends ConsumerState<ParcelScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Documents', 'icon': '📄'},
    {'name': 'Food', 'icon': '🍱'},
    {'name': 'Groceries', 'icon': '🛒'},
    {'name': 'Medicines', 'icon': '💊'},
    {'name': 'Electronics', 'icon': '📱'},
    {'name': 'Clothes', 'icon': '👕'},
    {'name': 'Gifts', 'icon': '🎁'},
    {'name': 'Home', 'icon': '🏠'},
    {'name': 'Spares', 'icon': '🔧'},
    {'name': 'Pets', 'icon': '🐶'},
    {'name': 'Others', 'icon': '📦'},
  ];
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final parcelFlowType = ref.watch(parcelFlowTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (parcelFlowType != null) {
              ref.read(parcelFlowTypeProvider.notifier).update(null);
            } else {
              context.pop();
            }
          },
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
      body: parcelFlowType == null ? _buildSelectionMode(context, ref) : _buildAddressSelectionMode(context, ref, parcelFlowType),
    );
  }

  Widget _buildSelectionMode(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('What would you like to do?', style: AppTextStyles.h2),
        const SizedBox(height: 32),
        _buildActionCard(
          context,
          title: 'Send a Parcel',
          subtitle: 'Send packages within the city',
          icon: Icons.outbox,
          color: Colors.blue,
          onTap: () {
            ref.read(parcelFlowTypeProvider.notifier).update('send');
            ref.read(locationProvider.notifier).clear();
            setState(() => _selectedCategory = null);
          },
        ),
        const SizedBox(height: 24),
        _buildActionCard(
          context,
          title: 'Receive a Parcel',
          subtitle: 'Get packages picked up and delivered to you',
          icon: Icons.move_to_inbox,
          color: AppColors.primaryGreen,
          onTap: () {
            ref.read(parcelFlowTypeProvider.notifier).update('receive');
            ref.read(locationProvider.notifier).clear();
            setState(() => _selectedCategory = null);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelectionMode(BuildContext context, WidgetRef ref, String flowType) {
    final locationState = ref.watch(locationProvider);
    final isSending = flowType == 'send';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(isSending ? 'Where are you sending to?' : 'Where are we picking it up?', style: AppTextStyles.h3),
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
                label: isSending ? 'Pick up from (You):' : 'Collect from (Sender):',
                address: locationState.pickup?.shortAddress,
                iconText: 'A',
                color: AppColors.primaryGreen,
                onTap: () => context.push('/parcel-location-search', extra: true),
              ),
              Container(
                height: 24,
                width: 1,
                color: AppColors.border,
                margin: const EdgeInsets.only(left: 3.5),
                alignment: Alignment.centerLeft,
              ),
              _buildAddressRow(
                label: isSending ? 'Deliver to (Receiver):' : 'Deliver to (You):',
                address: locationState.destination?.shortAddress,
                iconText: 'B',
                color: Colors.red,
                onTap: () => context.push('/parcel-location-search', extra: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Selection
        Text('What are you sending?', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreenLight : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category['icon'] as String, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
        PrimaryButton(
          text: 'Continue',
          disabled: locationState.pickup == null || locationState.destination == null || _selectedCategory == null,
          onPressed: () {
            context.push('/parcel-details', extra: _selectedCategory);
          },
        ),
        const SizedBox(height: 40),
      ],
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
