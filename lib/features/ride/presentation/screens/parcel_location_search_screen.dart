import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../map/domain/entities/app_location.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../../map/presentation/providers/map_repository_provider.dart';

class ParcelLocationSearchScreen extends ConsumerStatefulWidget {
  final bool isPickup;
  
  const ParcelLocationSearchScreen({super.key, required this.isPickup});

  @override
  ConsumerState<ParcelLocationSearchScreen> createState() => _ParcelLocationSearchScreenState();
}

class _ParcelLocationSearchScreenState extends ConsumerState<ParcelLocationSearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  bool _isSearching = false;
  List<AppLocation> _results = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
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

  void _handleSelectPlace(AppLocation place) {
    if (widget.isPickup) {
      ref.read(locationProvider.notifier).setPickup(place);
      if (ref.read(locationProvider).destination == null) {
        context.pushReplacement('/parcel-location-search', extra: false);
        return;
      }
    } else {
      ref.read(locationProvider.notifier).setDestination(place);
      if (ref.read(locationProvider).pickup == null) {
        context.pushReplacement('/parcel-location-search', extra: true);
        return;
      }
    }
    context.pop();
  }

  void _handleLocateOnMap() async {
    final result = await context.push<AppLocation>('/map-picker', extra: widget.isPickup);
    if (result != null && mounted) {
      _handleSelectPlace(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isPickup ? 'Pick-up location' : 'Deliver-to location', style: AppTextStyles.h3),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.isPickup ? AppColors.primaryGreen : Colors.red,
                      shape: BoxShape.circle
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search for an address or landmark',
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
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: Icon(Icons.cancel, color: AppColors.textSecondary, size: 20),
                    ),
                ],
              ),
            ),
          ),
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
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final place = _results[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.grey),
                  title: Text(place.shortAddress ?? '', style: AppTextStyles.bodyMedium),
                  subtitle: Text(place.formattedAddress ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => _handleSelectPlace(place),
                ).animate().fade(delay: (index * 20).ms).slideX(begin: 0.1, end: 0);
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
              onTap: _handleLocateOnMap,
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
    );
  }
}
