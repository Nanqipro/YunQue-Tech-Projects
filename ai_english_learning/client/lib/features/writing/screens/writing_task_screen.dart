import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/writing_task.dart';
import '../models/writing_submission.dart';
import '../providers/writing_provider.dart';

class WritingTaskScreen extends StatefulWidget {
  final WritingTask task;

  const WritingTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<WritingTaskScreen> createState() => _WritingTaskScreenState();
}

class _WritingTaskScreenState extends State<WritingTaskScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isSubmitting = false;
  bool _showInstructions = true;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _contentController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      
      // 检查时间限制
      if (widget.task.timeLimit != null && 
          _elapsedSeconds >= widget.task.timeLimit! * 60) {
        _showTimeUpDialog();
      }
    });
  }

  void _updateWordCount() {
    final text = _contentController.text;
    final words = text.trim().split(RegExp(r'\s+'));
    setState(() {
      _wordCount = text.trim().isEmpty ? 0 : words.length;
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('时间到！'),
        content: const Text('写作时间已结束，请提交您的作品。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitWriting();
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWriting() async {
    if (_isSubmitting) return;
    
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入写作内容')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<WritingProvider>(context, listen: false);
      // 首先开始任务（如果还没有开始）
      if (provider.currentSubmission == null) {
        await provider.startTask(widget.task.id);
      }
      // 更新内容
      provider.updateContent(content);
      provider.updateTimeSpent(_elapsedSeconds);
      // 提交写作
      final success = await provider.submitWriting();
      
      if (mounted && success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('写作已提交，正在批改中...')),
        );
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交失败，请重试')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          IconButton(
            icon: Icon(_showInstructions ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showInstructions = !_showInstructions;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 20,
                  color: _getTimeColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_elapsedSeconds),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getTimeColor(),
                  ),
                ),
                if (widget.task.timeLimit != null)
                  Text(
                    ' / ${widget.task.timeLimit}分钟',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const Spacer(),
                Icon(
                  Icons.text_fields,
                  size: 20,
                  color: _getWordCountColor(_wordCount),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_wordCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getWordCountColor(_wordCount),
                  ),
                ),
                if (widget.task.wordLimit != null)
                  Text(
                    ' / ${widget.task.wordLimit}字',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),
          
          // 任务说明
          if (_showInstructions)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '任务要求',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.task.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (widget.task.requirements.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '具体要求:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...widget.task.requirements.map((req) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 2),
                      child: Text(
                        '• $req',
                        style: const TextStyle(fontSize: 13),
                      ),
                    )).toList(),
                  ],
                  if (widget.task.keywords.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '关键词:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: widget.task.keywords.map((keyword) => Chip(
                        label: Text(
                          keyword,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue[100],
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],
                  if (widget.task.prompt != null && widget.task.prompt!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '提示:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 2),
                      child: Text(
                        '💡 ${widget.task.prompt}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // 写作区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: '请在此处开始写作...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('保存草稿'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitWriting,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('提交'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimeColor() {
    if (widget.task.timeLimit == null) return Colors.blue;
    final remainingMinutes = (widget.task.timeLimit! * 60 - _elapsedSeconds) / 60;
    if (remainingMinutes <= 5) return Colors.red;
    if (remainingMinutes <= 10) return Colors.orange;
    return Colors.blue;
  }

  Color _getWordCountColor(int wordCount) {
    if (widget.task.wordLimit == null) return Colors.green;
    final ratio = wordCount / widget.task.wordLimit!;
    if (ratio > 1.1) return Colors.red;
    if (ratio > 0.9) return Colors.green;
    if (ratio > 0.5) return Colors.orange;
    return Colors.grey;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写作帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '写作技巧:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 仔细阅读任务要求，确保理解题意'),
              Text('• 合理安排时间，留出检查和修改的时间'),
              Text('• 注意文章结构，包括开头、主体和结尾'),
              Text('• 使用多样化的词汇和句式'),
              Text('• 检查语法、拼写和标点符号'),
              SizedBox(height: 12),
              Text(
                '评分标准:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 内容相关性和完整性'),
              Text('• 语言准确性和流畅性'),
              Text('• 词汇丰富度和语法复杂性'),
              Text('• 文章结构和逻辑性'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}