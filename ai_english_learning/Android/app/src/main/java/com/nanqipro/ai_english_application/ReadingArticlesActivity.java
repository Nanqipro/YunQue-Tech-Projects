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

public class ReadingArticlesActivity extends AppCompatActivity {

    private TextView categoryTitleText;
    private TextView categoryDescriptionText;
    private RecyclerView articlesRecyclerView;
    private ArticleAdapter articleAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_reading_articles);

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
            getSupportActionBar().setTitle("阅读文章");
        }
    }

    private void initViews() {
        categoryTitleText = findViewById(R.id.category_title_text);
        categoryDescriptionText = findViewById(R.id.category_description_text);
        articlesRecyclerView = findViewById(R.id.articles_recycler_view);
    }

    private void loadData() {
        String level = getIntent().getStringExtra("level");
        String category = getIntent().getStringExtra("category");
        String target = getIntent().getStringExtra("target");
        String description = getIntent().getStringExtra("description");

        if (level != null) {
            categoryTitleText.setText(level);
            categoryDescriptionText.setText(target != null ? target : description);
        } else if (category != null) {
            categoryTitleText.setText(category);
            categoryDescriptionText.setText(description != null ? description : "精选文章");
        } else {
            categoryTitleText.setText("阅读文章");
            categoryDescriptionText.setText("开始你的阅读之旅");
        }
    }

    private void setupRecyclerView() {
        articlesRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        List<Article> articles = createSampleArticles();
        articleAdapter = new ArticleAdapter(articles);
        articleAdapter.setOnItemClickListener(this::onArticleClick);
        articlesRecyclerView.setAdapter(articleAdapter);
    }

    private List<Article> createSampleArticles() {
        List<Article> articles = new ArrayList<>();
        articles.add(new Article(
            "The Power of Reading",
            "阅读的力量",
            "Reading is one of the most powerful tools for learning and personal growth. It opens doors to new worlds, ideas, and perspectives that can transform our understanding of life.",
            "5分钟",
            "初级",
            false
        ));
        articles.add(new Article(
            "Technology and Education",
            "科技与教育",
            "The integration of technology in education has revolutionized the way we learn. From online courses to AI-powered tutoring systems, technology is making education more accessible and personalized.",
            "8分钟",
            "中级",
            true
        ));
        articles.add(new Article(
            "Climate Change Solutions",
            "气候变化解决方案",
            "As the world faces the challenges of climate change, innovative solutions are emerging. From renewable energy to sustainable agriculture, scientists and engineers are working to create a better future.",
            "12分钟",
            "高级",
            false
        ));
        articles.add(new Article(
            "The Art of Communication",
            "沟通的艺术",
            "Effective communication is essential in all aspects of life. Whether in personal relationships or professional settings, the ability to express ideas clearly and listen actively can make all the difference.",
            "6分钟",
            "中级",
            false
        ));
        articles.add(new Article(
            "Space Exploration",
            "太空探索",
            "Humanity's quest to explore space has led to incredible discoveries and technological advances. From the first moon landing to plans for Mars colonization, space exploration continues to inspire and amaze.",
            "10分钟",
            "高级",
            true
        ));
        return articles;
    }

    private void onArticleClick(Article article) {
        android.widget.Toast.makeText(this, 
            "打开文章: " + article.title + "\n" + article.chineseTitle, 
            android.widget.Toast.LENGTH_SHORT).show();
        // 阅读详情页面开发中，暂时显示Toast提示
        // android.content.Intent intent = new android.content.Intent(this, ReadingDetailActivity.class);
        // intent.putExtra("title", article.title);
        // intent.putExtra("chineseTitle", article.chineseTitle);
        // intent.putExtra("content", article.content);
        // intent.putExtra("readingTime", article.readingTime);
        // intent.putExtra("difficulty", article.difficulty);
        // intent.putExtra("isCompleted", article.isCompleted);
        // startActivity(intent);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    // 文章数据类
    public static class Article {
        public String title;
        public String chineseTitle;
        public String content;
        public String readingTime;
        public String difficulty;
        public boolean isCompleted;

        public Article(String title, String chineseTitle, String content, String readingTime, String difficulty, boolean isCompleted) {
            this.title = title;
            this.chineseTitle = chineseTitle;
            this.content = content;
            this.readingTime = readingTime;
            this.difficulty = difficulty;
            this.isCompleted = isCompleted;
        }
    }
}