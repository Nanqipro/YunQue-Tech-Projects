import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// 音频录制状态
enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

// 音频播放状态
enum PlaybackState {
  idle,
  playing,
  paused,
  stopped,
}

class AudioService {
  // 录制相关
  RecordingState _recordingState = RecordingState.idle;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  
  // 播放相关
  PlaybackState _playbackState = PlaybackState.idle;
  String? _currentPlayingPath;
  
  // 回调函数
  Function(RecordingState)? onRecordingStateChanged;
  Function(PlaybackState)? onPlaybackStateChanged;
  Function(Duration)? onRecordingProgress;
  Function(Duration)? onPlaybackProgress;
  Function(String)? onRecordingComplete;
  Function()? onPlaybackComplete;

  // Getters
  RecordingState get recordingState => _recordingState;
  PlaybackState get playbackState => _playbackState;
  String? get currentRecordingPath => _currentRecordingPath;
  String? get currentPlayingPath => _currentPlayingPath;
  bool get isRecording => _recordingState == RecordingState.recording;
  bool get isPlaying => _playbackState == PlaybackState.playing;

  // 初始化音频服务
  Future<void> initialize() async {
    // 请求麦克风权限
    await _requestPermissions();
  }

  // 请求权限
  Future<bool> _requestPermissions() async {
    final microphoneStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    
    if (microphoneStatus != PermissionStatus.granted) {
      throw Exception('需要麦克风权限才能录音');
    }
    
    if (storageStatus != PermissionStatus.granted) {
      throw Exception('需要存储权限才能保存录音文件');
    }
    
    return true;
  }

  // 开始录音
  Future<void> startRecording({String? fileName}) async {
    try {
      if (_recordingState == RecordingState.recording) {
        throw Exception('已经在录音中');
      }

      await _requestPermissions();
      
      // 生成录音文件路径
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      
      fileName ??= 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${recordingsDir.path}/$fileName';
      
      // 这里应该使用实际的录音插件，比如 record 或 flutter_sound
      // 由于没有实际的录音插件，这里只是模拟
      _recordingStartTime = DateTime.now();
      _setRecordingState(RecordingState.recording);
      
      if (kDebugMode) {
        print('开始录音: $_currentRecordingPath');
      }
      
      // 模拟录音进度更新
      _startRecordingProgressTimer();
      
    } catch (e) {
      throw Exception('开始录音失败: ${e.toString()}');
    }
  }

  // 停止录音
  Future<String?> stopRecording() async {
    try {
      if (_recordingState != RecordingState.recording) {
        throw Exception('当前没有在录音');
      }

      // 这里应该调用实际录音插件的停止方法
      _setRecordingState(RecordingState.stopped);
      
      final recordingPath = _currentRecordingPath;
      
      if (kDebugMode) {
        print('录音完成: $recordingPath');
      }
      
      // 通知录音完成
      if (recordingPath != null && onRecordingComplete != null) {
        onRecordingComplete!(recordingPath);
      }
      
      return recordingPath;
    } catch (e) {
      throw Exception('停止录音失败: ${e.toString()}');
    }
  }

  // 暂停录音
  Future<void> pauseRecording() async {
    try {
      if (_recordingState != RecordingState.recording) {
        throw Exception('当前没有在录音');
      }

      // 这里应该调用实际录音插件的暂停方法
      _setRecordingState(RecordingState.paused);
      
      if (kDebugMode) {
        print('录音已暂停');
      }
    } catch (e) {
      throw Exception('暂停录音失败: ${e.toString()}');
    }
  }

  // 恢复录音
  Future<void> resumeRecording() async {
    try {
      if (_recordingState != RecordingState.paused) {
        throw Exception('录音没有暂停');
      }

      // 这里应该调用实际录音插件的恢复方法
      _setRecordingState(RecordingState.recording);
      
      if (kDebugMode) {
        print('录音已恢复');
      }
    } catch (e) {
      throw Exception('恢复录音失败: ${e.toString()}');
    }
  }

