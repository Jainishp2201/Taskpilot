import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/bill_model.dart';
import '../widgets/clay_container.dart';
import 'bill_detail_screen.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  @override
  Widget build(BuildContext context) {
    final bills = context.watch<TaskProvider>().bills;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 120),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => BillDetailScreen(billId: bill.id),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Bill ${bill.id}", style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: const Color(0xFFB0A09A))),
                      _buildBillStatus(bill.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(bill.partyName, style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 20, color: const Color(0xFF2D201A))),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCEBFB8).withOpacity(0.55),
                          offset: const Offset(0, 8),
                          blurRadius: 16,
                        )
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Amount", style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 13, fontWeight: FontWeight.w300)),
                            const SizedBox(height: 4),
                            Text("₹${bill.amount > 0 ? bill.amount : '-'}", style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 18, color: const Color(0xFF2D201A))),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Discount", style: GoogleFonts.poppins(color: const Color(0xFF8B7468), fontSize: 13, fontWeight: FontWeight.w300)),
                            const SizedBox(height: 4),
                            Text("₹${bill.kasar > 0 ? bill.kasar : '-'}", style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 18, color: const Color(0xFF2D201A))),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillStatus(BillStatus status) {
    Color color;
    switch (status) {
      case BillStatus.pending: color = const Color(0xFFE89A35); break;
      case BillStatus.taken: color = Theme.of(context).primaryColor; break;
      case BillStatus.accepted: color = const Color(0xFF5B9E7A); break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.0),
      ),
    );
  }
}
