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

public class ReadingCategoryAdapter extends RecyclerView.Adapter<ReadingCategoryAdapter.ViewHolder> {

    private List<ReadingFragment.ReadingCategory> categories;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(ReadingFragment.ReadingCategory category);
    }

    public ReadingCategoryAdapter(List<ReadingFragment.ReadingCategory> categories) {
        this.categories = categories;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_reading_category, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ReadingFragment.ReadingCategory category = categories.get(position);
        
        holder.titleText.setText(category.title);
        holder.descriptionText.setText(category.description);
        holder.iconImage.setImageResource(category.iconRes);
        
        // 设置背景色
        int color = ContextCompat.getColor(holder.itemView.getContext(), category.colorRes);
        holder.iconBackground.setBackgroundTintList(
                android.content.res.ColorStateList.valueOf(color));
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(category);
            }
        });
    }

    @Override
    public int getItemCount() {
        return categories.size();
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