package com.nanqipro.service;

import com.nanqipro.entity.Vocabulary;
import com.nanqipro.entity.UserVocabulary;
import com.nanqipro.entity.StudyType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 词汇管理服务接口
 */
public interface VocabularyService {
    
    // ==================== 词汇基础管理 ====================
    
    /**
     * 添加词汇
     * @param vocabulary 词汇信息
     * @return 保存的词汇
     */
    Vocabulary addVocabulary(Vocabulary vocabulary);
    
    /**
     * 批量添加词汇
     * @param vocabularies 词汇列表
     * @return 保存的词汇列表
     */
    List<Vocabulary> addVocabularies(List<Vocabulary> vocabularies);
    
    /**
     * 更新词汇
     * @param vocabularyId 词汇ID
     * @param vocabulary 更新的词汇信息
     * @return 更新后的词汇
     */
    Vocabulary updateVocabulary(Long vocabularyId, Vocabulary vocabulary);
    
    /**
     * 删除词汇
     * @param vocabularyId 词汇ID
     */
    void deleteVocabulary(Long vocabularyId);
    
    /**
     * 批量删除词汇
     * @param vocabularyIds 词汇ID列表
     */
    void deleteVocabularies(List<Long> vocabularyIds);
    
    /**
     * 根据ID获取词汇
     * @param vocabularyId 词汇ID
     * @return 词汇信息
     */
    Vocabulary getVocabularyById(Long vocabularyId);
    
    /**
     * 根据单词获取词汇
     * @param word 单词
     * @return 词汇信息
     */
    Vocabulary getVocabularyByWord(String word);
    
    /**
     * 检查词汇是否存在
     * @param word 单词
     * @return 是否存在
     */
    boolean existsByWord(String word);
    
    // ==================== 词汇查询和搜索 ====================
    
    /**
     * 分页获取词汇列表
     * @param pageable 分页参数
     * @return 词汇分页列表
     */
    Page<Vocabulary> getVocabularies(Pageable pageable);
    
    /**
     * 根据难度级别获取词汇
     * @param level 难度级别
     * @param pageable 分页参数
     * @return 词汇分页列表
     */
    Page<Vocabulary> getVocabulariesByLevel(Vocabulary.DifficultyLevel level, Pageable pageable);
    
    /**
     * 根据分类获取词汇
     * @param category 分类
     * @param pageable 分页参数
     * @return 词汇分页列表
     */
    Page<Vocabulary> getVocabulariesByCategory(String category, Pageable pageable);
    
    /**
     * 搜索词汇
     * @param keyword 关键词
     * @param pageable 分页参数
     * @return 词汇分页列表
     */
    Page<Vocabulary> searchVocabularies(String keyword, Pageable pageable);
    
    /**
     * 高级搜索词汇
     * @param word 单词（可选）
     * @param level 难度级别（可选）
     * @param category 分类（可选）
     * @param tags 标签（可选）
     * @param pageable 分页参数
     * @return 词汇分页列表
     */
    Page<Vocabulary> advancedSearchVocabularies(String word, Vocabulary.DifficultyLevel level, 
                                               String category, List<String> tags, Pageable pageable);
    
    /**
     * 获取随机词汇
     * @param count 数量
     * @param level 难度级别（可选）
     * @return 随机词汇列表
     */
    List<Vocabulary> getRandomVocabularies(int count, Vocabulary.DifficultyLevel level);
    
    /**
     * 获取热门词汇
     * @param limit 数量限制
     * @return 热门词汇列表
     */
    List<Vocabulary> getPopularVocabularies(int limit);
    
    /**
     * 获取最新添加的词汇
     * @param limit 数量限制
     * @return 最新词汇列表
     */
    List<Vocabulary> getLatestVocabularies(int limit);
    
    // ==================== 用户词汇学习 ====================
    
    /**
     * 添加词汇到用户学习列表
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     * @return 学习记录
     */
    UserVocabulary addToLearningList(Long userId, Long vocabularyId);
    
    /**
     * 批量添加词汇到学习列表
     * @param userId 用户ID
     * @param vocabularyIds 词汇ID列表
     * @return 学习记录列表
     */
    List<UserVocabulary> addToLearningList(Long userId, List<Long> vocabularyIds);
    
    /**
     * 从学习列表移除词汇
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     */
    void removeFromLearningList(Long userId, Long vocabularyId);
    
    /**
     * 获取用户学习列表
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 学习记录分页列表
     */
    Page<UserVocabulary> getUserLearningList(Long userId, Pageable pageable);
    
    /**
     * 获取用户已掌握的词汇
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 学习记录分页列表
     */
    Page<UserVocabulary> getUserMasteredVocabularies(Long userId, Pageable pageable);
    
    /**
     * 获取用户需要复习的词汇
     * @param userId 用户ID
     * @param limit 数量限制
     * @return 需要复习的词汇列表
     */
    List<UserVocabulary> getVocabulariesForReview(Long userId, int limit);
    
    /**
     * 获取用户今日学习词汇
     * @param userId 用户ID
     * @param limit 数量限制
     * @return 今日学习词汇列表
     */
    List<UserVocabulary> getTodayLearningVocabularies(Long userId, int limit);
    
    // ==================== 学习记录管理 ====================
    
