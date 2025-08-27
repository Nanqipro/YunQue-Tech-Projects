import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/speaking_scenario.dart';
import '../models/conversation.dart';
import '../providers/speaking_provider.dart';

class SpeakingConversationScreen extends StatefulWidget {
  final SpeakingTask task;

  const SpeakingConversationScreen({
    super.key,
    required this.task,
  });

  @override
  State<SpeakingConversationScreen> createState() => _SpeakingConversationScreenState();
}

class _SpeakingConversationScreenState extends State<SpeakingConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isTextMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpeakingProvider>().startConversation(widget.task.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          Consumer<SpeakingProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.currentConversation?.status == ConversationStatus.active
                      ? Icons.pause
                      : Icons.stop,
                ),
                onPressed: () {
                  if (provider.currentConversation?.status == ConversationStatus.active) {
                    provider.pauseConversation();
                  } else {
                    _showEndConversationDialog();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<SpeakingProvider>(
        builder: (context, provider, child) {
          final conversation = provider.currentConversation;
          
          if (conversation == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // 任务信息卡片
              _buildTaskInfoCard(),
              
              // 对话状态指示器
              _buildStatusIndicator(conversation.status),
              
              // 消息列表
              Expanded(
                child: _buildMessageList(conversation.messages),
              ),
              
              // 输入区域
              _buildInputArea(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.task.scenario.displayName,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.task.difficulty.displayName,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.task.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          if (widget.task.objectives.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '目标: ${widget.task.objectives.join('、')}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ConversationStatus status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case ConversationStatus.active:
        statusColor = Colors.green;
        statusText = '对话进行中';
        statusIcon = Icons.mic;
        break;
      case ConversationStatus.paused:
        statusColor = Colors.orange;
        statusText = '对话已暂停';
        statusIcon = Icons.pause;
        break;
      case ConversationStatus.completed:
        statusColor = Colors.blue;
        statusText = '对话已完成';
        statusIcon = Icons.check_circle;
        break;
      case ConversationStatus.cancelled:
        statusColor = Colors.red;
        statusText = '对话已取消';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ConversationMessage> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    final isUser = message.type == MessageType.user;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.audioUrl != null)
                        Icon(
                          Icons.volume_up,
                          size: 12,
                          color: isUser ? Colors.white70 : Colors.grey[600],
                        ),
                      if (message.audioUrl != null) const SizedBox(width: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                      if (message.confidence != null && isUser) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.mic,
                          size: 12,
                          color: _getConfidenceColor(message.confidence!),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${(message.confidence! * 100).toInt()}%',
                          style: TextStyle(
                            color: _getConfidenceColor(message.confidence!),
                            fontSize: 10,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInputArea(SpeakingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // 模式切换
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('语音'),
                    icon: Icon(Icons.mic),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('文字'),
                    icon: Icon(Icons.keyboard),
                  ),
                ],
                selected: {_isTextMode},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    _isTextMode = selection.first;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 输入控件
          if (_isTextMode)
            _buildTextInput(provider)
          else
            _buildVoiceInput(provider),
        ],
      ),
    );
  }

  Widget _buildTextInput(SpeakingProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: '输入你的回复...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (text) => _sendTextMessage(provider, text),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          mini: true,
          onPressed: () => _sendTextMessage(provider, _textController.text),
          child: const Icon(Icons.send),
        ),
      ],
    );
  }

  Widget _buildVoiceInput(SpeakingProvider provider) {
    return Column(
      children: [
        // 录音按钮
        GestureDetector(
          onTapDown: (_) => provider.startRecording(),
          onTapUp: (_) => provider.stopRecording(),
          onTapCancel: () => provider.stopRecording(),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: provider.isRecording
                  ? Colors.red
                  : Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (provider.isRecording ? Colors.red : Theme.of(context).primaryColor)
                      .withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: provider.isRecording ? 5 : 0,
                ),
              ],
            ),
            child: Icon(
              provider.isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 录音提示
        Text(
          provider.isRecording ? '松开发送' : '按住说话',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        
        // 录音时长
        if (provider.isRecording)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _formatRecordingDuration(const Duration(seconds: 0)),
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
      ],
    );
  }

  void _sendTextMessage(SpeakingProvider provider, String text) {
    if (text.trim().isEmpty) return;
    
    provider.sendMessage(text.trim());
    _textController.clear();
  }

  void _showEndConversationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束对话'),
        content: const Text('确定要结束当前对话吗？对话记录将被保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SpeakingProvider>().endConversation();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatRecordingDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}