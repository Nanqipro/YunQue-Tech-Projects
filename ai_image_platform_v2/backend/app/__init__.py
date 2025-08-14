from flask import Flask
from flask_cors import CORS
from config.config import config
from .models import db

# 初始化扩展
cors = CORS()

def create_app(config_name='default'):
    """应用工厂函数"""
    app = Flask(__name__)
    
    # 加载配置
    config_class = config.get(config_name, config['default'])
    app.config.from_object(config_class)
    
    # 初始化配置
    config_class.init_app(app)
    
    # 初始化扩展
    db.init_app(app)
    cors.init_app(app, resources={
        r"/api/*": {
            "origins": ["http://localhost:3000", "http://127.0.0.1:3000"],
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # 注册蓝图
    from controllers.image_controller import image_bp
    from controllers.user_controller import user_bp
    from controllers.processing_controller import processing_bp
    from controllers.ai_controller import ai_bp
    from controllers.notification_controller import notification_bp
    from .health import health_bp
    
    app.register_blueprint(image_bp)  # image_bp already has url_prefix='/api/images'
    app.register_blueprint(user_bp)  # user_bp already has url_prefix='/api/users'
    app.register_blueprint(processing_bp)  # processing_bp already has url_prefix='/api/processing'
    app.register_blueprint(ai_bp)  # ai_bp already has url_prefix='/api/ai'
    app.register_blueprint(notification_bp)  # notification_bp already has url_prefix='/api/notifications'
    app.register_blueprint(health_bp, url_prefix='/api')
    
    # 创建数据库表
    with app.app_context():
        db.create_all()
    
    return app