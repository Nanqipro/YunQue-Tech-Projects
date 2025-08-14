# -*- coding: utf-8 -*-
"""
图片处理记录模型
"""

from datetime import datetime
from . import db


class ProcessingRecord(db.Model):
    """图片处理记录模型"""
    __tablename__ = 'processing_records'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True, index=True)
    image_id = db.Column(db.Integer, db.ForeignKey('images.id'), nullable=False, index=True)
    processing_type = db.Column(db.String(50), nullable=False)  # 处理类型：beauty, filter, adjust等
    parameters = db.Column(db.Text)  # JSON格式的处理参数
    status = db.Column(db.String(20), default='pending')  # pending, processing, completed, failed
    result_path = db.Column(db.String(500))  # 处理结果文件路径
    error_message = db.Column(db.Text)  # 错误信息
    processing_time = db.Column(db.Float)  # 处理耗时（秒）
    created_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    completed_at = db.Column(db.DateTime)  # 完成时间
    
    def to_dict(self, include_paths=False):
        """转换为字典"""
        data = {
            'id': self.id,
            'user_id': self.user_id,
            'image_id': self.image_id,
            'processing_type': self.processing_type,
            'parameters': self.parameters,
            'status': self.status,
            'error_message': self.error_message,
            'processing_time': self.processing_time,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
        
        if include_paths:
            data['result_path'] = self.result_path
            
        return data
    
    @property
    def result_url(self):
        """获取处理结果访问URL"""
        if self.status == 'completed' and self.result_path:
            return f'/api/processing/{self.id}/result'
        return None
    
    def mark_as_processing(self):
        """标记为处理中"""
        self.status = 'processing'
        self.updated_at = datetime.utcnow()
    
    def mark_as_completed(self, result_path, processing_time=None):
        """标记为完成"""
        self.status = 'completed'
        self.result_path = result_path
        self.completed_at = datetime.utcnow()
        self.updated_at = self.completed_at
        if processing_time:
            self.processing_time = processing_time
    
    def mark_as_failed(self, error_message):
        """标记为失败"""
        self.status = 'failed'
        self.error_message = error_message
        self.updated_at = datetime.utcnow()
    
    @classmethod
    def get_statistics(cls, user_id):
        """获取用户处理统计信息"""
        total = cls.query.filter_by(user_id=user_id).count()
        completed = cls.query.filter_by(user_id=user_id, status='completed').count()
        failed = cls.query.filter_by(user_id=user_id, status='failed').count()
        pending = cls.query.filter_by(user_id=user_id, status='pending').count()
        processing = cls.query.filter_by(user_id=user_id, status='processing').count()
        
        return {
            'total': total,
            'completed': completed,
            'failed': failed,
            'pending': pending,
            'processing': processing
        }
    
    def __repr__(self):
        return f'<ProcessingRecord {self.id}: {self.processing_type}>'