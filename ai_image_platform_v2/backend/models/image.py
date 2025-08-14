from datetime import datetime
from . import db
import os

class Image(db.Model):
    """图片模型"""
    
    __tablename__ = 'images'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # 基本信息
    filename = db.Column(db.String(255), nullable=False)
    original_filename = db.Column(db.String(255), nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    file_size = db.Column(db.Integer, nullable=False)  # 文件大小（字节）
    
    # 图片属性
    width = db.Column(db.Integer, nullable=False)
    height = db.Column(db.Integer, nullable=False)
    format = db.Column(db.String(10), nullable=False)  # PNG, JPEG, etc.
    color_mode = db.Column(db.String(10), nullable=True)  # RGB, RGBA, etc.
    
    # 缩略图
    thumbnail_path = db.Column(db.String(500), nullable=True)
    
    # 元数据
    title = db.Column(db.String(200), nullable=True)
    description = db.Column(db.Text, nullable=True)
    tags = db.Column(db.Text, nullable=True)  # JSON格式存储标签
    
    # 状态
    is_public = db.Column(db.Boolean, default=False, nullable=False)
    is_processed = db.Column(db.Boolean, default=False, nullable=False)
    
    # 外键
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # 时间戳
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # 关系
    processing_records = db.relationship('ProcessingRecord', backref='image', lazy='dynamic', cascade='all, delete-orphan')
    
    def __init__(self, filename, original_filename, file_path, file_size, width, height, format, user_id):
        self.filename = filename
        self.original_filename = original_filename
        self.file_path = file_path
        self.file_size = file_size
        self.width = width
        self.height = height
        self.format = format
        self.user_id = user_id
    
    def to_dict(self, include_path=False):
        """转换为字典"""
        data = {
            'id': self.id,
            'filename': self.filename,
            'original_filename': self.original_filename,
            'file_size': self.file_size,
            'width': self.width,
            'height': self.height,
            'format': self.format,
            'color_mode': self.color_mode,
            'title': self.title,
            'description': self.description,
            'tags': self.get_tags(),
            'is_public': self.is_public,
            'is_processed': self.is_processed,
            'user_id': self.user_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_path:
            data['file_path'] = self.file_path
            data['thumbnail_path'] = self.thumbnail_path
            
        return data
    
    def get_tags(self):
        """获取标签列表"""
        if self.tags:
            import json
            try:
                return json.loads(self.tags)
            except:
                return []
        return []
    
    def set_tags(self, tags_list):
        """设置标签列表"""
        import json
        self.tags = json.dumps(tags_list) if tags_list else None
    
    def get_file_url(self, base_url=''):
        """获取文件访问URL"""
        return f"{base_url}/api/images/{self.id}/file"
    
    def get_thumbnail_url(self, base_url=''):
        """获取缩略图访问URL"""
        if self.thumbnail_path:
            return f"{base_url}/api/images/{self.id}/thumbnail"
        return self.get_file_url(base_url)
    
    def delete_files(self):
        """删除关联的文件"""
        try:
            # 删除原图
            if os.path.exists(self.file_path):
                os.remove(self.file_path)
            
            # 删除缩略图
            if self.thumbnail_path and os.path.exists(self.thumbnail_path):
                os.remove(self.thumbnail_path)
                
            return True
        except Exception as e:
            print(f"删除文件失败: {e}")
            return False
    
    @staticmethod
    def get_user_images(user_id, page=1, per_page=20):
        """获取用户的图片列表"""
        return Image.query.filter_by(user_id=user_id).order_by(Image.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
    
    @staticmethod
    def get_public_images(page=1, per_page=20):
        """获取公开图片列表"""
        return Image.query.filter_by(is_public=True).order_by(Image.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
    
    def __repr__(self):
        return f'<Image {self.filename}>'
    
    def __str__(self):
        return self.original_filename