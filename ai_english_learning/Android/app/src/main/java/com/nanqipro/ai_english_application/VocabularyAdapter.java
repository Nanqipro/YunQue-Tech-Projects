package com.nanqipro.ai_english_application;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class VocabularyAdapter extends RecyclerView.Adapter<VocabularyAdapter.ViewHolder> {

    private List<WordsFragment.VocabularyLevel> vocabularyLevels;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(WordsFragment.VocabularyLevel level);
    }

    public VocabularyAdapter(List<WordsFragment.VocabularyLevel> vocabularyLevels) {
        this.vocabularyLevels = vocabularyLevels;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_vocabulary_level, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        WordsFragment.VocabularyLevel level = vocabularyLevels.get(position);
        
        holder.titleText.setText(level.title);
        holder.descriptionText.setText(level.description);
        holder.iconImage.setImageResource(level.iconRes);
        
        // 设置背景色
        int color = ContextCompat.getColor(holder.itemView.getContext(), level.colorRes);
        holder.iconBackground.setBackgroundTintList(
                android.content.res.ColorStateList.valueOf(color));
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(level);
            }
        });
    }

    @Override
    public int getItemCount() {
        return vocabularyLevels.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        CardView cardView;
        View iconBackground;
        ImageView iconImage;
        TextView titleText;
        TextView descriptionText;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            cardView = itemView.findViewById(R.id.card_view);
            iconBackground = itemView.findViewById(R.id.icon_background);
            iconImage = itemView.findViewById(R.id.icon_image);
            titleText = itemView.findViewById(R.id.title_text);
            descriptionText = itemView.findViewById(R.id.description_text);
        }
    }
}