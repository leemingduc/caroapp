// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

extension type AudioContext._(JSObject _) implements JSObject {
  external factory AudioContext();
  external JSNumber get currentTime;
  external OscillatorNode createOscillator();
  external GainNode createGain();
  external AudioDestinationNode get destination;
}

extension type AudioNode._(JSObject _) implements JSObject {
  external void connect(AudioNode destination);
}

extension type AudioDestinationNode._(JSObject _) implements AudioNode {}

extension type OscillatorNode._(JSObject _) implements AudioNode {
  external AudioParam get frequency;
  external set type(JSString value);
  external void start([JSNumber when]);
  external void stop([JSNumber when]);
}

extension type GainNode._(JSObject _) implements AudioNode {
  external AudioParam get gain;
}

extension type AudioParam._(JSObject _) implements JSObject {
  external void setValueAtTime(JSNumber value, JSNumber startTime);
  external void exponentialRampToValueAtTime(JSNumber value, JSNumber endTime);
  external void linearRampToValueAtTime(JSNumber value, JSNumber endTime);
}

/// Service tạo âm thanh procedurally bằng Web Audio API.
/// Không cần assets file, hoạt động hoàn toàn trên Flutter Web.
class AudioService {
  static AudioContext? _ctx;
  static bool _enabled = true;

  static bool get isEnabled => _enabled;
  static void setEnabled(bool value) => _enabled = value;

  static AudioContext _getCtx() {
    _ctx ??= AudioContext();
    return _ctx!;
  }

