from datetime import datetime
from app.models import db

class Notification(db.Model):
    """通知模型"""
    __tablename__ = 'notifications'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(50), nullable=False, default='system')  # system, processing, security, promotion
    priority = db.Column(db.String(20), nullable=False, default='normal')  # low, normal, high, urgent
    is_read = db.Column(db.Boolean, nullable=False, default=False)
    action_type = db.Column(db.String(50))  # view_result, download, settings等
    action_data = db.Column(db.JSON)  # 操作相关的数据
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    read_at = db.Column(db.DateTime)
    
    # 关联关系
    user = db.relationship('User', backref=db.backref('notifications', lazy=True, cascade='all, delete-orphan'))
    
    def __init__(self, user_id, title, content, category='system', priority='normal', action_type=None, action_data=None):
        self.user_id = user_id
        self.title = title
        self.content = content
        self.category = category
        self.priority = priority
        self.action_type = action_type
        self.action_data = action_data
    
    def mark_as_read(self):
        """标记为已读"""
        self.is_read = True
        self.read_at = datetime.utcnow()
    
    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'title': self.title,
            'content': self.content,
            'category': self.category,
            'priority': self.priority,
            'is_read': self.is_read,
            'action_type': self.action_type,
            'action_data': self.action_data,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'read_at': self.read_at.isoformat() if self.read_at else None
        }
    
    @staticmethod
    def create_system_notification(user_id, title, content, priority='normal', action_type=None, action_data=None):
        """创建系统通知"""
        notification = Notification(
            user_id=user_id,
            title=title,
            content=content,
            category='system',
            priority=priority,
            action_type=action_type,
            action_data=action_data
        )
        db.session.add(notification)
        return notification
    
    @staticmethod
    def create_processing_notification(user_id, title, content, priority='normal', action_type=None, action_data=None):
        """创建处理通知"""
        notification = Notification(
            user_id=user_id,
            title=title,
            content=content,
            category='processing',
            priority=priority,
            action_type=action_type,
            action_data=action_data
        )
        db.session.add(notification)
        return notification
    
    @staticmethod
    def create_security_notification(user_id, title, content, priority='high', action_type=None, action_data=None):
        """创建安全通知"""
        notification = Notification(
            user_id=user_id,
            title=title,
            content=content,
            category='security',
            priority=priority,
            action_type=action_type,
            action_data=action_data
        )
        db.session.add(notification)
        return notification
    
    @staticmethod
    def create_promotion_notification(user_id, title, content, priority='low', action_type=None, action_data=None):
        """创建推广通知"""
        notification = Notification(
            user_id=user_id,
            title=title,
            content=content,
            category='promotion',
            priority=priority,
            action_type=action_type,
            action_data=action_data
        )
        db.session.add(notification)
        return notification
    
    def __repr__(self):
        return f'<Notification {self.id}: {self.title}>'