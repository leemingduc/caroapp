import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

// ─── Game Mode & AI Difficulty ────────────────────────────────────────────
enum GameMode { pvp, pvc }

enum AiDifficulty { easy, amateur, medium, semiPro, professional }

extension AiDifficultyExt on AiDifficulty {
  String get label {
    switch (this) {
      case AiDifficulty.easy:         return '🎮 Dễ';
      case AiDifficulty.amateur:      return '🏠 Nghiệp dư';
      case AiDifficulty.medium:       return '⚔️ Trung bình';
      case AiDifficulty.semiPro:      return '🎯 Bán chuyên';
      case AiDifficulty.professional: return '🏆 Chuyên nghiệp';
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Supabase
  await initSupabase();

  runApp(const CaroApp());
}

class CaroApp extends StatelessWidget {
  const CaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caro Master Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = supabase.auth.currentUser;
        if (user == null) {
          return const LoginScreen();
        }

        return CaroGameScreen(userEmail: user.email ?? 'Unknown user');
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isRegisterMode) {
        await _signUp();
      } else {
        await _signIn();
      }
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Khong the xu ly yeu cau. Vui long thu lai.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signIn() async {
    await supabase.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _signUp() async {
    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || response.session != null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dang ky thanh cong. Vui long kiem tra email de xac nhan tai khoan.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleAuthMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _confirmPasswordController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF020617),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  color: const Color(0xFF111827),
                  elevation: 16,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.grid_4x4_rounded,
                            color: Color(0xFF00F2FE),
                            size: 44,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'CARO ARENA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Dang nhap'),
                                icon: Icon(Icons.login_rounded),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Dang ky'),
                                icon: Icon(Icons.person_add_alt_1_rounded),
                              ),
                            ],
                            selected: {_isRegisterMode},
                            onSelectionChanged: _isLoading
                                ? null
                                : (selection) {
                                    final nextMode = selection.first;
                                    if (nextMode != _isRegisterMode) {
                                      _toggleAuthMode();
                                    }
                                  },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Vui long nhap email';
                              if (!email.contains('@')) return 'Email khong hop le';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword ? 'Hien password' : 'An password',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) return 'Vui long nhap password';
                              return null;
                            },
                          ),
                          if (_isRegisterMode) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: const InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: Icon(Icons.verified_user_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (!_isRegisterMode) return null;
                                if ((value ?? '').isEmpty) {
                                  return 'Vui long nhap lai password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password khong trung khop';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(_isRegisterMode
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.login_rounded),
                            label: Text(_isRegisterMode ? 'Dang ky tai khoan' : 'Dang nhap'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isLoading ? null : _toggleAuthMode,
                            child: Text(
                              _isRegisterMode
                                  ? 'Da co tai khoan? Dang nhap'
                                  : 'Chua co tai khoan? Dang ky ngay',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CaroGameScreen extends StatefulWidget {
  const CaroGameScreen({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<CaroGameScreen> createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> with SingleTickerProviderStateMixin {
  // Game Configuration
  int _boardSize = 10; // default 10x10

  // Win length lookup table:
  // 3-4   → 3 ô
  // 5     → 4 ô
  // 6-14  → 5 ô
  // 15-19 → 6 ô
  // 20-24 → 7 ô
  // 25-29 → 8 ô
  // 30-35 → 9 ô
  int get _winLength {
    if (_boardSize <= 4)  return 3;
    if (_boardSize == 5)  return 4;
    if (_boardSize <= 14) return 5;
    if (_boardSize <= 19) return 6;
    if (_boardSize <= 24) return 7;
    if (_boardSize <= 29) return 8;
    return 9; // 30-35
  }
  bool _doubleBlockRule = true; // Rules: Vietnamese blocked-at-both-ends rule
  final double _cellSize = 44.0;

  // Game State
  final Map<Point<int>, String> _board = {}; // Coordinates mapped to 'X' or 'O'
  bool _isXTurn = true;
  String? _winner; // 'X', 'O', 'Draw', or null
  List<Point<int>>? _winningLine; // Coordinates of the 5 winning cells
  Point<int>? _lastMove;
  Point<int>? _hoveredCell;

  // Reward points, hint and revive states
  int _rewardPoints = 100;
  int _reviveCount = 0;
  Point<int>? _hintCell;

  // AI / Game Mode State
  GameMode _gameMode = GameMode.pvp;
  AiDifficulty _aiDifficulty = AiDifficulty.medium;
  bool _aiThinking = false;
  
  // History for Undo
  final List<Point<int>> _moveHistory = [];

  // Match statistics
  int _scoreX = 0;
  int _scoreO = 0;
  int _scoreDraws = 0;

  // Helpers for reward system
  int _getReviveCost() {
    return 20 * (1 << _reviveCount);
  }

  int _getWinPoints() {
    switch (_aiDifficulty) {
      case AiDifficulty.easy: return 10;
      case AiDifficulty.amateur: return 20;
      case AiDifficulty.medium: return 40;
      case AiDifficulty.semiPro: return 75;
      case AiDifficulty.professional: return 150;
    }
  }

  void _reviveWithPoints() {
    final cost = _getReviveCost();
    if (_rewardPoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Bạn không đủ điểm thưởng để hồi sinh!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _rewardPoints -= cost;
      _reviveCount++;
      
      // Revert AI's winning move
      if (_moveHistory.isNotEmpty && _winner == 'O') {
        final lastAiMove = _moveHistory.removeLast();
        _board.remove(lastAiMove);
        _scoreO = max(0, _scoreO - 1);
      }
      
      _winner = null;
      _winningLine = null;
      _isXTurn = true;
      _lastMove = _moveHistory.isNotEmpty ? _moveHistory.last : null;
      _hintCell = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Hồi sinh thành công! Sử dụng hết $cost điểm.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _useAiHint() {
    if (_gameMode != GameMode.pvc || !_isXTurn || _winner != null || _aiThinking) return;
    if (_rewardPoints < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Bạn không đủ điểm thưởng để nhận gợi ý (cần 15 điểm)!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Calculate best move for X by swapping X and O
    final swappedBoard = _board.map((key, value) {
      return MapEntry(key, value == 'X' ? 'O' : 'X');
    });

    final hint = CaroAI.getBestMove(
      board: swappedBoard,
      boardSize: _boardSize,
      winLength: _winLength,
      difficulty: _aiDifficulty,
    );

    if (hint != null) {
      setState(() {
        _rewardPoints -= 15;
        _hintCell = hint;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💡 Đã hiển thị gợi ý AI! Trừ 15 điểm.'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm được nước gợi ý phù hợp.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _showReviveDialog() {
    final cost = _getReviveCost();
    final canAfford = _rewardPoints >= cost;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.dangerous_rounded, color: Color(0xFFF43F5E), size: 28),
              SizedBox(width: 10),
              Text(
                'MÁY ĐÃ THẮNG!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn đã bị Máy đánh bại. Bạn có muốn hồi sinh để tiếp tục trận đấu không?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phí hồi sinh:', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text(
                      '$cost Điểm',
                      style: TextStyle(
                        color: canAfford ? const Color(0xFFFFB300) : const Color(0xFFF43F5E),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Điểm hiện tại của bạn: $_rewardPoints điểm',
                style: TextStyle(
                  color: canAfford ? Colors.white54 : const Color(0xFFF43F5E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chấp nhận thua', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: canAfford
                  ? () {
                      Navigator.of(context).pop();
                      _reviveWithPoints();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F2FE),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white10,
                disabledForegroundColor: Colors.white30,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(canAfford ? 'Hồi sinh ngay' : 'Không đủ điểm'),
            ),
          ],
        );
      },
    );
  }

  // InteractiveViewer controls
  final TransformationController _transformationController = TransformationController();
  Size? _lastViewportSize;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // Centering board logic based on viewport constraints
  void _resetBoardView(Size viewportSize) {
    final double boardSizePx = _boardSize * _cellSize;
    double scale = 1.0;
    
    // Scale board to fit viewport with 80% width/height margin
    if (boardSizePx > viewportSize.width || boardSizePx > viewportSize.height) {
      final scaleX = (viewportSize.width * 0.82) / boardSizePx;
      final scaleY = (viewportSize.height * 0.82) / boardSizePx;
      scale = min(scaleX, scaleY);
      if (scale < 0.25) scale = 0.25;
    }

    final double tx = (viewportSize.width - boardSizePx * scale) / 2;
    final double ty = (viewportSize.height - boardSizePx * scale) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);
  }

  // Reset current match state
  void _resetMatch({bool clearScore = false}) {
    setState(() {
      _board.clear();
      _moveHistory.clear();
      _isXTurn = true;
      _winner = null;
      _winningLine = null;
      _lastMove = null;
      _hoveredCell = null;
      _aiThinking = false;
      _reviveCount = 0;
      _hintCell = null;
      if (clearScore) {
        _scoreX = 0;
        _scoreO = 0;
        _scoreDraws = 0;
        _rewardPoints = 100;
      }
    });
    
    // Force center alignment after board changes
    if (_lastViewportSize != null) {
      _resetBoardView(_lastViewportSize!);
    }
  }

  // Handle cell tap
  void _handleCellTap(int r, int c) {
    final cell = Point(r, c);
    // Block taps when AI is thinking or when it's AI's turn in PvC
    if (_board[cell] != null || _winner != null || _aiThinking) return;
    if (_gameMode == GameMode.pvc && !_isXTurn) return;

    bool shouldTriggerAI = false;
    setState(() {
      _hintCell = null; // Clear hint on move
      final actualPlayer = (_gameMode == GameMode.pvp) ? (_isXTurn ? 'X' : 'O') : 'X';
      _board[cell] = actualPlayer;
      _lastMove = cell;
      _moveHistory.add(cell);

      HapticFeedback.lightImpact();

      final winLine = _checkWin(r, c, actualPlayer);
      if (winLine != null) {
        _winner = actualPlayer;
        _winningLine = winLine;
        if (actualPlayer == 'X') {
          _scoreX++;
          if (_gameMode == GameMode.pvc) {
            final winPts = _getWinPoints();
            _rewardPoints += winPts;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Chiến thắng! Bạn nhận được +$winPts điểm thưởng.'),
                  backgroundColor: Colors.amber[800],
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }
        } else {
          _scoreO++;
        }
      } else {
        if (_board.length == _boardSize * _boardSize) {
          _winner = 'Draw';
          _scoreDraws++;
        } else {
          _isXTurn = !_isXTurn;
          if (_gameMode == GameMode.pvc && !_isXTurn) {
            shouldTriggerAI = true;
          }
        }
      }

      if (_hoveredCell == cell) _hoveredCell = null;
    });

    if (shouldTriggerAI) _triggerAiMove();
  }

  // Trigger AI move asynchronously
  Future<void> _triggerAiMove() async {
    if (!mounted || _winner != null) return;
    setState(() => _aiThinking = true);

    // Delay to simulate thinking (longer = harder looks more thoughtful)
    int delay;
    switch (_aiDifficulty) {
      case AiDifficulty.easy:         delay = 300; break;
      case AiDifficulty.amateur:      delay = 400; break;
      case AiDifficulty.medium:       delay = 550; break;
      case AiDifficulty.semiPro:      delay = 750; break;
      case AiDifficulty.professional: delay = 950; break;
    }
    await Future.delayed(Duration(milliseconds: delay));

    if (!mounted || _winner != null) {
      if (mounted) setState(() => _aiThinking = false);
      return;
    }

    final move = CaroAI.getBestMove(
      board: Map.from(_board),
      boardSize: _boardSize,
      winLength: _winLength,
      difficulty: _aiDifficulty,
    );

    if (!mounted) return;
    if (move == null || _board.containsKey(move)) {
      setState(() => _aiThinking = false);
      return;
    }

    setState(() {
      _hintCell = null; // Clear hint on move
      _aiThinking = false;
      _board[move] = 'O';
      _lastMove = move;
      _moveHistory.add(move);

      final winLine = _checkWin(move.x, move.y, 'O');
      if (winLine != null) {
        _winner = 'O';
        _winningLine = winLine;
        _scoreO++;
      } else if (_board.length == _boardSize * _boardSize) {
        _winner = 'Draw';
        _scoreDraws++;
      } else {
        _isXTurn = true;
      }
    });

    if (_winner == 'O' && _gameMode == GameMode.pvc) {
      _showReviveDialog();
    }
  }

  // Undo the last move
  void _undoLastMove() {
    if (_moveHistory.isEmpty || _aiThinking) return;

    setState(() {
      _hintCell = null;
      // Clear winner state
      if (_winner != null) {
        if (_winner == 'X') _scoreX = max(0, _scoreX - 1);
        else if (_winner == 'O') _scoreO = max(0, _scoreO - 1);
        else _scoreDraws = max(0, _scoreDraws - 1);
        _winner = null;
        _winningLine = null;
      }

      // In PvC, undo 2 moves (AI's O + player's X) so it's always player's turn after undo
      final movesToUndo = (_gameMode == GameMode.pvc && _moveHistory.length >= 2) ? 2 : 1;
      String? lastUndone;
      for (int i = 0; i < movesToUndo; i++) {
        if (_moveHistory.isEmpty) break;
        final last = _moveHistory.removeLast();
        lastUndone = _board.remove(last);
      }

      // Restore turn
      if (_gameMode == GameMode.pvc) {
        _isXTurn = true; // Always player's (X) turn after undo
      } else {
        _isXTurn = lastUndone == 'X';
      }

      _lastMove = _moveHistory.isNotEmpty ? _moveHistory.last : null;
    });
  }

  // Main Win Checker Algorithm
  List<Point<int>>? _checkWin(int r, int c, String player) {
    final int winLen = _winLength;
    final directions = [
      [0, 1],   // Horizontal
      [1, 0],   // Vertical
      [1, 1],   // Diagonal \
      [1, -1],  // Diagonal /
    ];

    for (final dir in directions) {
      final dr = dir[0];
      final dc = dir[1];
      List<Point<int>> line = [Point(r, c)];

      // Positive check
      int nr = r + dr;
      int nc = c + dc;
      while (nr >= 0 && nr < _boardSize && nc >= 0 && nc < _boardSize && _board[Point(nr, nc)] == player) {
        line.add(Point(nr, nc));
        nr += dr;
        nc += dc;
      }

      // Negative check
      nr = r - dr;
      nc = c - dc;
      while (nr >= 0 && nr < _boardSize && nc >= 0 && nc < _boardSize && _board[Point(nr, nc)] == player) {
        line.add(Point(nr, nc));
        nr -= dr;
        nc -= dc;
      }

      if (line.length >= winLen) {
        if (_doubleBlockRule) {
          // Apply Vietnamese double-blocked rule check (only applies when win length >= 5)
          if (winLen >= 5) {
            final blocked = _isBlockedBothEnds(line, dr, dc, player);
            if (blocked) {
              continue; // Skip this direction as it's blocked, try other directions
            }
          }
        }
        // Return exactly winLen cells (sorted along the direction)
        line.sort((a, b) => (a.x * dr + a.y * dc).compareTo(b.x * dr + b.y * dc));
        return line.sublist(0, winLen);
      }
    }
    return null;
  }

  // Helper to determine block state of winning line ends
  bool _isBlockedBothEnds(List<Point<int>> line, int dr, int dc, String player) {
    // Sort line coordinates along the vector direction to find boundary cells
    line.sort((a, b) => (a.x * dr + a.y * dc).compareTo(b.x * dr + b.y * dc));
    
    final first = line.first;
    final last = line.last;
    
    final prev = Point(first.x - dr, first.y - dc);
    final next = Point(last.x + dr, last.y + dc);
    
    final opponent = player == 'X' ? 'O' : 'X';
    
    bool blockedStart = false;
    if (prev.x >= 0 && prev.x < _boardSize && prev.y >= 0 && prev.y < _boardSize) {
      if (_board[prev] == opponent) {
        blockedStart = true;
      }
    }
    
    bool blockedEnd = false;
    if (next.x >= 0 && next.x < _boardSize && next.y >= 0 && next.y < _boardSize) {
      if (_board[next] == opponent) {
        blockedEnd = true;
      }
    }
    
    return blockedStart && blockedEnd;
  }

  // Change board size helper
  void _changeBoardSize(int newSize, {VoidCallback? onConfirmExtra}) {
    if (newSize < 3 || newSize > 35) return;
    _showResetWarningDialog(() {
      setState(() {
        _boardSize = newSize;
      });
      _resetMatch();
      if (onConfirmExtra != null) {
        onConfirmExtra();
      }
    });
  }

  // Show dialog to input custom board size
  void _showCustomSizeDialog({VoidCallback? onConfirmExtra}) {
    final TextEditingController controller = TextEditingController(text: _boardSize.toString());
    // Board size limited to 3–35
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Kích thước tự chọn',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhập kích thước bàn cờ (từ 3 đến 35):',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Kích thước (3 - 35)',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    hintText: 'Nhập số từ 3 đến 35',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF00F2FE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFF43F5E)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập một số';
                    }
                    final size = int.tryParse(value);
                    if (size == null || size < 3 || size > 35) {
                      return 'Kích thước phải từ 3 đến 35';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newSize = int.parse(controller.text);
                  Navigator.of(context).pop();
                  _changeBoardSize(newSize, onConfirmExtra: onConfirmExtra);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F2FE),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 950;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Dark slate
              Color(0xFF1E293B), // Medium slate
              Color(0xFF020617), // Rich dark blue/black
            ],
          ),
        ),
        child: SafeArea(
          child: isDesktop 
              ? Row(
                  children: [
                    // Sidebar Controls
                    SizedBox(
                      width: 380,
                      child: _buildSidebar(context),
                    ),
                    // Main Board Area
                    Expanded(
                      child: _buildGameArea(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Mobile Header & Score
                    _buildMobileHeader(),
                    // Main Board Area
                    Expanded(
                      child: _buildGameArea(),
                    ),
                    // Mobile Controls Panel
                    _buildMobileControls(context),
                  ],
                ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildGameArea() {
    return Stack(
      children: [
        Positioned.fill(child: _buildBoardCanvas()),
        Positioned(
          top: 12,
          right: 12,
          child: _buildUserBadge(),
        ),
      ],
    );
  }

  Widget _buildUserBadge() {
    return Material(
      color: const Color(0xFF111827).withOpacity(0.9),
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF00F2FE),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.userEmail,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Dang xuat',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              color: Colors.white70,
              onPressed: () => supabase.auth.signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo & Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F2FE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.grid_4x4_rounded,
                    color: Color(0xFF00F2FE),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARO ARENA',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Local 2-Player Web App',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Turn and Winner Section
            _buildStatusCard(),
            const SizedBox(height: 24),

            // Points Section (only show in PVC mode)
            if (_gameMode == GameMode.pvc) ...[
              _buildPointsCard(),
              const SizedBox(height: 24),
            ],
  
            // Scoreboard Box
            _buildScoreboardCard(),
            const SizedBox(height: 24),
  
            // Settings Box
            _buildSettingsCard(),
            const SizedBox(height: 32),
  
            // Game Control Actions
            _buildActionButtons(),
            const SizedBox(height: 12),
            
            // Rules text info
            Center(
              child: Text(
                'InteractiveViewer: Click & drag to pan • Ctrl+Scroll to zoom',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_4x4_rounded, color: Color(0xFF00F2FE), size: 24),
              const SizedBox(width: 8),
              Text(
                'CARO ARENA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          // Short Turn Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _winner != null
                  ? (_winner == 'Draw'
                      ? Colors.orange.withOpacity(0.1)
                      : (_winner == 'X' ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E)).withOpacity(0.1))
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _winner != null
                    ? (_winner == 'Draw'
                        ? Colors.orange.withOpacity(0.3)
                        : (_winner == 'X' ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E)).withOpacity(0.3))
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                if (_winner == null && _aiThinking) ...[
                  const SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF43F5E)),
                  ),
                  const SizedBox(width: 6),
                  const Text('Máy nghĩ...', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF43F5E), fontSize: 12)),
                ] else if (_winner == null) ...[
                  const Text('Lượt: ', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  Text(
                    _isXTurn ? (_gameMode == GameMode.pvc ? 'Bạn (X)' : 'X') : 'O',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _isXTurn ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E),
                    ),
                  ),
                ] else if (_winner == 'Draw') ...[
                  const Text('Hòa!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
                ] else ...[
                  Text(
                    '$_winner Thắng!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _winner == 'X' ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E),
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F19),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row for Points and AI Hint on mobile (PvC mode only)
          if (_gameMode == GameMode.pvc) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Points display
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$_rewardPoints điểm',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // AI Hint button
                if (_winner == null && !_aiThinking && _isXTurn)
                  ElevatedButton.icon(
                    onPressed: _rewardPoints >= 15 ? _useAiHint : null,
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 12),
                    label: const Text('💡 Gợi ý AI (15đ)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white10,
                      disabledForegroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Row containing scores & settings toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Scores
              Row(
                children: [
                  _buildMiniScore('X', _scoreX, const Color(0xFF00F2FE)),
                  const SizedBox(width: 8),
                  _buildMiniScore('Hòa', _scoreDraws, Colors.grey),
                  const SizedBox(width: 8),
                  _buildMiniScore('O', _scoreO, const Color(0xFFF43F5E)),
                ],
              ),
              // Rule Toggles / Settings Menu
              Row(
                children: [
                  // Quick Info Trigger
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, color: Colors.white60, size: 20),
                    onPressed: () => _showRulesDialog(context),
                  ),
                  // Simple config trigger
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
                    onPressed: () => _showMobileSettingsMenu(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons: Reset, Undo, Center Board
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _moveHistory.isEmpty ? null : _undoLastMove,
                  icon: const Icon(Icons.undo_rounded, size: 16),
                  label: const Text('Hoàn tác'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  if (_lastViewportSize != null) {
                    _resetBoardView(_lastViewportSize!);
                  }
                },
                icon: const Icon(Icons.center_focus_strong_rounded, color: Colors.white70),
                tooltip: 'Căn giữa bàn cờ',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _resetMatch(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Chơi lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F2FE),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    shadowColor: const Color(0xFF00F2FE).withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniScore(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            '$value',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final bool isWon = _winner != null && _winner != 'Draw';
    final bool isDraw = _winner == 'Draw';
    
    Color accentColor = const Color(0xFF00F2FE);
    String titleText = 'Đang chơi';
    String descriptionText;

    if (isWon) {
      accentColor = _winner == 'X' ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E);
      titleText = 'CHIẾN THẮNG!';
      descriptionText = 'PLAYER $_winner đã thắng cuộc!';
    } else if (isDraw) {
      accentColor = Colors.orangeAccent;
      titleText = 'HÒA CỜ';
      descriptionText = 'Bàn cờ đã đầy!';
    } else if (_aiThinking) {
      accentColor = const Color(0xFFF43F5E);
      titleText = 'MÁY ĐANG NGHĨ';
      descriptionText = '🤖 Đang tính toán nước đi...';
    } else {
      accentColor = _isXTurn ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E);
      if (_gameMode == GameMode.pvc) {
        descriptionText = _isXTurn ? 'Lượt của BẠN (X)' : 'Lượt của MÁY (O)';
      } else {
        descriptionText = _isXTurn ? 'Lượt của PLAYER X' : 'Lượt của PLAYER O';
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                ),
              ),
              const SizedBox(width: 10),
              Text(
                titleText,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descriptionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (!isWon && !isDraw) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              backgroundColor: Colors.white.withOpacity(0.05),
              minHeight: 3,
            )
          ],
          if (_winner == 'O' && _gameMode == GameMode.pvc) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _rewardPoints >= _getReviveCost() ? _reviveWithPoints : null,
              icon: const Icon(Icons.autorenew_rounded),
              label: Text(
                'HỒI SINH BẰNG ĐIỂM (Tốn ${_getReviveCost()}đ)',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white10,
                disabledForegroundColor: Colors.white24,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
              ),
            ),
            if (_rewardPoints < _getReviveCost()) ...[
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Không đủ điểm thưởng để hồi sinh',
                  style: TextStyle(color: Color(0xFFF43F5E), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB300).withOpacity(0.08),
            const Color(0xFFFFA000).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.05),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFFFB300),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ĐIỂM THƯỞNG',
                    style: TextStyle(
                      color: Color(0xFFFFB300),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              if (_gameMode == GameMode.pvc && _winner == null && !_aiThinking && _isXTurn)
                ElevatedButton.icon(
                  onPressed: _rewardPoints >= 15 ? _useAiHint : null,
                  icon: const Icon(Icons.lightbulb_outline_rounded, size: 14),
                  label: const Text('💡 Gợi ý (15đ)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white10,
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_rewardPoints điểm',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỈ SỐ TRẬN ĐẤU',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white38),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // X Score
              Expanded(
                child: Column(
                  children: [
                    const Text('PLAYER X', style: TextStyle(fontSize: 11, color: Colors.white60)),
                    const SizedBox(height: 6),
                    Text(
                      '$_scoreX',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00F2FE),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 35,
                width: 1.5,
                color: Colors.white.withOpacity(0.1),
              ),
              // Draws
              Expanded(
                child: Column(
                  children: [
                    const Text('HÒA', style: TextStyle(fontSize: 11, color: Colors.white30)),
                    const SizedBox(height: 6),
                    Text(
                      '$_scoreDraws',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 35,
                width: 1.5,
                color: Colors.white.withOpacity(0.1),
              ),
              // O Score
              Expanded(
                child: Column(
                  children: [
                    const Text('PLAYER O', style: TextStyle(fontSize: 11, color: Colors.white60)),
                    const SizedBox(height: 6),
                    Text(
                      '$_scoreO',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF43F5E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THIẾT LẬP GAME',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white38),
          ),
          const SizedBox(height: 16),
          // Board Size selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kích thước:', style: TextStyle(fontSize: 13, color: Colors.white70)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _boardSize > 3 ? () => _changeBoardSize(_boardSize - 1) : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: const Color(0xFF00F2FE),
                    disabledColor: Colors.white24,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
                  GestureDetector(
                    onTap: _showCustomSizeDialog,
                    child: Tooltip(
                      message: 'Nhấp để tự nhập kích thước (3–35)',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                        ),
                        child: Text(
                          '$_boardSize × $_boardSize',
                          style: const TextStyle(
                            color: Color(0xFF00F2FE),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _boardSize < 35 ? () => _changeBoardSize(_boardSize + 1) : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: const Color(0xFF00F2FE),
                    disabledColor: Colors.white24,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider for quick select (3–35)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: const Color(0xFF00F2FE),
              inactiveTrackColor: Colors.white10,
              thumbColor: const Color(0xFF00F2FE),
              overlayColor: const Color(0xFF00F2FE).withOpacity(0.2),
              valueIndicatorColor: const Color(0xFF1E293B),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            child: Slider(
              value: _boardSize.toDouble().clamp(3.0, 35.0),
              min: 3,
              max: 35,
              divisions: 32,
              label: '$_boardSize × $_boardSize',
              onChanged: (double val) {
                final newSize = val.round();
                if (newSize != _boardSize) {
                  _changeBoardSize(newSize);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          // Win length info badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00F2FE).withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFF00F2FE), size: 14),
                const SizedBox(width: 8),
                Text(
                  'Cần $_winLength ô liên tiếp để thắng',
                  style: const TextStyle(
                    color: Color(0xFF00F2FE),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ─── Game Mode Toggle ───────────────────────────────────────
          const Text(
            'CHẾĐỘ CHƠI',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white38),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildModeChip('👥 2 Người', GameMode.pvp)),
              const SizedBox(width: 8),
              Expanded(child: _buildModeChip('🤖 vs Máy', GameMode.pvc)),
            ],
          ),
          // Difficulty chips (only in PvC)
          if (_gameMode == GameMode.pvc) ...[
            const SizedBox(height: 12),
            const Text(
              'ĐỘ KHÓ AI',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white38),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AiDifficulty.values.map((d) => _buildDifficultyChip(d)).toList(),
            ),
          ],
          const SizedBox(height: 12),
          // Block rule toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chặn 2 đầu:', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text(
                      'Không thắng nếu bị chặn 2 đầu',
                      style: TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _doubleBlockRule,
                activeColor: const Color(0xFF00F2FE),
                activeTrackColor: const Color(0xFF00F2FE).withOpacity(0.2),
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white.withOpacity(0.05),
                onChanged: (bool value) {
                  setState(() {
                    _doubleBlockRule = value;
                  });
                  // If game is in progress, recalculate the board state or just apply on next moves
                  // Standard is applying immediately, let's reset match for a clean start or just let it continue
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chuyển sang luật ${value ? "chặn hai đầu" : "tự do (Gomoku)"}.'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF1E293B),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Undo & Reset Side-by-side
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _moveHistory.isEmpty ? null : _undoLastMove,
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Hoàn tác'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledForegroundColor: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                if (_lastViewportSize != null) {
                  _resetBoardView(_lastViewportSize!);
                }
              },
              icon: const Icon(Icons.center_focus_strong_rounded, color: Colors.white70),
              tooltip: 'Căn giữa bàn cờ',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Restart Button
        ElevatedButton.icon(
          onPressed: () => _resetMatch(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('CHƠI LẬT TRẬN MỚI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00F2FE),
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            shadowColor: const Color(0xFF00F2FE).withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 12),
        // Clear Score Button
        TextButton.icon(
          onPressed: () => _resetMatch(clearScore: true),
          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white54),
          label: const Text('Đặt lại điểm số', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, GameMode mode) {
    final isSelected = _gameMode == mode;
    return GestureDetector(
      onTap: () {
        if (_gameMode == mode) return;
        setState(() {
          _gameMode = mode;
          _aiThinking = false;
        });
        _resetMatch();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F2FE).withOpacity(0.12) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F2FE).withOpacity(0.6) : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF00F2FE) : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(AiDifficulty difficulty) {
    final isSelected = _aiDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() => _aiDifficulty = difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF43F5E).withOpacity(0.14) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF43F5E).withOpacity(0.6) : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          difficulty.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFFF43F5E) : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Auto center on first load or on heavy size mutation (orientation change)
        if (_lastViewportSize == null) {
          _lastViewportSize = viewportSize;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetBoardView(viewportSize);
          });
        } else if ((_lastViewportSize!.width - viewportSize.width).abs() > 40 ||
                   (_lastViewportSize!.height - viewportSize.height).abs() > 40) {
          _lastViewportSize = viewportSize;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetBoardView(viewportSize);
          });
        }

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.15,
          maxScale: 2.2,
          constrained: false,
          boundaryMargin: EdgeInsets.all(_boardSize * _cellSize * 0.45),
          child: _buildBoardGrid(),
        );
      },
    );
  }

  Widget _buildBoardGrid() {
    final double sizePx = _boardSize * _cellSize;

    return Container(
      width: sizePx + 4,
      height: sizePx + 4,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: List.generate(_boardSize, (r) {
            return Row(
              children: List.generate(_boardSize, (c) {
                final cell = Point(r, c);
                final mark = _board[cell];
                final isLast = _lastMove == cell;
                final isWinning = _winningLine?.contains(cell) ?? false;
                
                return CaroCellWidget(
                  r: r,
                  c: c,
                  mark: mark,
                  isLast: isLast,
                  isWinning: isWinning,
                  isHint: _hintCell == cell,
                  onTap: () => _handleCellTap(r, c),
                  cellSize: _cellSize,
                  isXTurn: _isXTurn,
                  aiThinking: _aiThinking,
                  winner: _winner,
                  gameMode: _gameMode,
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  // --- Dialog Builders ---

  void _showResetWarningDialog(VoidCallback onConfirm) {
    if (_board.isEmpty) {
      onConfirm();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Thay đổi cài đặt?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
            'Việc thay đổi kích thước bàn cờ sẽ bắt đầu một trận đấu mới và làm sạch bàn cờ hiện tại. Bạn có chắc chắn muốn tiếp tục?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E), foregroundColor: Colors.white),
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Luật Chơi Cờ Caro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRulePoint('1', 'Người chơi lần lượt đặt X và O lên các ô trống.'),
                const SizedBox(height: 8),
                _buildRulePoint('2', 'Chiến thắng khi có 5 ô liên tiếp thẳng hàng ngang, dọc hoặc chéo.'),
                const SizedBox(height: 8),
                _buildRulePoint('3', 'Luật chặn 2 đầu (nếu bật): Nếu chuỗi 5 ô bị chặn ở cả 2 đầu bởi quân cờ của đối thủ thì chưa được tính thắng.'),
                const SizedBox(height: 8),
                _buildRulePoint('4', 'Thu phóng: Dùng thao tác Ctrl + Lăn chuột (trên PC) hoặc Kéo 2 ngón tay (trên Mobile) để phóng to/thu nhỏ. Kéo bằng 1 ngón/chuột để di chuyển bàn cờ.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFF00F2FE))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRulePoint(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF00F2FE),
            shape: BoxShape.circle,
          ),
          child: Text(num, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }

  void _showMobileSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CÀI ĐẶT TRẬN ĐẤU',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 20),
                  // Board size option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kích thước bàn cờ:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButton<int>(
                          value: _boardSize,
                          dropdownColor: const Color(0xFF1E293B),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          onChanged: (int? newValue) {
                            if (newValue != null && newValue != _boardSize) {
                              Navigator.pop(context);
                              _showResetWarningDialog(() {
                                setState(() {
                                  _boardSize = newValue;
                                });
                                _resetMatch();
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 20, child: Text('20 x 20')),
                            DropdownMenuItem(value: 25, child: Text('25 x 25')),
                            DropdownMenuItem(value: 30, child: Text('30 x 30')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Block rule option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Luật chặn hai đầu:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('Không thắng khi bị đối thủ chặn cả 2 đầu', style: TextStyle(color: Colors.white30, fontSize: 10)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _doubleBlockRule,
                        activeColor: const Color(0xFF00F2FE),
                        onChanged: (bool value) {
                          setModalState(() {
                            _doubleBlockRule = value;
                          });
                          setState(() {
                            _doubleBlockRule = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Clear scores option
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetMatch(clearScore: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E).withOpacity(0.1),
                      foregroundColor: const Color(0xFFF43F5E),
                      side: const BorderSide(color: Color(0xFFF43F5E), width: 1),
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Đặt lại tất cả điểm số (0 - 0)'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED CARO CELL WIDGET & PARTICLE EFFECT
// ─────────────────────────────────────────────────────────────────────────────

class CellParticle {
  final double angle;
  final double speed;
  final double maxRadius;
  CellParticle({required this.angle, required this.speed, required this.maxRadius});
}

class CellParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<CellParticle> particles;

  CellParticlePainter({
    required this.progress,
    required this.color,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;
    
    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;
      
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final p in particles) {
      final distance = p.maxRadius * progress * p.speed;
      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance;
      final sizeFactor = 3.0 * (1.0 - progress);
      canvas.drawCircle(Offset(x, y), sizeFactor, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CellParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class CaroCellWidget extends StatefulWidget {
  final int r;
  final int c;
  final String? mark;
  final bool isLast;
  final bool isWinning;
  final bool isHint;
  final VoidCallback onTap;
  final double cellSize;
  final bool isXTurn;
  final bool aiThinking;
  final String? winner;
  final GameMode gameMode;

  const CaroCellWidget({
    super.key,
    required this.r,
    required this.c,
    required this.mark,
    required this.isLast,
    required this.isWinning,
    required this.isHint,
    required this.onTap,
    required this.cellSize,
    required this.isXTurn,
    required this.aiThinking,
    required this.winner,
    required this.gameMode,
  });

  @override
  State<CaroCellWidget> createState() => _CaroCellWidgetState();
}

class _CaroCellWidgetState extends State<CaroCellWidget> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _markController;
  late AnimationController _hintController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hintGlowAnimation;
  bool _hovered = false;

  final List<CellParticle> _particles = List.generate(8, (index) {
    final angle = index * (2 * pi / 8) + (Random().nextDouble() * 0.4 - 0.2);
    final speed = 0.6 + Random().nextDouble() * 0.4;
    final maxRadius = 25.0 + Random().nextDouble() * 15.0;
    return CellParticle(angle: angle, speed: speed, maxRadius: maxRadius);
  });

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _markController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_markController);

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _hintGlowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    if (widget.mark != null) {
      _markController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CaroCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mark == null && widget.mark != null) {
      _markController.forward(from: 0.0);
      _particleController.forward(from: 0.0);
    } else if (widget.mark == null) {
      _markController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _markController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mark = widget.mark;
    final isLast = widget.isLast;
    final isWinning = widget.isWinning;
    final isHint = widget.isHint;

    Color? cellColor;
    Border? cellBorder;

    if (isWinning) {
      cellColor = Colors.greenAccent.withOpacity(0.25);
      cellBorder = Border.all(color: Colors.greenAccent.withOpacity(0.8), width: 2);
    } else if (isHint) {
      cellColor = Colors.amber.withOpacity(0.12 * _hintGlowAnimation.value);
      cellBorder = Border.all(color: Colors.amber.withOpacity(0.8 * _hintGlowAnimation.value), width: 2);
    } else if (isLast) {
      cellColor = const Color(0xFF00F2FE).withOpacity(0.16);
      cellBorder = Border.all(color: const Color(0xFF00F2FE).withOpacity(0.5), width: 1.5);
    } else if (_hovered) {
      cellColor = Colors.white.withOpacity(0.06);
      cellBorder = Border.all(color: Colors.white.withOpacity(0.12), width: 0.5);
    } else {
      cellColor = Colors.transparent;
      cellBorder = Border.all(color: Colors.white.withOpacity(0.06), width: 0.5);
    }

    final canInteract = widget.winner == null && mark == null &&
        !widget.aiThinking && (widget.gameMode == GameMode.pvp || widget.isXTurn);

    Widget cellContent = Container(
      width: widget.cellSize,
      height: widget.cellSize,
      decoration: BoxDecoration(
        color: cellColor,
        border: cellBorder,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.cellSize, widget.cellSize),
                painter: CellParticlePainter(
                  progress: _particleController.value,
                  color: mark == 'X' ? const Color(0xFF00F2FE) : const Color(0xFFF43F5E),
                  particles: _particles,
                ),
              );
            },
          ),
          if (mark != null)
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMarkWidget(mark, isWinning: isWinning),
            )
          else if (_hovered && canInteract)
            Opacity(
              opacity: 0.28,
              child: _buildMarkWidget(widget.isXTurn ? 'X' : 'O', isPreview: true),
            ),
          if (isHint && mark == null)
            AnimatedBuilder(
              animation: _hintGlowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _hintGlowAnimation.value,
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                );
              },
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) {
        if (canInteract) {
          setState(() { _hovered = true; });
        }
      },
      onExit: (_) {
        setState(() { _hovered = false; });
      },
      cursor: canInteract ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: cellContent,
      ),
    );
  }

  Widget _buildMarkWidget(String mark, {bool isWinning = false, bool isPreview = false}) {
    if (mark == 'X') {
      return Text(
        'X',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: isWinning ? Colors.greenAccent : const Color(0xFF00F2FE),
          shadows: [
            Shadow(
              color: isWinning
                  ? Colors.greenAccent.withOpacity(0.8)
                  : const Color(0xFF00F2FE).withOpacity(0.6),
              blurRadius: isWinning ? 14 : 6,
            )
          ],
        ),
      );
    } else {
      return Text(
        'O',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: isWinning ? Colors.greenAccent : const Color(0xFFF43F5E),
          shadows: [
            Shadow(
              color: isWinning
                  ? Colors.greenAccent.withOpacity(0.8)
                  : const Color(0xFFF43F5E).withOpacity(0.6),
              blurRadius: isWinning ? 14 : 6,
            )
          ],
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARO AI ENGINE
// ─────────────────────────────────────────────────────────────────────────────

class CaroAI {
  static final Random _random = Random();

  /// Entry point — returns best move for AI (plays as 'O')
  static Point<int>? getBestMove({
    required Map<Point<int>, String> board,
    required int boardSize,
    required int winLength,
    required AiDifficulty difficulty,
  }) {
    if (board.length >= boardSize * boardSize) return null;
    switch (difficulty) {
      case AiDifficulty.easy:         return _easyMove(board, boardSize);
      case AiDifficulty.amateur:      return _amateurMove(board, boardSize, winLength);
      case AiDifficulty.medium:       return _mediumMove(board, boardSize, winLength);
      case AiDifficulty.semiPro:      return _minimaxRoot(board, boardSize, winLength, depth: 2, maxCands: 12);
      case AiDifficulty.professional: return _minimaxRoot(board, boardSize, winLength, depth: boardSize <= 10 ? 4 : 3, maxCands: 15);
    }
  }

  // ── Level 1: Dễ — random gần quân đã đặt ───────────────────────────────
  static Point<int> _easyMove(Map<Point<int>, String> board, int boardSize) {
    final cands = _getCandidates(board, boardSize, radius: 2);
    return cands.isEmpty ? Point(boardSize ~/ 2, boardSize ~/ 2) : cands[_random.nextInt(cands.length)];
  }

  // ── Level 2: Nghiệp dư — chặn thắng hiển nhiên, còn lại random ─────────
  static Point<int> _amateurMove(Map<Point<int>, String> board, int boardSize, int winLength) {
    final cands = _getCandidates(board, boardSize, radius: 2);
    if (cands.isEmpty) return Point(boardSize ~/ 2, boardSize ~/ 2);
    // Win immediately
    for (final c in cands) { if (_wouldWin(board, c, 'O', boardSize, winLength)) return c; }
    // Block player's win
    for (final c in cands) { if (_wouldWin(board, c, 'X', boardSize, winLength)) return c; }
    return cands[_random.nextInt(cands.length)];
  }

  // ── Level 3: Trung bình — heuristic scoring ──────────────────────────────
  static Point<int> _mediumMove(Map<Point<int>, String> board, int boardSize, int winLength) {
    final cands = _getCandidates(board, boardSize, radius: 3);
    if (cands.isEmpty) return Point(boardSize ~/ 2, boardSize ~/ 2);
    int best = -1;
    Point<int> bestMove = cands.first;
    for (final c in cands) {
      final s = _scoreMove(board, c.x, c.y, boardSize, winLength);
      if (s > best) { best = s; bestMove = c; }
    }
    return bestMove;
  }

  // ── Minimax root (Levels 4 & 5) ──────────────────────────────────────────
  static Point<int> _minimaxRoot(
    Map<Point<int>, String> board, int boardSize, int winLength,
    {required int depth, required int maxCands}
  ) {
    final cands = _getCandidates(board, boardSize, radius: 3);
    if (cands.isEmpty) return Point(boardSize ~/ 2, boardSize ~/ 2);
    final top = _topCandidates(board, cands, boardSize, winLength, maxCount: maxCands);

    int bestScore = -999999999;
    Point<int> bestMove = top.first;

    for (final c in top) {
      // Take immediate win
      if (_wouldWin(board, c, 'O', boardSize, winLength)) return c;
      final nb = Map<Point<int>, String>.from(board)..[c] = 'O';
      final s = _minimax(nb, boardSize, winLength, depth - 1, false, -999999999, 999999999);
      if (s > bestScore) { bestScore = s; bestMove = c; }
    }
    return bestMove;
  }

  // ── Minimax with alpha-beta pruning ──────────────────────────────────────
  static int _minimax(
    Map<Point<int>, String> board, int boardSize, int winLength,
    int depth, bool isMax, int alpha, int beta,
  ) {
    if (depth == 0) return _evaluateBoard(board, boardSize, winLength);
    final cands = _getCandidates(board, boardSize, radius: 2);
    if (cands.isEmpty) return 0;
    final top = _topCandidates(board, cands, boardSize, winLength, maxCount: 8);

    if (isMax) {
      int maxEval = -999999999;
      for (final c in top) {
        if (_wouldWin(board, c, 'O', boardSize, winLength)) return 100000 + depth * 1000;
        final nb = Map<Point<int>, String>.from(board)..[c] = 'O';
        final e = _minimax(nb, boardSize, winLength, depth - 1, false, alpha, beta);
        if (e > maxEval) maxEval = e;
        if (maxEval > alpha) alpha = maxEval;
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999999;
      for (final c in top) {
        if (_wouldWin(board, c, 'X', boardSize, winLength)) return -100000 - depth * 1000;
        final nb = Map<Point<int>, String>.from(board)..[c] = 'X';
        final e = _minimax(nb, boardSize, winLength, depth - 1, true, alpha, beta);
        if (e < minEval) minEval = e;
        if (minEval < beta) beta = minEval;
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  // ── Board evaluation ─────────────────────────────────────────────────────
  static int _evaluateBoard(Map<Point<int>, String> board, int boardSize, int winLength) {
    int score = 0;
    final seen = <String>{};
    for (final entry in board.entries) {
      final r = entry.key.x; final c = entry.key.y;
      for (final dir in [[0,1],[1,0],[1,1],[1,-1]]) {
        // Only from line-start to avoid double-counting
        final pr = r - dir[0]; final pc = c - dir[1];
        if (pr >= 0 && pr < boardSize && pc >= 0 && pc < boardSize && board[Point(pr,pc)] == entry.value) continue;
        final key = '${r}_${c}_${dir[0]}_${dir[1]}';
        if (seen.contains(key)) continue;
        seen.add(key);
        final count = _countInLine(board, r, c, dir[0], dir[1], entry.value, boardSize);
        final blocked = _countBlocked(board, r, c, dir[0], dir[1], entry.value, boardSize);
        final s = _scoreForCount(count, blocked, winLength);
        score += entry.value == 'O' ? s : -s;
      }
    }
    return score;
  }

  // ── Heuristic: score a candidate move ────────────────────────────────────
  static int _scoreMove(Map<Point<int>, String> board, int r, int c, int boardSize, int winLength) {
    final cell = Point(r, c);
    // Attack score (O plays here)
    final nb1 = Map<Point<int>, String>.from(board)..[cell] = 'O';
    int score = _scoreForPlayer(nb1, 'O', r, c, boardSize, winLength) * 2;
    // Defense score (block X)
    final nb2 = Map<Point<int>, String>.from(board)..[cell] = 'X';
    score += _scoreForPlayer(nb2, 'X', r, c, boardSize, winLength);
    // Center bias
    final dist = ((r - boardSize / 2).abs() + (c - boardSize / 2).abs()).round();
    score += boardSize - dist;
    return score;
  }

  static int _scoreForPlayer(Map<Point<int>, String> board, String player, int r, int c, int boardSize, int winLength) {
    int score = 0;
    for (final dir in [[0,1],[1,0],[1,1],[1,-1]]) {
      final count = _countInLine(board, r, c, dir[0], dir[1], player, boardSize);
      final blocked = _countBlocked(board, r, c, dir[0], dir[1], player, boardSize);
      score += _scoreForCount(count, blocked, winLength);
    }
    return score;
  }

  static int _scoreForCount(int count, int blocked, int winLength) {
    if (count >= winLength) return 500000;
    if (blocked >= 2) return count >= winLength - 1 ? 50 : 0;
    final open = 2 - blocked;
    if (count == winLength - 1) return open == 2 ? 50000 : 5000;
    if (count == winLength - 2) return open == 2 ? 2000  : 200;
    if (count == winLength - 3 && winLength > 3) return open == 2 ? 100 : 10;
    return count * open;
  }

  // ── Check if placing at cell would immediately win ────────────────────────
  static bool _wouldWin(Map<Point<int>, String> board, Point<int> cell, String player, int boardSize, int winLength) {
    final nb = Map<Point<int>, String>.from(board)..[cell] = player;
    for (final dir in [[0,1],[1,0],[1,1],[1,-1]]) {
      if (_countInLine(nb, cell.x, cell.y, dir[0], dir[1], player, boardSize) >= winLength) return true;
    }
    return false;
  }

  // ── Count consecutive same-player pieces through (r,c) in direction ──────
  static int _countInLine(Map<Point<int>, String> board, int r, int c, int dr, int dc, String player, int boardSize) {
    int count = 1;
    int nr = r+dr, nc = c+dc;
    while (nr>=0 && nr<boardSize && nc>=0 && nc<boardSize && board[Point(nr,nc)]==player) { count++; nr+=dr; nc+=dc; }
    nr = r-dr; nc = c-dc;
    while (nr>=0 && nr<boardSize && nc>=0 && nc<boardSize && board[Point(nr,nc)]==player) { count++; nr-=dr; nc-=dc; }
    return count;
  }

  // ── Count how many ends of the line through (r,c) are blocked ────────────
  static int _countBlocked(Map<Point<int>, String> board, int r, int c, int dr, int dc, String player, int boardSize) {
    final opp = player == 'X' ? 'O' : 'X';
    int blocked = 0;
    // Positive end
    int pr = r, pc = c;
    while (pr+dr>=0 && pr+dr<boardSize && pc+dc>=0 && pc+dc<boardSize && board[Point(pr+dr,pc+dc)]==player) { pr+=dr; pc+=dc; }
    final nr1 = pr+dr, nc1 = pc+dc;
    if (nr1<0 || nr1>=boardSize || nc1<0 || nc1>=boardSize || board[Point(nr1,nc1)]==opp) blocked++;
    // Negative end
    int qr = r, qc = c;
    while (qr-dr>=0 && qr-dr<boardSize && qc-dc>=0 && qc-dc<boardSize && board[Point(qr-dr,qc-dc)]==player) { qr-=dr; qc-=dc; }
    final nr2 = qr-dr, nc2 = qc-dc;
    if (nr2<0 || nr2>=boardSize || nc2<0 || nc2>=boardSize || board[Point(nr2,nc2)]==opp) blocked++;
    return blocked;
  }

  // ── Get empty cells in radius around existing pieces ──────────────────────
  static List<Point<int>> _getCandidates(Map<Point<int>, String> board, int boardSize, {int radius = 2}) {
    if (board.isEmpty) return [Point(boardSize ~/ 2, boardSize ~/ 2)];
    final Set<Point<int>> result = {};
    for (final cell in board.keys) {
      for (int dr = -radius; dr <= radius; dr++) {
        for (int dc = -radius; dc <= radius; dc++) {
          if (dr == 0 && dc == 0) continue;
          final p = Point(cell.x + dr, cell.y + dc);
          if (p.x >= 0 && p.x < boardSize && p.y >= 0 && p.y < boardSize && !board.containsKey(p)) {
            result.add(p);
          }
        }
      }
    }
    return result.toList();
  }

  // ── Sort candidates by heuristic, return top N ────────────────────────────
  static List<Point<int>> _topCandidates(
    Map<Point<int>, String> board, List<Point<int>> cands,
    int boardSize, int winLength, {int maxCount = 12}
  ) {
    if (cands.length <= maxCount) return cands;
    final scored = cands.map((c) => MapEntry(c, _scoreMove(board, c.x, c.y, boardSize, winLength))).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return scored.take(maxCount).map((e) => e.key).toList();
  }
}
