import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/app_error.dart';
import '../models/api_response.dart';

/// 音频播放状态
enum AudioPlayerState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

/// 音频服务
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  
  final ApiClient _apiClient = ApiClient.instance;
  
  AudioPlayerState _state = AudioPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;
  double _playbackRate = 1.0;
  String? _currentUrl;
  
  // 回调函数
  Function(AudioPlayerState)? onStateChanged;
  Function(Duration)? onDurationChanged;
  Function(Duration)? onPositionChanged;
  Function(String)? onError;
  
  /// 更新播放状态
  void _updateState(AudioPlayerState state) {
    _state = state;
    onStateChanged?.call(state);
  }
  
  /// 播放网络音频
  Future<void> playFromUrl(String url) async {
    try {
      _updateState(AudioPlayerState.loading);
      _currentUrl = url;
      
      // TODO: 实现音频播放逻辑
      _updateState(AudioPlayerState.playing);
    } catch (e) {
      _updateState(AudioPlayerState.error);
      onError?.call('播放失败: $e');
    }
  }
  
  /// 播放本地音频文件
  Future<void> playFromFile(String filePath) async {
    try {
      _updateState(AudioPlayerState.loading);
      _currentUrl = filePath;
      
      // TODO: 实现本地音频播放逻辑
      _updateState(AudioPlayerState.playing);
    } catch (e) {
      _updateState(AudioPlayerState.error);
      onError?.call('播放失败: $e');
    }
  }
  
  /// 播放资源文件
  Future<void> playFromAsset(String assetPath) async {
    try {
      _updateState(AudioPlayerState.loading);
      _currentUrl = assetPath;
      
      // TODO: 实现资源音频播放逻辑
      _updateState(AudioPlayerState.playing);
    } catch (e) {
      _updateState(AudioPlayerState.error);
      onError?.call('播放失败: $e');
    }
  }
  
  /// 暂停播放
  Future<void> pause() async {
    try {
      // TODO: 实现暂停逻辑
      _updateState(AudioPlayerState.paused);
    } catch (e) {
      onError?.call('暂停失败: $e');
    }
  }
  
  /// 恢复播放
  Future<void> resume() async {
    try {
      // TODO: 实现恢复播放逻辑
      _updateState(AudioPlayerState.playing);
    } catch (e) {
      onError?.call('恢复播放失败: $e');
    }
  }
  
  /// 停止播放
  Future<void> stop() async {
    try {
      // TODO: 实现停止播放逻辑
      _updateState(AudioPlayerState.stopped);
      _position = Duration.zero;
    } catch (e) {
      onError?.call('停止播放失败: $e');
    }
  }
  
  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    try {
      // TODO: 实现跳转逻辑
      _position = position;
    } catch (e) {
      onError?.call('跳转失败: $e');
    }
  }
  
  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      // TODO: 实现音量设置逻辑
    } catch (e) {
      onError?.call('设置音量失败: $e');
    }
  }
  
  /// 设置播放速度 (0.5 - 2.0)
  Future<void> setPlaybackRate(double rate) async {
    try {
      _playbackRate = rate.clamp(0.5, 2.0);
      // TODO: 实现播放速度设置逻辑
    } catch (e) {
      onError?.call('设置播放速度失败: $e');
    }
  }
  
  /// 下载音频文件
  Future<ApiResponse<String>> downloadAudio({
    required String url,
    required String fileName,
    Function(int, int)? onProgress,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      final filePath = '${audioDir.path}/$fileName';
      
      // TODO: 实现文件下载逻辑
      final response = await _apiClient.get(url);
      final file = File(filePath);
      await file.writeAsBytes(response.data);
      
      return ApiResponse.success(
        message: '音频下载成功',
        data: filePath,
      );
    } catch (e) {
      return ApiResponse.failure(
        message: '音频下载失败: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 上传音频文件
  Future<ApiResponse<Map<String, dynamic>>> uploadAudio({
    required String filePath,
    required String type, // 'pronunciation', 'speaking', etc.
    Map<String, dynamic>? metadata,
    Function(int, int)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ApiResponse.failure(
          message: '音频文件不存在',
          error: 'FILE_NOT_FOUND',
        );
      }
      
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: file.path.split('/').last,
        ),
        'type': type,
        if (metadata != null) 'metadata': metadata,
      });
      
      final response = await _apiClient.post(
        '/audio/upload',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: response.data['message'] ?? '音频上传成功',
          data: response.data['data'],
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? '音频上传失败',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.failure(
        message: '音频上传失败: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取音频文件信息
  Future<ApiResponse<Map<String, dynamic>>> getAudioInfo(String audioId) async {
    try {
      final response = await _apiClient.get('/audio/$audioId');
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Audio info retrieved successfully',
          data: response.data['data'],
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get audio info',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get audio info: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 删除本地音频文件
  Future<bool> deleteLocalAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      onError?.call('删除音频文件失败: $e');
      return false;
    }
  }
  
  /// 清理缓存的音频文件
  Future<void> clearAudioCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }
    } catch (e) {
      onError?.call('清理音频缓存失败: $e');
    }
  }
  
  /// 检查音频文件是否存在
  Future<bool> isAudioCached(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/audio/$fileName';
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// 获取缓存音频文件路径
  Future<String?> getCachedAudioPath(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/audio/$fileName';
      final file = File(filePath);
      
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// 释放资源
  Future<void> dispose() async {
    // TODO: 实现资源释放逻辑
  }
  
  // Getters
  AudioPlayerState get state => _state;
  Duration get duration => _duration;
  Duration get position => _position;
  double get volume => _volume;
  double get playbackRate => _playbackRate;
  String? get currentUrl => _currentUrl;
  bool get isPlaying => _state == AudioPlayerState.playing;
  bool get isPaused => _state == AudioPlayerState.paused;
  bool get isStopped => _state == AudioPlayerState.stopped;
  bool get isLoading => _state == AudioPlayerState.loading;
  
  /// 获取播放进度百分比 (0.0 - 1.0)
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }
}