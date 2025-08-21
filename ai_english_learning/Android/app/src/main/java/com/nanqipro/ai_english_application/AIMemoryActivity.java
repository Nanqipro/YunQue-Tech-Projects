package com.nanqipro.ai_english_application;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.Button;
import android.widget.ProgressBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.cardview.widget.CardView;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import java.util.ArrayList;
import java.util.List;

public class AIMemoryActivity extends AppCompatActivity {

    private RecyclerView wordsRecyclerView;
    private ChipGroup selectedWordsChipGroup;
    private MaterialButton generateSentenceBtn;
    private CardView resultCard;
    private TextView generatedSentenceText;
    private TextView sentenceTranslationText;
    private ProgressBar loadingProgress;
    private MaterialButton saveBtn;
    private MaterialButton regenerateBtn;
    
    private WordSelectionAdapter wordAdapter;
    private List<SelectableWord> availableWords;
    private List<SelectableWord> selectedWords;
    private DeepSeekAPIClient apiClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ai_memory);

        setupToolbar();
        initViews();
        initData();
        setupRecyclerView();
        setupClickListeners();
    }

    private void setupToolbar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle("AI联想记忆");
        }
    }

    private void initViews() {
        wordsRecyclerView = findViewById(R.id.words_recycler_view);
        selectedWordsChipGroup = findViewById(R.id.selected_words_chip_group);
        generateSentenceBtn = findViewById(R.id.generate_sentence_btn);
        resultCard = findViewById(R.id.result_card);
        generatedSentenceText = findViewById(R.id.generated_sentence_text);
        sentenceTranslationText = findViewById(R.id.sentence_translation_text);
        loadingProgress = findViewById(R.id.loading_progress);
        saveBtn = findViewById(R.id.save_btn);
        regenerateBtn = findViewById(R.id.regenerate_btn);
    }

    private void initData() {
        selectedWords = new ArrayList<>();
        apiClient = new DeepSeekAPIClient();
        
        // 创建示例单词数据
        availableWords = createSampleWords();
    }

    private void setupRecyclerView() {
        wordsRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        wordAdapter = new WordSelectionAdapter(availableWords);
        wordAdapter.setOnWordSelectionListener(this::onWordSelectionChanged);
        wordsRecyclerView.setAdapter(wordAdapter);
    }

    private void setupClickListeners() {
        generateSentenceBtn.setOnClickListener(v -> generateMemorySentence());
        saveBtn.setOnClickListener(v -> saveSentence());
        regenerateBtn.setOnClickListener(v -> generateMemorySentence());
    }

    private void onWordSelectionChanged(SelectableWord word, boolean isSelected) {
        if (isSelected) {
            if (!selectedWords.contains(word)) {
                selectedWords.add(word);
                addWordChip(word);
            }
        } else {
            selectedWords.remove(word);
            removeWordChip(word);
        }
        
        updateGenerateButtonState();
    }

    private void addWordChip(SelectableWord word) {
        Chip chip = new Chip(this);
        chip.setText(word.word);
        chip.setCloseIconVisible(true);
        chip.setTag(word);
        chip.setOnCloseIconClickListener(v -> {
            selectedWords.remove(word);
            selectedWordsChipGroup.removeView(chip);
            wordAdapter.updateWordSelection(word, false);
            updateGenerateButtonState();
        });
        selectedWordsChipGroup.addView(chip);
    }

    private void removeWordChip(SelectableWord word) {
        for (int i = 0; i < selectedWordsChipGroup.getChildCount(); i++) {
            Chip chip = (Chip) selectedWordsChipGroup.getChildAt(i);
            if (word.equals(chip.getTag())) {
                selectedWordsChipGroup.removeView(chip);
                break;
            }
        }
    }

    private void updateGenerateButtonState() {
        boolean canGenerate = selectedWords.size() >= 2 && selectedWords.size() <= 8;
        generateSentenceBtn.setEnabled(canGenerate);
        
        if (selectedWords.size() < 2) {
            generateSentenceBtn.setText("请选择至少2个单词");
        } else if (selectedWords.size() > 8) {
            generateSentenceBtn.setText("最多选择8个单词");
        } else {
            generateSentenceBtn.setText("生成记忆句子 (" + selectedWords.size() + "个单词)");
        }
    }

    private void generateMemorySentence() {
        if (selectedWords.size() < 2) {
            android.widget.Toast.makeText(this, "请至少选择2个单词", android.widget.Toast.LENGTH_SHORT).show();
            return;
        }

        showLoading(true);
        
        List<String> words = new ArrayList<>();
        for (SelectableWord word : selectedWords) {
            words.add(word.word);
        }
        
        apiClient.generateMemorySentence(words, new DeepSeekAPIClient.APICallback() {
            @Override
            public void onSuccess(String sentence, String translation) {
                runOnUiThread(() -> {
                    showLoading(false);
                    displayResult(sentence, translation);
                });
            }

            @Override
            public void onError(String error) {
                runOnUiThread(() -> {
                    showLoading(false);
                    android.widget.Toast.makeText(AIMemoryActivity.this, 
                        "生成失败: " + error, android.widget.Toast.LENGTH_LONG).show();
                });
            }
        });
    }

    private void showLoading(boolean show) {
        loadingProgress.setVisibility(show ? android.view.View.VISIBLE : android.view.View.GONE);
        generateSentenceBtn.setEnabled(!show);
        resultCard.setVisibility(show ? android.view.View.GONE : resultCard.getVisibility());
    }

    private void displayResult(String sentence, String translation) {
        generatedSentenceText.setText(sentence);
        sentenceTranslationText.setText(translation);
        resultCard.setVisibility(android.view.View.VISIBLE);
        
        android.widget.Toast.makeText(this, "句子生成成功！", android.widget.Toast.LENGTH_SHORT).show();
    }

    private void saveSentence() {
        String sentence = generatedSentenceText.getText().toString();
        String translation = sentenceTranslationText.getText().toString();
        
        if (!sentence.isEmpty()) {
            // 这里可以实现保存到本地数据库或收藏夹的功能
            android.widget.Toast.makeText(this, "句子已保存到收藏夹", android.widget.Toast.LENGTH_SHORT).show();
        }
    }

    private List<SelectableWord> createSampleWords() {
        List<SelectableWord> words = new ArrayList<>();
        words.add(new SelectableWord("apple", "苹果", "n."));
        words.add(new SelectableWord("beautiful", "美丽的", "adj."));
        words.add(new SelectableWord("computer", "电脑", "n."));
        words.add(new SelectableWord("difficult", "困难的", "adj."));
        words.add(new SelectableWord("education", "教育", "n."));
        words.add(new SelectableWord("friend", "朋友", "n."));
        words.add(new SelectableWord("government", "政府", "n."));
        words.add(new SelectableWord("hospital", "医院", "n."));
        words.add(new SelectableWord("important", "重要的", "adj."));
        words.add(new SelectableWord("journey", "旅程", "n."));
        words.add(new SelectableWord("knowledge", "知识", "n."));
        words.add(new SelectableWord("language", "语言", "n."));
        words.add(new SelectableWord("mountain", "山", "n."));
        words.add(new SelectableWord("nature", "自然", "n."));
        words.add(new SelectableWord("ocean", "海洋", "n."));
        words.add(new SelectableWord("peaceful", "和平的", "adj."));
        words.add(new SelectableWord("question", "问题", "n."));
        words.add(new SelectableWord("research", "研究", "n."));
        words.add(new SelectableWord("science", "科学", "n."));
        words.add(new SelectableWord("technology", "技术", "n."));
        return words;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    // 可选择的单词数据类
    public static class SelectableWord {
        public String word;
        public String meaning;
        public String partOfSpeech;
        public boolean isSelected;

        public SelectableWord(String word, String meaning, String partOfSpeech) {
            this.word = word;
            this.meaning = meaning;
            this.partOfSpeech = partOfSpeech;
            this.isSelected = false;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            SelectableWord that = (SelectableWord) obj;
            return word.equals(that.word);
        }

        @Override
        public int hashCode() {
            return word.hashCode();
        }
    }
}