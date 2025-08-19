package com.nanqipro.service.impl;

import com.nanqipro.entity.SpeechEvaluation;
import com.nanqipro.entity.User;
import com.nanqipro.entity.Vocabulary;
import com.nanqipro.entity.Article;
import com.nanqipro.repository.SpeechEvaluationRepository;
import com.nanqipro.repository.UserRepository;
import com.nanqipro.repository.VocabularyRepository;
import com.nanqipro.repository.ArticleRepository;
import com.nanqipro.service.SpeechEvaluationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 语音评估服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SpeechEvaluationServiceImpl implements SpeechEvaluationService {
    
    private final SpeechEvaluationRepository speechEvaluationRepository;
    private final UserRepository userRepository;
    private final VocabularyRepository vocabularyRepository;
    private final ArticleRepository articleRepository;
    
    // ==================== 语音评估 ====================
    
    @Override
    @Transactional
    public SpeechEvaluation evaluateVocabularyPronunciation(Long userId, Long vocabularyId, MultipartFile audioFile) {
        log.info("评估用户 {} 的词汇 {} 发音", userId, vocabularyId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        Vocabulary vocabulary = vocabularyRepository.findById(vocabularyId)
                .orElseThrow(() -> new RuntimeException("词汇不存在"));
        
        // 模拟语音评估结果
        SpeechEvaluation evaluation = new SpeechEvaluation();
        evaluation.setUserId(userId);
        evaluation.setContentType(SpeechEvaluation.ContentType.VOCABULARY);
        evaluation.setContentId(vocabularyId);
        evaluation.setAudioFilePath(saveAudioFile(audioFile));
        evaluation.setPronunciationScore(BigDecimal.valueOf(85.5));
        evaluation.setFluencyScore(BigDecimal.valueOf(80.0));
        evaluation.setRhythmScore(BigDecimal.valueOf(78.5));
        evaluation.setIntonationScore(BigDecimal.valueOf(82.0));
        evaluation.setOverallScore(BigDecimal.valueOf(81.5));
        evaluation.setFeedback("发音基本准确，建议注意重音位置");
        evaluation.setCreatedAt(LocalDateTime.now());
        
        return speechEvaluationRepository.save(evaluation);
    }
    
    @Override
    @Transactional
    public SpeechEvaluation evaluateArticleReading(Long userId, Long articleId, MultipartFile audioFile) {
        log.info("评估用户 {} 的文章 {} 朗读", userId, articleId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        Article article = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("文章不存在"));
        
        SpeechEvaluation evaluation = new SpeechEvaluation();
        evaluation.setUserId(userId);
        evaluation.setContentType(SpeechEvaluation.ContentType.ARTICLE);
        evaluation.setContentId(articleId);
        evaluation.setAudioFilePath(saveAudioFile(audioFile));
        evaluation.setPronunciationScore(BigDecimal.valueOf(88.0));
        evaluation.setFluencyScore(BigDecimal.valueOf(85.5));
        evaluation.setRhythmScore(BigDecimal.valueOf(83.0));
        evaluation.setIntonationScore(BigDecimal.valueOf(86.5));
        evaluation.setOverallScore(BigDecimal.valueOf(85.8));
        evaluation.setFeedback("朗读流畅，语调自然，建议注意停顿节奏");
        evaluation.setCreatedAt(LocalDateTime.now());
        
        return speechEvaluationRepository.save(evaluation);
    }
    
    @Override
    @Transactional
    public SpeechEvaluation evaluateFreeSpeech(Long userId, String topic, MultipartFile audioFile) {
        log.info("评估用户 {} 的自由发言，主题: {}", userId, topic);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        SpeechEvaluation evaluation = new SpeechEvaluation();
        evaluation.setUserId(userId);
        evaluation.setContentType(SpeechEvaluation.ContentType.FREE_SPEECH);
        evaluation.setContentId(null);
        evaluation.setAudioFilePath(saveAudioFile(audioFile));
        evaluation.setPronunciationScore(BigDecimal.valueOf(82.0));
        evaluation.setFluencyScore(BigDecimal.valueOf(78.5));
        evaluation.setRhythmScore(BigDecimal.valueOf(75.0));
        evaluation.setIntonationScore(BigDecimal.valueOf(80.0));
        evaluation.setOverallScore(BigDecimal.valueOf(78.9));
        evaluation.setFeedback("表达较为流畅，词汇运用恰当，建议提高语音连贯性");
        evaluation.setCreatedAt(LocalDateTime.now());
        
        return speechEvaluationRepository.save(evaluation);
    }
    
    @Override
    @Transactional
    public SpeechEvaluation evaluateSentenceReading(Long userId, String sentence, MultipartFile audioFile) {
        log.info("评估用户 {} 的句子朗读", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        SpeechEvaluation evaluation = new SpeechEvaluation();
        evaluation.setUserId(userId);
        evaluation.setContentType(SpeechEvaluation.ContentType.SENTENCE);
        evaluation.setContentId(null);
        evaluation.setAudioFilePath(saveAudioFile(audioFile));
        evaluation.setPronunciationScore(BigDecimal.valueOf(87.5));
        evaluation.setFluencyScore(BigDecimal.valueOf(84.0));
        evaluation.setRhythmScore(BigDecimal.valueOf(81.5));
        evaluation.setIntonationScore(BigDecimal.valueOf(85.0));
        evaluation.setOverallScore(BigDecimal.valueOf(84.5));
        evaluation.setFeedback("句子朗读准确，语调把握较好");
        evaluation.setCreatedAt(LocalDateTime.now());
        
        return speechEvaluationRepository.save(evaluation);
    }
    
    @Override
    @Transactional
    public List<SpeechEvaluation> batchEvaluate(Long userId, List<MultipartFile> audioFiles, SpeechEvaluation.ContentType contentType) {
        log.info("批量评估用户 {} 的 {} 个语音文件", userId, audioFiles.size());
        
        List<SpeechEvaluation> evaluations = new ArrayList<>();
        
        for (MultipartFile audioFile : audioFiles) {
            SpeechEvaluation evaluation = new SpeechEvaluation();
            evaluation.setUserId(userId);
            evaluation.setContentType(contentType);
            evaluation.setAudioFilePath(saveAudioFile(audioFile));
            evaluation.setPronunciationScore(BigDecimal.valueOf(80.0 + Math.random() * 20));
            evaluation.setFluencyScore(BigDecimal.valueOf(75.0 + Math.random() * 25));
            evaluation.setRhythmScore(BigDecimal.valueOf(70.0 + Math.random() * 30));
            evaluation.setIntonationScore(BigDecimal.valueOf(78.0 + Math.random() * 22));
            evaluation.setOverallScore(calculateOverallScore(evaluation));
            evaluation.setFeedback("批量评估结果");
            evaluation.setCreatedAt(LocalDateTime.now());
            
            evaluations.add(evaluation);
        }
        
        return speechEvaluationRepository.saveAll(evaluations);
    }
    
    // ==================== 语音分析 ====================
    
    @Override
    public Map<String, Object> analyzePronunciationAccuracy(Long evaluationId) {
        SpeechEvaluation evaluation = speechEvaluationRepository.findById(evaluationId)
                .orElseThrow(() -> new RuntimeException("评估记录不存在"));
        
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("pronunciationScore", evaluation.getPronunciationScore());
        analysis.put("accuracy", evaluation.getPronunciationScore().doubleValue() / 100.0);
        analysis.put("level", getPronunciationLevel(evaluation.getPronunciationScore()));
        analysis.put("suggestions", generatePronunciationSuggestions(evaluation.getPronunciationScore()));
        
        return analysis;
    }
    
    @Override
    public Map<String, Object> analyzeFluency(Long evaluationId) {
        SpeechEvaluation evaluation = speechEvaluationRepository.findById(evaluationId)
                .orElseThrow(() -> new RuntimeException("评估记录不存在"));
        
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("fluencyScore", evaluation.getFluencyScore());
        analysis.put("level", getFluencyLevel(evaluation.getFluencyScore()));
        analysis.put("suggestions", generateFluencySuggestions(evaluation.getFluencyScore()));
        
        return analysis;
    }
    
    @Override
    public Map<String, Object> analyzeRhythm(Long evaluationId) {
        SpeechEvaluation evaluation = speechEvaluationRepository.findById(evaluationId)
                .orElseThrow(() -> new RuntimeException("评估记录不存在"));
        
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("rhythmScore", evaluation.getRhythmScore());
        analysis.put("level", getRhythmLevel(evaluation.getRhythmScore()));
        analysis.put("suggestions", generateRhythmSuggestions(evaluation.getRhythmScore()));
        
        return analysis;
    }
    
    @Override
    public Map<String, Object> analyzeIntonation(Long evaluationId) {
        SpeechEvaluation evaluation = speechEvaluationRepository.findById(evaluationId)
                .orElseThrow(() -> new RuntimeException("评估记录不存在"));
        
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("intonationScore", evaluation.getIntonationScore());
        analysis.put("level", getIntonationLevel(evaluation.getIntonationScore()));
        analysis.put("suggestions", generateIntonationSuggestions(evaluation.getIntonationScore()));
        
        return analysis;
    }
    
    @Override
    public List<Map<String, Object>> detectPronunciationErrors(Long evaluationId) {
        List<Map<String, Object>> errors = new ArrayList<>();
        
        // 模拟发音错误检测结果
        Map<String, Object> error1 = new HashMap<>();
        error1.put("position", "0:05-0:07");
        error1.put("word", "pronunciation");
        error1.put("error", "重音位置错误");
        error1.put("suggestion", "重音应在第二音节");
        errors.add(error1);
        
        Map<String, Object> error2 = new HashMap<>();
        error2.put("position", "0:12-0:14");
        error2.put("word", "through");
        error2.put("error", "th音发音不准确");
        error2.put("suggestion", "舌尖轻触上齿");
        errors.add(error2);
        
        return errors;
    }
    
    @Override
    public Map<String, Object> extractSpeechFeatures(Long evaluationId) {
        Map<String, Object> features = new HashMap<>();
        
        // 模拟语音特征提取结果
        features.put("duration", 15.5); // 秒
        features.put("averagePitch", 180.5); // Hz
        features.put("pitchRange", 120.0); // Hz
        features.put("speakingRate", 150.0); // 词/分钟
        features.put("pauseCount", 3);
        features.put("averagePauseLength", 0.8); // 秒
        features.put("volumeLevel", 65.0); // dB
        
        return features;
    }
    
    // ==================== 评估管理 ====================
    
    @Override
    @Transactional
    public SpeechEvaluation saveEvaluation(SpeechEvaluation evaluation) {
        return speechEvaluationRepository.save(evaluation);
    }
    
    @Override
    @Transactional
    public SpeechEvaluation updateEvaluation(SpeechEvaluation evaluation) {
        return speechEvaluationRepository.save(evaluation);
    }
    
    @Override
    @Transactional
    public void deleteEvaluation(Long evaluationId) {
        speechEvaluationRepository.deleteById(evaluationId);
    }
    
    @Override
    @Transactional
    public void batchDeleteEvaluations(List<Long> evaluationIds) {
        speechEvaluationRepository.deleteAllById(evaluationIds);
    }
    
    @Override
    @Transactional
    public SpeechEvaluation reevaluate(Long evaluationId) {
        SpeechEvaluation evaluation = speechEvaluationRepository.findById(evaluationId)
                .orElseThrow(() -> new RuntimeException("评估记录不存在"));
        
        // 重新评估，更新分数
        evaluation.setPronunciationScore(BigDecimal.valueOf(85.0 + Math.random() * 15));
        evaluation.setFluencyScore(BigDecimal.valueOf(80.0 + Math.random() * 20));
        evaluation.setRhythmScore(BigDecimal.valueOf(75.0 + Math.random() * 25));
        evaluation.setIntonationScore(BigDecimal.valueOf(78.0 + Math.random() * 22));
        evaluation.setOverallScore(calculateOverallScore(evaluation));
        evaluation.setUpdatedAt(LocalDateTime.now());
        
        return speechEvaluationRepository.save(evaluation);
    }
    
    // ==================== 评估查询 ====================
    
    @Override
    public SpeechEvaluation getEvaluationById(Long evaluationId) {
        return speechEvaluationRepository.findById(evaluationId)
                .orElseThrow(() -> new RuntimeException("评估记录不存在"));
    }
    
    @Override
    public Page<SpeechEvaluation> getUserEvaluations(Long userId, Pageable pageable) {
        return speechEvaluationRepository.findByUserId(userId, pageable);
    }
    
    @Override
    public List<SpeechEvaluation> getEvaluationsByContentType(Long userId, SpeechEvaluation.ContentType contentType) {
        return speechEvaluationRepository.findByUserIdAndContentType(userId, contentType);
    }
    
    @Override
    public List<SpeechEvaluation> getVocabularyEvaluations(Long userId, Long vocabularyId) {
        return speechEvaluationRepository.findByUserIdAndContentTypeAndContentId(
                userId, SpeechEvaluation.ContentType.VOCABULARY, vocabularyId);
    }
    
    @Override
    public List<SpeechEvaluation> getArticleEvaluations(Long userId, Long articleId) {
        return speechEvaluationRepository.findByUserIdAndContentTypeAndContentId(
                userId, SpeechEvaluation.ContentType.ARTICLE, articleId);
    }
    
    @Override
    public List<SpeechEvaluation> getRecentEvaluations(Long userId, int count) {
        return speechEvaluationRepository.findTop10ByUserIdOrderByCreatedAtDesc(userId);
    }
    
    @Override
    public List<SpeechEvaluation> getEvaluationsByTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return speechEvaluationRepository.findByUserIdAndCreatedAtBetween(userId, startTime, endTime);
    }
    
    @Override
    public List<SpeechEvaluation> getHighScoreEvaluations(Long userId, Double minScore) {
        return speechEvaluationRepository.findByUserIdAndOverallScoreGreaterThanEqual(
                userId, BigDecimal.valueOf(minScore));
    }
    
    @Override
    public List<SpeechEvaluation> getLowScoreEvaluations(Long userId, Double maxScore) {
        return speechEvaluationRepository.findByUserIdAndOverallScoreLessThanEqual(
                userId, BigDecimal.valueOf(maxScore));
    }
    
    @Override
    public List<SpeechEvaluation> getBestPerformances(Long userId, SpeechEvaluation.ContentType contentType) {
        return speechEvaluationRepository.findTop5ByUserIdAndContentTypeOrderByOverallScoreDesc(
                userId, contentType);
    }
    
    @Override
    public List<SpeechEvaluation> getEvaluationsNeedingImprovement(Long userId, Double threshold) {
        return speechEvaluationRepository.findByUserIdAndOverallScoreLessThan(
                userId, BigDecimal.valueOf(threshold));
    }
    
    // ==================== 其他方法的简化实现 ====================
    
    @Override
    public Map<String, Object> getUserEvaluationStats(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalEvaluations", speechEvaluationRepository.countByUserId(userId));
        stats.put("averageScore", speechEvaluationRepository.getAverageScoreByUserId(userId));
        return stats;
    }
    
    @Override
    public Map<String, Double> getScoreDistribution(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<SpeechEvaluation.ContentType, Long> getContentTypeDistribution(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public List<Map<String, Object>> getDailyEvaluationStats(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new ArrayList<>();
    }
    
    @Override
    public List<Map<String, Object>> getScoreTrends(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new ArrayList<>();
    }
    
    @Override
    public Map<String, Object> getVocabularyPronunciationStats(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> getArticleReadingStats(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> getActiveTimeStats(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Long> getScoreLevelDistribution(Long userId) {
        return new HashMap<>();
    }
    
    // 评估分析方法的简化实现
    @Override
    public Map<String, Object> analyzePronunciationPatterns(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> analyzeLearningProgress(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> generateProgressReport(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new HashMap<>();
    }
    
    @Override
    public List<String> identifyWeaknesses(Long userId) {
        return Arrays.asList("发音准确度", "语调控制", "语音连贯性");
    }
    
    @Override
    public Map<String, Object> analyzeLearningEffectiveness(Long userId) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> predictScoreTrends(Long userId) {
        return new HashMap<>();
    }
    
    // 个性化建议方法的简化实现
    @Override
    public List<String> generateLearningAdvice(Long userId) {
        return Arrays.asList(
                "建议每天练习发音30分钟",
                "重点练习th音和r音的发音",
                "多听英语原声材料提高语调"
        );
    }
    
    @Override
    public List<Map<String, Object>> recommendPracticeContent(Long userId) {
        return new ArrayList<>();
    }
    
    @Override
    public List<Long> recommendReviewVocabularies(Long userId) {
        return new ArrayList<>();
    }
    
    @Override
    public List<Long> recommendReadingArticles(Long userId) {
        return new ArrayList<>();
    }
    
    @Override
    public Map<String, Object> generateLearningPlan(Long userId) {
        return new HashMap<>();
    }
    
    // 语音处理方法的简化实现
    @Override
    public String uploadAudioFile(MultipartFile audioFile) {
        return saveAudioFile(audioFile);
    }
    
    @Override
    public byte[] downloadAudioFile(String filePath) {
        // 简化实现，返回空数组
        return new byte[0];
    }
    
    @Override
    @Transactional
    public void deleteAudioFile(String filePath) {
        // 简化实现
    }
    
    @Override
    public String convertAudioFormat(String filePath, String targetFormat) {
        return filePath;
    }
    
    @Override
    public String compressAudioFile(String filePath) {
        return filePath;
    }
    
    @Override
    public boolean validateAudioFile(MultipartFile audioFile) {
        return audioFile != null && !audioFile.isEmpty();
    }
    
    // 比较分析方法的简化实现
    @Override
    public Map<String, Object> compareEvaluationResults(Long evaluationId1, Long evaluationId2) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> compareWithAverage(Long userId, SpeechEvaluation.ContentType contentType) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> comparePerformanceOverTime(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return new HashMap<>();
    }
    
    @Override
    public Map<String, Object> generateProgressReport(Long userId, LocalDateTime startTime, LocalDateTime endTime, SpeechEvaluation.ContentType contentType) {
        return new HashMap<>();
    }
    
    // 系统管理方法的简化实现
    @Override
    @Transactional
    public void cleanupExpiredRecords(LocalDateTime expireTime) {
        // 简化实现
    }
    
    @Override
    @Transactional
    public void cleanupAudioFiles(LocalDateTime expireTime) {
        // 简化实现
    }
    
    @Override
    public List<Map<String, Object>> exportEvaluationData(Long userId) {
        return new ArrayList<>();
    }
    
    @Override
    public Map<String, Object> getSystemHealth() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "healthy");
        health.put("totalEvaluations", speechEvaluationRepository.count());
        return health;
    }
    
    @Override
    @Transactional
    public void optimizePerformance() {
        // 简化实现
    }
    
    @Override
    @Transactional
    public void calibrateAlgorithms() {
        // 简化实现
    }
    
    // ==================== 私有辅助方法 ====================
    
    private String saveAudioFile(MultipartFile audioFile) {
        // 简化实现，返回模拟文件路径
        return "/audio/" + System.currentTimeMillis() + "_" + audioFile.getOriginalFilename();
    }
    
    private BigDecimal calculateOverallScore(SpeechEvaluation evaluation) {
        BigDecimal total = evaluation.getPronunciationScore()
                .add(evaluation.getFluencyScore())
                .add(evaluation.getRhythmScore())
                .add(evaluation.getIntonationScore());
        
        return total.divide(BigDecimal.valueOf(4), 2, RoundingMode.HALF_UP);
    }
    
    private String getPronunciationLevel(BigDecimal score) {
        double scoreValue = score.doubleValue();
        if (scoreValue >= 90) return "优秀";
        if (scoreValue >= 80) return "良好";
        if (scoreValue >= 70) return "中等";
        if (scoreValue >= 60) return "及格";
        return "需要改进";
    }
    
    private String getFluencyLevel(BigDecimal score) {
        return getPronunciationLevel(score);
    }
    
    private String getRhythmLevel(BigDecimal score) {
        return getPronunciationLevel(score);
    }
    
    private String getIntonationLevel(BigDecimal score) {
        return getPronunciationLevel(score);
    }
    
    private List<String> generatePronunciationSuggestions(BigDecimal score) {
        List<String> suggestions = new ArrayList<>();
        double scoreValue = score.doubleValue();
        
        if (scoreValue < 80) {
            suggestions.add("建议多练习音标发音");
            suggestions.add("注意重音位置");
        }
        if (scoreValue < 70) {
            suggestions.add("建议跟读标准发音");
            suggestions.add("练习困难音素");
        }
        
        return suggestions;
    }
    
    private List<String> generateFluencySuggestions(BigDecimal score) {
        List<String> suggestions = new ArrayList<>();
        double scoreValue = score.doubleValue();
        
        if (scoreValue < 80) {
            suggestions.add("建议提高语速");
            suggestions.add("减少停顿");
        }
        if (scoreValue < 70) {
            suggestions.add("多练习连读");
            suggestions.add("提高语音连贯性");
        }
        
        return suggestions;
    }
    
    private List<String> generateRhythmSuggestions(BigDecimal score) {
        List<String> suggestions = new ArrayList<>();
        double scoreValue = score.doubleValue();
        
        if (scoreValue < 80) {
            suggestions.add("注意语音节奏");
            suggestions.add("练习重读和弱读");
        }
        
        return suggestions;
    }
    
    private List<String> generateIntonationSuggestions(BigDecimal score) {
        List<String> suggestions = new ArrayList<>();
        double scoreValue = score.doubleValue();
        
        if (scoreValue < 80) {
            suggestions.add("练习语调变化");
            suggestions.add("注意句子重音");
        }
        
        return suggestions;
    }
}