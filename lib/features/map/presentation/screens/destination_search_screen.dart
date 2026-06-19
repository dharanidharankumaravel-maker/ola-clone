import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/app_location.dart';
import '../providers/location_provider.dart';
import '../providers/map_repository_provider.dart';
import 'dart:async';

class DestinationSearchScreen extends ConsumerStatefulWidget {
  final bool isPickup;
  final String? returnRoute;
  final bool returnLocation;
  const DestinationSearchScreen({super.key, this.isPickup = false, this.returnRoute, this.returnLocation = false});

  @override
  ConsumerState<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends ConsumerState<DestinationSearchScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _pickupFocus = FocusNode();
  final _destinationFocus = FocusNode();

  bool _isSearching = false;
  List<AppLocation> _results = [];
  Timer? _debounce;
  bool _isEditingPickup = false;

  @override
  void initState() {
    super.initState();
    _pickupFocus.addListener(() {
      if (_pickupFocus.hasFocus) {
        setState(() {
          _isEditingPickup = true;
          _results = [];
        });
        _onSearchChanged(_pickupController.text);
      }
    });

    _destinationFocus.addListener(() {
      if (_destinationFocus.hasFocus) {
        setState(() {
          _isEditingPickup = false;
          _results = [];
        });
        _onSearchChanged(_destinationController.text);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationState = ref.read(locationProvider);
      final currentLocAsync = ref.read(currentLocationProvider);
      
      _pickupController.text = locationState.pickup?.shortAddress ?? currentLocAsync.value?.shortAddress ?? 'Current Location';
      _destinationController.text = locationState.destination?.shortAddress ?? '';

      if (widget.isPickup) {
        _pickupFocus.requestFocus();
      } else {
        _destinationFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocus.dispose();
    _destinationFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // If not actively searching or too short, show empty results or default suggestions
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      try {
        final repo = ref.read(mapRepositoryProvider);
        final locations = await repo.searchLocations(query);
        if (!mounted) return;
        setState(() {
          _results = locations;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _handleSelectPlace(AppLocation place) async {
    if (_isEditingPickup) {
      ref.read(locationProvider.notifier).setPickup(place);
      _pickupController.text = place.shortAddress ?? '';
      _destinationFocus.requestFocus();
    } else {
      ref.read(locationProvider.notifier).setDestination(place);
      _destinationController.text = place.shortAddress ?? '';
      
      // If we selected destination, make sure we have a pickup
      final pickup = ref.read(locationProvider).pickup;
      if (pickup == null) {
        final currentLoc = ref.read(currentLocationProvider).value;
        if (currentLoc != null) {
          ref.read(locationProvider.notifier).setPickup(currentLoc);
        } else {
          _pickupFocus.requestFocus();
          return;
        }
      }
      
      if (widget.returnLocation) {
        context.pop(place);
        return;
      }
      
      if (widget.returnRoute != null) {
        context.pop();
      } else {
        context.replace('/ride-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationAsync = ref.watch(currentLocationProvider);
    final savedPlaces = ref.watch(savedPlacesProvider);
    
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgSurface,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        // Pickup Field
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _isEditingPickup ? AppColors.primaryGreen : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _pickupController,
                                  focusNode: _pickupFocus,
                                  onChanged: _onSearchChanged,
                                  decoration: const InputDecoration(
                                    hintText: 'Current Location',
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_pickupController.text.isNotEmpty && _isEditingPickup)
                                GestureDetector(
                                  onTap: () {
                                    _pickupController.clear();
                                    _onSearchChanged('');
                                  },
                                  child: Icon(Icons.cancel, color: AppColors.textSecondary, size: 20),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Destination Field
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: !_isEditingPickup ? AppColors.primaryGreen : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _destinationController,
                                  focusNode: _destinationFocus,
                                  onChanged: _onSearchChanged,
                                  decoration: const InputDecoration(
                                    hintText: 'Search destination...',
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_destinationController.text.isNotEmpty && !_isEditingPickup)
                                GestureDetector(
                                  onTap: () {
                                    _destinationController.clear();
                                    _onSearchChanged('');
                                  },
                                  child: Icon(Icons.cancel, color: AppColors.textSecondary, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading state
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen)),
                    const SizedBox(width: 12),
                    Text('Searching...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),

            // Results List
            Expanded(
              child: (_isEditingPickup && _pickupController.text.isEmpty) || (!_isEditingPickup && _destinationController.text.isEmpty)
                  ? ListView(
                      children: [
                        if (_isEditingPickup)
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.primaryGreenLight, shape: BoxShape.circle),
                              child: Icon(Icons.my_location, color: AppColors.primaryGreen, size: 20),
                            ),
                            title: Text('Current Location', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(currentLocationAsync.value?.shortAddress ?? 'Fetching...', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            onTap: () {
                              if (currentLocationAsync.value != null) {
                                _handleSelectPlace(currentLocationAsync.value!);
                              }
                            },
                          ),
                        ...savedPlaces.map((place) {
                          final isHome = place.title.toLowerCase() == 'home';
                          final isWork = place.title.toLowerCase() == 'work';
                          final icon = isHome 
                              ? Icons.home_outlined 
                              : (isWork ? Icons.work_outline_rounded : Icons.bookmark_outline_rounded);
                          final iconColor = isHome 
                              ? Colors.green 
                              : (isWork ? Colors.blue : Colors.purple);
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: iconColor, size: 20),
                            ),
                            title: Text(place.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(place.subtitle ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            onTap: () => _handleSelectPlace(place.location),
                          );
                        }),
                        // Saved places or recent searches can go here
                        ListTile(
                          leading: Icon(Icons.history, color: AppColors.textSecondary),
                          title: const Text('Central Station'),
                          subtitle: Text('Park Town, Chennai', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          onTap: () => _handleSelectPlace(const AppLocation(latitude: 13.0827, longitude: 80.2707, shortAddress: 'Central Station', formattedAddress: 'Park Town, Chennai')),
                        ),
                        ListTile(
                          leading: Icon(Icons.history, color: AppColors.textSecondary),
                          title: const Text('Airport'),
                          subtitle: Text('Meenambakkam, Chennai', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          onTap: () => _handleSelectPlace(const AppLocation(latitude: 12.9716, longitude: 80.1898, shortAddress: 'Airport', formattedAddress: 'Meenambakkam, Chennai')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final place = _results[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.primaryGreenLight, shape: BoxShape.circle),
                            child: Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                          ),
                          title: Text(place.shortAddress ?? '', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(place.formattedAddress ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          onTap: () => _handleSelectPlace(place),
                        ).animate().fade(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: InkWell(
                onTap: () async {
                  final result = await context.push<AppLocation>('/map-picker', extra: widget.isPickup);
                  if (result != null && mounted) {
                    _handleSelectPlace(result);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Text('Locate on Map', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
