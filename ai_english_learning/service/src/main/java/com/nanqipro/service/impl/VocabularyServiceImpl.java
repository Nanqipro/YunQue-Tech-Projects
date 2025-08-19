package com.nanqipro.service.impl;

import com.nanqipro.entity.*;
import com.nanqipro.repository.UserVocabularyRepository;
import com.nanqipro.repository.VocabularyRepository;
import com.nanqipro.service.VocabularyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 词汇管理服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class VocabularyServiceImpl implements VocabularyService {
    
    private final VocabularyRepository vocabularyRepository;
    private final UserVocabularyRepository userVocabularyRepository;
    
    // ==================== 词汇基础管理 ====================
    
    @Override
    public Vocabulary addVocabulary(Vocabulary vocabulary) {
        log.info("Adding vocabulary: {}", vocabulary.getWord());
        vocabulary.setCreatedAt(LocalDateTime.now());
        vocabulary.setUpdatedAt(LocalDateTime.now());
        vocabulary.setIsActive(true);
        return vocabularyRepository.save(vocabulary);
    }
    
    @Override
    public List<Vocabulary> addVocabularies(List<Vocabulary> vocabularies) {
        log.info("Batch adding {} vocabularies", vocabularies.size());
        LocalDateTime now = LocalDateTime.now();
        vocabularies.forEach(vocabulary -> {
            vocabulary.setCreatedAt(now);
            vocabulary.setUpdatedAt(now);
            vocabulary.setIsActive(true);
        });
        return vocabularyRepository.saveAll(vocabularies);
    }
    
    @Override
    public Vocabulary updateVocabulary(Long vocabularyId, Vocabulary vocabulary) {
        log.info("Updating vocabulary with id: {}", vocabularyId);
        Vocabulary existing = vocabularyRepository.findById(vocabularyId)
            .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
        
        existing.setWord(vocabulary.getWord());
        existing.setPhoneticUs(vocabulary.getPhoneticUs());
        existing.setPhoneticUk(vocabulary.getPhoneticUk());
        existing.setWordType(vocabulary.getWordType());
        existing.setDifficultyLevel(vocabulary.getDifficultyLevel());
        existing.setUpdatedAt(LocalDateTime.now());
        
        return vocabularyRepository.save(existing);
    }
    
    @Override
    public void deleteVocabulary(Long vocabularyId) {
        log.info("Deleting vocabulary with id: {}", vocabularyId);
        vocabularyRepository.deleteById(vocabularyId);
    }
    
    @Override
    public void deleteVocabularies(List<Long> vocabularyIds) {
        log.info("Batch deleting {} vocabularies", vocabularyIds.size());
        vocabularyRepository.deleteAllById(vocabularyIds);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Vocabulary getVocabularyById(Long vocabularyId) {
        return vocabularyRepository.findById(vocabularyId)
            .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
    }
    
    @Override
    @Transactional(readOnly = true)
    public Vocabulary getVocabularyByWord(String word) {
        return vocabularyRepository.findByWord(word)
            .orElseThrow(() -> new RuntimeException("Vocabulary not found"));
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean existsByWord(String word) {
        return vocabularyRepository.existsByWord(word);
    }
    
    // ==================== 词汇查询和搜索 ====================
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> getVocabularies(Pageable pageable) {
        return vocabularyRepository.findAll(pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> getVocabulariesByLevel(Vocabulary.DifficultyLevel level, Pageable pageable) {
        return vocabularyRepository.findByDifficultyLevel(level, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> getVocabulariesByCategory(String category, Pageable pageable) {
        return vocabularyRepository.findByTag(category, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> searchVocabularies(String keyword, Pageable pageable) {
        return vocabularyRepository.searchByKeyword(keyword, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> advancedSearchVocabularies(String word, Vocabulary.DifficultyLevel level, 
                                                      String category, List<String> tags, Pageable pageable) {
        return vocabularyRepository.advancedSearch(word, level, null, null, true, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Vocabulary> getRandomVocabularies(int count, Vocabulary.DifficultyLevel level) {
        if (level != null) {
            return vocabularyRepository.findByDifficultyLevel(level, PageRequest.of(0, count)).getContent();
        }
        return vocabularyRepository.findRandomVocabularies(count);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Vocabulary> getPopularVocabularies(int limit) {
        return vocabularyRepository.findPopularVocabularies(PageRequest.of(0, limit));
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Vocabulary> getLatestVocabularies(int limit) {
        Pageable pageable = PageRequest.of(0, limit, Sort.by(Sort.Direction.DESC, "createdAt"));
        return vocabularyRepository.findAll(pageable).getContent();
    }
    
    // ==================== 用户词汇学习 ====================
    
    @Override
    public UserVocabulary addToLearningList(Long userId, Long vocabularyId) {
        log.info("Adding vocabulary {} to user {} learning list", vocabularyId, userId);
        
        Optional<UserVocabulary> existing = userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId);
        if (existing.isPresent()) {
            return existing.get();
        }
        
        UserVocabulary userVocabulary = new UserVocabulary();
        User user = new User();
        user.setId(userId);
        userVocabulary.setUser(user);
        
        Vocabulary vocabulary = getVocabularyById(vocabularyId);
        userVocabulary.setVocabulary(vocabulary);
        userVocabulary.setMasteryLevel(UserVocabulary.MasteryLevel.NEW);
        userVocabulary.setFirstLearnedAt(LocalDateTime.now());
        
        return userVocabularyRepository.save(userVocabulary);
    }
    
    @Override
    public List<UserVocabulary> addToLearningList(Long userId, List<Long> vocabularyIds) {
        log.info("Batch adding {} vocabularies to user {} learning list", vocabularyIds.size(), userId);
        List<UserVocabulary> results = new ArrayList<>();
        for (Long vocabularyId : vocabularyIds) {
            results.add(addToLearningList(userId, vocabularyId));
        }
        return results;
    }
    
    @Override
    public void removeFromLearningList(Long userId, Long vocabularyId) {
        log.info("Removing vocabulary {} from user {} learning list", vocabularyId, userId);
        userVocabularyRepository.deleteByUserIdAndVocabularyId(userId, vocabularyId);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<UserVocabulary> getUserLearningList(Long userId, Pageable pageable) {
        return userVocabularyRepository.findByUserId(userId, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<UserVocabulary> getUserMasteredVocabularies(Long userId, Pageable pageable) {
        return userVocabularyRepository.findByUserIdAndMasteryLevel(userId, 
            UserVocabulary.MasteryLevel.EXPERT, pageable);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<UserVocabulary> getVocabulariesForReview(Long userId, int limit) {
        return userVocabularyRepository.findVocabulariesForReview(userId, LocalDateTime.now(), 
            PageRequest.of(0, limit));
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<UserVocabulary> getTodayLearningVocabularies(Long userId, int limit) {
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        LocalDateTime endOfDay = startOfDay.plusDays(1);
        return userVocabularyRepository.findTodayLearningVocabularies(userId, startOfDay, endOfDay, 
            PageRequest.of(0, limit));
    }
    
    // ==================== 学习记录管理 ====================
    
    @Override
    public UserVocabulary recordLearning(Long userId, Long vocabularyId, boolean isCorrect, 
                                        StudyType studyType, int timeSpent) {
        log.info("Recording learning for user {} vocabulary {} correct {}", userId, vocabularyId, isCorrect);
        
        UserVocabulary userVocabulary = userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId)
            .orElseGet(() -> addToLearningList(userId, vocabularyId));
        
        userVocabulary.setStudyCount(userVocabulary.getStudyCount() + 1);
        userVocabulary.setLastStudyTime((long) timeSpent);
        userVocabulary.setTotalStudyTime(userVocabulary.getTotalStudyTime() + timeSpent);
        userVocabulary.setLastReviewedAt(LocalDateTime.now());
        
        if (isCorrect) {
            userVocabulary.setCorrectCount(userVocabulary.getCorrectCount() + 1);
        } else {
            userVocabulary.setWrongCount(userVocabulary.getWrongCount() + 1);
        }
        
        userVocabulary.calculateAccuracyRate();
        
        return userVocabularyRepository.save(userVocabulary);
    }
    
    @Override
    public List<UserVocabulary> batchRecordLearning(Long userId, List<Map<String, Object>> learningData) {
        log.info("Batch recording learning for user {} with {} records", userId, learningData.size());
        List<UserVocabulary> results = new ArrayList<>();
        
        for (Map<String, Object> data : learningData) {
            Long vocabularyId = ((Number) data.get("vocabularyId")).longValue();
            boolean isCorrect = (Boolean) data.get("isCorrect");
            StudyType studyType = (StudyType) data.get("studyType");
            int timeSpent = ((Number) data.get("timeSpent")).intValue();
            
            UserVocabulary record = recordLearning(userId, vocabularyId, isCorrect, studyType, timeSpent);
            results.add(record);
        }
        
        return results;
    }
    
    @Override
    public UserVocabulary markAsMastered(Long userId, Long vocabularyId) {
        log.info("Marking vocabulary {} as mastered for user {}", vocabularyId, userId);
        
        UserVocabulary userVocabulary = userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId)
            .orElseThrow(() -> new RuntimeException("User vocabulary record not found"));
        
        userVocabulary.setMasteryLevel(UserVocabulary.MasteryLevel.EXPERT);
        return userVocabularyRepository.save(userVocabulary);
    }
    
    @Override
    public UserVocabulary resetLearningProgress(Long userId, Long vocabularyId) {
        log.info("Resetting learning progress for user {} vocabulary {}", userId, vocabularyId);
        
        UserVocabulary userVocabulary = userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId)
            .orElseThrow(() -> new RuntimeException("User vocabulary record not found"));
        
        userVocabulary.setMasteryLevel(UserVocabulary.MasteryLevel.NEW);
        userVocabulary.setStudyCount(0);
        userVocabulary.setCorrectCount(0);
        userVocabulary.setWrongCount(0);
        userVocabulary.setAccuracyRate(0.0);
        
        return userVocabularyRepository.save(userVocabulary);
    }
    
    @Override
    @Transactional(readOnly = true)
    public UserVocabulary getLearningRecord(Long userId, Long vocabularyId) {
        return userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId).orElse(null);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserLearningStats(Long userId) {
        Object[] stats = userVocabularyRepository.getUserLearningStatistics(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("totalWords", stats[0]);
        result.put("totalStudyCount", stats[1]);
        result.put("totalCorrectCount", stats[2]);
        result.put("totalWrongCount", stats[3]);
        result.put("totalStudyTime", stats[4]);
        result.put("avgAccuracyRate", stats[5]);
        return result;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<UserVocabulary> getUserLearningHistory(Long userId, LocalDateTime startDate, 
                                                      LocalDateTime endDate, Pageable pageable) {
        return userVocabularyRepository.findUserLearningHistory(userId, startDate, endDate, pageable);
    }
    
    // ==================== 复习算法 ====================
    
    @Override
    public LocalDateTime calculateNextReviewTime(UserVocabulary record, boolean isCorrect) {
        int interval = record.getReviewInterval();
        if (isCorrect) {
            interval = Math.max(1, interval * 2);
        } else {
            interval = 1;
        }
        return LocalDateTime.now().plusDays(interval);
    }
    
    @Override
    public UserVocabulary updateReviewInterval(UserVocabulary record, boolean isCorrect) {
        LocalDateTime nextReviewTime = calculateNextReviewTime(record, isCorrect);
        record.setNextReviewAt(nextReviewTime);
        
        if (isCorrect) {
            record.setReviewInterval(Math.max(1, record.getReviewInterval() * 2));
        } else {
            record.setReviewInterval(1);
        }
        
        return userVocabularyRepository.save(record);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Vocabulary> getRecommendedVocabularies(Long userId, int limit) {
        return vocabularyRepository.findByIsActiveTrueOrderByCreatedAtDesc(PageRequest.of(0, limit));
    }
    
    // ==================== 词汇导入导出 ====================
    
    @Override
    public Map<String, Object> importVocabulariesFromFile(MultipartFile file, String category) {
        log.info("Importing vocabularies from file: {}", file.getOriginalFilename());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("importedCount", 0);
        result.put("message", "Import functionality not implemented yet");
        return result;
    }
    
    @Override
    @Transactional(readOnly = true)
    public byte[] exportVocabularies(List<Long> vocabularyIds, String format) {
        log.info("Exporting {} vocabularies in format {}", vocabularyIds.size(), format);
        return "Export functionality not implemented yet".getBytes();
    }
    
    @Override
    @Transactional(readOnly = true)
    public byte[] exportUserLearningData(Long userId, String format) {
        log.info("Exporting user {} learning data in format {}", userId, format);
        return "Export functionality not implemented yet".getBytes();
    }
    
    // ==================== 词汇分析和统计 ====================
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getVocabularyStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCount", vocabularyRepository.count());
        stats.put("activeCount", vocabularyRepository.countByIsActive(true));
        return stats;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Long> getCategoryStatistics() {
        Map<String, Long> stats = new HashMap<>();
        stats.put("total", vocabularyRepository.count());
        return stats;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<Vocabulary.DifficultyLevel, Long> getLevelStatistics() {
        List<Object[]> results = vocabularyRepository.getDifficultyLevelStatistics();
        return results.stream()
            .collect(Collectors.toMap(
                result -> (Vocabulary.DifficultyLevel) result[0],
                result -> (Long) result[1]
            ));
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getLearningTrend(Long userId, int days) {
        LocalDateTime startDate = LocalDateTime.now().minusDays(days);
        List<Object[]> results = userVocabularyRepository.getUserLearningTrend(userId, startDate);
        
        return results.stream()
            .map(result -> {
                Map<String, Object> trend = new HashMap<>();
                trend.put("date", result[0]);
                trend.put("wordsStudied", result[1]);
                trend.put("totalTime", result[2]);
                return trend;
            })
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getMasteryAnalysis(Long userId) {
        List<Object[]> results = userVocabularyRepository.getUserMasteryDistribution(userId);
        Map<String, Object> analysis = new HashMap<>();
        
        for (Object[] result : results) {
            UserVocabulary.MasteryLevel level = (UserVocabulary.MasteryLevel) result[0];
            Long count = (Long) result[1];
            Double avgAccuracy = (Double) result[2];
            
            Map<String, Object> levelData = new HashMap<>();
            levelData.put("count", count);
            levelData.put("avgAccuracy", avgAccuracy);
            analysis.put(level.name(), levelData);
        }
        
        return analysis;
    }
    
    // ==================== 词汇收藏和标签 ====================
    
    @Override
    public void favoriteVocabulary(Long userId, Long vocabularyId) {
        UserVocabulary userVocabulary = userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId)
            .orElseGet(() -> addToLearningList(userId, vocabularyId));
        userVocabulary.setIsFavorite(true);
        userVocabularyRepository.save(userVocabulary);
    }
    
    @Override
    public void unfavoriteVocabulary(Long userId, Long vocabularyId) {
        UserVocabulary userVocabulary = userVocabularyRepository.findByUserIdAndVocabularyId(userId, vocabularyId)
            .orElse(null);
        if (userVocabulary != null) {
            userVocabulary.setIsFavorite(false);
            userVocabularyRepository.save(userVocabulary);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> getUserFavoriteVocabularies(Long userId, Pageable pageable) {
        Page<UserVocabulary> userVocabularies = userVocabularyRepository.findByUserIdAndIsFavoriteTrue(userId, pageable);
        return userVocabularies.map(UserVocabulary::getVocabulary);
    }
    
    @Override
    public Vocabulary addTagsToVocabulary(Long vocabularyId, List<String> tags) {
        Vocabulary vocabulary = getVocabularyById(vocabularyId);
        List<String> currentTags = vocabulary.getTags();
        Set<String> tagSet = new HashSet<>();
        
        if (currentTags != null && !currentTags.isEmpty()) {
            tagSet.addAll(currentTags);
        }
        tagSet.addAll(tags);
        
        vocabulary.setTags(new ArrayList<>(tagSet));
        return vocabularyRepository.save(vocabulary);
    }
    
    @Override
    public Vocabulary removeTagsFromVocabulary(Long vocabularyId, List<String> tags) {
        Vocabulary vocabulary = getVocabularyById(vocabularyId);
        List<String> currentTags = vocabulary.getTags();
        
        if (currentTags != null && !currentTags.isEmpty()) {
            Set<String> tagSet = new HashSet<>(currentTags);
            tagSet.removeAll(tags);
            vocabulary.setTags(new ArrayList<>(tagSet));
        }
        
        return vocabularyRepository.save(vocabulary);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<String> getAllTags() {
        return vocabularyRepository.findAllTags();
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<Vocabulary> getVocabulariesByTag(String tag, Pageable pageable) {
        return vocabularyRepository.findByTag(tag, pageable);
    }
}