from datetime import datetime
from . import db
import json

class ProcessingRecord(db.Model):
    """图片处理记录模型"""
    
    __tablename__ = 'processing_records'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # 处理信息
    tool_type = db.Column(db.String(50), nullable=False)  # beauty, filter, color, etc.
    tool_name = db.Column(db.String(100), nullable=False)  # 具体工具名称
    parameters = db.Column(db.Text, nullable=True)  # JSON格式存储处理参数
    
    # 处理结果
    status = db.Column(db.String(20), default='pending', nullable=False)  # pending, processing, completed, failed
    result_path = db.Column(db.String(500), nullable=True)  # 处理结果文件路径
    error_message = db.Column(db.Text, nullable=True)  # 错误信息
    
    # 性能指标
    processing_time = db.Column(db.Float, nullable=True)  # 处理耗时（秒）
    file_size_before = db.Column(db.Integer, nullable=True)  # 处理前文件大小
    file_size_after = db.Column(db.Integer, nullable=True)  # 处理后文件大小
    
    # 外键
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    image_id = db.Column(db.Integer, db.ForeignKey('images.id'), nullable=False)
    
    # 时间戳
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    started_at = db.Column(db.DateTime, nullable=True)
    completed_at = db.Column(db.DateTime, nullable=True)
    
    def __init__(self, tool_type=None, tool_name=None, user_id=None, image_id=None, parameters=None):
        # 调用父类构造函数
        super().__init__()
        
        # 设置字段值
        if tool_type is not None:
            self.tool_type = tool_type
        if tool_name is not None:
            self.tool_name = tool_name
        if user_id is not None:
            self.user_id = user_id
        if image_id is not None:
            self.image_id = image_id
        if parameters is not None:
            self.set_parameters(parameters)
    
    def to_dict(self, include_result=False):
        """转换为字典"""
        data = {
            'id': self.id,
            'tool_type': self.tool_type,
            'tool_name': self.tool_name,
            'parameters': self.get_parameters(),
            'status': self.status,
            'error_message': self.error_message,
            'processing_time': self.processing_time,
            'file_size_before': self.file_size_before,
            'file_size_after': self.file_size_after,
            'user_id': self.user_id,
            'image_id': self.image_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
        
        if include_result and self.result_path:
            data['result_path'] = self.result_path
            
        return data
    
    def get_parameters(self):
        """获取处理参数"""
        if self.parameters:
            try:
                return json.loads(self.parameters)
            except:
                return {}
        return {}
    
    def set_parameters(self, params_dict):
        """设置处理参数"""
        if params_dict:
            self.parameters = json.dumps(params_dict)
        else:
            self.parameters = None
    
    def start_processing(self):
        """开始处理"""
        self.status = 'processing'
        self.started_at = datetime.utcnow()
        db.session.commit()
    
    def complete_processing(self, result_path=None, file_size_after=None):
        """完成处理"""
        self.status = 'completed'
        self.completed_at = datetime.utcnow()
        self.result_path = result_path
        self.file_size_after = file_size_after
        
        # 计算处理时间
        if self.started_at:
            self.processing_time = (self.completed_at - self.started_at).total_seconds()
        
        db.session.commit()
    
    def fail_processing(self, error_message):
        """处理失败"""
        self.status = 'failed'
        self.completed_at = datetime.utcnow()
        self.error_message = error_message
        
        # 计算处理时间
        if self.started_at:
            self.processing_time = (self.completed_at - self.started_at).total_seconds()
        
        db.session.commit()
    
    def get_result_url(self, base_url=''):
        """获取处理结果URL"""
        if self.result_path and self.status == 'completed':
            return f"{base_url}/api/processing/{self.id}/result"
        return None
    
    @staticmethod
    def get_user_records(user_id, page=1, per_page=20, tool_type=None):
        """获取用户的处理记录"""
        query = ProcessingRecord.query.filter_by(user_id=user_id)
        
        if tool_type:
            query = query.filter_by(tool_type=tool_type)
        
        return query.order_by(ProcessingRecord.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
    
    @staticmethod
    def get_image_records(image_id, page=1, per_page=20):
        """获取图片的处理记录"""
        return ProcessingRecord.query.filter_by(image_id=image_id).order_by(
            ProcessingRecord.created_at.desc()
        ).paginate(page=page, per_page=per_page, error_out=False)
    
    @staticmethod
    def get_statistics(user_id=None, days=30):
        """获取处理统计信息"""
        from datetime import timedelta
        
        start_date = datetime.utcnow() - timedelta(days=days)
        query = ProcessingRecord.query.filter(ProcessingRecord.created_at >= start_date)
        
        if user_id:
            query = query.filter_by(user_id=user_id)
        
        records = query.all()
        
        stats = {
            'total_count': len(records),
            'completed_count': len([r for r in records if r.status == 'completed']),
            'failed_count': len([r for r in records if r.status == 'failed']),
            'avg_processing_time': 0,
            'tool_usage': {}
        }
        
        # 计算平均处理时间
        completed_records = [r for r in records if r.status == 'completed' and r.processing_time]
        if completed_records:
            stats['avg_processing_time'] = sum(r.processing_time for r in completed_records) / len(completed_records)
        
        # 统计工具使用情况
        for record in records:
            tool = record.tool_type
            if tool not in stats['tool_usage']:
                stats['tool_usage'][tool] = 0
            stats['tool_usage'][tool] += 1
        
        return stats
    
    def __repr__(self):
        return f'<ProcessingRecord {self.id}: {self.tool_type}/{self.tool_name}>'
    
    def __str__(self):
        return f"{self.tool_name} - {self.status}"