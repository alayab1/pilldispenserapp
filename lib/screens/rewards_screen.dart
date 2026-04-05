import 'package:flutter/material.dart';
import 'dart:math';

// ── Colours ───────────────────────────────────────────────────────────────────
const _bgDark    = Color(0xFF2B2B2B);
const _bgCard    = Color(0xFF383838);
const _accent    = Color(0xFFE8A838);
const _accentDim = Color(0xFF7A561A);
const _textPrim  = Color(0xFFF5EDD6);
const _textSec   = Color(0xFF9A9A9A);
const _success   = Color(0xFF6DBF6A);
const _danger    = Color(0xFFE05C3A);
const _info      = Color(0xFF5B9BD5);

// ── Pet type based on age ─────────────────────────────────────────────────────

enum PetType { walle, mot, eve }

PetType petTypeForAge(int age) {
  if (age < 21)  return PetType.walle;
  if (age <= 50) return PetType.mot;
  return PetType.eve;
}

String petName(PetType type) {
  switch (type) {
    case PetType.walle: return 'WALL-E';
    case PetType.mot:   return 'M-O';
    case PetType.eve:   return 'EVE';
  }
}

// ── Reward actions ────────────────────────────────────────────────────────────

class RewardAction {
  final String label;
  final IconData icon;
  final Color color;
  final int xp;
  final String stat; // which stat it boosts: hunger, clean, happy, energy

  const RewardAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.xp,
    required this.stat,
  });
}

const _actions = [
  RewardAction(label: 'Feed',    icon: Icons.fastfood_rounded,       color: Color(0xFFE8A838), xp: 10, stat: 'hunger'),
  RewardAction(label: 'Clean',   icon: Icons.cleaning_services_rounded, color: Color(0xFF5B9BD5), xp: 10, stat: 'clean'),
  RewardAction(label: 'Pet',     icon: Icons.favorite_rounded,       color: Color(0xFFE07090), xp: 15, stat: 'happy'),
  RewardAction(label: 'Fetch',   icon: Icons.sports_baseball_rounded, color: Color(0xFF7EC86A), xp: 20, stat: 'energy'),
];

// ── Consequence state ─────────────────────────────────────────────────────────

enum ConsequenceState { none, chased, petDead, playerDead }

// ── Rewards screen ────────────────────────────────────────────────────────────

class RewardsScreen extends StatefulWidget {
  final int userAge;
  final int missedDoses;   // pass real missed count from your data layer
  final int currentStreak;

