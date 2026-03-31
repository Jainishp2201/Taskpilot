import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/bill_model.dart';

class TaskProvider extends ChangeNotifier {
  final List<RequestModel> _requests = [
    RequestModel(
      id: "R1",
      partyName: "Diamond Traders",
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: RequestStatus.pending,
    ),
    RequestModel(
      id: "R2",
      partyName: "Golden Jewels",
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      status: RequestStatus.accepted,
      acceptedBy: "emp1",
    ),
    RequestModel(
      id: "R3",
      partyName: "Sparkle Co",
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      status: RequestStatus.completed,
      acceptedBy: "emp1",
    ),
  ];

  final List<BillModel> _bills = [
    BillModel(id: "B1", partyName: "Diamond Traders", amount: 15000, kasar: 500),
    BillModel(id: "B2", partyName: "Golden Jewels", amount: 22000, kasar: 1000, status: BillStatus.taken),
  ];

  List<RequestModel> get requests => [..._requests];
  List<BillModel> get bills => [..._bills];

  List<RequestModel> getFilteredRequests(RequestStatus? statusFilter) {
    if (statusFilter == null) return requests;
    return _requests.where((r) => r.status == statusFilter).toList();
  }

  void addRequest(RequestModel request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  void acceptRequest(String requestId, String employeeName) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index].status = RequestStatus.accepted;
      _requests[index].acceptedBy = employeeName;
      notifyListeners();
    }
  }

  void completeRequest(String requestId, String photoPath) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _requests[index];
      req.status = RequestStatus.completed;
      req.photoPath = photoPath;
      
      // Automatically add to Wallet (Bills) when completed
      _bills.insert(0, BillModel(
        id: "B${DateTime.now().millisecondsSinceEpoch}",
        partyName: req.partyName,
        amount: 0.0, // To be filled by employee when taking the bill
        kasar: 0.0,
        status: BillStatus.pending,
      ));
      
      notifyListeners();
    }
  }

  void updateBillStatus(String billId, BillStatus newStatus, {double? collected, double? amount, double? kasar}) {
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      _bills[index].status = newStatus;
      if (collected != null) {
        _bills[index].collectedAmount = collected;
      }
      if (amount != null) {
        _bills[index] = BillModel(
            id: _bills[index].id,
            partyName: _bills[index].partyName,
            amount: amount,
            kasar: kasar ?? _bills[index].kasar,
            status: newStatus,
            collectedAmount: collected ?? _bills[index].collectedAmount,
        );
      }
      notifyListeners();
    }
  }
}
