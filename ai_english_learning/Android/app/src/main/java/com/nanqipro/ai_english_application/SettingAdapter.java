package com.nanqipro.ai_english_application;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class SettingAdapter extends RecyclerView.Adapter<SettingAdapter.ViewHolder> {

    private List<ProfileFragment.Setting> settings;
    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(ProfileFragment.Setting setting);
    }

    public SettingAdapter(List<ProfileFragment.Setting> settings) {
        this.settings = settings;
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.onItemClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_setting, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        ProfileFragment.Setting setting = settings.get(position);
        
        holder.titleText.setText(setting.title);
        holder.descriptionText.setText(setting.description);
        holder.iconImage.setImageResource(setting.iconRes);
        
        holder.itemView.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(setting);
            }
        });
    }

    @Override
    public int getItemCount() {
        return settings.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView iconImage;
        TextView titleText;
        TextView descriptionText;
        ImageView arrowImage;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            iconImage = itemView.findViewById(R.id.icon_image);
            titleText = itemView.findViewById(R.id.title_text);
            descriptionText = itemView.findViewById(R.id.description_text);
            arrowImage = itemView.findViewById(R.id.arrow_image);
        }
    }
}