import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';

/// 阅读分类标签组件
class ReadingCategoryTabs extends StatelessWidget {
  const ReadingCategoryTabs({super.key});

  static const List<Map<String, String>> categories = [
    {'key': '', 'label': '全部'},
    {'key': 'cet4', 'label': '四级'},
    {'key': 'cet6', 'label': '六级'},
    {'key': 'toefl', 'label': '托福'},
    {'key': 'ielts', 'label': '雅思'},
    {'key': 'daily', 'label': '日常'},
    {'key': 'business', 'label': '商务'},
    {'key': 'academic', 'label': '学术'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Consumer<ReadingProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = provider.selectedCategory == category['key'] ||
                  (provider.selectedCategory == null && category['key'] == '');
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryChip(
                  context,
                  category['label']!,
                  category['key']!,
                  isSelected,
                  provider,
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 构建分类标签
  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String key,
    bool isSelected,
    ReadingProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        final selectedKey = key.isEmpty ? null : key;
        provider.setFilter(category: selectedKey);
        provider.loadArticles(refresh: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 阅读难度筛选组件
class ReadingDifficultyFilter extends StatelessWidget {
  const ReadingDifficultyFilter({super.key});

  static const List<Map<String, String>> difficulties = [
    {'key': '', 'label': '全部难度'},
    {'key': 'a1', 'label': 'A1'},
    {'key': 'a2', 'label': 'A2'},
    {'key': 'b1', 'label': 'B1'},
    {'key': 'b2', 'label': 'B2'},
    {'key': 'c1', 'label': 'C1'},
    {'key': 'c2', 'label': 'C2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Consumer<ReadingProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: difficulties.length,
            itemBuilder: (context, index) {
              final difficulty = difficulties[index];
              final isSelected = provider.selectedDifficulty == difficulty['key'] ||
                  (provider.selectedDifficulty == null && difficulty['key'] == '');
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildDifficultyChip(
                  context,
                  difficulty['label']!,
                  difficulty['key']!,
                  isSelected,
                  provider,
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 构建难度标签
  Widget _buildDifficultyChip(
    BuildContext context,
    String label,
    String key,
    bool isSelected,
    ReadingProvider provider,
  ) {
    final color = _getDifficultyColor(key);
    
    return GestureDetector(
      onTap: () {
        final selectedKey = key.isEmpty ? null : key;
        provider.setFilter(difficulty: selectedKey);
        provider.loadArticles(refresh: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : color,
            fontSize: 14,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 获取难度颜色
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'a1':
      case 'a2':
        return Colors.green;
      case 'b1':
      case 'b2':
        return Colors.orange;
      case 'c1':
      case 'c2':
        return Colors.red;
      default:
        return const Color(0xFF2196F3);
    }
  }
}

/// 组合的分类和难度筛选组件
class ReadingFilterTabs extends StatelessWidget {
  const ReadingFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ReadingCategoryTabs(),
        const ReadingDifficultyFilter(),
      ],
    );
  }
}