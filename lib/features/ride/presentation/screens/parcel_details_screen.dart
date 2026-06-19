import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/ride_option.dart';
import '../../domain/entities/ride.dart';
import '../providers/ride_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../map/presentation/providers/location_provider.dart';
import '../../../map/presentation/providers/map_repository_provider.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ParcelDetailsScreen extends ConsumerStatefulWidget {
  final String category;

  const ParcelDetailsScreen({super.key, required this.category});

  @override
  ConsumerState<ParcelDetailsScreen> createState() => _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends ConsumerState<ParcelDetailsScreen> {
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _contentsController = TextEditingController();

  List<File> _parcelImages = [];
  File? _parcelVideo;
  final _imagePicker = ImagePicker();

  String _weight = 'upto_5';
  bool _touchedSenderName = false;
  bool _touchedSenderPhone = false;
  bool _touchedReceiverName = false;
  bool _touchedReceiverPhone = false;

  double _distanceKm = 5.2;
  int _durationMins = 15;
  bool _isEstimating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillDetails();
      _calculateFare();
    });
  }

  void _prefillDetails() {
    final user = ref.read(authProvider).value;
    final flowType = ref.read(parcelFlowTypeProvider) ?? 'send';
    
    if (user != null) {
      if (flowType == 'send') {
        _senderNameController.text = user.name ?? '';
        _senderPhoneController.text = user.phone;
      } else {
        _receiverNameController.text = user.name ?? '';
        _receiverPhoneController.text = user.phone;
      }
      setState(() {});
    }
  }

  Future<void> _calculateFare() async {
    final locationState = ref.read(locationProvider);
    final pickup = locationState.pickup;
    final destination = locationState.destination;
    
    if (pickup != null && destination != null) {
      final repo = ref.read(mapRepositoryProvider);
      final points = await repo.getRoutePolylines(
        LatLng(pickup.latitude, pickup.longitude),
        LatLng(destination.latitude, destination.longitude),
      );
      
      if (mounted) {
        double totalMeters = 0;
        final distanceCalc = const Distance();
        for (int i = 0; i < points.length - 1; i++) {
          totalMeters += distanceCalc.distance(points[i], points[i+1]);
        }
        _distanceKm = (totalMeters > 0 ? (totalMeters * 1.2) / 1000 : 5.2).clamp(1.0, 500.0);
        _durationMins = (_distanceKm * 3.5).ceil();
        setState(() {
          _isEstimating = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isEstimating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  bool get _isSenderNameValid => _senderNameController.text.trim().isNotEmpty;
  bool get _isSenderPhoneValid => _senderPhoneController.text.trim().length >= 10;
  bool get _isReceiverNameValid => _receiverNameController.text.trim().isNotEmpty;
  bool get _isReceiverPhoneValid => _receiverPhoneController.text.trim().length >= 10;
  
  bool get _isFormValid => _isSenderNameValid && _isSenderPhoneValid && _isReceiverNameValid && _isReceiverPhoneValid && !_isEstimating;

  void _handleConfirm() {
    if (!_isFormValid) return;
    
    final flowType = ref.read(parcelFlowTypeProvider) ?? 'send';
    
    // Save parcel details globally
    ref.read(parcelDetailsProvider.notifier).update(
      ParcelDetails(
        type: flowType,
        senderName: _senderNameController.text.trim(),
        senderPhone: _senderPhoneController.text.trim(),
        receiverName: _receiverNameController.text.trim(),
        receiverPhone: _receiverPhoneController.text.trim(),
        contents: _contentsController.text.trim().isNotEmpty ? '${widget.category} - ${_contentsController.text.trim()}' : widget.category,
        weightCategory: _weight,
        imagePaths: _parcelImages.isEmpty ? null : _parcelImages.map((e) => e.path).toList(),
        videoPath: _parcelVideo?.path,
      )
    );
    
    // Calculate final fare
    double baseFare = 40;
    double distanceFare = _distanceKm * 15;
    double totalFare = baseFare + distanceFare;

    const iconPath = 'assets/parcel.svg';

    // Provide the dynamic option
    ref.read(rideOptionsProvider.notifier).update([
      RideOption(
        type: 'parcel',
        name: 'Alo Parcel',
        description: 'Package delivery service',
        icon: iconPath,
        seats: 1,
        available: true,
        eta: 5,
        fareEstimate: FareEstimate(
          baseFare: baseFare,
          distanceFare: distanceFare,
          timeFare: 0,
          surgeMultiplier: 1,
          total: totalFare,
          currency: 'INR',
          distance: _distanceKm,
          duration: _durationMins,
        ),
      )
    ]);

    ref.read(selectedRideTypeProvider.notifier).update('parcel');
    context.push('/driver-search');
  }

  @override
  Widget build(BuildContext context) {
    double baseFare = 40;
    double distanceFare = _distanceKm * 15;
    double totalFare = baseFare + distanceFare;

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
        title: Text('Parcel Details', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Sender Details', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _senderNameController,
                  hint: 'Sender Name',
                  icon: Icons.person_outline,
                  errorText: _touchedSenderName && !_isSenderNameValid ? "Please enter sender's name" : null,
                  onChanged: (v) => setState(() {}),
                  onFocusLost: () => setState(() => _touchedSenderName = true),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _senderPhoneController,
                  hint: 'Sender Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  errorText: _touchedSenderPhone && !_isSenderPhoneValid ? "Please enter a valid 10-digit number" : null,
                  onChanged: (v) => setState(() {}),
                  onFocusLost: () => setState(() => _touchedSenderPhone = true),
                ),
                const SizedBox(height: 32),

                Text('Receiver Details', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _receiverNameController,
                  hint: 'Receiver Name',
                  icon: Icons.person_outline,
                  errorText: _touchedReceiverName && !_isReceiverNameValid ? "Please enter receiver's name" : null,
                  onChanged: (v) => setState(() {}),
                  onFocusLost: () => setState(() => _touchedReceiverName = true),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _receiverPhoneController,
                  hint: 'Receiver Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  errorText: _touchedReceiverPhone && !_isReceiverPhoneValid ? "Please enter a valid 10-digit number" : null,
                  onChanged: (v) => setState(() {}),
                  onFocusLost: () => setState(() => _touchedReceiverPhone = true),
                ),
                const SizedBox(height: 32),

                Text('Parcel Information (${widget.category})', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contentsController,
                  hint: 'Additional Notes (Optional)',
                  icon: Icons.inventory_2_outlined,
                  onChanged: (v) => setState(() {}),
                  onFocusLost: () {},
                ),
                const SizedBox(height: 24),

                Text('Approximate Weight', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _weight = 'upto_5'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _weight == 'upto_5' ? AppColors.primaryGreenLight : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _weight == 'upto_5' ? AppColors.primaryGreen : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('Up to 5 kg', style: AppTextStyles.bodyMedium.copyWith(color: _weight == 'upto_5' ? AppColors.primaryGreen : AppColors.textPrimary, fontWeight: _weight == 'upto_5' ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _weight = '5_15'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _weight == '5_15' ? AppColors.primaryGreenLight : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _weight == '5_15' ? AppColors.primaryGreen : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('5 - 15 kg', style: AppTextStyles.bodyMedium.copyWith(color: _weight == '5_15' ? AppColors.primaryGreen : AppColors.textPrimary, fontWeight: _weight == '5_15' ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildMediaSection(),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Do not send cash, jewelry, or prohibited items. Driver may verify the contents before pickup.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Bar with Fare Estimate
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimated Fare', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        _isEstimating
                            ? Container(width: 60, height: 24, color: AppColors.border).animate(onPlay: (c) => c.repeat()).shimmer()
                            : Text('₹${totalFare.toStringAsFixed(0)}', style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Distance', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        _isEstimating
                            ? Container(width: 40, height: 20, color: AppColors.border).animate(onPlay: (c) => c.repeat()).shimmer()
                            : Text('${_distanceKm.toStringAsFixed(1)} km', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Confirm Booking',
                  onPressed: _isFormValid ? _handleConfirm : null,
                  disabled: !_isFormValid,
                  isLoading: _isEstimating,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    int? maxLength,
    required ValueChanged<String> onChanged,
    required VoidCallback onFocusLost,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) onFocusLost();
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen),
          ),
          errorText: errorText,
          counterText: '',
          filled: true,
          fillColor: AppColors.bgSurface,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _pickMedia(bool isVideo, ImageSource source) async {
    if (isVideo) {
      final pickedFile = await _imagePicker.pickVideo(source: source);
      if (pickedFile != null) {
        setState(() => _parcelVideo = File(pickedFile.path));
      }
    } else {
      if (_parcelImages.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 photos allowed')));
        return;
      }
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _parcelImages.add(File(pickedFile.path)));
      }
    }
  }

  void _showMediaPicker(bool isVideo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isVideo ? 'Upload Video' : 'Upload Photo', style: AppTextStyles.h3),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                context.pop();
                _pickMedia(isVideo, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                context.pop();
                _pickMedia(isVideo, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parcel Media (Optional)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMediaButton(
              title: 'Add Photo',
              icon: Icons.camera_alt_outlined,
              onTap: () => _showMediaPicker(false),
            ),
            const SizedBox(width: 16),
            _buildMediaButton(
              title: 'Add Video',
              icon: Icons.videocam_outlined,
              onTap: () => _showMediaPicker(true),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_parcelImages.isNotEmpty || _parcelVideo != null) ...[
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ..._parcelImages.asMap().entries.map((e) => _buildMediaPreview(false, e.value, index: e.key)),
              if (_parcelVideo != null) _buildMediaPreview(true, _parcelVideo!),
            ],
          ),
          const SizedBox(height: 24),
        ]
      ],
    );
  }

  Widget _buildMediaButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 28),
              const SizedBox(height: 8),
              Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(bool isVideo, File file, {int? index}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo
                ? Container(
                    color: Colors.black12,
                    child: const Icon(Icons.play_circle_outline, size: 40, color: Colors.black54),
                  )
                : Image.file(file, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() {
                if (isVideo) _parcelVideo = null;
                else if (index != null) _parcelImages.removeAt(index);
              }),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
