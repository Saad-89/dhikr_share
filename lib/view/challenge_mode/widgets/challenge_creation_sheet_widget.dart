import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ChallengeCreationSheetWidget extends StatefulWidget {
  final VoidCallback onClose;

  const ChallengeCreationSheetWidget({super.key, required this.onClose});

  @override
  State<ChallengeCreationSheetWidget> createState() =>
      _ChallengeCreationSheetWidgetState();
}

class _ChallengeCreationSheetWidgetState
    extends State<ChallengeCreationSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedType = "solo";
  String _selectedDifficulty = "medium";
  String _selectedDhikrPhrase = "SubhanAllah";
  int _selectedDuration = 7;
  bool _isPrivate = false;

  final List<String> dhikrPhrases = [
    "SubhanAllah",
    "Alhamdulillah",
    "Allahu Akbar",
    "La ilaha illa Allah",
    "Astaghfirullah",
    "Salawat (Blessings on Prophet)",
    "Custom Dhikr",
  ];

  final List<int> durations = [1, 3, 7, 14, 21, 30, 60, 90];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _createChallenge() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context);
      widget.onClose();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Challenge created successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    "Create Challenge",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onClose();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.primaryDarkGreen,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Challenge Type"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeCard(
                              "solo",
                              "Solo Challenge",
                              "Personal spiritual journey",
                              Icons.person,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTypeCard(
                              "group",
                              "Group Challenge",
                              "Community motivation",
                              Icons.group,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Challenge Title"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _titleController,
                        "Enter challenge title",
                        Icons.title,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Description"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _descriptionController,
                        "Describe your challenge...",
                        Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Dhikr Phrase"),
                      const SizedBox(height: 8),
                      _buildDropdown(_selectedDhikrPhrase, dhikrPhrases, (
                        value,
                      ) {
                        setState(
                          () => _selectedDhikrPhrase = value ?? "SubhanAllah",
                        );
                      }),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Daily Target"),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  _targetController,
                                  "100",
                                  Icons.flag,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Duration (Days)"),
                                const SizedBox(height: 8),
                                _buildDropdown(_selectedDuration, durations, (
                                  value,
                                ) {
                                  setState(
                                    () => _selectedDuration = value ?? 7,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Difficulty Level"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDifficultyChip("easy", "Easy", Colors.green),
                          const SizedBox(width: 8),
                          _buildDifficultyChip(
                            "medium",
                            "Medium",
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildDifficultyChip("hard", "Hard", Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_selectedType == "group") ...[
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Private Challenge",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Switch(
                              value: _isPrivate,
                              onChanged: (value) =>
                                  setState(() => _isPrivate = value),
                            ),
                          ],
                        ),
                        Text(
                          _isPrivate
                              ? "Only invited friends can join"
                              : "Anyone can join this challenge",
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.white, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                        side: WidgetStatePropertyAll(
                          BorderSide(color: AppColors.primaryDarkGreen),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onClose();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          AppColors.primaryGreen,
                        ),
                      ),
                      onPressed: _createChallenge,
                      child: const Text(
                        "Create",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        // prefixIcon: Padding(
        //   padding: const EdgeInsets.all(12),
        //   child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        // ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'This field cannot be empty';
        if (keyboardType == TextInputType.number && int.tryParse(value) == null)
          return 'Enter valid number';
        return null;
      },
    );
  }

  Widget _buildDropdown<T>(T value, List<T> items, ValueChanged<T?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    String type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedType == type;
    final color = isSelected ? AppColors.primaryGreen : AppColors.grey;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String value, String label, Color color) {
    final isSelected = _selectedDifficulty == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
