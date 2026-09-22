import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/widgets/status_badge.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onTap;

  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (request.priority) {
      case RequestPriority.high:
        priorityColor = Colors.red.shade600;
        break;
      case RequestPriority.medium:
        priorityColor = Colors.amber.shade700;
        break;
      case RequestPriority.low:
        priorityColor = Colors.blue.shade600;
        break;
    }

    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.requestNumber,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          request.priority.toDbString().toUpperCase(),
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: request.status, isDense: true),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                request.serviceName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.serviceAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(request.preferredDateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  if (request.agentName != null)
                    Row(
                      children: [
                        const Icon(Icons.engineering_outlined, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(
                          request.agentName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
