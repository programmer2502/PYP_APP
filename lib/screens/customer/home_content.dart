import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../providers/pyp_store.dart';
import '../../services/location_service.dart';
import '../../widgets/customer/category_card.dart';
import '../../widgets/customer/photographer_card.dart';
import 'photographer_details_screen.dart';
import 'search_screen.dart';
import '../shared/notifications_screen.dart';

class HomeContent extends StatefulWidget {
  final PypStore store;

  const HomeContent({
    super.key,
    required this.store,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Active Filter State
  String _selectedServiceType = 'All'; // 'All', 'Photographer', 'Videographer'
  DateTime? _selectedDate;
  String? _selectedLocation; // null means use store location or All
  double? _selectedMaxBudget; // null means any budget
  String? _selectedCategory; // null means all categories

  @override
  void initState() {
    super.initState();
    // Default location to current detected city if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.store.currentLocation == null) {
        widget.store.detectLocation(promptPermission: false);
      }
    });
  }

  bool get _hasActiveFilters =>
      _selectedServiceType != 'All' ||
      _selectedDate != null ||
      (_selectedLocation != null &&
          _selectedLocation!.isNotEmpty &&
          _selectedLocation != 'All') ||
      _selectedMaxBudget != null ||
      _selectedCategory != null;

  void _resetFilters() {
    setState(() {
      _selectedServiceType = 'All';
      _selectedDate = null;
      _selectedLocation = null;
      _selectedMaxBudget = null;
      _selectedCategory = null;
    });
  }

  List<PhotographerModel> _getFilteredCreatives() {
    final effectiveLocation = _selectedLocation ?? widget.store.currentCity;
    return widget.store.filterCreatives(
      date: _selectedDate,
      location: _selectedLocation == 'All' ? null : effectiveLocation,
      serviceType: _selectedServiceType == 'All' ? null : _selectedServiceType,
      maxBudget: _selectedMaxBudget,
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final filteredCreatives = _getFilteredCreatives();
        final currentCityDisplay = widget.store.currentCity;
        final activeLocationLabel = _selectedLocation == 'All'
            ? 'All Locations'
            : (_selectedLocation ?? currentCityDisplay);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar with Logo, Location Pill, and Notification Icon
                _buildHeader(context, currentCityDisplay),
                const SizedBox(height: 20),

                // Hero Tagline
                const Text(
                  'Find the perfect',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.8,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _selectedServiceType == 'Videographer'
                      ? 'videographer.'
                      : (_selectedServiceType == 'Photographer'
                          ? 'photographer.'
                          : 'creative artist.'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),

                // Dynamic Filter Hub Card (Date, Location, Role, Budget)
                _buildFilterHub(context, activeLocationLabel),
                const SizedBox(height: 16),

                // Active Filters Chips Bar
                if (_hasActiveFilters) _buildActiveFilterChips(activeLocationLabel),

                const SizedBox(height: 24),

                // What are you shooting? Category Selector
                const Text(
                  'What are you shooting?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _buildCategoriesRow(context),

                const SizedBox(height: 28),

                // Results Header with Live Count & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasActiveFilters
                                ? 'Filtered Creatives'
                                : 'Featured in $activeLocationLabel',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${filteredCreatives.length} available matching your criteria',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hasActiveFilters)
                      GestureDetector(
                        onTap: _resetFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 14, color: Colors.white70),
                              SizedBox(width: 4),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(store: widget.store),
                            ),
                          );
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Matching Creatives List or Empty State
                if (filteredCreatives.isNotEmpty)
                  ...filteredCreatives.map(
                    (creative) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PhotographerCard(
                        photographer: creative,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotographerDetailsScreen(
                                photographer: creative,
                                store: widget.store,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  _buildEmptyState(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Top App Header with Logo, Location Detection Pill, and Notification Button
  Widget _buildHeader(BuildContext context, String currentCity) {
    final locationDisplay = widget.store.currentLocation?.fullAddress ??
        widget.store.currentLocation?.city ??
        'Detecting location...';
    final isGps = widget.store.currentLocation?.isGpsAccurate ?? false;

    return Row(
      children: [
        Image.asset(
          'assets/pyp_logo.png',
          width: 46,
          height: 46,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.camera_alt_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        // Interactive Location Pill
        Expanded(
          child: GestureDetector(
            onTap: () => _showLocationSelectorSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isGps
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  if (widget.store.isDetectingLocation)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: Padding(
                        padding: EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _selectedLocation ?? currentCity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isGps) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'GPS',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          locationDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Notifications Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(store: widget.store),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.borderLight,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (widget.store.notifications.any((n) => !n.isRead))
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBBF24),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Modern Search & Filter Hub Card
  Widget _buildFilterHub(BuildContext context, String activeLocationLabel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Role Toggle Selector (All / Photographer / Videographer)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                _buildRoleTab('All', '✨ All', Icons.auto_awesome_rounded),
                _buildRoleTab('Photographer', '📸 Photo', Icons.camera_alt_rounded),
                _buildRoleTab('Videographer', '🎥 Video', Icons.videocam_rounded),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Filter Inputs Grid: Date, Location, Budget
          Row(
            children: [
              // Date Picker Field
              Expanded(
                child: _buildFilterInputTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Any Date',
                  isSelected: _selectedDate != null,
                  onTap: () => _selectDate(context),
                  onClear: _selectedDate != null
                      ? () => setState(() => _selectedDate = null)
                      : null,
                ),
              ),
              const SizedBox(width: 8),

              // Location Selector Field
              Expanded(
                child: _buildFilterInputTile(
                  icon: Icons.location_on_rounded,
                  label: 'City',
                  value: activeLocationLabel,
                  isSelected: _selectedLocation != null && _selectedLocation != 'All',
                  onTap: () => _showLocationSelectorSheet(context),
                  onClear: _selectedLocation != null && _selectedLocation != 'All'
                      ? () => setState(() => _selectedLocation = null)
                      : null,
                ),
              ),
              const SizedBox(width: 8),

              // Budget Selector Field
              Expanded(
                child: _buildFilterInputTile(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Budget',
                  value: _selectedMaxBudget != null
                      ? '≤ ₹${_selectedMaxBudget!.toInt()}'
                      : 'Any',
                  isSelected: _selectedMaxBudget != null,
                  onTap: () => _showBudgetSelectorSheet(context),
                  onClear: _selectedMaxBudget != null
                      ? () => setState(() => _selectedMaxBudget = null)
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Bar Shortcut
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(
                    store: widget.store,
                    initialRole: _selectedServiceType == 'All' ? null : _selectedServiceType,
                    initialLocation: _selectedLocation == 'All' ? null : _selectedLocation,
                    initialMaxBudget: _selectedMaxBudget,
                    initialDate: _selectedDate,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text(
                    'Search by name, style, or event...',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
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

  Widget _buildRoleTab(String roleValue, String label, IconData icon) {
    final isSelected = _selectedServiceType == roleValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedServiceType = roleValue;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.black : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterInputTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8).withValues(alpha: 0.12)
              : const Color(0xFF171717),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8).withValues(alpha: 0.5)
                : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? const Color(0xFF38BDF8) : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF38BDF8) : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Active Filters Dismissible Chips Bar
  Widget _buildActiveFilterChips(String activeLocationLabel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text(
            'Filters: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          if (_selectedServiceType != 'All')
            _buildChip(
              label: _selectedServiceType,
              onRemove: () => setState(() => _selectedServiceType = 'All'),
            ),
          if (_selectedDate != null)
            _buildChip(
              label: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              onRemove: () => setState(() => _selectedDate = null),
            ),
          if (_selectedLocation != null && _selectedLocation != 'All')
            _buildChip(
              label: '📍 $_selectedLocation',
              onRemove: () => setState(() => _selectedLocation = null),
            ),
          if (_selectedMaxBudget != null)
            _buildChip(
              label: '💰 ≤ ₹${_selectedMaxBudget!.toInt()}',
              onRemove: () => setState(() => _selectedMaxBudget = null),
            ),
          if (_selectedCategory != null)
            _buildChip(
              label: _selectedCategory!,
              onRemove: () => setState(() => _selectedCategory = null),
            ),
          GestureDetector(
            onTap: _resetFilters,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF27272A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// Categories Carousel
  Widget _buildCategoriesRow(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryCard(
            icon: Icons.favorite_rounded,
            title: 'Weddings',
            onTap: () {
              setState(() {
                _selectedCategory =
                    _selectedCategory == 'Weddings' ? null : 'Weddings';
              });
            },
          ),
          CategoryCard(
            icon: Icons.person_rounded,
            title: 'Portraits',
            onTap: () {
              setState(() {
                _selectedCategory =
                    _selectedCategory == 'Portraits' ? null : 'Portraits';
              });
            },
          ),
          CategoryCard(
            icon: Icons.business_center_rounded,
            title: 'Business',
            onTap: () {
              setState(() {
                _selectedCategory =
                    _selectedCategory == 'Business' ? null : 'Business';
              });
            },
          ),
          CategoryCard(
            icon: Icons.celebration_rounded,
            title: 'Events',
            onTap: () {
              setState(() {
                _selectedCategory =
                    _selectedCategory == 'Events' ? null : 'Events';
              });
            },
          ),
        ],
      ),
    );
  }

  /// Empty State when 0 creatives match the filters
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Creatives Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No photographers or videographers matched all your selected criteria (role, location, budget, date). Try adjusting the filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              'Reset Filters',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Date Picker Flow
  Future<void> _selectDate(BuildContext context) async {
    final initial = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E24),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E24),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Location Selector Bottom Sheet
  void _showLocationSelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Select Shoot Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Filter creatives by city or detect your exact GPS location.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GPS Detect Button
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await widget.store.detectLocation(promptPermission: true);
                      setState(() {
                        _selectedLocation = widget.store.currentCity;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF38BDF8).withValues(alpha: 0.2),
                            const Color(0xFF818CF8).withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.location_on,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Use Current GPS Location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.store.currentLocation?.fullAddress ??
                                      'Auto-detect via satellite & Wi-Fi',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    'Popular Cities',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // 'All Locations' option
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.public_rounded,
                            color: Colors.white70,
                          ),
                          title: const Text(
                            'All Locations (Anywhere)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          trailing: _selectedLocation == 'All'
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8))
                              : null,
                          onTap: () {
                            setState(() => _selectedLocation = 'All');
                            Navigator.pop(ctx);
                          },
                        ),
                        const Divider(color: Colors.white10),
                        ...LocationService.popularCities.map((city) {
                          final isSelected =
                              (_selectedLocation ?? widget.store.currentCity) == city;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.location_city_rounded,
                              color: Colors.white54,
                              size: 20,
                            ),
                            title: Text(
                              city,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8))
                                : null,
                            onTap: () {
                              setState(() => _selectedLocation = city);
                              widget.store.setManualLocation(city);
                              Navigator.pop(ctx);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Budget Selector Bottom Sheet
  void _showBudgetSelectorSheet(BuildContext context) {
    double tempBudget = _selectedMaxBudget ?? 20000;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Maximum Budget',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Set your ceiling price to filter creatives within your price range.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display Current Slider Value
                  Center(
                    child: Text(
                      'Up to ₹${tempBudget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF38BDF8),
                      thumbColor: Colors.white,
                      inactiveTrackColor: Colors.white12,
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: tempBudget,
                      min: 3000,
                      max: 50000,
                      divisions: 47,
                      onChanged: (val) {
                        setModalState(() {
                          tempBudget = (val / 500).round() * 500.0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick preset chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPresetChip('₹5k', 5000, tempBudget, (v) => setModalState(() => tempBudget = v)),
                      _buildPresetChip('₹10k', 10000, tempBudget, (v) => setModalState(() => tempBudget = v)),
                      _buildPresetChip('₹20k', 20000, tempBudget, (v) => setModalState(() => tempBudget = v)),
                      _buildPresetChip('₹35k', 35000, tempBudget, (v) => setModalState(() => tempBudget = v)),
                      _buildPresetChip('₹50k', 50000, tempBudget, (v) => setModalState(() => tempBudget = v)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _selectedMaxBudget = null);
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Clear / Any Budget'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedMaxBudget = tempBudget);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Apply Budget',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPresetChip(
    String label,
    double value,
    double currentValue,
    Function(double) onSelect,
  ) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}
