import 'package:flutter/material.dart';
import 'package:quickserve/models/service_item.dart';

class ServiceTile extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'wind':
        return Icons.air;
      case 'droplet':
        return Icons.water_drop_outlined;
      case 'zap':
        return Icons.bolt;
      case 'sparkles':
        return Icons.auto_awesome;
      default:
        return Icons.build_outlined;
    }
  }

  Color _getColor(String code) {
    switch (code) {
      case 'ac_servicing':
        return const Color(0xFF0284C7);
      case 'plumbing':
        return const Color(0xFF0D9488);
      case 'electrical':
        return const Color(0xFFD97706);
      case 'cleaning':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(service.code);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(service.iconName),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Starting at \$${service.basePrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 13, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 3),
                            Text(
                              '~${service.estimatedHours} hrs',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
