import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app_route_observer.dart';
import 'package:frontend/health_news/health_news_provider.dart';
import 'package:frontend/reportAnalyzer/report_analyzer_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/start_page.dart';
import 'package:frontend/patient/services/soctype-symptom.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/patient/screens/consultation_form_page.dart';
import 'package:frontend/patient/screens/patientHistory.dart';
import 'package:frontend/patient/screens/bmi_calculator.dart';
import 'package:frontend/patient/screens/ai_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:frontend/consultAi/consultAi_page.dart';
import 'package:frontend/patient/profile/patient_profile.dart';
import 'package:frontend/patient/help/help_support.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:frontend/patient/providers/auth_provider.dart';

class PatientHome extends ConsumerStatefulWidget {
  @override
  ConsumerState<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends ConsumerState<PatientHome>
    with RouteAware, WidgetsBindingObserver {
  static const Color primaryColor = Color(0xFF1D1F8C);
  static const Color darkColor = Color(0xFF080826);
  final TextEditingController _searchCtrl = TextEditingController();
  // Symptom selection state (from soctype-symptom)
  List<String> _allSymptoms = [];
  List<String> _filteredSymptoms = [];
  final Set<String> _selectedSymptoms = {};
  Map<String, String> _symptomToSpeciality = {};

  // Doctors list: loaded from API
  List<Map<String, dynamic>> _doctors = [];
  int _doctorTabIndex = 0;
  bool _doctorsLoading = false;

  // Notifications
  List<Map<String, dynamic>> _notifications = [];
  Timer? _notificationCheckTimer;
  Timer? _notificationDismissTimer;

  final ApiService _api = ApiService();

  /// Fetches doctors for the given list of specialities (deduped by _id).
  Future<void> _loadDoctorsBySpecialities(List<String> specialities) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;
    if (mounted) setState(() => _doctorsLoading = true);
    try {
      final allDocs = <Map<String, dynamic>>[];
      final seenIds = <String>{};
      for (final spec in specialities) {
        try {
          final encoded = Uri.encodeComponent(spec);
          final res = await _api.get('/patient/$encoded', token: token);
          final list = res['Doclist'] as List<dynamic>?;
          if (list != null) {
            for (final d in list) {
              final m = Map<String, dynamic>.from(d as Map);
              final id = (m['_id'] ?? '').toString();
              if (seenIds.add(id)) {
                allDocs.add({
                  'id': id,
                  'name': m['name'] ?? 'Doctor',
                  'speciality': m['speciality'] ?? 'General',
                  'fee': m['fees'] ?? 0,
                  'regId': m['licenceId'] ?? '',
                  'availTime': m['availTime'] ?? '',
                });
              }
            }
          }
        } catch (_) {
          // skip failed speciality
        }
      }
      if (mounted) setState(() => _doctors = allDocs);
    } catch (_) {
      // keep existing list
    } finally {
      if (mounted) setState(() => _doctorsLoading = false);
    }
  }

  /// Returns true if current time is within the doctor's availTime range.
  /// availTime format from DB: "9:00 AM - 5:00 PM" or "09:00 - 17:00".
  bool _isDoctorAvailable(String availTime) {
    if (availTime.isEmpty) return true;
    try {
      final parts = availTime.split(' - ');
      if (parts.length != 2) return true;
      final start = _parseTime(parts[0].trim());
      final end = _parseTime(parts[1].trim());
      if (start == null || end == null) return true;
      final now = DateTime.now();
      final nowMins = now.hour * 60 + now.minute;
      if (start <= end) {
        return nowMins >= start && nowMins <= end;
      }
      return nowMins >= start || nowMins <= end;
    } catch (_) {
      return true;
    }
  }

