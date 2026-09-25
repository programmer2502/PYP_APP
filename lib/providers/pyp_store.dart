import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/photographer_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../repositories/photographer_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/user_repository.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'chat_provider.dart';

class PypStore extends ChangeNotifier {
  final UserRepository? _userRepository;
  final PhotographerRepository _photographerRepository;
  final BookingRepository _bookingRepository;
  final PortfolioRepository? _portfolioRepository;
  final StorageService? _storageService;
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();
  final ChatProvider chatProvider = ChatProvider();
  StreamSubscription<List<PhotographerModel>>? _photographerSubscription;
  StreamSubscription<List<BookingModel>>? _bookingsSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;
  StreamSubscription<List<AppNotificationModel>>? _notificationsSubscription;

  UserRepository? get userRepository => _userRepository;
  PhotographerRepository get photographerRepository => _photographerRepository;
  BookingRepository get bookingRepository => _bookingRepository;
  PortfolioRepository get portfolioRepository =>
      _portfolioRepository ?? PortfolioRepository();
  StorageService get storageService =>
      _storageService ?? StorageService();
  NotificationService get notificationService => _notificationService;
  LocationService get locationService => _locationService;

  UserRole role = UserRole.customer;
  final UserProfile user = UserProfile();
  PhotographerModel? photographerAccount;
  final List<BookingModel> bookings = [];
  final List<AppNotificationModel> notifications = [];
  final Set<String> savedPhotographers = {};
  bool notificationsEnabled = true;
  bool emailUpdates = true;

  // Location State
  UserLocationData? currentLocation;
  bool isDetectingLocation = false;
  String get currentCity => currentLocation?.city ?? 'Bengaluru';
  String get currentLocationDisplay =>
      currentLocation?.fullAddress ?? (user.city.isNotEmpty ? user.city : 'Bengaluru, India');

  List<String> get currentUserChatIdentifiers {
    final ids = <String>{};
    if (user.uid.isNotEmpty) ids.add(user.uid.trim());
    if (user.email.isNotEmpty && user.email != 'user@example.com') {
      ids.add(user.email.trim());
    }
    if (user.name.isNotEmpty && user.name != 'PYP User') {
      ids.add(user.name.trim());
    }
    if (photographerAccount != null) {
      if (photographerAccount!.id.isNotEmpty) ids.add(photographerAccount!.id.trim());
      if (photographerAccount!.uid.isNotEmpty) ids.add(photographerAccount!.uid.trim());
      if (photographerAccount!.name.isNotEmpty) ids.add(photographerAccount!.name.trim());
      if (photographerAccount!.email.isNotEmpty) ids.add(photographerAccount!.email.trim());
    }
    // Always provide fallback if empty
    if (ids.isEmpty) {
      ids.add('customer_1');
    }
    return ids.toList();
  }

