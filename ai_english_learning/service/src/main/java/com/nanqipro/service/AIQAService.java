package com.nanqipro.service;

import com.nanqipro.entity.AIQARecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * AI问答服务接口
 */
public interface AIQAService {
    
    // ==================== 问答处理 ====================
    
    /**
     * 处理用户问题并生成回答
     */
    AIQARecord processQuestion(Long userId, String questionText, 
                              AIQARecord.Language questionLanguage,
                              AIQARecord.Language answerLanguage);
    
    /**
     * 处理文章相关问题
     */
    AIQARecord processArticleQuestion(Long userId, Long articleId, 
                                     String questionText,
                                     AIQARecord.Language questionLanguage,
                                     AIQARecord.Language answerLanguage);
    
    /**
     * 处理词汇相关问题
     */
    AIQARecord processVocabularyQuestion(Long userId, Long vocabularyId, 
                                        String questionText,
                                        AIQARecord.Language questionLanguage,
                                        AIQARecord.Language answerLanguage);
    
    /**
     * 处理语法问题
     */
    AIQARecord processGrammarQuestion(Long userId, String questionText,
                                     AIQARecord.Language questionLanguage,
                                     AIQARecord.Language answerLanguage);
    
    /**
     * 处理翻译问题
     */
    AIQARecord processTranslationQuestion(Long userId, String sourceText,
                                         AIQARecord.Language sourceLanguage,
                                         AIQARecord.Language targetLanguage);
    
    /**
     * 批量处理问题
     */
    List<AIQARecord> batchProcessQuestions(Long userId, List<String> questions,
                                          AIQARecord.Language questionLanguage,
                                          AIQARecord.Language answerLanguage);
    
    // ==================== 智能问答 ====================
    
    /**
     * 生成智能回答（基于上下文）
     */
    String generateIntelligentAnswer(String questionText, String context,
                                   AIQARecord.Language questionLanguage,
                                   AIQARecord.Language answerLanguage);
    
    /**
     * 生成解释性回答
     */
    String generateExplanatoryAnswer(String questionText, String topic,
                                   AIQARecord.Language questionLanguage,
                                   AIQARecord.Language answerLanguage);
    
    /**
     * 生成示例性回答
     */
    String generateExampleBasedAnswer(String questionText, List<String> examples,
                                    AIQARecord.Language questionLanguage,
                                    AIQARecord.Language answerLanguage);
    
    /**
     * 生成对话式回答
     */
    String generateConversationalAnswer(String questionText, List<AIQARecord> conversationHistory,
                                      AIQARecord.Language questionLanguage,
                                      AIQARecord.Language answerLanguage);
    
    /**
     * 生成个性化回答（基于用户学习水平）
     */
    String generatePersonalizedAnswer(Long userId, String questionText,
                                    AIQARecord.Language questionLanguage,
                                    AIQARecord.Language answerLanguage);
    
    // ==================== 问答管理 ====================
    
    /**
     * 保存问答记录
     */
    AIQARecord saveQARecord(AIQARecord qaRecord);
    
    /**
     * 更新问答记录
     */
    AIQARecord updateQARecord(AIQARecord qaRecord);
    
    /**
     * 删除问答记录
     */
    void deleteQARecord(Long recordId);
    
    /**
     * 批量删除问答记录
     */
    void batchDeleteQARecords(List<Long> recordIds);
    
    /**
     * 标记问答记录为有用
     */
    void markAsHelpful(Long recordId, Long userId);
    
    /**
     * 标记问答记录为无用
     */
    void markAsUnhelpful(Long recordId, Long userId);
    
    // ==================== 问答查询 ====================
    
    /**
     * 根据ID获取问答记录
     */
    AIQARecord getQARecordById(Long recordId);
    
    /**
     * 获取用户问答记录
     */
    Page<AIQARecord> getUserQARecords(Long userId, Pageable pageable);
    
    /**
     * 获取用户文章相关问答
     */
    List<AIQARecord> getUserArticleQA(Long userId, Long articleId);
    
    /**
     * 获取用户词汇相关问答
     */
    List<AIQARecord> getUserVocabularyQA(Long userId, Long vocabularyId);
    
    /**
     * 根据语言获取问答记录
     */
    List<AIQARecord> getQARecordsByLanguage(Long userId, 
                                           AIQARecord.Language questionLanguage,
                                           AIQARecord.Language answerLanguage);
    
