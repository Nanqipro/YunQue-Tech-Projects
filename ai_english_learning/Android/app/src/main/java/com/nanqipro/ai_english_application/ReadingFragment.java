package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class ReadingFragment extends Fragment {

    private RecyclerView readingLevelsRecyclerView;
    private RecyclerView readingCategoriesRecyclerView;
    private RecyclerView readingFeaturesRecyclerView;
    private ReadingLevelAdapter levelAdapter;
    private ReadingCategoryAdapter categoryAdapter;
    private ReadingFeatureAdapter featureAdapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_reading, container, false);
        
        initViews(view);
        setupRecyclerViews();
        
        return view;
    }

    private void initViews(View view) {
        readingLevelsRecyclerView = view.findViewById(R.id.reading_levels_recycler_view);
        readingCategoriesRecyclerView = view.findViewById(R.id.reading_categories_recycler_view);
        readingFeaturesRecyclerView = view.findViewById(R.id.reading_features_recycler_view);
    }

    private void setupRecyclerViews() {
        // 设置阅读等级
        readingLevelsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        List<ReadingLevel> readingLevels = createReadingLevels();
        levelAdapter = new ReadingLevelAdapter(readingLevels);
        levelAdapter.setOnItemClickListener(this::onReadingLevelClick);
        readingLevelsRecyclerView.setAdapter(levelAdapter);

        // 设置阅读分类
        readingCategoriesRecyclerView.setLayoutManager(new GridLayoutManager(getContext(), 2));
        List<ReadingCategory> categories = createReadingCategories();
        categoryAdapter = new ReadingCategoryAdapter(categories);
        categoryAdapter.setOnItemClickListener(this::onReadingCategoryClick);
        readingCategoriesRecyclerView.setAdapter(categoryAdapter);

        // 设置AI功能
        readingFeaturesRecyclerView.setLayoutManager(new GridLayoutManager(getContext(), 2));
        List<ReadingFeature> features = createReadingFeatures();
        featureAdapter = new ReadingFeatureAdapter(features);
        featureAdapter.setOnItemClickListener(this::onReadingFeatureClick);
        readingFeaturesRecyclerView.setAdapter(featureAdapter);
    }
    
    private void onReadingLevelClick(ReadingLevel level) {
        if (getContext() != null) {
            android.widget.Toast.makeText(getContext(), 
                "选择阅读等级: " + level.level + "\n" + level.description, 
                android.widget.Toast.LENGTH_SHORT).show();
            
            // 跳转到阅读文章列表
            android.content.Intent intent = new android.content.Intent(getContext(), ReadingArticlesActivity.class);
            intent.putExtra("level", level.level);
            intent.putExtra("target", level.target);
            intent.putExtra("description", level.description);
            startActivity(intent);
        }
    }
    
    private void onReadingCategoryClick(ReadingCategory category) {
        if (getContext() != null) {
            android.widget.Toast.makeText(getContext(), 
                "选择分类: " + category.title + "\n" + category.description, 
                android.widget.Toast.LENGTH_SHORT).show();
            
            // 跳转到分类文章列表
            android.content.Intent intent = new android.content.Intent(getContext(), ReadingArticlesActivity.class);
            intent.putExtra("category", category.title);
            intent.putExtra("description", category.description);
            startActivity(intent);
        }
    }
    
    private void onReadingFeatureClick(ReadingFeature feature) {
        if (getContext() != null) {
            android.widget.Toast.makeText(getContext(), 
                "启动功能: " + feature.title + "\n" + feature.description, 
                android.widget.Toast.LENGTH_SHORT).show();
            
            // 暂时所有功能都显示开发中提示
            switch (feature.title) {
                case "AI伴读":
                    android.widget.Toast.makeText(getContext(), "AI伴读功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                    break;
                case "段落提纲":
                    android.widget.Toast.makeText(getContext(), "段落提纲功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                    break;
                case "智能问答":
                    android.widget.Toast.makeText(getContext(), "智能问答功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                    break;
                case "阅读任务":
                    android.widget.Toast.makeText(getContext(), "阅读任务功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                    break;
                default:
                    android.widget.Toast.makeText(getContext(), "功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                    break;
            }
        }
    }

    private List<ReadingLevel> createReadingLevels() {
        List<ReadingLevel> levels = new ArrayList<>();
        levels.add(new ReadingLevel("R-L级", "小学适用", "基础阅读", R.color.primary_blue));
        levels.add(new ReadingLevel("M-P级", "中学适用", "进阶阅读", R.color.accent_green));
        levels.add(new ReadingLevel("Q-T级", "高中适用", "高级阅读", R.color.warning_orange));
        levels.add(new ReadingLevel("U-Z级", "成人适用", "专业阅读", R.color.reading_module));
        return levels;
    }

    private List<ReadingCategory> createReadingCategories() {
        List<ReadingCategory> categories = new ArrayList<>();
        categories.add(new ReadingCategory("经典文学", "世界名著节选", R.drawable.ic_literature, R.color.words_module));
        categories.add(new ReadingCategory("科普类", "科学发现介绍", R.drawable.ic_science, R.color.accent_green));
        categories.add(new ReadingCategory("时评类", "新闻评论热点", R.drawable.ic_news, R.color.warning_orange));
        categories.add(new ReadingCategory("历史类", "历史事件人物", R.drawable.ic_history, R.color.reading_module));
        return categories;
    }

    private List<ReadingFeature> createReadingFeatures() {
        List<ReadingFeature> features = new ArrayList<>();
        features.add(new ReadingFeature("AI伴读", "语音跟读纠正", R.drawable.ic_voice, R.color.primary_blue));
        features.add(new ReadingFeature("段落提纲", "智能摘要生成", R.drawable.ic_outline, R.color.accent_green));
        features.add(new ReadingFeature("智能问答", "即时答疑解惑", R.drawable.ic_qa, R.color.warning_orange));
        features.add(new ReadingFeature("阅读任务", "理解能力训练", R.drawable.ic_task, R.color.reading_module));
        return features;
    }

    // 阅读等级数据类
    public static class ReadingLevel {
        public String level;
        public String target;
        public String description;
        public int colorRes;

        public ReadingLevel(String level, String target, String description, int colorRes) {
            this.level = level;
            this.target = target;
            this.description = description;
            this.colorRes = colorRes;
        }
    }

    // 阅读分类数据类
    public static class ReadingCategory {
        public String title;
        public String description;
        public int iconRes;
        public int colorRes;

        public ReadingCategory(String title, String description, int iconRes, int colorRes) {
            this.title = title;
            this.description = description;
            this.iconRes = iconRes;
            this.colorRes = colorRes;
        }
    }

    // 阅读功能数据类
    public static class ReadingFeature {
        public String title;
        public String description;
        public int iconRes;
        public int colorRes;

        public ReadingFeature(String title, String description, int iconRes, int colorRes) {
            this.title = title;
            this.description = description;
            this.iconRes = iconRes;
            this.colorRes = colorRes;
        }
    }
}