  List<PhotographerModel> photographers = [
    PhotographerModel(
      id: 'mock_1',
      uid: 'mock_uid_1',
      name: 'Arjun Photography',
      category: 'Weddings',
      specialty: 'Wedding • Candid Photography',
      rating: '4.9',
      price: '₹8,000 onwards',
      startingPrice: 8000,
      location: 'Bengaluru',
      bio: 'Professional wedding and candid photographer creating natural, cinematic memories with premium lighting.',
      phone: '',
      email: '',
      instagram: '@arjunphotography',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Photographer',
      experienceYears: 6,
      reviewCount: 48,
    ),
    PhotographerModel(
      id: 'mock_2',
      uid: 'mock_uid_2',
      name: 'Cinematic Reel Works',
      category: 'Weddings',
      specialty: 'Cinematic 4K Films & Teasers',
      rating: '4.9',
      price: '₹14,000 onwards',
      startingPrice: 14000,
      location: 'Bengaluru',
      bio: 'Award-winning wedding videography team specializing in 4K drone cinematography and emotional storytelling.',
      phone: '',
      email: '',
      instagram: '@cinematicreelworks',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Videographer',
      experienceYears: 7,
      reviewCount: 62,
    ),
    PhotographerModel(
      id: 'mock_3',
      uid: 'mock_uid_3',
      name: 'Frame Stories',
      category: 'Portraits',
      specialty: 'Portrait • Fashion Editorial',
      rating: '4.8',
      price: '₹5,000 onwards',
      startingPrice: 5000,
      location: 'Bengaluru',
      bio: 'Portrait and fashion photographer focused on clean, expressive imagery with studio and natural lighting.',
      phone: '',
      email: '',
      instagram: '@framestories',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Photographer',
      experienceYears: 4,
      reviewCount: 35,
    ),
    PhotographerModel(
      id: 'mock_4',
      uid: 'mock_uid_4',
      name: 'Aura Visuals & Video',
      category: 'Portraits',
      specialty: 'Fashion Reels • Brand Short Films',
      rating: '4.9',
      price: '₹7,500 onwards',
      startingPrice: 7500,
      location: 'Mumbai',
      bio: 'Specialist in viral Instagram fashion reels, music videos, and dynamic portrait videography.',
      phone: '',
      email: '',
      instagram: '@auravisuals',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Videographer',
      experienceYears: 5,
      reviewCount: 41,
    ),
    PhotographerModel(
      id: 'mock_5',
      uid: 'mock_uid_5',
      name: 'Studio 24 Live',
      category: 'Events',
      specialty: 'Events • Concerts & Festivals',
      rating: '4.7',
      price: '₹6,000 onwards',
      startingPrice: 6000,
      location: 'Delhi NCR',
      bio: 'Full coverage event team capturing electrifying concert performances and grand celebrations.',
      phone: '',
      email: '',
      instagram: '@studio24live',
      verified: false,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Both',
      experienceYears: 5,
      reviewCount: 29,
    ),
    PhotographerModel(
      id: 'mock_6',
      uid: 'mock_uid_6',
      name: 'Black Lens Studio',
      category: 'Business',
      specialty: 'Brand • Corporate Media',
      rating: '4.9',
      price: '₹10,000 onwards',
      startingPrice: 10000,
      location: 'Bengaluru',
      bio: 'Commercial photography & corporate video production for brands, products, and leadership profiles.',
      phone: '',
      email: '',
      instagram: '@blacklensstudio',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Both',
      experienceYears: 8,
      reviewCount: 74,
    ),
    PhotographerModel(
      id: 'mock_7',
      uid: 'mock_uid_7',
      name: 'Pixel Motion Videography',
      category: 'Events',
      specialty: '4K Event Recaps & Live Stream',
      rating: '4.8',
      price: '₹9,500 onwards',
      startingPrice: 9500,
      location: 'Hyderabad',
      bio: 'High-energy event recap videography, multi-camera live streaming and corporate event highlights.',
      phone: '',
      email: '',
      instagram: '@pixelmotionvideo',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Videographer',
      experienceYears: 6,
      reviewCount: 38,
    ),
    PhotographerModel(
      id: 'mock_8',
      uid: 'mock_uid_8',
      name: 'Coastline Frames',
      category: 'Weddings',
      specialty: 'Destination Weddings • Sunset Shoots',
      rating: '5.0',
      price: '₹18,000 onwards',
      startingPrice: 18000,
      location: 'Goa',
      bio: 'Bespoke destination wedding photography and drone films across Goa and coastal beach retreats.',
      phone: '',
      email: '',
      instagram: '@coastlineframes',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
      serviceType: 'Both',
      experienceYears: 9,
      reviewCount: 88,
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
    listenCustomerBookings(currentUserChatIdentifiers);
    listenNotifications(currentUserChatIdentifiers);
    detectLocation(promptPermission: false);
  }

  /// Automatically or manually detect user's current GPS location
  Future<void> detectLocation({bool promptPermission = true}) async {
    isDetectingLocation = true;
    notifyListeners();
    try {
      final loc = await _locationService.detectCurrentLocation(
        promptPermission: promptPermission,
      );
      currentLocation = loc;
      if (user.city.isEmpty) {
        user.city = loc.city;
      }
    } catch (_) {
      currentLocation = UserLocationData.fallback;
    } finally {
      isDetectingLocation = false;
      notifyListeners();
    }
  }

  /// Set manual city location
  void setManualLocation(String cityName) {
    currentLocation = UserLocationData(
      city: cityName,
      fullAddress: '$cityName, India',
      isGpsAccurate: false,
    );
    notifyListeners();
  }

  /// Comprehensive multi-criteria filtering for Photographers & Videographers
  List<PhotographerModel> filterCreatives({
    DateTime? date,
    String? location,
    String? serviceType, // 'All', 'Photographer', 'Videographer'
    double? maxBudget,
    String? category,
    String? query,
  }) {
    return photographers.where((p) {
      // 1. Service Type / Role filter (Photographer vs Videographer)
      if (serviceType != null && serviceType.isNotEmpty && serviceType.toLowerCase() != 'all') {
        final st = serviceType.toLowerCase();
        if (st == 'photographer' && !p.isPhotographer) {
          return false;
        } else if (st == 'videographer' && !p.isVideographer) {
          return false;
        }
      }

      // 2. Location filter
      if (location != null &&
          location.isNotEmpty &&
          location.toLowerCase() != 'all' &&
          location.toLowerCase() != 'all locations' &&
          location.toLowerCase() != 'anywhere') {
        final locQuery = location.trim().toLowerCase();
        final pLoc = p.location.trim().toLowerCase();
        if (!pLoc.contains(locQuery) && !locQuery.contains(pLoc)) {
          return false;
        }
      }

      // 3. Budget filter
      if (maxBudget != null && maxBudget > 0) {
        final price = p.startingPrice ?? _extractNumericPrice(p.price);
        if (price != null && price > maxBudget) {
          return false;
        }
      }

      // 4. Category filter
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'all') {
        if (p.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      // 5. General search text query
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final textBlock =
            '${p.name} ${p.category} ${p.specialty} ${p.location} ${p.bio} ${p.serviceType}'
                .toLowerCase();
        if (!textBlock.contains(q)) {
          return false;
        }
      }

      // 6. Date availability filter
      if (date != null) {
        // If creative is marked unavailable completely
        if (!p.acceptingBookings) {
          return false;
        }

        // Check if there is already a confirmed booking for this creative on that date
        final isBookedOnDate = bookings.any((b) {
          final isSameCreative = b.matchesPhotographer([p.id, p.uid, p.name, p.email]);
          final isSameDay = b.date.year == date.year &&
              b.date.month == date.month &&
              b.date.day == date.day;
          final isConfirmed = b.status.toLowerCase() == 'confirmed' ||
              b.status.toLowerCase() == 'accepted';
          return isSameCreative && isSameDay && isConfirmed;
        });

        if (isBookedOnDate) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  double? _extractNumericPrice(String priceStr) {
    final clean = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean);
  }

  PhotographerModel? findPhotographerForCurrentUser() {
    if (photographers.isEmpty) return null;

    final targetUid = user.uid.trim();
    final targetEmail = user.email.trim().toLowerCase();
    final targetName = user.name.trim().toLowerCase();
    final targetPhone = user.phone.trim();

    final matchIndex = photographers.indexWhere((p) {
      if (targetUid.isNotEmpty && (p.uid == targetUid || p.id == targetUid)) {
        return true;
      }
      if (targetEmail.isNotEmpty &&
          targetEmail != 'user@example.com' &&
          p.email.isNotEmpty &&
          p.email.toLowerCase() == targetEmail) {
        return true;
      }
      if (targetPhone.isNotEmpty && p.phone.isNotEmpty && p.phone == targetPhone) {
        return true;
      }
      if (targetName.isNotEmpty &&
          targetName != 'pyp user' &&
          p.name.isNotEmpty &&
          p.name.toLowerCase() == targetName) {
        return true;
      }
      return false;
    });

    if (matchIndex != -1) {
      return photographers[matchIndex];
    }
    return null;
  }

  void _checkAndLinkPhotographerAccount() {
    final matched = findPhotographerForCurrentUser();
    if (matched != null) {
      photographerAccount = matched;
      listenPhotographerBookings(
        matched.id.isNotEmpty ? matched.id : matched.name,
      );
    }
  }

  void syncAuthenticatedUser(UserModel userModel) {
    user.uid = userModel.uid;
    user.name = userModel.name;
    user.email = userModel.email;
    user.phone = userModel.phone;
    user.city = userModel.city;
    user.profileImageUrl = userModel.profileImageUrl;

    // Automatically search & link photographer account
    _checkAndLinkPhotographerAccount();

    if (userModel.role == UserRole.photographer) {
      role = UserRole.photographer;
      if (photographerAccount == null) {
        final newAccount = PhotographerModel(
          id: userModel.uid,
          uid: userModel.uid,
          name: userModel.name.isNotEmpty ? userModel.name : 'Photographer',
          category: 'Weddings',
          specialty: 'Photography & Media',
          rating: '5.0',
          price: '₹5,000 onwards',
          startingPrice: 5000,
          location: userModel.city.isNotEmpty ? userModel.city : 'Bengaluru',
          bio: 'Passionate professional photographer creating cinematic moments.',
          phone: userModel.phone,
          email: userModel.email,
          instagram: '',
          verified: false,
          acceptingBookings: true,
          portfolio: [],
          createdAt: DateTime.now(),
        );
        photographers.insert(0, newAccount);
        photographerAccount = newAccount;
        _photographerRepository.savePhotographer(newAccount).catchError((_) {});
      }

      listenPhotographerBookings(currentUserChatIdentifiers);
      listenNotifications(currentUserChatIdentifiers);
    } else {
      listenCustomerBookings(currentUserChatIdentifiers);
      listenFavorites(userModel.uid);
      listenNotifications(currentUserChatIdentifiers);
    }
    notifyListeners();
  }

  void resetOnSignOut() {
    role = UserRole.customer;
    user.uid = '';
    user.name = 'PYP User';
    user.email = 'user@example.com';
    user.phone = '';
    user.city = '';
    user.profileImageUrl = null;
    photographerAccount = null;
    bookings.clear();
    notifications.clear();
    savedPhotographers.clear();
    _bookingsSubscription?.cancel();
    _favoritesSubscription?.cancel();
    _notificationsSubscription?.cancel();
    notifyListeners();
  }

  void _initPhotographers() {
    _photographerSubscription = _photographerRepository.getPhotographers().listen(
      (items) {
        if (items.isNotEmpty) {
          photographers = items;
          if (photographerAccount != null) {
            final updatedIdx = photographers.indexWhere(
              (p) => p.id == photographerAccount!.id || p.uid == photographerAccount!.uid,
            );
            if (updatedIdx != -1) {
              photographerAccount = photographers[updatedIdx];
            }
          } else {
            // Automatically find and link photographer account if user previously created one
            _checkAndLinkPhotographerAccount();
          }
          notifyListeners();
        }
      },
      onError: (_) {
        // Fallback to initial mock photographers
      },
    );
  }

  void listenCustomerBookings(dynamic identifiers) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _bookingRepository.getCustomerBookings(identifiers).listen(
      (items) {
        // Retain any pending locally created bookings while merging server items
        final Map<String, BookingModel> map = {};
        for (final b in items) {
          if (b.id.isNotEmpty) map[b.id] = b;
        }
        for (final b in bookings) {
          if (b.id.isEmpty) {
            map['local_${b.hashCode}'] = b;
          } else if (!map.containsKey(b.id)) {
            map[b.id] = b;
          }
        }
        bookings.clear();
        bookings.addAll(map.values);
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void listenPhotographerBookings(dynamic identifiers) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _bookingRepository.getPhotographerRequests(identifiers).listen(
      (items) {
        final Map<String, BookingModel> map = {};
        for (final b in items) {
          if (b.id.isNotEmpty) map[b.id] = b;
        }
        for (final b in bookings) {
          if (b.id.isEmpty) {
            map['local_${b.hashCode}'] = b;
          } else if (!map.containsKey(b.id)) {
            map[b.id] = b;
          }
        }
        bookings.clear();
        bookings.addAll(map.values);
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void listenNotifications(List<String> identifiers) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _notificationService.streamNotifications(identifiers).listen(
      (items) {
        notifications.clear();
        notifications.addAll(items);
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void listenFavorites(String uid) {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _photographerRepository.getFavorites(uid).listen(
      (items) {
        savedPhotographers.clear();
        savedPhotographers.addAll(items);
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  List<BookingModel> get customerBookings {
    final matched = bookings.where((booking) => booking.matchesCustomer(currentUserChatIdentifiers)).toList();
    return matched.isNotEmpty ? matched : bookings;
  }

  List<BookingModel> get photographerRequests {
    final matched = bookings.where((booking) => booking.matchesPhotographer(currentUserChatIdentifiers)).toList();
    return matched.isNotEmpty ? matched : bookings;
  }

  void switchToCustomer() {
    role = UserRole.customer;
    listenCustomerBookings(currentUserChatIdentifiers);
    listenNotifications(currentUserChatIdentifiers);
    if (user.uid.isNotEmpty) {
      listenFavorites(user.uid);
    }
    notifyListeners();
  }

  void switchToPhotographer() {
    if (photographerAccount == null) {
      _checkAndLinkPhotographerAccount();
    }

    if (photographerAccount == null) {
      final id = user.uid.isNotEmpty
          ? user.uid
          : DateTime.now().millisecondsSinceEpoch.toString();

      photographerAccount = PhotographerModel(
        id: id,
        uid: id,
        name: user.name.isNotEmpty && user.name != 'PYP User'
            ? user.name
            : 'Photographer',
        category: 'Weddings',
        specialty: 'Photography & Media',
        rating: '5.0',
        price: '₹5,000 onwards',
        startingPrice: 5000,
        location: user.city.isNotEmpty ? user.city : 'Bengaluru',
        bio: 'Professional photographer creating cinematic memories.',
        phone: user.phone,
        email: user.email,
        instagram: '',
        verified: false,
        acceptingBookings: true,
        portfolio: [],
        createdAt: DateTime.now(),
      );
      photographers.insert(0, photographerAccount!);
      _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {});
    }

    role = UserRole.photographer;
    listenPhotographerBookings(
      photographerAccount!.id.isNotEmpty
          ? photographerAccount!.id
          : photographerAccount!.name,
    );
    notifyListeners();

    if (user.uid.isNotEmpty) {
      _userRepository?.createOrUpdateUser(
        user.toUserModel().copyWith(role: UserRole.photographer),
      ).catchError((_) {});
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

  bool isSaved(String name) =>
      savedPhotographers.contains(name);

  bool isPhotographerSaved(PhotographerModel photo) =>
      savedPhotographers.contains(photo.id) ||
      savedPhotographers.contains(photo.name);

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
    final generatedId = (uid != null && uid.isNotEmpty)
        ? uid
        : (user.uid.isNotEmpty
            ? user.uid
            : DateTime.now().millisecondsSinceEpoch.toString());

    photographerAccount = PhotographerModel(
      id: generatedId,
      uid: generatedId,
      name: name,
      category: category,
      specialty: specialty,
      rating: '5.0',
      price: price,
      location: location,
      bio: bio,
      phone: phone.isNotEmpty ? phone : user.phone,
      email: email.isNotEmpty ? email : user.email,
      instagram: instagram,
      verified: false,
      acceptingBookings: true,
      portfolio: [],
      createdAt: DateTime.now(),
    );

    final existingIndex = photographers.indexWhere(
      (item) =>
          item.id == generatedId ||
          item.uid == generatedId ||
          item.name.toLowerCase() == name.toLowerCase(),
    );

    if (existingIndex == -1) {
      photographers.insert(0, photographerAccount!);
    } else {
      photographers[existingIndex] = photographerAccount!;
    }

    role = UserRole.photographer;
    listenPhotographerBookings(generatedId);
    notifyListeners();

    // Persist to Firestore photographers collection
    _photographerRepository.savePhotographer(photographerAccount!).catchError((_) {});

    // Update user record in Firestore to role: photographer
    if (user.uid.isNotEmpty) {
      _userRepository?.createOrUpdateUser(
        user.toUserModel().copyWith(role: UserRole.photographer),
      ).catchError((_) {});
    }
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

    String? id;
    try {
      id = await _bookingRepository.createBooking(booking);
      final index = bookings.indexOf(booking);
      if (index != -1 && id.isNotEmpty) {
        bookings[index] = booking.copyWith(id: id);
        notifyListeners();
      }
    } catch (_) {
      // Retained in-memory for offline/demo mode
    }

    // Queue in-app notification for photographer & customer (No chat created until paid)
    try {
      final clientLabel = booking.customerName.isNotEmpty
          ? booking.customerName
          : (booking.customerEmail.isNotEmpty ? booking.customerEmail : 'A client');

      _notificationService.sendNotification(
        recipientUserId: booking.photographerId,
        title: 'New Booking Request',
        message: '$clientLabel requested a ${booking.category} session on ${booking.date.day}/${booking.date.month}/${booking.date.year}.',
        type: AppNotificationType.bookingRequest,
        referenceId: id ?? '',
      ).catchError((_) => null);

      _notificationService.sendNotification(
        recipientUserId: booking.customerId,
        title: 'Booking Request Sent',
        message: 'Your booking request for ${booking.photographerName} (${booking.category}) has been submitted.',
        type: AppNotificationType.bookingRequest,
        referenceId: id ?? '',
      ).catchError((_) => null);
    } catch (_) {}

    return id;
  }

  Future<void> updateBookingStatus(BookingModel booking, String status) async {
    final oldStatus = booking.status;
    booking.status = status;
    final idx = bookings.indexWhere((b) => (b.id.isNotEmpty && b.id == booking.id) || b == booking);
    if (idx != -1) {
      bookings[idx] = booking.copyWith(status: status);
    }
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

    // Notifications for status update (Chat remains gated on payment)
    try {
      String notifTitle = '';
      String notifBody = '';
      AppNotificationType notifType = AppNotificationType.system;
      String notifRecipient = booking.customerId;

      final isAccepted = status.toLowerCase() == 'accepted' || status.toLowerCase() == 'confirmed';
      final isRejected = status.toLowerCase() == 'rejected';
      final isCancelled = status.toLowerCase() == 'cancelled';

      if (isAccepted) {
        notifTitle = 'Booking Confirmed! 🎉';
        notifBody = '${booking.photographerName} has accepted your booking for ${booking.category}. Please complete payment to unlock chat.';
        notifType = AppNotificationType.bookingAccepted;
        notifRecipient = booking.customerId;
      } else if (isRejected) {
        notifTitle = 'Booking Request Declined';
        notifBody = '${booking.photographerName} was unable to accept your request for ${booking.date.day}/${booking.date.month}/${booking.date.year}.';
        notifType = AppNotificationType.bookingRejected;
        notifRecipient = booking.customerId;
      } else if (isCancelled) {
        notifTitle = 'Booking Cancelled';
        notifBody = 'The booking on ${booking.date.day}/${booking.date.month}/${booking.date.year} has been cancelled.';
        notifType = AppNotificationType.bookingCancelled;
        notifRecipient = booking.photographerId;
      }

      if (notifTitle.isNotEmpty) {
        _notificationService.sendNotification(
          recipientUserId: notifRecipient,
          title: notifTitle,
          message: notifBody,
          type: notifType,
          referenceId: booking.id,
        ).catchError((_) => null);
      }
    } catch (_) {}
  }

  Future<void> updateBookingPayment(
    BookingModel booking, {
    required PaymentStatus paymentStatus,
    String? paymentId,
    String? orderId,
    bool? chatEnabled,
    String? conversationId,
    String? signature,
  }) async {
    final isPaid = paymentStatus == PaymentStatus.paid;
    final enabled = chatEnabled ?? isPaid;
    final convoId = conversationId ??
        (isPaid ? 'convo_bk_${booking.id.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}' : null);

    final idx = bookings.indexWhere((b) => (b.id.isNotEmpty && b.id == booking.id) || b == booking);
    if (idx != -1) {
      bookings[idx] = bookings[idx].copyWith(
        paymentStatus: paymentStatus,
        chatEnabled: enabled,
        chatEnabledAt: isPaid ? DateTime.now() : null,
        conversationId: convoId,
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
      );
    }
    notifyListeners();

    if (booking.id.isNotEmpty) {
      try {
        await _bookingRepository.updateBookingPayment(
          bookingId: booking.id,
          paymentStatus: paymentStatus,
          paymentId: paymentId,
          orderId: orderId,
          chatEnabled: enabled,
          conversationId: convoId,
          signature: signature,
        );
      } catch (_) {
        // Retained locally in offline mode
      }
    }

    // Auto-activate verified chat thread & notification once paid
    if (isPaid && convoId != null) {
      try {
        final allParticipants = <String>{
          booking.customerId,
          booking.customerEmail,
          booking.customerName,
          booking.customerPhone,
          ...booking.customerIdentifiers,
          booking.photographerId,
          booking.photographerUid,
          booking.photographerName,
          booking.photographerEmail,
          ...booking.photographerIdentifiers,
          ...currentUserChatIdentifiers,
        }..removeWhere((s) => s.isEmpty || s == 'guest_user' || s == 'user@example.com' || s == 'pyp user');

        final payMsg = '💳 Payment Verified & Received\n'
            '• Amount: ${booking.price}\n'
            '• Payment ID: ${paymentId ?? 'N/A'}\n'
            '• Gateway: Razorpay Verified\n'
            '• Status: Paid in Full\n\n'
            'Chat is now active for this booking.';

        chatProvider.sendMessage(
          conversationId: convoId,
          message: payMsg,
          senderId: 'system',
          senderName: 'PYP Concierge',
          recipientId: booking.photographerId,
          recipientName: booking.photographerName,
          customerId: booking.customerId,
          customerName: booking.customerName,
          photographerId: booking.photographerId,
          photographerName: booking.photographerName,
          additionalParticipants: allParticipants.toList(),
          type: 'system',
        ).catchError((_) {});

        _notificationService.sendNotification(
          recipientUserId: booking.photographerId,
          title: 'Payment Received! 💳',
          message: '${booking.customerName.isNotEmpty ? booking.customerName : 'Client'} completed payment of ${booking.price}. Chat is unlocked.',
          type: AppNotificationType.bookingAccepted,
          referenceId: booking.id,
        ).catchError((_) => null);
      } catch (_) {}
    }
  }

  void markNotificationRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
    _notificationService.markAsRead(id);
  }

  void markAllNotificationsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
        _notificationService.markAsRead(notifications[i].id);
      }
    }
    notifyListeners();
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
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
