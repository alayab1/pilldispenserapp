import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart' show Medication;

// ── Message model ──────────────────────────────────────────────────────────
class _Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  bool isLoading;

  _Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });
}

// ── Main screen ────────────────────────────────────────────────────────────
class ChatbotScreen extends StatefulWidget {
  final List<Medication> medications;
  final int userAge;

  const ChatbotScreen({
    super.key,
    this.medications = const [],
    this.userAge = 30,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  static const _bgDark   = Color(0xFF2B2B2B);
  static const _bgCard   = Color(0xFF383838);
  static const _amber    = Color(0xFFE8A838);
  static const _amberDim = Color(0xFFB8822A);
  static const _eveBlue  = Color(0xFF78D4F0);
  static const _textDim  = Color(0xFF9A9A9A);

  // !! PASTE YOUR OPENAI KEY HERE !!
  static const _openAiKey = 'YOUR_OPENAI_KEY';

  final _controller    = TextEditingController();
  final _scrollCtrl    = ScrollController();
  final _focusNode     = FocusNode();
  final List<_Message> _messages = [];
  bool _sending = false;

  late final AnimationController _eyeCtrl;
  late final AnimationController _bobCtrl;
  late final Animation<double>   _eyeAnim;
  late final Animation<double>   _bobAnim;

  final List<String> _suggestions = [
    'What are my medications for?',
    'Can I take these together?',
    'What are common side effects?',
    'What happens if I miss a dose?',
    'Can I drink alcohol with my meds?',
    'Any foods I should avoid?',
  ];

  @override
  void initState() {
    super.initState();

    _eyeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _eyeAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _eyeCtrl, curve: Curves.easeInOut),
    );
    _bobAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut),
    );

    _messages.add(_Message(
      text:
          "Heyyyy! I'm EVE 🤖 — your WALL-E med assistant! Ask me anything about your medications, side effects, interactions, or just how to stay on track. I'm here to help! 💊",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _eyeCtrl.dispose();
    _bobCtrl.dispose();
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _buildMedContext() {
    if (widget.medications.isEmpty) {
      return 'The user has not added any medications yet.';
    }
    final buffer = StringBuffer('The user takes the following medications:\n');
    for (final m in widget.medications) {
      buffer.write('- ${m.name} (${m.dosage})');
      if (m.purpose.isNotEmpty) buffer.write(': ${m.purpose}');
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _controller.clear();
    _focusNode.unfocus();

    final userMsg = _Message(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    final loadingMsg = _Message(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(loadingMsg);
      _sending = true;
    });
    _scrollToBottom();

    final history = _messages
        .where((m) => !m.isLoading)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final systemPrompt = '''
You are EVE, a friendly and knowledgeable medication assistant in a WALL-E themed pill dispenser app called WALL-E Meds. You speak warmly and occasionally use a space/robot metaphor, but always stay medically accurate and helpful. You are NOT a substitute for a doctor.

${_buildMedContext()}

The user is ${widget.userAge} years old.

Guidelines:
- Answer questions about medications clearly and helpfully.
- Always recommend consulting a doctor or pharmacist for serious concerns.
- Flag overdose risks with a ⚠️ emoji and clear language.
- Keep responses concise (2-4 sentences usually) unless detail is needed.
- Do not diagnose conditions or prescribe medications.
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'max_tokens': 1000,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...history,
          ],
        }),
      );

      final data = jsonDecode(response.body);
      final reply = data['choices'][0]['message']['content'] as String;

      setState(() {
        _messages.remove(loadingMsg);
        _messages.add(_Message(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _sending = false;
      });
    } catch (e) {
      setState(() {
        _messages.remove(loadingMsg);
        _messages.add(_Message(
          text: 'Oops! My circuits got a little tangled 🔧 Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _sending = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMessageList(),
            if (_messages.length <= 1) _buildSuggestions(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(
          bottom: BorderSide(color: _amber.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _amber, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          AnimatedBuilder(
            animation: _bobCtrl,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _bobAnim.value * 0.5),
              child: child,
            ),
            child: AnimatedBuilder(
              animation: _eyeCtrl,
              builder: (context, _) => CustomPaint(
                size: const Size(44, 44),
                painter: _EveMiniPainter(glowIntensity: _eyeAnim.value),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EVE — Med Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                Text('Ask me anything about your meds',
                    style: TextStyle(color: _textDim, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Online',
                    style: TextStyle(color: Colors.green, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _messages.length,
        itemBuilder: (context, i) => _buildMessageBubble(_messages[i]),
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg) {
    if (msg.isLoading) return _buildLoadingBubble();
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _eveBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: _eveBlue.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.smart_toy, color: _eveBlue, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _amber.withValues(alpha: 0.15) : _bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? _amber.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser ? _amber : Colors.white.withValues(alpha: 0.92),
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _eveBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _eveBlue.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.smart_toy, color: _eveBlue, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: _ThinkingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        // fixed: was (_, _) which is a compile error — must be (_, __)
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _sendMessage(_suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _amberDim.withValues(alpha: 0.5)),
            ),
            child: Text(_suggestions[i],
                style: const TextStyle(color: _amber, fontSize: 12.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(
            top: BorderSide(color: _amber.withValues(alpha: 0.15), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              cursorColor: _amber,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask about your medications…',
                hintStyle: TextStyle(color: _textDim, fontSize: 14),
                filled: true,
                fillColor: _bgDark,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: _amber.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: _amber.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: _amber, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _sending ? _amberDim.withValues(alpha: 0.4) : _amber,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _sending
                    ? Icons.hourglass_top_rounded
                    : Icons.send_rounded,
                color: _sending ? _textDim : Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thinking dots ─────────────────────────────────────────────────────────
class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value - i * 0.18).clamp(0.0, 1.0);
            final scale =
                0.6 + 0.4 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF78D4F0).withValues(alpha: scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── EVE mini painter ──────────────────────────────────────────────────────
class _EveMiniPainter extends CustomPainter {
  final double glowIntensity;
  const _EveMiniPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 4), width: 34, height: 42),
        Paint()
          ..color = const Color(0xFFEEEEEE)
          ..style = PaintingStyle.fill);

    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 4), width: 34, height: 42),
        Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - 1), width: 30, height: 14),
        Paint()
          ..color =
              const Color(0xFF78D4F0).withValues(alpha: 0.3 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 1), width: 28, height: 11),
        const Radius.circular(5.5),
      ),
      Paint()
        ..color = const Color(0xFF111111)
        ..style = PaintingStyle.fill,
    );

    _drawEye(canvas, Offset(cx - 7, cy - 1), glowIntensity);
    _drawEye(canvas, Offset(cx + 7, cy - 1), glowIntensity);

    canvas.drawCircle(
      Offset(cx, cy + 10),
      3.5,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF78D4F0).withValues(alpha: 0.6),
          const Color(0xFF78D4F0),
          glowIntensity,
        )!
        ..style = PaintingStyle.fill,
    );
  }

  void _drawEye(Canvas canvas, Offset center, double glow) {
    canvas.drawCircle(center, 4,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF4ABCDE),
            const Color(0xFF78D4F0),
            glow,
          )!);
    canvas.drawCircle(
        center, 1.8, Paint()..color = const Color(0xFF0A1520));
    canvas.drawCircle(center.translate(-1, -1.2), 0.9,
        Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(_EveMiniPainter old) =>
      old.glowIntensity != glowIntensity;
}