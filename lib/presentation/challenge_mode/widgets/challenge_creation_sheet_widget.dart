import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
      // Handle challenge creation
      Navigator.pop(context);
      widget.onClose();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Challenge created successfully!"),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  "Create Challenge",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onClose();
                  },
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenge Type
                    Text(
                      "Challenge Type",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: "solo",
                            title: "Solo Challenge",
                            subtitle: "Personal spiritual journey",
                            icon: 'person',
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildTypeCard(
                            type: "group",
                            title: "Group Challenge",
                            subtitle: "Community motivation",
                            icon: 'group',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    // Challenge Title
                    Text(
                      "Challenge Title",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Enter challenge title",
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'title',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a challenge title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),

                    // Description
                    Text(
                      "Description",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Describe your challenge...",
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'description',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),

                    // Dhikr Phrase Selection
                    Text(
                      "Dhikr Phrase",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDhikrPhrase,
                          isExpanded: true,
                          items: dhikrPhrases.map((phrase) {
                            return DropdownMenuItem(
                              value: phrase,
                              child: Text(phrase),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDhikrPhrase = value ?? "SubhanAllah";
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Target and Duration Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Daily Target",
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 1.h),
                              TextFormField(
                                controller: _targetController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "100",
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'flag',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter target';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Enter valid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Duration (Days)",
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.lightTheme.dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedDuration,
                                    isExpanded: true,
                                    items: durations.map((duration) {
                                      return DropdownMenuItem(
                                        value: duration,
                                        child: Text("$duration days"),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDuration = value ?? 7;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    // Difficulty Selection
                    Text(
                      "Difficulty Level",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildDifficultyChip("easy", "Easy", Colors.green),
                        SizedBox(width: 2.w),
                        _buildDifficultyChip("medium", "Medium", Colors.orange),
                        SizedBox(width: 2.w),
                        _buildDifficultyChip("hard", "Hard", Colors.red),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    // Privacy Settings
                    if (_selectedType == "group") ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Private Challenge",
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Switch(
                            value: _isPrivate,
                            onChanged: (value) {
                              setState(() {
                                _isPrivate = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Text(
                        _isPrivate
                            ? "Only invited friends can join"
                            : "Anyone can join this challenge",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onClose();
                    },
                    child: Text("Cancel"),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createChallenge,
                    child: Text("Create Challenge"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                )
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String value, String label, Color color) {
    final isSelected = _selectedDifficulty == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDifficulty = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
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
