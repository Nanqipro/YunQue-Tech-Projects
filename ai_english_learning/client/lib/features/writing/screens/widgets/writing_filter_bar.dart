import 'package:flutter/material.dart';
import '../../models/writing_task.dart';

class WritingFilterBar extends StatelessWidget {
  final WritingType? selectedType;
  final WritingDifficulty? selectedDifficulty;
  final String? sortBy;
  final bool isAscending;
  final Function(WritingType?) onTypeChanged;
  final Function(WritingDifficulty?) onDifficultyChanged;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;

  const WritingFilterBar({
    super.key,
    this.selectedType,
    this.selectedDifficulty,
    this.sortBy,
    this.isAscending = true,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '筛选条件',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('清除'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeFilter(),
                const SizedBox(width: 12),
                _buildDifficultyFilter(),
                const SizedBox(width: 12),
                _buildSortFilter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
        color: selectedType != null ? Colors.blue[50] : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WritingType?>(
          value: selectedType,
          hint: const Text(
            '类型',
            style: TextStyle(fontSize: 14),
          ),
          isDense: true,
          items: [
            const DropdownMenuItem<WritingType?>(
              value: null,
              child: Text('全部类型'),
            ),
            ...WritingType.values.map((type) {
              return DropdownMenuItem<WritingType?>(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
          ],
          onChanged: onTypeChanged,
        ),
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
        color: selectedDifficulty != null ? Colors.orange[50] : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WritingDifficulty?>(
          value: selectedDifficulty,
          hint: const Text(
            '难度',
            style: TextStyle(fontSize: 14),
          ),
          isDense: true,
          items: [
            const DropdownMenuItem<WritingDifficulty?>(
              value: null,
              child: Text('全部难度'),
            ),
            ...WritingDifficulty.values.map((difficulty) {
              return DropdownMenuItem<WritingDifficulty?>(
                value: difficulty,
                child: Text(difficulty.displayName),
              );
            }).toList(),
          ],
          onChanged: onDifficultyChanged,
        ),
      ),
    );
  }

  Widget _buildSortFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
        color: sortBy != null ? Colors.green[50] : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: sortBy,
          hint: const Text(
            '排序',
            style: TextStyle(fontSize: 14),
          ),
          isDense: true,
          items: const [
            DropdownMenuItem<String>(
              value: 'createdAt',
              child: Text('创建时间'),
            ),
            DropdownMenuItem<String>(
              value: 'difficulty',
              child: Text('难度'),
            ),
            DropdownMenuItem<String>(
              value: 'timeLimit',
              child: Text('时间限制'),
            ),
            DropdownMenuItem<String>(
              value: 'wordLimit',
              child: Text('字数限制'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
        ),
      ),
    );
  }
}