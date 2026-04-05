import 'package:flutter/material.dart';
import 'dart:async';
import 'schedule_screen.dart';
import 'bluetooth_screen.dart';
import '../services/bluetooth_service.dart';

// ── Placeholder models (replace with your real models later) ──────────────────

class Medication {
  final String name;
  final String dosage;
  final List<TimeOfDay> times;
  final int pillsRemaining;
  final int refillThreshold;
  final Color color;
  // 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun
  // Default: every day
  final List<int> scheduledDays;

  const Medication({
    required this.name,
    required this.dosage,
    required this.times,
    required this.pillsRemaining,
    required this.refillThreshold,
    required this.color,
    required this.scheduledDays,
  });

  bool get needsRefill => pillsRemaining <= refillThreshold;
}

class ScheduledDose {
  final Medication medication;
  final TimeOfDay time;
  final bool taken;

  const ScheduledDose({
    required this.medication,
    required this.time,
    this.taken = false,
  });
}

// ── Sample data (swap out with Hive/Riverpod later) ───────────────────────────

final List<Medication> sampleMeds = [
  Medication(
    name: 'Metformin',
    dosage: '500 mg',
    times: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
    pillsRemaining: 5,
    refillThreshold: 7,
    color: Color(0xFFE8A838),
    scheduledDays: [0, 1, 2, 3, 4, 5, 6], // every day
  ),
  Medication(
    name: 'Lisinopril',
    dosage: '10 mg',
    times: [TimeOfDay(hour: 9, minute: 30)],
    pillsRemaining: 20,
    refillThreshold: 7,
    color: Color(0xFF5B9BD5),
    scheduledDays: [0, 1, 2, 3, 4], // weekdays only
  ),
  Medication(
    name: 'Vitamin D',
    dosage: '1000 IU',
    times: [TimeOfDay(hour: 12, minute: 0)],
    pillsRemaining: 3,
    refillThreshold: 7,
    color: Color(0xFF7EC86A),
    scheduledDays: [0, 2, 4], // Mon, Wed, Fri
  ),
];

List<ScheduledDose> buildTodaySchedule() {
  final doses = <ScheduledDose>[];
  final now = TimeOfDay.now();
  final todayIndex = DateTime.now().weekday - 1; // 0=Mon … 6=Sun
  for (final med in sampleMeds) {
    if (!med.scheduledDays.contains(todayIndex)) continue;
    for (final t in med.times) {
      final isPast =
          t.hour < now.hour || (t.hour == now.hour && t.minute <= now.minute);
      doses.add(ScheduledDose(medication: med, time: t, taken: isPast));
    }
  }
  doses.sort((a, b) {
    final aMin = a.time.hour * 60 + a.time.minute;
    final bMin = b.time.hour * 60 + b.time.minute;
    return aMin.compareTo(bMin);
  });
  return doses;
}

// ── Colours & theme ───────────────────────────────────────────────────────────

const _bgDark    = Color(0xFF2B2B2B);  // main gray background
const _bgCard    = Color(0xFF383838);  // card gray
const _accent    = Color(0xFFE8A838);  // WALL-E amber/gold
const _accentDim = Color(0xFF7A561A);
const _textPrim  = Color(0xFFF5EDD6);
const _textSec   = Color(0xFF9A9A9A);
const _danger    = Color(0xFFE05C3A);
const _success   = Color(0xFF6DBF6A);

