import 'package:flutter/material.dart';
import 'package:quickserve/models/service_request.dart';
import 'package:quickserve/core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final bool isDense;

  const StatusBadge({
    super.key,
    required this.status,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case RequestStatus.created:
        bg = AppTheme.statusCreated.withOpacity(0.12);
        fg = AppTheme.statusCreated;
        break;
      case RequestStatus.assigned:
        bg = AppTheme.statusAssigned.withOpacity(0.12);
        fg = AppTheme.statusAssigned;
        break;
      case RequestStatus.accepted:
        bg = AppTheme.statusAccepted.withOpacity(0.12);
        fg = AppTheme.statusAccepted;
        break;
      case RequestStatus.inProgress:
        bg = AppTheme.statusInProgress.withOpacity(0.12);
        fg = AppTheme.statusInProgress;
        break;
      case RequestStatus.completed:
        bg = AppTheme.statusCompleted.withOpacity(0.12);
        fg = AppTheme.statusCompleted;
        break;
      case RequestStatus.cancelled:
        bg = AppTheme.statusCancelled.withOpacity(0.12);
        fg = AppTheme.statusCancelled;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDense ? 8 : 10,
        vertical: isDense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: isDense ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
