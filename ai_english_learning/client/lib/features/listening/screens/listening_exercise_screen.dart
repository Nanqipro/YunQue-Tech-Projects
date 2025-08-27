import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listening_exercise_model.dart';
import '../providers/listening_provider.dart';
import '../../../shared/widgets/loading_widget.dart';

/// 听力练习详情页面
class ListeningExerciseScreen extends StatefulWidget {
  final String exerciseId;

  const ListeningExerciseScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  State<ListeningExerciseScreen> createState() => _ListeningExerciseScreenState();
}

class _ListeningExerciseScreenState extends State<ListeningExerciseScreen> {
  bool _showTranscript = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListeningProvider>().startExercise(widget.exerciseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('听力练习'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Consumer<ListeningProvider>(
            builder: (context, provider, child) {
              if (provider.currentExercise == null) return const SizedBox();
              return IconButton(
                icon: Icon(_showTranscript ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _showTranscript = !_showTranscript;
                  });
                },
                tooltip: _showTranscript ? '隐藏文本' : '显示文本',
              );
            },
          ),
        ],
      ),
      body: Consumer<ListeningProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentExercise == null) {
            return const LoadingWidget(message: '加载练习中...');
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.startExercise(widget.exerciseId);
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final exercise = provider.currentExercise;
          if (exercise == null) {
            return const Center(
              child: Text('练习不存在'),
            );
          }

          if (provider.currentResult != null && _isSubmitted) {
            return _buildResultView(provider.currentResult!);
          }

          return Column(
            children: [
              _buildExerciseHeader(exercise),
              _buildAudioPlayer(provider),
              if (_showTranscript) _buildTranscript(exercise),
              Expanded(
                child: _buildQuestionView(provider),
              ),
              _buildBottomControls(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseHeader(ListeningExercise exercise) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                _getDifficultyDisplayName(exercise.difficulty),
                _getDifficultyColor(exercise.difficulty),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                _getTypeDisplayName(exercise.type),
                Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                '${exercise.duration}s',
                Colors.grey[600]!,
              ),
            ],
          ),
          if (exercise.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              exercise.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(ListeningProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: 实现后退15秒
                },
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  provider.togglePlayback();
                },
                icon: Icon(
                  provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 64,
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  // TODO: 实现前进15秒
                },
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _formatDuration(provider.playbackPosition),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: provider.playbackPosition,
                  max: provider.currentExercise?.duration.toDouble() ?? 100.0,
                  onChanged: (value) {
                    provider.seekTo(value);
                  },
                ),
              ),
              Text(
                _formatDuration(provider.currentExercise?.duration.toDouble() ?? 0),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('播放速度: '),
              DropdownButton<double>(
                value: provider.playbackSpeed,
                items: const [
                  DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                  DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                  DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                  DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                  DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.setPlaybackSpeed(value);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranscript(ListeningExercise exercise) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_snippet,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '听力文本',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exercise.transcript,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(ListeningProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) {
      return const Center(
        child: Text('没有问题'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionProgress(provider),
          const SizedBox(height: 24),
          _buildQuestionContent(question, provider),
        ],
      ),
    );
  }

  Widget _buildQuestionProgress(ListeningProvider provider) {
    final current = provider.currentQuestionIndex + 1;
    final total = provider.currentQuestions.length;
    final progress = current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '问题 $current / $total',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(ListeningQuestion question, ListeningProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildAnswerOptions(question, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(ListeningQuestion question, ListeningProvider provider) {
    final userAnswer = provider.userAnswers[question.id];

    switch (question.type) {
      case ListeningQuestionType.multipleChoice:
        return Column(
          children: question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = userAnswer == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  provider.answerQuestion(question.id, index);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[400]!,
                          ),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${String.fromCharCode(65 + index)}. $option',
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontWeight: isSelected ? FontWeight.w500 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case ListeningQuestionType.trueFalse:
        return Row(
          children: [
            Expanded(
              child: _buildTrueFalseOption('正确', true, userAnswer, provider, question.id),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTrueFalseOption('错误', false, userAnswer, provider, question.id),
            ),
          ],
        );

      case ListeningQuestionType.fillBlank:
        return TextField(
          decoration: const InputDecoration(
            hintText: '请输入答案...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            provider.answerQuestion(question.id, value);
          },
        );

      case ListeningQuestionType.shortAnswer:
        return TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '请输入您的答案...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            provider.answerQuestion(question.id, value);
          },
        );

      case ListeningQuestionType.matching:
        // TODO: 实现匹配题
        return const Text('匹配题功能开发中...');
    }
  }

  Widget _buildTrueFalseOption(
    String label,
    bool value,
    dynamic userAnswer,
    ListeningProvider provider,
    String questionId,
  ) {
    final isSelected = userAnswer == value;

    return InkWell(
      onTap: () {
        provider.answerQuestion(questionId, value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(ListeningProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (provider.hasPreviousQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  provider.previousQuestion();
                },
                child: const Text('上一题'),
              ),
            ),
          if (provider.hasPreviousQuestion && provider.hasNextQuestion)
            const SizedBox(width: 16),
          if (provider.hasNextQuestion)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  provider.nextQuestion();
                },
                child: const Text('下一题'),
              ),
            ),
          if (provider.isLastQuestion)
            Expanded(
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        await provider.submitAnswers();
                        setState(() {
                          _isSubmitted = true;
                        });
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('提交答案'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultView(ListeningExerciseResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    result.isPassed ? Icons.check_circle : Icons.cancel,
                    size: 64,
                    color: result.isPassed ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.isPassed ? '恭喜通过!' : '继续努力!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: result.isPassed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildResultItem('得分', '${result.score.toStringAsFixed(1)}%'),
                  _buildResultItem('正确题数', '${result.correctCount}/${result.totalQuestions}'),
                  _buildResultItem('用时', '${result.timeSpent} 秒'),
                  _buildResultItem('播放次数', '${result.playCount} 次'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ListeningProvider>().resetExercise();
                    setState(() {
                      _isSubmitted = false;
                    });
                  },
                  child: const Text('重新练习'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('返回'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getDifficultyDisplayName(ListeningDifficulty difficulty) {
    switch (difficulty) {
      case ListeningDifficulty.beginner:
        return '初级';
      case ListeningDifficulty.elementary:
        return '基础';
      case ListeningDifficulty.intermediate:
        return '中级';
      case ListeningDifficulty.advanced:
        return '高级';
      case ListeningDifficulty.expert:
        return '专家';
    }
  }

  String _getTypeDisplayName(ListeningExerciseType type) {
    switch (type) {
      case ListeningExerciseType.conversation:
        return '对话';
      case ListeningExerciseType.lecture:
        return '讲座';
      case ListeningExerciseType.news:
        return '新闻';
      case ListeningExerciseType.story:
        return '故事';
      case ListeningExerciseType.interview:
        return '访谈';
      case ListeningExerciseType.dialogue:
        return '对话';
    }
  }

  Color _getDifficultyColor(ListeningDifficulty difficulty) {
    switch (difficulty) {
      case ListeningDifficulty.beginner:
        return Colors.green;
      case ListeningDifficulty.elementary:
        return Colors.lightGreen;
      case ListeningDifficulty.intermediate:
        return Colors.orange;
      case ListeningDifficulty.advanced:
        return Colors.red;
      case ListeningDifficulty.expert:
        return Colors.purple;
    }
  }
}