    /**
     * 记录词汇学习
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     * @param isCorrect 是否正确
     * @param studyType 学习类型
     * @param timeSpent 学习时间（秒）
     * @return 更新后的学习记录
     */
    UserVocabulary recordLearning(Long userId, Long vocabularyId, boolean isCorrect, 
                                           StudyType studyType, int timeSpent);
    
    /**
     * 批量记录学习
     * @param userId 用户ID
     * @param learningData 学习数据列表
     * @return 更新后的学习记录列表
     */
    List<UserVocabulary> batchRecordLearning(Long userId, List<Map<String, Object>> learningData);
    
    /**
     * 标记词汇为已掌握
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     * @return 更新后的学习记录
     */
    UserVocabulary markAsMastered(Long userId, Long vocabularyId);
    
    /**
     * 重置词汇学习进度
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     * @return 重置后的学习记录
     */
    UserVocabulary resetLearningProgress(Long userId, Long vocabularyId);
    
    /**
     * 获取学习记录
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     * @return 学习记录
     */
    UserVocabulary getLearningRecord(Long userId, Long vocabularyId);
    
    /**
     * 获取用户学习统计
     * @param userId 用户ID
     * @return 学习统计信息
     */
    Map<String, Object> getUserLearningStats(Long userId);
    
    /**
     * 获取用户学习历史
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @param pageable 分页参数
     * @return 学习历史分页列表
     */
    Page<UserVocabulary> getUserLearningHistory(Long userId, LocalDateTime startDate, 
                                                         LocalDateTime endDate, Pageable pageable);
    
    // ==================== 复习算法 ====================
    
    /**
     * 计算下次复习时间
     * @param record 学习记录
     * @param isCorrect 本次是否正确
     * @return 下次复习时间
     */
    LocalDateTime calculateNextReviewTime(UserVocabulary record, boolean isCorrect);
    
    /**
     * 更新复习间隔
     * @param record 学习记录
     * @param isCorrect 是否正确
     * @return 更新后的学习记录
     */
    UserVocabulary updateReviewInterval(UserVocabulary record, boolean isCorrect);
    
    /**
     * 获取推荐学习词汇
     * @param userId 用户ID
     * @param limit 数量限制
     * @return 推荐词汇列表
     */
    List<Vocabulary> getRecommendedVocabularies(Long userId, int limit);
    
    // ==================== 词汇导入导出 ====================
    
    /**
     * 从文件导入词汇
     * @param file 词汇文件
     * @param category 分类
     * @return 导入结果
     */
    Map<String, Object> importVocabulariesFromFile(MultipartFile file, String category);
    
    /**
     * 导出词汇到文件
     * @param vocabularyIds 词汇ID列表
     * @param format 导出格式（csv, excel, json）
     * @return 文件数据
     */
    byte[] exportVocabularies(List<Long> vocabularyIds, String format);
    
    /**
     * 导出用户学习数据
     * @param userId 用户ID
     * @param format 导出格式
     * @return 文件数据
     */
    byte[] exportUserLearningData(Long userId, String format);
    
    // ==================== 词汇分析和统计 ====================
    
    /**
     * 获取词汇统计信息
     * @return 统计信息
     */
    Map<String, Object> getVocabularyStatistics();
    
    /**
     * 获取分类统计
     * @return 分类统计信息
     */
    Map<String, Long> getCategoryStatistics();
    
    /**
     * 获取难度级别统计
     * @return 难度级别统计信息
     */
    Map<Vocabulary.DifficultyLevel, Long> getLevelStatistics();
    
    /**
     * 获取学习趋势数据
     * @param userId 用户ID
     * @param days 天数
     * @return 学习趋势数据
     */
    List<Map<String, Object>> getLearningTrend(Long userId, int days);
    
    /**
     * 获取词汇掌握度分析
     * @param userId 用户ID
     * @return 掌握度分析数据
     */
    Map<String, Object> getMasteryAnalysis(Long userId);
    
    // ==================== 词汇收藏和标签 ====================
    
    /**
     * 收藏词汇
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     */
    void favoriteVocabulary(Long userId, Long vocabularyId);
    
    /**
     * 取消收藏词汇
     * @param userId 用户ID
     * @param vocabularyId 词汇ID
     */
    void unfavoriteVocabulary(Long userId, Long vocabularyId);
    
    /**
     * 获取用户收藏的词汇
     * @param userId 用户ID
     * @param pageable 分页参数
     * @return 收藏词汇分页列表
     */
    Page<Vocabulary> getUserFavoriteVocabularies(Long userId, Pageable pageable);
    
    /**
     * 为词汇添加标签
     * @param vocabularyId 词汇ID
     * @param tags 标签列表
     * @return 更新后的词汇
     */
    Vocabulary addTagsToVocabulary(Long vocabularyId, List<String> tags);
    
    /**
     * 从词汇移除标签
     * @param vocabularyId 词汇ID
     * @param tags 标签列表
     * @return 更新后的词汇
     */
    Vocabulary removeTagsFromVocabulary(Long vocabularyId, List<String> tags);
    
    /**
     * 获取所有标签
     * @return 标签列表
     */
    List<String> getAllTags();
    
    /**
     * 根据标签获取词汇
     * @param tag 标签
     * @param pageable 分页参数
     * @return 词汇分页列表
     */
    Page<Vocabulary> getVocabulariesByTag(String tag, Pageable pageable);
}