  /// Âm thanh đặt quân X theo từng skin (tần số cao, sắc nét)
  static void playPlaceX([String skinId = 'default']) {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;

      if (skinId == 'gold') {
        // Vàng hoàng kim - Chuông vang lấp lánh (chime metallic)
        _playNote(ctx, 1200, now, 0.15, 0.25, 'sine');
        _playNote(ctx, 1800, now + 0.04, 0.08, 0.2, 'sine');
      } else if (skinId == 'volcano') {
        // Hỏa ngục magma - Sóng răng cưa (sawtooth) trầm đục quét tần số đi xuống
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'sawtooth'.toJS;
        osc.frequency.setValueAtTime(320.0.toJS, now.toJS);
        osc.frequency.linearRampToValueAtTime(60.0.toJS, (now + 0.18).toJS);
        gain.gain.setValueAtTime(0.12.toJS, now.toJS);
        gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.22).toJS);
        osc.start(now.toJS);
        osc.stop((now + 0.25).toJS);
      } else if (skinId == 'ocean') {
        // Xanh đại dương - Giọt nước quét tần số đi lên nhanh, mượt mà
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'sine'.toJS;
        osc.frequency.setValueAtTime(600.0.toJS, now.toJS);
        osc.frequency.exponentialRampToValueAtTime(950.0.toJS, (now + 0.12).toJS);
        gain.gain.setValueAtTime(0.22.toJS, now.toJS);
        gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.16).toJS);
        osc.start(now.toJS);
        osc.stop((now + 0.18).toJS);
      } else {
        // Neon mặc định
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'sine'.toJS;
        osc.frequency.setValueAtTime(880.0.toJS, now.toJS);
        osc.frequency.exponentialRampToValueAtTime(440.0.toJS, (now + 0.12).toJS);
        gain.gain.setValueAtTime(0.25.toJS, now.toJS);
        gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.18).toJS);
        osc.start(now.toJS);
        osc.stop((now + 0.20).toJS);
      }
    } catch (_) {}
  }

  /// Âm thanh đặt quân O theo từng skin (tần số trầm hơn, mềm hơn)
  static void playPlaceO([String skinId = 'default']) {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;

      if (skinId == 'gold') {
        // Vàng hoàng kim - Chuông vàng ấm hơn
        _playNote(ctx, 900, now, 0.15, 0.28, 'sine');
        _playNote(ctx, 1350, now + 0.05, 0.08, 0.22, 'sine');
      } else if (skinId == 'volcano') {
        // Hỏa ngục magma - Răng cưa cực trầm và kéo dài hơn
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'sawtooth'.toJS;
        osc.frequency.setValueAtTime(240.0.toJS, now.toJS);
        osc.frequency.linearRampToValueAtTime(45.0.toJS, (now + 0.22).toJS);
        gain.gain.setValueAtTime(0.12.toJS, now.toJS);
        gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.26).toJS);
        osc.start(now.toJS);
        osc.stop((now + 0.30).toJS);
      } else if (skinId == 'ocean') {
        // Xanh đại dương - Giọt nước bong bóng trầm hơn
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'sine'.toJS;
        osc.frequency.setValueAtTime(400.0.toJS, now.toJS);
        osc.frequency.exponentialRampToValueAtTime(650.0.toJS, (now + 0.15).toJS);
        gain.gain.setValueAtTime(0.20.toJS, now.toJS);
        gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.18).toJS);
        osc.start(now.toJS);
        osc.stop((now + 0.20).toJS);
      } else {
        // Neon mặc định
        final osc = ctx.createOscillator();
        final gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.type = 'triangle'.toJS;
        osc.frequency.setValueAtTime(523.0.toJS, now.toJS);
        osc.frequency.exponentialRampToValueAtTime(261.0.toJS, (now + 0.15).toJS);
        gain.gain.setValueAtTime(0.22.toJS, now.toJS);
        gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.2).toJS);
        osc.start(now.toJS);
        osc.stop((now + 0.22).toJS);
      }
    } catch (_) {}
  }

  /// Âm thanh thắng ở cấp dễ — Giai điệu vui tươi + sustain (~2.5s)
  static void playWinEasy() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      // Melody ascending C major
      final melody = [523, 587, 659, 698, 784, 880, 988, 1047];
      for (int i = 0; i < melody.length; i++) {
        _playNote(ctx, melody[i].toDouble(), now + i * 0.14, 0.22, 0.28, 'sine');
      }
      // Sustain chord — C Major (kéo dài)
      _playNote(ctx, 523.25, now + 1.2, 0.15, 1.2, 'sine');
      _playNote(ctx, 659.25, now + 1.2, 0.12, 1.2, 'triangle');
      _playNote(ctx, 783.99, now + 1.2, 0.12, 1.2, 'sine');
    } catch (_) {}
  }

  /// Âm thanh thắng ở cấp amateur — Fanfare nhỏ + sustain (~3s)
  static void playWinAmateur() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      // Melody ascending with jumps
      final melody = [523, 659, 784, 880, 988, 1047, 1319, 1047];
      for (int i = 0; i < melody.length; i++) {
        _playNote(ctx, melody[i].toDouble(), now + i * 0.13, 0.22, 0.26, 'sine');
      }
      // Sustain chord — G Major (vui nhộn)
      _playNote(ctx, 392.00, now + 1.1, 0.15, 1.5, 'sine');
      _playNote(ctx, 493.88, now + 1.1, 0.12, 1.5, 'triangle');
      _playNote(ctx, 587.33, now + 1.1, 0.12, 1.5, 'sine');
      _playNote(ctx, 783.99, now + 1.1, 0.10, 1.5, 'sine');
      // Sparkle ending
      _playNote(ctx, 1568.0, now + 2.2, 0.06, 0.5, 'sine');
      _playNote(ctx, 2093.0, now + 2.4, 0.05, 0.5, 'sine');
    } catch (_) {}
  }

  /// Âm thanh thắng ở cấp trung bình — Progression + sparkle ending (~3.5s)
  static void playWinMedium() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      // Melody with bold intervals
      final melody = [523, 659, 784, 1047, 587, 739, 880, 1175, 1319];
      for (int i = 0; i < melody.length; i++) {
        _playNote(ctx, melody[i].toDouble(), now + i * 0.12, 0.24, 0.28, 'sine');
      }
      // Chord progression: C → F → G → C (hoành tráng hơn)
      _playNote(ctx, 261.63, now + 1.1, 0.15, 0.5, 'triangle');
      _playNote(ctx, 523.25, now + 1.1, 0.12, 0.5, 'sine');
      _playNote(ctx, 349.23, now + 1.6, 0.15, 0.5, 'triangle');
      _playNote(ctx, 698.46, now + 1.6, 0.12, 0.5, 'sine');
      _playNote(ctx, 392.00, now + 2.1, 0.18, 0.5, 'triangle');
      _playNote(ctx, 783.99, now + 2.1, 0.15, 0.5, 'sine');
      // Grand finale sustain
      _playNote(ctx, 523.25, now + 2.6, 0.15, 1.0, 'sine');
      _playNote(ctx, 659.25, now + 2.6, 0.12, 1.0, 'triangle');
      _playNote(ctx, 783.99, now + 2.6, 0.12, 1.0, 'sine');
      _playNote(ctx, 1046.50, now + 2.6, 0.10, 1.0, 'sine');
      // Sparkle
      _playNote(ctx, 1568.0, now + 3.0, 0.06, 0.4, 'sine');
      _playNote(ctx, 2093.0, now + 3.2, 0.05, 0.4, 'sine');
    } catch (_) {}
  }

  /// Âm thanh thắng ở cấp bán chuyên — Fanfare rực rỡ + brass sustain (~4s)
  static void playWinSemiPro() {
    if (!_enabled) return;
    _playFanfare();
  }

  /// Âm thanh thắng ở cấp chuyên nghiệp — Epic orchestral + grand finale (~5s)
  static void playWinPro() {
    if (!_enabled) return;
    _playEpicWin();
  }

  /// Âm thanh thua
  static void playLose() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      _playNote(ctx, 392, now, 0.2, 0.25, 'sawtooth');
      _playNote(ctx, 330, now + 0.3, 0.18, 0.22, 'sawtooth');
      _playNote(ctx, 261, now + 0.6, 0.15, 0.2, 'sawtooth');
    } catch (_) {}
  }

  /// Âm thanh hòa
  static void playDraw() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      _playNote(ctx, 523, now, 0.15, 0.18, 'sine');
      _playNote(ctx, 523, now + 0.4, 0.12, 0.15, 'sine');
    } catch (_) {}
  }

  /// Âm thanh nhận kim cương
  static void playDiamond() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      _playNote(ctx, 1047, now, 0.15, 0.15, 'sine');
      _playNote(ctx, 1319, now + 0.1, 0.12, 0.15, 'sine');
      _playNote(ctx, 1568, now + 0.2, 0.1, 0.2, 'sine');
    } catch (_) {}
  }

  /// Âm thanh cảnh báo hồi sinh — Heartbeat + urgency beeps (~2.5s)
  static void playReviveAlert() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;

      // ── 1. Heartbeat (2 nhịp đập trầm, tạo cảm giác nguy hiểm) ──
      // Nhịp 1: lub-dub
      _playNote(ctx, 60.0, now, 0.30, 0.12, 'sine');
      _playNote(ctx, 45.0, now + 0.12, 0.25, 0.10, 'sine');
      // Nhịp 2: lub-dub (nhanh hơn)
      _playNote(ctx, 65.0, now + 0.35, 0.32, 0.11, 'sine');
      _playNote(ctx, 48.0, now + 0.46, 0.27, 0.09, 'sine');

      // ── 2. Urgency beeps (3 chuỗi leo thang tần số) ──
      // Chuỗi 1 — chậm
      _playNote(ctx, 440.0, now + 0.70, 0.15, 0.10, 'square');
      _playNote(ctx, 554.37, now + 0.82, 0.15, 0.10, 'square');
      _playNote(ctx, 659.25, now + 0.94, 0.18, 0.12, 'square');

      // Chuỗi 2 — nhanh hơn, cao hơn
      _playNote(ctx, 523.25, now + 1.15, 0.18, 0.08, 'square');
      _playNote(ctx, 659.25, now + 1.25, 0.18, 0.08, 'square');
      _playNote(ctx, 783.99, now + 1.35, 0.20, 0.10, 'square');

      // Chuỗi 3 — nhanh nhất, cao nhất (cực khẩn cấp)
      _playNote(ctx, 659.25, now + 1.55, 0.20, 0.06, 'square');
      _playNote(ctx, 783.99, now + 1.63, 0.22, 0.06, 'square');
      _playNote(ctx, 987.77, now + 1.71, 0.25, 0.08, 'square');

      // ── 3. Âm huyền ảo hy vọng cuối (A Major arpeggio) ──
      _playNote(ctx, 440.0, now + 1.90, 0.15, 0.25, 'sine');
      _playNote(ctx, 554.37, now + 1.98, 0.15, 0.25, 'sine');
      _playNote(ctx, 659.25, now + 2.06, 0.15, 0.25, 'sine');
      _playNote(ctx, 880.0, now + 2.14, 0.18, 0.35, 'sine');
    } catch (_) {}
  }

  /// Âm thanh hồi sinh thành công — Phoenix rising effect (~1.8s)
  static void playReviveSuccess() {
    if (!_enabled) return;
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;

      // 1. Quét tần số "phoenix rising" (Upward sweep mạnh mẽ)
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.type = 'triangle'.toJS;
      osc.frequency.setValueAtTime(150.0.toJS, now.toJS);
      osc.frequency.exponentialRampToValueAtTime(1500.0.toJS, (now + 0.5).toJS);

      gain.gain.setValueAtTime(0.01.toJS, now.toJS);
      gain.gain.linearRampToValueAtTime(0.22.toJS, (now + 0.15).toJS);
      gain.gain.exponentialRampToValueAtTime(0.001.toJS, (now + 0.6).toJS);

      osc.start(now.toJS);
      osc.stop((now + 0.65).toJS);

      // 2. Power chord tại đỉnh
      _playNote(ctx, 523.25, now + 0.4, 0.18, 0.6, 'sine');
      _playNote(ctx, 659.25, now + 0.4, 0.14, 0.6, 'triangle');
      _playNote(ctx, 783.99, now + 0.4, 0.14, 0.6, 'sine');

      // 3. Chuông lấp lánh (sparkling chimes) ngân dài
      _playNote(ctx, 1320.0, now + 0.55, 0.10, 0.5, 'sine');
      _playNote(ctx, 1661.22, now + 0.65, 0.08, 0.5, 'sine');
      _playNote(ctx, 1975.53, now + 0.75, 0.08, 0.5, 'sine');
      _playNote(ctx, 2637.02, now + 0.85, 0.06, 0.6, 'sine');

      // 4. Sustain chord ngân dài kết thúc
      _playNote(ctx, 523.25, now + 1.0, 0.12, 0.8, 'sine');
      _playNote(ctx, 783.99, now + 1.0, 0.10, 0.8, 'triangle');
      _playNote(ctx, 1046.50, now + 1.0, 0.08, 0.8, 'sine');
    } catch (_) {}
  }

  // ─── Internal helpers ────────────────────────────────────────────────────


  static void _playFanfare() {
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;
      // Nhịp Fanfare rực rỡ
      final freqs = [523, 659, 784, 1047, 784, 1047, 1319, 1047, 1319, 1568];
      for (int i = 0; i < freqs.length; i++) {
        _playNote(ctx, freqs[i].toDouble(), now + i * 0.10, 0.25, 0.25, 'sine');
      }
      // Bè bass hòa âm
      _playNote(ctx, 261.63, now, 0.15, 0.6, 'triangle');
      _playNote(ctx, 392.00, now + 0.4, 0.15, 0.6, 'triangle');
      _playNote(ctx, 523.25, now + 0.8, 0.18, 0.8, 'triangle');

      // ── Phần mới: Brass sustain kéo dài (~2s thêm) ──
      // Hợp âm F Major sustain
      _playNote(ctx, 349.23, now + 1.2, 0.15, 0.7, 'sine');
      _playNote(ctx, 440.00, now + 1.2, 0.12, 0.7, 'triangle');
      _playNote(ctx, 523.25, now + 1.2, 0.12, 0.7, 'sine');
      _playNote(ctx, 698.46, now + 1.2, 0.10, 0.7, 'sine');

      // Hợp âm G Major resolve
      _playNote(ctx, 392.00, now + 1.9, 0.15, 0.7, 'sine');
      _playNote(ctx, 493.88, now + 1.9, 0.12, 0.7, 'triangle');
      _playNote(ctx, 587.33, now + 1.9, 0.12, 0.7, 'sine');
      _playNote(ctx, 783.99, now + 1.9, 0.10, 0.7, 'sine');

      // Grand C Major finale
      _playNote(ctx, 261.63, now + 2.6, 0.18, 1.4, 'sine');
      _playNote(ctx, 523.25, now + 2.6, 0.15, 1.4, 'sine');
      _playNote(ctx, 659.25, now + 2.6, 0.12, 1.4, 'triangle');
      _playNote(ctx, 783.99, now + 2.6, 0.12, 1.4, 'sine');
      _playNote(ctx, 1046.50, now + 2.6, 0.10, 1.4, 'sine');

      // Sparkle finale
      _playNote(ctx, 1568.0, now + 3.2, 0.06, 0.5, 'sine');
      _playNote(ctx, 2093.0, now + 3.4, 0.05, 0.5, 'sine');
    } catch (_) {}
  }

  static void _playEpicWin() {
    try {
      final ctx = _getCtx();
      final now = ctx.currentTime.toDartDouble;

      // Hợp âm 1: C Major (C4, E4, G4, C5)
      _playNote(ctx, 261.63, now, 0.20, 0.4, 'sine');
      _playNote(ctx, 329.63, now, 0.15, 0.4, 'triangle');
      _playNote(ctx, 392.00, now, 0.15, 0.4, 'sine');
      _playNote(ctx, 523.25, now, 0.15, 0.4, 'sine');

      // Hợp âm 2: F Major (F4, A4, C5, F5)
      _playNote(ctx, 349.23, now + 0.4, 0.20, 0.4, 'sine');
      _playNote(ctx, 440.00, now + 0.4, 0.15, 0.4, 'triangle');
      _playNote(ctx, 523.25, now + 0.4, 0.15, 0.4, 'sine');
      _playNote(ctx, 698.46, now + 0.4, 0.15, 0.4, 'sine');

      // Hợp âm 3: G Major (G4, B4, D5, G5)
      _playNote(ctx, 392.00, now + 0.8, 0.20, 0.4, 'sine');
      _playNote(ctx, 493.88, now + 0.8, 0.15, 0.4, 'triangle');
      _playNote(ctx, 587.33, now + 0.8, 0.15, 0.4, 'sine');
      _playNote(ctx, 783.99, now + 0.8, 0.15, 0.4, 'sine');

      // Hợp âm 4: Grand C Major Resolution (giữ rất dài)
      _playNote(ctx, 130.81, now + 1.2, 0.35, 2.0, 'sawtooth'); // Bass cực trầm
      _playNote(ctx, 261.63, now + 1.2, 0.20, 2.0, 'sine');
      _playNote(ctx, 329.63, now + 1.2, 0.15, 2.0, 'triangle');
      _playNote(ctx, 392.00, now + 1.2, 0.15, 2.0, 'sine');
      _playNote(ctx, 523.25, now + 1.2, 0.18, 2.0, 'sine');
      _playNote(ctx, 659.25, now + 1.2, 0.12, 2.0, 'sine');
      _playNote(ctx, 783.99, now + 1.2, 0.12, 2.0, 'sine');
      _playNote(ctx, 1046.50, now + 1.2, 0.15, 2.2, 'sine'); // Nốt C6 sáng

      // Sparkle effects trong lúc ngân hợp âm cuối
      _playNote(ctx, 1318.51, now + 1.5, 0.08, 0.3, 'sine');
      _playNote(ctx, 1567.98, now + 1.8, 0.08, 0.3, 'sine');
      _playNote(ctx, 2093.00, now + 2.1, 0.10, 0.5, 'sine');
      _playNote(ctx, 2637.02, now + 2.4, 0.08, 0.5, 'sine');

      // ── Phần mới: Epic crescendo finale (~2s thêm) ──
      // Hợp âm Ab Major (dramatic tension)
      _playNote(ctx, 207.65, now + 3.2, 0.18, 0.6, 'sine');
      _playNote(ctx, 261.63, now + 3.2, 0.14, 0.6, 'triangle');
      _playNote(ctx, 311.13, now + 3.2, 0.14, 0.6, 'sine');
      _playNote(ctx, 415.30, now + 3.2, 0.12, 0.6, 'sine');

      // Resolve to C Major GRAND (cực hoành tráng)
      _playNote(ctx, 130.81, now + 3.8, 0.30, 1.5, 'sawtooth');
      _playNote(ctx, 261.63, now + 3.8, 0.22, 1.5, 'sine');
      _playNote(ctx, 329.63, now + 3.8, 0.18, 1.5, 'triangle');
      _playNote(ctx, 392.00, now + 3.8, 0.18, 1.5, 'sine');
      _playNote(ctx, 523.25, now + 3.8, 0.18, 1.5, 'sine');
      _playNote(ctx, 659.25, now + 3.8, 0.15, 1.5, 'sine');
      _playNote(ctx, 783.99, now + 3.8, 0.15, 1.5, 'sine');
      _playNote(ctx, 1046.50, now + 3.8, 0.15, 1.5, 'sine');
      _playNote(ctx, 1318.51, now + 3.8, 0.10, 1.5, 'sine');

      // Final sparkle cascade
      _playNote(ctx, 2093.00, now + 4.2, 0.06, 0.6, 'sine');
      _playNote(ctx, 2637.02, now + 4.4, 0.06, 0.6, 'sine');
      _playNote(ctx, 3135.96, now + 4.6, 0.05, 0.8, 'sine');
    } catch (_) {}
  }

  static void _playNote(
    AudioContext ctx,
    double freq,
    double startTime,
    double gainVal,
    double duration,
    String type,
  ) {
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.type = type.toJS;
    osc.frequency.setValueAtTime(freq.toJS, startTime.toJS);

    gain.gain.setValueAtTime(gainVal.toJS, startTime.toJS);
    gain.gain.exponentialRampToValueAtTime(0.001.toJS, (startTime + duration).toJS);

    osc.start(startTime.toJS);
    osc.stop((startTime + duration + 0.05).toJS);
  }
}
