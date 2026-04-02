import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/app_route_observer.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'dart:developer' as developer;

// ── Colour palette ──────────────────────────────────────────────────────────
const Color kBg = Color(0xFF03020F); // very deep navy-black
const Color kSurface = Color(0xFF080826); // slightly lighter surface
const Color kAccent = Color(0xFF1D1F8C);
const Color kAccentBright = Color(0xFF3D40CC);
const Color kCardBg = Color(0x1A1D1F8C); // 10 % opacity – darker cards
const Color kCardBorder = Color(0x331D1F8C); // 20 % opacity border
const Color kEmergency = Color(0xFFFF4C6A);
const Color kNormal = Color(0xFF00D4AA);
const Color kWhite = Colors.white;

// ── Mock data (replace with API call once backend is ready) ──────────────────
class CaseModel {
  // consultationId comes from the backend (consultation document _id)
  final String consultationId;
  final String patientName;
  final String diagnosis;
  final String date;
  final String time;
  final CaseType type;
  final String status;

  const CaseModel({
    required this.consultationId,
    required this.patientName,
    required this.diagnosis,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
  });
}

enum CaseType { emergency, normal }

// ─────────────────────────────────────────────────────────────────────────────

class Dochistory extends StatefulWidget {
  const Dochistory({super.key});

  @override
  State<Dochistory> createState() => _DochistoryState();
}

class _DochistoryState extends State<Dochistory>
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  bool _loading = false;
  List<CaseModel> _cases = [];

  void _refreshData() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _tabController.dispose();
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

  // ── filter cases by status tab ──────────────────────────────────────────
  // 0 = Resolved  · 1 = Unresolved  · 2 = Cancelled
  List<CaseModel> _filtered(int index) {
    const statuses = ['Resolved', 'Unresolved', 'Cancelled'];
    return _cases.where((c) => c.status == statuses[index]).toList();
  }

  int _countForTab(int index) {
    const statuses = ['Resolved', 'Unresolved', 'Cancelled'];
    return _cases.where((c) => c.status == statuses[index]).length;
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final token = await TokenStorage.getToken();
      final res = await ApiService().get('/doctor/history', token: token);

      List<dynamic> raw;
      if (res is List) {
        raw = res;
      } else if (res is Map && res['cases'] is List) {
        raw = res['cases'];
      } else if (res is Map) {
        // Some backends return { doctor: {...}, cases: [...] }
        raw = res.values.where((v) => v is List).cast<List>().fold<List<dynamic>>([], (p, e) => p..addAll(e));
      } else {
        raw = [];
      }

      final parsed = raw.map<CaseModel>((c) {
        final id = c['_id']?.toString() ?? c['id']?.toString() ?? 'unknown';
        final patient = (c['patient_id'] is Map) ? (c['patient_id']['name'] ?? 'Patient') : (c['patient_id']?.toString() ?? 'Patient');
        final diagnosis = (c['doctorNotes'] ?? c['Problem'] ?? c['diagnosis'] ?? '').toString();
        final created = c['createdAt']?.toString() ?? c['created_at']?.toString() ?? DateTime.now().toIso8601String();
        DateTime dt = DateTime.tryParse(created) ?? DateTime.now();
        final date = '${dt.day.toString().padLeft(2,'0')} ${_monthName(dt.month)} ${dt.year}';
        final time = TimeOfDay.fromDateTime(dt).format(context);
        final type = (c['type']?.toString() ?? '').toLowerCase() == 'emergency' ? CaseType.emergency : CaseType.normal;
        // Map backend status values to the display strings used for tab filtering.
        final rawStatus = c['status']?.toString() ?? 'pending';
        final status = rawStatus == 'responded'
            ? 'Resolved'
            : rawStatus == 'pending'
                ? 'Unresolved'
                : 'Cancelled';

        return CaseModel(
          consultationId: id,
          patientName: patient,
          diagnosis: diagnosis,
          date: date,
          time: time,
          type: type,
          status: status,
        );
      }).toList();

      setState(() {
        _cases = parsed;
      });
      developer.log('Loaded ${_cases.length} history cases', name: 'DocHistory');
    } catch (e) {
      developer.log('Failed to load history: $e', name: 'DocHistory');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return (m>=1 && m<=12) ? names[m-1] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _HistorySliverAppBar(
            tabController: _tabController,
            forceElevated: innerBoxIsScrolled,
            countForTab: _countForTab,
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: List.generate(
                  3,
                  (i) => AnimatedBuilder(
                    animation: _tabController,
                    builder: (_, __) => _CaseList(cases: _filtered(i)),
                  ),
                ),
              ),
      ),
    );
  }
}

