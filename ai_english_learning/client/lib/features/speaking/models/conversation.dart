enum MessageType {
  user,
  ai,
  system;
}

enum ConversationStatus {
  active,
  paused,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ConversationStatus.active:
        return '进行中';
      case ConversationStatus.paused:
        return '已暂停';
      case ConversationStatus.completed:
        return '已完成';
      case ConversationStatus.cancelled:
        return '已取消';
    }
  }
}

class ConversationMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? audioUrl;
  final double? confidence; // 语音识别置信度
  final Map<String, dynamic>? metadata;

  const ConversationMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.audioUrl,
    this.confidence,
    this.metadata,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      audioUrl: json['audioUrl'] as String?,
      confidence: json['confidence'] as double?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'audioUrl': audioUrl,
      'confidence': confidence,
      'metadata': metadata,
    };
  }
}

class Conversation {
  final String id;
  final String taskId;
  final String userId;
  final List<ConversationMessage> messages;
  final ConversationStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalDuration; // 总时长（秒）
  final Map<String, dynamic>? settings;

  const Conversation({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.messages,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.totalDuration,
    this.settings,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      totalDuration: json['totalDuration'] as int,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'messages': messages.map((e) => e.toJson()).toList(),
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalDuration': totalDuration,
      'settings': settings,
    };
  }

  Conversation copyWith({
    String? id,
    String? taskId,
    String? userId,
    List<ConversationMessage>? messages,
    ConversationStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? totalDuration,
    Map<String, dynamic>? settings,
  }) {
    return Conversation(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration: totalDuration ?? this.totalDuration,
      settings: settings ?? this.settings,
    );
  }
}