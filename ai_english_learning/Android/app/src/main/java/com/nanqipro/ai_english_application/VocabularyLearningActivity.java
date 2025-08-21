package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class VocabularyLearningActivity extends AppCompatActivity {

    private TextView levelTitleText;
    private TextView levelDescriptionText;
    private TextView progressText;
    private RecyclerView wordsRecyclerView;
    private WordItemAdapter wordAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vocabulary_learning);

        setupToolbar();
        initViews();
        loadData();
        setupRecyclerView();
    }

    private void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("词汇学习");
        }
    }

    private void initViews() {
        levelTitleText = findViewById(R.id.level_title_text);
        levelDescriptionText = findViewById(R.id.level_description_text);
        progressText = findViewById(R.id.progress_text);
        wordsRecyclerView = findViewById(R.id.words_recycler_view);
    }

    private void loadData() {
        String levelTitle = getIntent().getStringExtra("level_title");
        String levelDescription = getIntent().getStringExtra("level_description");

        levelTitleText.setText(levelTitle != null ? levelTitle : "词汇学习");
        levelDescriptionText.setText(levelDescription != null ? levelDescription : "开始学习词汇");
        progressText.setText("学习进度: 15/100 (15%)");
    }

    private void setupRecyclerView() {
        wordsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        List<WordItem> words = createSampleWords();
        wordAdapter = new WordItemAdapter(words);
        wordAdapter.setOnItemClickListener(this::onWordClick);
        wordsRecyclerView.setAdapter(wordAdapter);
    }

    private List<WordItem> createSampleWords() {
        List<WordItem> words = new ArrayList<>();
        words.add(new WordItem("apple", "苹果", "n.", "I like to eat an apple.", true));
        words.add(new WordItem("beautiful", "美丽的", "adj.", "She is a beautiful girl.", true));
        words.add(new WordItem("computer", "电脑", "n.", "I use a computer to work.", false));
        words.add(new WordItem("difficult", "困难的", "adj.", "This question is difficult.", false));
        words.add(new WordItem("education", "教育", "n.", "Education is very important.", false));
        words.add(new WordItem("friend", "朋友", "n.", "He is my best friend.", true));
        words.add(new WordItem("government", "政府", "n.", "The government made a new policy.", false));
        words.add(new WordItem("hospital", "医院", "n.", "She works in a hospital.", false));
        words.add(new WordItem("important", "重要的", "adj.", "This is an important meeting.", true));
        words.add(new WordItem("journey", "旅程", "n.", "Life is a long journey.", false));
        return words;
    }

    private void onWordClick(WordItem word) {
        android.content.Intent intent = new android.content.Intent(this, WordDetailActivity.class);
        intent.putExtra("word", word.word);
        intent.putExtra("meaning", word.meaning);
        intent.putExtra("partOfSpeech", word.partOfSpeech);
        intent.putExtra("example", word.example);
        intent.putExtra("isLearned", word.isLearned);
        startActivity(intent);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    // 单词数据类
    public static class WordItem {
        public String word;
        public String meaning;
        public String partOfSpeech;
        public String example;
        public boolean isLearned;

        public WordItem(String word, String meaning, String partOfSpeech, String example, boolean isLearned) {
            this.word = word;
            this.meaning = meaning;
            this.partOfSpeech = partOfSpeech;
            this.example = example;
            this.isLearned = isLearned;
        }
    }
}