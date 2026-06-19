import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../providers/ride_provider.dart';

class DriverFeedbackScreen extends ConsumerStatefulWidget {
  const DriverFeedbackScreen({super.key});

  @override
  ConsumerState<DriverFeedbackScreen> createState() => _DriverFeedbackScreenState();
}

class _DriverFeedbackScreenState extends ConsumerState<DriverFeedbackScreen> {
  int _rating = 0;
  final Set<String> _selectedChips = {};
  final TextEditingController _commentController = TextEditingController();
  bool _showFareBreakdown = false;

  final List<String> _rideGoodFeedback = [
    'Polite & Professional Driver',
    'Safe & Smooth Driving',
    'Clean Vehicle',
    'Excellent Overall Ride',
  ];

  final List<String> _rideBadFeedback = [
    'Rude/Unprofessional Driver',
    'Rash/Unsafe Driving',
    'Unclean Vehicle',
    'Unsatisfactory Overall Ride',
  ];

  final List<String> _parcelGoodFeedback = [
    'Quick & Timely Delivery',
    'Safe Parcel Handling',
    'Smooth Pickup & Drop-off',
    'Good Communication',
    'Excellent Overall Delivery',
  ];

  final List<String> _parcelBadFeedback = [
    'Delayed Delivery',
    'Careless Parcel Handling',
    'Difficult Pickup/Drop-off',
    'Poor Communication',
    'Unsatisfactory Overall Delivery',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final currentRide = ref.read(currentRideProvider);
    final promoDiscount = ref.read(promoDiscountProvider);
    
    if (currentRide != null) {
      final double baseTotal = currentRide.fareEstimate.total - promoDiscount;
      final double finalFare = baseTotal + (currentRide.tipAmount ?? 0.0);

      ref.read(currentRideProvider.notifier).clearCurrentRide();
      
      // Reset the booking state for the next ride
      ref.read(locationProvider.notifier).clearDestination();
      ref.read(selectedRideTypeProvider.notifier).update(null);
      ref.read(selectedRideCategoryProvider.notifier).update('daily'); // Reset to default home category
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final currentRide = ref.watch(currentRideProvider);
    final promoDiscount = ref.watch(promoDiscountProvider);

    if (currentRide == null || currentRide.driver == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Feedback')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Back to Home'),
          ),
        ),
      );
    }

    final double tip = currentRide.tipAmount ?? 0.0;
    final double baseTotal = currentRide.fareEstimate.total - promoDiscount;
    final double finalFare = baseTotal + tip;
    final isParcel = currentRide.rideType == 'parcel';
    final goodFeedback = isParcel ? _parcelGoodFeedback : _rideGoodFeedback;
    final badFeedback = isParcel ? _parcelBadFeedback : _rideBadFeedback;
    final chipsToDisplay = _rating > 0 && _rating < 4 ? badFeedback : goodFeedback;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                 Text(
                  isParcel ? 'Delivery Completed' : 'Trip Completed',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 16),
                
                // Final Fare
                Text('₹${finalFare.toStringAsFixed(0)}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('Paid via ${currentRide.paymentMethod == 'cash' ? 'Cash' : 'Alo Money'}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                
                const SizedBox(height: 16),
                
                // Fare Breakdown Toggle
                GestureDetector(
                  onTap: () => setState(() => _showFareBreakdown = !_showFareBreakdown),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fare Breakdown', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGreen)),
                      Icon(_showFareBreakdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
                
                // Expandable Fare Breakdown
                if (_showFareBreakdown)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildBreakdownRow('Base Fare', '₹${currentRide.fareEstimate.baseFare.toStringAsFixed(0)}'),
                        _buildBreakdownRow('Distance Charge', '₹${currentRide.fareEstimate.distanceFare.toStringAsFixed(0)}'),
                        _buildBreakdownRow('Time Charge', '₹${currentRide.fareEstimate.timeFare.toStringAsFixed(0)}'),
                        if (promoDiscount > 0)
                          _buildBreakdownRow('Promo Applied', '-₹${promoDiscount.toStringAsFixed(0)}', isDiscount: true),
                        if (tip > 0)
                          _buildBreakdownRow('Tip Amount', '₹${tip.toStringAsFixed(0)}', isHighlight: true),
                        Divider(color: AppColors.border, height: 24),
                        _buildBreakdownRow('Final Payable Amount', '₹${finalFare.toStringAsFixed(0)}', isTotal: true),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 32),

                // Driver Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGreen, width: 2),
                        ),
                        child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isParcel
                            ? 'How was your delivery with ${currentRide.driver!.name}?'
                            : 'How was your ride with ${currentRide.driver!.name}?',
                        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isParcel
                            ? 'Delivery Partner • ${currentRide.driver!.vehicleModel} • ${currentRide.driver!.vehicleNumber}'
                            : '${currentRide.driver!.vehicleModel} • ${currentRide.driver!.vehicleNumber}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Star Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                                _selectedChips.clear();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(
                                index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 40,
                                color: index < _rating ? Colors.amber : AppColors.textSecondary,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                if (_rating > 0) ...[
                  const SizedBox(height: 32),
                  Text(
                    _rating < 4
                        ? (isParcel ? 'What went wrong with the delivery?' : 'What went wrong with the ride?')
                        : (isParcel ? 'What did you like about the delivery?' : 'What did you like about the ride?'),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  
                  // Feedback Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: chipsToDisplay.map((chipLabel) {
                      final isSelected = _selectedChips.contains(chipLabel);
                      return ChoiceChip(
                        label: Text(chipLabel),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedChips.add(chipLabel);
                            } else {
                              _selectedChips.remove(chipLabel);
                            }
                          });
                        },
                        selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                        backgroundColor: AppColors.bgCard,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryGreen : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  
                  // Comment Text Field
                  TextField(
                    controller: _commentController,
                    style: TextStyle(color: AppColors.textPrimary),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add an optional comment...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _rating > 0 && _selectedChips.isNotEmpty ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppColors.bgCard,
                    disabledForegroundColor: AppColors.textSecondary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildBreakdownRow(String label, String value, {bool isDiscount = false, bool isHighlight = false, bool isTotal = false}) {
    Color color = AppColors.textPrimary;
    if (isDiscount) color = AppColors.primaryGreen;
    if (isHighlight) color = Colors.amber;
    if (isTotal) color = AppColors.primaryGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          )),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: isTotal || isHighlight ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}
