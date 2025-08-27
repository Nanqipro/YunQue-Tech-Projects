import 'package:flutter/material.dart';
import '../models/speaking_scenario.dart';

class SpeakingFilterBar extends StatelessWidget {
  final SpeakingScenario? selectedScenario;
  final SpeakingDifficulty? selectedDifficulty;
  final String sortBy;
  final ValueChanged<SpeakingScenario?> onScenarioChanged;
  final ValueChanged<SpeakingDifficulty?> onDifficultyChanged;
  final ValueChanged<String> onSortChanged;

  const SpeakingFilterBar({
    super.key,
    this.selectedScenario,
    this.selectedDifficulty,
    required this.sortBy,
    required this.onScenarioChanged,
    required this.onDifficultyChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 筛选器行
          Row(
            children: [
              // 场景筛选
              Expanded(
                child: _buildScenarioFilter(context),
              ),
              const SizedBox(width: 12),
              
              // 难度筛选
              Expanded(
                child: _buildDifficultyFilter(context),
              ),
              const SizedBox(width: 12),
              
              // 排序筛选
              Expanded(
                child: _buildSortFilter(context),
              ),
            ],
          ),
          
          // 清除筛选按钮
          if (selectedScenario != null || selectedDifficulty != null || sortBy != 'recommended')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('清除筛选'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScenarioFilter(BuildContext context) {
    return PopupMenuButton<SpeakingScenario?>(
      initialValue: selectedScenario,
      onSelected: onScenarioChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedScenario?.displayName ?? '场景',
                style: TextStyle(
                  fontSize: 12,
                  color: selectedScenario != null ? Colors.black87 : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<SpeakingScenario?>(
          value: null,
          child: Text('全部场景'),
        ),
        ...SpeakingScenario.values.map(
          (scenario) => PopupMenuItem<SpeakingScenario?>(
            value: scenario,
            child: Text(scenario.displayName),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter(BuildContext context) {
    return PopupMenuButton<SpeakingDifficulty?>(
      initialValue: selectedDifficulty,
      onSelected: onDifficultyChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.trending_up,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDifficulty?.displayName ?? '难度',
                style: TextStyle(
                  fontSize: 12,
                  color: selectedDifficulty != null ? Colors.black87 : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<SpeakingDifficulty?>(
          value: null,
          child: Text('全部难度'),
        ),
        ...SpeakingDifficulty.values.map(
          (difficulty) => PopupMenuItem<SpeakingDifficulty?>(
            value: difficulty,
            child: Text(difficulty.displayName),
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilter(BuildContext context) {
    final sortOptions = {
      'recommended': '推荐',
      'difficulty': '难度',
      'duration': '时长',
      'popularity': '热度',
    };

    return PopupMenuButton<String>(
      initialValue: sortBy,
      onSelected: onSortChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sort,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sortOptions[sortBy] ?? '排序',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => sortOptions.entries
          .map(
            (entry) => PopupMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
    );
  }

  void _clearFilters() {
    onScenarioChanged(null);
    onDifficultyChanged(null);
    onSortChanged('recommended');
  }
}