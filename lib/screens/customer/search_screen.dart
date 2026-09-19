import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../providers/pyp_store.dart';
import '../../services/location_service.dart';
import '../../widgets/customer/photographer_list_card.dart';

class SearchScreen extends StatefulWidget {
  final PypStore store;
  final String? initialCategory;
  final String? initialQuery;
  final String? initialRole; // 'Photographer', 'Videographer', 'All'
  final String? initialLocation;
  final double? initialMaxBudget;
  final DateTime? initialDate;

  const SearchScreen({
    super.key,
    required this.store,
    this.initialCategory,
    this.initialQuery,
    this.initialRole,
    this.initialLocation,
    this.initialMaxBudget,
    this.initialDate,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController controller;
  String query = '';
  String selectedRole = 'All';
  String? selectedLocation;
  double? selectedMaxBudget;
  DateTime? selectedDate;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    query = widget.initialQuery ?? '';
    selectedCategory = widget.initialCategory;
    selectedRole = widget.initialRole ?? 'All';
    selectedLocation = widget.initialLocation;
    selectedMaxBudget = widget.initialMaxBudget;
    selectedDate = widget.initialDate;
    controller = TextEditingController(text: query);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<PhotographerModel> _getResults() {
    return widget.store.filterCreatives(
      query: query.isNotEmpty ? query : null,
      serviceType: selectedRole == 'All' ? null : selectedRole,
      location: selectedLocation == 'All' ? null : selectedLocation,
      maxBudget: selectedMaxBudget,
      date: selectedDate,
      category: selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _getResults();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Search Creatives',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // Search Input
          TextField(
            controller: controller,
            autofocus: false,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Photographer, videographer, style, location...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white60),
                      onPressed: () {
                        controller.clear();
                        setState(() => query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Role Filter Pills (All / Photo / Video)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoleFilterChip('All', '✨ All'),
                _buildRoleFilterChip('Photographer', '📸 Photographers'),
                _buildRoleFilterChip('Videographer', '🎥 Videographers'),
                const SizedBox(width: 8),
                // Location Quick Picker
                ActionChip(
                  avatar: const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF38BDF8)),
                  label: Text(
                    selectedLocation ?? 'City',
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedLocation != null ? const Color(0xFF38BDF8) : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: selectedLocation != null
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                      : const Color(0xFF27272A),
                  side: BorderSide(
                    color: selectedLocation != null
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                        : Colors.white12,
                  ),
                  onPressed: () => _showLocationSheet(context),
                ),
                const SizedBox(width: 8),
                // Budget Quick Picker
                ActionChip(
                  avatar: const Icon(Icons.currency_rupee_rounded, size: 14, color: Color(0xFF38BDF8)),
                  label: Text(
                    selectedMaxBudget != null ? '≤ ₹${selectedMaxBudget!.toInt()}' : 'Budget',
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedMaxBudget != null ? const Color(0xFF38BDF8) : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: selectedMaxBudget != null
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                      : const Color(0xFF27272A),
                  side: BorderSide(
                    color: selectedMaxBudget != null
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                        : Colors.white12,
                  ),
                  onPressed: () => _showBudgetSheet(context),
                ),
                if (selectedRole != 'All' ||
                    selectedLocation != null ||
                    selectedMaxBudget != null ||
                    selectedCategory != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedRole = 'All';
                        selectedLocation = null;
                        selectedMaxBudget = null;
                        selectedDate = null;
                        selectedCategory = null;
                        controller.clear();
                        query = '';
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Count Text
          Text(
            '${results.length} creatives found',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          if (results.isNotEmpty)
            ...results.map(
              (photographer) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PhotographerListCard(
                  photographer: photographer,
                  store: widget.store,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: Colors.white38),
                  const SizedBox(height: 14),
                  const Text(
                    'No matching creatives',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Try changing your search terms or clearing your location/budget filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String roleValue, String label) {
    final isSelected = selectedRole == roleValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.white,
        backgroundColor: const Color(0xFF27272A),
        side: BorderSide(color: isSelected ? Colors.white : Colors.white12),
        onSelected: (selected) {
          if (selected) {
            setState(() => selectedRole = roleValue);
          }
        },
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by City',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.public_rounded, color: Colors.white70),
                title: const Text('All Cities', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => selectedLocation = null);
                  Navigator.pop(ctx);
                },
              ),
              const Divider(color: Colors.white12),
              ...LocationService.popularCities.take(6).map((city) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_city_rounded, color: Colors.white54, size: 18),
                  title: Text(city, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() => selectedLocation = city);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Max Budget',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBudgetTile(ctx, 'Any Budget', null),
                  _buildBudgetTile(ctx, '≤ ₹5,000', 5000),
                  _buildBudgetTile(ctx, '≤ ₹10,000', 10000),
                  _buildBudgetTile(ctx, '≤ ₹15,000', 15000),
                  _buildBudgetTile(ctx, '≤ ₹25,000', 25000),
                  _buildBudgetTile(ctx, '≤ ₹50,000', 50000),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetTile(BuildContext ctx, String label, double? val) {
    final isSelected = selectedMaxBudget == val;
    return GestureDetector(
      onTap: () {
        setState(() => selectedMaxBudget = val);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