  int? _parseTime(String s) {
    final m24 = RegExp(r'^(\d{1,2}):(\d{2})$');
    final m12 = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false);
    var m = m12.firstMatch(s);
    if (m != null) {
      var h = int.parse(m.group(1)!);
      final mins = int.parse(m.group(2)!);
      final ampm = (m.group(3) ?? '').toUpperCase();
      if (ampm == 'PM' && h != 12) h += 12;
      if (ampm == 'AM' && h == 12) h = 0;
      return h * 60 + mins;
    }
    m = m24.firstMatch(s);
    if (m != null) {
      final h = int.parse(m.group(1)!);
      final mins = int.parse(m.group(2)!);
      return h * 60 + mins;
    }
    return null;
  }

  Future<void> _fetchNotifications() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      print("No token available");
      return;
    }
    try {
      print("Fetching notifications...");
      final res = await _api.get('/patient/notifications', token: token);
      print("Notification response: $res");
      
      // Try different response structures
      List<dynamic> notifList = [];
      
      if (res is Map) {
        // Try 'notifications' key first
        if (res.containsKey('notifications')) {
          notifList = res['notifications'] as List<dynamic>? ?? [];
        }
        // Try direct response as list
        else if (res.containsKey('data')) {
          notifList = res['data'] as List<dynamic>? ?? [];
        }
        // Try other common keys
        else if (res.containsKey('alert') || res.containsKey('alerts')) {
          notifList = res['alert'] ?? res['alerts'] ?? [];
        }
      }
      
      print("Notifications list: $notifList");
      final newNotifications = <Map<String, dynamic>>[];
      
      final readIds = await TokenStorage.getReadNotificationIds();

      for (final notif in notifList) {
        final m = Map<String, dynamic>.from(notif as Map);
        final String notifId = m['_id']?.toString() ?? m['id']?.toString() ?? '';
        
        newNotifications.add({
          'id': notifId,
          'title': m['title'] ?? m['subject'] ?? 'Admin Notification',
          'message': m['message'] ?? m['content'] ?? m['body'] ?? '',
          'type': m['type'] ?? 'alert',
          'createdAt': m['createdAt'] ?? m['createddate'] ?? '',
          'read': readIds.contains(notifId),
        });
      }
      
      print("Processed notifications: $newNotifications");
      
      if (mounted) {
        setState(() => _notifications = newNotifications);
        
        // Show popup for unread notifications
        if (newNotifications.isNotEmpty) {
          final unread = newNotifications.where((n) => n['read'] == false).toList();
          if (unread.isNotEmpty) {
            final firstUnread = unread.first;
            
            // Note: marking as read so we don't show it again across polls/restarts
            final String firstId = firstUnread['id'] as String;
            if (firstId.isNotEmpty) {
              readIds.add(firstId);
              await TokenStorage.saveReadNotificationIds(readIds);
              
              // update local state to avoid immediate re-trigger during setState
              setState(() {
                final idx = _notifications.indexWhere((n) => n['id'] == firstId);
                if (idx != -1) {
                  _notifications[idx]['read'] = true;
                }
              });
            }
            
            _showNotificationPopup(firstUnread);
          }
        }
      }
    } catch (e) {
      print("Fetch notifications error: $e");
      print("Error details: ${e.toString()}");
    }
  }

  void _showNotificationPopup(Map<String, dynamic> notification) {
    _notificationDismissTimer?.cancel();
    
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Notification',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    _notificationDismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void _refreshData() {
    ref.invalidate(newsProvider);
    try {
      final dt = doctypesymptom();
      final specs = _selectedSymptoms.isEmpty
          ? dt.symptoms.keys.toList()
          : _selectedSymptoms
              .map((s) => _symptomToSpeciality[s] ?? '')
              .where((sp) => sp.isNotEmpty)
              .toSet()
              .toList();
      _loadDoctorsBySpecialities(specs);
    } catch (_) {}
    _fetchNotifications();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      final dt = doctypesymptom();
      final merged = <String>{};
      final specMap = <String, String>{};
      for (final e in dt.symptoms.entries) {
        for (final s in e.value) {
          if (!merged.contains(s)) {
            merged.add(s);
            specMap[s] = e.key;
          }
        }
      }
      _allSymptoms = merged.toList()..sort();
      _filteredSymptoms = List.from(_allSymptoms);
      _symptomToSpeciality = specMap;
      // Load all doctors for every speciality on startup
      _loadDoctorsBySpecialities(dt.symptoms.keys.toList());
    } catch (_) {
      _allSymptoms = [];
      _filteredSymptoms = [];
      _symptomToSpeciality = {};
    }
    
    // Fetch notifications on startup
    _fetchNotifications();
    
    // Set up periodic notification check every 30 seconds
    _notificationCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _searchCtrl.dispose();
    _notificationCheckTimer?.cancel();
    _notificationDismissTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double expandedHeight = 200.0;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0024),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: expandedHeight,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildAppBarMenu(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildNotificationIcon(),
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double maxHeight = constraints.maxHeight;
                final bool isCollapsed = maxHeight <= kToolbarHeight + 20;
                final bool isExpanded = maxHeight >= expandedHeight - 10;
                final bg = Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, darkColor],
                    ),
                  ),
                );
                if (isCollapsed) {
                  return Stack(
                    children: [
                      bg,
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Welcome, Patient',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (isExpanded) {
                  return Stack(
                    children: [
                      bg,
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 60, color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome Back!',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore your health dashboard',
                              style: GoogleFonts.manrope(
                                textStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                final double t =
                    ((maxHeight - kToolbarHeight) /
                            (expandedHeight - kToolbarHeight))
                        .clamp(0.0, 1.0);
                return Stack(
                  children: [
                    bg,
                    if (t > 0.25)
                      Opacity(
                        opacity: t,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 60, color: Colors.white),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome Back!',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explore your health dashboard',
                                style: GoogleFonts.manrope(
                                  textStyle: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 1.0 - t,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Welcome, Patient',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF0F0024),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar – filters symptom cards
                        TextField(
                          controller: _searchCtrl,
                          style: GoogleFonts.manrope(color: Colors.white),
                          onChanged: (v) {
                            setState(() {
                              final query = v.trim().toLowerCase();
                              if (query.isEmpty) {
                                _filteredSymptoms = List.from(_allSymptoms);
                              } else {
                                _filteredSymptoms = _allSymptoms
                                    .where(
                                      (s) => s.toLowerCase().contains(query),
                                    )
                                    .toList();
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search symptoms...',
                            hintStyle: GoogleFonts.manrope(
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1A0F32),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Symptom cards section
                        Text(
                          'Select your symptoms',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedSymptoms.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${_selectedSymptoms.length} selected',
                              style: GoogleFonts.manrope(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Multi-select symptom cards in a single horizontal scrollable row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filteredSymptoms.asMap().entries.map((
                              entry,
                            ) {
                              final i = entry.key;
                              final s = entry.value;
                              final selected = _selectedSymptoms.contains(s);
                              final speciality = _symptomToSpeciality[s] ?? '';
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: i < _filteredSymptoms.length - 1
                                      ? 10
                                      : 0,
                                ),
                                child: _SymptomCard(
                                  symptom: s,
                                  speciality: speciality,
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      if (selected) {
                                        _selectedSymptoms.remove(s);
                                      } else {
                                        _selectedSymptoms.add(s);
                                      }
                                    });
                                    // Reload doctors based on selection
                                    final specs = _selectedSymptoms.isEmpty
                                        ? doctypesymptom().symptoms.keys
                                              .toList()
                                        : _selectedSymptoms
                                              .map(
                                                (sym) =>
                                                    _symptomToSpeciality[sym] ??
                                                    '',
                                              )
                                              .where((sp) => sp.isNotEmpty)
                                              .toSet()
                                              .toList();
                                    _loadDoctorsBySpecialities(specs);
                                  },
                                  primaryColor: primaryColor,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (_filteredSymptoms.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No symptoms match your search',
                                style: GoogleFonts.manrope(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Doctors section with Free/Paid tabs — above Health News
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Doctors',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tab switcher for Free / Paid doctors
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Simple segmented control instead of TabBar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111023),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _doctorTabIndex = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _doctorTabIndex == 0
                                          ? primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Free',
                                        style: TextStyle(
                                          color: _doctorTabIndex == 0
                                              ? Colors.white
                                              : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _doctorTabIndex = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _doctorTabIndex == 1
                                          ? primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Paid',
                                        style: TextStyle(
                                          color: _doctorTabIndex == 1
                                              ? Colors.white
                                              : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Horizontal scrollable list of doctors
                        SizedBox(
                          height: MediaQuery.of(context).size.width > 600 ? 175 : 158,
                          child: _doctorsLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Builder(
                                  builder: (context) {
                                    var filtered = _doctorTabIndex == 0
                                        ? _doctors.where((d) =>
                                            ((d['fee'] ?? 0) as num) == 0)
                                        : _doctors.where((d) =>
                                            ((d['fee'] ?? 0) as num) > 0);
                                    filtered = filtered.where((d) =>
                                        _isDoctorAvailable(
                                            (d['availTime'] ?? '') as String));
                                    final list = filtered.toList();
                                    final cardWidth = MediaQuery.of(context).size.width > 600 ? 135.0 : 118.0;
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      itemCount: list.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) => SizedBox(
                                        width: cardWidth,
                                        child: _buildDoctorCard(list[index]),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Health News Carousel
                  _buildHealthNewsCarousel(),
                  const SizedBox(height: 24),
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConsultaiPage()),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
    );
  }

  Widget _buildHealthNewsCarousel() {
    final newsAsync = ref.watch(newsProvider);

    return newsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      ),
      error: (error, stack) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            "Failed to load news",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (healthNews) {
        if (healthNews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "No health news available",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Health News',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            CarouselSlider.builder(
              itemCount: healthNews.length,
              itemBuilder: (context, index, realIndex) {
                final news = healthNews[index];
                final imageUrl = news['image'];
                final title = news['title'];
                final url = news['url'];

                return GestureDetector(
                  onTap: () async {
                    if (url != null && url.toString().startsWith('http')) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: primaryColor,
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                onPageChanged: (index, reason) {},
              ),
            ),
            // Report analyser + history cards below the carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildReportAnalyserCard(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildHistoryCard(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildBMICard(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationIcon() {
    final unreadCount = _notifications.where((n) => n['read'] == false).length;
    
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () => _showNotificationModal(),
          padding: const EdgeInsets.all(8),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF080826),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Notifications List
            if (_notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No notifications yet',
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white10,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['read'] == true;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.transparent
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notif['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          notif['message'] ?? '',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: !isRead
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Manual Refresh Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _fetchNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refreshing notifications...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
            );
            break;
          case 'contact':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PatientHelpSupport()));
            break;
          case 'logout':
            try {
              await ref.read(authProvider.notifier).logout();
            } catch (e) {
              // ignore logout errors, proceed to clear local token anyway
            }
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StartPage()),
              (route) => false,
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'contact', child: Text('Help and Support')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }

  Widget _buildReportAnalyserCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReportAnalyzerPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF6B5CE6), const Color(0xFF4ECDC4)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Analyser',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered medical report analysis',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PatientHistory()));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111023),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See recent activity and patient history',
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    return Row(
      children: [
        // BMI Calculator Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BMICalculator()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111023),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calculate, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BMI',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calculator',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // AI Doctor Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AICallScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111023),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medical_services, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AI',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Doctor',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doc) {
    final docId = (doc['id'] ?? doc['_id'] ?? '') as String;
    final name = (doc['name'] as String?) ?? 'Doctor';
    final speciality = (doc['speciality'] as String?) ?? 'General';
    final fee = ((doc['fee'] as num?) ?? 0).toInt();
    final licenceId = (doc['regId'] as String?) ?? '';
    final isFree = fee == 0;

    // Colour based on free/paid — vivid & noticeable
    const freeColor  = Color(0xFF00E5B8); // brighter teal
    const paidColor  = Color(0xFF6C63FF); // vivid indigo-violet
    final accentColor = isFree ? freeColor : paidColor;

    return GestureDetector(
      onTap: () {
        if (docId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to book a consultation'),
            ),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConsultationFormPage(
              doctorId: docId,
              doctorName: name,
              doctorSpeciality: speciality,
              fee: fee,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.13),
              const Color(0xFF0C0B38),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top accent bar 
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.15)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Avatar + Name 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(0.8),
                                accentColor.withOpacity(0.3),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: accentColor.withOpacity(0.4), width: 1.2),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (licenceId.isNotEmpty)
                                Text(
                                  licenceId,
                                  style: GoogleFonts.manrope(
                                    color: accentColor.withOpacity(0.7),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ── Speciality badge 
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: accentColor.withOpacity(0.25), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medical_services_rounded,
                              size: 8, color: accentColor),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              speciality,
                              style: GoogleFonts.manrope(
                                color: accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Fee + Book row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Fee',
                              style: GoogleFonts.manrope(
                                color: Colors.white38,
                                fontSize: 8,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              isFree ? 'FREE' : '₹$fee',
                              style: GoogleFonts.poppins(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor,
                                accentColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Book',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Multi-selectable symptom card (fetchable from search bar via soctype-symptom)
class _SymptomCard extends StatelessWidget {
  final String symptom;
  final String speciality;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _SymptomCard({
    required this.symptom,
    required this.speciality,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withOpacity(0.85)
              : const Color(0xFF111023),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primaryColor : Colors.white12,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.medical_services_outlined,
              size: 20,
              color: selected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  symptom,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (speciality.isNotEmpty)
                  Text(
                    speciality,
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
