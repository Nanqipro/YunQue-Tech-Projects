package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import com.google.android.material.button.MaterialButton;

public class WordDetailActivity extends AppCompatActivity {

    private TextView wordText;
    private TextView meaningText;
    private TextView partOfSpeechText;
    private TextView exampleText;
    private TextView pronunciationText;
    private TextView synonymsText;
    private TextView antonymsText;
    private MaterialButton playPronunciationBtn;
    private MaterialButton markLearnedBtn;
    private MaterialButton addToFavoriteBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_word_detail);

        setupToolbar();
        initViews();
        loadWordData();
        setupClickListeners();
    }

    private void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("单词详情");
        }
    }

    private void initViews() {
        wordText = findViewById(R.id.word_text);
        meaningText = findViewById(R.id.meaning_text);
        partOfSpeechText = findViewById(R.id.part_of_speech_text);
        exampleText = findViewById(R.id.example_text);
        pronunciationText = findViewById(R.id.pronunciation_text);
        synonymsText = findViewById(R.id.synonyms_text);
        antonymsText = findViewById(R.id.antonyms_text);
        playPronunciationBtn = findViewById(R.id.play_pronunciation_btn);
        markLearnedBtn = findViewById(R.id.mark_learned_btn);
        addToFavoriteBtn = findViewById(R.id.add_to_favorite_btn);
    }

    private void loadWordData() {
        String word = getIntent().getStringExtra("word");
        String meaning = getIntent().getStringExtra("meaning");
        String partOfSpeech = getIntent().getStringExtra("partOfSpeech");
        String example = getIntent().getStringExtra("example");
        boolean isLearned = getIntent().getBooleanExtra("isLearned", false);

        wordText.setText(word != null ? word : "Unknown");
        meaningText.setText(meaning != null ? meaning : "暂无释义");
        partOfSpeechText.setText(partOfSpeech != null ? partOfSpeech : "未知");
        exampleText.setText(example != null ? example : "暂无例句");
        
        // 模拟音标和同反义词
        pronunciationText.setText("/ˈæpəl/");
        synonymsText.setText("fruit, produce");
        antonymsText.setText("暂无");
        
        // 设置按钮状态
        markLearnedBtn.setText(isLearned ? "已掌握" : "标记为已学");
        markLearnedBtn.setEnabled(!isLearned);
    }

    private void setupClickListeners() {
        playPronunciationBtn.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "播放发音", android.widget.Toast.LENGTH_SHORT).show();
            // 这里可以集成TTS或音频播放功能
        });

        markLearnedBtn.setOnClickListener(v -> {
            markLearnedBtn.setText("已掌握");
            markLearnedBtn.setEnabled(false);
            android.widget.Toast.makeText(this, "已标记为掌握", android.widget.Toast.LENGTH_SHORT).show();
        });

        addToFavoriteBtn.setOnClickListener(v -> {
            android.widget.Toast.makeText(this, "已添加到收藏", android.widget.Toast.LENGTH_SHORT).show();
            addToFavoriteBtn.setText("已收藏");
            addToFavoriteBtn.setEnabled(false);
        });
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