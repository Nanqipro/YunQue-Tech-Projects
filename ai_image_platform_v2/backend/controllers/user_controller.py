from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import check_password_hash
import jwt
from datetime import datetime, timedelta
import re

from app.models.user import User
from app.models.image import Image
from app.models.processing_record import ProcessingRecord
from app.models import db
from utils.auth import token_required
from config.config import Config

user_bp = Blueprint('user', __name__, url_prefix='/api/users')

@user_bp.route('/register', methods=['POST'])
def register():
    """用户注册"""
    try:
        data = request.get_json()
        
        # 验证必填字段
        if not data or not data.get('username') or not data.get('password'):
            return jsonify({
                'success': False,
                'message': '用户名和密码不能为空'
            }), 400
        
        username = data['username'].strip()
        password = data['password']
        
        # 验证用户名格式
        if len(username) < 3 or len(username) > 50:
            return jsonify({
                'success': False,
                'message': '用户名长度必须在3-50个字符之间',
                'field': 'username'
            }), 400
        
        if not re.match(r'^[a-zA-Z0-9_\u4e00-\u9fa5]+$', username):
            return jsonify({
                'success': False,
                'message': '用户名只能包含字母、数字、下划线和中文',
                'field': 'username'
            }), 400
        

        
        # 验证密码强度
        if len(password) < 6:
            return jsonify({'error': '密码长度至少6个字符'}), 400
        
        # 检查用户名是否已存在
        if User.find_by_username(username):
            return jsonify({
                'success': False,
                'message': '用户名已存在',
                'field': 'username'
            }), 409
        

        
        # 创建新用户
        user = User()
        user.username = username
        user.set_password(password)
        
        # 设置可选字段
        if 'nickname' in data:
            user.nickname = data['nickname'].strip()
        if 'avatar_url' in data:
            user.avatar_url = data['avatar_url'].strip()
        
        db.session.add(user)
        db.session.commit()
        
        # 创建欢迎通知
        try:
            from controllers.notification_controller import create_welcome_notification
            create_welcome_notification(user.id)
        except Exception as e:
            current_app.logger.warning(f"创建欢迎通知失败: {str(e)}")
        
        return jsonify({
            'success': True,
            'message': '注册成功',
            'data': {
                'user': user.to_dict()
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"用户注册失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '注册失败，请稍后重试'
        }), 500

@user_bp.route('/login', methods=['POST'])
def login():
    """用户登录"""
    try:
        data = request.get_json()
        current_app.logger.info(f"登录请求数据: {data}")
        
        if not data or not data.get('username') or not data.get('password'):
            current_app.logger.error("登录失败: 用户名和密码不能为空")
            return jsonify({
                'success': False,
                'message': '用户名和密码不能为空'
            }), 400
        
        username = data['username'].strip()
        password = data['password']
        
        # 查找用户（支持用户名或邮箱登录）
        user = User.find_by_username_or_email(username)
        current_app.logger.info(f"查找用户结果: {user}")
        
        if not user:
            current_app.logger.error(f"用户不存在: {username}")
            return jsonify({
                'success': False,
                'message': '用户不存在'
            }), 404
        
        if not user.check_password(password):
            return jsonify({
                'success': False,
                'message': '密码错误'
            }), 401
        
        if not user.is_active:
            return jsonify({
                'success': False,
                'message': '账户已被禁用'
            }), 403
        
        # 生成JWT token
        token_payload = {
            'user_id': user.id,
            'username': user.username,
            'exp': datetime.utcnow() + timedelta(days=7)  # 7天过期
        }
        
        token = jwt.encode(
            token_payload,
            current_app.config['SECRET_KEY'],
            algorithm='HS256'
        )
        
        # 更新最后登录时间
        user.update_last_login()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': '登录成功',
            'data': {
                'token': token,
                'user': user.to_dict()
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"用户登录失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '登录失败，请稍后重试'
        }), 500

@user_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    """获取用户资料"""
    try:
        return jsonify({
            'success': True,
            'data': current_user.to_dict(include_stats=True)
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取用户资料失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '获取用户资料失败'
        }), 500

@user_bp.route('/profile', methods=['PUT'])
@token_required
def update_profile(current_user):
    """更新用户资料"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': '请提供要更新的数据'}), 400
        
        # 更新可修改的字段
        if 'nickname' in data:
            current_user.nickname = data['nickname'].strip() if data['nickname'] else None
        
        if 'avatar_url' in data:
            current_user.avatar_url = data['avatar_url'].strip() if data['avatar_url'] else None
        
        if 'bio' in data:
            current_user.bio = data['bio'].strip() if data['bio'] else None
        
        current_user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'message': '资料更新成功',
            'user': current_user.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"更新用户资料失败: {str(e)}")
        return jsonify({'error': '更新资料失败'}), 500

@user_bp.route('/change-password', methods=['PUT'])
@token_required
def change_password(current_user):
    """修改密码"""
    try:
        data = request.get_json()
        
        if not data or not data.get('old_password') or not data.get('new_password'):
            return jsonify({'error': '请提供旧密码和新密码'}), 400
        
        old_password = data['old_password']
        new_password = data['new_password']
        
        # 验证旧密码
        if not current_user.check_password(old_password):
            return jsonify({'error': '旧密码错误'}), 401
        
        # 验证新密码
        if len(new_password) < 6:
            return jsonify({'error': '新密码长度至少6个字符'}), 400
        
        if old_password == new_password:
            return jsonify({'error': '新密码不能与旧密码相同'}), 400
        
        # 更新密码
        current_user.set_password(new_password)
        current_user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({'message': '密码修改成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"修改密码失败: {str(e)}")
        return jsonify({'error': '修改密码失败'}), 500

@user_bp.route('/stats', methods=['GET'])
@token_required
def get_user_stats(current_user):
    """获取用户统计信息"""
    try:
        # 图片统计
        total_images = Image.query.filter_by(user_id=current_user.id).count()
        public_images = Image.query.filter_by(user_id=current_user.id, is_public=True).count()
        
        # 处理记录统计
        processing_stats = ProcessingRecord.get_statistics(current_user.id)
        
        # 存储使用统计
        total_storage = db.session.query(db.func.sum(Image.file_size)).filter_by(user_id=current_user.id).scalar() or 0
        
        stats = {
            'images': {
                'total': total_images,
                'public': public_images,
                'private': total_images - public_images
            },
            'processing': processing_stats,
            'storage': {
                'total_bytes': total_storage,
                'total_mb': round(total_storage / (1024 * 1024), 2)
            }
        }
        
        return jsonify({'stats': stats}), 200
        
    except Exception as e:
        current_app.logger.error(f"获取用户统计失败: {str(e)}")
        return jsonify({'error': '获取统计信息失败'}), 500

@user_bp.route('/verify-token', methods=['POST'])
@token_required
def verify_token(current_user):
    """验证token有效性"""
    return jsonify({
        'valid': True,
        'user': current_user.to_dict()
    }), 200

@user_bp.route('/logout', methods=['POST'])
@token_required
def logout(current_user):
    """用户登出（客户端处理）"""
    return jsonify({'message': '登出成功'}), 200