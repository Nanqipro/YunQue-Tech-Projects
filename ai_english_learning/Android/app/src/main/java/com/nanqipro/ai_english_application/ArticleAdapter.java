package com.nanqipro.ai_english_application;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ArticleAdapter extends RecyclerView.Adapter<ArticleAdapter.ViewHolder> {

    private List<ReadingArticlesActivity.Article> articles;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(ReadingArticlesActivity.Article article);
    }

    public ArticleAdapter(List<ReadingArticlesActivity.Article> articles) {
        this.articles = articles;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_article, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ReadingArticlesActivity.Article article = articles.get(position);
        
        holder.titleText.setText(article.title);
        holder.chineseTitleText.setText(article.chineseTitle);
        holder.contentPreviewText.setText(article.content.length() > 100 ? 
            article.content.substring(0, 100) + "..." : article.content);
        holder.readingTimeText.setText(article.readingTime);
        holder.difficultyText.setText(article.difficulty);
        
        // 设置完成状态
        if (article.isCompleted) {
            holder.statusIcon.setImageResource(R.drawable.ic_star);
            holder.statusIcon.setColorFilter(ContextCompat.getColor(holder.itemView.getContext(), R.color.accent_green));
            holder.titleText.setTextColor(ContextCompat.getColor(holder.itemView.getContext(), R.color.accent_green));
        } else {
            holder.statusIcon.setImageResource(R.drawable.ic_reading);
            holder.statusIcon.setColorFilter(ContextCompat.getColor(holder.itemView.getContext(), R.color.reading_module));
            holder.titleText.setTextColor(ContextCompat.getColor(holder.itemView.getContext(), R.color.text_primary));
        }
        
        // 设置难度标签颜色
        int difficultyColor;
        switch (article.difficulty) {
            case "初级":
                difficultyColor = R.color.accent_green;
                break;
            case "中级":
                difficultyColor = R.color.warning_orange;
                break;
            case "高级":
                difficultyColor = R.color.error_red;
                break;
            default:
                difficultyColor = R.color.gray_medium;
                break;
        }
        holder.difficultyTag.setBackgroundTintList(
            ContextCompat.getColorStateList(holder.itemView.getContext(), difficultyColor));
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(article);
            }
        });
    }

    @Override
    public int getItemCount() {
        return articles.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView statusIcon;
        TextView titleText;
        TextView chineseTitleText;
        TextView contentPreviewText;
        TextView readingTimeText;
        TextView difficultyText;
        View difficultyTag;
        ImageView arrowIcon;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            statusIcon = itemView.findViewById(R.id.status_icon);
            titleText = itemView.findViewById(R.id.title_text);
            chineseTitleText = itemView.findViewById(R.id.chinese_title_text);
            contentPreviewText = itemView.findViewById(R.id.content_preview_text);
            readingTimeText = itemView.findViewById(R.id.reading_time_text);
            difficultyText = itemView.findViewById(R.id.difficulty_text);
            difficultyTag = itemView.findViewById(R.id.difficulty_tag);
            arrowIcon = itemView.findViewById(R.id.arrow_icon);
        }
    }
}