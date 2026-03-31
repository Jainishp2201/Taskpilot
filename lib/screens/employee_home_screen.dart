import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/request_model.dart';
import '../widgets/status_chip.dart';
import '../widgets/clay_container.dart';
import 'request_detail_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  RequestStatus? _currentFilter;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final requests = taskProvider.getFilteredRequests(_currentFilter);
    final pendingCount = taskProvider.requests.where((r) => r.status == RequestStatus.pending).length;
    final acceptedCount = taskProvider.requests.where((r) => r.status == RequestStatus.accepted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${auth.user?.username ?? 'Employee'}.", 
                  style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937), letterSpacing: -1.0)),
              const SizedBox(height: 8),
              Text("Overview of your field tasks", 
                  style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w300)),
              
              const SizedBox(height: 36),
              
              // New asymmetrical stats layout
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildStatCard("Pending Tasks", pendingCount, const Color(0xFFE8960A)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildStatCard("Active", acceptedCount, Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        _buildFilterBar(),
        
        Expanded(
          child: requests.isEmpty 
            ? _buildEmptyState() 
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => RequestDetailScreen(requestId: req.id),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var curve = Curves.easeOutCirc;
                              var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: curve));
                              return SlideTransition(position: animation.drive(tween), child: child);
                            },
                          )
                        );
                      },
                      child: ClayContainer(
                        depth: 6,
                        padding: const EdgeInsets.all(28),
                        borderRadius: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(req.partyName, 
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 20, color: const Color(0xFF1F2937))),
                                      const SizedBox(height: 4),
                                      Text(DateFormat('MMM dd • hh:mm a').format(req.dateTime), 
                                        style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w300)),
                                    ],
                                  ),
                                ),
                                StatusChip(status: req.status),
                              ],
                            ),
                            if (req.acceptedBy != null) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white, 
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD1D9E6).withOpacity(0.5),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 18, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 8),
                                      Text(req.acceptedBy!, 
                                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor)),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return ClayContainer(
      depth: 4,
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count.toString(), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w300, color: color, height: 1.0)),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.coffee_rounded, size: 80, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 20),
          Text("No requests found", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w300, color: const Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text("You're all caught up.", style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _filterChip("All", null),
          _filterChip("Pending", RequestStatus.pending),
          _filterChip("Active", RequestStatus.accepted),
          _filterChip("Completed", RequestStatus.completed),
        ],
      ),
    );
  }

  Widget _filterChip(String label, RequestStatus? status) {
    bool isSelected = _currentFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _currentFilter = status;
          });
        },
        backgroundColor: Colors.transparent,
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSelected ? BorderSide.none : const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        labelStyle: GoogleFonts.poppins(
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
          fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
        ),
      ),
    );
  }
}