    /**
     * 获取用户最近问答记录
     */
    List<AIQARecord> getRecentQARecords(Long userId, int count);
    
    /**
     * 获取用户指定时间段的问答记录
     */
    List<AIQARecord> getQARecordsByTimeRange(Long userId, 
                                           LocalDateTime startTime, 
                                           LocalDateTime endTime);
    
    /**
     * 搜索问答记录
     */
    List<AIQARecord> searchQARecords(Long userId, String keyword);
    
    /**
     * 获取快速响应的问答记录
     */
    List<AIQARecord> getFastResponseRecords(Long userId, Integer maxResponseTime);
    
    /**
     * 获取跨语言问答记录
     */
    List<AIQARecord> getCrossLanguageRecords(Long userId);
    
    // ==================== 问答统计 ====================
    
    /**
     * 获取用户问答统计
     */
    Map<String, Object> getUserQAStats(Long userId);
    
    /**
     * 获取问答语言分布
     */
    Map<String, Object> getLanguageDistribution(Long userId);
    
    /**
     * 获取每日问答统计
     */
    List<Map<String, Object>> getDailyQAStats(Long userId, 
                                             LocalDateTime startTime, 
                                             LocalDateTime endTime);
    
    /**
     * 获取问答效率统计
     */
    Map<String, Object> getQAEfficiencyStats(Long userId, 
                                            LocalDateTime startTime, 
                                            LocalDateTime endTime);
    
    /**
     * 获取用户平均响应时间
     */
    Double getAverageResponseTime(Long userId);
    
    /**
     * 获取最活跃的问答文章
     */
    List<Map<String, Object>> getMostActiveArticles(Long userId, int count);
    
    /**
     * 获取问答活跃时段统计
     */
    List<Map<String, Object>> getHourlyActivityStats(Long userId, LocalDateTime startTime);
    
    // ==================== 问答分析 ====================
    
    /**
     * 分析用户问答模式
     */
    Map<String, Object> analyzeUserQAPatterns(Long userId);
    
    /**
     * 分析问答质量
     */
    Map<String, Object> analyzeQAQuality(Long userId);
    
    /**
     * 生成问答报告
     */
    Map<String, Object> generateQAReport(Long userId, 
                                        LocalDateTime startTime, 
                                        LocalDateTime endTime);
    
    /**
     * 分析用户学习需求
     */
    Map<String, Object> analyzeLearningNeeds(Long userId);
    
    /**
     * 预测用户问题类型
     */
    Map<String, Double> predictQuestionTypes(Long userId);
    
    // ==================== 智能推荐 ====================
    
    /**
     * 推荐相关问题
     */
    List<String> recommendRelatedQuestions(String questionText, 
                                          AIQARecord.Language language);
    
    /**
     * 推荐学习内容（基于问答历史）
     */
    List<Map<String, Object>> recommendLearningContent(Long userId);
    
    /**
     * 推荐练习题目
     */
    List<Map<String, Object>> recommendExercises(Long userId);
    
    /**
     * 推荐复习内容
     */
    List<Map<String, Object>> recommendReviewContent(Long userId);
    
    // ==================== 上下文管理 ====================
    
    /**
     * 构建问答上下文
     */
    String buildQAContext(Long userId, String questionText);
    
    /**
     * 更新对话上下文
     */
    void updateConversationContext(Long userId, AIQARecord qaRecord);
    
    /**
     * 获取对话历史
     */
    List<AIQARecord> getConversationHistory(Long userId, int count);
    
    /**
     * 清理对话上下文
     */
    void clearConversationContext(Long userId);
    
    // ==================== 质量控制 ====================
    
    /**
     * 验证问题质量
     */
    boolean validateQuestionQuality(String questionText);
    
    /**
     * 验证回答质量
     */
    boolean validateAnswerQuality(String answerText, String questionText);
    
    /**
     * 过滤不当内容
     */
    boolean filterInappropriateContent(String text);
    
    /**
     * 检测问题重复
     */
    boolean detectQuestionDuplication(Long userId, String questionText);
    
    // ==================== 系统管理 ====================
    
    /**
     * 清理过期问答记录
     */
    void cleanupExpiredQARecords(LocalDateTime expireTime);
    
    /**
     * 导出问答数据
     */
    List<Map<String, Object>> exportQAData(Long userId);
    
    /**
     * 获取问答系统健康状态
     */
    Map<String, Object> getQASystemHealth();
    
    /**
     * 优化问答性能
     */
    void optimizeQAPerformance();
}