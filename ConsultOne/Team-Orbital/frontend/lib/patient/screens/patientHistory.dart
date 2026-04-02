import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/app_route_observer.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/patient/screens/patient_consultation_chat_screen.dart';

// Reuse the same palette as doctor history for visual parity
const Color kBg = Color(0xFF03020F);
const Color kAccent = Color(0xFF1D1F8C);
const Color kAccentBright = Color(0xFF3D40CC);
const Color kCardBg = Color(0x1A1D1F8C);
const Color kCardBorder = Color(0x331D1F8C);
const Color kEmergency = Color(0xFFFF4C6A);
const Color kNormal = Color(0xFF00D4AA);
const Color kWhite = Colors.white;

class PatientHistory extends StatefulWidget {
  const PatientHistory({super.key});

  @override
  State<PatientHistory> createState() => _PatientHistoryState();
}

class _PatientCase {
  final String consultationId;
  final String doctorName;
  final String doctorSpeciality;
  final String problem;
  final String doctorNotes;
  final String patientFileUrl;
  final String doctorFileUrl;
  final String email;
  final String age;
  final String gender;
  final String contactNo;
  final String lifeStyle;
  final DateTime date;
  final String type; // 'normal' | 'emergency'
  final String status; // 'pending' | 'responded'

  _PatientCase({
    required this.consultationId,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.problem,
    required this.doctorNotes,
    required this.patientFileUrl,
    required this.doctorFileUrl,
    required this.email,
    required this.age,
    required this.gender,
    required this.contactNo,
    required this.lifeStyle,
    required this.date,
    required this.type,
    required this.status,
  });

  factory _PatientCase.fromMap(Map m) {
    final id = (m['_id'] ?? m['id'] ?? '').toString();
    final doc = m['doctor_id'];
    final doctorName = doc is Map
        ? (doc['name'] ?? '')
        : (m['doctorName'] ?? '');
    final doctorSpeciality = doc is Map
        ? (doc['speciality'] ?? '')
        : (m['doctorSpeciality'] ?? '');
    final created = m['createdAt'] ?? m['updatedAt'];
    DateTime dt;
    try {
      dt = DateTime.parse(created ?? DateTime.now().toIso8601String());
    } catch (_) {
      dt = DateTime.now();
    }
    return _PatientCase(
      consultationId: id,
      doctorName: doctorName ?? '',
      doctorSpeciality: doctorSpeciality ?? '',
      problem: (m['Problem'] ?? '').toString(),
      doctorNotes: (m['doctorTextResponse'] ?? m['doctorNotes'] ?? '').toString(),
      patientFileUrl: (m['patientFileUrl'] ?? '').toString(),
      doctorFileUrl: (m['doctorFileUrl'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      age: (m['age'] ?? '').toString(),
      gender: (m['gender'] ?? '').toString(),
      contactNo: (m['contactNo'] ?? '').toString(),
      lifeStyle: (m['life_style'] ?? '').toString(),
      date: dt,
      type: (m['type'] ?? 'normal').toString(),
      status: (m['status'] ?? '').toString(),
    );
  }
}

extension _Resp on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
  double sp(double base) => base * (sw / 390).clamp(0.82, 1.22);
}

class _PatientHistoryState extends State<PatientHistory>
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late TabController _tabController;
  final ApiService _api = ApiService();
  List<_PatientCase> _resolved = [];
  List<_PatientCase> _unresolved = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
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
    _loadHistory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }
      final resUn = await _api.get('/patient/unresolved', token: token);
      final resRe = await _api.get('/patient/resolved', token: token);

      final unList = (resUn['unResolveDocs'] as List<dynamic>?) ?? [];
      final reList = (resRe['ResolveDocs'] as List<dynamic>?) ?? [];

      setState(() {
        _unresolved = unList
            .map(
              (e) => _PatientCase.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        _resolved = reList
            .map(
              (e) => _PatientCase.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          _HistorySliverAppBar(
            tabController: _tabController,
            forceElevated: inner,
            resolvedCount: _resolved.length,
            unresolvedCount: _unresolved.length,
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(
                  'Error: $_error',
                  style: GoogleFonts.manrope(color: Colors.white70),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _CaseList(cases: _resolved, onRefresh: _loadHistory),
                  _CaseList(cases: _unresolved, onRefresh: _loadHistory),
                ],
              ),
      ),
    );
  }
}

