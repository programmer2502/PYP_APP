import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/navigation/floating_navigation_bar.dart';
import '../chat/chat_inbox_screen.dart';
import '../customer/customer_bookings_content.dart';
import '../customer/customer_profile_content.dart';
import '../customer/discover_content.dart';
import '../customer/home_content.dart';
import '../photographer/photographer_calendar_content.dart';
import '../photographer/photographer_dashboard_content.dart';
import '../photographer/photographer_profile_content.dart';
import '../photographer/photographer_requests_content.dart';

class HomeScreen extends StatefulWidget {
  final PypStore store;
  final AuthProvider? authProvider;

  const HomeScreen({
    super.key,
    required this.store,
    this.authProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  UserRole? _previousRole;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final isPhotographer = widget.store.role == UserRole.photographer;

        // When switching between Customer and Photographer modes, reset to first tab
        if (_previousRole != null && _previousRole != widget.store.role) {
          selectedIndex = 0;
        }
        _previousRole = widget.store.role;

        final customerPages = [
          HomeContent(store: widget.store),
          DiscoverContent(store: widget.store),
          BookingsContent(store: widget.store),
          ChatInboxScreen(
            store: widget.store,
            chatProvider: widget.store.chatProvider,
            authProvider: widget.authProvider,
            isTab: true,
          ),
          ProfileContent(
            store: widget.store,
            authProvider: widget.authProvider,
          ),
        ];

        final photographerPages = [
          PhotographerDashboard(store: widget.store),
          PhotographerRequests(store: widget.store),
          PhotographerCalendar(store: widget.store),
          ChatInboxScreen(
            store: widget.store,
            chatProvider: widget.store.chatProvider,
            authProvider: widget.authProvider,
            isTab: true,
          ),
          PhotographerProfile(
            store: widget.store,
            authProvider: widget.authProvider,
          ),
        ];

        final pages = isPhotographer ? photographerPages : customerPages;

        if (selectedIndex >= pages.length) {
          selectedIndex = 0;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
              Positioned(
                left: 16,
                right: 16,
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
      },
    );
  }
}
