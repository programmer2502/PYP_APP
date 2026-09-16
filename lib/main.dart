
import 'package:flutter/material.dart';

void main() {
  runApp(const PypApp());
}

// ============================================================
// PYP - PICK YOUR PHOTOGRAPHER
// Complete customer + photographer prototype
// ============================================================

class PypApp extends StatefulWidget {
  const PypApp({super.key});

  @override
  State<PypApp> createState() => _PypAppState();
}

class _PypAppState extends State<PypApp> {
  final PypStore store = PypStore();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PYP - Pick Your Photographer',
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              secondary: Colors.white,
              surface: Color(0xFF111111),
            ),
          ),
          home: HomeScreen(store: store),
        );
      },
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

enum UserRole {
  customer,
  photographer,
}

class PhotographerModel {
  String name;
  String category;
  String specialty;
  String rating;
  String price;
  String location;
  String bio;
  String phone;
  String email;
  String instagram;
  bool verified;
  bool acceptingBookings;
  List<String> portfolio;

  PhotographerModel({
    required this.name,
    required this.category,
    required this.specialty,
    required this.rating,
    required this.price,
    required this.location,
    required this.bio,
    required this.phone,
    required this.email,
    required this.instagram,
    required this.verified,
    required this.acceptingBookings,
    required this.portfolio,
  });
}

class BookingModel {
  final String photographerName;
  final String category;
  final DateTime date;
  final String time;
  String status;
  final String price;

  BookingModel({
    required this.photographerName,
    required this.category,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
  });
}

class UserProfile {
  String name;
  String email;
  String phone;
  String city;

  UserProfile({
    this.name = 'PYP User',
    this.email = 'user@example.com',
    this.phone = '',
    this.city = '',
  });
}

// ============================================================
// APP STORE
// ============================================================

class PypStore extends ChangeNotifier {
  UserRole role = UserRole.customer;

  final UserProfile user = UserProfile();

  PhotographerModel? photographerAccount;

  final List<BookingModel> bookings = [];

  final Set<String> savedPhotographers = {};

  bool notificationsEnabled = true;
  bool emailUpdates = true;

  final List<PhotographerModel> photographers = [
    PhotographerModel(
      name: 'Arjun Photography',
      category: 'Weddings',
      specialty: 'Wedding • Candid',
      rating: '4.9',
      price: '₹8,000 onwards',
      location: 'Bengaluru',
      bio:
      'Professional wedding and candid photographer creating natural, cinematic memories.',
      phone: '',
      email: '',
      instagram: '@arjunphotography',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
    ),
    PhotographerModel(
      name: 'Frame Stories',
      category: 'Portraits',
      specialty: 'Portrait • Fashion',
      rating: '4.8',
      price: '₹5,000 onwards',
      location: 'Bengaluru',
      bio:
      'Portrait and fashion photographer focused on clean, expressive imagery.',
      phone: '',
      email: '',
      instagram: '@framestories',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
    ),
    PhotographerModel(
      name: 'Studio 24',
      category: 'Events',
      specialty: 'Events • Concerts',
      rating: '4.7',
      price: '₹6,000 onwards',
      location: 'Bengaluru',
      bio:
      'Event photographer covering celebrations, concerts and live experiences.',
      phone: '',
      email: '',
      instagram: '@studio24',
      verified: false,
      acceptingBookings: true,
      portfolio: [],
    ),
    PhotographerModel(
      name: 'Black Lens Studio',
      category: 'Business',
      specialty: 'Brand • Corporate',
      rating: '4.9',
      price: '₹7,500 onwards',
      location: 'Bengaluru',
      bio:
      'Commercial photography for brands, teams, products and corporate campaigns.',
      phone: '',
      email: '',
      instagram: '@blacklensstudio',
      verified: true,
      acceptingBookings: true,
      portfolio: [],
    ),
  ];

  List<BookingModel> get customerBookings => bookings;

