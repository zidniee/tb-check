import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/hospital_dto.dart';
import '../providers/hospital_provider.dart';
import '../widgets/hospital_card.dart';

class HospitalListPage extends StatefulWidget {
  const HospitalListPage({super.key});

  @override
  State<HospitalListPage> createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedHospitalId;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _cardKeys = {};

  // Default coordinate: Jakarta, Indonesia
  static const LatLng _defaultCenter = LatLng(-6.208763, 106.845599);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HospitalProvider>(context, listen: false);
      provider.fetchHospitals().then((_) {
        provider.determinePositionAndSort().then((success) {
          if (success && provider.userPosition != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(
                  provider.userPosition!.latitude,
                  provider.userPosition!.longitude,
                ),
                13.0,
              ),
            );
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onHospitalTap(HospitalDTO hospital) {
    setState(() {
      _selectedHospitalId = hospital.hospitalId;
    });

    // Move Map Camera
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(hospital.latitude, hospital.longitude),
        15.0,
      ),
    );

    // Scroll to the card
    final key = _cardKeys[hospital.hospitalId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HospitalProvider>(context);

    // Create Map Markers
    final Set<Marker> markers = provider.filteredHospitals.map((hospital) {
      final isSelected = hospital.hospitalId == _selectedHospitalId;
      return Marker(
        markerId: MarkerId(hospital.hospitalId),
        position: LatLng(hospital.latitude, hospital.longitude),
        infoWindow: InfoWindow(
          title: hospital.hospitalName,
          snippet: hospital.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          _onHospitalTap(hospital);
        },
      );
    }).toSet();

    // Map Center Location
    LatLng initialCenter = _defaultCenter;
    if (provider.userPosition != null) {
      initialCenter = LatLng(
        provider.userPosition!.latitude,
        provider.userPosition!.longitude,
      );
    } else if (provider.filteredHospitals.isNotEmpty) {
      initialCenter = LatLng(
        provider.filteredHospitals.first.latitude,
        provider.filteredHospitals.first.longitude,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Rumah Sakit Mitra',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 1. Peta Google Maps (40% height)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: initialCenter,
                    zoom: provider.userPosition != null ? 13.0 : 10.0,
                  ),
                  markers: markers,
                  myLocationEnabled: provider.userPosition != null,
                  myLocationButtonEnabled: false, // Customized button instead
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                ),
                // Floating search bar or map utilities
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'my_location_btn',
                    mini: true,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: () async {
                      final success = await provider.determinePositionAndSort();
                      if (success && provider.userPosition != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(
                              provider.userPosition!.latitude,
                              provider.userPosition!.longitude,
                            ),
                            14.0,
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),

          // 2. Search & List Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Drag indicator handle for visual aesthetic
                  const SizedBox(height: 12),
                  Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: provider.searchHospitals,
                      decoration: InputDecoration(
                        hintText: 'Cari Rumah Sakit...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.searchHospitals('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info message / error banner if any
                  if (provider.errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Hospital List
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.filteredHospitals.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada rumah sakit mitra ditemukan.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 4),
                                itemCount: provider.filteredHospitals.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final hospital = provider.filteredHospitals[index];
                                  
                                  // Assign GlobalKey if not already present
                                  _cardKeys.putIfAbsent(hospital.hospitalId, () => GlobalKey());
                                  
                                  final isSelected = hospital.hospitalId == _selectedHospitalId;
                                  final distanceStr = provider.getFormattedDistance(hospital.hospitalId);

                                  return Container(
                                    key: _cardKeys[hospital.hospitalId],
                                    child: HospitalCard(
                                      hospital: hospital,
                                      distanceStr: distanceStr,
                                      isSelected: isSelected,
                                      onTap: () => _onHospitalTap(hospital),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
