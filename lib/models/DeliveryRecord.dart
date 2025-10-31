class DeliveryRecord {
  final String? id;
  final String robotId;
  final String address;
  final String status;
  final String message;
  final String inventoryIds;
  final String quantity;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  DeliveryRecord({
    this.id,
    required this.robotId,
    required this.address,
    required this.status,
    required this.message,
    required this.inventoryIds,
    required this.quantity,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  // Convert from JSON (API response)
  factory DeliveryRecord.fromJson(Map<String, dynamic> json) {
    return DeliveryRecord(
      id: json['id'],
      robotId: json['robot_id'],
      address: json['address'],
      status: json['status'],
      message: json['message'],
      inventoryIds: json['inventory_ids'],
      quantity: json['quantity'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastUpdatedAt: json['last_updated_at'] != null
          ? DateTime.parse(json['last_updated_at'])
          : null,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    print(inventoryIds);
    return {
      'id': id,
      'robot_id': robotId,
      'address': address,
      'status': status,
      'message': message,
      'inventory_ids': inventoryIds,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
    };
  }
}
