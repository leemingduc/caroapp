import 'package:flutter/material.dart';
import '../services/db_service.dart';

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      elevation: 24,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFB300),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'BẢNG XẾP HẠNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // Realtime leaderboard stream
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: DbService.getLeaderboardStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00F2FE),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Không thể tải bảng xếp hạng.\nVui lòng thử lại!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 13),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có dữ liệu người chơi.',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final email = item['email'] ?? 'Ẩn danh';
                        final diamonds = item['diamonds'] ?? 0;
                        final wins = item['wins_pvc'] ?? 0;
                        
                        return _buildLeaderboardRow(index + 1, email, diamonds, wins);
                      },
                    );
                  },
                ),
              ),
              
              // Close button
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.06),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  elevation: 0,
                ),
                child: const Text('ĐÓNG BẢNG XẾP HẠNG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, String email, int diamonds, int wins) {
    Widget rankIcon;
    Color? rankBgColor;
    Color? borderGlowColor;

    if (rank == 1) {
      rankIcon = const Text('🥇', style: TextStyle(fontSize: 22));
      rankBgColor = const Color(0xFFFFB300).withOpacity(0.08);
      borderGlowColor = const Color(0xFFFFB300).withOpacity(0.4);
    } else if (rank == 2) {
      rankIcon = const Text('🥈', style: TextStyle(fontSize: 22));
      rankBgColor = Colors.white.withOpacity(0.04);
      borderGlowColor = Colors.white.withOpacity(0.2);
    } else if (rank == 3) {
      rankIcon = const Text('🥉', style: TextStyle(fontSize: 22));
      rankBgColor = Colors.orangeAccent.withOpacity(0.04);
      borderGlowColor = Colors.orangeAccent.withOpacity(0.2);
    } else {
      rankIcon = Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      rankBgColor = Colors.transparent;
      borderGlowColor = Colors.white.withOpacity(0.04);
    }

    // Mask email for privacy (e.g. user***@gmail.com)
    String displayName = email;
    if (email.contains('@') && !email.contains('🤖')) {
      final parts = email.split('@');
      final name = parts[0];
      if (name.length > 3) {
        displayName = '${name.substring(0, 3)}***@${parts[1]}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rankBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGlowColor, width: rank <= 3 ? 1.5 : 1),
      ),
      child: Row(
        children: [
          rankIcon,
          const SizedBox(width: 14),
          
          // Display Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: rank <= 3 ? Colors.white : Colors.white70,
                    fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Thắng máy: $wins trận',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          
          // Diamonds count
          Row(
            children: [
              const Text('💎 ', style: TextStyle(fontSize: 13)),
              Text(
                '$diamonds',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
