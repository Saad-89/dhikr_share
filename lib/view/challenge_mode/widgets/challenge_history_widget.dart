import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ChallengeHistoryWidget extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ChallengeHistoryWidget({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isGroupChallenge = challenge["type"] == "group";
    final completedDate = DateTime.tryParse(challenge["completedDate"] ?? "");
    final formattedDate = completedDate != null
        ? "${completedDate.day}/${completedDate.month}/${completedDate.year}"
        : "Unknown";

    return Card(
      // elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge["title"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("Completed on $formattedDate"),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Achievement badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge["achievement"] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Achievement Unlocked",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  if (isGroupChallenge && challenge["rank"] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getRankColor(challenge["rank"]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "#${challenge["rank"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _buildStatItem(
                  icon: isGroupChallenge ? Icons.group : Icons.person,
                  label: "Type",
                  value: isGroupChallenge ? "Group" : "Solo",
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.schedule,
                  label: "Duration",
                  value: challenge["duration"] ?? "",
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.countertops,
                  label: "Total Dhikr",
                  value: "${challenge["totalDhikr"] ?? 0}",
                ),
              ],
            ),

            if (isGroupChallenge) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.people,
                    label: "Participants",
                    value: "${challenge["participants"] ?? 0}",
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    icon: Icons.leaderboard,
                    label: "Final Rank",
                    value: "#${challenge["rank"] ?? 0}",
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showCertificate(context);
                    },
                    icon: Icon(
                      Icons.file_download,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                    label: const Text("Certificate"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColors.primaryGreen,
                      ),
                    ),
                    onPressed: () {
                      _shareAchievement(context);
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      "Share",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int? rank) {
    if (rank == null) return Colors.grey;
    if (rank <= 3) return Colors.amber;
    if (rank <= 10) return Colors.orange;
    return Colors.grey;
  }

  void _showCertificate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Certificate of Completion",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(challenge["title"] ?? "", textAlign: TextAlign.center),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "This certifies that you have successfully completed the challenge with dedication and spiritual commitment.",
                style: TextStyle(color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Total Dhikr: ${challenge["totalDhikr"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text("Duration: ${challenge["duration"]}"),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Handle download certificate
                      },
                      child: const Text("Download"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAchievement(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Achievement shared successfully!")),
    );
  }
}
