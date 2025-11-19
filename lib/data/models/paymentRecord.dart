import 'package:cconnect/utils/constraints/enums.dart';
import 'package:flutter/foundation.dart';

class PaymentRecord {
  final String id;
  final String payerId;
  final String payeeId;
  final double amount;
  final String currency;
  final String description;
  final PaymentStatus status;
  final DateTime createdAt;

  PaymentRecord({
    required this.id,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    this.currency = 'USD',
    this.description = '',
    this.status = PaymentStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    id: json['id'],
    payerId: json['payerId'],
    payeeId: json['payeeId'],
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] ?? 'USD',
    description: json['description'] ?? '',
    status: _statusFromString(json['status'] as String?),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'payerId': payerId,
    'payeeId': payeeId,
    'amount': amount,
    'currency': currency,
    'description': description,
    'status': describeEnum(status),
    'createdAt': createdAt.toIso8601String(),
  };

  static PaymentStatus _statusFromString(String? s) {
    if (s == null) return PaymentStatus.pending;
    return PaymentStatus.values.firstWhere(
      (p) => describeEnum(p) == s,
      orElse: () => PaymentStatus.pending,
    );
  }
}
