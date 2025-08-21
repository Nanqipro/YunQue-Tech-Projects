package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.ProgressBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.card.MaterialCardView;

public class SmartLearningActivity extends AppCompatActivity {

    private TextView featureTitleText;
    private TextView currentWordText;
    private TextView currentMeaningText;
    private TextView progressText;
    private ProgressBar learningProgress;
    private MaterialCardView wordCard;
    private MaterialButton knowBtn;
    private MaterialButton dontKnowBtn;
    private MaterialButton showAnswerBtn;
    private MaterialButton nextWordBtn;
    
    private boolean isAnswerShown = false;
    private int currentWordIndex = 0;
    private int totalWords = 20;
    private String[] words = {"apple", "beautiful", "computer", "difficult", "education"};
    private String[] meanings = {"苹果", "美丽的", "电脑", "困难的", "教育"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_smart_learning);

        setupToolbar();
        initViews();
        loadFeatureData();
        setupClickListeners();
        showCurrentWord();
    }

    private void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("智能背词");
        }
    }

    private void initViews() {
        featureTitleText = findViewById(R.id.feature_title_text);
        currentWordText = findViewById(R.id.current_word_text);
        currentMeaningText = findViewById(R.id.current_meaning_text);
        progressText = findViewById(R.id.progress_text);
        learningProgress = findViewById(R.id.learning_progress);
        wordCard = findViewById(R.id.word_card);
        knowBtn = findViewById(R.id.know_btn);
        dontKnowBtn = findViewById(R.id.dont_know_btn);
        showAnswerBtn = findViewById(R.id.show_answer_btn);
        nextWordBtn = findViewById(R.id.next_word_btn);
    }

    private void loadFeatureData() {
        String featureTitle = getIntent().getStringExtra("feature_title");
        featureTitleText.setText(featureTitle != null ? featureTitle : "智能背词");
        updateProgress();
    }

    private void setupClickListeners() {
        showAnswerBtn.setOnClickListener(v -> showAnswer());
        
        knowBtn.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "很好！继续保持", android.widget.Toast.LENGTH_SHORT).show();
            nextWord();
        });
        
        dontKnowBtn.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "没关系，多练习就会了", android.widget.Toast.LENGTH_SHORT).show();
            nextWord();
        });
        
        nextWordBtn.setOnClickListener(v -> nextWord());
        
        wordCard.setOnClickListener(v -> {
            if (!isAnswerShown) {
                showAnswer();
            }
        });
    }

    private void showCurrentWord() {
        if (currentWordIndex < words.length) {
            currentWordText.setText(words[currentWordIndex]);
            currentMeaningText.setText("点击显示释义");
            currentMeaningText.setTextColor(getResources().getColor(R.color.gray_medium));
            isAnswerShown = false;
            
            showAnswerBtn.setVisibility(android.view.View.VISIBLE);
            knowBtn.setVisibility(android.view.View.GONE);
            dontKnowBtn.setVisibility(android.view.View.GONE);
            nextWordBtn.setVisibility(android.view.View.GONE);
        } else {
            // 学习完成
            currentWordText.setText("恭喜完成！");
            currentMeaningText.setText("今日学习任务已完成");
            currentMeaningText.setTextColor(getResources().getColor(R.color.accent_green));
            hideAllButtons();
        }
    }

    private void showAnswer() {
        if (currentWordIndex < meanings.length) {
            currentMeaningText.setText(meanings[currentWordIndex]);
            currentMeaningText.setTextColor(getResources().getColor(R.color.text_primary));
            isAnswerShown = true;
            
            showAnswerBtn.setVisibility(android.view.View.GONE);
            knowBtn.setVisibility(android.view.View.VISIBLE);
            dontKnowBtn.setVisibility(android.view.View.VISIBLE);
            nextWordBtn.setVisibility(android.view.View.VISIBLE);
        }
    }

    private void nextWord() {
        currentWordIndex++;
        updateProgress();
        showCurrentWord();
    }

    private void updateProgress() {
        int progress = Math.min(currentWordIndex, totalWords);
        progressText.setText(String.format("进度: %d/%d", progress, totalWords));
        learningProgress.setMax(totalWords);
        learningProgress.setProgress(progress);
    }

    private void hideAllButtons() {
        showAnswerBtn.setVisibility(android.view.View.GONE);
        knowBtn.setVisibility(android.view.View.GONE);
        dontKnowBtn.setVisibility(android.view.View.GONE);
        nextWordBtn.setVisibility(android.view.View.GONE);
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