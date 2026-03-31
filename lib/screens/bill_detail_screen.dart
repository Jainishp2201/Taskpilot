import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/task_provider.dart';
import '../models/bill_model.dart';
import '../widgets/clay_container.dart';
import '../utils/toast_utils.dart';

class BillDetailScreen extends StatefulWidget {
  final String billId;
  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  final _amountController = TextEditingController();
  final _kasarController = TextEditingController();
  final _collectedController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _kasarController.dispose();
    _collectedController.dispose();
    super.dispose();
  }

  void _shareReceipt(BillModel bill) {
    final netAmount = bill.amount - bill.kasar;
    final text = "Payment Receipt\n"
        "--------------------------\n"
        "Party: ${bill.partyName}\n"
        "Bill Amount: ₹${bill.amount}\n"
        "Discount (Kasar): ₹${bill.kasar}\n"
        "Net Payable: ₹$netAmount\n"
        "Collected: ₹${bill.collectedAmount}\n"
        "Status: ${bill.status.name.toUpperCase()}\n"
        "--------------------------\n"
        "Thank you!";
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    
    final int billIndex = taskProvider.bills.indexWhere((b) => b.id == widget.billId);
    if (billIndex == -1) {
      return Scaffold(appBar: AppBar(title: const Text("Not Found")), body: const Center(child: Text("Bill not found")));
    }
    final bill = taskProvider.bills[billIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Payment Details", style: GoogleFonts.poppins(fontWeight: FontWeight.w300, color: const Color(0xFF1F2937))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF374151)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF4B5563)),
            onPressed: () => _shareReceipt(bill),
            tooltip: "Share Receipt",
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bill.partyName, style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937), letterSpacing: -1.0)),
              const SizedBox(height: 8),
              Text("Bill ID: ${bill.id}", style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w300)),
              const SizedBox(height: 40),
              
              ClayContainer(
                depth: 6,
                padding: const EdgeInsets.all(32),
                borderRadius: 30,
                child: Column(
                  children: [
                    _rowItem("Bill Amount", "₹${bill.amount}", size: 20),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: Divider(color: const Color(0xFFE5E7EB), thickness: 1)),
                    _rowItem("Discount Applied", "₹${bill.kasar}", color: const Color(0xFF10B981)),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: Divider(color: const Color(0xFFE5E7EB), thickness: 1)),
                    _rowItem("Status", bill.status.name.toUpperCase(), color: _getStatusColor(bill.status)),
                  ],
                ),
              ),
              
              const SizedBox(height: 56),
              if (bill.status == BillStatus.pending) ...[
                Text("Process Collection", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937), letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text("Enter the amounts to record this payment.", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w300, color: const Color(0xFF6B7280))),
                const SizedBox(height: 32),
                ClayContainer(
                  depth: 6,
                  padding: const EdgeInsets.all(28),
                  borderRadius: 30,
                  child: Column(
                    children: [
                      _buildInputRow("Total Bill Amount", _amountController),
                      const SizedBox(height: 28),
                      _buildInputRow("Discount (Kasar)", _kasarController),
                      const SizedBox(height: 28),
                      _buildInputRow("Cash Collected", _collectedController, isAccent: true),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    final kasar = double.tryParse(_kasarController.text) ?? 0;
                    final collected = double.tryParse(_collectedController.text) ?? 0;

                    if (amount <= 0 || collected <= 0) {
                      ToastUtils.showCustomToast(context, "Amount and collected values are required", isError: true);
                      return;
                    }

                    taskProvider.updateBillStatus(
                        bill.id,
                        BillStatus.taken,
                        amount: amount,
                        kasar: kasar,
                        collected: collected
                    );
                    
                    Navigator.pop(context);
                    ToastUtils.showCustomToast(context, "Payment recorded successfully!");
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
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          offset: const Offset(0, 12),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text("MARK TAKEN & COLLECT", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 48),
              ],
              if (bill.status == BillStatus.taken || bill.status == BillStatus.accepted) 
                ClayContainer(
                  depth: 4,
                  color: const Color(0xFF10B981),
                  padding: const EdgeInsets.all(40),
                  borderRadius: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 72),
                      const SizedBox(height: 24),
                      Text("Payment Collected", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: 26, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text("Total Received: ₹${bill.collectedAmount}", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 18, fontWeight: FontWeight.w300)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.pending: return const Color(0xFFE8960A);
      case BillStatus.taken: return Theme.of(context).primaryColor;
      case BillStatus.accepted: return const Color(0xFF10B981);
    }
  }

  Widget _buildInputRow(String label, TextEditingController controller, {bool isAccent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: isAccent ? Theme.of(context).primaryColor : const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD1D9E6).withOpacity(0.5),
                offset: const Offset(0, 8),
                blurRadius: 16,
              )
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 20, color: const Color(0xFF374151)),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle: GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: 20, color: const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowItem(String label, String value, {bool isBold = false, double size = 16, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontWeight: FontWeight.w300, fontSize: 15)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: size, color: color ?? const Color(0xFF374151))),
      ],
    );
  }
}
