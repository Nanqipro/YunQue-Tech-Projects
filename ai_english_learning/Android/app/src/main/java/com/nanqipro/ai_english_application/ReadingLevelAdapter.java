package com.nanqipro.ai_english_application;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class ReadingLevelAdapter extends RecyclerView.Adapter<ReadingLevelAdapter.ViewHolder> {

    private List<ReadingFragment.ReadingLevel> readingLevels;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(ReadingFragment.ReadingLevel level);
    }

    public ReadingLevelAdapter(List<ReadingFragment.ReadingLevel> readingLevels) {
        this.readingLevels = readingLevels;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_reading_level, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ReadingFragment.ReadingLevel level = readingLevels.get(position);
        
        holder.levelText.setText(level.level);
        holder.targetText.setText(level.target);
        holder.descriptionText.setText(level.description);
        
        // 设置背景色
        int color = ContextCompat.getColor(holder.itemView.getContext(), level.colorRes);
        holder.cardView.setCardBackgroundColor(color);
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(level);
            }
        });
    }

    @Override
    public int getItemCount() {
        return readingLevels.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        CardView cardView;
        TextView levelText;
        TextView targetText;
        TextView descriptionText;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            cardView = itemView.findViewById(R.id.card_view);
            levelText = itemView.findViewById(R.id.level_text);
            targetText = itemView.findViewById(R.id.target_text);
            descriptionText = itemView.findViewById(R.id.description_text);
        }
    }
}