import 'package:flutter/material.dart';
import '../app_language.dart';
import '../models/emote_config.dart';

/// Callback when user selects an emote or chat message.
typedef OnEmoteOrChat = void Function({String? emoteId, String? chatMessage});

class EmoteChatPanel extends StatefulWidget {
  final List<String> unlockedEmotes;
  final AppLanguage language;
  final OnEmoteOrChat onSend;

  const EmoteChatPanel({
    super.key,
    required this.unlockedEmotes,
    required this.language,
    required this.onSend,
  });

  @override
  State<EmoteChatPanel> createState() => _EmoteChatPanelState();
}

class _EmoteChatPanelState extends State<EmoteChatPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AppText get _t => AppText(widget.language);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF00F2FE),
            unselectedLabelColor: Colors.white38,
            indicatorColor: const Color(0xFF00F2FE),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
            tabs: [
              Tab(text: _t.emotesTab),
              Tab(text: _t.quickChatTab),
            ],
          ),
          // Content
          SizedBox(
            height: 220,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmotesGrid(),
                _buildQuickChatList(),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEmotesGrid() {
    return GridView.count(
      crossAxisCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: EmoteConfig.allEmotes.map((emote) {
        final owned = widget.unlockedEmotes.contains(emote.id);
        return GestureDetector(
          onTap: owned
              ? () {
                  Navigator.of(context).pop();
                  widget.onSend(emoteId: emote.id);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: owned
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: owned
                    ? Colors.white.withOpacity(0.12)
                    : Colors.white.withOpacity(0.04),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  emote.emoji,
                  style: TextStyle(
                    fontSize: 26,
                    color: owned ? null : Colors.white24.withOpacity(0.1),
                  ),
                ),
                if (!owned) ...[
                  const Text('🔒', style: TextStyle(fontSize: 16)),
                  Positioned(
                    bottom: 2,
                    child: Text(
                      '50 💎',
                      style: const TextStyle(
                          fontSize: 8,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickChatList() {
    final messages = _t.quickChatMessages;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
      itemBuilder: (_, i) {
        final msg = messages[i];
        return InkWell(
          onTap: () {
            Navigator.of(context).pop();
            widget.onSend(chatMessage: msg);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              msg,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
  }
}
