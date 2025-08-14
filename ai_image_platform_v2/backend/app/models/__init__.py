# -*- coding: utf-8 -*-
"""
数据模型模块
"""

from flask_sqlalchemy import SQLAlchemy

# 数据库实例
db = SQLAlchemy()

# 导入所有模型
from .user import User
from .image import Image
from .processing_record import ProcessingRecord
from .notification import Notification

__all__ = ['db', 'User', 'Image', 'ProcessingRecord', 'Notification']