  // 播放音频
  Future<void> playAudio(String audioPath) async {
    try {
      if (_playbackState == PlaybackState.playing) {
        await stopPlayback();
      }

      _currentPlayingPath = audioPath;
      
      // 这里应该使用实际的音频播放插件，比如 audioplayers 或 just_audio
      // 由于没有实际的播放插件，这里只是模拟
      _setPlaybackState(PlaybackState.playing);
      
      if (kDebugMode) {
        print('开始播放: $audioPath');
      }
      
      // 模拟播放进度和完成
      _startPlaybackProgressTimer();
      
    } catch (e) {
      throw Exception('播放音频失败: ${e.toString()}');
    }
  }

  // 暂停播放
  Future<void> pausePlayback() async {
    try {
      if (_playbackState != PlaybackState.playing) {
        throw Exception('当前没有在播放');
      }

      // 这里应该调用实际播放插件的暂停方法
      _setPlaybackState(PlaybackState.paused);
      
      if (kDebugMode) {
        print('播放已暂停');
      }
    } catch (e) {
      throw Exception('暂停播放失败: ${e.toString()}');
    }
  }

  // 恢复播放
  Future<void> resumePlayback() async {
    try {
      if (_playbackState != PlaybackState.paused) {
        throw Exception('播放没有暂停');
      }

      // 这里应该调用实际播放插件的恢复方法
      _setPlaybackState(PlaybackState.playing);
      
      if (kDebugMode) {
        print('播放已恢复');
      }
    } catch (e) {
      throw Exception('恢复播放失败: ${e.toString()}');
    }
  }

  // 停止播放
  Future<void> stopPlayback() async {
    try {
      // 这里应该调用实际播放插件的停止方法
      _setPlaybackState(PlaybackState.stopped);
      _currentPlayingPath = null;
      
      if (kDebugMode) {
        print('播放已停止');
      }
    } catch (e) {
      throw Exception('停止播放失败: ${e.toString()}');
    }
  }

  // 获取音频文件时长
  Future<Duration?> getAudioDuration(String audioPath) async {
    try {
      // 这里应该使用实际的音频插件获取时长
      // 模拟返回时长
      return const Duration(seconds: 30);
    } catch (e) {
      if (kDebugMode) {
        print('获取音频时长失败: ${e.toString()}');
      }
      return null;
    }
  }

  // 删除录音文件
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('删除录音文件失败: ${e.toString()}');
      }
      return false;
    }
  }

  // 获取所有录音文件
  Future<List<String>> getAllRecordings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      
      if (!await recordingsDir.exists()) {
        return [];
      }
      
      final files = await recordingsDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.m4a'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('获取录音文件列表失败: ${e.toString()}');
      }
      return [];
    }
  }

  // 私有方法：设置录音状态
  void _setRecordingState(RecordingState state) {
    _recordingState = state;
    onRecordingStateChanged?.call(state);
  }

  // 私有方法：设置播放状态
  void _setPlaybackState(PlaybackState state) {
    _playbackState = state;
    onPlaybackStateChanged?.call(state);
  }

  // 私有方法：录音进度计时器
  void _startRecordingProgressTimer() {
    // 这里应该实现实际的进度更新逻辑
    // 模拟进度更新
  }

  // 私有方法：播放进度计时器
  void _startPlaybackProgressTimer() {
    // 这里应该实现实际的播放进度更新逻辑
    // 模拟播放完成
    Future.delayed(const Duration(seconds: 3), () {
      _setPlaybackState(PlaybackState.stopped);
      onPlaybackComplete?.call();
    });
  }

  // 释放资源
  void dispose() {
    // 停止所有操作
    if (_recordingState == RecordingState.recording) {
      stopRecording();
    }
    if (_playbackState == PlaybackState.playing) {
      stopPlayback();
    }
    
    // 清理回调
    onRecordingStateChanged = null;
    onPlaybackStateChanged = null;
    onRecordingProgress = null;
    onPlaybackProgress = null;
    onRecordingComplete = null;
    onPlaybackComplete = null;
  }
}