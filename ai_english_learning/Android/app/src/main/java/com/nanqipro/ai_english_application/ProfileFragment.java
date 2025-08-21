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
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class ProfileFragment extends Fragment {

    private TextView userNameText;
    private TextView userLevelText;
    private TextView totalWordsText;
    private TextView totalReadingText;
    private TextView streakDaysText;
    private RecyclerView achievementsRecyclerView;
    private RecyclerView settingsRecyclerView;
    private AchievementAdapter achievementAdapter;
    private SettingAdapter settingAdapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);
        
        initViews(view);
        setupData();
        setupRecyclerViews();
        
        return view;
    }

    private void initViews(View view) {
        userNameText = view.findViewById(R.id.user_name_text);
        userLevelText = view.findViewById(R.id.user_level_text);
        totalWordsText = view.findViewById(R.id.total_words_text);
        totalReadingText = view.findViewById(R.id.total_reading_text);
        streakDaysText = view.findViewById(R.id.streak_days_text);
        achievementsRecyclerView = view.findViewById(R.id.achievements_recycler_view);
        settingsRecyclerView = view.findViewById(R.id.settings_recycler_view);
    }

    private void setupData() {
        // 模拟用户数据
        userNameText.setText("英语学习者");
        userLevelText.setText("中级学习者");
        totalWordsText.setText("1,256");
        totalReadingText.setText("45");
        streakDaysText.setText("15");
    }

    private void setupRecyclerViews() {
        // 设置成就列表
        achievementsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        List<Achievement> achievements = createAchievements();
        achievementAdapter = new AchievementAdapter(achievements);
        achievementAdapter.setOnItemClickListener(this::onAchievementClick);
        achievementsRecyclerView.setAdapter(achievementAdapter);

        // 设置设置列表
        settingsRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        List<Setting> settings = createSettings();
        settingAdapter = new SettingAdapter(settings);
        settingAdapter.setOnItemClickListener(this::onSettingClick);
        settingsRecyclerView.setAdapter(settingAdapter);
    }
    
    private void onAchievementClick(Achievement achievement) {
        if (getContext() != null) {
            String message = achievement.isUnlocked ? 
                "恭喜获得成就: " + achievement.title + "\n" + achievement.description :
                "未解锁成就: " + achievement.title + "\n" + achievement.description;
            android.widget.Toast.makeText(getContext(), message, android.widget.Toast.LENGTH_LONG).show();
        }
    }
    
    private void onSettingClick(Setting setting) {
        if (getContext() != null) {
            android.widget.Toast.makeText(getContext(), 
                "打开设置: " + setting.title, 
                android.widget.Toast.LENGTH_SHORT).show();
            
            // 根据不同设置项启动不同Activity或功能
             android.content.Intent intent = null;
             switch (setting.title) {
                 case "学习提醒":
                     android.widget.Toast.makeText(getContext(), "学习提醒功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                     return;
                 case "学习报告":
                     intent = new android.content.Intent(getContext(), LearningReportActivity.class);
                     break;
                 case "语音设置":
                     android.widget.Toast.makeText(getContext(), "语音设置功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                     return;
                 case "主题设置":
                     android.widget.Toast.makeText(getContext(), "主题设置功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                     return;
                 case "关于我们":
                     android.widget.Toast.makeText(getContext(), "关于我们功能开发中...", android.widget.Toast.LENGTH_SHORT).show();
                     return;
                 default:
                     return;
             }
             if (intent != null) {
                 intent.putExtra("setting_title", setting.title);
                 intent.putExtra("setting_description", setting.description);
                 startActivity(intent);
             }
        }
    }

    private List<Achievement> createAchievements() {
        List<Achievement> achievements = new ArrayList<>();
        achievements.add(new Achievement("初学者", "完成首次学习", R.drawable.ic_star, true));
        achievements.add(new Achievement("坚持者", "连续学习7天", R.drawable.ic_fire, true));
        achievements.add(new Achievement("词汇达人", "学习1000个单词", R.drawable.ic_book, true));
        achievements.add(new Achievement("阅读爱好者", "阅读10篇文章", R.drawable.ic_reading, false));
        achievements.add(new Achievement("学习专家", "连续学习30天", R.drawable.ic_target, false));
        return achievements;
    }

    private List<Setting> createSettings() {
        List<Setting> settings = new ArrayList<>();
        settings.add(new Setting("学习提醒", "设置每日学习提醒", R.drawable.ic_notification));
        settings.add(new Setting("学习报告", "查看详细学习分析", R.drawable.ic_chart));
        settings.add(new Setting("语音设置", "选择发音偏好", R.drawable.ic_voice));
        settings.add(new Setting("主题设置", "切换应用主题", R.drawable.ic_theme));
        settings.add(new Setting("关于我们", "应用信息和反馈", R.drawable.ic_info));
        return settings;
    }

    // 成就数据类
    public static class Achievement {
        public String title;
        public String description;
        public int iconRes;
        public boolean isUnlocked;

        public Achievement(String title, String description, int iconRes, boolean isUnlocked) {
            this.title = title;
            this.description = description;
            this.iconRes = iconRes;
            this.isUnlocked = isUnlocked;
        }
    }

    // 设置数据类
    public static class Setting {
        public String title;
        public String description;
        public int iconRes;

        public Setting(String title, String description, int iconRes) {
            this.title = title;
            this.description = description;
            this.iconRes = iconRes;
        }
    }
}