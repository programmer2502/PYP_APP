import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class UserLocationData {
  final String city;
  final String locality;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final bool isGpsAccurate;

  const UserLocationData({
    required this.city,
    this.locality = '',
    required this.fullAddress,
    this.latitude,
    this.longitude,
    this.isGpsAccurate = false,
  });

  static const UserLocationData fallback = UserLocationData(
    city: 'Bengaluru',
    locality: 'Indiranagar',
    fullAddress: 'Bengaluru, Karnataka',
    latitude: 12.9716,
    longitude: 77.5946,
    isGpsAccurate: false,
  );
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  UserLocationData? _lastKnownLocation;
  UserLocationData? get lastKnownLocation => _lastKnownLocation;

  static const List<String> popularCities = [
    'Bengaluru',
    'Mumbai',
    'Delhi NCR',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Goa',
    'Jaipur',
    'Ahmedabad',
    'Kochi',
    'Chandigarh',
  ];

  /// Returns unique list of city options including detected current city
  static List<String> getCityOptions({String? currentCity}) {
    final list = <String>[];
    if (currentCity != null && currentCity.trim().isNotEmpty) {
      list.add(currentCity.trim());
    }
    for (final city in popularCities) {
      if (!list.contains(city)) {
        list.add(city);
      }
    }
    return list;
  }

  /// Detects device location upon opening the app
  Future<UserLocationData> detectCurrentLocation({bool promptPermission = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled && promptPermission) {
        // Location services disabled, attempt IP detection
        return await _detectLocationFromIp();
      }

      if (permission == LocationPermission.denied && promptPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return await _detectLocationFromIp();
      }

      // We have permission, get GPS position with 5s timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // Reverse geocode to city name
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final city = place.locality?.isNotEmpty == true
              ? place.locality!
              : (place.subAdministrativeArea?.isNotEmpty == true
                  ? place.subAdministrativeArea!
                  : (place.administrativeArea?.isNotEmpty == true
                      ? place.administrativeArea!
                      : 'Bengaluru'));

          final subLocality = place.subLocality ?? place.name ?? '';
          final state = place.administrativeArea ?? '';
          final fullAddr = subLocality.isNotEmpty && subLocality != city
              ? '$subLocality, $city'
              : (state.isNotEmpty && state != city ? '$city, $state' : city);

          final result = UserLocationData(
            city: city,
            locality: subLocality,
            fullAddress: fullAddr,
            latitude: position.latitude,
            longitude: position.longitude,
            isGpsAccurate: true,
          );

          _lastKnownLocation = result;
          return result;
        }
      } catch (e) {
        debugPrint('Reverse geocoding error: $e');
      }

      // Fallback with GPS coordinates
      final gpsFallback = UserLocationData(
        city: 'Bengaluru',
        fullAddress: 'Current GPS Location',
        latitude: position.latitude,
        longitude: position.longitude,
        isGpsAccurate: true,
      );
      _lastKnownLocation = gpsFallback;
      return gpsFallback;
    } catch (e) {
      debugPrint('Location detection error: $e');
      return await _detectLocationFromIp();
    }
  }

  /// IP Geolocation fallback when GPS is not available/denied
  Future<UserLocationData> _detectLocationFromIp() async {
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final city = data['city'] as String? ?? 'Bengaluru';
        final region = data['regionName'] as String? ?? '';
        final lat = (data['lat'] as num?)?.toDouble();
        final lon = (data['lon'] as num?)?.toDouble();

        final fullAddr = region.isNotEmpty ? '$city, $region' : city;

        final result = UserLocationData(
          city: city,
          fullAddress: fullAddr,
          latitude: lat,
          longitude: lon,
          isGpsAccurate: false,
        );
        _lastKnownLocation = result;
        return result;
      }
    } catch (_) {}

    _lastKnownLocation = UserLocationData.fallback;
    return UserLocationData.fallback;
  }
}
