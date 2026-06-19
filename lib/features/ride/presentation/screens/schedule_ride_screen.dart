import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_option.dart';
import '../providers/ride_provider.dart';

class ScheduleRideScreen extends ConsumerStatefulWidget {
  const ScheduleRideScreen({super.key});

  @override
  ConsumerState<ScheduleRideScreen> createState() => _ScheduleRideScreenState();
}

class _ScheduleRideScreenState extends ConsumerState<ScheduleRideScreen> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;

  final List<DateTime> _dates = [];
  final List<int> _hours = List.generate(24, (i) => i);
  final List<int> _minutes = [0, 15, 30, 45];
  bool _isScheduling = false;
  
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _dates.add(DateTime(now.year, now.month, now.day).add(Duration(days: i)));
    }
    _selectedDate = _dates[0];
    
    final minDate = now.add(const Duration(minutes: 30));
    _selectedHour = minDate.hour;
    _selectedMinute = _minutes.firstWhere((m) => m >= minDate.minute, orElse: () => 0);
    
    _hourController = FixedExtentScrollController(initialItem: _hours.indexOf(_selectedHour));
    _minuteController = FixedExtentScrollController(initialItem: _minutes.indexOf(_selectedMinute));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  bool _isValidTime() {
    final now = DateTime.now();
    final minDate = now.add(const Duration(minutes: 30));
    final maxDate = now.add(const Duration(days: 7));
    
    final scheduled = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
    
    return scheduled.isAfter(minDate) && scheduled.isBefore(maxDate);
  }

  String _dayLabel(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    }
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return DateFormat('E, d MMM').format(date);
  }

  void _handleSchedule() {
    if (!_isValidTime()) return;
    
    setState(() => _isScheduling = true);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isScheduling = false);
      
      final locationState = ref.read(locationProvider);
      final pickup = locationState.pickup;
      final destination = locationState.destination;
      
      if (pickup != null && destination != null) {
        final scheduled = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedHour,
          _selectedMinute,
        );
        
        final mockRide = Ride(
          id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'usr_1',
          status: 'scheduled',
          pickup: pickup,
          destination: destination,
          distance: 5.0,
          duration: 15,
          rideType: 'mini',
          fareEstimate: FareEstimate(
            baseFare: 50,
            distanceFare: 60,
            timeFare: 15,
            surgeMultiplier: 1,
            total: 125,
            currency: 'INR',
            distance: 5.0,
            duration: 15,
          ),
          paymentMethod: 'cash',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          scheduledAt: scheduled.toIso8601String(),
        );
        
        ref.read(scheduledRidesProvider.notifier).scheduleRide(mockRide);
      }
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 28),
              SizedBox(width: 12),
              Text('Ride Scheduled'),
            ],
          ),
          content: Text('Your ride is scheduled successfully for ${_dayLabel(_selectedDate)} at ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/');
              },
              child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTipBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.12),
            Colors.blue.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule_send_rounded, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skip Peak Hour Surcharges',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lock in your bookings in advance to secure standard rates and guarantee dispatch.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final pickup = locationState.pickup;
    final destination = locationState.destination;

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
        title: Text('Schedule Ride', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.all(20),
              children: [
                _buildTipBanner()
                    .animate()
                    .fade(duration: 400.ms)
                    .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                
                // Address Routing Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(pickup?.shortAddress ?? 'Pickup not set', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                        ],
                      ),
                      Container(
                        height: 24,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: AppColors.border, width: 1.5, style: BorderStyle.solid)),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(destination?.shortAddress ?? 'Destination not set', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: 28),
                
                Text('Select Date', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))
                    .animate().fade(delay: 150.ms, duration: 300.ms),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final date = _dates[index];
                      final isSelected = date == _selectedDate;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: isSelected ? 1.5 : 1.0),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _dayLabel(date),
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fade(delay: 200.ms, duration: 400.ms).slideX(begin: 0.05, end: 0),
                const SizedBox(height: 28),

                Text('Select Time', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))
                    .animate().fade(delay: 250.ms, duration: 300.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimePicker('Hour', _hours, _selectedHour, _hourController, (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedHour = v);
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300, color: AppColors.primaryGreen)),
                    ),
                    _buildTimePicker('Min', _minutes, _selectedMinute, _minuteController, (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMinute = v);
                    }),
                  ],
                ).animate().fade(delay: 300.ms, duration: 500.ms).scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
                const SizedBox(height: 28),

                // Booking info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryGreenLight.withOpacity(0.35), AppColors.primaryGreenLight.withOpacity(0.15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: AppColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RIDE DETAILS', style: AppTextStyles.caption.copyWith(color: AppColors.primaryGreen.withOpacity(0.85), fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            const SizedBox(height: 4),
                            Text(
                              '${_dayLabel(_selectedDate)}, ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(target: _isValidTime() ? 1.0 : 0.0)
                 .fade(duration: 300.ms)
                 .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack),
                
                if (!_isValidTime()) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Please select a time at least 30 minutes from now and within 7 days.',
                      style: AppTextStyles.caption.copyWith(color: Colors.red, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().shake(duration: 400.ms),
                ],
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: AppColors.border,
                      elevation: 2,
                    ),
                    onPressed: _isValidTime() && !_isScheduling ? _handleSchedule : null,
                    icon: _isScheduling
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Icon(Icons.calendar_month, size: 20),
                    label: Text(
                      _isScheduling ? 'Scheduling...' : 'Schedule Ride',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildTimePicker(String label, List<int> values, int selectedValue, FixedExtentScrollController controller, Function(int) onSelected) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 160,
              width: 90,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 44,
                perspective: 0.006,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) => onSelected(values[index]),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: values.length,
                  builder: (context, index) {
                    final value = values[index];
                    final isSelected = value == selectedValue;
                    return Center(
                      child: Text(
                        value.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 26 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                        ),
                      ).animate(target: isSelected ? 1 : 0)
                       .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 150.ms),
                    );
                  },
                ),
              ),
            ),
            
            // Picker Central Highlight Line Overlay
            IgnorePointer(
              child: Container(
                height: 44,
                width: 90,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3), width: 1.5),
                  ),
                ),
              ),
            ),
            
            // Top and Bottom 3D Gradient Mask Overlay
            IgnorePointer(
              child: Container(
                height: 160,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bgCard.withOpacity(0.9),
                      AppColors.bgCard.withOpacity(0.0),
                      AppColors.bgCard.withOpacity(0.0),
                      AppColors.bgCard.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.25, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
