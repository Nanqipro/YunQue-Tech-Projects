package com.nanqipro.ai_english_application;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class WordSelectionAdapter extends RecyclerView.Adapter<WordSelectionAdapter.ViewHolder> {

    private List<AIMemoryActivity.SelectableWord> words;
    private OnWordSelectionListener onWordSelectionListener;

    public interface OnWordSelectionListener {
        void onWordSelectionChanged(AIMemoryActivity.SelectableWord word, boolean isSelected);
    }

    public WordSelectionAdapter(List<AIMemoryActivity.SelectableWord> words) {
        this.words = words;
    }

    public void setOnWordSelectionListener(OnWordSelectionListener listener) {
        this.onWordSelectionListener = listener;
    }

    public void updateWordSelection(AIMemoryActivity.SelectableWord word, boolean isSelected) {
        word.isSelected = isSelected;
        int position = words.indexOf(word);
        if (position != -1) {
            notifyItemChanged(position);
        }
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_selectable_word, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        AIMemoryActivity.SelectableWord word = words.get(position);
        
        holder.wordText.setText(word.word);
        holder.meaningText.setText(word.meaning);
        holder.partOfSpeechText.setText(word.partOfSpeech);
        
        // 设置复选框状态，但不触发监听器
        holder.checkBox.setOnCheckedChangeListener(null);
        holder.checkBox.setChecked(word.isSelected);
        
        // 设置复选框监听器
        holder.checkBox.setOnCheckedChangeListener((buttonView, isChecked) -> {
            word.isSelected = isChecked;
            if (onWordSelectionListener != null) {
                onWordSelectionListener.onWordSelectionChanged(word, isChecked);
            }
        });
        
        // 设置整个项目的点击监听器
        holder.itemView.setOnClickListener(v -> {
            boolean newState = !word.isSelected;
            word.isSelected = newState;
            holder.checkBox.setChecked(newState);
            if (onWordSelectionListener != null) {
                onWordSelectionListener.onWordSelectionChanged(word, newState);
            }
        });
        
        // 设置选中状态的视觉效果
        if (word.isSelected) {
            holder.itemView.setBackgroundResource(R.drawable.selected_word_background);
            holder.wordText.setTextColor(holder.itemView.getContext().getResources().getColor(R.color.primary_blue));
        } else {
            holder.itemView.setBackgroundResource(R.drawable.unselected_word_background);
            holder.wordText.setTextColor(holder.itemView.getContext().getResources().getColor(R.color.text_primary));
        }
    }

    @Override
    public int getItemCount() {
        return words.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        CheckBox checkBox;
        TextView wordText;
        TextView meaningText;
        TextView partOfSpeechText;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            checkBox = itemView.findViewById(R.id.word_checkbox);
            wordText = itemView.findViewById(R.id.word_text);
            meaningText = itemView.findViewById(R.id.meaning_text);
            partOfSpeechText = itemView.findViewById(R.id.part_of_speech_text);
        }
    }
}