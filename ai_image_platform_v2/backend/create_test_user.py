#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
创建测试用户脚本
"""

from app.models.user import User
from app.models import db
from app import create_app

def create_test_user():
    app = create_app()
    with app.app_context():
        # 检查admin用户是否存在
        user = User.query.filter_by(username='admin').first()
        if user:
            print('admin用户已存在')
            return
        
        # 创建admin用户
        new_user = User(
            username='admin',
            email='admin@example.com',
            nickname='管理员'
        )
        new_user.set_password('admin123')
        
        db.session.add(new_user)
        db.session.commit()
        
        print('已成功创建admin用户')
        print('用户名: admin')
        print('密码: admin123')
        print('邮箱: admin@example.com')

if __name__ == '__main__':
    create_test_user()