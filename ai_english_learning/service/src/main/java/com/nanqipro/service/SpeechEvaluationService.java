package com.nanqipro.service;

import com.nanqipro.entity.SpeechEvaluation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 语音评估服务接口
 */
public interface SpeechEvaluationService {
    
    // ==================== 语音评估 ====================
    
    /**
     * 评估词汇发音
     */
    SpeechEvaluation evaluateVocabularyPronunciation(Long userId, Long vocabularyId, MultipartFile audioFile);
    
    /**
     * 评估文章朗读
     */
    SpeechEvaluation evaluateArticleReading(Long userId, Long articleId, MultipartFile audioFile);
    
    /**
     * 评估自由发言
     */
    SpeechEvaluation evaluateFreeSpeech(Long userId, String topic, MultipartFile audioFile);
    
    /**
     * 评估句子朗读
     */
    SpeechEvaluation evaluateSentenceReading(Long userId, String sentence, MultipartFile audioFile);
    
    /**
     * 批量评估语音
     */
    List<SpeechEvaluation> batchEvaluate(Long userId, List<MultipartFile> audioFiles, SpeechEvaluation.ContentType contentType);
    
    // ==================== 语音分析 ====================
    
    /**
     * 分析发音准确度
     */
    Map<String, Object> analyzePronunciationAccuracy(Long evaluationId);
    
    /**
     * 分析语音流利度
     */
    Map<String, Object> analyzeFluency(Long evaluationId);
    
    /**
     * 分析语音节奏
     */
    Map<String, Object> analyzeRhythm(Long evaluationId);
    
    /**
     * 分析语音语调
     */
    Map<String, Object> analyzeIntonation(Long evaluationId);
    
    /**
     * 检测语音错误
     */
    List<Map<String, Object>> detectPronunciationErrors(Long evaluationId);
    
    /**
     * 生成语音特征
     */
    Map<String, Object> extractSpeechFeatures(Long evaluationId);
    
    // ==================== 评估管理 ====================
    
    /**
     * 保存评估记录
     */
    SpeechEvaluation saveEvaluation(SpeechEvaluation evaluation);
    
    /**
     * 更新评估记录
     */
    SpeechEvaluation updateEvaluation(SpeechEvaluation evaluation);
    
    /**
     * 删除评估记录
     */
    void deleteEvaluation(Long evaluationId);
    
    /**
     * 批量删除评估记录
     */
    void batchDeleteEvaluations(List<Long> evaluationIds);
    
    /**
     * 重新评估语音
     */
    SpeechEvaluation reevaluate(Long evaluationId);
    
    // ==================== 评估查询 ====================
    
    /**
     * 根据ID获取评估记录
     */
    SpeechEvaluation getEvaluationById(Long evaluationId);
    
    /**
     * 获取用户评估记录
     */
    Page<SpeechEvaluation> getUserEvaluations(Long userId, Pageable pageable);
    
    /**
     * 根据内容类型获取评估记录
     */
    List<SpeechEvaluation> getEvaluationsByContentType(Long userId, SpeechEvaluation.ContentType contentType);
    
    /**
     * 获取用户词汇评估记录
     */
    List<SpeechEvaluation> getVocabularyEvaluations(Long userId, Long vocabularyId);
    
    /**
     * 获取用户文章评估记录
     */
    List<SpeechEvaluation> getArticleEvaluations(Long userId, Long articleId);
    
    /**
     * 获取最近评估记录
     */
    List<SpeechEvaluation> getRecentEvaluations(Long userId, int count);
    
    /**
     * 根据时间范围获取评估记录
     */
    List<SpeechEvaluation> getEvaluationsByTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取高分评估记录
     */
    List<SpeechEvaluation> getHighScoreEvaluations(Long userId, Double minScore);
    
    /**
     * 获取低分评估记录
     */
    List<SpeechEvaluation> getLowScoreEvaluations(Long userId, Double maxScore);
    
    /**
     * 获取最佳表现记录
     */
    List<SpeechEvaluation> getBestPerformances(Long userId, SpeechEvaluation.ContentType contentType);
    
    /**
     * 获取需要改进的记录
     */
    List<SpeechEvaluation> getEvaluationsNeedingImprovement(Long userId, Double threshold);
    
    // ==================== 评估统计 ====================
    
