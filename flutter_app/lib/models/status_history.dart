import 'package:quickserve/models/service_request.dart';

class StatusHistoryItem {
  final String id;
  final String requestId;
  final RequestStatus? previousStatus;
  final RequestStatus newStatus;
  final String changedBy;
  final String? changedByName;
  final String? note;
  final DateTime createdAt;

  StatusHistoryItem({
    required this.id,
    required this.requestId,
    this.previousStatus,
    required this.newStatus,
    required this.changedBy,
    this.changedByName,
    this.note,
    required this.createdAt,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      previousStatus: json['previous_status'] != null
          ? RequestStatus.fromString(json['previous_status'] as String)
          : null,
      newStatus: RequestStatus.fromString(json['new_status'] as String),
      changedBy: json['changed_by'] as String,
      changedByName: json['profiles'] != null ? json['profiles']['full_name'] as String? : null,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
