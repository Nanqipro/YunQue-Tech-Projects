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

public class WordItemAdapter extends RecyclerView.Adapter<WordItemAdapter.ViewHolder> {

    private List<VocabularyLearningActivity.WordItem> words;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(VocabularyLearningActivity.WordItem word);
    }

    public WordItemAdapter(List<VocabularyLearningActivity.WordItem> words) {
        this.words = words;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_word, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        VocabularyLearningActivity.WordItem word = words.get(position);
        
        holder.wordText.setText(word.word);
        holder.meaningText.setText(word.meaning);
        holder.partOfSpeechText.setText(word.partOfSpeech);
        holder.exampleText.setText(word.example);
        
        // 设置学习状态图标和颜色
        if (word.isLearned) {
            holder.statusIcon.setImageResource(R.drawable.ic_star);
            holder.statusIcon.setColorFilter(ContextCompat.getColor(holder.itemView.getContext(), R.color.accent_green));
            holder.wordText.setTextColor(ContextCompat.getColor(holder.itemView.getContext(), R.color.accent_green));
        } else {
            holder.statusIcon.setImageResource(R.drawable.ic_book);
            holder.statusIcon.setColorFilter(ContextCompat.getColor(holder.itemView.getContext(), R.color.gray_medium));
            holder.wordText.setTextColor(ContextCompat.getColor(holder.itemView.getContext(), R.color.text_primary));
        }
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(word);
            }
        });
    }

    @Override
    public int getItemCount() {
        return words.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView statusIcon;
        TextView wordText;
        TextView meaningText;
        TextView partOfSpeechText;
        TextView exampleText;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            statusIcon = itemView.findViewById(R.id.status_icon);
            wordText = itemView.findViewById(R.id.word_text);
            meaningText = itemView.findViewById(R.id.meaning_text);
            partOfSpeechText = itemView.findViewById(R.id.part_of_speech_text);
            exampleText = itemView.findViewById(R.id.example_text);
        }
    }
}