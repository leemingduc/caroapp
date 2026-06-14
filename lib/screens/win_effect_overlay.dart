import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIN EFFECT OVERLAY — Hiệu ứng chiến thắng theo cấp độ
// ─────────────────────────────────────────────────────────────────────────────

enum WinEffectLevel {
  easy,       // 🎮 Dễ — confetti nhỏ nhẹ
  amateur,    // 🏠 Nghiệp dư — confetti nhiều hơn
  medium,     // ⚔️ Trung bình — pháo hoa
  semiPro,    // 🎯 Bán chuyên — pháo hoa + beam
  professional, // 🏆 Chuyên nghiệp — epic explosion + aurora
}

// ─── Confetti Particle ───────────────────────────────────────────────────────

class ConfettiParticle {
  double x, y, vx, vy;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;
  double opacity;

  ConfettiParticle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.rotation, required this.rotationSpeed,
    required this.color, required this.size,
    this.opacity = 1.0,
  });
}

// ─── Firework Particle ───────────────────────────────────────────────────────

class FireworkParticle {
  double x, y, vx, vy;
  double life; // 0.0 - 1.0
  Color color;
  double size;
  List<Offset> trail;

  FireworkParticle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.color, required this.size,
  }) : life = 1.0, trail = [];
}

// ─── Beam / Aurora Particle ──────────────────────────────────────────────────

class BeamParticle {
  double x, y;
  double angle;
  double length;
  double opacity;
  Color color;
  double width;

  BeamParticle({
    required this.x, required this.y,
    required this.angle, required this.length,
    required this.opacity, required this.color,
    required this.width,
  });
}

// ─── Win Effect Painter ──────────────────────────────────────────────────────

class WinEffectPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final WinEffectLevel level;
  final List<ConfettiParticle> confetti;
  final List<FireworkParticle> fireworks;
  final List<BeamParticle> beams;
  final String winnerLabel;
  final Color winnerColor;

  WinEffectPainter({
    required this.progress,
    required this.level,
    required this.confetti,
    required this.fireworks,
    required this.beams,
    required this.winnerLabel,
    required this.winnerColor,
  });


  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    switch (level) {
      case WinEffectLevel.easy:
        _paintConfetti(canvas, size, intensity: 0.5);
        break;
      case WinEffectLevel.amateur:
        _paintConfetti(canvas, size, intensity: 0.8);
        break;
      case WinEffectLevel.medium:
        _paintConfetti(canvas, size, intensity: 0.6);
        _paintFireworks(canvas, size, intensity: 0.7);
        break;
      case WinEffectLevel.semiPro:
        _paintBeams(canvas, size);
        _paintFireworks(canvas, size, intensity: 1.0);
        _paintConfetti(canvas, size, intensity: 0.8);
        break;
      case WinEffectLevel.professional:
        _paintAurora(canvas, size);
        _paintBeams(canvas, size);
        _paintFireworks(canvas, size, intensity: 1.0);
        _paintConfetti(canvas, size, intensity: 1.0);
        _paintEpicCenter(canvas, size);
        break;
    }
  }

  void _paintConfetti(Canvas canvas, Size size, {required double intensity}) {
    for (final p in confetti) {
      final paint = Paint()
        ..color = p.color.withAlpha((p.opacity * intensity * 255).round().clamp(0, 255))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintFireworks(Canvas canvas, Size size, {required double intensity}) {
    for (final p in fireworks) {
      final alpha = (p.life * intensity * 255).round().clamp(0, 255);
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..strokeWidth = p.size * p.life
        ..style = PaintingStyle.fill;

      // Glow effect
      final glowPaint = Paint()
        ..color = p.color.withAlpha((alpha * 0.3).round().clamp(0, 255))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life * 1.5, glowPaint);
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);

      // Trail
      if (p.trail.length > 1) {
        for (int i = 1; i < p.trail.length; i++) {
          final trailAlpha = (alpha * (i / p.trail.length) * 0.4).round().clamp(0, 255);
          final trailPaint = Paint()
            ..color = p.color.withAlpha(trailAlpha)
            ..strokeWidth = p.size * p.life * 0.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(p.trail[i - 1], p.trail[i], trailPaint);
        }
      }
    }
  }

  void _paintBeams(Canvas canvas, Size size) {
    for (final b in beams) {
      final paint = Paint()
        ..color = b.color.withAlpha((b.opacity * 255).round().clamp(0, 255))
        ..strokeWidth = b.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, b.width * 0.8);

      final dx = cos(b.angle) * b.length;
      final dy = sin(b.angle) * b.length;
      canvas.drawLine(
        Offset(b.x, b.y),
        Offset(b.x + dx, b.y + dy),
        paint,
      );
    }
  }

  void _paintAurora(Canvas canvas, Size size) {
    // Draw flowing aurora wave at the top
    final waveProgress = (progress * 2).clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final colors = [
      const Color(0xFF00F2FE),
      const Color(0xFF4FACFE),
      const Color(0xFFA855F7),
      const Color(0xFFEC4899),
    ];

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final offset = i * 0.25;
      final waveHeight = 80.0 + i * 20;
      final phase = progress * pi * 2 + offset * pi;

      path.moveTo(0, 0);
      for (double x = 0; x <= size.width; x += 4) {
        final y = sin(x / size.width * pi * 3 + phase) * waveHeight * waveProgress +
            (i * 30) - 20;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, 0);
      path.close();

      paint.color = colors[i % colors.length].withAlpha((0.08 * waveProgress * 255).round().clamp(0, 255));
      canvas.drawPath(path, paint);
    }
  }

  void _paintEpicCenter(Canvas canvas, Size size) {
    if (progress < 0.1) return;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Pulsing ring
    final ringProgress = (sin(progress * pi * 4) * 0.5 + 0.5);
    final ringRadius = 40.0 + ringProgress * 60;
    final ringPaint = Paint()
      ..color = winnerColor.withAlpha((ringProgress * 120).round().clamp(0, 255))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(cx, cy), ringRadius, ringPaint);

    // Second ring
    final ring2Radius = 20.0 + ringProgress * 30;
    ringPaint.color = winnerColor.withAlpha((ringProgress * 80).round().clamp(0, 255));
    canvas.drawCircle(Offset(cx, cy), ring2Radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant WinEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ─── Win Effect Overlay Widget ───────────────────────────────────────────────

class WinEffectOverlay extends StatefulWidget {
  final WinEffectLevel level;
  final String winnerLabel;
  final Color winnerColor;
  final VoidCallback? onComplete;

  const WinEffectOverlay({
    super.key,
    required this.level,
    required this.winnerLabel,
    required this.winnerColor,
    this.onComplete,
  });

  @override
  State<WinEffectOverlay> createState() => _WinEffectOverlayState();
}

class _WinEffectOverlayState extends State<WinEffectOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _textController;
  late Animation<double> _textScale;
  late Animation<double> _textOpacity;

  final Random _rng = Random();
  List<ConfettiParticle> _confetti = [];
  List<FireworkParticle> _fireworks = [];
  List<BeamParticle> _beams = [];

  static const _confettiColors = [
    Color(0xFFFFD700), Color(0xFFFF6B6B), Color(0xFF00F2FE),
    Color(0xFFA855F7), Color(0xFF4ADE80), Color(0xFFFBBF24),
    Color(0xFFEC4899), Color(0xFF38BDF8),
  ];

  static const _fireworkColors = [
    Color(0xFFFFD700), Color(0xFFFF6B6B), Color(0xFF00F2FE),
    Color(0xFFA855F7), Color(0xFF4ADE80), Color(0xFFF97316),
  ];

  @override
  void initState() {
    super.initState();
    _initParticles();

    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    )..addListener(_updateParticles);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_textController);

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.4)),
    );

    _controller.forward();
    _textController.forward();

    if (widget.onComplete != null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete!();
        }
      });
    }
  }

  Duration _getDuration() {
    switch (widget.level) {
      case WinEffectLevel.easy: return const Duration(seconds: 3);
      case WinEffectLevel.amateur: return const Duration(seconds: 4);
      case WinEffectLevel.medium: return const Duration(seconds: 5);
      case WinEffectLevel.semiPro: return const Duration(seconds: 6);
      case WinEffectLevel.professional: return const Duration(seconds: 7);
    }
  }

  int _getConfettiCount() {
    switch (widget.level) {
      case WinEffectLevel.easy: return 40;
      case WinEffectLevel.amateur: return 70;
      case WinEffectLevel.medium: return 90;
      case WinEffectLevel.semiPro: return 120;
      case WinEffectLevel.professional: return 180;
    }
  }

  int _getFireworkCount() {
    switch (widget.level) {
      case WinEffectLevel.easy: return 0;
      case WinEffectLevel.amateur: return 0;
      case WinEffectLevel.medium: return 60;
      case WinEffectLevel.semiPro: return 100;
      case WinEffectLevel.professional: return 150;
    }
  }

  int _getBeamCount() {
    switch (widget.level) {
      case WinEffectLevel.easy: return 0;
      case WinEffectLevel.amateur: return 0;
      case WinEffectLevel.medium: return 0;
      case WinEffectLevel.semiPro: return 12;
      case WinEffectLevel.professional: return 20;
    }
  }

  void _initParticles() {
    final confettiCount = _getConfettiCount();
    _confetti = List.generate(confettiCount, (i) {
      return ConfettiParticle(
        x: _rng.nextDouble() * 800,
        y: -20 - _rng.nextDouble() * 200,
        vx: (_rng.nextDouble() - 0.5) * 3,
        vy: 2 + _rng.nextDouble() * 4,
        rotation: _rng.nextDouble() * pi * 2,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.3,
        color: _confettiColors[_rng.nextInt(_confettiColors.length)],
        size: 6 + _rng.nextDouble() * 8,
        opacity: 0.8 + _rng.nextDouble() * 0.2,
      );
    });

    final fireworkCount = _getFireworkCount();
    _fireworks = List.generate(fireworkCount, (i) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 60 + _rng.nextDouble() * 120;
      return FireworkParticle(
        x: 200 + _rng.nextDouble() * 400,
        y: 150 + _rng.nextDouble() * 300,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 40,
        color: _fireworkColors[_rng.nextInt(_fireworkColors.length)],
        size: 3 + _rng.nextDouble() * 4,
      );
    });

    final beamCount = _getBeamCount();
    _beams = List.generate(beamCount, (i) {
      return BeamParticle(
        x: 400,
        y: 300,
        angle: (i / beamCount) * pi * 2,
        length: 100 + _rng.nextDouble() * 200,
        opacity: 0.6 + _rng.nextDouble() * 0.4,
        color: _fireworkColors[i % _fireworkColors.length],
        width: 1.5 + _rng.nextDouble() * 2,
      );
    });
  }

  void _updateParticles() {
    if (!mounted) return;
    final dt = 0.016; // ~60fps delta
    setState(() {
      for (final p in _confetti) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.15; // gravity
        p.vx *= 0.99; // air drag
        p.rotation += p.rotationSpeed;
        // Fade out near end
        if (_controller.value > 0.7) {
          p.opacity = (1.0 - (_controller.value - 0.7) / 0.3).clamp(0.0, 1.0);
        }
      }

      for (final p in _fireworks) {
        p.trail.add(Offset(p.x, p.y));
        if (p.trail.length > 6) p.trail.removeAt(0);
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.vy += 30 * dt; // gravity
        p.vx *= 0.98;
        p.vy *= 0.98;
        p.life -= dt * 0.6;
        if (p.life < 0) p.life = 0;
      }

      for (final b in _beams) {
        b.angle += 0.015;
        b.length = 100 + sin(_controller.value * pi * 4 + b.angle) * 80;
        if (_controller.value > 0.75) {
          b.opacity = ((1.0 - (_controller.value - 0.75) / 0.25) * 0.8).clamp(0.0, 1.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  String _getLevelTitle() {
    switch (widget.level) {
      case WinEffectLevel.easy: return '🎮 Chiến thắng!';
      case WinEffectLevel.amateur: return '🏠 Xuất sắc!';
      case WinEffectLevel.medium: return '⚔️ Ấn tượng!';
      case WinEffectLevel.semiPro: return '🎯 Bán chuyên nghiệp!';
      case WinEffectLevel.professional: return '🏆 HUYỀN THOẠI!';
    }
  }

  String _getLevelSubtitle() {
    switch (widget.level) {
      case WinEffectLevel.easy: return 'Bạn đã vượt qua AI dễ';
      case WinEffectLevel.amateur: return 'Bạn đã vượt qua AI nghiệp dư';
      case WinEffectLevel.medium: return 'Bạn đã chinh phục AI trung bình';
      case WinEffectLevel.semiPro: return 'Bạn đã đánh bại AI bán chuyên!';
      case WinEffectLevel.professional: return 'Bạn đã ĐÁNH BẠI AI CHUYÊN NGHIỆP!';
    }
  }

  Color _getGlowColor() {
    switch (widget.level) {
      case WinEffectLevel.easy: return const Color(0xFF4ADE80);
      case WinEffectLevel.amateur: return const Color(0xFF00F2FE);
      case WinEffectLevel.medium: return const Color(0xFFFBBF24);
      case WinEffectLevel.semiPro: return const Color(0xFFA855F7);
      case WinEffectLevel.professional: return const Color(0xFFFFD700);
    }
  }

  double _getTextSize() {
    switch (widget.level) {
      case WinEffectLevel.easy: return 22;
      case WinEffectLevel.amateur: return 24;
      case WinEffectLevel.medium: return 26;
      case WinEffectLevel.semiPro: return 28;
      case WinEffectLevel.professional: return 32;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _getGlowColor();
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: Stack(
        children: [
          // Particle canvas
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: WinEffectPainter(
                  progress: _controller.value,
                  level: widget.level,
                  confetti: _confetti,
                  fireworks: _fireworks,
                  beams: _beams,
                  winnerLabel: widget.winnerLabel,
                  winnerColor: widget.winnerColor,
                ),
              );
            },
          ),

          // Win text card — center of screen
          Center(
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.scale(
                    scale: _textScale.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F172A).withAlpha(230),
                      const Color(0xFF1E293B).withAlpha(220),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: glowColor.withAlpha(180), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withAlpha(100),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: glowColor.withAlpha(40),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Level title
                    Text(
                      _getLevelTitle(),
                      style: TextStyle(
                        fontSize: _getTextSize(),
                        fontWeight: FontWeight.w900,
                        color: glowColor,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(color: glowColor.withAlpha(200), blurRadius: 16),
                          Shadow(color: glowColor.withAlpha(100), blurRadius: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Winner label
                    Text(
                      widget.winnerLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Subtitle
                    Text(
                      _getLevelSubtitle(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(140),
                      ),
                    ),
                    // Pro-level extra flair
                    if (widget.level == WinEffectLevel.professional) ...[
                      const SizedBox(height: 12),
                      _buildProBadge(glowColor),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBadge(Color glowColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = sin(_controller.value * pi * 6) * 0.5 + 0.5;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700).withAlpha(50),
                const Color(0xFFFFA500).withAlpha(30),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD700).withAlpha((100 + pulse * 100).round()),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withAlpha((pulse * 80).round()),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: const Color(0xFFFFD700), size: 14,
                shadows: [Shadow(color: const Color(0xFFFFD700).withAlpha((pulse * 200).round()), blurRadius: 8)]),
              const SizedBox(width: 6),
              const Text(
                'MASTER LEVEL ACHIEVED',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.star_rounded, color: const Color(0xFFFFD700), size: 14,
                shadows: [Shadow(color: const Color(0xFFFFD700).withAlpha((pulse * 200).round()), blurRadius: 8)]),
            ],
          ),
        );
      },
    );
  }
}
