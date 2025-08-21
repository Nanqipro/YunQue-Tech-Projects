package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.cardview.widget.CardView;
import com.google.android.material.button.MaterialButton;

public class LearningReportActivity extends AppCompatActivity {

    private TextView reportTitleText;
    private TextView totalWordsText;
    private TextView totalReadingText;
    private TextView studyTimeText;
    private TextView accuracyText;
    private TextView streakDaysText;
    private TextView weeklyGoalText;
    private MaterialButton shareReportBtn;
    private MaterialButton exportReportBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_learning_report);

        setupToolbar();
        initViews();
        loadReportData();
        setupClickListeners();
    }

    private void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("学习报告");
        }
    }

    private void initViews() {
        reportTitleText = findViewById(R.id.report_title_text);
        totalWordsText = findViewById(R.id.total_words_text);
        totalReadingText = findViewById(R.id.total_reading_text);
        studyTimeText = findViewById(R.id.study_time_text);
        accuracyText = findViewById(R.id.accuracy_text);
        streakDaysText = findViewById(R.id.streak_days_text);
        weeklyGoalText = findViewById(R.id.weekly_goal_text);
        shareReportBtn = findViewById(R.id.share_report_btn);
        exportReportBtn = findViewById(R.id.export_report_btn);
    }

    private void loadReportData() {
        // 模拟学习数据
        reportTitleText.setText("本周学习报告");
        totalWordsText.setText("156");
        totalReadingText.setText("12");
        studyTimeText.setText("8.5小时");
        accuracyText.setText("87%");
        streakDaysText.setText("15天");
        weeklyGoalText.setText("已完成 85%");
    }

    private void setupClickListeners() {
        shareReportBtn.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "分享学习报告", android.widget.Toast.LENGTH_SHORT).show();
            // 这里可以实现分享功能
            shareReport();
        });

        exportReportBtn.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "导出学习报告", android.widget.Toast.LENGTH_SHORT).show();
            // 这里可以实现导出功能
            exportReport();
        });
    }

    private void shareReport() {
        String reportText = "我的AI英语学习报告:\n" +
                "📚 本周学习单词: " + totalWordsText.getText() + "个\n" +
                "📖 阅读文章: " + totalReadingText.getText() + "篇\n" +
                "⏰ 学习时长: " + studyTimeText.getText() + "\n" +
                "🎯 准确率: " + accuracyText.getText() + "\n" +
                "🔥 连续学习: " + streakDaysText.getText() + "\n" +
                "\n坚持学习，进步每一天！";

        android.content.Intent shareIntent = new android.content.Intent(android.content.Intent.ACTION_SEND);
        shareIntent.setType("text/plain");
        shareIntent.putExtra(android.content.Intent.EXTRA_TEXT, reportText);
        shareIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, "我的英语学习报告");
        startActivity(android.content.Intent.createChooser(shareIntent, "分享学习报告"));
    }

    private void exportReport() {
        // 模拟导出功能
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(this);
        builder.setTitle("导出报告")
                .setMessage("选择导出格式:")
                .setPositiveButton("PDF", (dialog, which) -> {
                    android.widget.Toast.makeText(this, "正在生成PDF报告...", android.widget.Toast.LENGTH_SHORT).show();
                })
                .setNegativeButton("Excel", (dialog, which) -> {
                    android.widget.Toast.makeText(this, "正在生成Excel报告...", android.widget.Toast.LENGTH_SHORT).show();
                })
                .setNeutralButton("取消", null)
                .show();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}