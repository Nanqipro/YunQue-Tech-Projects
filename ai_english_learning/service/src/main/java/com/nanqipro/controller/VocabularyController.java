package com.nanqipro.controller;

import com.nanqipro.common.ApiResponse;
import com.nanqipro.entity.StudyType;
import com.nanqipro.entity.UserVocabulary;
import com.nanqipro.entity.Vocabulary;
import com.nanqipro.service.VocabularyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 词汇管理控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/vocabularies")
@RequiredArgsConstructor
@Tag(name = "词汇管理", description = "词汇的增删改查、学习记录、复习算法等功能")
public class VocabularyController {
    
    private final VocabularyService vocabularyService;
    
    // ==================== 词汇基础管理 ====================
    
    @PostMapping
    @Operation(summary = "添加词汇", description = "添加新的词汇到系统")
    public ResponseEntity<ApiResponse<Vocabulary>> addVocabulary(
            @Valid @RequestBody Vocabulary vocabulary) {
        log.info("Adding vocabulary: {}", vocabulary.getWord());
        Vocabulary result = vocabularyService.addVocabulary(vocabulary);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/batch")
    @Operation(summary = "批量添加词汇", description = "批量添加多个词汇")
    public ResponseEntity<ApiResponse<List<Vocabulary>>> addVocabularies(
            @Valid @RequestBody List<Vocabulary> vocabularies) {
        log.info("Batch adding {} vocabularies", vocabularies.size());
        List<Vocabulary> results = vocabularyService.addVocabularies(vocabularies);
        return ResponseEntity.ok(ApiResponse.success(results));
    }
    
    @PutMapping("/{vocabularyId}")
    @Operation(summary = "更新词汇", description = "更新指定词汇的信息")
    public ResponseEntity<ApiResponse<Vocabulary>> updateVocabulary(
            @PathVariable Long vocabularyId,
            @Valid @RequestBody Vocabulary vocabulary) {
        log.info("Updating vocabulary with id: {}", vocabularyId);
        Vocabulary result = vocabularyService.updateVocabulary(vocabularyId, vocabulary);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @DeleteMapping("/{vocabularyId}")
    @Operation(summary = "删除词汇", description = "删除指定的词汇")
    public ResponseEntity<ApiResponse<Void>> deleteVocabulary(
            @PathVariable Long vocabularyId) {
        log.info("Deleting vocabulary with id: {}", vocabularyId);
        vocabularyService.deleteVocabulary(vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @DeleteMapping("/batch")
    @Operation(summary = "批量删除词汇", description = "批量删除多个词汇")
    public ResponseEntity<ApiResponse<Void>> deleteVocabularies(
            @RequestBody List<Long> vocabularyIds) {
        log.info("Batch deleting {} vocabularies", vocabularyIds.size());
        vocabularyService.deleteVocabularies(vocabularyIds);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/{vocabularyId}")
    @Operation(summary = "获取词汇详情", description = "根据ID获取词汇详细信息")
    public ResponseEntity<ApiResponse<Vocabulary>> getVocabularyById(
            @PathVariable Long vocabularyId) {
        Vocabulary vocabulary = vocabularyService.getVocabularyById(vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(vocabulary));
    }
    
    @GetMapping("/word/{word}")
    @Operation(summary = "根据单词获取词汇", description = "根据单词获取词汇信息")
    public ResponseEntity<ApiResponse<Vocabulary>> getVocabularyByWord(
            @PathVariable String word) {
        Vocabulary vocabulary = vocabularyService.getVocabularyByWord(word);
        return ResponseEntity.ok(ApiResponse.success(vocabulary));
    }
    
    @GetMapping("/exists/{word}")
    @Operation(summary = "检查单词是否存在", description = "检查指定单词是否已存在于系统中")
    public ResponseEntity<ApiResponse<Boolean>> existsByWord(
            @PathVariable String word) {
        boolean exists = vocabularyService.existsByWord(word);
        return ResponseEntity.ok(ApiResponse.success(exists));
    }
    
    // ==================== 词汇查询和搜索 ====================
    
    @GetMapping
    @Operation(summary = "获取词汇列表", description = "分页获取词汇列表")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> getVocabularies(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<Vocabulary> vocabularies = vocabularyService.getVocabularies(pageable);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/level/{level}")
    @Operation(summary = "按难度级别获取词汇", description = "根据难度级别分页获取词汇")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> getVocabulariesByLevel(
            @PathVariable Vocabulary.DifficultyLevel level,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Vocabulary> vocabularies = vocabularyService.getVocabulariesByLevel(level, pageable);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/category/{category}")
    @Operation(summary = "按分类获取词汇", description = "根据分类标签分页获取词汇")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> getVocabulariesByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Vocabulary> vocabularies = vocabularyService.getVocabulariesByCategory(category, pageable);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/search")
    @Operation(summary = "搜索词汇", description = "根据关键词搜索词汇")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> searchVocabularies(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Vocabulary> vocabularies = vocabularyService.searchVocabularies(keyword, pageable);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/search/advanced")
    @Operation(summary = "高级搜索词汇", description = "根据多个条件进行高级搜索")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> advancedSearchVocabularies(
            @RequestParam(required = false) String word,
            @RequestParam(required = false) Vocabulary.DifficultyLevel level,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) List<String> tags,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Vocabulary> vocabularies = vocabularyService.advancedSearchVocabularies(
            word, level, category, tags, pageable);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/random")
    @Operation(summary = "获取随机词汇", description = "获取指定数量的随机词汇")
    public ResponseEntity<ApiResponse<List<Vocabulary>>> getRandomVocabularies(
            @RequestParam(defaultValue = "10") int count,
            @RequestParam(required = false) Vocabulary.DifficultyLevel level) {
        
        List<Vocabulary> vocabularies = vocabularyService.getRandomVocabularies(count, level);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/popular")
    @Operation(summary = "获取热门词汇", description = "获取最受欢迎的词汇")
    public ResponseEntity<ApiResponse<List<Vocabulary>>> getPopularVocabularies(
            @RequestParam(defaultValue = "10") int limit) {
        
        List<Vocabulary> vocabularies = vocabularyService.getPopularVocabularies(limit);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    @GetMapping("/latest")
    @Operation(summary = "获取最新词汇", description = "获取最新添加的词汇")
    public ResponseEntity<ApiResponse<List<Vocabulary>>> getLatestVocabularies(
            @RequestParam(defaultValue = "10") int limit) {
        
        List<Vocabulary> vocabularies = vocabularyService.getLatestVocabularies(limit);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
    
    // ==================== 用户词汇学习 ====================
    
    @PostMapping("/{vocabularyId}/learn")
    @Operation(summary = "添加到学习列表", description = "将词汇添加到用户的学习列表")
    public ResponseEntity<ApiResponse<UserVocabulary>> addToLearningList(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        UserVocabulary result = vocabularyService.addToLearningList(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/learn/batch")
    @Operation(summary = "批量添加到学习列表", description = "批量将词汇添加到用户的学习列表")
    public ResponseEntity<ApiResponse<List<UserVocabulary>>> addToLearningList(
            @RequestBody List<Long> vocabularyIds,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<UserVocabulary> results = vocabularyService.addToLearningList(userId, vocabularyIds);
        return ResponseEntity.ok(ApiResponse.success(results));
    }
    
    @DeleteMapping("/{vocabularyId}/learn")
    @Operation(summary = "从学习列表移除", description = "将词汇从用户的学习列表中移除")
    public ResponseEntity<ApiResponse<Void>> removeFromLearningList(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        vocabularyService.removeFromLearningList(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/my-learning")
    @Operation(summary = "获取我的学习列表", description = "获取用户的词汇学习列表")
    public ResponseEntity<ApiResponse<Page<UserVocabulary>>> getUserLearningList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size);
        Page<UserVocabulary> learningList = vocabularyService.getUserLearningList(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(learningList));
    }
    
    @GetMapping("/my-mastered")
    @Operation(summary = "获取已掌握词汇", description = "获取用户已掌握的词汇列表")
    public ResponseEntity<ApiResponse<Page<UserVocabulary>>> getUserMasteredVocabularies(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size);
        Page<UserVocabulary> masteredList = vocabularyService.getUserMasteredVocabularies(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(masteredList));
    }
    
    @GetMapping("/review")
    @Operation(summary = "获取复习词汇", description = "获取需要复习的词汇列表")
    public ResponseEntity<ApiResponse<List<UserVocabulary>>> getVocabulariesForReview(
            @RequestParam(defaultValue = "20") int limit,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<UserVocabulary> reviewList = vocabularyService.getVocabulariesForReview(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(reviewList));
    }
    
    @GetMapping("/today")
    @Operation(summary = "获取今日学习词汇", description = "获取今日学习的词汇列表")
    public ResponseEntity<ApiResponse<List<UserVocabulary>>> getTodayLearningVocabularies(
            @RequestParam(defaultValue = "20") int limit,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<UserVocabulary> todayList = vocabularyService.getTodayLearningVocabularies(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(todayList));
    }
    
    // ==================== 学习记录管理 ====================
    
    @PostMapping("/{vocabularyId}/record")
    @Operation(summary = "记录学习", description = "记录用户对词汇的学习情况")
    public ResponseEntity<ApiResponse<UserVocabulary>> recordLearning(
            @PathVariable Long vocabularyId,
            @RequestParam boolean isCorrect,
            @RequestParam StudyType studyType,
            @RequestParam int timeSpent,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        UserVocabulary result = vocabularyService.recordLearning(userId, vocabularyId, isCorrect, studyType, timeSpent);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/record/batch")
    @Operation(summary = "批量记录学习", description = "批量记录用户的学习情况")
    public ResponseEntity<ApiResponse<List<UserVocabulary>>> batchRecordLearning(
            @RequestBody List<Map<String, Object>> learningData,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<UserVocabulary> results = vocabularyService.batchRecordLearning(userId, learningData);
        return ResponseEntity.ok(ApiResponse.success(results));
    }
    
    @PostMapping("/{vocabularyId}/master")
    @Operation(summary = "标记为已掌握", description = "将词汇标记为已掌握")
    public ResponseEntity<ApiResponse<UserVocabulary>> markAsMastered(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        UserVocabulary result = vocabularyService.markAsMastered(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/{vocabularyId}/reset")
    @Operation(summary = "重置学习进度", description = "重置词汇的学习进度")
    public ResponseEntity<ApiResponse<UserVocabulary>> resetLearningProgress(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        UserVocabulary result = vocabularyService.resetLearningProgress(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @GetMapping("/{vocabularyId}/record")
    @Operation(summary = "获取学习记录", description = "获取用户对特定词汇的学习记录")
    public ResponseEntity<ApiResponse<UserVocabulary>> getLearningRecord(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        UserVocabulary record = vocabularyService.getLearningRecord(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(record));
    }
    
    @GetMapping("/stats")
    @Operation(summary = "获取学习统计", description = "获取用户的学习统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserLearningStats(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> stats = vocabularyService.getUserLearningStats(userId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/history")
    @Operation(summary = "获取学习历史", description = "获取用户的学习历史记录")
    public ResponseEntity<ApiResponse<Page<UserVocabulary>>> getUserLearningHistory(
            @RequestParam(required = false) @Parameter(description = "开始日期") LocalDateTime startDate,
            @RequestParam(required = false) @Parameter(description = "结束日期") LocalDateTime endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size);
        Page<UserVocabulary> history = vocabularyService.getUserLearningHistory(userId, startDate, endDate, pageable);
        return ResponseEntity.ok(ApiResponse.success(history));
    }
    
    // ==================== 复习算法 ====================
    
    @GetMapping("/recommended")
    @Operation(summary = "获取推荐词汇", description = "根据算法获取推荐学习的词汇")
    public ResponseEntity<ApiResponse<List<Vocabulary>>> getRecommendedVocabularies(
            @RequestParam(defaultValue = "10") int limit,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<Vocabulary> recommended = vocabularyService.getRecommendedVocabularies(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(recommended));
    }
    
    // ==================== 词汇导入导出 ====================
    
    @PostMapping("/import")
    @Operation(summary = "导入词汇", description = "从文件导入词汇")
    public ResponseEntity<ApiResponse<Map<String, Object>>> importVocabularies(
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false) String category) {
        
        Map<String, Object> result = vocabularyService.importVocabulariesFromFile(file, category);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @PostMapping("/export")
    @Operation(summary = "导出词汇", description = "导出指定词汇")
    public ResponseEntity<byte[]> exportVocabularies(
            @RequestBody List<Long> vocabularyIds,
            @RequestParam(defaultValue = "csv") String format) {
        
        byte[] data = vocabularyService.exportVocabularies(vocabularyIds, format);
        return ResponseEntity.ok()
            .header("Content-Disposition", "attachment; filename=vocabularies." + format)
            .body(data);
    }
    
    @GetMapping("/export/my-data")
    @Operation(summary = "导出学习数据", description = "导出用户的学习数据")
    public ResponseEntity<byte[]> exportUserLearningData(
            @RequestParam(defaultValue = "csv") String format,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        byte[] data = vocabularyService.exportUserLearningData(userId, format);
        return ResponseEntity.ok()
            .header("Content-Disposition", "attachment; filename=my-learning-data." + format)
            .body(data);
    }
    
    // ==================== 词汇分析和统计 ====================
    
    @GetMapping("/statistics")
    @Operation(summary = "获取词汇统计", description = "获取系统词汇的统计信息")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getVocabularyStatistics() {
        Map<String, Object> stats = vocabularyService.getVocabularyStatistics();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/statistics/categories")
    @Operation(summary = "获取分类统计", description = "获取词汇分类的统计信息")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getCategoryStatistics() {
        Map<String, Long> stats = vocabularyService.getCategoryStatistics();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/statistics/levels")
    @Operation(summary = "获取难度级别统计", description = "获取各难度级别词汇的统计信息")
    public ResponseEntity<ApiResponse<Map<Vocabulary.DifficultyLevel, Long>>> getLevelStatistics() {
        Map<Vocabulary.DifficultyLevel, Long> stats = vocabularyService.getLevelStatistics();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/statistics/learning-trend")
    @Operation(summary = "获取学习趋势", description = "获取用户的学习趋势数据")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getLearningTrend(
            @RequestParam(defaultValue = "30") int days,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        List<Map<String, Object>> trend = vocabularyService.getLearningTrend(userId, days);
        return ResponseEntity.ok(ApiResponse.success(trend));
    }
    
    @GetMapping("/statistics/mastery-analysis")
    @Operation(summary = "获取掌握度分析", description = "获取用户的词汇掌握度分析")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMasteryAnalysis(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Map<String, Object> analysis = vocabularyService.getMasteryAnalysis(userId);
        return ResponseEntity.ok(ApiResponse.success(analysis));
    }
    
    // ==================== 词汇收藏和标签 ====================
    
    @PostMapping("/{vocabularyId}/favorite")
    @Operation(summary = "收藏词汇", description = "将词汇添加到收藏列表")
    public ResponseEntity<ApiResponse<Void>> favoriteVocabulary(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        vocabularyService.favoriteVocabulary(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @DeleteMapping("/{vocabularyId}/favorite")
    @Operation(summary = "取消收藏词汇", description = "将词汇从收藏列表中移除")
    public ResponseEntity<ApiResponse<Void>> unfavoriteVocabulary(
            @PathVariable Long vocabularyId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        vocabularyService.unfavoriteVocabulary(userId, vocabularyId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @GetMapping("/favorites")
    @Operation(summary = "获取收藏词汇", description = "获取用户收藏的词汇列表")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> getUserFavoriteVocabularies(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long userId = Long.parseLong(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size);
        Page<Vocabulary> favorites = vocabularyService.getUserFavoriteVocabularies(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(favorites));
    }
    
    @PostMapping("/{vocabularyId}/tags")
    @Operation(summary = "添加标签", description = "为词汇添加标签")
    public ResponseEntity<ApiResponse<Vocabulary>> addTagsToVocabulary(
            @PathVariable Long vocabularyId,
            @RequestBody List<String> tags) {
        
        Vocabulary result = vocabularyService.addTagsToVocabulary(vocabularyId, tags);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @DeleteMapping("/{vocabularyId}/tags")
    @Operation(summary = "移除标签", description = "从词汇中移除标签")
    public ResponseEntity<ApiResponse<Vocabulary>> removeTagsFromVocabulary(
            @PathVariable Long vocabularyId,
            @RequestBody List<String> tags) {
        
        Vocabulary result = vocabularyService.removeTagsFromVocabulary(vocabularyId, tags);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    @GetMapping("/tags")
    @Operation(summary = "获取所有标签", description = "获取系统中所有的词汇标签")
    public ResponseEntity<ApiResponse<List<String>>> getAllTags() {
        List<String> tags = vocabularyService.getAllTags();
        return ResponseEntity.ok(ApiResponse.success(tags));
    }
    
    @GetMapping("/tag/{tag}")
    @Operation(summary = "按标签获取词汇", description = "根据标签获取词汇列表")
    public ResponseEntity<ApiResponse<Page<Vocabulary>>> getVocabulariesByTag(
            @PathVariable String tag,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Vocabulary> vocabularies = vocabularyService.getVocabulariesByTag(tag, pageable);
        return ResponseEntity.ok(ApiResponse.success(vocabularies));
    }
}