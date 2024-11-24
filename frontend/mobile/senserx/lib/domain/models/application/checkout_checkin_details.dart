import 'package:senserx/domain/enums/operation_mode.dart';

class CheckoutCheckinDetails {
  final double quantity;
  final String upc;
  final OperationMode mode;

  CheckoutCheckinDetails({
    required this.quantity,
    required this.upc,
    required this.mode,
  });

  factory CheckoutCheckinDetails.fromJson(Map<String, dynamic> json) {
    return CheckoutCheckinDetails(
      quantity: json['quantity'] ?? 0.0,
      upc: json['upc'],
      mode: json['mode']
    );
  }

  @override
  String toString() {
    return '''
    CheckoutCheckinDetails {
      quantity: $quantity,
      upc: $upc,
      mode: $mode
    ''';
  }
}