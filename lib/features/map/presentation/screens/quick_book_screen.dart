import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/location_provider.dart';
import '../../domain/entities/app_location.dart';
import '../../../ride/presentation/providers/ride_provider.dart';

class QuickBookScreen extends ConsumerStatefulWidget {
  const QuickBookScreen({super.key});

  @override
  ConsumerState<QuickBookScreen> createState() => _QuickBookScreenState();
}

class _QuickBookScreenState extends ConsumerState<QuickBookScreen> {
  int _promoPageIndex = 0;
  late PageController _promoPageController;

  @override
  void initState() {
    super.initState();
    _promoPageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLocationAsync = ref.read(locationStreamProvider);
      final locationState = ref.read(locationProvider);
      
      if (locationState.pickup == null && currentLocationAsync.value != null) {
        ref.read(locationProvider.notifier).setPickup(currentLocationAsync.value!);
      }
    });
  }

  @override
  void dispose() {
    _promoPageController.dispose();
    super.dispose();
  }

  void _handleSelectDestination(AppLocation place) {
    ref.read(locationProvider.notifier).setDestination(place);
    ref.read(selectedRideCategoryProvider.notifier).update('daily');
    ref.read(selectedRideTypeProvider.notifier).update(null);
    context.pushReplacement('/ride-selection');
  }

  Widget _buildPromoCarousel() {
    final promoCards = [
      _PromoData(
        title: 'One-Click Quick Booking',
        description: 'Tap any saved or recent location to confirm your route instantly with pre-filled defaults.',
        icon: Icons.bolt_rounded,
        iconColor: Colors.amber,
        gradient: [
          Colors.indigo.shade800,
          Colors.blue.shade900,
        ],
      ),
      _PromoData(
        title: 'Frequent Routes Discount',
        description: 'Save up to 15% on daily commutes when booking through Quick Book.',
        icon: Icons.local_offer_rounded,
        iconColor: Colors.yellowAccent,
        gradient: [
          Colors.teal.shade800,
          Colors.cyan.shade900,
        ],
      ),
      _PromoData(
        title: 'Priority Dispatch Enabled',
        description: 'Get matched 2x faster with nearby drivers automatically during peak hours.',
        icon: Icons.speed_rounded,
        iconColor: Colors.orangeAccent,
        gradient: [
          Colors.red.shade900,
          Colors.orange.shade900,
        ],
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 125,
          child: PageView.builder(
            controller: _promoPageController,
            onPageChanged: (index) {
              setState(() {
                _promoPageIndex = index;
              });
            },
            itemCount: promoCards.length,
            itemBuilder: (context, index) {
              final promo = promoCards[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: promo.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: promo.gradient.first.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(promo.icon, color: promo.iconColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo.description,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.85), 
                              height: 1.2,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promoCards.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _promoPageIndex == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _promoPageIndex == index ? AppColors.primaryGreen : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow(List<SavedPlace> savedPlaces) {
    // Find Work or Home locations
    final homePlace = savedPlaces.firstWhere(
      (p) => p.title.toLowerCase() == 'home', 
      orElse: () => SavedPlace(
        title: 'Home', 
        location: const AppLocation(latitude: 0, longitude: 0, shortAddress: 'Not Set')
      ),
    );
    final workPlace = savedPlaces.firstWhere(
      (p) => p.title.toLowerCase() == 'work', 
      orElse: () => SavedPlace(
        title: 'Work', 
        location: const AppLocation(latitude: 0, longitude: 0, shortAddress: 'Not Set')
      ),
    );

    final hasHome = homePlace.location.shortAddress != 'Not Set';
    final hasWork = workPlace.location.shortAddress != 'Not Set';

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildQuickActionChip(
            icon: Icons.home_rounded,
            label: hasHome ? 'Go Home' : 'Set Home',
            color: Colors.green,
            onTap: () async {
              if (hasHome) {
                _handleSelectDestination(homePlace.location);
              } else {
                final result = await context.push<AppLocation>('/map-picker');
                if (result != null && mounted) {
                  ref.read(savedPlacesProvider.notifier).addPlace(
                    SavedPlace(
                      title: 'Home',
                      subtitle: result.formattedAddress,
                      location: result,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Home address saved!'), backgroundColor: AppColors.primaryGreen),
                  );
                }
              }
            },
          ),
          _buildQuickActionChip(
            icon: Icons.work_rounded,
            label: hasWork ? 'Go Work' : 'Set Work',
            color: Colors.blue,
            onTap: () async {
              if (hasWork) {
                _handleSelectDestination(workPlace.location);
              } else {
                final result = await context.push<AppLocation>('/map-picker');
                if (result != null && mounted) {
                  ref.read(savedPlacesProvider.notifier).addPlace(
                    SavedPlace(
                      title: 'Work',
                      subtitle: result.formattedAddress,
                      location: result,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Work address saved!'), backgroundColor: AppColors.primaryGreen),
                  );
                }
              }
            },
          ),
          _buildQuickActionChip(
            icon: Icons.bookmark_add_rounded,
            label: 'Saved Places',
            color: Colors.purple,
            onTap: () {
              // Navigate to profile screen where saved places are managed
              context.push('/profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlaceItem(SavedPlace place) {
    final String labelText = place.title.toUpperCase();
    final Color badgeBgColor;
    final IconData placeIcon;
    final Color iconColor;

    if (labelText == 'WORK') {
      badgeBgColor = Colors.blue.shade600;
      placeIcon = Icons.work_outline_rounded;
      iconColor = Colors.blue;
    } else if (labelText == 'HOME') {
      badgeBgColor = Colors.green.shade600;
      placeIcon = Icons.home_outlined;
      iconColor = Colors.green;
    } else {
      badgeBgColor = Colors.purple.shade600;
      placeIcon = Icons.star_outline_rounded;
      iconColor = Colors.purple;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _handleSelectDestination(place.location);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(placeIcon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          place.title, 
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBgColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeBgColor.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          labelText,
                          style: AppTextStyles.caption.copyWith(
                            color: badgeBgColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(place.subtitle ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPlaceItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final currentLocationAsync = ref.watch(locationStreamProvider);
    final savedPlaces = ref.watch(savedPlacesProvider);
    
    final currentPickup = locationState.pickup ?? currentLocationAsync.value;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
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
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        title: Text('Quick Book', style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Location (Pickup)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Location', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            currentPickup?.shortAddress ?? 'Fetching location...',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text('Where to?', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary))
                  .animate().fade(delay: 50.ms, duration: 300.ms),
            ),

            // Saved and Recent Places
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 4),
                  // Quick Actions Row
                  _buildQuickActionsRow(savedPlaces)
                      .animate()
                      .fade(delay: 80.ms, duration: 350.ms)
                      .slideX(begin: 0.05, end: 0),

                  // Swipeable Promotional Carousel
                  _buildPromoCarousel()
                      .animate()
                      .fade(delay: 120.ms, duration: 400.ms)
                      .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), curve: Curves.easeOutCubic),
                  
                  const SizedBox(height: 24),

                  if (savedPlaces.isNotEmpty) ...[
                    Text('Saved Places', style: AppTextStyles.h3)
                        .animate().fade(delay: 150.ms, duration: 300.ms),
                    const SizedBox(height: 12),
                    ...savedPlaces.asMap().entries.map((entry) {
                      final index = entry.key;
                      final place = entry.value;
                      return _buildSavedPlaceItem(place)
                          .animate()
                          .fade(delay: (200 + index * 50).ms, duration: 300.ms)
                          .slideY(begin: 0.05, end: 0);
                    }),
                    const SizedBox(height: 16),
                  ],
                  
                  Text('Recent Places', style: AppTextStyles.h3)
                      .animate().fade(delay: 250.ms, duration: 300.ms),
                  const SizedBox(height: 12),
                  
                  _buildRecentPlaceItem(
                    title: 'Central Station',
                    subtitle: 'Park Town, Chennai',
                    icon: Icons.history_rounded,
                    iconColor: AppColors.textSecondary,
                    onTap: () {
                      _handleSelectDestination(AppLocation(
                        latitude: 13.0827,
                        longitude: 80.2707,
                        shortAddress: 'Central Station',
                        formattedAddress: 'Park Town, Chennai',
                      ));
                    },
                  ).animate().fade(delay: 300.ms, duration: 350.ms).slideY(begin: 0.05, end: 0),
                  
                  _buildRecentPlaceItem(
                    title: 'Airport',
                    subtitle: 'Meenambakkam, Chennai',
                    icon: Icons.history_rounded,
                    iconColor: AppColors.textSecondary,
                    onTap: () {
                      _handleSelectDestination(AppLocation(
                        latitude: 12.9716,
                        longitude: 80.1898,
                        shortAddress: 'Airport',
                        formattedAddress: 'Meenambakkam, Chennai',
                      ));
                    },
                  ).animate().fade(delay: 350.ms, duration: 350.ms).slideY(begin: 0.05, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _PromoData {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;

  _PromoData({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.gradient,
  });
}
