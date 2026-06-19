import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    return PopScope(
      canPop: parcelFlowType == null && context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (parcelFlowType != null) {
            ref.read(parcelFlowTypeProvider.notifier).update(null);
          } else {
            context.go('/');
          }
        }
      },
      child: Scaffold(
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
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
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
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SUPER FAST',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'City-wide Delivery',
                      style: AppTextStyles.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Same-day, door-to-door delivery starting at just ₹40!',
                      style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 2,
                child: SizedBox(), // Space for floating parcel box icon
              ),
            ],
          ),
          Positioned(
            right: -10,
            top: -20,
            bottom: -20,
            child: SvgPicture.asset(
              'assets/parcel.svg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .move(begin: const Offset(0, -6), end: const Offset(0, 6), duration: 1600.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionMode(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildPromoBanner()
            .animate()
            .fade(duration: 400.ms)
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutCubic),
        const SizedBox(height: 32),
        Text('What would you like to do?', style: AppTextStyles.h2),
        const SizedBox(height: 24),
        _buildActionCard(
          context,
          title: 'Send a Parcel',
          subtitle: 'Send packages within the city instantly',
          icon: Icons.outbox_rounded,
          color: Colors.blue,
          onTap: () {
            ref.read(parcelFlowTypeProvider.notifier).update('send');
            ref.read(locationProvider.notifier).clear();
            setState(() => _selectedCategory = null);
          },
        ).animate()
         .fade(delay: 100.ms, duration: 400.ms)
         .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
        const SizedBox(height: 20),
        _buildActionCard(
          context,
          title: 'Receive a Parcel',
          subtitle: 'Get packages picked up and delivered to your door',
          icon: Icons.move_to_inbox_rounded,
          color: AppColors.primaryGreen,
          onTap: () {
            ref.read(parcelFlowTypeProvider.notifier).update('receive');
            ref.read(locationProvider.notifier).clear();
            setState(() => _selectedCategory = null);
          },
        ).animate()
         .fade(delay: 200.ms, duration: 400.ms)
         .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 1.5),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 12),
            ),
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
        Text(isSending ? 'Where are you sending to?' : 'Where are we picking it up?', style: AppTextStyles.h3)
            .animate().fade(duration: 300.ms).slideX(begin: -0.05, end: 0),
        const SizedBox(height: 16),

        // Address Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
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
                width: 1.5,
                color: AppColors.border,
                margin: const EdgeInsets.only(left: 11),
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
        ).animate().fade(delay: 50.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 24),

        // OTP Secure Dropoff Alert
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'OTP Secured Drop-off: Secure verification PIN code required at Drop-off.',
                  style: AppTextStyles.caption.copyWith(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 24),

        // Category Selection
        Text('What are you sending?', style: AppTextStyles.h3)
            .animate().fade(delay: 150.ms, duration: 300.ms),
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
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedCategory = category['name'] as String);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(
                          colors: [AppColors.primaryGreenLight.withOpacity(0.4), AppColors.primaryGreenLight.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: isSelected ? 2.0 : 1.0),
                  boxShadow: isSelected 
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category['icon'] as String, style: const TextStyle(fontSize: 32))
                        .animate(target: isSelected ? 1 : 0)
                        .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 200.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(delay: (index * 30).ms, duration: 250.ms, curve: Curves.easeOutBack);
          },
        ),
        const SizedBox(height: 24),

        // Specifications List
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fits these delivery guidelines:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              _buildSpecItem(Icons.scale, 'Parcel weighs 20kg or less'),
              _buildSpecItem(Icons.warning_amber_rounded, 'No illegal, alcoholic, or restricted items'),
              _buildSpecItem(Icons.inventory_2_outlined, 'Package should fit in a standard delivery backpack'),
              _buildSpecItem(Icons.wine_bar_rounded, 'Avoid sending high value or fragile items'),
            ],
          ),
        ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),

        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Continue',
          disabled: locationState.pickup == null || locationState.destination == null || _selectedCategory == null,
          onPressed: () {
            context.push('/parcel-details', extra: _selectedCategory);
          },
        ).animate().fade(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAddressRow({required String label, String? address, required String iconText, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(iconText, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    if (address == null) const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primaryGreen),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address ?? 'Tap to add address details', style: AppTextStyles.caption.copyWith(color: address != null ? AppColors.textPrimary : AppColors.textSecondary)),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primaryGreenLight.withOpacity(0.5), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
