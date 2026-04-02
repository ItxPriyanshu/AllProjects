import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AICallScreen extends StatefulWidget {
  const AICallScreen({super.key});

  @override
  State<AICallScreen> createState() => _AICallScreenState();
}

class _AICallScreenState extends State<AICallScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isProcessing = false;
  String _status = "Call Connected";
  String _userMessage = "";
  String _aiResponse = "";

  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSpeech();
  }

  void _initTTS() async {
    try {
      await _tts.setLanguage("en-IN");
      await _tts.setSpeechRate(0.5);
    } catch (e) {
      print("TTS Init Error: $e");
    }
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize();
      if (!available) {
        if (mounted) {
          setState(() => _status = "Microphone not available");
        }
      }
    } catch (e) {
      print("Speech Init Error: $e");
      if (mounted) {
        setState(() => _status = "Error initializing microphone");
      }
    }
  }

  Future<void> _startListening() async {
    if (_isListening || _isProcessing) return;

    try {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() => _userMessage = result.recognizedWords);
          }
          
          if (result.finalResult) {
            _speech.stop();
            if (mounted) {
              setState(() => _isListening = false);
            }
            if (result.recognizedWords.isNotEmpty) {
              _sendToAI(result.recognizedWords);
            } else {
              if (mounted) {
                setState(() {
                  _status = "Could not understand. Please try again.";
                });
              }
            }
          }
        },
      );
    } catch (e) {
      print("Listening Error: $e");
      if (mounted) {
        setState(() {
          _isListening = false;
          _status = "Error starting microphone";
        });
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _sendToAI(String message) async {
    if (message.isEmpty) return;

    try {
      if (mounted) {
        setState(() {
          _isProcessing = true;
          _status = "Processing your query...";
        });
      }

      final response = await http.post(
        Uri.parse("https://team-orbital.onrender.com/home/gemini"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": message}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["reply"] ?? "Unable to get response";

        if (mounted) {
          setState(() {
            _aiResponse = reply;
            _status = "Doctor's Response";
            _isProcessing = false;
          });
        }

        await _tts.speak(reply);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("AI Error: $e");
      if (mounted) {
        setState(() {
          _status = "Error: Could not reach doctor";
          _isProcessing = false;
          _aiResponse = "An error occurred. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1D1F8C);
    const Color darkColor = Color(0xFF080826);

    return Scaffold(
      backgroundColor: darkColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Header
                Text(
                  'AI Doctor',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                    ).fontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Talk to your AI Medical Assistant',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: GoogleFonts.manrope().fontFamily,
                  ),
                ),
                const SizedBox(height: 30),

                // AI Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.15),
                      border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      size: 80,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Display
                Center(
                  child: Column(
                    children: [
                      Text(
                        _status,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _status.contains("Error")
                              ? Colors.red
                              : _isProcessing
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                      if (_isProcessing)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // User Message Display
                if (_userMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You said:',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _userMessage,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // AI Response Display
                if (_aiResponse.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111023),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor says:',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _aiResponse,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),

                // Mic Button
                Center(
                  child: GestureDetector(
                    onTap: _isProcessing ? null : _startListening,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.red.withOpacity(0.3)
                            : _isProcessing
                                ? Colors.grey.withOpacity(0.3)
                                : primaryColor.withOpacity(0.3),
                        border: Border.all(
                          color: _isListening
                              ? Colors.red
                              : _isProcessing
                                  ? Colors.grey
                                  : primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 60,
                        color: _isListening
                            ? Colors.red
                            : _isProcessing
                                ? Colors.grey
                                : primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _isListening
                        ? 'Listening...'
                        : _isProcessing
                            ? 'Processing...'
                            : 'Tap to speak',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // End Call Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'End Call',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}