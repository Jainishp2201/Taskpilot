import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/request_model.dart';

class StatusChip extends StatelessWidget {
  final RequestStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case RequestStatus.pending: color = const Color(0xFFE8960A); break;
      case RequestStatus.accepted: color = Theme.of(context).primaryColor; break;
      case RequestStatus.completed: color = const Color(0xFF10B981); break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
