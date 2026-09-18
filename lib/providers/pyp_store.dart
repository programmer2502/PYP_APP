import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/photographer_model.dart';
import '../models/booking_model.dart';
import '../repositories/photographer_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/user_repository.dart';
import '../services/storage_service.dart';

class PypStore extends ChangeNotifier {
  final UserRepository? _userRepository;
  final PhotographerRepository _photographerRepository;
  final BookingRepository _bookingRepository;
  final PortfolioRepository? _portfolioRepository;
  final StorageService? _storageService;
  StreamSubscription<List<PhotographerModel>>? _photographerSubscription;
  StreamSubscription<List<BookingModel>>? _bookingsSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;

  UserRepository? get userRepository => _userRepository;
  PhotographerRepository get photographerRepository => _photographerRepository;
  BookingRepository get bookingRepository => _bookingRepository;
  PortfolioRepository get portfolioRepository =>
      _portfolioRepository ?? PortfolioRepository();
  StorageService get storageService =>
      _storageService ?? StorageService();

  UserRole role = UserRole.customer;
  final UserProfile user = UserProfile();
  PhotographerModel? photographerAccount;
  final List<BookingModel> bookings = [];
  final Set<String> savedPhotographers = {};
  bool notificationsEnabled = true;
  bool emailUpdates = true;

  List<PhotographerModel> photographers = [
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

  PypStore({
    UserRepository? userRepository,
    PhotographerRepository? photographerRepository,
    BookingRepository? bookingRepository,
    PortfolioRepository? portfolioRepository,
    StorageService? storageService,
  })  : _userRepository = userRepository,
        _photographerRepository = photographerRepository ?? PhotographerRepository(),
        _bookingRepository = bookingRepository ?? BookingRepository(),
        _portfolioRepository = portfolioRepository,
        _storageService = storageService {
    _initPhotographers();
  }

  void _initPhotographers() {
    _photographerSubscription = _photographerRepository.getPhotographers().listen(
      (items) {
        if (items.isNotEmpty) {
          photographers = items;
          notifyListeners();
        }
      },
      onError: (_) {
        // Fallback to initial mock photographers
      },
    );
  }

  void listenCustomerBookings(String customerId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _bookingRepository.getCustomerBookings(customerId).listen(
      (items) {
        if (items.isNotEmpty) {
          bookings.clear();
          bookings.addAll(items);
          notifyListeners();
        }
      },
      onError: (_) {},
    );
  }


  void listenFavorites(String uid) {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _photographerRepository.getFavorites(uid).listen(
      (items) {
        if (items.isNotEmpty) {
          savedPhotographers.addAll(items);
          notifyListeners();
        }
      },
      onError: (_) {},
    );
  }

  List<BookingModel> get customerBookings => bookings;

  List<BookingModel> get photographerRequests {
    if (photographerAccount == null) return [];
    return bookings
        .where((booking) => booking.photographerName == photographerAccount!.name)
        .toList();
  }

  void switchToCustomer() {
    role = UserRole.customer;
    notifyListeners();
  }

  void switchToPhotographer() {
    if (photographerAccount != null) {
      role = UserRole.photographer;
      notifyListeners();
    }
  }

  void savePhotographer(String identifier, {String? uid}) {
    final isCurrentlySaved = savedPhotographers.contains(identifier);
    if (isCurrentlySaved) {
      savedPhotographers.remove(identifier);
    } else {
      savedPhotographers.add(identifier);
    }
    notifyListeners();

    final userId = uid ?? (user.email.isNotEmpty ? user.email : null);
    if (userId != null) {
      _photographerRepository.toggleFavorite(
        uid: userId,
        photographerId: identifier,
        isCurrentlySaved: isCurrentlySaved,
      ).catchError((_) {});
    }
  }

  bool isSaved(String name) => savedPhotographers.contains(name);


  void createPhotographerAccount({
    required String name,
    required String category,
    required String specialty,
    required String price,
    required String location,
    required String bio,
    required String phone,
    required String email,
    required String instagram,
    String? uid,
  }) {
    final generatedId = uid ?? DateTime.now().millisecondsSinceEpoch.toString();

    photographerAccount = PhotographerModel(
      id: generatedId,
      uid: generatedId,
      name: name,
      category: category,
      specialty: specialty,
      rating: 'New',
      price: price,
      location: location,
      bio: bio,
      phone: phone,
      email: email,
      instagram: instagram,
      verified: false,
      acceptingBookings: true,
      portfolio: [],
      createdAt: DateTime.now(),
    );

    final existingIndex =
        photographers.indexWhere((item) => item.name == name);

    if (existingIndex == -1) {
      photographers.add(photographerAccount!);
    } else {
      photographers[existingIndex] = photographerAccount!;
    }

    role = UserRole.photographer;
    notifyListeners();

    // Persist to Firestore
    _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {
      // Handled gracefully in offline mode
    });
  }

