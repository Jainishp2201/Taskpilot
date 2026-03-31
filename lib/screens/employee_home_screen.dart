import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/request_model.dart';
import '../widgets/clay_container.dart';
import '../widgets/status_chip.dart';
import 'filtered_requests_screen.dart';
import 'request_detail_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  bool _isAllTasksExpanded = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    
    final pendingCount = taskProvider.requests.where((r) => r.status == RequestStatus.pending).length;
    final acceptedCount = taskProvider.requests.where((r) => r.status == RequestStatus.accepted).length;
    final completedCount = taskProvider.requests.where((r) => r.status == RequestStatus.completed).length;
    final allRequests = taskProvider.requests;

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────────
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isAllTasksExpanded ? 0.0 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 56, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello,",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF8B7468),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "${auth.user?.username ?? 'Employee'}.",
                        style: GoogleFonts.poppins(
                          fontSize: 38,
                          fontWeight: FontWeight.w200,
                          color: const Color(0xFF2D201A),
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Main Content Area ──────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.only(top: _isAllTasksExpanded ? -100 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    // The 3 Status Cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildStatCard(
                            context,
                            title: "Pending",
                            count: pendingCount,
                            color: const Color(0xFFE89A35),
                            icon: Icons.access_time_rounded,
                            tall: true,
                            filter: RequestStatus.pending,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildStatCard(
                                context,
                                title: "Active",
                                count: acceptedCount,
                                color: const Color(0xFFE8734A),
                                icon: Icons.bolt_rounded,
                                tall: false,
                                filter: RequestStatus.accepted,
                              ),
                              const SizedBox(height: 14),
                              _buildStatCard(
                                context,
                                title: "Done",
                                count: completedCount,
                                color: const Color(0xFF5B9E7A),
                                icon: Icons.check_circle_outline_rounded,
                                tall: false,
                                filter: RequestStatus.completed,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── "All Tasks" Broad Container ──────────────────────────────
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllTasksExpanded = !_isAllTasksExpanded;
                        });
                      },
                      child: ClayContainer(
                        depth: 6,
                        borderRadius: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D201A).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _isAllTasksExpanded ? Icons.close_rounded : Icons.apps_rounded,
                                    color: const Color(0xFF2D201A),
                                    size: 24
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "All Tasks",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF2D201A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isAllTasksExpanded ? "Tap to close list" : "View complete history",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13,
                                        color: const Color(0xFF8B7468),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D201A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                allRequests.length.toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── The Inline Expandable List ───────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: _isAllTasksExpanded
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: allRequests.map((req) => _buildListItem(context, req)).toList(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool tall,
    required RequestStatus filter,
  }) {
    final String heroTag = 'hero_${title.toLowerCase()}';
    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, anim, second) => FilteredRequestsScreen(
                statusFilter: filter,
                title: "$title Tasks",
                heroTag: heroTag,
              ),
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: ClayContainer(
          depth: 4,
          borderRadius: 24,
          padding: EdgeInsets.symmetric(vertical: tall ? 32 : 20, horizontal: 20),
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: tall ? 22 : 18),
                ),
                SizedBox(height: tall ? 28 : 16),
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: tall ? 44 : 32,
                    fontWeight: FontWeight.w200,
                    color: color,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    fontSize: tall ? 15 : 14,
                    color: const Color(0xFF8B7468),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, RequestModel req) {
    Color statusAccent(RequestStatus status) {
      switch (status) {
        case RequestStatus.pending: return const Color(0xFFE89A35);
        case RequestStatus.accepted: return const Color(0xFFE8734A);
        case RequestStatus.completed: return const Color(0xFF5B9E7A);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, anim, second) => RequestDetailScreen(requestId: req.id),
              transitionDuration: const Duration(milliseconds: 380),
              transitionsBuilder: (context, anim, second, child) {
                return SlideTransition(
                  position: anim.drive(Tween(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
                  child: child,
                );
              },
            ),
          );
        },
        child: ClayContainer(
          depth: 4,
          borderRadius: 24,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: statusAccent(req.status),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(req.partyName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF2D201A))),
                            StatusChip(status: req.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('MMM dd • hh:mm a').format(req.dateTime), style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8B7468))),
                      ],
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
