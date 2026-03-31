import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/request_model.dart';
import '../widgets/clay_container.dart';
import '../widgets/status_chip.dart';
import '../utils/toast_utils.dart';
import 'login_screen.dart';

class PartyHomeScreen extends StatefulWidget {
  const PartyHomeScreen({super.key});

  @override
  State<PartyHomeScreen> createState() => _PartyHomeScreenState();
}

class _PartyHomeScreenState extends State<PartyHomeScreen> {
  final _noteController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submitRequest() {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    final newRequest = RequestModel(
      id: "R${DateTime.now().millisecondsSinceEpoch}",
      partyName: auth.user?.username ?? "Party",
      type: "Pick",
      dateTime: _selectedDateTime,
      note: _noteController.text.trim(),
    );

    taskProvider.addRequest(newRequest);
    _noteController.clear();
    setState(() {
      _selectedDateTime = DateTime.now();
    });

    ToastUtils.showCustomToast(context, "New pickup request scheduled!");
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final requests = context.watch<TaskProvider>().requests.where((r) => r.partyName == auth.user?.username).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Schedule", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w300, color: const Color(0xFF2D201A))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF5C4A40)),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var curve = Curves.easeOutCirc;
                    var tween = Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: curve));
                    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                    return Opacity(
                      opacity: animation.drive(fadeTween).value,
                      child: Transform.scale(
                        scale: animation.drive(tween).value,
                        child: child,
                      ),
                    );
                  },
                )
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Create a Pickup", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w300, color: const Color(0xFF2D201A), letterSpacing: -1.0)),
              const SizedBox(height: 8),
              Text("Request a new pickup from your location.", style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 16, fontWeight: FontWeight.w300)),
              const SizedBox(height: 36),
              
              ClayContainer(
                depth: 6,
                padding: const EdgeInsets.all(28),
                borderRadius: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReadOnlyField("Business Name", auth.user?.username ?? ""),
                    const SizedBox(height: 24),
                    Text("Schedule Time", style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 13, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFCEBFB8).withOpacity(0.55), offset: const Offset(0, 8), blurRadius: 16)
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMM yyyy \n hh:mm a').format(_selectedDateTime), 
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16, color: const Color(0xFF2D201A))),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                              child: Icon(Icons.access_time_rounded, size: 24, color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text("Instructions", style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 13, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFD1D9E6).withOpacity(0.5), offset: const Offset(0, 8), blurRadius: 16)
                        ],
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: const Color(0xFF2D201A), fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Add specific details...",
                          hintStyle: GoogleFonts.poppins(color: const Color(0xFFB0A09A), fontWeight: FontWeight.w300),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _submitRequest,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.4),
                              offset: const Offset(0, 12),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Text("SCHEDULE", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 2.0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
              Text("Recent Pickups", style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w300, color: const Color(0xFF2D201A))),
              const SizedBox(height: 24),
              
              if (requests.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text("No requests created yet. Schedule your first pickup above!", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontWeight: FontWeight.w300, fontSize: 16)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ClayContainer(
                        depth: 6,
                        borderRadius: 24,
                        padding: const EdgeInsets.all(28),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: Icon(Icons.outbox_rounded, size: 28, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.type.toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16, color: const Color(0xFF2D201A))),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('MMM dd • hh:mm a').format(req.dateTime), style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 14, fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ),
                            StatusChip(status: req.status),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 13, fontWeight: FontWeight.w400)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8E4),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: const Color(0xFFC3B5AC).withOpacity(0.65), blurRadius: 10, offset: const Offset(4, 4)),
              const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-4, -4)),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 16),
              ],
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16, color: const Color(0xFF2D201A))),
            ],
          ),
        ),
      ],
    );
  }
}
