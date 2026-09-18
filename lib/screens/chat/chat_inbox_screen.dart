import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/common/empty_state.dart';
import 'chat_room_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  final String currentUserId;
  final ChatProvider? chatProvider;

  const ChatInboxScreen({
    super.key,
    required this.currentUserId,
    this.chatProvider,
  });

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  late final ChatProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.chatProvider ?? ChatProvider();
    _provider.streamConversations(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          final convos = _provider.conversations;

          if (convos.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              subtitle: 'Message a photographer or customer to start chatting.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            itemCount: convos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final convo = convos[index];
              final otherId = convo.customerId == widget.currentUserId
                  ? convo.photographerId
                  : convo.customerId;

              return ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.cardElevated,
                  child: const Icon(Icons.person, color: Colors.white70),
                ),
                title: Text(
                  otherId.isNotEmpty ? otherId : 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  convo.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        conversationId: convo.id,
                        recipientName: otherId,
                        currentUserId: widget.currentUserId,
                        chatProvider: _provider,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
