import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/pyp_store.dart';
import '../customer/booking_screen.dart';
import '../customer/photographer_details_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String recipientName;
  final String currentUserId;
  final String? recipientPhoto;
  final String? recipientId;
  final ChatProvider? chatProvider;
  final PypStore? store;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    required this.currentUserId,
    this.recipientPhoto,
    this.recipientId,
    this.chatProvider,
    this.store,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatProvider _provider;
  bool _hasText = false;

  final List<String> _quickPrompts = [
    'Are you available next weekend?',
    'What packages do you offer?',
    'Can I see your recent work?',
    'What is your hourly rate?',
  ];

  @override
  void initState() {
    super.initState();
    _provider = widget.chatProvider ?? widget.store?.chatProvider ?? ChatProvider();
    _provider.streamMessages(widget.conversationId);
    _controller.addListener(() {
      final hasNow = _controller.text.trim().isNotEmpty;
      if (hasNow != _hasText) {
        setState(() {
          _hasText = hasNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  PhotographerModel? _findPhotographer() {
    if (widget.store == null) return null;
    final id = widget.recipientId ?? '';
    final name = widget.recipientName.toLowerCase();
    try {
      return widget.store!.photographers.firstWhere(
        (p) =>
            (id.isNotEmpty && (p.id == id || p.uid == id)) ||
            p.name.toLowerCase() == name,
      );
    } catch (_) {
      return null;
    }
  }

  void _sendMessage([String? predefinedText]) {
    final text = predefinedText ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (predefinedText == null) {
      _controller.clear();
    }

    final isPhotographerMode = widget.store?.role == UserRole.photographer;
    final senderName = widget.store?.user.name.isNotEmpty == true &&
            widget.store?.user.name != 'PYP User'
        ? widget.store!.user.name
        : (isPhotographerMode ? 'Photographer' : 'Customer');

    final matchedPhoto = _findPhotographer();
    final additional = <String>{
      if (widget.store != null) ...widget.store!.currentUserChatIdentifiers,
      if (matchedPhoto != null) ...[
        if (matchedPhoto.id.isNotEmpty) matchedPhoto.id,
        if (matchedPhoto.uid.isNotEmpty) matchedPhoto.uid,
        if (matchedPhoto.name.isNotEmpty) matchedPhoto.name,
        if (matchedPhoto.email.isNotEmpty) matchedPhoto.email,
      ],
    }.toList();

    _provider.sendMessage(
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      senderName: senderName,
      message: text,
      recipientId: widget.recipientId,
      recipientName: widget.recipientName,
      customerName: isPhotographerMode ? widget.recipientName : senderName,
      photographerName: isPhotographerMode
          ? (widget.store?.photographerAccount?.name ?? senderName)
          : widget.recipientName,
      customerId: isPhotographerMode ? widget.recipientId : widget.currentUserId,
      photographerId: isPhotographerMode ? widget.currentUserId : widget.recipientId,
      additionalParticipants: additional,
    );

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final matchedPhotographer = _findPhotographer();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.cardElevated,
                  backgroundImage: widget.recipientPhoto != null &&
                          (widget.recipientPhoto!.startsWith('http://') ||
                              widget.recipientPhoto!.startsWith('https://'))
                      ? NetworkImage(widget.recipientPhoto!)
                      : (matchedPhotographer?.profileImageUrl != null
                          ? NetworkImage(matchedPhotographer!.profileImageUrl!)
                          : null),
                  child: widget.recipientPhoto == null &&
                          matchedPhotographer?.profileImageUrl == null
                      ? Text(
                          widget.recipientName.isNotEmpty
                              ? widget.recipientName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.recipientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    matchedPhotographer != null
                        ? '${matchedPhotographer.category} • Active now'
                        : 'Active now',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (matchedPhotographer != null && widget.store != null) ...[
            IconButton(
              tooltip: 'Book Photographer',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(
                      photographer: matchedPhotographer,
                      store: widget.store!,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
              ),
            ),
            IconButton(
              tooltip: 'View Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotographerDetailsScreen(
                      photographer: matchedPhotographer,
                      store: widget.store!,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _provider,
              builder: (context, _) {
                final messages = _provider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 28,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chat with ${widget.recipientName}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ask about availability, packages, or request custom quotes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _quickPrompts.map((prompt) {
                              return ActionChip(
                                label: Text(prompt),
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                backgroundColor: AppColors.cardElevated,
                                side: BorderSide(color: AppColors.borderLight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onPressed: () => _sendMessage(prompt),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final userIdentifiers = widget.store?.currentUserChatIdentifiers ??
                    [widget.currentUserId];
                final lowerUserIdentifiers =
                    userIdentifiers.map((e) => e.toLowerCase()).toSet();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = lowerUserIdentifiers.contains(msg.senderId.toLowerCase()) ||
                        (msg.senderName.isNotEmpty &&
                            lowerUserIdentifiers.contains(msg.senderName.toLowerCase())) ||
                        msg.senderId == 'local_${widget.currentUserId}' ||
                        msg.senderId == widget.currentUserId;

                    final timeStr = _formatTime(msg.createdAt);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.white : AppColors.cardElevated,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.message,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: isMe ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (timeStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.black54 : Colors.white38,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo attachment ready for upload.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: _hasText ? Colors.white : AppColors.cardElevated,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _hasText ? () => _sendMessage() : null,
                      icon: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: _hasText ? Colors.black : Colors.white30,
                      ),
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
}
