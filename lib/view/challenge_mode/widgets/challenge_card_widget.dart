import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ChallengeCardWidget extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback onTap;

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroupChallenge = challenge["type"] == "group";
    final difficultyColor = _getDifficultyColor(challenge["difficulty"]);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBadges(
                  isGroupChallenge,
                  difficultyColor,
                  screenWidth,
                ),
                const SizedBox(height: 8),
                _buildChallengeContent(screenWidth),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Image on top-right inside a container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.brown.shade100,
              image: challenge["backgroundImage"] != null
                  ? DecorationImage(
                      image: NetworkImage(challenge["backgroundImage"]),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadges(
    bool isGroupChallenge,
    Color difficultyColor,
    double screenWidth,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isGroupChallenge
                ? AppColors.primaryDarkGreen
                : AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isGroupChallenge ? Icons.group : Icons.person,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isGroupChallenge ? "Group" : "Solo",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: difficultyColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            challenge["difficulty"] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeContent(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge["title"] ?? "",
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth < 600 ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          challenge["description"] ?? "",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: screenWidth < 600 ? 12 : 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            _buildStatChip(Icons.schedule, challenge["estimatedTime"] ?? ""),
            _buildStatChip(Icons.flag, "${challenge["target"]} target"),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primaryDarkGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryDarkGreen,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  challenge["spiritualBenefit"] ?? "",
                  style: TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontSize: screenWidth < 600 ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black87, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
