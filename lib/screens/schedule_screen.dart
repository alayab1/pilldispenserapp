import 'package:flutter/material.dart';
import 'home_screen.dart';

// ── Colours (shared with home screen) ────────────────────────────────────────

const _bgDark   = Color(0xFF1A1610);
const _bgCard   = Color(0xFF2A2318);
const _accent   = Color(0xFFE8A838);
const _accentDim = Color(0xFF7A561A);
const _textPrim = Color(0xFFF5EDD6);
const _textSec  = Color(0xFF9A8E78);
const _success  = Color(0xFF6DBF6A);

// ── Days of week helper ───────────────────────────────────────────────────────

const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// Maps DateTime.weekday (1=Mon … 7=Sun) to our 0-based index
int _todayIndex() => DateTime.now().weekday - 1;

// ── Schedule screen ───────────────────────────────────────────────────────────

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _todayIndex();
  }

  /// Returns doses for the selected day, sorted by time.
  List<ScheduledDose> _dosesForDay(int dayIndex) {
    final doses = <ScheduledDose>[];
    final now = TimeOfDay.now();
    final isToday = dayIndex == _todayIndex();

    for (final med in sampleMeds) {
      // Skip if this medication isn't scheduled on the selected day
      if (!med.scheduledDays.contains(dayIndex)) continue;

      for (final t in med.times) {
        final isPast = isToday &&
            (t.hour < now.hour ||
                (t.hour == now.hour && t.minute <= now.minute));
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

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final doses = _dosesForDay(_selectedDay);
    final taken = doses.where((d) => d.taken).length;

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
          'Full schedule',
          style: TextStyle(
            color: _accent,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: Column(
        children: [

          // ── Day selector ─────────────────────────────────────────────────
          Container(
            color: _bgDark,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final isSelected = i == _selectedDay;
                final isToday = i == _todayIndex();
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _accent
                          : _bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday && !isSelected
                            ? _accentDim
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dayNames[i],
                          style: TextStyle(
                            color: isSelected ? _bgDark : _textSec,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _DayDot(
                          hasDoses: sampleMeds
                              .any((m) => m.scheduledDays.contains(i)),
                          isSelected: isSelected,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Progress bar ─────────────────────────────────────────────────
          if (_selectedDay == _todayIndex() && doses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _ProgressBar(taken: taken, total: doses.length),
            ),

          const SizedBox(height: 8),

          // ── Dose list ────────────────────────────────────────────────────
          Expanded(
            child: doses.isEmpty
                ? _EmptyDay(dayName: _dayNames[_selectedDay])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: doses.length,
                    itemBuilder: (_, i) => _ScheduleTile(
                      dose: doses[i],
                      formatTime: _formatTime,
                      isToday: _selectedDay == _todayIndex(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Small dot showing if a day has doses ─────────────────────────────────────

class _DayDot extends StatelessWidget {
  final bool hasDoses;
  final bool isSelected;
  const _DayDot({required this.hasDoses, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (!hasDoses) return const SizedBox(height: 6);
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _bgDark : _accent,
      ),
    );
  }
}

// ── Today's progress bar ──────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int taken;
  final int total;
  const _ProgressBar({required this.taken, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : taken / total;
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
              Text(
                "Today's progress",
                style: TextStyle(
                  color: _textPrim,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '$taken / $total doses',
                style: TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: _accentDim.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct == 1.0 ? _success : _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule tile ─────────────────────────────────────────────────────────────

class _ScheduleTile extends StatelessWidget {
  final ScheduledDose dose;
  final String Function(TimeOfDay) formatTime;
  final bool isToday;

  const _ScheduleTile({
    required this.dose,
    required this.formatTime,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final med = dose.medication;
    final dimmed = isToday && dose.taken;

    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dimmed ? Colors.transparent : med.color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [

            // Colour icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: med.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.medication_rounded, color: med.color, size: 24),
            ),

            const SizedBox(width: 14),

            // Name + dosage + days scheduled
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      color: _textPrim,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    med.dosage,
                    style: TextStyle(color: _textSec, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  _DayChips(scheduledDays: med.scheduledDays, color: med.color),
                ],
              ),
            ),

            // Time + taken indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(dose.time),
                  style: TextStyle(
                    color: dimmed ? _textSec : med.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  isToday
                      ? (dose.taken
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded)
                      : Icons.schedule_rounded,
                  color: isToday
                      ? (dose.taken ? _success : _textSec)
                      : _textSec,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini day chips showing which days a med is scheduled ─────────────────────

class _DayChips extends StatelessWidget {
  final List<int> scheduledDays;
  final Color color;
  const _DayChips({required this.scheduledDays, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final active = scheduledDays.contains(i);
        return Container(
          margin: const EdgeInsets.only(right: 3),
          width: 22,
          height: 16,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active ? color.withValues(alpha: 0.5) : _textSec.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              _dayNames[i][0],
              style: TextStyle(
                color: active ? color : _textSec.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyDay extends StatelessWidget {
  final String dayName;
  const _EmptyDay({required this.dayName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded, color: _textSec, size: 52),
          const SizedBox(height: 14),
          Text(
            'No doses on $dayName',
            style: TextStyle(
              color: _textPrim,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enjoy your day off!',
            style: TextStyle(color: _textSec, fontSize: 13),
          ),
        ],
      ),
    );
  }
}