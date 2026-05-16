class VendorInventoryImage {
  final int id;
  final String imagePath;
  const VendorInventoryImage({required this.id, required this.imagePath});

  factory VendorInventoryImage.fromJson(Map<String, dynamic> json) {
    return VendorInventoryImage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imagePath: (json['image_path'] ?? '').toString(),
    );
  }
}

class VendorInventoryLog {
  final String changeType;
  final int quantityChange;
  final int? quantityBefore;
  final int quantityAfter;
  final String actorName;
  final String createdAt;
  final String? note;
  final String? referenceType;
  final int? referenceId;

  const VendorInventoryLog({
    required this.changeType,
    required this.quantityChange,
    required this.quantityAfter,
    required this.actorName,
    required this.createdAt,
    this.quantityBefore,
    this.note,
    this.referenceType,
    this.referenceId,
  });

  factory VendorInventoryLog.fromJson(Map<String, dynamic> json) {
    return VendorInventoryLog(
      changeType: (json['change_type'] ?? '').toString(),
      quantityChange: (json['quantity_change'] as num?)?.toInt() ?? 0,
      quantityBefore: (json['quantity_before'] as num?)?.toInt(),
      quantityAfter: (json['quantity_after'] as num?)?.toInt() ?? 0,
      actorName: (json['actor_name'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      note: json['note']?.toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: (json['reference_id'] as num?)?.toInt(),
    );
  }
}

class VendorInventoryProduct {
  final int id;
  final String name;
  final int stock;
  final int vendorId;
  final List<VendorInventoryImage> images;
  final List<VendorInventoryLog> inventoryLogs;

  const VendorInventoryProduct({
    required this.id,
    required this.name,
    required this.stock,
    required this.vendorId,
    required this.images,
    required this.inventoryLogs,
  });

  factory VendorInventoryProduct.fromJson(Map<String, dynamic> json) {
    final imgs = (json['images'] as List?) ?? const [];
    final logs = (json['inventory_logs'] as List?) ?? const [];
    return VendorInventoryProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      vendorId: (json['vendor_id'] as num?)?.toInt() ?? 0,
      images: imgs
          .whereType<Map>()
          .map((e) => VendorInventoryImage.fromJson(e.cast<String, dynamic>()))
          .toList(),
      inventoryLogs: logs
          .whereType<Map>()
          .map((e) => VendorInventoryLog.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class VendorInventoryProductLogsResponse {
  final VendorInventoryProduct product;
  final List<VendorInventoryLog> logs;
  const VendorInventoryProductLogsResponse({
    required this.product,
    required this.logs,
  });
}

class VendorInventorySummaryEvent {
  final int id;
  final String actorName;
  final String changeType;
  final int quantityChange;
  final int? quantityBefore;
  final int? quantityAfter;
  final String direction;
  final String time;

  const VendorInventorySummaryEvent({
    required this.id,
    required this.actorName,
    required this.changeType,
    required this.quantityChange,
    required this.direction,
    required this.time,
    this.quantityBefore,
    this.quantityAfter,
  });

  factory VendorInventorySummaryEvent.fromJson(Map<String, dynamic> json) {
    return VendorInventorySummaryEvent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      actorName: (json['actor_name'] ?? '').toString(),
      changeType: (json['change_type'] ?? '').toString(),
      quantityChange: (json['quantity_change'] as num?)?.toInt() ?? 0,
      quantityBefore: (json['quantity_before'] as num?)?.toInt(),
      quantityAfter: (json['quantity_after'] as num?)?.toInt(),
      direction: (json['direction'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
    );
  }
}

