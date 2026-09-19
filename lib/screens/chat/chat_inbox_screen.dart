import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/pyp_store.dart';
import 'chat_room_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  final String? currentUserId;
  final ChatProvider? chatProvider;
  final PypStore? store;
  final AuthProvider? authProvider;
  final bool isTab;

  const ChatInboxScreen({
    super.key,
    this.currentUserId,
    this.chatProvider,
    this.store,
    this.authProvider,
    this.isTab = false,
  });

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  late final ChatProvider _provider;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _provider = widget.chatProvider ?? widget.store?.chatProvider ?? ChatProvider();
    _syncConversations();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    widget.store?.addListener(_onStoreUpdated);
  }

  void _onStoreUpdated() {
    if (mounted) {
      _syncConversations();
    }
  }

  void _syncConversations() {
    final identifiers = _resolveUserIdentifiers();
    _provider.streamConversations(identifiers);
  }

  @override
  void didUpdateWidget(covariant ChatInboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store ||
        oldWidget.currentUserId != widget.currentUserId) {
      _syncConversations();
    }
  }

  @override
  void dispose() {
    widget.store?.removeListener(_onStoreUpdated);
    _searchController.dispose();
    super.dispose();
  }

  List<String> _resolveUserIdentifiers() {
    if (widget.store != null) {
      return widget.store!.currentUserChatIdentifiers;
    }
    if (widget.currentUserId != null && widget.currentUserId!.isNotEmpty) {
      return [widget.currentUserId!];
    }
    return ['customer_1'];
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  PhotographerModel? _findPhotographer(String identifier, String name) {
    if (widget.store == null) return null;
    try {
      return widget.store!.photographers.firstWhere(
        (p) =>
            (identifier.isNotEmpty && (p.id == identifier || p.uid == identifier)) ||
            p.name.toLowerCase() == name.toLowerCase() ||
            p.name.toLowerCase() == identifier.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void _openNewChatSheet() {
    final photographers = widget.store?.photographers ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Message',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white60),
                      ),
                    ],
                  ),
                  const Text(
                    'Select a photographer to start a conversation',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: photographers.isEmpty
                        ? const Center(
                            child: Text(
                              'No photographers available',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: photographers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (_, idx) {
                              final p = photographers[idx];
                              return ListTile(
                                tileColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: AppColors.borderLight),
                                ),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.cardElevated,
                                  backgroundImage: p.profileImageUrl != null
                                      ? NetworkImage(p.profileImageUrl!)
                                      : null,
                                  child: p.profileImageUrl == null
                                      ? Text(
                                          p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${p.category} • ${p.price}',
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  final identifiers = _resolveUserIdentifiers();
                                  final currentUserId = identifiers.first;
                                  final customerName = widget.store?.user.name.isNotEmpty == true &&
                                          widget.store?.user.name != 'PYP User'
                                      ? widget.store!.user.name
                                      : 'Customer';

                                  final convoId = await _provider.startConversationWithPhotographer(
                                    customerId: currentUserId,
                                    customerName: customerName,
                                    photographer: p,
                                    customerAliases: identifiers,
                                  );

                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatRoomScreen(
                                          conversationId: convoId,
                                          recipientName: p.name,
                                          recipientId: p.id.isNotEmpty ? p.id : p.name,
                                          recipientPhoto: p.profileImageUrl,
                                          currentUserId: currentUserId,
                                          chatProvider: _provider,
                                          store: widget.store,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
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

  @override
  Widget build(BuildContext context) {
    final userIdentifiers = _resolveUserIdentifiers();
    final isPhotographerMode = widget.store?.role == UserRole.photographer;

    Widget bodyContent = ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final allConvos = _provider.conversations;

        final filteredConvos = _searchQuery.isEmpty
            ? allConvos
            : allConvos.where((c) {
                final otherName = c.getOtherParticipantName(userIdentifiers).toLowerCase();
                final msg = c.lastMessage.toLowerCase();
                return otherName.contains(_searchQuery) || msg.contains(_searchQuery);
              }).toList();

        return Column(
          children: [
            // Search & New Chat Action Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search chats...',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
                                  onPressed: () => _searchController.clear(),
                                  padding: EdgeInsets.zero,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openNewChatSheet,
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add_rounded, color: Colors.black, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'New',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Conversations List
            Expanded(
              child: filteredConvos.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No chats matching "$_searchQuery"'
                                  : (isPhotographerMode
                                      ? 'No client inquiries yet'
                                      : 'No conversations yet'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Try searching with a different name or keyword.'
                                  : (isPhotographerMode
                                      ? 'Incoming client messages, package requests, and shoot inquiries will appear here.'
                                      : 'Start a message with a photographer to discuss dates, packages, or custom quotes.'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (!isPhotographerMode)
                              ElevatedButton.icon(
                                onPressed: _openNewChatSheet,
                                icon: const Icon(Icons.add_comment_rounded, size: 18),
                                label: const Text('Start a Conversation'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        widget.isTab ? 110 : 30,
                      ),
                      itemCount: filteredConvos.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final convo = filteredConvos[index];
                        final displayName = convo.getOtherParticipantName(userIdentifiers);
                        final displayPhoto = convo.getOtherParticipantPhoto(userIdentifiers);
                        final otherId = convo.customerId.isNotEmpty &&
                                userIdentifiers.map((e) => e.toLowerCase()).contains(convo.customerId.toLowerCase())
                            ? convo.photographerId
                            : convo.customerId;

                        final matchedPhotographer = _findPhotographer(otherId, displayName);
                        final timeStr = _formatTimestamp(convo.updatedAt ?? convo.createdAt);

                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                    conversationId: convo.id,
                                    recipientName: displayName.isNotEmpty
                                        ? displayName
                                        : (matchedPhotographer?.name ?? otherId),
                                    recipientId: otherId,
                                    recipientPhoto: displayPhoto ??
                                        matchedPhotographer?.profileImageUrl,
                                    currentUserId: userIdentifiers.first,
                                    chatProvider: _provider,
                                    store: widget.store,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppColors.cardElevated,
                                        backgroundImage: displayPhoto != null &&
                                                (displayPhoto.startsWith('http://') ||
                                                    displayPhoto.startsWith('https://'))
                                            ? NetworkImage(displayPhoto)
                                            : (matchedPhotographer?.profileImageUrl != null
                                                ? NetworkImage(
                                                    matchedPhotographer!.profileImageUrl!)
                                                : null),
                                        child: (displayPhoto == null &&
                                                matchedPhotographer?.profileImageUrl == null)
                                            ? Text(
                                                displayName.isNotEmpty
                                                    ? displayName[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.surface,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                displayName.isNotEmpty
                                                    ? displayName
                                                    : (matchedPhotographer?.name ?? otherId),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (timeStr.isNotEmpty)
                                              Text(
                                                timeStr,
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (matchedPhotographer != null) ...[
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.cardElevated,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              matchedPhotographer.category,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                        Text(
                                          convo.lastMessage.isNotEmpty
                                              ? convo.lastMessage
                                              : 'Tap to view conversation',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );

    if (widget.isTab) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _openNewChatSheet,
                    tooltip: 'New message',
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.edit_square,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: bodyContent),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _openNewChatSheet,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
