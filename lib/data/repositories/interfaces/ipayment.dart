import 'package:cconnect/data/models/paymentRecord.dart';
import 'package:cconnect/utils/constraints/enums.dart';

abstract class IPaymentRepository {
  Future<PaymentRecord> createPayment(PaymentRecord p);
  Future<PaymentRecord?> getPayment(String id);
  Future<void> updatePaymentStatus(String id, PaymentStatus status);
}
