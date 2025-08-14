#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI图片处理平台后端启动文件
"""

import os
import sys
from flask import Flask
from flask_migrate import Migrate

# 加载环境变量
try:
    from dotenv import load_dotenv
    # 加载项目根目录的.env文件
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    env_path = os.path.join(project_root, '.env')
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print(f"已加载环境变量文件: {env_path}")
    else:
        print(f"环境变量文件不存在: {env_path}")
except ImportError:
    print("警告: python-dotenv 未安装，无法加载 .env 文件")

# 添加项目根目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from config.config import Config

def create_application():
    """创建Flask应用实例"""
    app = create_app()
    
    # 初始化数据库迁移
    migrate = Migrate(app, db)
    
    return app

def init_database(app):
    """初始化数据库"""
    with app.app_context():
        try:
            # 创建所有表
            db.create_all()
            print("数据库表创建成功")
            
            # 创建默认管理员用户（如果不存在）
            from app.models.user import User
            admin_user = User.query.filter_by(username='admin').first()
            if not admin_user:
                admin_user = User(
                    username='admin',
                    email='admin@example.com'
                )
                admin_user.set_password('admin123')
                admin_user.is_admin = True
                db.session.add(admin_user)
                db.session.commit()
                print("默认管理员用户创建成功 (用户名: admin, 密码: admin123)")
            
        except Exception as e:
            print(f"数据库初始化失败: {e}")
            sys.exit(1)

def main():
    """主函数"""
    # 创建应用
    app = create_application()
    
    # 检查是否需要初始化数据库
    if len(sys.argv) > 1 and sys.argv[1] == 'init-db':
        init_database(app)
        return
    
    # 创建必要的目录
    upload_dir = app.config.get('UPLOAD_FOLDER', 'static/uploads')
    os.makedirs(upload_dir, exist_ok=True)
    os.makedirs(os.path.join(upload_dir, 'images'), exist_ok=True)
    os.makedirs(os.path.join(upload_dir, 'processed'), exist_ok=True)
    
    # 获取运行配置
    host = os.environ.get('HOST', '127.0.0.1')
    port = int(os.environ.get('FLASK_PORT', os.environ.get('PORT', 5002)))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    
    print(f"启动AI图片处理平台后端服务...")
    print(f"访问地址: http://{host}:{port}")
    print(f"调试模式: {debug}")
    print(f"上传目录: {upload_dir}")
    
    # 启动应用
    try:
        app.run(
            host=host,
            port=port,
            debug=debug,
            threaded=True
        )
    except KeyboardInterrupt:
        print("\n服务已停止")
    except Exception as e:
        print(f"启动失败: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()