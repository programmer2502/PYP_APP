import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/location_service.dart';

class PypLocationDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final String label;
  final String? detectedJoiningCity;
  final bool requiredField;

  const PypLocationDropdown({
    super.key,
    this.value,
    required this.onChanged,
    this.label = 'Location',
    this.detectedJoiningCity,
    this.requiredField = true,
  });

  @override
  State<PypLocationDropdown> createState() => _PypLocationDropdownState();
}

class _PypLocationDropdownState extends State<PypLocationDropdown> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = _resolveInitialValue();
  }

  @override
  void didUpdateWidget(covariant PypLocationDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null && widget.value!.isNotEmpty) {
      setState(() {
        _currentValue = widget.value!;
      });
    }
  }

  String _resolveInitialValue() {
    if (widget.value != null && widget.value!.trim().isNotEmpty) {
      return widget.value!.trim();
    }
    if (widget.detectedJoiningCity != null && widget.detectedJoiningCity!.trim().isNotEmpty) {
      return widget.detectedJoiningCity!.trim();
    }
    return LocationService.popularCities.first;
  }

  List<String> _buildOptions() {
    final list = <String>[];

    // Priority 1: User's joining/detected city or current value
    if (_currentValue.isNotEmpty) {
      list.add(_currentValue);
    }
    if (widget.detectedJoiningCity != null &&
        widget.detectedJoiningCity!.isNotEmpty &&
        !list.contains(widget.detectedJoiningCity)) {
      list.add(widget.detectedJoiningCity!);
    }

    // Add standard popular cities
    for (final city in LocationService.popularCities) {
      if (!list.contains(city)) {
        list.add(city);
      }
    }

    return list;
  }

  Future<void> _promptCustomCity() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enter Custom Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Mysuru, Hubballi, etc.',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Set Location', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentValue = result;
      });
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();

    // Ensure _currentValue is within options
    if (!options.contains(_currentValue) && _currentValue.isNotEmpty) {
      options.insert(0, _currentValue);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(_currentValue) ? _currentValue : options.first,
        dropdownColor: AppColors.card,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF38BDF8),
          ),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        items: [
          ...options.map(
            (city) => DropdownMenuItem<String>(
              value: city,
              child: Row(
                children: [
                  Text(city),
                  if (widget.detectedJoiningCity != null &&
                      widget.detectedJoiningCity!.toLowerCase() == city.toLowerCase()) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Your Location',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const DropdownMenuItem<String>(
            value: '__custom__',
            child: Row(
              children: [
                Icon(Icons.add_location_alt_outlined, size: 16, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Text(
                  '+ Other Location...',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (val) {
          if (val == null) return;
          if (val == '__custom__') {
            _promptCustomCity();
          } else {
            setState(() {
              _currentValue = val;
            });
            widget.onChanged(val);
          }
        },
      ),
    );
  }
}
