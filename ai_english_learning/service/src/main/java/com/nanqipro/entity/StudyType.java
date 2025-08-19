package com.nanqipro.entity;

/**
 * 学习类型枚举
 */
public enum StudyType {
    RECOGNITION("识别", "看英文选中文"),
    RECALL("回忆", "看中文写英文"),
    SPELLING("拼写", "听音频拼写单词"),
    LISTENING("听力", "听音频选择正确答案"),
    READING("阅读", "阅读理解练习"),
    SENTENCE_MAKING("造句", "用单词造句"),
    SYNONYM_ANTONYM("同反义词", "选择同义词或反义词"),
    FILL_BLANK("填空", "完形填空练习"),
    MULTIPLE_CHOICE("选择题", "多项选择题"),
    TRUE_FALSE("判断题", "判断正误"),
    REVIEW("复习", "复习已学词汇"),
    QUICK_REVIEW("快速复习", "快速浏览复习"),
    INTENSIVE_STUDY("精学", "深入学习词汇"),
    CASUAL_BROWSE("随意浏览", "随意浏览词汇");
    
    private final String displayName;
    private final String description;
    
    StudyType(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public String getDescription() {
        return description;
    }
    
    /**
     * 根据显示名称获取学习类型
     */
    public static StudyType fromDisplayName(String displayName) {
        for (StudyType type : values()) {
            if (type.displayName.equals(displayName)) {
                return type;
            }
        }
        throw new IllegalArgumentException("未知的学习类型: " + displayName);
    }
    
    /**
     * 获取所有学习类型的显示名称
     */
    public static String[] getAllDisplayNames() {
        StudyType[] types = values();
        String[] names = new String[types.length];
        for (int i = 0; i < types.length; i++) {
            names[i] = types[i].displayName;
        }
        return names;
    }
    
    /**
     * 判断是否为主动学习类型（需要用户输入）
     */
    public boolean isActiveStudy() {
        return this == RECALL || this == SPELLING || this == SENTENCE_MAKING || this == FILL_BLANK;
    }
    
    /**
     * 判断是否为被动学习类型（选择题形式）
     */
    public boolean isPassiveStudy() {
        return this == RECOGNITION || this == LISTENING || this == MULTIPLE_CHOICE || 
               this == SYNONYM_ANTONYM || this == TRUE_FALSE;
    }
    
    /**
     * 判断是否为复习类型
     */
    public boolean isReviewType() {
        return this == REVIEW || this == QUICK_REVIEW;
    }
}