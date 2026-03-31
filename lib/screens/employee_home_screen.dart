import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/request_model.dart';
import '../widgets/clay_container.dart';
import 'filtered_requests_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    
    final pendingCount =
        taskProvider.requests.where((r) => r.status == RequestStatus.pending).length;
    final acceptedCount =
        taskProvider.requests.where((r) => r.status == RequestStatus.accepted).length;
    final completedCount =
        taskProvider.requests.where((r) => r.status == RequestStatus.completed).length;
    final allCount = taskProvider.requests.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
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
                const SizedBox(height: 36),

                // ── Asymmetric Stats Row ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large tall card — Pending
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
                    // Two stacked smaller cards
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

                // ── Broad "All Tasks" Container ──────────────────────────────
                GestureDetector(
                  onTap: () => _openFilteredScreen(
                    context,
                    title: "All Tasks",
                    filter: null,
                  ),
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
                              child: const Icon(Icons.apps_rounded, color: Color(0xFF2D201A), size: 24),
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
                                  "View complete history",
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
                            allCount.toString(),
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
                const SizedBox(height: 120), // Bottom padding for navigation dock
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Stat Card Button ─────────────────────────────────────────────
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool tall,
    required RequestStatus filter,
  }) {
    return GestureDetector(
      onTap: () => _openFilteredScreen(context, title: "$title Tasks", filter: filter),
      child: ClayContainer(
        depth: 4,
        borderRadius: 24,
        padding: EdgeInsets.symmetric(
          vertical: tall ? 32 : 20,
          horizontal: 20,
        ),
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
    );
  }

  // ── Helper: Navigation ──────────────────────────────────────────────────
  void _openFilteredScreen(BuildContext context, {required String title, required RequestStatus? filter}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FilteredRequestsScreen(statusFilter: filter, title: title),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }
}
