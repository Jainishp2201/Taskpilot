enum BillStatus { pending, taken, accepted }

class BillModel {
  final String id;
  final String partyName;
  final double amount;
  final double kasar;
  BillStatus status;
  double? collectedAmount;

  BillModel({
    required this.id,
    required this.partyName,
    required this.amount,
    required this.kasar,
    this.status = BillStatus.pending,
    this.collectedAmount,
  });
}
