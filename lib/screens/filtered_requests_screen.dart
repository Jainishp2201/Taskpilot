import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/request_model.dart';
import '../widgets/status_chip.dart';
import '../widgets/clay_container.dart';
import 'request_detail_screen.dart';

class FilteredRequestsScreen extends StatelessWidget {
  final RequestStatus? statusFilter;
  final String title;
  final String heroTag;

  const FilteredRequestsScreen({
    super.key,
    required this.statusFilter,
    required this.title,
    required this.heroTag,
  });

  Color _statusAccent(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return const Color(0xFFE89A35);
      case RequestStatus.accepted:
        return const Color(0xFFE8734A);
      case RequestStatus.completed:
        return const Color(0xFF5B9E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final requests = taskProvider.getFilteredRequests(statusFilter);

    return Hero(
      tag: heroTag,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDE8E4),
        appBar: AppBar(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF2D201A),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A3028), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: requests.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                RequestDetailScreen(requestId: req.id),
                            transitionDuration: const Duration(milliseconds: 380),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              final tween = Tween(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeOutCubic));
                              return SlideTransition(
                                  position: animation.drive(tween), child: child);
                            },
                          ),
                        );
                      },
                      child: ClayContainer(
                        depth: 6,
                        padding: EdgeInsets.zero,
                        borderRadius: 28,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 5,
                                decoration: BoxDecoration(
                                  color: _statusAccent(req.status),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    bottomLeft: Radius.circular(28),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(22, 24, 24, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  req.partyName,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                    color: const Color(0xFF2D201A),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat('MMM dd • hh:mm a')
                                                      .format(req.dateTime),
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFFB0A09A),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          StatusChip(status: req.status),
                                        ],
                                      ),
                                      if (req.acceptedBy != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8734A)
                                                .withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.person_outline_rounded,
                                                size: 14,
                                                color: Color(0xFFE8734A),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                req.acceptedBy!,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFFE8734A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFE8734A).withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.coffee_rounded,
              size: 48,
              color: Color(0xFFE8734A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No requests found",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF2D201A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You're all caught up.",
            style: GoogleFonts.poppins(
              color: const Color(0xFF8B7468),
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
