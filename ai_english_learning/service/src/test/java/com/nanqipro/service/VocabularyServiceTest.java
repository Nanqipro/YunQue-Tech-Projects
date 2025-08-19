package com.nanqipro.service;

import com.nanqipro.entity.Vocabulary;
import com.nanqipro.repository.VocabularyRepository;
import com.nanqipro.service.impl.VocabularyServiceImpl;
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

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * 词汇服务测试类
 */
@ExtendWith(MockitoExtension.class)
class VocabularyServiceTest {

    @Mock
    private VocabularyRepository vocabularyRepository;

    @InjectMocks
    private VocabularyServiceImpl vocabularyService;

    private Vocabulary testVocabulary;

    @BeforeEach
    void setUp() {
        testVocabulary = new Vocabulary();
        testVocabulary.setId(1L);
        testVocabulary.setWord("hello");
        testVocabulary.setPhoneticUs("/həˈloʊ/");
        testVocabulary.setDifficultyLevel(Vocabulary.DifficultyLevel.BEGINNER);
        testVocabulary.setWordType(Vocabulary.WordType.WORD);
    }

    @Test
    void testGetVocabularyById_Success() {
        // Given
        when(vocabularyRepository.findById(1L)).thenReturn(Optional.of(testVocabulary));

        // When
        Vocabulary result = vocabularyService.getVocabularyById(1L);

        // Then
        assertNotNull(result);
        assertEquals("hello", result.getWord());
        verify(vocabularyRepository, times(1)).findById(1L);
    }

    @Test
    void testGetVocabularies_Success() {
        // Given
        Pageable pageable = PageRequest.of(0, 10);
        List<Vocabulary> vocabularies = Arrays.asList(testVocabulary);
        Page<Vocabulary> page = new PageImpl<>(vocabularies, pageable, 1);
        when(vocabularyRepository.findAll(pageable)).thenReturn(page);

        // When
        Page<Vocabulary> result = vocabularyService.getVocabularies(pageable);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        assertEquals("hello", result.getContent().get(0).getWord());
        verify(vocabularyRepository, times(1)).findAll(pageable);
    }

    @Test
    void testGetAllVocabularies_Success() {
        // Given
        Pageable pageable = PageRequest.of(0, 10);
        List<Vocabulary> vocabularies = Arrays.asList(testVocabulary);
        Page<Vocabulary> page = new PageImpl<>(vocabularies, pageable, 1);
        when(vocabularyRepository.findAll(pageable)).thenReturn(page);

        // When
        Page<Vocabulary> result = vocabularyService.getVocabularies(pageable);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(vocabularyRepository, times(1)).findAll(pageable);
    }

    @Test
    void testAddVocabulary_Success() {
        // Given
        when(vocabularyRepository.save(any(Vocabulary.class))).thenReturn(testVocabulary);

        // When
        Vocabulary result = vocabularyService.addVocabulary(testVocabulary);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(vocabularyRepository, times(1)).save(any(Vocabulary.class));
    }

    @Test
    void testDeleteVocabulary_Success() {
        // Given
        when(vocabularyRepository.existsById(1L)).thenReturn(true);
        doNothing().when(vocabularyRepository).deleteById(1L);

        // When
        vocabularyService.deleteVocabulary(1L);

        // Then
        verify(vocabularyRepository, times(1)).existsById(1L);
        verify(vocabularyRepository, times(1)).deleteById(1L);
    }
}