  List<BookingModel> get photographerRequests {
    if (photographerAccount == null) return [];
    return bookings
        .where((booking) =>
    booking.photographerName == photographerAccount!.name)
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

  void savePhotographer(String name) {
    if (savedPhotographers.contains(name)) {
      savedPhotographers.remove(name);
    } else {
      savedPhotographers.add(name);
    }
    notifyListeners();
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
  }) {
    photographerAccount = PhotographerModel(
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

    for (final booking in bookings) {
      if (booking.photographerName == oldName) {
        // BookingModel names are final; existing bookings intentionally keep
        // their historical photographer name.
      }
    }

    notifyListeners();
  }

  void addPortfolioItem(String title) {
    if (photographerAccount == null) return;
    photographerAccount!.portfolio.add(title);
    notifyListeners();
  }

  void removePortfolioItem(int index) {
    if (photographerAccount == null) return;
    if (index < 0 || index >= photographerAccount!.portfolio.length) return;
    photographerAccount!.portfolio.removeAt(index);
    notifyListeners();
  }

  void setAcceptingBookings(bool value) {
    if (photographerAccount == null) return;
    photographerAccount!.acceptingBookings = value;
    notifyListeners();
  }

  void addBooking(BookingModel booking) {
    bookings.add(booking);
    notifyListeners();
  }

  void updateBookingStatus(BookingModel booking, String status) {
    booking.status = status;
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
}

// ============================================================
// MAIN SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final PypStore store;

  const HomeScreen({
    super.key,
    required this.store,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isPhotographer = widget.store.role == UserRole.photographer;

    final customerPages = [
      HomeContent(store: widget.store),
      DiscoverContent(store: widget.store),
      BookingsContent(store: widget.store),
      ProfileContent(store: widget.store),
    ];

    final photographerPages = [
      PhotographerDashboard(store: widget.store),
      PhotographerRequests(store: widget.store),
      PhotographerCalendar(store: widget.store),
      PhotographerProfile(store: widget.store),
    ];

    final pages = isPhotographer ? photographerPages : customerPages;

    if (selectedIndex >= pages.length) {
      selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: pages,
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: FloatingNavigationBar(
              selectedIndex: selectedIndex,
              photographerMode: isPhotographer,
              onSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CUSTOMER HOME
// ============================================================

class HomeContent extends StatelessWidget {
  final PypStore store;

  const HomeContent({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/pyp_logo.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.contain,
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Find the perfect',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                letterSpacing: -1,
              ),
            ),
            const Text(
              'photographer.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 22),
            SearchBox(
              hint: 'Search photographers...',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(store: store),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'What are you shooting?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 105,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryCard(
                    icon: Icons.favorite_rounded,
                    title: 'Weddings',
                  ),
                  CategoryCard(
                    icon: Icons.person_rounded,
                    title: 'Portraits',
                  ),
                  CategoryCard(
                    icon: Icons.business_center_rounded,
                    title: 'Business',
                  ),
                  CategoryCard(
                    icon: Icons.celebration_rounded,
                    title: 'Events',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured photographers',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(store: store),
                      ),
                    );
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const PhotographerCard(
              name: 'Featured Photographer',
              specialty: 'Portrait • Wedding • Events',
              rating: '4.9',
            ),
            const SizedBox(height: 16),
            const PhotographerCard(
              name: 'Creative Studio',
              specialty: 'Fashion • Portrait • Brand',
              rating: '4.8',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class SearchScreen extends StatefulWidget {
  final PypStore store;

  const SearchScreen({
    super.key,
    required this.store,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.store.photographers.where((photographer) {
      final value =
      '${photographer.name} ${photographer.category} ${photographer.specialty} ${photographer.location}'
          .toLowerCase();
      return value.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Photographer, style or location',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.white70,
              ),
              filled: true,
              fillColor: const Color(0xFF151515),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            '${results.length} photographers found',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ...results.map(
                (photographer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PhotographerListCard(
                photographer: photographer,
                store: widget.store,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DISCOVER
// ============================================================

class DiscoverContent extends StatefulWidget {
  final PypStore store;

  const DiscoverContent({
    super.key,
    required this.store,
  });

  @override
  State<DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<DiscoverContent> {
  String selectedCategory = 'All';
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.store.photographers.where((photo) {
      final categoryMatches = selectedCategory == 'All' ||
          photo.category == selectedCategory;

      final text =
      '${photo.name} ${photo.specialty} ${photo.location}'.toLowerCase();

      return categoryMatches && text.contains(search.toLowerCase());
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discover',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Find photographers that match your style.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search photographers...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: const Color(0xFF151515),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Explore',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final category in [
                    'All',
                    'Weddings',
                    'Portraits',
                    'Events',
                    'Business',
                  ])
                    DiscoverChip(
                      title: category,
                      selected: selectedCategory == category,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photographers',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${filtered.length} found',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0x73FFFFFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No photographers found',
                subtitle: 'Try another search or category.',
              ),
            ...filtered.map(
                  (photo) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PhotographerListCard(
                  photographer: photo,
                  store: widget.store,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER LIST CARD
// ============================================================

class PhotographerListCard extends StatelessWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const PhotographerListCard({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotographerDetailsScreen(
              photographer: photographer,
              store: store,
            ),
          ),
        );
      },
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 102,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white24,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          photographer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (photographer.verified)
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    photographer.specialty,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0x73FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        photographer.rating,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        photographer.location,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    photographer.price,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              store.isSaved(photographer.name)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 20,
              color: store.isSaved(photographer.name)
                  ? Colors.white
                  : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER DETAILS
// ============================================================

class PhotographerDetailsScreen extends StatelessWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const PhotographerDetailsScreen({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Photographer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              store.savePhotographer(photographer.name);
            },
            icon: Icon(
              store.isSaved(photographer.name)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 70,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    photographer.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        photographer.rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              photographer.specialty,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${photographer.location}',
              style: const TextStyle(
                color: Color(0x73FFFFFF),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              photographer.bio,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 26),
            if (photographer.portfolio.isNotEmpty) ...[
              const Text(
                'Portfolio',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 105,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: photographer.portfolio
                      .map(
                        (item) => Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 7),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
              const SizedBox(height: 28),
            ],
            const Text(
              'Starting price',
              style: TextStyle(
                fontSize: 14,
                color: Color(0x73FFFFFF),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              photographer.price,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 30),
            if (!photographer.acceptingBookings)
              const EmptyState(
                icon: Icons.event_busy_rounded,
                title: 'Currently unavailable',
                subtitle: 'This photographer is not accepting bookings.',
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          photographer: photographer,
                          store: store,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Book this photographer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOOKING SCREEN
// ============================================================

class BookingScreen extends StatefulWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const BookingScreen({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  String selectedTime = '10:00 AM';
  final TextEditingController notesController = TextEditingController();

  final List<String> times = const [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
  ];

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF151515),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void confirmBooking() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date first.'),
        ),
      );
      return;
    }

    widget.store.addBooking(
      BookingModel(
        photographerName: widget.photographer.name,
        category: widget.photographer.category,
        date: selectedDate!,
        time: selectedTime,
        status: 'Pending',
        price: widget.photographer.price,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151515),
          title: const Text(
            'Booking request sent',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            '${widget.photographer.name} will receive your booking request.',
            style: const TextStyle(color: Colors.white60),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Photographer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.photographer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.photographer.price,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select date',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: chooseDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      selectedDate == null
                          ? 'Choose a date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedDate == null
                            ? const Color(0x73FFFFFF)
                            : Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select time',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: times.map((time) {
                final selected = selectedTime == time;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                      selected ? Colors.white : const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.black : Colors.white70,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text(
              'Message for photographer',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tell them about your event...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF151515),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Confirm booking',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER BOOKINGS
// ============================================================

class BookingsContent extends StatelessWidget {
  final PypStore store;

  const BookingsContent({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final bookings = store.customerBookings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bookings',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your photography bookings.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 30),
            if (bookings.isEmpty)
              const EmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'No bookings yet',
                subtitle:
                'Your upcoming and past bookings will appear here.',
              ),
            ...bookings.reversed.map(
                  (booking) => BookingCard(
                booking: booking,
                onCancel: booking.status == 'Pending'
                    ? () {
                  store.updateBookingStatus(booking, 'Cancelled');
                }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER PROFILE
// ============================================================

class ProfileContent extends StatelessWidget {
  final PypStore store;

  const ProfileContent({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 38,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    store.user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store.user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0x73FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            ProfileOption(
              icon: Icons.person_outline_rounded,
              title: 'Personal details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalDetailsScreen(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.favorite_border_rounded,
              title: 'Saved photographers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavedPhotographersScreen(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.camera_alt_outlined,
              title: store.photographerAccount == null
                  ? 'Create photographer account'
                  : 'Photographer mode',
              onTap: () {
                if (store.photographerAccount == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotographerOnboardingScreen(
                        store: store,
                      ),
                    ),
                  );
                } else {
                  store.switchToPhotographer();
                }
              },
            ),
            ProfileOption(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(store: store),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF151515),
                      title: const Text('Sign out?'),
                      content: const Text(
                        'This prototype keeps account data locally while the app is running.',
                        style: TextStyle(color: Colors.white60),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signed out locally.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign out',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PERSONAL DETAILS
// ============================================================

class PersonalDetailsScreen extends StatefulWidget {
  final PypStore store;

  const PersonalDetailsScreen({
    super.key,
    required this.store,
  });

  @override
  State<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController cityController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.store.user.name);
    emailController = TextEditingController(text: widget.store.user.email);
    phoneController = TextEditingController(text: widget.store.user.phone);
    cityController = TextEditingController(text: widget.store.user.city);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void save() {
    widget.store.updateUser(
      name: nameController.text.trim().isEmpty
          ? 'PYP User'
          : nameController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? 'user@example.com'
          : emailController.text.trim(),
      phone: phoneController.text.trim(),
      city: cityController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal details saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Personal details',
      children: [
        PypTextField(
          controller: nameController,
          label: 'Full name',
          icon: Icons.person_outline_rounded,
        ),
        PypTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        PypTextField(
          controller: phoneController,
          label: 'Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        PypTextField(
          controller: cityController,
          label: 'City',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          title: 'Save changes',
          onPressed: save,
        ),
      ],
    );
  }
}

// ============================================================
// SAVED PHOTOGRAPHERS
// ============================================================

class SavedPhotographersScreen extends StatelessWidget {
  final PypStore store;

  const SavedPhotographersScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final saved = store.photographers
        .where((photo) => store.savedPhotographers.contains(photo.name))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Saved photographers',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: saved.isEmpty
          ? const EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Nothing saved yet',
        subtitle: 'Save photographers you want to come back to.',
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: saved
            .map(
              (photo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PhotographerListCard(
              photographer: photo,
              store: store,
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsScreen extends StatelessWidget {
  final PypStore store;

  const SettingsScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          SettingSwitch(
            title: 'Push notifications',
            subtitle: 'Booking and account updates',
            value: store.notificationsEnabled,
            onChanged: store.setNotificationsEnabled,
          ),
          SettingSwitch(
            title: 'Email updates',
            subtitle: 'Important updates and reminders',
            value: store.emailUpdates,
            onChanged: store.setEmailUpdates,
          ),
          const SizedBox(height: 20),
          const ProfileOptionStatic(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
          ),
          const ProfileOptionStatic(
            icon: Icons.description_outlined,
            title: 'Terms & conditions',
          ),
          const ProfileOptionStatic(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER ONBOARDING
// ============================================================

class PhotographerOnboardingScreen extends StatefulWidget {
  final PypStore store;

  const PhotographerOnboardingScreen({
    super.key,
    required this.store,
  });

  @override
  State<PhotographerOnboardingScreen> createState() =>
      _PhotographerOnboardingScreenState();
}

class _PhotographerOnboardingScreenState
    extends State<PhotographerOnboardingScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final specialtyController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final instagramController = TextEditingController();

  String category = 'Weddings';

  @override
  void dispose() {
    nameController.dispose();
    specialtyController.dispose();
    priceController.dispose();
    locationController.dispose();
    bioController.dispose();
    phoneController.dispose();
    emailController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (!formKey.currentState!.validate()) return;

    widget.store.createPhotographerAccount(
      name: nameController.text.trim(),
      category: category,
      specialty: specialtyController.text.trim(),
      price: priceController.text.trim(),
      location: locationController.text.trim(),
      bio: bioController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      instagram: instagramController.text.trim(),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photographer account created.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Photographer account',
      children: [
        const Text(
          'Build your photographer profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your profile can appear in PYP Discover for customers.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              PypTextField(
                controller: nameController,
                label: 'Business / photographer name',
                icon: Icons.camera_alt_outlined,
                requiredField: true,
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                dropdownColor: const Color(0xFF151515),
                decoration: InputDecoration(
                  labelText: 'Primary category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  filled: true,
                  fillColor: const Color(0xFF151515),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  'Weddings',
                  'Portraits',
                  'Events',
                  'Business',
                  'Fashion',
                ]
                    .map(
                      (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              PypTextField(
                controller: specialtyController,
                label: 'Specialty',
                icon: Icons.style_outlined,
                hint: 'Wedding • Candid',
                requiredField: true,
              ),
              PypTextField(
                controller: priceController,
                label: 'Starting price',
                icon: Icons.currency_rupee_rounded,
                hint: '₹8,000 onwards',
                requiredField: true,
              ),
              PypTextField(
                controller: locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
                hint: 'Bengaluru',
                requiredField: true,
              ),
              PypTextField(
                controller: bioController,
                label: 'About you',
                icon: Icons.notes_rounded,
                maxLines: 4,
                requiredField: true,
              ),
              PypTextField(
                controller: phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              PypTextField(
                controller: emailController,
                label: 'Business email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              PypTextField(
                controller: instagramController,
                label: 'Instagram',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                title: 'Create photographer account',
                onPressed: createAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PHOTOGRAPHER DASHBOARD
// ============================================================

class PhotographerDashboard extends StatelessWidget {
  final PypStore store;

  const PhotographerDashboard({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final account = store.photographerAccount!;
    final requests = store.photographerRequests;
    final pending =
        requests.where((booking) => booking.status == 'Pending').length;
    final accepted =
        requests.where((booking) => booking.status == 'Accepted').length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome, ${account.name}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: account.acceptingBookings
                        ? const Color(0xFF151515)
                        : const Color(0xFF241515),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Text(
                    account.acceptingBookings ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      fontSize: 11,
                      color: account.acceptingBookings
                          ? Colors.white
                          : Colors.white54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking requests',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$pending',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Pending requests',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0x73FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Accepted',
                    value: '$accepted',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Portfolio',
                    value: '${account.portfolio.length}',
                    icon: Icons.photo_library_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Quick actions',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            QuickActionCard(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              subtitle: 'Update your public photographer profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotographerEditProfile(
                      store: store,
                    ),
                  ),
                );
              },
            ),
            QuickActionCard(
              icon: Icons.photo_library_outlined,
              title: 'Manage portfolio',
              subtitle: 'Add or remove portfolio entries',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PortfolioManager(store: store),
                  ),
                );
              },
            ),
            QuickActionCard(
              icon: Icons.event_available_outlined,
              title: 'Availability',
              subtitle: account.acceptingBookings
                  ? 'You are accepting bookings'
                  : 'You are currently unavailable',
              onTap: () {
                store.setAcceptingBookings(!account.acceptingBookings);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER REQUESTS
// ============================================================

class PhotographerRequests extends StatelessWidget {
  final PypStore store;

  const PhotographerRequests({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final requests = store.photographerRequests;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requests',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage customer booking requests.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 30),
            if (requests.isEmpty)
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No requests yet',
                subtitle:
                'New customer booking requests will appear here.',
              ),
            ...requests.reversed.map(
                  (booking) => PhotographerRequestCard(
                booking: booking,
                onAccept: booking.status == 'Pending'
                    ? () {
                  store.updateBookingStatus(booking, 'Accepted');
                }
                    : null,
                onReject: booking.status == 'Pending'
                    ? () {
                  store.updateBookingStatus(booking, 'Rejected');
                }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER CALENDAR
// ============================================================

class PhotographerCalendar extends StatelessWidget {
  final PypStore store;

  const PhotographerCalendar({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final bookings = store.photographerRequests
        .where((booking) => booking.status != 'Cancelled')
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendar',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your accepted and pending shoots.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 30),
            if (bookings.isEmpty)
              const EmptyState(
                icon: Icons.calendar_month_outlined,
                title: 'Calendar is clear',
                subtitle: 'Confirmed shoots will appear here.',
              ),
            ...bookings.map(
                  (booking) => BookingCard(
                booking: booking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER PROFILE
// ============================================================

class PhotographerProfile extends StatelessWidget {
  final PypStore store;

  const PhotographerProfile({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final account = store.photographerAccount!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    account.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    account.specialty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0x73FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ProfileOption(
              icon: Icons.edit_outlined,
              title: 'Edit public profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotographerEditProfile(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.photo_library_outlined,
              title: 'Portfolio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PortfolioManager(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.swap_horiz_rounded,
              title: 'Switch to customer',
              onTap: store.switchToCustomer,
            ),
            ProfileOption(
              icon: Icons.visibility_outlined,
              title: 'View customer profile',
              onTap: store.switchToCustomer,
            ),
            const SizedBox(height: 20),
            SettingSwitch(
              title: 'Accept new bookings',
              subtitle: 'Show your profile as available',
              value: account.acceptingBookings,
              onChanged: store.setAcceptingBookings,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PHOTOGRAPHER EDIT PROFILE
// ============================================================

class PhotographerEditProfile extends StatefulWidget {
  final PypStore store;

  const PhotographerEditProfile({
    super.key,
    required this.store,
  });

  @override
  State<PhotographerEditProfile> createState() =>
      _PhotographerEditProfileState();
}

class _PhotographerEditProfileState extends State<PhotographerEditProfile> {
  late final TextEditingController nameController;
  late final TextEditingController specialtyController;
  late final TextEditingController priceController;
  late final TextEditingController locationController;
  late final TextEditingController bioController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController instagramController;

  late String category;

  @override
  void initState() {
    super.initState();
    final account = widget.store.photographerAccount!;
    nameController = TextEditingController(text: account.name);
    specialtyController = TextEditingController(text: account.specialty);
    priceController = TextEditingController(text: account.price);
    locationController = TextEditingController(text: account.location);
    bioController = TextEditingController(text: account.bio);
    phoneController = TextEditingController(text: account.phone);
    emailController = TextEditingController(text: account.email);
    instagramController = TextEditingController(text: account.instagram);
    category = account.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    specialtyController.dispose();
    priceController.dispose();
    locationController.dispose();
    bioController.dispose();
    phoneController.dispose();
    emailController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  void save() {
    widget.store.updatePhotographer(
      name: nameController.text.trim(),
      category: category,
      specialty: specialtyController.text.trim(),
      price: priceController.text.trim(),
      location: locationController.text.trim(),
      bio: bioController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      instagram: instagramController.text.trim(),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photographer profile updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Edit profile',
      children: [
        PypTextField(
          controller: nameController,
          label: 'Business / photographer name',
          icon: Icons.camera_alt_outlined,
        ),
        DropdownButtonFormField<String>(
          initialValue: category,
          dropdownColor: const Color(0xFF151515),
          decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: const Icon(Icons.category_outlined),
            filled: true,
            fillColor: const Color(0xFF151515),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            'Weddings',
            'Portraits',
            'Events',
            'Business',
            'Fashion',
          ]
              .map(
                (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                category = value;
              });
            }
          },
        ),
        const SizedBox(height: 12),
        PypTextField(
          controller: specialtyController,
          label: 'Specialty',
          icon: Icons.style_outlined,
        ),
        PypTextField(
          controller: priceController,
          label: 'Starting price',
          icon: Icons.currency_rupee_rounded,
        ),
        PypTextField(
          controller: locationController,
          label: 'Location',
          icon: Icons.location_on_outlined,
        ),
        PypTextField(
          controller: bioController,
          label: 'About',
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
        PypTextField(
          controller: phoneController,
          label: 'Phone',
          icon: Icons.phone_outlined,
        ),
        PypTextField(
          controller: emailController,
          label: 'Business email',
          icon: Icons.email_outlined,
        ),
        PypTextField(
          controller: instagramController,
          label: 'Instagram',
          icon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          title: 'Save profile',
          onPressed: save,
        ),
      ],
    );
  }
}

// ============================================================
// PORTFOLIO MANAGER
// ============================================================

class PortfolioManager extends StatefulWidget {
  final PypStore store;

  const PortfolioManager({
    super.key,
    required this.store,
  });

  @override
  State<PortfolioManager> createState() => _PortfolioManagerState();
}

class _PortfolioManagerState extends State<PortfolioManager> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void add() {
    final value = controller.text.trim();
    if (value.isEmpty) return;

    widget.store.addPortfolioItem(value);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = widget.store.photographerAccount!.portfolio;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Portfolio',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          const Text(
            'Add portfolio work',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For now, portfolio entries are represented as placeholders. Real image upload can be connected later.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0x73FFFFFF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Portfolio title',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF151515),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 56,
                width: 56,
                child: ElevatedButton(
                  onPressed: add,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          if (portfolio.isEmpty)
            const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'Portfolio is empty',
              subtitle: 'Add your first portfolio entry above.',
            ),
          ...List.generate(
            portfolio.length,
                (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0x73FFFFFF),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        portfolio[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.store.removePortfolioItem(index);
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0x73FFFFFF),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UI COMPONENTS
// ============================================================

class SearchBox extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const SearchBox({
    super.key,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Colors.white70,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              hint,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoverChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const DiscoverChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PhotographerCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;

  const PhotographerCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3A3A3A),
                      Color(0xFF111111),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 55,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 22,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOptionStatic extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileOptionStatic({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 22,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white30,
          ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
  });

  Color statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.white;
      case 'Rejected':
      case 'Cancelled':
        return Colors.white38;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.photographerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.category,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0x73FFFFFF),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Colors.white54,
              ),
              const SizedBox(width: 7),
              Text(
                '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: Colors.white54,
              ),
              const SizedBox(width: 7),
              Text(
                booking.time,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            booking.price,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Colors.white54,
              ),
              child: const Text('Cancel booking'),
            ),
          ],
        ],
      ),
    );
  }
}

class PhotographerRequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const PhotographerRequestCard({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer booking request',
            style: TextStyle(
              fontSize: 12,
              color: Color(0x73FFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            booking.category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Colors.white54,
              ),
              const SizedBox(width: 7),
              Text(
                '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: Colors.white54,
              ),
              const SizedBox(width: 7),
              Text(
                booking.time,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking.status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          if (onAccept != null || onReject != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white54,
            size: 20,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0x73FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0x73FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0x73FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.black,
            activeTrackColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: Colors.white38,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0x73FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class PypTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool requiredField;
  final int maxLines;
  final TextInputType? keyboardType;

  const PypTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.requiredField = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: requiredField
            ? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFF151515),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class FormScreenScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormScreenScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FLOATING NAVIGATION
// ============================================================

class FloatingNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final bool photographerMode;
  final ValueChanged<int> onSelected;

  const FloatingNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.photographerMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final customerItems = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Discover'),
      (Icons.calendar_month_rounded, 'Bookings'),
      (Icons.person_rounded, 'Profile'),
    ];

    final photographerItems = [
      (Icons.dashboard_rounded, 'Home'),
      (Icons.inbox_rounded, 'Requests'),
      (Icons.calendar_month_rounded, 'Calendar'),
      (Icons.person_rounded, 'Profile'),
    ];

    final items = photographerMode ? photographerItems : customerItems;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          items.length,
              (index) {
            final isSelected = selectedIndex == index;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: 22,
                        color: isSelected
                            ? Colors.black
                            : Colors.white70,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.black
                              : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