class _HistorySliverAppBar extends StatelessWidget {
  const _HistorySliverAppBar({
    required this.tabController,
    required this.forceElevated,
    required this.resolvedCount,
    required this.unresolvedCount,
  });
  final TabController tabController;
  final bool forceElevated;
  final int resolvedCount;
  final int unresolvedCount;

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final double expandedH =
        (context.sh *
                (sw > 900
                    ? 0.16
                    : sw > 600
                    ? 0.20
                    : 0.24))
            .clamp(120.0, 260.0);
    final double tabBarTotalHeight =
        (context.sp(sw > 420 ? 52 : 44) + context.sp(10)).clamp(44.0, 80.0);
    return SliverAppBar(
      backgroundColor: kBg,
      expandedHeight: expandedH,
      floating: false,
      pinned: true,
      elevation: forceElevated ? 8 : 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(start: 72, bottom: 16),
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w600,
            color: kWhite,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF07062A), kBg],
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: context.sp(sw > 420 ? 24 : 16),
            right: context.sp(sw > 420 ? 24 : 16),
            bottom: (expandedH * (sw > 900 ? 0.28 : 0.32)).clamp(
              context.sp(36),
              context.sp(84),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'CASE RECORDS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.oswald(
                        fontSize: context.sp(sw > 420 ? 11 : 9.5),
                        letterSpacing: 2.8,
                        color: kAccentBright.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: tabController,
                    builder: (_, __) {
                      final index = tabController.index;
                      final label = index == 0 ? 'Resolved' : 'Unresolved';
                      final count = index == 0
                          ? resolvedCount
                          : unresolvedCount;
                      return _PillBadge(
                        icon: index == 0
                            ? Icons.check_circle_rounded
                            : Icons.pending_outlined,
                        label: '$count $label',
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: context.sp(10)),
              Text(
                'History',
                style: GoogleFonts.poppins(
                  fontSize: context.sp(
                    sw > 900
                        ? 40
                        : sw > 600
                        ? 34
                        : 28,
                  ),
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                ),
              ),
              SizedBox(height: context.sp(3)),
              Text(
                'Your consultations and responses',
                style: GoogleFonts.manrope(
                  fontSize: context.sp(sw > 420 ? 13 : 11.5),
                  color: kWhite.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(tabBarTotalHeight),
        child: _HistoryTabBar(controller: tabController),
      ),
    );
  }
}

