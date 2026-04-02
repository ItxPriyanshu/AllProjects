import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/patient/screens/patient_consultation_chat_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Consultation form scaffold: Normal | Emergency with name, email, phone, age, description, prescription upload.
/// [doctorId] is required for backend. [doctorName] and [doctorSpeciality] are for display.
class ConsultationFormPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpeciality;
  /// Consultation fee in INR. If 0 the payment button is hidden.
  final int fee;

  const ConsultationFormPage({
    super.key,
    required this.doctorId,
    this.doctorName = 'Doctor',
    this.doctorSpeciality = 'General',
    this.fee = 0,
  });

  @override
  State<ConsultationFormPage> createState() => _ConsultationFormPageState();
}

class _ConsultationFormPageState extends State<ConsultationFormPage> {
  static const Color primaryColor = Color(0xFF1D1F8C);
  static const Color darkBg = Color(0xFF0F0024);
  static const Color surface = Color(0xFF1A0F32);
  static const Color kEmergency = Color(0xFFFF4C6A);
  static const Color kNormal = Color(0xFF00D4AA);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  bool _isEmergency = false;
  String _gender = 'Male';
  bool _isSubmitting = false;
  bool _isPaymentProcessing = false;
  bool _paymentDone = false;
  String? _orderId; // Razorpay order_id from backend
  String? _pickedFileName;
  List<int>? _pickedFileBytes;

  final ApiService _api = ApiService();
  late final Razorpay _razorpay;
  Map<String, dynamic>? _patientProfile;
  int _walletBalance = 0;
  bool _walletLoading = true;

  // Your Razorpay Key ID (publishable — safe in client code).
  // Must match the RAZORPAY_KEY_ID set on your server (Render env vars).
  // Get it from https://dashboard.razorpay.com → Settings → API Keys
  static const String _razorpayKeyId = 'rzp_test_SIHjzOo44uZZjs'; // ← paste your key here

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPatientProfile();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// Get the effective fee (2x for emergency, normal for non-emergency)
  int _getEffectiveFee() {
    if (widget.fee == 0) return 0;
    return _isEmergency ? widget.fee * 2 : widget.fee;
  }

  Future<void> _loadPatientProfile() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return;
      final res = await _api.get('/patient/profile', token: token);
      final p = res['fullPatientInfo'] as Map<String, dynamic>?;
      if (p != null) {
        if (mounted) setState(() {
          _patientProfile = p;
          _walletBalance = (p['balance'] ?? 0) as int;
          _walletLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _walletLoading = false);
    }
  }