  const RewardsScreen({
    super.key,
    this.userAge = 25,
    this.missedDoses = 0,
    this.currentStreak = 3,
  });

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {

  late PetType _petType;
  late int _xp;
  late int _level;

  // Pet stats 0–100
  double _hunger = 70;
  double _clean  = 60;
  double _happy  = 80;
  double _energy = 50;

  late AnimationController _petBounce;
  late Animation<double>   _bounceAnim;
  late AnimationController _chaseController;
  late Animation<double>   _chaseAnim;

  bool _petJustActed = false;
  String _lastActionMsg = '';
  ConsequenceState _consequence = ConsequenceState.none;

  @override
  void initState() {
    super.initState();
    _petType = petTypeForAge(widget.userAge);
    _xp      = 120;
    _level   = _xp ~/ 100 + 1;

    _petBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -18).animate(
      CurvedAnimation(parent: _petBounce, curve: Curves.easeOut),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) _petBounce.reverse();
    });

    _chaseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _chaseAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _chaseController, curve: Curves.easeInOut),
    );

    // Set consequence based on missed doses
    if (widget.missedDoses >= 3) {
      _consequence = ConsequenceState.playerDead;
    } else if (widget.missedDoses == 2) {
      _consequence = ConsequenceState.petDead;
    } else if (widget.missedDoses == 1) {
      _consequence = ConsequenceState.chased;
    }
  }

  @override
  void dispose() {
    _petBounce.dispose();
    _chaseController.dispose();
    super.dispose();
  }

  void _doAction(RewardAction action) {
    if (_consequence == ConsequenceState.petDead ||
        _consequence == ConsequenceState.playerDead) return;

    setState(() {
      switch (action.stat) {
        case 'hunger': _hunger = min(100, _hunger + 20); break;
        case 'clean':  _clean  = min(100, _clean  + 20); break;
        case 'happy':  _happy  = min(100, _happy  + 20); break;
        case 'energy': _energy = min(100, _energy + 20); break;
      }
      _xp += action.xp;
      _level = _xp ~/ 100 + 1;
      _petJustActed = true;
      _lastActionMsg = '+${action.xp} XP — ${action.label}!';
    });

    _petBounce.forward(from: 0);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _petJustActed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _accent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rewards',
          style: TextStyle(
            color: _accent,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: _accent, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      'Lvl $_level  •  $_xp XP',
                      style: TextStyle(
                          color: _accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [

            // ── Consequence banner ────────────────────────────────────────
            if (_consequence != ConsequenceState.none)
              _ConsequenceBanner(
                state: _consequence,
                missedDoses: widget.missedDoses,
              ),

            const SizedBox(height: 12),

            // ── Streak card ───────────────────────────────────────────────
            _StreakCard(streak: widget.currentStreak),

            const SizedBox(height: 16),

            // ── Pet display ───────────────────────────────────────────────
            _PetCard(
              petType: _petType,
              bounceAnim: _bounceAnim,
              chaseAnim: _chaseAnim,
              consequence: _consequence,
              actionMsg: _petJustActed ? _lastActionMsg : null,
            ),

            const SizedBox(height: 16),

            // ── Pet stats ─────────────────────────────────────────────────
            if (_consequence != ConsequenceState.petDead &&
                _consequence != ConsequenceState.playerDead)
              _PetStats(
                hunger: _hunger,
                clean: _clean,
                happy: _happy,
                energy: _energy,
              ),

            const SizedBox(height: 16),

            // ── Action buttons ────────────────────────────────────────────
            if (_consequence != ConsequenceState.petDead &&
                _consequence != ConsequenceState.playerDead) ...[
              Text(
                'Care for ${petName(_petType)}',
                style: TextStyle(
                  color: _textPrim,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: _actions.map((a) => _ActionButton(
                  action: a,
                  onTap: () => _doAction(a),
                )).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // ── XP progress bar ───────────────────────────────────────────
            _XpBar(xp: _xp, level: _level),
          ],
        ),
      ),
    );
  }
}

// ── Consequence banner ────────────────────────────────────────────────────────

class _ConsequenceBanner extends StatelessWidget {
  final ConsequenceState state;
  final int missedDoses;
  const _ConsequenceBanner({required this.state, required this.missedDoses});

  @override
  Widget build(BuildContext context) {
    String title, subtitle, emoji;
    Color color;

    switch (state) {
      case ConsequenceState.chased:
        title    = 'AUTO is chasing you!';
        subtitle = 'You missed a dose — take your meds to escape!';
        emoji    = '😱';
        color    = Color(0xFFE8A838);
        break;
      case ConsequenceState.petDead:
        title    = 'AUTO got your pet...';
        subtitle = 'You missed 2 doses. Take your meds to revive ${_petLabel(missedDoses)}!';
        emoji    = '💔';
        color    = _danger;
        break;
      case ConsequenceState.playerDead:
        title    = 'AUTO got you!';
        subtitle = 'You missed 3 doses. Take all meds to respawn!';
        emoji    = '💀';
        color    = _danger;
        break;
      default:
        return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(color: _textSec, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _petLabel(int missed) => missed >= 2 ? 'your pet' : 'them';
}

// ── Streak card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text('🔥', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$streak day streak!',
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              Text('Keep taking your meds every day',
                  style: TextStyle(color: _textSec, fontSize: 12)),
            ],
          ),
          const Spacer(),
          // Streak dots (last 7 days)
          Row(
            children: List.generate(7, (i) {
              final active = i < (streak % 7 == 0 ? 7 : streak % 7);
              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? _accent : _accentDim.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Pet card ──────────────────────────────────────────────────────────────────

class _PetCard extends StatelessWidget {
  final PetType petType;
  final Animation<double> bounceAnim;
  final Animation<double> chaseAnim;
  final ConsequenceState consequence;
  final String? actionMsg;

  const _PetCard({
    required this.petType,
    required this.bounceAnim,
    required this.chaseAnim,
    required this.consequence,
    this.actionMsg,
  });

  @override
  Widget build(BuildContext context) {
    final isDead = consequence == ConsequenceState.playerDead;
    final petDead = consequence == ConsequenceState.petDead || isDead;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDead
              ? _danger.withValues(alpha: 0.5)
              : _accent.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Stars/space background dots
          ...List.generate(12, (i) {
            final rng = Random(i * 7);
            return Positioned(
              left: rng.nextDouble() * 320,
              top:  rng.nextDouble() * 180,
              child: Container(
                width: rng.nextDouble() * 3 + 1,
                height: rng.nextDouble() * 3 + 1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _textSec.withValues(alpha: 0.3),
                ),
              ),
            );
          }),

          // AUTO chaser (shown when consequence is active)
          if (consequence == ConsequenceState.chased)
            AnimatedBuilder(
              animation: chaseAnim,
              builder: (_, __) => Positioned(
                right: 20 + chaseAnim.value,
                bottom: 30,
                child: Opacity(
                  opacity: 0.85,
                  child: _AutoPainter(),
                ),
              ),
            ),

          // Pet
          AnimatedBuilder(
            animation: bounceAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, bounceAnim.value),
              child: child,
            ),
            child: Opacity(
              opacity: petDead ? 0.35 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPet(petType, petDead),
                  const SizedBox(height: 8),
                  Text(
                    petDead
                        ? '${petName(petType)} 💔'
                        : petName(petType),
                    style: TextStyle(
                      color: petDead ? _danger : _textPrim,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action message popup
          if (actionMsg != null)
            Positioned(
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _success.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  actionMsg!,
                  style: TextStyle(
                    color: _bgDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // Dead overlay text
          if (isDead)
            Container(
              decoration: BoxDecoration(
                color: _danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'GAME OVER\nTake your meds to respawn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _danger,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPet(PetType type, bool dead) {
    switch (type) {
      case PetType.walle:
        return SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: _WallePetPainter(dead: dead)),
        );
      case PetType.mot:
        return SizedBox(
          width: 90,
          height: 90,
          child: CustomPaint(painter: _MOTPainter(dead: dead)),
        );
      case PetType.eve:
        return SizedBox(
          width: 110,
          height: 90,
          child: CustomPaint(painter: _EvePainter(dead: dead)),
        );
    }
  }
}

// ── WALL-E pet painter ────────────────────────────────────────────────────────

class _WallePetPainter extends CustomPainter {
  final bool dead;
  const _WallePetPainter({this.dead = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final amber  = dead ? const Color(0xFF666666) : const Color(0xFFB8862A);
    final dark   = const Color(0xFF1A1A1A);
    final amberL = dead ? const Color(0xFF888888) : const Color(0xFFD4A030);

    // Treads
    final tread = Paint()..color = dark;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*0.04, h*0.70, w*0.20, h*0.26), const Radius.circular(5)), tread);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*0.76, h*0.70, w*0.20, h*0.26), const Radius.circular(5)), tread);

    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*0.18, h*0.54, w*0.64, h*0.36), const Radius.circular(5)),
        Paint()..color = amber);

    // Neck
    canvas.drawRect(Rect.fromLTWH(w*0.40, h*0.36, w*0.20, h*0.20),
        Paint()..color = const Color(0xFF8A6010));

    // Head
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*0.12, h*0.08, w*0.76, h*0.30), const Radius.circular(7)),
        Paint()..color = amber);

    // Eyes
    _eye(canvas, Offset(w*0.315, h*0.225), w*0.13, dead);
    _eye(canvas, Offset(w*0.685, h*0.225), w*0.13, dead);

    // Eye bridge
    canvas.drawRect(Rect.fromLTWH(w*0.38, h*0.18, w*0.24, h*0.055),
        Paint()..color = dark);
  }

  void _eye(Canvas canvas, Offset c, double r, bool dead) {
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawCircle(c, r*0.75, Paint()..color = const Color(0xFF0D1A2A));
    canvas.drawCircle(c, r*0.50,
        Paint()..color = dead ? const Color(0xFF444444) : const Color(0xFF2E6DA4));
    canvas.drawCircle(c, r*0.25, Paint()..color = const Color(0xFF0A0A0A));
    if (!dead) {
      canvas.drawCircle(c + Offset(-r*0.18, -r*0.18), r*0.13,
          Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── M-O painter ───────────────────────────────────────────────────────────────

class _MOTPainter extends CustomPainter {
  final bool dead;
  const _MOTPainter({this.dead = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final blue  = dead ? const Color(0xFF444444) : const Color(0xFF3A6EA8);
    final blueL = dead ? const Color(0xFF666666) : const Color(0xFF5B9BD5);
    final dark  = const Color(0xFF1A1A1A);
    final white = dead ? const Color(0xFF555555) : const Color(0xFFDDEEFF);

    // Base / wheels
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*0.10, h*0.72, w*0.80, h*0.20), const Radius.circular(8)),
        Paint()..color = dark);

    // Left wheel dot
    canvas.drawCircle(Offset(w*0.25, h*0.82), w*0.07, Paint()..color = const Color(0xFF333333));
    canvas.drawCircle(Offset(w*0.75, h*0.82), w*0.07, Paint()..color = const Color(0xFF333333));

    // Body dome (round)
    canvas.drawOval(
        Rect.fromLTWH(w*0.15, h*0.18, w*0.70, h*0.58),
        Paint()..color = blueL);

    // Body shadow
    canvas.drawOval(
        Rect.fromLTWH(w*0.20, h*0.38, w*0.60, h*0.34),
        Paint()..color = blue);

    // Visor (dark screen on front)
    canvas.drawOval(
        Rect.fromLTWH(w*0.22, h*0.20, w*0.56, h*0.36),
        Paint()..color = dark);

    // Eye / screen glow
    if (!dead) {
      canvas.drawOval(
          Rect.fromLTWH(w*0.28, h*0.25, w*0.44, h*0.26),
          Paint()..color = const Color(0xFF1A3A5C));
      // Single eye dot
      canvas.drawCircle(Offset(w*0.50, h*0.38), w*0.10,
          Paint()..color = blueL);
      canvas.drawCircle(Offset(w*0.50, h*0.38), w*0.05,
          Paint()..color = white);
      // Shine
      canvas.drawCircle(Offset(w*0.44, h*0.33), w*0.025,
          Paint()..color = Colors.white.withValues(alpha: 0.7));
    } else {
      // X eyes when dead
      final xPaint = Paint()
        ..color = const Color(0xFF666666)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(w*0.38, h*0.28), Offset(w*0.48, h*0.40), xPaint);
      canvas.drawLine(Offset(w*0.48, h*0.28), Offset(w*0.38, h*0.40), xPaint);
    }

    // Brush arm on side
    canvas.drawRect(Rect.fromLTWH(w*0.78, h*0.38, w*0.12, h*0.28),
        Paint()..color = blue);
    canvas.drawRect(Rect.fromLTWH(w*0.76, h*0.62, w*0.16, h*0.08),
        Paint()..color = blueL);

    // M-O label on body
    final tp = TextPainter(
      text: TextSpan(
        text: 'M-O',
        style: TextStyle(
          color: dead ? const Color(0xFF444444) : white,
          fontSize: w * 0.14,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w*0.50 - tp.width/2, h*0.48));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── EVE painter ───────────────────────────────────────────────────────────────

class _EvePainter extends CustomPainter {
  final bool dead;
  const _EvePainter({this.dead = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final white  = dead ? const Color(0xFF666666) : const Color(0xFFEEF4FF);
    final whiteD = dead ? const Color(0xFF555555) : const Color(0xFFCCDDEE);
    final cyan   = dead ? const Color(0xFF444444) : const Color(0xFF00D4FF);
    final dark   = const Color(0xFF1A1A1A);

    // Hover glow underneath
    if (!dead) {
      canvas.drawOval(
          Rect.fromLTWH(w*0.20, h*0.82, w*0.60, h*0.12),
          Paint()..color = cyan.withValues(alpha: 0.2));
    }

    // Body — sleek egg shape
    canvas.drawOval(
        Rect.fromLTWH(w*0.10, h*0.10, w*0.80, h*0.78),
        Paint()..color = white);

    // Body shading
    canvas.drawOval(
        Rect.fromLTWH(w*0.18, h*0.40, w*0.64, h*0.44),
        Paint()..color = whiteD);

    // Neck indent
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w*0.35, h*0.55, w*0.30, h*0.12),
            const Radius.circular(4)),
        Paint()..color = whiteD);

    // Eyes — EVE has two glowing cyan oval eyes
    if (!dead) {
      final eyePaint = Paint()..color = cyan;
      canvas.drawOval(Rect.fromLTWH(w*0.20, h*0.28, w*0.22, h*0.14), eyePaint);
      canvas.drawOval(Rect.fromLTWH(w*0.58, h*0.28, w*0.22, h*0.14), eyePaint);
      // Eye shine
      canvas.drawOval(
          Rect.fromLTWH(w*0.22, h*0.29, w*0.08, h*0.05),
          Paint()..color = Colors.white.withValues(alpha: 0.6));
      canvas.drawOval(
          Rect.fromLTWH(w*0.60, h*0.29, w*0.08, h*0.05),
          Paint()..color = Colors.white.withValues(alpha: 0.6));
    } else {
      final xPaint = Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(w*0.22, h*0.28), Offset(w*0.38, h*0.42), xPaint);
      canvas.drawLine(Offset(w*0.38, h*0.28), Offset(w*0.22, h*0.42), xPaint);
      canvas.drawLine(Offset(w*0.60, h*0.28), Offset(w*0.76, h*0.42), xPaint);
      canvas.drawLine(Offset(w*0.76, h*0.28), Offset(w*0.60, h*0.42), xPaint);
    }

    // Hand stubs
    canvas.drawOval(Rect.fromLTWH(w*0.0,  h*0.42, w*0.14, h*0.18),
        Paint()..color = white);
    canvas.drawOval(Rect.fromLTWH(w*0.86, h*0.42, w*0.14, h*0.18),
        Paint()..color = white);

    // Cyan chest gem
    if (!dead) {
      canvas.drawCircle(Offset(w*0.50, h*0.65), w*0.07,
          Paint()..color = cyan.withValues(alpha: 0.8));
      canvas.drawCircle(Offset(w*0.50, h*0.65), w*0.04,
          Paint()..color = Colors.white.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── AUTO chaser painter ───────────────────────────────────────────────────────

class _AutoPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(painter: _AutoCustomPainter()),
    );
  }
}

class _AutoCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // AUTO is the steering wheel villain — red eye in a wheel
    // Outer ring
    canvas.drawCircle(Offset(w/2, h/2), w*0.48,
        Paint()..color = const Color(0xFFCC2200));
    canvas.drawCircle(Offset(w/2, h/2), w*0.38,
        Paint()..color = const Color(0xFF1A1A1A));
    // Red eye
    canvas.drawCircle(Offset(w/2, h/2), w*0.22,
        Paint()..color = const Color(0xFFFF3300));
    canvas.drawCircle(Offset(w/2, h/2), w*0.10,
        Paint()..color = const Color(0xFFFF6600));
    // Spokes
    final spoke = Paint()
      ..color = const Color(0xFFCC2200)
      ..strokeWidth = 4;
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120) * pi / 180;
      canvas.drawLine(
        Offset(w/2 + cos(angle) * w*0.22, h/2 + sin(angle) * h*0.22),
        Offset(w/2 + cos(angle) * w*0.46, h/2 + sin(angle) * h*0.46),
        spoke,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Pet stats ─────────────────────────────────────────────────────────────────

class _PetStats extends StatelessWidget {
  final double hunger, clean, happy, energy;
  const _PetStats({
    required this.hunger,
    required this.clean,
    required this.happy,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pet stats',
              style: TextStyle(
                  color: _textPrim,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 12),
          _StatBar(label: '🍔 Hunger', value: hunger, color: Color(0xFFE8A838)),
          _StatBar(label: '🧹 Clean',  value: clean,  color: Color(0xFF5B9BD5)),
          _StatBar(label: '💖 Happy',  value: happy,  color: Color(0xFFE07090)),
          _StatBar(label: '⚡ Energy', value: energy, color: Color(0xFF7EC86A)),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StatBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(color: _textSec, fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                backgroundColor: _accentDim.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${value.toInt()}',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final RewardAction action;
  final VoidCallback onTap;
  const _ActionButton({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: action.color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.label,
                    style: TextStyle(
                        color: _textPrim,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('+${action.xp} XP',
                    style: TextStyle(
                        color: action.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── XP progress bar ───────────────────────────────────────────────────────────

class _XpBar extends StatelessWidget {
  final int xp, level;
  const _XpBar({required this.xp, required this.level});

  @override
  Widget build(BuildContext context) {
    final xpInLevel  = xp % 100;
    final xpToNext   = 100;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level $level',
                  style: TextStyle(
                      color: _textPrim,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text('$xpInLevel / $xpToNext XP to next level',
                  style: TextStyle(color: _accent, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpInLevel / xpToNext,
              minHeight: 10,
              backgroundColor: _accentDim.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
        ],
      ),
    );
  }
}