from functools import wraps
from flask import request, jsonify, current_app
import jwt
from app.models.user import User

def token_required(f):
    """JWT token验证装饰器"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # 从请求头获取token
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                # 格式: "Bearer <token>"
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'error': 'Token格式错误'}), 401
        
        if not token:
            return jsonify({'error': '缺少访问令牌'}), 401
        
        try:
            # 解码token
            data = jwt.decode(
                token, 
                current_app.config['SECRET_KEY'], 
                algorithms=['HS256']
            )
            
            # 获取用户信息
            current_user = User.query.get(data['user_id'])
            
            if not current_user:
                return jsonify({'error': '用户不存在'}), 401
            
            if not current_user.is_active:
                return jsonify({'error': '账户已被禁用'}), 403
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token已过期'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token无效'}), 401
        except Exception as e:
            current_app.logger.error(f"Token验证失败: {str(e)}")
            return jsonify({'error': 'Token验证失败'}), 401
        
        # 将当前用户传递给被装饰的函数
        return f(current_user, *args, **kwargs)
    
    return decorated

def admin_required(f):
    """管理员权限验证装饰器"""
    @wraps(f)
    @token_required
    def decorated(current_user, *args, **kwargs):
        if not current_user.is_admin:
            return jsonify({'error': '需要管理员权限'}), 403
        
        return f(current_user, *args, **kwargs)
    
    return decorated

def optional_auth(f):
    """可选认证装饰器（用于公开接口，但可以获取用户信息）"""
    @wraps(f)
    def decorated(*args, **kwargs):
        current_user = None
        
        # 尝试获取token
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
                
                # 解码token
                data = jwt.decode(
                    token, 
                    current_app.config['SECRET_KEY'], 
                    algorithms=['HS256']
                )
                
                # 获取用户信息
                current_user = User.query.get(data['user_id'])
                
                if current_user and not current_user.is_active:
                    current_user = None
                    
            except (jwt.ExpiredSignatureError, jwt.InvalidTokenError, IndexError):
                # 忽略token错误，继续执行
                pass
        
        # 将当前用户（可能为None）传递给被装饰的函数
        return f(current_user, *args, **kwargs)
    
    return decorated