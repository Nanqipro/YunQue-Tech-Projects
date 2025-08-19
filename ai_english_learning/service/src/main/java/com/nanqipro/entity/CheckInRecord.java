package com.nanqipro.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 打卡记录实体类
 */
@Entity
@Table(name = "check_in_records")
public class CheckInRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 打卡活动
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "check_in_id", nullable = false)
    private CheckIn checkIn;
    
    /**
     * 用户ID
     */
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    /**
     * 打卡日期
     */
    @Column(name = "check_in_date", nullable = false)
    private LocalDate checkInDate;
    
    /**
     * 打卡时间
     */
    @Column(name = "check_in_time", nullable = false)
    private LocalDateTime checkInTime;
    
    /**
     * 打卡状态
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CheckInRecordStatus status;
    
    /**
     * 打卡类型
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CheckInRecordType type;
    
    /**
     * 获得积分
     */
    @Column(name = "points_earned")
    private Integer pointsEarned = 0;
    
    /**
     * 连续打卡天数
     */
    @Column(name = "streak_days")
    private Integer streakDays = 0;
    
    /**
     * 学习时长（分钟）
     */
    @Column(name = "study_duration")
    private Integer studyDuration;
    
    /**
     * 完成的任务数
     */
    @Column(name = "completed_tasks")
    private Integer completedTasks = 0;
    
    /**
     * 打卡内容（JSON格式）
     */
    @Column(name = "check_in_content", columnDefinition = "TEXT")
    private String checkInContent;
    
    /**
     * 打卡截图或证明
     */
    @Column(name = "proof_image")
    private String proofImage;
    
    /**
     * 打卡备注
     */
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    /**
     * 是否为补签
     */
    @Column(name = "is_makeup", nullable = false)
    private Boolean isMakeup = false;
    
    /**
     * 补签费用
     */
    @Column(name = "makeup_cost")
    private Integer makeupCost;
    
    /**
     * 补签时间
     */
    @Column(name = "makeup_time")
    private LocalDateTime makeupTime;
    
    /**
     * 验证状态
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status")
    private VerificationStatus verificationStatus;
    
    /**
     * 验证者ID
     */
    @Column(name = "verifier_id")
    private Long verifierId;
    
    /**
     * 验证时间
     */
    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;
    
    /**
     * 验证备注
     */
    @Column(name = "verification_notes")
    private String verificationNotes;
    
    /**
     * 创建时间
     */
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * 打卡记录状态枚举
     */
    public enum CheckInRecordStatus {
        PENDING,    // 待确认
        COMPLETED,  // 已完成
        FAILED,     // 失败
        CANCELLED   // 已取消
    }
    
    /**
     * 打卡记录类型枚举
     */
    public enum CheckInRecordType {
        NORMAL,     // 正常打卡
        MAKEUP,     // 补签
        BONUS       // 额外打卡
    }
    
    /**
     * 验证状态枚举
     */
    public enum VerificationStatus {
        PENDING,    // 待验证
        APPROVED,   // 已通过
        REJECTED,   // 已拒绝
        AUTO_APPROVED // 自动通过
    }
    
    // 构造函数
    public CheckInRecord() {
        this.createdAt = LocalDateTime.now();
        this.checkInTime = LocalDateTime.now();
        this.checkInDate = LocalDate.now();
        this.status = CheckInRecordStatus.PENDING;
        this.type = CheckInRecordType.NORMAL;
        this.verificationStatus = VerificationStatus.PENDING;
        this.pointsEarned = 0;
        this.streakDays = 0;
        this.completedTasks = 0;
        this.isMakeup = false;
    }
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public CheckIn getCheckIn() {
        return checkIn;
    }
    
    public void setCheckIn(CheckIn checkIn) {
        this.checkIn = checkIn;
    }
    
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public LocalDate getCheckInDate() {
        return checkInDate;
    }
    
    public void setCheckInDate(LocalDate checkInDate) {
        this.checkInDate = checkInDate;
    }
    
    public LocalDateTime getCheckInTime() {
        return checkInTime;
    }
    
    public void setCheckInTime(LocalDateTime checkInTime) {
        this.checkInTime = checkInTime;
    }
    
    public CheckInRecordStatus getStatus() {
        return status;
    }
    
    public void setStatus(CheckInRecordStatus status) {
        this.status = status;
    }
    
    public CheckInRecordType getType() {
        return type;
    }
    
    public void setType(CheckInRecordType type) {
        this.type = type;
    }
    
    public Integer getPointsEarned() {
        return pointsEarned;
    }
    
    public void setPointsEarned(Integer pointsEarned) {
        this.pointsEarned = pointsEarned;
    }
    
    public Integer getStreakDays() {
        return streakDays;
    }
    
    public void setStreakDays(Integer streakDays) {
        this.streakDays = streakDays;
    }
    
    public Integer getStudyDuration() {
        return studyDuration;
    }
    
    public void setStudyDuration(Integer studyDuration) {
        this.studyDuration = studyDuration;
    }
    
    public Integer getCompletedTasks() {
        return completedTasks;
    }
    
    public void setCompletedTasks(Integer completedTasks) {
        this.completedTasks = completedTasks;
    }
    
    public String getCheckInContent() {
        return checkInContent;
    }
    
    public void setCheckInContent(String checkInContent) {
        this.checkInContent = checkInContent;
    }
    
    public String getProofImage() {
        return proofImage;
    }
    
    public void setProofImage(String proofImage) {
        this.proofImage = proofImage;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public Boolean getIsMakeup() {
        return isMakeup;
    }
    
    public void setIsMakeup(Boolean isMakeup) {
        this.isMakeup = isMakeup;
        if (isMakeup) {
            this.type = CheckInRecordType.MAKEUP;
        }
    }
    
    public Integer getMakeupCost() {
        return makeupCost;
    }
    
    public void setMakeupCost(Integer makeupCost) {
        this.makeupCost = makeupCost;
    }
    
    public LocalDateTime getMakeupTime() {
        return makeupTime;
    }
    
    public void setMakeupTime(LocalDateTime makeupTime) {
        this.makeupTime = makeupTime;
    }
    
    public VerificationStatus getVerificationStatus() {
        return verificationStatus;
    }
    
    public void setVerificationStatus(VerificationStatus verificationStatus) {
        this.verificationStatus = verificationStatus;
    }
    
    public Long getVerifierId() {
        return verifierId;
    }
    
    public void setVerifierId(Long verifierId) {
        this.verifierId = verifierId;
    }
    
    public LocalDateTime getVerifiedAt() {
        return verifiedAt;
    }
    
    public void setVerifiedAt(LocalDateTime verifiedAt) {
        this.verifiedAt = verifiedAt;
    }
    
    public String getVerificationNotes() {
        return verificationNotes;
    }
    
    public void setVerificationNotes(String verificationNotes) {
        this.verificationNotes = verificationNotes;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    /**
     * 检查是否已完成
     */
    public boolean isCompleted() {
        return this.status == CheckInRecordStatus.COMPLETED;
    }
    
    /**
     * 检查是否为补签
     */
    public boolean isMakeupRecord() {
        return this.isMakeup != null && this.isMakeup;
    }
    
    /**
     * 检查是否已验证通过
     */
    public boolean isVerified() {
        return this.verificationStatus == VerificationStatus.APPROVED || 
               this.verificationStatus == VerificationStatus.AUTO_APPROVED;
    }
    
    /**
     * 标记为完成
     */
    public void markAsCompleted() {
        this.status = CheckInRecordStatus.COMPLETED;
        this.verificationStatus = VerificationStatus.AUTO_APPROVED;
        this.verifiedAt = LocalDateTime.now();
    }
    
    /**
     * 标记为补签
     */
    public void markAsMakeup(Integer cost) {
        this.isMakeup = true;
        this.type = CheckInRecordType.MAKEUP;
        this.makeupCost = cost;
        this.makeupTime = LocalDateTime.now();
    }
}