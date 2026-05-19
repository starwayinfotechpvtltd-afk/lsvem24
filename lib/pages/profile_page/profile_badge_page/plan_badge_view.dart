import 'package:flutter/material.dart';
import 'package:metube/database/database.dart';
import 'package:get/get.dart';

class PlanBadgeWidget extends StatelessWidget {
  const PlanBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final badge = Database.purchasedPlanBadgeRx.value;

    return _buildBadge(badge);
  }   

  Widget _buildBadge(String badge) {
    switch (badge) {
      case 'Business':
        return _badgeContainer(
          icon: const Icon(
            Icons.check,
            color: Color(0xFF4CAF50),
            size: 16,
          ),
          text: 'Businessman',
          color: const Color(0xFF4CAF50),
        );

      case 'Influencer':
        return _badgeContainer(
          icon: const Icon(
            Icons.check,
            color: Color(0xFF1E88E5),
            size: 16,
          ),
          text: 'Influencer',
          color: const Color(0xFF1E88E5),
        );

      case 'Celebrity':
        return _badgeContainer(
          icon: const Icon(
            Icons.done_all, // WhatsApp-style double check
            color: Color(0xFF1E88E5),
            size: 18,
          ),
          text: 'Celebrity',
          color: const Color(0xFF1E88E5),
        );

      default:
        return _badgeContainer(
          icon: const Icon(
            Icons.check,
            color: Color(0xFF1E88E5),
            size: 16,
          ),
          text: 'Creator',
          color: const Color(0xFF1E88E5),
        );
    }
  }

  Widget _badgeContainer({
    required Widget icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
