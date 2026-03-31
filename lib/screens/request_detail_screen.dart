import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/request_model.dart';
import '../widgets/status_chip.dart';
import '../widgets/clay_container.dart';
import '../utils/toast_utils.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleComplete() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClayContainer(
        depth: 4,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        borderRadius: 32,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 24),
              Text("Capture Proof", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937))),
              const SizedBox(height: 28),
              _buildBottomSheetAction(Icons.camera_alt_rounded, "Take Photo", () => _pickImage(ImageSource.camera)),
              const SizedBox(height: 16),
              _buildBottomSheetAction(Icons.photo_library_rounded, "Pick from Gallery", () => _pickImage(ImageSource.gallery)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD1D9E6).withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 20),
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16, color: const Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);

    if (image != null) {
      if (!mounted) return;
      _showConfirmationDialog(image.path);
    }
  }

  void _showConfirmationDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClayContainer(
          depth: 4,
          padding: const EdgeInsets.all(28),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Complete Task", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937))),
              const SizedBox(height: 16),
              Text("Are you sure you want to mark this request as completed with this proof?",
                  style: GoogleFonts.poppins(color: const Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: kIsWeb 
                  ? Image.network(path, height: 160, width: double.infinity, fit: BoxFit.cover)
                  : Image.file(File(path), height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context), 
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text("CANCEL", style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: const Color(0xFF4B5563))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TaskProvider>().completeRequest(widget.requestId, path);
                        Navigator.pop(context);
                        ToastUtils.showCustomToast(context, "Request successfully completed!");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            )
                          ]
                        ),
                        child: Text("CONFIRM", style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final auth = context.read<AuthProvider>();
    final int requestIndex = taskProvider.requests.indexWhere((r) => r.id == widget.requestId);
    if (requestIndex == -1) {
      return Scaffold(appBar: AppBar(title: const Text("Not Found")), body: const Center(child: Text("Request not found")));
    }
    final req = taskProvider.requests[requestIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Task Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w300, color: const Color(0xFF1F2937))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF374151)),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(status: req.status),
                  if (req.acceptedBy != null) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text("Assigned to: ${req.acceptedBy}", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor)),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Text(req.partyName, style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937), letterSpacing: -1.0)),
              const SizedBox(height: 12),
              Text(DateFormat('EEEE, dd MMMM yyyy').format(req.dateTime), style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w300)),
              const SizedBox(height: 4),
              Text(DateFormat('hh:mm a').format(req.dateTime), style: GoogleFonts.poppins(color: const Color(0xFF4B5563), fontSize: 16, fontWeight: FontWeight.w400)),
              const SizedBox(height: 40),
              
              ClayContainer(
                depth: 6,
                borderRadius: 30,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    _detailItem(Icons.local_shipping_rounded, "Type", req.type),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Divider(color: const Color(0xFFE5E7EB), thickness: 2),
                    ),
                    _detailItem(Icons.notes_rounded, "Notes", req.note == null || req.note!.isEmpty ? "No internal notes." : req.note!),
                    if (req.photoPath != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Divider(color: const Color(0xFFE5E7EB), thickness: 2),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, color: const Color(0xFF9CA3AF), size: 24),
                              const SizedBox(width: 16),
                              Text("Proof of Completion", style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: kIsWeb
                              ? Image.network(req.photoPath!, height: 220, width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(req.photoPath!), height: 220, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ],
                      )
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
              if (req.status == RequestStatus.pending) ...[
                GestureDetector(
                  onTap: () {
                    taskProvider.acceptRequest(req.id, auth.user?.username ?? "Employee");
                    ToastUtils.showCustomToast(context, "You accepted the request!");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          offset: const Offset(0, 10),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Text("ACCEPT TASK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 48),
              ],
              if (req.status == RequestStatus.accepted) ...[
                GestureDetector(
                  onTap: _handleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          offset: const Offset(0, 10),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Text("COMPLETE TASK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF9CA3AF), size: 28),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w300)),
              const SizedBox(height: 6),
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 18, color: const Color(0xFF374151))),
            ],
          ),
        ),
      ],
    );
  }
}
