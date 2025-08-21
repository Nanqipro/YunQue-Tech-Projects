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

public class AchievementAdapter extends RecyclerView.Adapter<AchievementAdapter.ViewHolder> {

    private List<ProfileFragment.Achievement> achievements;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(ProfileFragment.Achievement achievement);
    }

    public AchievementAdapter(List<ProfileFragment.Achievement> achievements) {
        this.achievements = achievements;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_achievement, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ProfileFragment.Achievement achievement = achievements.get(position);
        
        holder.titleText.setText(achievement.title);
        holder.descriptionText.setText(achievement.description);
        holder.iconImage.setImageResource(achievement.iconRes);
        
        // 根据解锁状态设置样式
        if (achievement.isUnlocked) {
            holder.iconBackground.setBackgroundTintList(
                    ContextCompat.getColorStateList(holder.itemView.getContext(), R.color.accent_green));
            holder.cardView.setAlpha(1.0f);
        } else {
            holder.iconBackground.setBackgroundTintList(
                    ContextCompat.getColorStateList(holder.itemView.getContext(), R.color.gray_medium));
            holder.cardView.setAlpha(0.6f);
        }
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(achievement);
            }
        });
    }

    @Override
    public int getItemCount() {
        return achievements.size();
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