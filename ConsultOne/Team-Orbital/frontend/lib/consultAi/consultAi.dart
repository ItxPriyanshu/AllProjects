import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsultAi extends StatefulWidget {
  const ConsultAi({super.key});

  @override
  State<ConsultAi> createState() => _ConsultAiState();
}

// Simple message model
class _Msg {
  final bool isBot;
  final String text;
  _Msg({required this.isBot, required this.text});
}

class _ConsultAiState extends State<ConsultAi> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Dio _dio = Dio();
  bool _loading = false;

  final List<_Msg> _messages = [
    _Msg(
      isBot: true,
      text:
          'Hello! 👋 I\'m your Health Assistant.\n\nI can help you with:\n• Symptoms guidance\n• Medicine information\n• General health advice\n• When to consult a doctor\n\nHow can I assist you today?',
    ),
  ];

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(_Msg(isBot: false, text: text));
      _loading = true;
    });
    _input.clear();
    _scrollToBottom();

    try {
      final res = await _dio.post(
        'https://team-orbital.onrender.com/home/gemini',
        data: {'prompt': text},
        options: Options(contentType: Headers.jsonContentType),
      );
      final reply = (res.data['reply'] as String?) ?? 'No response received.';
      setState(() => _messages.add(_Msg(isBot: true, text: reply)));
    } catch (_) {
      setState(() =>
          _messages.add(_Msg(isBot: true, text: 'Server error. Please try again.')));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.blue[400],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Center(child: Text('👨\u200d⚕️', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ConsultAI',
                style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            Text('Active',
                style: GoogleFonts.manrope(
                    fontSize: 11, color: Colors.green[600])),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _messages.length) return _typingBubble();
              return _bubble(_messages[i]);
            },
          ),
        ),
        _inputBar(),
      ]),
    );
  }

  Widget _bubble(_Msg m) {
    return Align(
      alignment: m.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: m.isBot ? Colors.blue[50] : Colors.blue[400],
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .07),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(m.text,
            style: GoogleFonts.manrope(
                fontSize: 14,
                color: m.isBot ? Colors.grey[800] : Colors.white,
                height: 1.5)),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14)),
        child: Text('Typing...',
            style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _input,
            onSubmitted: (_) => _send(),
            textInputAction: TextInputAction.send,
            style: GoogleFonts.manrope(fontSize: 14, color: Colors.black87),
            cursorColor: Colors.black87,
            decoration: InputDecoration(
              hintText: 'Ask health related question...',
              hintStyle:
                  GoogleFonts.manrope(fontSize: 14, color: Colors.grey[400]),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.send_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}