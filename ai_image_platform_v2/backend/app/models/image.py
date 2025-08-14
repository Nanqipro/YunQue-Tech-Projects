# -*- coding: utf-8 -*-
"""
图片模型
"""

from datetime import datetime
import json
from . import db


class Image(db.Model):
    """图片模型"""
    __tablename__ = 'images'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True, index=True)
    filename = db.Column(db.String(255), nullable=False)
    original_filename = db.Column(db.String(255), nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    file_size = db.Column(db.Integer)  # 文件大小（字节）
    width = db.Column(db.Integer)  # 图片宽度
    height = db.Column(db.Integer)  # 图片高度
    format = db.Column(db.String(10))  # 图片格式（jpg, png等）
    mime_type = db.Column(db.String(50))  # MIME类型
    is_processed = db.Column(db.Boolean, default=False)
    is_public = db.Column(db.Boolean, default=False)
    tags = db.Column(db.Text)  # JSON格式的标签
    description = db.Column(db.Text)
    title = db.Column(db.String(255))  # 图片标题
    color_mode = db.Column(db.String(20))  # 颜色模式
    thumbnail_path = db.Column(db.String(500))  # 缩略图路径
    created_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关系
    processing_records = db.relationship('ProcessingRecord', backref='image', lazy='dynamic', cascade='all, delete-orphan')
    
    def to_dict(self, include_path=False):
        """转换为字典"""
        data = {
            'id': self.id,
            'user_id': self.user_id,
            'filename': self.filename,
            'original_filename': self.original_filename,
            'file_size': self.file_size,
            'width': self.width,
            'height': self.height,
            'format': self.format,
            'mime_type': self.mime_type,
            'is_processed': self.is_processed,
            'is_public': self.is_public,
            'title': self.title,
            'color_mode': self.color_mode,
            'thumbnail_path': self.thumbnail_path,
            'tags': self.get_tags(),  # 返回解析后的标签列表
            'description': self.description,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'url': self.url
        }
        
        if include_path:
            data['file_path'] = self.file_path
            
        return data
    
    @property
    def url(self):
        """获取图片访问URL"""
        return f'/api/images/{self.id}/view'
    
    def set_tags(self, tags_list):
        """设置标签"""
        if tags_list:
            self.tags = json.dumps(tags_list)
        else:
            self.tags = None
    
    def get_tags(self):
        """获取标签列表"""
        if self.tags:
            try:
                return json.loads(self.tags)
            except (json.JSONDecodeError, TypeError):
                return []
        return []
    
    @staticmethod
    def get_user_images(user_id, page=1, per_page=20):
        """获取用户图片列表"""
        return Image.query.filter_by(user_id=user_id).order_by(
            Image.created_at.desc()
        ).paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )
    
    @staticmethod
    def get_public_images(page=1, per_page=20):
        """获取公开图片列表"""
        return Image.query.filter_by(is_public=True).order_by(
            Image.created_at.desc()
        ).paginate(
            page=page, 
            per_page=per_page, 
            error_out=False
        )

    def __repr__(self):
        return f'<Image {self.filename}>'