  void updatePhotographer({
    required String name,
    required String category,
    required String specialty,
    required String price,
    required String location,
    required String bio,
    required String phone,
    required String email,
    required String instagram,
  }) {
    if (photographerAccount == null) return;

    final account = photographerAccount!;
    final oldName = account.name;

    account.name = name;
    account.category = category;
    account.specialty = specialty;
    account.price = price;
    account.location = location;
    account.bio = bio;
    account.phone = phone;
    account.email = email;
    account.instagram = instagram;

    final index =
        photographers.indexWhere((photographer) => photographer.name == oldName);

    if (index != -1) {
      photographers[index] = account;
    }

    notifyListeners();

    // Persist updates to Firestore
    _photographerRepository.savePhotographer(account).catchError((_) {
      // Handled gracefully in offline mode
    });
  }

  void addPortfolioItem(String title) {
    if (photographerAccount == null) return;
    photographerAccount!.portfolio.add(title);
    notifyListeners();

    _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {});
  }

  Future<String?> uploadPortfolioImage({
    required String title,
    required Uint8List imageBytes,
  }) async {
    if (photographerAccount == null) return null;

    try {
      final portfolioItem = await portfolioRepository.addPortfolioItem(
        photographerId: photographerAccount!.id,
        title: title,
        imageBytes: imageBytes,
      );

      photographerAccount!.portfolio.add(portfolioItem.imageUrl);
      final index = photographers.indexWhere(
        (p) => p.id == photographerAccount!.id || p.name == photographerAccount!.name,
      );
      if (index != -1) {
        photographers[index] = photographerAccount!;
      }
      notifyListeners();

      _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {});
      return portfolioItem.imageUrl;
    } catch (_) {
      addPortfolioItem(title.isNotEmpty ? title : 'Uploaded Photo');
      return null;
    }
  }

  void removePortfolioItem(int index) {
    if (photographerAccount == null) return;
    if (index < 0 || index >= photographerAccount!.portfolio.length) return;
    photographerAccount!.portfolio.removeAt(index);

    final idx = photographers.indexWhere(
      (p) => p.id == photographerAccount!.id || p.name == photographerAccount!.name,
    );
    if (idx != -1) {
      photographers[idx] = photographerAccount!;
    }
    notifyListeners();

    _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {});
  }

  Future<String?> uploadProfileImage({
    required String uid,
    required Uint8List imageBytes,
    bool isPhotographer = false,
  }) async {
    try {
      final url = await storageService.uploadProfileImage(
        uid: uid,
        imageBytes: imageBytes,
      );

      if (isPhotographer && photographerAccount != null) {
        photographerAccount!.profileImageUrl = url;
        _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {});
      } else {
        user.profileImageUrl = url;
        _userRepository?.createOrUpdateUser(user.toUserModel(uid)).catchError((_) {});
      }


      notifyListeners();
      return url;
    } catch (_) {
      return null;
    }
  }

  void setAcceptingBookings(bool value) {
    if (photographerAccount == null) return;
    photographerAccount!.acceptingBookings = value;
    notifyListeners();

    if (photographerAccount!.id.isNotEmpty) {
      _photographerRepository
          .updateAvailability(photographerAccount!.id, value)
          .catchError((_) {});
    }
  }

  Future<String?> addBooking(BookingModel booking) async {
    bookings.add(booking);
    notifyListeners();

    try {
      final id = await _bookingRepository.createBooking(booking);
      final index = bookings.indexOf(booking);
      if (index != -1) {
        bookings[index] = booking.copyWith(id: id);
        notifyListeners();
      }
      return id;
    } catch (_) {
      // Retained in-memory for offline/demo mode
      return null;
    }
  }

  Future<void> updateBookingStatus(BookingModel booking, String status) async {
    final oldStatus = booking.status;
    booking.status = status;
    notifyListeners();

    if (booking.id.isNotEmpty) {
      try {
        await _bookingRepository.updateBookingStatus(
          bookingId: booking.id,
          currentStatus: BookingStatus.fromString(oldStatus),
          newStatus: BookingStatus.fromString(status),
        );
      } catch (_) {
        // Retained locally in offline/demo mode
      }
    }
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setEmailUpdates(bool value) {
    emailUpdates = value;
    notifyListeners();
  }

  void updateUser({
    required String name,
    required String email,
    required String phone,
    required String city,
  }) {
    user.name = name;
    user.email = email;
    user.phone = phone;
    user.city = city;
    notifyListeners();
  }

  @override
  void dispose() {
    _photographerSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}


