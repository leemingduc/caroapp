import 'package:flutter/material.dart';
import '../app_language.dart';
import '../models/user_profile.dart';
import '../services/friends_service.dart';

class FriendsDialog extends StatefulWidget {
  final UserProfile userProfile;
  final AppLanguage language;

  const FriendsDialog({
    super.key,
    required this.userProfile,
    required this.language,
  });

  @override
  State<FriendsDialog> createState() => _FriendsDialogState();
}

class _FriendsDialogState extends State<FriendsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AppText get _t => AppText(widget.language);

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pending = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  String? _searchResult; // 'sent' | 'exists' | 'not_found' | 'self' | 'error' | null

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final uid = widget.userProfile.id;
    final friends = await FriendsService.getFriends(uid);
    final pending = await FriendsService.getPendingReceived(uid);
    if (mounted) {
      setState(() {
        _friends = friends;
        _pending = pending;
        _loading = false;
      });
    }
  }

  bool _isOnline(dynamic lastSeenAt) {
    if (lastSeenAt == null) return false;
    try {
      final dt = DateTime.parse(lastSeenAt.toString()).toLocal();
      return DateTime.now().difference(dt).inMinutes < 5;
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendRequest() async {
    final email = _searchController.text.trim();
    if (email.isEmpty) return;
    setState(() => _searching = true);
    final result =
        await FriendsService.sendRequest(widget.userProfile.id, email);
    if (mounted) {
      setState(() {
        _searching = false;
        _searchResult = result;
      });
    }
    if (result == 'sent') _loadData();
  }

  Future<void> _accept(String requestId) async {
    final ok = await FriendsService.acceptRequest(requestId);
    if (ok) _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? _t.friendAccepted : _t.friendActionFailed),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _remove(String relationshipId) async {
    final ok = await FriendsService.removeRelationship(relationshipId);
    if (ok) _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? _t.friendRemoved : _t.friendActionFailed),
        backgroundColor: ok ? Colors.blueGrey : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.people_rounded,
                      color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _t.friendsTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2),
                  ),
                ]),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon:
                      const Icon(Icons.close_rounded, color: Colors.white54),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4CAF50),
            unselectedLabelColor: Colors.white38,
            indicatorColor: const Color(0xFF4CAF50),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
            tabs: [
              Tab(text: _t.friendsTab),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_t.requestsTab),
                    if (_pending.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_pending.length}',
                          style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(text: _t.searchTab),
            ],
          ),
          // Content
          SizedBox(
            height: 340,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFriendsTab(),
                      _buildRequestsTab(),
                      _buildSearchTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (_friends.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          _t.noFriendsYet,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _friends.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.white.withOpacity(0.06)),
      itemBuilder: (_, i) {
        final f = _friends[i];
        final online = _isOnline(f['last_seen_at']);
        return ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.06),
            child: Text(
              ((f['display_name'] as String? ?? f['email'] as String? ?? '?'))
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(f['display_name'] as String? ?? f['email'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          subtitle: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: online
                      ? const Color(0xFF4CAF50)
                      : Colors.white24,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                online ? _t.online : _t.offline,
                style: TextStyle(
                    fontSize: 11,
                    color: online
                        ? const Color(0xFF4CAF50)
                        : Colors.white30),
              ),
            ],
          ),
          trailing: TextButton(
            onPressed: () =>
                _remove(f['relationship_id'] as String),
            child: Text(_t.removeFriend,
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 11)),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    if (_pending.isEmpty) {
      return Center(
          child: Text(_t.noPendingRequests,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 13)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _pending.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.white.withOpacity(0.06)),
      itemBuilder: (_, i) {
        final r = _pending[i];
        return ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.06),
            child: Text(
              ((r['display_name'] as String? ?? r['email'] as String? ?? '?'))
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(r['display_name'] as String? ?? r['email'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () =>
                    _accept(r['relationship_id'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: Text(_t.accept),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () =>
                    _remove(r['relationship_id'] as String),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(
                      color: Colors.redAccent, width: 1),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(_t.decline),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    String? resultMsg;
    Color resultColor = Colors.green;
    if (_searchResult == 'sent') {
      resultMsg = _t.friendRequestSent;
    } else if (_searchResult == 'exists') {
      resultMsg = _t.friendRequestExists;
      resultColor = Colors.orange;
    } else if (_searchResult == 'not_found') {
      resultMsg = _t.userNotFound;
      resultColor = Colors.redAccent;
    } else if (_searchResult == 'self') {
      resultMsg = _t.userNotFound;
      resultColor = Colors.orange;
    } else if (_searchResult == 'error') {
      resultMsg = _t.friendActionFailed;
      resultColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: _t.searchByEmail,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF4CAF50)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Colors.white38, size: 18),
            ),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _sendRequest(),
            onChanged: (_) => setState(() => _searchResult = null),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _searching ? null : _sendRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _searching
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(_t.addFriend,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (resultMsg != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: resultColor.withOpacity(0.3)),
              ),
              child: Text(resultMsg,
                  style: TextStyle(color: resultColor, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
