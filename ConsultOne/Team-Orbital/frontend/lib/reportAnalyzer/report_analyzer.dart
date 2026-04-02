import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportAnalyzer extends StatefulWidget {
  const ReportAnalyzer({super.key});

  @override
  State<ReportAnalyzer> createState() => _ReportAnalyzerState();
}

class _Msg {
  final bool isBot;
  final String text;
  _Msg({required this.isBot, required this.text});
}

class _ReportAnalyzerState extends State<ReportAnalyzer> {
  final ScrollController _scroll = ScrollController();
  final Dio _dio = Dio();
  bool _loading = false;

  final List<_Msg> _messages = [
    _Msg(
      isBot: true,
      text:
          'Upload your medical report 📄\n\nSupported formats:\n• Image (JPG, PNG)\n• PDF\n\nI will systematically organize the clinical information from your report.',
    ),
  ];

  Future<void> _pickAndUpload() async {
    if (_loading) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final filePath = file.path!;
    final fileName = file.name;

    setState(() {
      _messages.add(_Msg(isBot: false, text: '📎 $fileName'));
      _messages.add(_Msg(isBot: true, text: 'Analyzing report...'));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final formData = FormData.fromMap({
        'report': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
        'https://team-orbital.onrender.com/home/analyze-Report',
        data: formData,
      );
      final resultText =
          (res.data['result'] as String?) ?? 'No response received.';
      // Replace the "Analyzing..." placeholder with real result
      setState(() {
        _messages.removeLast();
        _messages.add(_Msg(isBot: true, text: resultText));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(
            _Msg(isBot: true, text: 'Server error. Please try again.'));
      });
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
            child: const Center(
                child: Text('📋', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Medical Report Analyzer',
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            Text('Report Analyzer',
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
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _bubble(_messages[i]),
          ),
        ),
        _uploadButton(),
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

  Widget _uploadButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _pickAndUpload,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('🗒️', style: TextStyle(fontSize: 18)),
          label: Text(
            _loading ? 'Analyzing...' : 'Select Report',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600, fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[100],
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
