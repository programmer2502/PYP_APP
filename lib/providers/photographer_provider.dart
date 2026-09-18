import 'dart:async';
import 'package:flutter/material.dart';
import '../models/photographer_model.dart';
import '../repositories/photographer_repository.dart';

class PhotographerProvider extends ChangeNotifier {
  final PhotographerRepository _repository;
  StreamSubscription<List<PhotographerModel>>? _subscription;

  List<PhotographerModel> _firestorePhotographers = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  static final List<PhotographerModel> initialMockPhotographers = [
    PhotographerModel(
      id: 'mock_1',
      uid: 'mock_uid_1',
      name: 'Arjun Photography',
      category: 'Weddings',
      specialty: 'Wedding • Candid',
      rating: '4.9',
      price: '₹8,000 onwards',
      startingPrice: 8000,
      location: 'Bengaluru',
      bio: 'Professional wedding and candid photographer creating natural, cinematic memories.',
      phone: '',
      email: '',
      instagram: '@arjunphotography',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
    ),
    PhotographerModel(
      id: 'mock_2',
      uid: 'mock_uid_2',
      name: 'Frame Stories',
      category: 'Portraits',
      specialty: 'Portrait • Fashion',
      rating: '4.8',
      price: '₹5,000 onwards',
      startingPrice: 5000,
      location: 'Bengaluru',
      bio: 'Portrait and fashion photographer focused on clean, expressive imagery.',
      phone: '',
      email: '',
      instagram: '@framestories',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
    ),
    PhotographerModel(
      id: 'mock_3',
      uid: 'mock_uid_3',
      name: 'Studio 24',
      category: 'Events',
      specialty: 'Events • Concerts',
      rating: '4.7',
      price: '₹6,000 onwards',
      startingPrice: 6000,
      location: 'Bengaluru',
      bio: 'Event photographer covering celebrations, concerts and live experiences.',
      phone: '',
      email: '',
      instagram: '@studio24',
      verified: false,
      acceptingBookings: true,
      portfolio: [],
    ),
    PhotographerModel(
      id: 'mock_4',
      uid: 'mock_uid_4',
      name: 'Black Lens Studio',
      category: 'Business',
      specialty: 'Brand • Corporate',
      rating: '4.9',
      price: '₹7,500 onwards',
      startingPrice: 7500,
      location: 'Bengaluru',
      bio: 'Commercial photography for brands, teams, products and corporate campaigns.',
      phone: '',
      email: '',
      instagram: '@blacklensstudio',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
    ),
  ];

  PhotographerProvider({PhotographerRepository? repository})
      : _repository = repository ?? PhotographerRepository() {
    _initStream();
  }

  List<PhotographerModel> get allPhotographers {
    if (_firestorePhotographers.isNotEmpty) {
      return _firestorePhotographers;
    }
    return initialMockPhotographers;
  }

  List<PhotographerModel> get filteredPhotographers {
    return allPhotographers.where((photo) {
      final categoryMatches =
          _selectedCategory == 'All' || photo.category == _selectedCategory;

      final text =
          '${photo.name} ${photo.specialty} ${photo.location} ${photo.category}'
              .toLowerCase();

      final searchMatches =
          _searchQuery.isEmpty || text.contains(_searchQuery.toLowerCase());

      return categoryMatches && searchMatches;
    }).toList();
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initStream() {
    _subscription = _repository.getPhotographers().listen(
      (list) {
        _firestorePhotographers = list;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> savePhotographer(PhotographerModel photographer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.savePhotographer(photographer);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateAvailability(String photographerId, bool isAvailable) async {
    try {
      await _repository.updateAvailability(photographerId, isAvailable);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
