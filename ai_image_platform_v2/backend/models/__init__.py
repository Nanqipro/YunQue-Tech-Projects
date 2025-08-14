from flask_sqlalchemy import SQLAlchemy

# 初始化数据库对象
db = SQLAlchemy()

# 导入模型（在db初始化之后）
from .user import User
from .image import Image
from .processing_record import ProcessingRecord

__all__ = ['db', 'User', 'Image', 'ProcessingRecord']