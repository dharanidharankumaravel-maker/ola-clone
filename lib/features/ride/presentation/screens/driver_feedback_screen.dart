import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  final List<String> _goodFeedback = [
    'Excellent Service',
    'Clean Car',
    'Polite Behavior',
    'Safe Driving',
    'Great Navigation'
  ];

  final List<String> _badFeedback = [
    'Late Arrival',
    'Unclean Car',
    'Rude Behavior',
    'Rash Driving',
    'Wrong Route'
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Clear the current ride
    ref.read(currentRideProvider.notifier).clearCurrentRide();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    // Go back to home
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final currentRide = ref.watch(currentRideProvider);
    final promoDiscount = ref.watch(promoDiscountProvider);

    // Fallback if accessed without a completed ride
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

    final finalFare = (currentRide.fareEstimate.total - promoDiscount).toStringAsFixed(0);
    final chipsToDisplay = _rating > 0 && _rating < 4 ? _badFeedback : _goodFeedback;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text('Trip Completed', style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
                const SizedBox(height: 16),
                
                // Fare Display
                Text('₹$finalFare', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Paid via ${currentRide.paymentMethod == 'cash' ? 'Cash' : 'Ola Money'}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                
                const SizedBox(height: 40),

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
                        child: const Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Text('How was your ride with ${currentRide.driver!.name}?', style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('${currentRide.driver!.vehicleModel} • ${currentRide.driver!.vehicleNumber}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      
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
                  Text('What did you like?', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
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
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add an optional comment...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
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
                  onPressed: _rating > 0 ? _handleSubmit : null,
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
                
                if (_rating == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextButton(
                      onPressed: _handleSubmit,
                      child: Text('Skip for now', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
