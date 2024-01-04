class Invoice {
  final String id;
  final String patient_id;
  final String dateof;
  final String amount;
  final String message;

  Invoice(
      {required this.id,
      required this.patient_id,
      required this.dateof,
      required this.amount,
      required this.message});

  Invoice copyWith({
    String? id,
    String? patient_id,
    String? dateof,
    String? amount,
    String? message,
  }) {
    return Invoice(
      id: id ?? this.id,
      patient_id: patient_id ?? this.patient_id,
      dateof: dateof ?? this.dateof,
      amount: amount ?? this.amount,
      message: message ?? this.message,
    );
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as String,
      patient_id: map['patient_id'] as String,
      dateof: map['dateof'] as String,
      amount: map['amount'] as String,
      message: map['message'] as String,
    );
  }
}

class InvoiceListModel {
  int? success;
  List<Invoice>? data;
  InvoiceListModel({this.success, this.data});

  InvoiceListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Invoice>[];
      json['data'].forEach((v) {
        data!.add(Invoice.fromMap(v));
      });
    }
  }
}
