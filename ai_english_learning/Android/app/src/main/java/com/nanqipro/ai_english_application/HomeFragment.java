package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.cardview.widget.CardView;

public class HomeFragment extends Fragment {

    private TextView welcomeText;
    private TextView dailyGoalText;
    private TextView streakText;
    private TextView wordsLearnedText;
    private TextView readingTimeText;
    private CardView wordsModuleCard;
    private CardView readingModuleCard;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);
        
        initViews(view);
        setupData();
        setupClickListeners();
        
        return view;
    }

    private void initViews(View view) {
        welcomeText = view.findViewById(R.id.welcome_text);
        dailyGoalText = view.findViewById(R.id.daily_goal_text);
        streakText = view.findViewById(R.id.streak_text);
        wordsLearnedText = view.findViewById(R.id.words_learned_text);
        readingTimeText = view.findViewById(R.id.reading_time_text);
        wordsModuleCard = view.findViewById(R.id.words_module_card);
        readingModuleCard = view.findViewById(R.id.reading_module_card);
        androidx.cardview.widget.CardView aiMemoryCard = view.findViewById(R.id.ai_memory_card);
        
        // 设置AI联想记忆卡片点击事件
        if (aiMemoryCard != null) {
            aiMemoryCard.setOnClickListener(v -> {
                android.content.Intent intent = new android.content.Intent(getContext(), AIMemoryActivity.class);
                startActivity(intent);
            });
        }
    }

    private void setupData() {
        // 模拟数据
        dailyGoalText.setText("今日目标: 20个单词");
        streakText.setText("连续学习: 7天");
        wordsLearnedText.setText("已学单词: 156个");
        readingTimeText.setText("阅读时长: 45分钟");
    }

    private void setupClickListeners() {
        wordsModuleCard.setOnClickListener(v -> {
            // 切换到单词模块
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).getSupportFragmentManager()
                        .beginTransaction()
                        .replace(R.id.fragment_container, new WordsFragment())
                        .addToBackStack(null)
                        .commit();
            }
        });

        readingModuleCard.setOnClickListener(v -> {
            // 切换到阅读模块
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).getSupportFragmentManager()
                        .beginTransaction()
                        .replace(R.id.fragment_container, new ReadingFragment())
                        .addToBackStack(null)
                        .commit();
            }
        });
    }
}