class _HistoryTabBar extends StatelessWidget {
  const _HistoryTabBar({required this.controller});
  final TabController controller;
  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final isSmall = sw < 360;
    final h = context.sp(isSmall ? 42 : (sw > 720 ? 60 : 48));
    return Container(
      height: h,
      margin: EdgeInsets.fromLTRB(
        context.sp(14),
        0,
        context.sp(14),
        context.sp(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A093A),
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
        isScrollable: isSmall,
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
          fontSize: context.sp(isSmall ? 10.5 : 11.5),
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: context.sp(isSmall ? 10.5 : 11.5),
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

class _CaseList extends StatelessWidget {
  final List<_PatientCase> cases;
  final Future<void> Function() onRefresh;
  const _CaseList({required this.cases, required this.onRefresh});
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

    final sw = context.sw;
    // For wide screens use a 2-column grid, otherwise single column list
    if (sw > 720) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(
            context.sp(14),
            context.sp(10),
            context.sp(14),
            context.sp(32),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.sp(12),
            mainAxisSpacing: context.sp(12),
            childAspectRatio: 1.6,
          ),
          itemCount: cases.length,
          itemBuilder: (context, i) => InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => PatientConsultationChatScreen(
                    consultationId: cases[i].consultationId,
                    doctorName: cases[i].doctorName,
                    doctorSpeciality: cases[i].doctorSpeciality,
                    isEmergency: cases[i].type == 'emergency',
                    isDoctor: false,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: _CaseCard(caseModel: cases[i]),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          context.sp(14),
          context.sp(10),
          context.sp(14),
          context.sp(32),
        ),
        itemCount: cases.length,
        itemBuilder: (context, i) => InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => PatientConsultationChatScreen(
                  consultationId: cases[i].consultationId,
                  doctorName: cases[i].doctorName,
                  doctorSpeciality: cases[i].doctorSpeciality,
                  isEmergency: cases[i].type == 'emergency',
                  isDoctor: false,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: _CaseCard(caseModel: cases[i]),
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final _PatientCase caseModel;
  const _CaseCard({required this.caseModel});

  Color get _typeColor => caseModel.type == 'emergency' ? kEmergency : kNormal;
  IconData get _typeIcon => caseModel.type == 'emergency'
      ? Icons.local_hospital_rounded
      : Icons.healing_rounded;
  String get _typeLabel =>
      caseModel.type == 'emergency' ? 'Emergency' : 'Normal';

  @override
  Widget build(BuildContext context) {
    final dt = caseModel.date;
    final date =
        '${dt.day.toString().padLeft(2, '0')} ${_monthShort(dt.month)} ${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: context.sp(13)),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0B38),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                caseModel.consultationId,
                                style: GoogleFonts.oswald(
                                  fontSize: context.sp(11.5),
                                  letterSpacing: 1.5,
                                  color: kWhite.withOpacity(0.38),
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
                        Text(
                          'Dr. ${caseModel.doctorName.isNotEmpty ? caseModel.doctorName : '—'}',
                          style: GoogleFonts.poppins(
                            fontSize: context.sp(16.5),
                            fontWeight: FontWeight.w600,
                            color: kWhite,
                          ),
                        ),
                        SizedBox(height: context.sp(6)),
                        Text(
                          caseModel.problem.isNotEmpty
                              ? caseModel.problem
                              : (caseModel.doctorNotes.isNotEmpty
                                    ? caseModel.doctorNotes
                                    : 'No details'),
                          style: GoogleFonts.manrope(
                            fontSize: context.sp(12.5),
                            color: kWhite.withOpacity(0.58),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.sp(12)),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: context.sp(12),
                              color: kWhite.withOpacity(0.35),
                            ),
                            SizedBox(width: context.sp(5)),
                            Flexible(
                              child: Text(
                                date,
                                style: GoogleFonts.inter(
                                  fontSize: context.sp(11.5),
                                  color: kWhite.withOpacity(0.45),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: context.sp(12)),
                            Icon(
                              Icons.access_time_rounded,
                              size: context.sp(12),
                              color: kWhite.withOpacity(0.35),
                            ),
                            SizedBox(width: context.sp(5)),
                            Flexible(
                              child: Text(
                                time,
                                style: GoogleFonts.inter(
                                  fontSize: context.sp(11.5),
                                  color: kWhite.withOpacity(0.45),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.sp(12)),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.sw * 0.28,
                      minWidth: context.sp(64),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusChip(
                          status: caseModel.status == 'responded'
                              ? 'Resolved'
                              : 'Unresolved',
                        ),
                        SizedBox(height: context.sp(10)),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: kWhite.withOpacity(0.35),
                          size: context.sp(22),
                        ),
                      ],
                    ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  Color get _color =>
      status == 'Resolved' ? const Color(0xFF00D4AA) : const Color(0xFFFFC857);
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

String _monthShort(int m) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[(m - 1).clamp(0, 11)];
}


