import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speaking_provider.dart';

class SpeakingResultScreen extends StatefulWidget {
  final Map<String, dynamic> evaluation;
  final String conversationId;

  const SpeakingResultScreen({
    super.key,
    required this.evaluation,
    required this.conversationId,
  });

  @override
  State<SpeakingResultScreen> createState() => _SpeakingResultScreenState();
}

class _SpeakingResultScreenState extends State<SpeakingResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResult,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总分卡片
          _buildOverallScoreCard(),
          const SizedBox(height: 20),
          
          // 详细评分
          _buildDetailedScores(),
          const SizedBox(height: 20),
          
          // 反馈和建议
          _buildFeedbackSection(),
          const SizedBox(height: 20),
          
          // 进步对比
          _buildProgressComparison(),
          const SizedBox(height: 20),
          
          // 录音回放
          _buildAudioPlayback(),
          const SizedBox(height: 100), // 为底部按钮留空间
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(widget.evaluation['overallScore'] as double? ?? 0.0),
            _getScoreColor(widget.evaluation['overallScore'] as double? ?? 0.0).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(widget.evaluation['overallScore'] as double? ?? 0.0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '总体评分',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(widget.evaluation['overallScore'] as double? ?? 0.0).toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreLevel(widget.evaluation['overallScore'] as double? ?? 0.0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getScoreIcon(widget.evaluation['overallScore'] as double? ?? 0.0),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getScoreMessage(widget.evaluation['overallScore'] as double? ?? 0.0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScores() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '详细评分',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showDetails = !_showDetails;
                  });
                },
                child: Text(
                  _showDetails ? '收起' : '展开',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(widget.evaluation['criteriaScores'] as Map<String, double>? ?? {}).entries.map(
            (entry) => _buildScoreItem(
              _getCriteriaDisplayName(entry.key.toString()),
              entry.value,
            ),
          ),
          if (_showDetails) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailedAnalysis(),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreItem(String title, double score) {
    final percentage = score / 100;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${score.toStringAsFixed(1)}分',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '详细分析',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if ((widget.evaluation['strengths'] as List<String>? ?? []).isNotEmpty) ...[
          _buildAnalysisSection(
            '表现优秀',
            widget.evaluation['strengths'] as List<String>? ?? [],
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(height: 12),
        ],
        if ((widget.evaluation['weaknesses'] as List<String>? ?? []).isNotEmpty) ...[
          _buildAnalysisSection(
            '需要改进',
            widget.evaluation['weaknesses'] as List<String>? ?? [],
            Colors.orange,
            Icons.warning,
          ),
          const SizedBox(height: 12),
        ],
        if ((widget.evaluation['commonErrors'] as List<String>? ?? []).isNotEmpty)
          _buildAnalysisSection(
            '常见错误',
            widget.evaluation['commonErrors'] as List<String>? ?? [],
            Colors.red,
            Icons.error,
          ),
      ],
    );
  }

  Widget _buildAnalysisSection(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '改进建议',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if ((widget.evaluation['suggestions'] as List<String>? ?? []).isNotEmpty)
            ...(widget.evaluation['suggestions'] as List<String>? ?? []).map(
              (suggestion) => _buildSuggestionItem(suggestion),
            )
          else
            const Text(
              '表现很好，继续保持！',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressComparison() {
    return Consumer<SpeakingProvider>(
      builder: (context, provider, child) {
        final previousScore = _getPreviousScore(provider);
        if (previousScore == null) {
          return const SizedBox.shrink();
        }
        
        final improvement = (widget.evaluation['overallScore'] as double? ?? 0.0) - previousScore;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '进步对比',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildComparisonItem(
                      '上次得分',
                      previousScore.toStringAsFixed(1),
                      Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildComparisonItem(
                      '本次得分',
                      (widget.evaluation['overallScore'] as double? ?? 0.0).toStringAsFixed(1),
                      _getScoreColor(widget.evaluation['overallScore'] as double? ?? 0.0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildComparisonItem(
                      '进步幅度',
                      '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}',
                      improvement >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAudioPlayback() {
    if (widget.evaluation['audioUrl'] == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '录音回放',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _playAudio,
                icon: const Icon(Icons.play_arrow),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '点击播放你的录音',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '时长: ${_formatDuration(Duration(seconds: widget.evaluation['duration'] as int? ?? 0))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _downloadAudio,
                icon: const Icon(Icons.download),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _practiceAgain,
              child: const Text('再次练习'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _continueNext,
              child: const Text('继续下一个'),
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLevel(double score) {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '一般';
    return '需要改进';
  }

  IconData _getScoreIcon(double score) {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 80) return Icons.thumb_up;
    if (score >= 70) return Icons.trending_up;
    return Icons.trending_down;
  }

  String _getScoreMessage(double score) {
    if (score >= 90) return '表现出色！';
    if (score >= 80) return '表现良好！';
    if (score >= 70) return '继续努力！';
    return '需要更多练习';
  }

  String _getCriteriaDisplayName(String criteria) {
    const criteriaNames = {
      'pronunciation': '发音',
      'fluency': '流利度',
      'grammar': '语法',
      'vocabulary': '词汇',
      'comprehension': '理解力',
    };
    return criteriaNames[criteria] ?? criteria;
  }

  double? _getPreviousScore(SpeakingProvider provider) {
    // 简化实现，实际应该从历史记录中获取
    return 75.0;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _shareResult() {
    // 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中...')),
    );
  }

  void _playAudio() {
    // 实现音频播放
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('播放录音...')),
    );
  }

  void _downloadAudio() {
    // 实现音频下载
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('下载录音...')),
    );
  }

  void _practiceAgain() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _continueNext() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    // 可以导航到下一个练习
  }
}