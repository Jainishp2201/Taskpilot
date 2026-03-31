enum RequestStatus { pending, accepted, completed }

class RequestModel {
  final String id;
  final String partyName;
  final String type; // Pick
  final DateTime dateTime;
  final String? note;
  RequestStatus status;
  String? acceptedBy;
  String? photoPath;

  RequestModel({
    required this.id,
    required this.partyName,
    this.type = "Pick",
    required this.dateTime,
    this.note,
    this.status = RequestStatus.pending,
    this.acceptedBy,
    this.photoPath,
  });

  
  RequestModel copyWith({
    RequestStatus? status,
    String? acceptedBy,
    String? photoPath,
  }) {
    return RequestModel(
      id: id,
      partyName: partyName,
      type: type,
      dateTime: dateTime,
      note: note,
      status: status ?? this.status,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
