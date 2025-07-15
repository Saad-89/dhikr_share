import 'package:flutter/material.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';

class SyncContactsButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const SyncContactsButton({
    super.key,
    this.text = 'Sync Contacts',
    this.icon = Icons.contacts, // You can use a custom icon if needed
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0E6), // Light background
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blueGrey),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
