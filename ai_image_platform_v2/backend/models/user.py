from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from . import db

class User(db.Model):
    """用户模型"""
    
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=True, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    
    # 用户信息
    nickname = db.Column(db.String(100), nullable=True)
    avatar_url = db.Column(db.String(255), nullable=True)
    bio = db.Column(db.Text, nullable=True)
    
    # 状态字段
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    is_verified = db.Column(db.Boolean, default=False, nullable=False)
    
    # 时间戳
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_login = db.Column(db.DateTime, nullable=True)
    
    # 关系
    images = db.relationship('Image', backref='owner', lazy='dynamic', cascade='all, delete-orphan')
    processing_records = db.relationship('ProcessingRecord', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    
    def set_password(self, password):
        """设置密码哈希"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """验证密码"""
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self, include_email=False, include_stats=False):
        """转换为字典"""
        data = {
            'id': self.id,
            'username': self.username,
            'nickname': self.nickname,
            'avatar_url': self.avatar_url,
            'bio': self.bio,
            'is_active': self.is_active,
            'is_verified': self.is_verified,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None
        }
        
        if include_email:
            data['email'] = self.email
            
        if include_stats:
            data['stats'] = {
                'total_images': self.images.count(),
                'total_processing_records': self.processing_records.count()
            }
            
        return data
    
    def update_last_login(self):
        """更新最后登录时间"""
        self.last_login = datetime.utcnow()
        db.session.commit()
    
    @staticmethod
    def find_by_username(username):
        """根据用户名查找用户"""
        return User.query.filter_by(username=username).first()
    
    @staticmethod
    def find_by_email(email):
        """根据邮箱查找用户"""
        return User.query.filter_by(email=email).first()
    
    @staticmethod
    def find_by_username_or_email(identifier):
        """根据用户名或邮箱查找用户"""
        return User.query.filter(
            (User.username == identifier) | 
            (User.email == identifier if identifier else False)
        ).first()
    
    def __repr__(self):
        return f'<User {self.username}>'
    
    def __str__(self):
        return self.username