import 'package:senserx/domain/enums/operation_mode.dart';

class CheckoutCheckinDetails {
  final double quantity;
  final String ndc;
  final OperationMode mode;

  CheckoutCheckinDetails({
    required this.quantity,
    required this.ndc,
    required this.mode,
  });

  factory CheckoutCheckinDetails.fromJson(Map<String, dynamic> json) {
    return CheckoutCheckinDetails(
      quantity: json['quantity'] ?? 0.0,
      ndc: json['ndc'],
      mode: json['mode']
    );
  }

  @override
  String toString() {
    return '''
    CheckoutCheckinDetails {
      quantity: $quantity,
      ndc: $ndc,
      mode: $mode
    ''';
  }
}