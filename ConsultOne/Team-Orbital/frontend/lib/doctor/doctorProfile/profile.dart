import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';

const Color _primaryColor = Color(0xFF1D1F8C);
const Color _darkColor = Color(0xFF080826);
const Color _cardColor = Color(0xFF1A0F2E);

class DoctorProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated; 
  const DoctorProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) throw Exception('Not authenticated');
      
      final res = await _api.get('/doctor/profile', token: token);
      final p = res['doctor'] as Map<String, dynamic>?;
      if (p == null) throw Exception('Profile not found');
      
      if (mounted) setState(() => _profile = p);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile(String name, String phone, String availTime, String feesText, String speciality) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) throw Exception('Not authenticated');

      int fees = int.tryParse(feesText) ?? 0;

      final payload = {
        "name": name,
        "phone": phone,
        "availTime": availTime,
        "fees": fees,
        "speciality": speciality
      };

      final res = await _api.post('/doctor/edit', payload, token: token);
      
      if (res['doctor'] != null) {
        if (mounted) {
          setState(() {
            _profile = res['doctor'] as Map<String, dynamic>;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
          );
          if (widget.onProfileUpdated != null) {
            widget.onProfileUpdated!();
          }
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: _profile?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile?['phone'] ?? '');
    final tempFees = _profile?['fees']?.toString() ?? '0';
    final feesCtrl = TextEditingController(text: tempFees);
    final availCtrl = TextEditingController(text: _profile?['availTime'] ?? '');
    final specCtrl = TextEditingController(text: _profile?['speciality'] ?? '');

    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(labelText: 'Name', labelStyle: GoogleFonts.manrope(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor))),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(labelText: 'Phone', labelStyle: GoogleFonts.manrope(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor))),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: specCtrl,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(labelText: 'Speciality', labelStyle: GoogleFonts.manrope(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor))),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: availCtrl,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(labelText: 'Availability Time', labelStyle: GoogleFonts.manrope(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor))),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feesCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(labelText: 'Fees (₹)', labelStyle: GoogleFonts.manrope(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor))),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.manrope(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          await _updateProfile(
                            nameCtrl.text.trim(),
                            phoneCtrl.text.trim(),
                            availCtrl.text.trim(),
                            feesCtrl.text.trim(),
                            specCtrl.text.trim(),
                          );
                          if (mounted && Navigator.canPop(ctx)) {
                            Navigator.pop(ctx);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : Text('Save', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0024),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_loading && _profile != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _showEditDialog,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.manrope(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      /// 🔷 PROFILE HEADER CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_primaryColor, _darkColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(radius: 45, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50, color: Colors.white)),
                            const SizedBox(height: 14),
                            Text(
                              _profile?['name'] ?? 'Doctor',
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _profile?['speciality'] ?? 'Specialist',
                              style: GoogleFonts.manrope(fontSize: 15, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🔷 PERSONAL INFO CARD
                      _buildInfoCard(
                        title: "Contact Information",
                        children: [
                          ProfileTile(icon: Icons.email_outlined, title: "Email", value: _profile?['email'] ?? "N/A"),
                          const SizedBox(height: 12),
                          ProfileTile(icon: Icons.phone_outlined, title: "Phone", value: _profile?['phone'] ?? "N/A"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// 🔷 PROFESSIONAL INFO CARD
                      _buildInfoCard(
                        title: "Professional Details",
                        children: [
                          ProfileTile(icon: Icons.badge_outlined, title: "Licence ID", value: _profile?['licenceId'] ?? "N/A"),
                          const SizedBox(height: 12),
                          ProfileTile(icon: Icons.access_time_outlined, title: "Sitting Time", value: _profile?['availTime'] ?? "N/A"),
                          const SizedBox(height: 12),
                          ProfileTile(icon: Icons.currency_rupee, title: "Consultation Fees", value: "₹${_profile?['fees'] ?? 0}"),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileTile({super.key, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _primaryColor, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.manrope(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        )
      ],
    );
  }
}
