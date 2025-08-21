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

public class WordsFeatureAdapter extends RecyclerView.Adapter<WordsFeatureAdapter.ViewHolder> {

    private List<WordsFragment.WordsFeature> features;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(WordsFragment.WordsFeature feature);
    }

    public WordsFeatureAdapter(List<WordsFragment.WordsFeature> features) {
        this.features = features;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_words_feature, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        WordsFragment.WordsFeature feature = features.get(position);
        
        holder.titleText.setText(feature.title);
        holder.descriptionText.setText(feature.description);
        holder.iconImage.setImageResource(feature.iconRes);
        
        // 设置背景色
        int color = ContextCompat.getColor(holder.itemView.getContext(), feature.colorRes);
        holder.iconBackground.setBackgroundTintList(
                android.content.res.ColorStateList.valueOf(color));
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(feature);
            }
        });
    }

    @Override
    public int getItemCount() {
        return features.size();
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