  Future<void> _payWithWallet() async {
    if (_patientProfile == null) return;
    try {
      final token = await TokenStorage.getToken();
      final res = await _api.post('/payment/pay-with-wallet', {'patientId': _patientProfile!['_id'], 'fee': widget.fee}, token: token);
      if (res['success'] == true) {
        final newBal = res['balance'] as int? ?? _walletBalance - widget.fee;
        if (mounted) setState(() {
          _walletBalance = newBal;
          _paymentDone = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paid using wallet')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Wallet payment failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallet payment error: $e')));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    // Verify payment on backend
    try {
      final verifyRes = await _api.post(
        '/payment/verify',
        {
          'rzO_ID': _orderId ?? '',
          'rzP_ID': response.paymentId ?? '',
          'rzSign': response.signature ?? '',
        },
      );
      final success = verifyRes['success'] == true;
      if (mounted) {
        setState(() => _paymentDone = success);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Payment verified! ID: ${response.paymentId}'
                : 'Payment verification failed — contact support'),
            backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _paymentDone = true); // mark done even if verify call fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment received (ID: ${response.paymentId}), but verification failed: $e'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  Future<void> _initiatePayment() async {
    if (_isPaymentProcessing) return;
    if (_razorpayKeyId.contains('XXXX')) {
      _showError('Paste your Razorpay Key ID into _razorpayKeyId in consultation_form_page.dart');
      return;
    }
    if (mounted) setState(() => _isPaymentProcessing = true);
    try {
      // Step 1: Create order on backend
      final effectiveFee = _getEffectiveFee();
      final orderRes = await _api.post('/payment', {'fees': effectiveFee});
      if (orderRes['success'] != true) {
        _showError(orderRes['error']?.toString() ?? 'Could not create payment order. Try again.');
        return;
      }
      final order = orderRes['order'] as Map<String, dynamic>?;
      final orderId = order?['id'] as String?;
      if (orderId == null || orderId.isEmpty) {
        // Show raw response for debugging
        _showError('No order ID from server. Raw: ${orderRes.toString()}');
        return;
      }
      _orderId = orderId;

      // Step 2: Open Razorpay checkout
      final options = <String, dynamic>{
        'key': _razorpayKeyId,
        'order_id': orderId,
        'name': 'BitByBit Health',
        'description': 'Consultation with ${widget.doctorName} (${widget.doctorSpeciality})',
        'currency': 'INR',
        'prefill': {
          'contact': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        },
        'theme': {'color': '#1D1F8C'},
      };
      _razorpay.open(options);
    } catch (e) {
      _showError('Payment error: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      if (mounted) setState(() => _isPaymentProcessing = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.bytes == null) return;
    setState(() {
      _pickedFileName = file.name;
      _pickedFileBytes = file.bytes;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        _showError('Please log in again.');
        setState(() => _isSubmitting = false);
        return;
      }

      final fields = <String, String>{
        'full_name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'contactNo': _phoneCtrl.text.trim(),
        'age': _ageCtrl.text.trim(),
        'gender': _gender,
        'Problem': _descriptionCtrl.text.trim(),
        'life_style': '',
        'type': _isEmergency ? 'emergency' : 'normal',
      };

      final res = await _api.postForm(
        '/patient/form/${widget.doctorId}',
        fields,
        token: token,
        fileBytes: _pickedFileBytes,
        fileName: _pickedFileName ?? 'prescription',
        fileFieldName: 'patientForm',
      );

      final consultation = res['consultation'] as Map<String, dynamic>?;
      final consultId = consultation?['_id'] as String?;
      if (consultId == null) {
        _showError('Invalid response from server.');
        setState(() => _isSubmitting = false);
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PatientConsultationChatScreen(
            consultationId: consultId,
            doctorName: widget.doctorName,
            doctorSpeciality: widget.doctorSpeciality,
            isEmergency: _isEmergency,
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Consultation Form',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor info chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctorName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              widget.doctorSpeciality,
                              style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Normal / Emergency toggle
                Text(
                  'Type',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'Normal',
                        icon: Icons.healing_rounded,
                        isSelected: !_isEmergency,
                        color: kNormal,
                        onTap: () => setState(() => _isEmergency = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeChip(
                        label: 'Emergency',
                        icon: Icons.emergency_rounded,
                        isSelected: _isEmergency,
                        color: kEmergency,
                        enabled: widget.fee > 0,
                        onTap: () {
                          if (widget.fee == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Emergency option is disabled for doctors offering free consultations')),
                            );
                            return;
                          }
                          setState(() => _isEmergency = true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _nameCtrl,
                  label: 'Full Name *',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailCtrl,
                  label: 'Email ${_isEmergency ? "(optional)" : "*"}',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !_isEmergency && (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneCtrl,
                  label: 'Phone ${_isEmergency ? "(optional)" : "*"}',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => !_isEmergency && (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageCtrl,
                  label: 'Age *',
                  hint: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Gender dropdown
                Text(
                  'Gender *',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _gender,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A0F32),
                      style: GoogleFonts.manrope(color: Colors.white),
                      items: ['Male', 'Female', 'Other']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v ?? _gender),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _descriptionCtrl,
                  label: 'Description / Problem ${_isEmergency ? "(optional)" : "*"}',
                  hint: 'Describe your condition or problem',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) => !_isEmergency && (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Prescription upload
                Text(
                  'Previous prescription (optional)',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _pickFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _pickedFileName ?? 'Upload file (PDF, image, doc)',
                    style: GoogleFonts.manrope(fontSize: 14),
                  ),
                ),
                if (_pickedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Selected: $_pickedFileName',
                      style: GoogleFonts.manrope(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 32),

                // Proceed to Payment button (only shown for paid consultations)
                if (widget.fee > 0) ...
                  [
                    // Wallet summary and wallet-pay option
                    if (!_walletLoading) Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Wallet Balance', style: GoogleFonts.manrope(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Text('₹$_walletBalance', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            ]),
                            if (_walletBalance >= widget.fee && !_paymentDone)
                              ElevatedButton(
                                onPressed: _payWithWallet,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D1F8C)),
                                child: Text('Pay with Wallet', style: GoogleFonts.manrope(color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // Disabled once payment is done
                        onPressed: (_isSubmitting || _isPaymentProcessing || _paymentDone) ? null : _initiatePayment,
                        icon: _paymentDone
                            ? const Icon(Icons.check_circle, color: Colors.white)
                            : const Icon(Icons.payment_rounded, color: Colors.white),
                        label: _isPaymentProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _paymentDone ? 'Payment Done ✓' : 'Proceed to Payment  ₹${_getEffectiveFee()} ${_isEmergency ? "(2x Normal)" : ""}',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _paymentDone ? Colors.green.shade700 : const Color(0xFF2BB673),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // For paid consultations, require payment first
                    onPressed: (_isSubmitting || (widget.fee > 0 && !_paymentDone)) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Submit & Go to Chat',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            prefixIcon: Icon(icon, color: Colors.white54, size: 22),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = !enabled
        ? Colors.white10
        : (isSelected ? color.withOpacity(0.2) : const Color(0xFF1A0F32));
    final borderColor = !enabled ? Colors.white10 : (isSelected ? color : Colors.white12);
    final iconColor = !enabled ? Colors.white30 : (isSelected ? color : Colors.white54);
    final textColor = !enabled ? Colors.white30 : (isSelected ? color : Colors.white70);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