// ── Home screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final BluetoothService btService;
  const HomeScreen({super.key, required this.btService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();
  late List<ScheduledDose> _doses;
  late AnimationController _walleController;
  late Animation<double> _walleFloat;

  @override
  void initState() {
    super.initState();
    _doses = buildTodaySchedule();

    // Tick clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    // WALL-E floating animation
    _walleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _walleFloat = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _walleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _walleController.dispose();
    super.dispose();
  }

  ScheduledDose? get _nextDose {
    final now = TimeOfDay.fromDateTime(_now);
    final nowMin = now.hour * 60 + now.minute;
    try {
      return _doses.firstWhere((d) {
        final dMin = d.time.hour * 60 + d.time.minute;
        return dMin > nowMin;
      });
    } catch (_) {
      return null;
    }
  }

  List<Medication> get _medsNeedingRefill =>
      sampleMeds.where((m) => m.needsRefill).toList();

  String _greeting() {
    final h = _now.hour;
    if (h < 12) return 'Good morning!';
    if (h < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _timeUntil(TimeOfDay t) {
    final nowMin = _now.hour * 60 + _now.minute;
    final doseMin = t.hour * 60 + t.minute;
    final diff = doseMin - nowMin;
    if (diff <= 0) return 'now';
    if (diff < 60) return 'in ${diff}m';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? 'in ${h}h' : 'in ${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: _bgDark,
              elevation: 0,
              pinned: true,
              title: Text(
                'WALL-E Meds',
                style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── WALL-E + greeting ────────────────────────────────────
                  _WalleHeader(
                    float: _walleFloat,
                    greeting: _greeting(),
                    now: _now,
                  ),

                  const SizedBox(height: 20),

                  // ── Refill warnings ──────────────────────────────────────
                  if (_medsNeedingRefill.isNotEmpty) ...[
                    _RefillBanner(meds: _medsNeedingRefill),
                    const SizedBox(height: 16),
                  ],

                  // ── Next medication card ─────────────────────────────────
                  _NextMedCard(
                    dose: _nextDose,
                    timeUntil: _nextDose != null
                        ? _timeUntil(_nextDose!.time)
                        : null,
                    formatTime: _formatTime,
                  ),

                  const SizedBox(height: 20),

                  // ── Section header: today's schedule ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's schedule",
                        style: TextStyle(
                          color: _textPrim,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_doses.where((d) => d.taken).length}/${_doses.length} done',
                        style: TextStyle(color: _textSec, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Schedule list ────────────────────────────────────────
                  ..._doses.map((dose) => _DoseTile(
                        dose: dose,
                        formatTime: _formatTime,
                      )),

                  const SizedBox(height: 24),

                  // ── View full schedule button ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScheduleScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text('View full schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: _bgDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom nav ───────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(btService: widget.btService),
    );
  }
}

// ── WALL-E header widget ──────────────────────────────────────────────────────

class _WalleHeader extends StatelessWidget {
  final Animation<double> float;
  final String greeting;
  final DateTime now;

  const _WalleHeader({
    required this.float,
    required this.greeting,
    required this.now,
  });

  String _clockString() {
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentDim.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          // WALL-E illustration (simple widget — swap for Lottie animation)
          AnimatedBuilder(
            animation: float,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, float.value),
              child: child,
            ),
            child: _WalleIcon(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "WALL-E's got your meds covered.",
                  style: TextStyle(color: _textSec, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _accent.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    _clockString(),
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── WALL-E custom painter ─────────────────────────────────────────────────────

class _WalleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _WallePainter(),
      ),
    );
  }
}

class _WallePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Treads ───────────────────────────────────────────────────────────────
    final treadPaint = Paint()..color = const Color(0xFF1A1A1A);
    final treadLeft  = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.68, w * 0.2, h * 0.28), Radius.circular(6));
    final treadRight = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.76, h * 0.68, w * 0.2, h * 0.28), Radius.circular(6));
    canvas.drawRRect(treadLeft,  treadPaint);
    canvas.drawRRect(treadRight, treadPaint);

    // Tread highlights
    final treadHL = Paint()..color = const Color(0xFF333333);
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.06, h * (0.71 + i * 0.06), w * 0.16, h * 0.03),
        treadHL,
      );
      canvas.drawRect(
        Rect.fromLTWH(w * 0.78, h * (0.71 + i * 0.06), w * 0.16, h * 0.03),
        treadHL,
      );
    }

    // ── Body ─────────────────────────────────────────────────────────────────
    final bodyPaint = Paint()..color = const Color(0xFFB8862A);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.52, w * 0.64, h * 0.38), Radius.circular(6));
    canvas.drawRRect(body, bodyPaint);

    // Body shadow/detail line
    final bodyDetail = Paint()
      ..color = const Color(0xFF8A6010)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.56, w * 0.56, h * 0.30), Radius.circular(4)),
      bodyDetail,
    );

    // Solar panel lines on body
    final linePaint = Paint()
      ..color = const Color(0xFF8A6010)
      ..strokeWidth = 1.0;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(w * 0.22, h * (0.56 + i * 0.075)),
        Offset(w * 0.78, h * (0.56 + i * 0.075)),
        linePaint,
      );
    }

    // ── Neck ─────────────────────────────────────────────────────────────────
    final neckPaint = Paint()..color = const Color(0xFF8A6010);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.40, h * 0.34, w * 0.20, h * 0.20),
      neckPaint,
    );
    // Neck highlight
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.36, w * 0.06, h * 0.16),
      Paint()..color = const Color(0xFFD4A030),
    );

    // ── Head ─────────────────────────────────────────────────────────────────
    final headPaint = Paint()..color = const Color(0xFFB8862A);
    final head = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.06, w * 0.76, h * 0.30), Radius.circular(8));
    canvas.drawRRect(head, headPaint);

    // Head rim
    final headRim = Paint()
      ..color = const Color(0xFF8A6010)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.06, w * 0.76, h * 0.30), Radius.circular(8)),
      headRim,
    );

    // ── Eyes (binocular style) ────────────────────────────────────────────────
    _drawEye(canvas, Offset(w * 0.315, h * 0.205), w * 0.14, h);
    _drawEye(canvas, Offset(w * 0.685, h * 0.205), w * 0.14, h);

    // Eye bridge
    final bridgePaint = Paint()..color = const Color(0xFF5A4010);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.175, w * 0.24, h * 0.06),
      bridgePaint,
    );
  }

  void _drawEye(Canvas canvas, Offset center, double radius, double h) {
    // Outer ring (dark casing)
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A1A1A));

    // Inner lens (dark)
    canvas.drawCircle(center, radius * 0.78, Paint()..color = const Color(0xFF0D1A2A));

    // Iris (blue)
    canvas.drawCircle(center, radius * 0.55, Paint()..color = const Color(0xFF2E6DA4));

    // Pupil
    canvas.drawCircle(center, radius * 0.30, Paint()..color = const Color(0xFF0A0A0A));

    // Shine highlight
    canvas.drawCircle(
      center + Offset(-radius * 0.18, -radius * 0.18),
      radius * 0.14,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Refill warning banner ─────────────────────────────────────────────────────

class _RefillBanner extends StatelessWidget {
  final List<Medication> meds;
  const _RefillBanner({required this.meds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _danger.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _danger, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refill needed',
                  style: TextStyle(
                    color: _danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meds.map((m) => '${m.name} (${m.pillsRemaining} left)').join(' · '),
                  style: TextStyle(color: _textSec, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next medication card ──────────────────────────────────────────────────────

class _NextMedCard extends StatelessWidget {
  final ScheduledDose? dose;
  final String? timeUntil;
  final String Function(TimeOfDay) formatTime;

  const _NextMedCard({
    required this.dose,
    required this.timeUntil,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    if (dose == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: _success, size: 28),
            const SizedBox(width: 12),
            Text(
              'All doses taken today!',
              style: TextStyle(
                  color: _success, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      );
    }

    final med = dose!.medication;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: med.color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: med.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication_rounded, color: med.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next dose',
                  style: TextStyle(color: _textSec, fontSize: 11),
                ),
                Text(
                  med.name,
                  style: TextStyle(
                    color: _textPrim,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  med.dosage,
                  style: TextStyle(color: _textSec, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatTime(dose!.time),
                style: TextStyle(
                  color: med.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: med.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeUntil ?? '',
                  style: TextStyle(
                      color: med.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dose tile ─────────────────────────────────────────────────────────────────

class _DoseTile extends StatelessWidget {
  final ScheduledDose dose;
  final String Function(TimeOfDay) formatTime;

  const _DoseTile({required this.dose, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final med = dose.medication;
    return Opacity(
      opacity: dose.taken ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dose.taken
                ? Colors.transparent
                : med.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Color dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dose.taken ? _textSec : med.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      color: _textPrim,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    med.dosage,
                    style: TextStyle(color: _textSec, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              formatTime(dose.time),
              style: TextStyle(
                color: dose.taken ? _textSec : med.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              dose.taken
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: dose.taken ? _success : _textSec,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final BluetoothService btService;
  const _BottomNav({required this.btService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(top: BorderSide(color: _accentDim.withValues(alpha: 0.3))),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: _accent,
        unselectedItemColor: _textSec,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication_rounded), label: 'Meds'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_rounded), label: 'Rewards'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BluetoothScreen(btService: btService),
              ),
            );
          }
        },
      ),
    );
  }
}