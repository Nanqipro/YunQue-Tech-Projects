package com.nanqipro.service;

import com.nanqipro.entity.Article;
import com.nanqipro.repository.ArticleRepository;
import com.nanqipro.service.impl.ArticleServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * 文章服务测试类
 */
@ExtendWith(MockitoExtension.class)
class ArticleServiceTest {

    @Mock
    private ArticleRepository articleRepository;

    @InjectMocks
    private ArticleServiceImpl articleService;

    private Article testArticle;

    @BeforeEach
    void setUp() {
        testArticle = new Article();
        testArticle.setId(1L);
        testArticle.setTitle("Test Article");
        testArticle.setContent("This is a test article content.");
        testArticle.setDifficultyLevel(Article.DifficultyLevel.INTERMEDIATE);
        testArticle.setCategory(Article.Category.TECHNOLOGY);
        testArticle.setWordCount(100);
        testArticle.setEstimatedReadingTime(5);
        testArticle.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void testGetArticleById_Success() {
        // Given
        when(articleRepository.findById(1L)).thenReturn(Optional.of(testArticle));

        // When
        Article result = articleService.getArticleById(1L);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("Test Article", result.getTitle());
        verify(articleRepository, times(1)).findById(1L);
    }

    @Test
    void testGetArticleById_NotFound() {
        // Given
        when(articleRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(RuntimeException.class, () -> {
            articleService.getArticleById(1L);
        });
        verify(articleRepository, times(1)).findById(1L);
    }

    @Test
    void testGetAllArticles_Success() {
        // Given
        Pageable pageable = PageRequest.of(0, 10);
        List<Article> articles = Arrays.asList(testArticle);
        Page<Article> page = new PageImpl<>(articles, pageable, 1);
        when(articleRepository.findAll(pageable)).thenReturn(page);

        // When
        Page<Article> result = articleService.getArticles(pageable);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(articleRepository, times(1)).findAll(pageable);
    }

    @Test
    void testSearchArticles_Success() {
        // Given
        String keyword = "test";
        Pageable pageable = PageRequest.of(0, 10);
        List<Article> articles = Arrays.asList(testArticle);
        Page<Article> page = new PageImpl<>(articles, pageable, 1);
        when(articleRepository.findByTitleContainingIgnoreCase(keyword, pageable))
                .thenReturn(page);

        // When
        Page<Article> result = articleService.searchArticles(keyword, pageable);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(articleRepository, times(1))
                .findByTitleContainingIgnoreCase(keyword, pageable);
    }

    @Test
    void testGetArticlesByDifficulty_Success() {
        // Given
        Article.DifficultyLevel difficulty = Article.DifficultyLevel.INTERMEDIATE;
        Pageable pageable = PageRequest.of(0, 10);
        List<Article> articles = Arrays.asList(testArticle);
        Page<Article> page = new PageImpl<>(articles, pageable, 1);
        when(articleRepository.findByDifficultyLevel(difficulty, pageable))
                .thenReturn(page);

        // When
        Page<Article> result = articleService.getArticlesByLevel(difficulty, pageable);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(articleRepository, times(1))
                .findByDifficultyLevel(difficulty, pageable);
    }

    @Test
    void testGetArticlesByCategory_Success() {
        // Given
        Article.Category category = Article.Category.TECHNOLOGY;
        Pageable pageable = PageRequest.of(0, 10);
        List<Article> articles = Arrays.asList(testArticle);
        Page<Article> page = new PageImpl<>(articles, pageable, 1);
        when(articleRepository.findByCategory(category, pageable))
                .thenReturn(page);

        // When
        Page<Article> result = articleService.getArticlesByType(category, pageable);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(articleRepository, times(1))
                .findByCategory(category, pageable);
    }

    @Test
    void testAddArticle_Success() {
        // Given
        when(articleRepository.save(any(Article.class))).thenReturn(testArticle);

        // When
        Article result = articleService.addArticle(testArticle);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(articleRepository, times(1)).save(any(Article.class));
    }

    @Test
    void testUpdateArticle_Success() {
        // Given
        when(articleRepository.existsById(1L)).thenReturn(true);
        when(articleRepository.save(any(Article.class))).thenReturn(testArticle);

        // When
        Article result = articleService.updateArticle(1L, testArticle);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(articleRepository, times(1)).existsById(1L);
        verify(articleRepository, times(1)).save(testArticle);
    }

    @Test
    void testDeleteArticle_Success() {
        // Given
        when(articleRepository.existsById(1L)).thenReturn(true);
        doNothing().when(articleRepository).deleteById(1L);

        // When
        articleService.deleteArticle(1L);

        // Then
        verify(articleRepository, times(1)).existsById(1L);
        verify(articleRepository, times(1)).deleteById(1L);
    }
}