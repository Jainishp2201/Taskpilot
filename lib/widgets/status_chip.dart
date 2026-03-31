import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/request_model.dart';

class StatusChip extends StatelessWidget {
  final RequestStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case RequestStatus.pending:
        color = const Color(0xFFE89A35);
        icon = Icons.access_time_rounded;
        break;
      case RequestStatus.accepted:
        color = Theme.of(context).primaryColor;
        icon = Icons.bolt_rounded;
        break;
      case RequestStatus.completed:
        color = const Color(0xFF5B9E7A);
        icon = Icons.check_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            status.name.toUpperCase(),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
