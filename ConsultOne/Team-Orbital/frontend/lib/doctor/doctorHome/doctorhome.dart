import "package:flutter/material.dart";
import "package:carousel_slider/carousel_slider.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app_route_observer.dart';
import 'package:frontend/doctor/docHistory/docHistory.dart';
import 'package:frontend/health_news/health_news_provider.dart';
import 'package:frontend/reportAnalyzer/report_analyzer_page.dart';
import 'package:frontend/consultAi/consultAi_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/doctor/doctorProfile/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/patient/screens/patient_consultation_chat_screen.dart';
import 'package:frontend/doctor/doctorResponse/docChat.dart';
import 'package:frontend/doctor/auth/doctor_signUp_provider.dart';
import 'package:frontend/start_page.dart';
import 'dart:developer' as developer;
import 'package:frontend/firebase_api.dart';
import 'package:frontend/doctor/services/fcm_api.dart';
import 'package:frontend/doctor/help/help_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class DoctorHome extends ConsumerStatefulWidget {
  const DoctorHome({super.key});

  @override
  ConsumerState<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends ConsumerState<DoctorHome>
    with RouteAware, WidgetsBindingObserver {
  // Color constants
  static const Color primaryColor = Color(0xFF1D1F8C);
  static const Color darkColor = Color(0xFF080826);
  
  int _selectedTabIndex = 0;

  // ── Real consultation data ───────────────────────────────────────────────
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _allCases = [];
  bool _casesLoading = false;
  String? _casesError;

  void _refreshData() {
    ref.invalidate(newsProvider);
    _loadCases();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFcmAndLoadCases();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
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

  Future<void> _initFcmAndLoadCases() async {
    // 1. Initialize FCM Notifications
    try {
      await FirebaseApi().initNotifications(context);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FcmApi.registerToken(fcmToken);
      }
    } catch (e) {
      developer.log('FCM Initialization Failed: $e');
    }

    // 2. Load Cases
    _loadCases();
  }

  Future<void> _loadCases() async {
    if (!mounted) return;
    setState(() {
      _casesLoading = true;
      _casesError = null;
    });
    try {
      final token = await TokenStorage.getToken();
      developer.log('🔵 DoctorHome: Token check - ${token == null ? "NULL" : "Present (length=${token.length})"}', name: 'DoctorHome');
      
      // Debug: Check if token exists
      if (token == null || token.isEmpty) {
        developer.log('❌ DoctorHome: No valid token found', name: 'DoctorHome');
        if (mounted) {
          setState(() {
            _casesError = 'Authentication required. Please log in again.';
            _casesLoading = false;
          });
        }
        return;
      }

      developer.log('🟢 DoctorHome: Fetching cases with valid token', name: 'DoctorHome');
      
      // Fetch both normal and emergency pending consultations in parallel
      final results = await Future.wait([
        _api.get('/doctor/cases/normal', token: token),
        _api.get('/doctor/cases/emergency', token: token),
      ]);
      final List<dynamic> normalRaw = results[0] is List ? results[0] as List<dynamic> : [];
      final List<dynamic> emergRaw = results[1] is List ? results[1] as List<dynamic> : [];
      final merged = [
        ...normalRaw.whereType<Map<String, dynamic>>(),
        ...emergRaw.whereType<Map<String, dynamic>>(),
      ];
      // Sort newest first
      merged.sort((a, b) {
        final aTime = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      developer.log('✅ DoctorHome: Loaded ${merged.length} cases', name: 'DoctorHome');
      if (mounted) setState(() => _allCases = merged);
    } catch (e) {
      developer.log('🔴 DoctorHome: Error loading cases - $e', name: 'DoctorHome');
      if (mounted) setState(() => _casesError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _casesLoading = false);
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
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double maxHeight = constraints.maxHeight;
                final double topPad = MediaQuery.of(context).padding.top;
                final double collapsedHeight = kToolbarHeight + topPad;
                final bool isCollapsed = maxHeight <= collapsedHeight + 1;
                final bool isExpanded = maxHeight >= expandedHeight - 10;

                final bg = Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        darkColor,
                      ],
                    ),
                  ),
                );

                if (isCollapsed) {
                  // Collapsed: show only the compact title (no logo/subtitle)
                  return Stack(children: [
                    bg,
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ]);
                }

                if (isExpanded) {
                  // only show the expanded content when near full height
                  return Stack(children: [
                    bg,
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_hospital,
                                size: 60,
                                color: Colors.white,
                              ),
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
                                'Manage your patients and appointments',
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
                    ),
                  ]);
                }

                // intermediate state: cross-fade the expanded header out, and the compact
                // title in. Logo/subtitle fade away as the bar shrinks.
                final double t = ((maxHeight - collapsedHeight) /
                    (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);

                return Stack(
                  children: [
                    bg,
                    Opacity(
                      opacity: t,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_hospital,
                                  size: 60,
                                  color: Colors.white,
                                ),
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
                                  'Manage your patients and appointments',
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 1.0 - t,
                        child: Text(
                          'Welcome Back!',
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
              },
            ),
          ),
          // Content section
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF0F0024),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health News Carousel
                  _buildHealthNewsCarousel(),
                  const SizedBox(height: 24),
                  // Report Analyser Feature Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildReportAnalyserCard(),
                  ),
                  const SizedBox(height: 16),
                  // View History Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHistoryCard(),
                  ),
                  const SizedBox(height: 24),
                  // Tab View for Cases
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTabView(),
                  ),
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Chatbot Icon
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
      child: Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
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
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
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
                            child: const Icon(Icons.image,
                                color: Colors.white),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black87,
                                Colors.transparent
                              ],
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
                        )
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
        ],
      );
    },
  );
}

  Widget _buildReportAnalyserCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_)=>ReportAnalyzerPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6B5CE6),
              const Color(0xFF4ECDC4),
            ],
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
              child: const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Analyser',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered medical report analysis',
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Dochistory()));
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
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See recent activity and patient history',
                    style: GoogleFonts.manrope(textStyle: TextStyle(color: Colors.white70, fontSize: 14)),
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

  Widget _buildTabView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patients',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tab Bar (styled to match History tab bar pill)
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF0A093A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTabButton('All Cases', Icons.grid_view_rounded, 0),
              _buildTabButton('Emergency', Icons.add_circle_outline_rounded, 1),
              _buildTabButton('Normal', Icons.favorite_border_rounded, 2),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Tab Content
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: isSelected
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D1F8C), Color(0xFF3D40CC)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D40CC).withOpacity(0.5),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    textStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.dashboard, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorProfileScreen()));
            break;
          case 'contact':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorHelpSupport()));
            break;
          case 'logout':
            _handleDoctorLogout();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'contact', child: Text('Help and Support')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> _handleDoctorLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        developer.log('🗑️ Doctor logout: Starting logout process', name: 'Logout');
        
        // Call logout through provider
        await ref.read(doctorAuthProvider.notifier).logout();
        
        developer.log('✅ Doctor logout: Tokens cleared, navigating to StartPage', name: 'Logout');
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const StartPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        developer.log('🔴 Doctor logout error: $e', name: 'Logout');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout error: $e')),
          );
        }
      }
    }
  }

  Widget _buildTabContent() {
    if (_casesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }
    if (_casesError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    _casesError ?? 'Error loading cases',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      developer.log('Retrying to load cases', name: 'DoctorHome');
                      _loadCases();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_casesError?.contains('Authentication') == true) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        developer.log('Doctor login again: Clearing tokens and navigating', name: 'DoctorHome');
                        try {
                          await TokenStorage.clearAll();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const StartPage()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        } catch (e) {
                          developer.log('Error during login again: $e', name: 'DoctorHome');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Login Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4C6A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> filtered;
    if (_selectedTabIndex == 1) {
      filtered = _allCases.where((p) => p['type'] == 'emergency').toList();
    } else if (_selectedTabIndex == 2) {
      filtered = _allCases.where((p) => p['type'] == 'normal').toList();
    } else {
      filtered = _allCases;
    }

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              Text('No pending consultations',
                  style: TextStyle(color: Colors.grey[400], fontSize: 15)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loadCases,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filtered
          .map((c) => _buildPatientCard(c))
          .toList(),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final sw = MediaQuery.of(context).size.width;
    double sp(double base) => base * (sw / 390).clamp(0.82, 1.22);

    // Backend returns 'emergency' / 'normal' (lowercase)
    final isEmergency = (patient['type'] as String? ?? '').toLowerCase() == 'emergency';
    final typeColor = isEmergency
        ? const Color(0xFFFF4C6A)
        : const Color(0xFF00D4AA);
    final typeIcon =
        isEmergency ? Icons.local_hospital_rounded : Icons.healing_rounded;
    final typeLabel = isEmergency ? 'Emergency' : 'Normal';

    // Map backend fields
    final consultId = patient['_id'] as String? ?? '';
    final patientName = patient['full_name'] as String? ?? 'Patient';
    final problem = patient['Problem'] as String? ?? 'Consultation';
    final doctorName = (patient['doctor_id'] is Map)
        ? (patient['doctor_id'] as Map)['name'] as String? ?? ''
        : '';
    final doctorSpec = (patient['doctor_id'] is Map)
        ? (patient['doctor_id'] as Map)['speciality'] as String? ?? ''
        : '';
    // Format date from createdAt
    String dateStr = '';
    try {
      final dt = DateTime.parse(patient['createdAt']?.toString() ?? '').toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {}

    Widget typeBadge() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: sp(9), vertical: sp(3.5)),
        decoration: BoxDecoration(
          color: typeColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: typeColor.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(typeIcon, size: sp(10.5), color: typeColor),
            SizedBox(width: sp(4)),
            Text(
              typeLabel,
              style: GoogleFonts.oswald(
                fontSize: sp(10.5),
                letterSpacing: 0.8,
                color: typeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: consultId.isEmpty
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DocResponseScreen(
                  consultationId: consultId,
                  isEmergency: isEmergency,
                ),
              )),
      child: Container(
        margin: EdgeInsets.only(bottom: sp(13)),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0B38),
          borderRadius: BorderRadius.circular(sp(18)),
          border: Border.all(color: const Color(0x331D1F8C), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(sp(18)),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [typeColor, typeColor.withOpacity(0.2)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(sp(20), sp(14), sp(14), sp(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: GoogleFonts.oswald(
                            fontSize: sp(11.5),
                            letterSpacing: 1.5,
                            color: Colors.white.withOpacity(0.38),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        typeBadge(),
                      ],
                    ),
                    SizedBox(height: sp(7)),
                    Text(
                      patientName,
                      style: GoogleFonts.poppins(
                        fontSize: sp(16.5),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: sp(3)),
                    Text(
                      problem,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: sp(12.5),
                        color: Colors.white.withOpacity(0.58),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: sp(13)),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: sp(12),
                          color: Colors.white.withOpacity(0.35),
                        ),
                        SizedBox(width: sp(5)),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: sp(11.5),
                            color: Colors.white.withOpacity(0.45),
                            fontWeight: FontWeight.w500,
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

