import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/presentation/providers/location_provider.dart';
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
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ride Scheduled'),
          content: Text('Your ride is scheduled for ${_dayLabel(_selectedDate)} at ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/');
              },
              child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final pickup = locationState.pickup;
    final destination = locationState.destination;

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Schedule Ride', style: AppTextStyles.h3),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(pickup?.shortAddress ?? 'Pickup not set', style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                      Container(
                        height: 20,
                        margin: const EdgeInsets.only(left: 4.5),
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: AppColors.border, width: 1.5)),
                        ),
                      ),
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(destination?.shortAddress ?? 'Destination not set', style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Text('Select Date', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final date = _dates[index];
                      final isSelected = date == _selectedDate;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = date),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreenLight : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _dayLabel(date),
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                Text('Select Time', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimePicker('Hour', _hours, _selectedHour, _hourController, (v) => setState(() => _selectedHour = v)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    _buildTimePicker('Min', _minutes, _selectedMinute, _minuteController, (v) => setState(() => _selectedMinute = v)),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreenLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scheduled for', style: AppTextStyles.caption.copyWith(color: AppColors.primaryGreen)),
                          Text(
                            '${_dayLabel(_selectedDate)}, ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!_isValidTime()) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Please select a time at least 30 minutes from now and within 7 days.',
                    style: AppTextStyles.caption.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: AppColors.bgSurface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: AppColors.border,
                    ),
                    onPressed: _isValidTime() && !_isScheduling ? _handleSchedule : null,
                    icon: _isScheduling
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.calendar_month),
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
    );
  }

  Widget _buildTimePicker(String label, List<int> values, int selectedValue, FixedExtentScrollController controller, Function(int) onSelected) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            perspective: 0.005,
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
                      fontSize: isSelected ? 24 : 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
