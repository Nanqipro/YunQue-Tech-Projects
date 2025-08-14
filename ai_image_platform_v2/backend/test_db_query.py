#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试数据库查询
"""

from app.models.user import User
from app.models import db
from app import create_app

def test_db_query():
    app = create_app()
    with app.app_context():
        # 直接查询
        user1 = User.query.filter_by(username='admin').first()
        print(f'直接查询admin用户: {user1}')
        
        # OR查询
        user2 = User.query.filter(
            db.or_(
                User.username == 'admin',
                User.email == 'admin'
            )
        ).first()
        print(f'OR查询admin用户: {user2}')
        
        # 使用find_by_username_or_email方法
        user3 = User.find_by_username_or_email('admin')
        print(f'find_by_username_or_email查询admin用户: {user3}')
        
        # 查看所有用户
        all_users = User.query.all()
        print(f'所有用户数量: {len(all_users)}')
        for user in all_users:
            print(f'  用户: {user.username}, 邮箱: {user.email}')

if __name__ == '__main__':
    test_db_query()