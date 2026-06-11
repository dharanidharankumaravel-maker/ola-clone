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
  const DestinationSearchScreen({super.key, this.isPickup = false});

  @override
  ConsumerState<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends ConsumerState<DestinationSearchScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<AppLocation> _results = [];
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().length < 2) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
        return;
      }

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
    // Nominatim provides lat/lng in the search response, so we don't need a separate details API call
    if (widget.isPickup) {
      ref.read(locationProvider.notifier).setPickup(place);
      final dest = ref.read(locationProvider).destination;
      if (dest != null) {
        context.replace('/ride-selection');
      } else {
        context.pop();
      }
    } else {
      ref.read(locationProvider.notifier).setDestination(place);
      final pickup = ref.read(locationProvider).pickup;
      if (pickup != null) {
        context.replace('/ride-selection');
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationAsync = ref.watch(currentLocationProvider);
    
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: widget.isPickup ? 'Search pickup location...' : 'Search destination...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              child: const Icon(Icons.cancel, color: AppColors.textSecondary, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading state
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                    ),
                    SizedBox(width: 12),
                    Text('Searching...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),

            // Results List
            Expanded(
              child: _searchController.text.isEmpty
                  ? Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.my_location, color: AppColors.primaryGreen, size: 20),
                          ),
                          title: Text('Current Location', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(currentLocationAsync.value?.shortAddress ?? 'Fetching...', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          onTap: () {
                            if (currentLocationAsync.value != null) {
                              _handleSelectPlace(currentLocationAsync.value!);
                            }
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search, size: 48, color: AppColors.border),
                                const SizedBox(height: 16),
                                Text(widget.isPickup ? 'Search for a pickup location' : 'Search for a destination', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
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
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                          ),
                          title: Text(place.shortAddress ?? '', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(place.formattedAddress ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          onTap: () => _handleSelectPlace(place),
                        ).animate().fade(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