    /**
     * 获取用户评估统计
     */
    Map<String, Object> getUserEvaluationStats(Long userId);
    
    /**
     * 获取用户分数统计
     */
    Map<String, Double> getScoreDistribution(Long userId);
    
    /**
     * 获取内容类型分布统计
     */
    Map<SpeechEvaluation.ContentType, Long> getContentTypeDistribution(Long userId);
    
    /**
     * 获取每日评估统计
     */
    List<Map<String, Object>> getDailyEvaluationStats(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取分数趋势
     */
    List<Map<String, Object>> getScoreTrends(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取词汇发音统计
     */
    Map<String, Object> getVocabularyPronunciationStats(Long userId);
    
    /**
     * 获取文章朗读统计
     */
    Map<String, Object> getArticleReadingStats(Long userId);
    
    /**
     * 获取活跃时段统计
     */
    Map<String, Object> getActiveTimeStats(Long userId);
    
    /**
     * 获取评估等级分布
     */
    Map<String, Long> getScoreLevelDistribution(Long userId);
    
    // ==================== 评估分析 ====================
    
    /**
     * 分析用户发音模式
     */
    Map<String, Object> analyzePronunciationPatterns(Long userId);
    
    /**
     * 分析用户学习进步
     */
    Map<String, Object> analyzeLearningProgress(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 生成评估报告
     */
    Map<String, Object> generateProgressReport(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 识别发音弱点
     */
    List<String> identifyWeaknesses(Long userId);
    
    /**
     * 分析学习效果
     */
    Map<String, Object> analyzeLearningEffectiveness(Long userId);
    
    /**
     * 预测学习趋势
     */
    Map<String, Object> predictScoreTrends(Long userId);
    
    // ==================== 个性化建议 ====================
    
    /**
     * 生成个性化学习建议
     */
    List<String> generateLearningAdvice(Long userId);
    
    /**
     * 推荐练习内容
     */
    List<Map<String, Object>> recommendPracticeContent(Long userId);
    
    /**
     * 推荐复习词汇
     */
    List<Long> recommendReviewVocabularies(Long userId);
    
    /**
     * 推荐朗读文章
     */
    List<Long> recommendReadingArticles(Long userId);
    
    /**
     * 生成学习计划
     */
    Map<String, Object> generateLearningPlan(Long userId);
    
    // ==================== 语音处理 ====================
    
    /**
     * 上传语音文件
     */
    String uploadAudioFile(MultipartFile audioFile);
    
    /**
     * 下载语音文件
     */
    byte[] downloadAudioFile(String filePath);
    
    /**
     * 删除语音文件
     */
    void deleteAudioFile(String filePath);
    
    /**
     * 转换语音格式
     */
    String convertAudioFormat(String filePath, String targetFormat);
    
    /**
     * 压缩语音文件
     */
    String compressAudioFile(String filePath);
    
    /**
     * 验证语音文件
     */
    boolean validateAudioFile(MultipartFile audioFile);
    
    // ==================== 比较分析 ====================
    
    /**
     * 比较两次评估结果
     */
    Map<String, Object> compareEvaluationResults(Long evaluationId1, Long evaluationId2);
    
    /**
     * 比较用户与平均水平
     */
    Map<String, Object> compareWithAverage(Long userId, SpeechEvaluation.ContentType contentType);
    
    /**
     * 比较不同时间段的表现
     */
    Map<String, Object> comparePerformanceOverTime(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 生成进步报告
     */
    Map<String, Object> generateProgressReport(Long userId, LocalDateTime startTime, LocalDateTime endTime, SpeechEvaluation.ContentType contentType);
    

    
    // ==================== 系统管理 ====================
    
    /**
     * 清理过期评估记录
     */
    void cleanupExpiredRecords(LocalDateTime expireTime);
    
    /**
     * 清理过期语音文件
     */
    void cleanupAudioFiles(LocalDateTime expireTime);
    
    /**
     * 导出评估数据
     */
    List<Map<String, Object>> exportEvaluationData(Long userId);
    
    /**
     * 获取评估系统健康状态
     */
    Map<String, Object> getSystemHealth();
    
    /**
     * 优化评估性能
     */
    void optimizePerformance();
    
    /**
     * 校准评估算法
     */
    void calibrateAlgorithms();
}