// ─── Payment Entity ─────────────────────────────────────────────────
// Domain entities for Stripe and Chapa payments.

import 'package:equatable/equatable.dart';

enum PaymentProvider { stripe, chapa }
enum PaymentStatus { pending, succeeded, failed, refunded }

class PaymentEntity extends Equatable {
  final String id;
  final String userId;
  final String? bookingId;
  final PaymentProvider provider;
  final String? externalTransactionId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.provider,
    this.externalTransactionId,
    required this.amount,
    this.currency = 'USD',
    this.status = PaymentStatus.pending,
    required this.createdAt,
  });

  bool get isSuccessful => status == PaymentStatus.succeeded;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;

  @override
  List<Object?> get props => [id, userId, provider, amount, status];
}
