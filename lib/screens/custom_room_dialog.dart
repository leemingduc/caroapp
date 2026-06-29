import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_language.dart';
import '../models/user_profile.dart';
import '../services/pvp_room_service.dart';
import '../supabase_config.dart';

/// Callback khi trận đấu được thiết lập xong.
/// [matchId] trống nghĩa là dùng auto matchmaking.
typedef OnMatchReady = void Function(
    String matchId, String role, String opponentEmail);

class CustomRoomDialog extends StatefulWidget {
  final UserProfile userProfile;
  final AppLanguage language;
  final OnMatchReady onMatchReady;

  const CustomRoomDialog({
    super.key,
    required this.userProfile,
    required this.language,
    required this.onMatchReady,
  });

  @override
  State<CustomRoomDialog> createState() => _CustomRoomDialogState();
}

class _CustomRoomDialogState extends State<CustomRoomDialog> {
  AppText get _t => AppText(widget.language);

  // 0 = chọn chế độ, 1 = tạo phòng, 2 = vào phòng
  int _page = 0;

  // Trạng thái tạo phòng
  String? _roomCode;
  bool _creatingRoom = false;
  RealtimeChannel? _roomChannel;

  // Trạng thái vào phòng
  final TextEditingController _codeController = TextEditingController();
  bool _joiningRoom = false;
  String? _joinError;

  @override
  void dispose() {
    _roomChannel?.unsubscribe();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() => _creatingRoom = true);
    try {
      final code = await PvpRoomService.createRoom(widget.userProfile.id);
      if (!mounted) return;
      setState(() {
        _roomCode = code;
        _creatingRoom = false;
        _page = 1;
      });
      _subscribeToRoom(code);
    } catch (e) {
      if (mounted) setState(() => _creatingRoom = false);
    }
  }

  void _subscribeToRoom(String code) {
    _roomChannel = supabase
        .channel('custom_room_$code')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'custom_rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_code',
            value: code,
          ),
          callback: (payload) async {
            final record = payload.newRecord;
            if (record != null && record['status'] == 'matched') {
              final matchId = record['match_id'] as String?;
              if (matchId != null && mounted) {
                Navigator.of(context, rootNavigator: true).pop();
                widget.onMatchReady(matchId, 'X', '');
              }
            }
          },
        );
    _roomChannel!.subscribe();
  }

  Future<void> _cancelRoom() async {
    if (_roomCode != null) await PvpRoomService.cancelRoom(_roomCode!);
    _roomChannel?.unsubscribe();
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _joinError = _t.roomNotFound);
      return;
    }
    setState(() {
      _joiningRoom = true;
      _joinError = null;
    });
    final result = await PvpRoomService.joinRoom(
      code,
      widget.userProfile.id,
      widget.userProfile.email,
    );
    if (!mounted) return;
    final status = result['status'];
    if (status == 'matched') {
      Navigator.of(context, rootNavigator: true).pop();
      widget.onMatchReady(
        result['match_id'] as String,
        result['role'] as String? ?? 'O',
        result['host_email'] as String? ?? '',
      );
    } else {
      String err;
      if (status == 'self_join') {
        err = _t.roomSelfJoin;
      } else if (status == 'not_found') {
        err = _t.roomNotFound;
      } else {
        err = _t.roomJoinFailed;
      }
      setState(() {
        _joiningRoom = false;
        _joinError = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _page == 0
              ? _buildChoosePage()
              : _page == 1
                  ? _buildCreatePage()
                  : _buildJoinPage(),
        ),
      ),
    );
  }

  Widget _buildChoosePage() {
    return Column(
      key: const ValueKey('choose'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t.pvpModeTitle,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 20),
        _modeButton(
          icon: Icons.shuffle_rounded,
          iconColor: const Color(0xFF00F2FE),
          title: _t.autoMatchmaking,
          desc: _t.autoMatchmakingDesc,
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            widget.onMatchReady('', 'X', '');
          },
        ),
        const SizedBox(height: 10),
        _modeButton(
          icon: Icons.add_box_rounded,
          iconColor: const Color(0xFF4CAF50),
          title: _t.createRoom,
          desc: _t.createRoomDesc,
          onTap: _creatingRoom ? null : _createRoom,
          loading: _creatingRoom,
        ),
        const SizedBox(height: 10),
        _modeButton(
          icon: Icons.login_rounded,
          iconColor: const Color(0xFFFFB300),
          title: _t.joinRoom,
          desc: _t.joinRoomDesc,
          onTap: () => setState(() => _page = 2),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(),
          child: Text(_t.cancel,
              style: const TextStyle(color: Colors.white38)),
        ),
      ],
    );
  }

  Widget _modeButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: iconColor))
                    : Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(desc,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePage() {
    return Column(
      key: const ValueKey('create'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_t.createRoom,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 20),
        Text(_t.yourRoomCode,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 12),
        // Mã phòng lớn
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _roomCode ?? '------',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: _roomCode ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(_t.codeCopied),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ));
                },
                icon: const Icon(Icons.copy_rounded,
                    color: Colors.white38, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 10),
            Text(_t.waitingForGuest,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _cancelRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFFF43F5E).withOpacity(0.15),
            foregroundColor: const Color(0xFFF43F5E),
            side: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(_t.cancelRoom,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildJoinPage() {
    return Column(
      key: const ValueKey('join'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_t.joinRoom,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 20),
        TextField(
          controller: _codeController,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 8),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            hintText: _t.roomCodeHint,
            hintStyle: const TextStyle(
                color: Colors.white24, letterSpacing: 1, fontSize: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFFFB300))),
          ),
          onChanged: (_) => setState(() => _joinError = null),
          onSubmitted: (_) => _joinRoom(),
        ),
        if (_joinError != null) ...[
          const SizedBox(height: 8),
          Text(_joinError!,
              style:
                  const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _joiningRoom ? null : _joinRoom,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: _joiningRoom
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : Text(_t.joinRoomButton,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() {
            _page = 0;
            _joinError = null;
          }),
          child: Text(_t.cancel,
              style: const TextStyle(color: Colors.white38)),
        ),
      ],
    );
  }
}