// (counts are provided by the stateful widget)

// ── Responsive helpers ────────────────────────────────────────────────────────
extension _Resp on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
  double sp(double base) => base * (sw / 390).clamp(0.82, 1.22);
}

// ── Sliver App Bar ────────────────────────────────────────────────────────────
class _HistorySliverAppBar extends StatelessWidget {
  const _HistorySliverAppBar({
    required this.tabController,
    required this.forceElevated,
    required this.countForTab,
  });

  final TabController tabController;
  final bool forceElevated;
  final int Function(int) countForTab;

  @override
  Widget build(BuildContext context) {
    final double expandedH = (context.sh * 0.22).clamp(160.0, 210.0);
    // Keep the SliverAppBar bottom height in sync with the actual TabBar
    // widget height + its bottom margin to prevent RenderFlex overflow.
    final double tabBarTotalHeight = context.sp(48) + context.sp(10);

    return SliverAppBar(
      backgroundColor: kBg,
      expandedHeight: expandedH,
      floating: false,
      pinned: true,
      elevation: forceElevated ? 8 : 0,
      shadowColor: kAccent.withOpacity(0.6),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        // Small title that appears only when the bar is collapsed
        titlePadding: EdgeInsetsDirectional.only(start: 72, bottom: 16),
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w600,
            color: kWhite,
          ),
        ),
        background: _ExpandedHeader(
          expandedHeight: expandedH,
          tabController: tabController,
          countForTab: countForTab,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(tabBarTotalHeight),
        child: _HistoryTabBar(controller: tabController),
      ),
    );
  }
}

// ── Expanded header (visible when not scrolled) ───────────────────────────────
class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({
    required this.expandedHeight,
    required this.tabController,
    required this.countForTab,
  });
  final double expandedHeight;
  final TabController tabController;
  final int Function(int) countForTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottomPad = (expandedHeight * 0.32).clamp(
      context.sp(44),
      context.sp(68),
    );
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07062A), kBg],
        ),
      ),
      padding: EdgeInsets.only(
        top: top + 14,
        left: context.sp(22),
        right: context.sp(22),
        bottom: bottomPad, // room for tab bar (dynamic to avoid overflow)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── top row ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CASE RECORDS',
                style: GoogleFonts.oswald(
                  fontSize: context.sp(10.5),
                  letterSpacing: 2.8,
                  color: kAccentBright.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnimatedBuilder(
                animation: tabController,
                builder: (_, __) {
                  final index = tabController.index;
                  const labels = ['Resolved', 'Unresolved', 'Cancelled'];
                  final count = countForTab(index);
                  return _PillBadge(
                    icon: Icons.folder_copy_rounded,
                    label: '$count ${labels[index]}',
                  );
                },
              ),
            ],
          ),
          SizedBox(height: context.sp(10)),
          // ── Main heading (large when expanded) ────────────────
          Text(
            'History',
            style: GoogleFonts.poppins(
              fontSize: context.sp(36),
              fontWeight: FontWeight.w700,
              color: kWhite,
              height: 1.05,
            ),
          ),
          SizedBox(height: context.sp(3)),
          Text(
            'Your complete patient case archive',
            style: GoogleFonts.manrope(
              fontSize: context.sp(12.5),
              color: kWhite.withOpacity(0.45),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(10),
        vertical: context.sp(4),
      ),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.sp(12), color: kNormal),
          SizedBox(width: context.sp(5)),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: context.sp(11),
              color: kWhite.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────
class _HistoryTabBar extends StatelessWidget {
  const _HistoryTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final h = context.sp(48);
    return Container(
      height: h,
      margin: EdgeInsets.fromLTRB(
        context.sp(14),
        0,
        context.sp(14),
        context.sp(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A093A), // darker pill background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: kAccent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D1F8C), Color(0xFF3D40CC)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kAccentBright.withOpacity(0.5),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        labelStyle: GoogleFonts.manrope(
          fontSize: context.sp(11.5),
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: context.sp(11.5),
          fontWeight: FontWeight.w500,
        ),
        labelColor: kWhite,
        unselectedLabelColor: kWhite.withOpacity(0.4),
        tabs: [
          Tab(
            child: _TabItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Resolved',
              sp: context.sp,
            ),
          ),
          Tab(
            child: _TabItem(
              icon: Icons.pending_outlined,
              label: 'Unresolved',
              sp: context.sp,
            ),
          ),
          Tab(
            child: _TabItem(
              icon: Icons.cancel_outlined,
              label: 'Cancelled',
              sp: context.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, required this.sp});

  final IconData icon;
  final String label;
  final double Function(double) sp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: sp(13)),
        SizedBox(width: sp(4)),
        Text(label),
      ],
    );
  }
}

