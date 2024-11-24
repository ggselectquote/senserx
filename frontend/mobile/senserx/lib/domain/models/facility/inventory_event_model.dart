class InventoryEventModel {
  final String eventType;
  final String upc;
  final double quantity;
  final bool isConfirmed;
  final String facilityId;
  final String? shelfId;
  final String? facilityLayoutId;
  final String? timestamp;
  final String? confirmedAt;

  InventoryEventModel({
    required this.eventType,
    required this.upc,
    required this.quantity,
    required this.isConfirmed,
    required this.facilityId,
    required this.shelfId,
    required this.facilityLayoutId,
    this.timestamp,
    this.confirmedAt,
  });

  factory InventoryEventModel.fromJson(Map<String, dynamic> json) {
    return InventoryEventModel(
      eventType: json['eventType'] as String,
      upc: json['upc'] as String,
      quantity: double.parse(json['quantity'].toString()),
      isConfirmed: json['isConfirmed'] as bool,
      facilityId: json['facilityId'] ,
      shelfId: json['shelfId'],
      facilityLayoutId: json['facilityLayoutId'],
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int).toIso8601String()
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['confirmedAt'] as int).toIso8601String()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'upc': upc,
      'quantity': quantity,
      'isConfirmed': isConfirmed,
      'shelfId': shelfId,
      'facilityLayoutId': facilityLayoutId,
      'facilityId': facilityId,
      'timestamp': timestamp,
      'confirmedAt': confirmedAt,
    };
  }

  List<Object?> get props => [
    eventType,
    upc,
    quantity,
    isConfirmed,
    facilityId,
    shelfId,
    facilityLayoutId,
    timestamp,
    confirmedAt,
  ];
}