import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/services.dart';

const Color _primaryColor = Color(0xFF1D1F8C);
const Color _darkColor = Color(0xFF080826);
const Color _cardColor = Color(0xFF1A0F2E);

class PatientProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated; // callback to refresh parent
  const PatientProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;
  late final Razorpay _razorpay;
  String? _currentOrderId;
  static const String _razorpayKeyId = 'rzp_test_SIHjzOo44uZZjs';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadProfile();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      if (_currentOrderId == null) return;
      // Verify and credit wallet
      final verifyRes = await _api.post('/payment/verify', {
        'rzO_ID': _currentOrderId ?? '',
        'rzP_ID': response.paymentId ?? '',
        'rzSign': response.signature ?? '',
        'patientId': _profile?['_id'],
        'amount': int.tryParse(_topUpAmount?.toString() ?? '0') ?? 0,
      });
      if (verifyRes['success'] == true) {
        // refresh profile to reflect new balance
        await _loadProfile();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet credited successfully')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment verified but credit failed')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Top-up verify failed: $e')));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment error: ${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External wallet chosen: ${response.walletName}')));
  }

  int? _topUpAmount;

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) throw Exception('Not authenticated');
      final res = await _api.get('/patient/profile', token: token);
      final p = res['fullPatientInfo'] as Map<String, dynamic>?;
      if (p == null) throw Exception('Profile not found');
      if (mounted) setState(() => _profile = p);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startTopUp() async {
    // Ask user for amount
    final amountCtrl = TextEditingController();
    var submitting = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: Text('Add Money to Wallet', style: GoogleFonts.poppins(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.manrope(color: Colors.white),
                decoration: InputDecoration(hintText: 'Amount (INR)', hintStyle: GoogleFonts.manrope(color: Colors.white38)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: submitting ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.manrope(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              onPressed: submitting
                  ? null
                  : () async {
                      final amtStr = amountCtrl.text.trim();
                      final amt = int.tryParse(amtStr);
                      if (amt == null || amt <= 0) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                        return;
                      }
                      setS(() => submitting = true);
                      Navigator.pop(ctx);
                      await _createAndOpenOrder(amt);
                    },
              child: submitting ? const CircularProgressIndicator() : Text('Proceed', style: GoogleFonts.manrope(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _createAndOpenOrder(int amount) async {
    try {
      final token = await TokenStorage.getToken();
      final orderRes = await _api.post('/payment', {'fees': amount}, token: token);
      if (orderRes['success'] != true) throw Exception('Order creation failed');
      final order = orderRes['order'] as Map<String, dynamic>?;
      final orderId = order?['id'] as String?;
      if (orderId == null) throw Exception('No order id');
      _currentOrderId = orderId;
      _topUpAmount = amount;
      final options = {
        'key': _razorpayKeyId,
        'order_id': orderId,
        'name': 'BitByBit Health',
        'description': 'Wallet Top-up',
        'currency': 'INR',
        'prefill': {'contact': _profile?['phoneNo'] ?? '', 'email': _profile?['email'] ?? ''},
        'theme': {'color': '#1D1F8C'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Top-up failed: $e')));
    }
  }

  Future<void> _updateProfile(String name, String email, String phoneNo) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) throw Exception('Not authenticated');

      final payload = {
        "name": name,
        "email": email,
        "phoneNo": phoneNo
      };

      final res = await _api.post('/patient/edit', payload, token: token);
      
      if (res['patient'] != null) {
        if (mounted) {
          setState(() {
            _profile = res['patient'] as Map<String, dynamic>;
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
    final emailCtrl = TextEditingController(text: _profile?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile?['phoneNo'] ?? '');

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
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.manrope(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.manrope(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Phone No.',
                        labelStyle: GoogleFonts.manrope(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primaryColor)),
                      ),
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
                            emailCtrl.text.trim(),
                            phoneCtrl.text.trim(),
                          );
                          if (mounted && Navigator.canPop(ctx)) {
                            Navigator.pop(ctx);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
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
        title: Text('My Profile', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_primaryColor, _darkColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(radius: 45, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50, color: Colors.white)),
                            const SizedBox(height: 14),
                            Text(_profile?['name'] ?? 'Patient', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(_profile?['role'] ?? 'Patient', style: GoogleFonts.manrope(fontSize: 15, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        title: 'Contact Information',
                        children: [
                          ProfileTile(icon: Icons.email_outlined, title: 'Email', value: _profile?['email'] ?? ''),
                          const SizedBox(height: 12),
                          ProfileTile(icon: Icons.phone, title: 'Phone', value: _profile?['phoneNo'] ?? ''),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        title: 'Account',
                        children: [
                          ProfileTile(icon: Icons.calendar_today, title: 'Joined', value: _formatDate(_profile?['createdAt'])),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        title: 'Wallet',
                        children: [
                          ProfileTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Balance',
                            value: (_profile?['balance'] ?? 0).toString(),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startTopUp,
                              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                              child: Text('Add Money to Wallet', style: GoogleFonts.manrope(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    try {
      final dt = DateTime.parse(d.toString());
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return d.toString();
    }
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
        const SizedBox(height: 14),
        ...children,
      ]),
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
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: _primaryColor, size: 20)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.manrope(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
      ])
    ]);
  }
}