// ── Case list ─────────────────────────────────────────────────────────────────
class _CaseList extends StatelessWidget {
  const _CaseList({required this.cases});

  final List<CaseModel> cases;

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: context.sp(52),
              color: kAccentBright.withOpacity(0.35),
            ),
            SizedBox(height: context.sp(12)),
            Text(
              'No cases found',
              style: GoogleFonts.manrope(
                fontSize: context.sp(15),
                color: kWhite.withOpacity(0.38),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        context.sp(14),
        context.sp(10),
        context.sp(14),
        context.sp(32),
      ),
      itemCount: cases.length,
      itemBuilder: (context, i) => _CaseCard(caseModel: cases[i]),
    );
  }
}

// ── Case card ─────────────────────────────────────────────────────────────────
class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.caseModel});

  final CaseModel caseModel;

  Color get _typeColor =>
      caseModel.type == CaseType.emergency ? kEmergency : kNormal;

  IconData get _typeIcon => caseModel.type == CaseType.emergency
      ? Icons.local_hospital_rounded
      : Icons.healing_rounded;

  String get _typeLabel =>
      caseModel.type == CaseType.emergency ? 'Emergency' : 'Normal';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.sp(13)),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0B38), // medium-dark card face
        borderRadius: BorderRadius.circular(context.sp(18)),
        border: Border.all(color: kCardBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: kAccent.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.sp(18)),
        child: Stack(
          children: [
            // ── colour strip ──────────────────────────────────
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
                    colors: [_typeColor, _typeColor.withOpacity(0.2)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(14),
                context.sp(14),
                context.sp(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: ID + badge ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        caseModel.consultationId,
                        style: GoogleFonts.oswald(
                          fontSize: context.sp(11.5),
                          letterSpacing: 1.5,
                          color: kWhite.withOpacity(0.38),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      _Badge(
                        icon: _typeIcon,
                        label: _typeLabel,
                        color: _typeColor,
                      ),
                    ],
                  ),
                  SizedBox(height: context.sp(7)),
                  // ── Patient name ───────────────────────────────
                  Text(
                    caseModel.patientName,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(16.5),
                      fontWeight: FontWeight.w600,
                      color: kWhite,
                    ),
                  ),
                  SizedBox(height: context.sp(3)),
                  // ── Diagnosis ──────────────────────────────────
                  Text(
                    caseModel.diagnosis,
                    style: GoogleFonts.manrope(
                      fontSize: context.sp(12.5),
                      color: kWhite.withOpacity(0.58),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: context.sp(13)),
                  // ── Row 3: date + time + status ────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: context.sp(12),
                        color: kWhite.withOpacity(0.35),
                      ),
                      SizedBox(width: context.sp(5)),
                      Text(
                        caseModel.date,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(11.5),
                          color: kWhite.withOpacity(0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: context.sp(12)),
                      Icon(
                        Icons.access_time_rounded,
                        size: context.sp(12),
                        color: kWhite.withOpacity(0.35),
                      ),
                      SizedBox(width: context.sp(5)),
                      Text(
                        caseModel.time,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(11.5),
                          color: kWhite.withOpacity(0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(status: caseModel.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small badge (Emergency / Normal) ─────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(9),
        vertical: context.sp(3.5),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.sp(10.5), color: color),
          SizedBox(width: context.sp(4)),
          Text(
            label,
            style: GoogleFonts.oswald(
              fontSize: context.sp(10.5),
              letterSpacing: 0.8,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  // Resolved  → teal green
  // Unresolved → amber
  // Cancelled  → soft red-pink
  Color get _color {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF00D4AA); // teal
      case 'Unresolved':
        return const Color(0xFFFFC857); // amber
      case 'Cancelled':
        return const Color(0xFFFF6B8A); // soft pink-red
      default:
        return kWhite.withOpacity(0.45);
    }
  }

  Color get _bgColor => _color.withOpacity(0.12);
  Color get _borderColor => _color.withOpacity(0.35);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(8),
        vertical: context.sp(3),
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.sp(6),
            height: context.sp(6),
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: context.sp(5)),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: context.sp(10.5),
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
