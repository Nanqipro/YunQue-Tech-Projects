package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.cardview.widget.CardView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class WordsFragment extends Fragment {

    private RecyclerView vocabularyRecyclerView;
    private RecyclerView featuresRecyclerView;
    private VocabularyAdapter vocabularyAdapter;
    private WordsFeatureAdapter featuresAdapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_words, container, false);
        
        initViews(view);
        setupRecyclerViews();
        
        return view;
    }

    private void initViews(View view) {
        vocabularyRecyclerView = view.findViewById(R.id.vocabulary_recycler_view);
        featuresRecyclerView = view.findViewById(R.id.features_recycler_view);
    }

    private void setupRecyclerViews() {
        // 设置词库选择
        vocabularyRecyclerView.setLayoutManager(new GridLayoutManager(getContext(), 2));
        List<VocabularyLevel> vocabularyLevels = createVocabularyLevels();
        vocabularyAdapter = new VocabularyAdapter(vocabularyLevels);
        vocabularyRecyclerView.setAdapter(vocabularyAdapter);

        // 设置功能模块
        featuresRecyclerView.setLayoutManager(new GridLayoutManager(getContext(), 2));
        List<WordsFeature> features = createWordsFeatures();
        featuresAdapter = new WordsFeatureAdapter(features);
        featuresRecyclerView.setAdapter(featuresAdapter);
    }

    private List<VocabularyLevel> createVocabularyLevels() {
        List<VocabularyLevel> levels = new ArrayList<>();
        levels.add(new VocabularyLevel("小学词汇", "基础词汇 500+", R.drawable.ic_school, R.color.primary_blue));
        levels.add(new VocabularyLevel("初中词汇", "进阶词汇 1500+", R.drawable.ic_school, R.color.accent_green));
        levels.add(new VocabularyLevel("高中词汇", "核心词汇 3500+", R.drawable.ic_school, R.color.warning_orange));
        levels.add(new VocabularyLevel("四级词汇", "大学词汇 4500+", R.drawable.ic_university, R.color.words_module));
        levels.add(new VocabularyLevel("六级词汇", "高级词汇 6000+", R.drawable.ic_university, R.color.reading_module));
        levels.add(new VocabularyLevel("托福词汇", "留学词汇 8000+", R.drawable.ic_global, R.color.profile_module));
        levels.add(new VocabularyLevel("雅思词汇", "国际词汇 9000+", R.drawable.ic_global, R.color.error_red));
        levels.add(new VocabularyLevel("自定义", "个性化词库", R.drawable.ic_custom, R.color.gray_medium));
        return levels;
    }

    private List<WordsFeature> createWordsFeatures() {
        List<WordsFeature> features = new ArrayList<>();
        features.add(new WordsFeature("智能背词", "AI记忆曲线", R.drawable.ic_brain, R.color.primary_blue));
        features.add(new WordsFeature("语境记忆", "真实场景学习", R.drawable.ic_context, R.color.accent_green));
        features.add(new WordsFeature("智能测试", "多样化练习", R.drawable.ic_quiz, R.color.warning_orange));
        features.add(new WordsFeature("能力画像", "学习分析报告", R.drawable.ic_chart, R.color.words_module));
        return features;
    }

    // 词汇等级数据类
    public static class VocabularyLevel {
        public String title;
        public String description;
        public int iconRes;
        public int colorRes;

        public VocabularyLevel(String title, String description, int iconRes, int colorRes) {
            this.title = title;
            this.description = description;
            this.iconRes = iconRes;
            this.colorRes = colorRes;
        }
    }

    // 单词功能数据类
    public static class WordsFeature {
        public String title;
        public String description;
        public int iconRes;
        public int colorRes;

        public WordsFeature(String title, String description, int iconRes, int colorRes) {
            this.title = title;
            this.description = description;
            this.iconRes = iconRes;
            this.colorRes = colorRes;
        }
    }
}