# -*- coding: utf-8 -*-
"""
通知控制器
处理通知相关的API请求
"""

from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from sqlalchemy import desc, and_, or_

from app.models.notification import Notification
from app.models import db
from utils.auth import token_required

# 创建蓝图
notification_bp = Blueprint('notifications', __name__, url_prefix='/api/notifications')

@notification_bp.route('/', methods=['GET'])
@token_required
def get_notifications(current_user):
    """获取通知列表"""
    try:
        # 获取查询参数
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        category = request.args.get('category')
        is_read = request.args.get('is_read')
        priority = request.args.get('priority')
        search = request.args.get('search')
        
        # 限制每页数量
        per_page = min(per_page, 100)
        
        # 构建查询
        query = Notification.query.filter_by(user_id=current_user.id)
        
        # 分类筛选
        if category:
            query = query.filter(Notification.category == category)
        
        # 已读状态筛选
        if is_read is not None:
            is_read_bool = is_read.lower() in ['true', '1', 'yes']
            query = query.filter(Notification.is_read == is_read_bool)
        
        # 优先级筛选
        if priority:
            query = query.filter(Notification.priority == priority)
        
        # 搜索
        if search:
            search_term = f'%{search}%'
            query = query.filter(
                or_(
                    Notification.title.like(search_term),
                    Notification.content.like(search_term)
                )
            )
        
        # 按创建时间倒序排列
        query = query.order_by(desc(Notification.created_at))
        
        # 分页
        pagination = query.paginate(
            page=page,
            per_page=per_page,
            error_out=False
        )
        
        notifications = [notification.to_dict() for notification in pagination.items]
        
        return jsonify({
            'success': True,
            'data': {
                'notifications': notifications,
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': pagination.total,
                    'pages': pagination.pages,
                    'has_prev': pagination.has_prev,
                    'has_next': pagination.has_next
                }
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取通知列表失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '获取通知列表失败'
        }), 500

@notification_bp.route('/unread-count', methods=['GET'])
@token_required
def get_unread_count(current_user):
    """获取未读通知数量"""
    try:
        count = Notification.query.filter_by(
            user_id=current_user.id,
            is_read=False
        ).count()
        
        return jsonify({
            'success': True,
            'data': {
                'unread_count': count
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取未读通知数量失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '获取未读通知数量失败'
        }), 500

@notification_bp.route('/<int:notification_id>/read', methods=['POST'])
@token_required
def mark_as_read(current_user, notification_id):
    """标记通知为已读"""
    try:
        notification = Notification.query.filter_by(
            id=notification_id,
            user_id=current_user.id
        ).first()
        
        if not notification:
            return jsonify({
                'success': False,
                'message': '通知不存在'
            }), 404
        
        if not notification.is_read:
            notification.mark_as_read()
            db.session.commit()
        
        return jsonify({
            'success': True,
            'message': '标记成功'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"标记通知已读失败: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': '标记失败'
        }), 500

@notification_bp.route('/mark-all-read', methods=['POST'])
@token_required
def mark_all_as_read(current_user):
    """标记所有通知为已读"""
    try:
        # 获取所有未读通知
        unread_notifications = Notification.query.filter_by(
            user_id=current_user.id,
            is_read=False
        ).all()
        
        # 批量标记为已读
        for notification in unread_notifications:
            notification.mark_as_read()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'已标记 {len(unread_notifications)} 条通知为已读'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"批量标记通知已读失败: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': '批量标记失败'
        }), 500

@notification_bp.route('/<int:notification_id>', methods=['DELETE'])
@token_required
def delete_notification(current_user, notification_id):
    """删除通知"""
    try:
        notification = Notification.query.filter_by(
            id=notification_id,
            user_id=current_user.id
        ).first()
        
        if not notification:
            return jsonify({
                'success': False,
                'message': '通知不存在'
            }), 404
        
        db.session.delete(notification)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': '删除成功'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"删除通知失败: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': '删除失败'
        }), 500

@notification_bp.route('/batch-delete', methods=['POST'])
@token_required
def batch_delete_notifications(current_user):
    """批量删除通知"""
    try:
        data = request.get_json()
        
        if not data or 'notification_ids' not in data:
            return jsonify({
                'success': False,
                'message': '缺少通知ID列表'
            }), 400
        
        notification_ids = data['notification_ids']
        
        if not isinstance(notification_ids, list) or not notification_ids:
            return jsonify({
                'success': False,
                'message': '通知ID列表格式错误'
            }), 400
        
        # 查询要删除的通知
        notifications = Notification.query.filter(
            and_(
                Notification.id.in_(notification_ids),
                Notification.user_id == current_user.id
            )
        ).all()
        
        # 批量删除
        for notification in notifications:
            db.session.delete(notification)
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'已删除 {len(notifications)} 条通知'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"批量删除通知失败: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': '批量删除失败'
        }), 500

@notification_bp.route('/clear-all', methods=['POST'])
@token_required
def clear_all_notifications(current_user):
    """清空所有通知"""
    try:
        # 获取用户的所有通知
        notifications = Notification.query.filter_by(
            user_id=current_user.id
        ).all()
        
        # 批量删除
        for notification in notifications:
            db.session.delete(notification)
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'已清空 {len(notifications)} 条通知'
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"清空通知失败: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'message': '清空失败'
        }), 500

@notification_bp.route('/<int:notification_id>', methods=['GET'])
@token_required
def get_notification_detail(current_user, notification_id):
    """获取通知详情"""
    try:
        notification = Notification.query.filter_by(
            id=notification_id,
            user_id=current_user.id
        ).first()
        
        if not notification:
            return jsonify({
                'success': False,
                'message': '通知不存在'
            }), 404
        
        # 如果是未读通知，自动标记为已读
        if not notification.is_read:
            notification.mark_as_read()
            db.session.commit()
        
        return jsonify({
            'success': True,
            'data': notification.to_dict()
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取通知详情失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '获取通知详情失败'
        }), 500

@notification_bp.route('/categories', methods=['GET'])
@token_required
def get_notification_categories(current_user):
    """获取通知分类统计"""
    try:
        # 查询各分类的通知数量
        categories = db.session.query(
            Notification.category,
            db.func.count(Notification.id).label('total'),
            db.func.sum(db.case([(Notification.is_read == False, 1)], else_=0)).label('unread')
        ).filter(
            Notification.user_id == current_user.id
        ).group_by(Notification.category).all()
        
        category_stats = []
        for category, total, unread in categories:
            category_stats.append({
                'category': category,
                'total': total,
                'unread': unread or 0
            })
        
        return jsonify({
            'success': True,
            'data': {
                'categories': category_stats
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取通知分类统计失败: {str(e)}")
        return jsonify({
            'success': False,
            'message': '获取分类统计失败'
        }), 500

# 创建通知的辅助函数（供其他模块调用）
def create_processing_notification(user_id, processing_type, status, record_id=None):
    """创建处理通知"""
    try:
        if status == 'completed':
            title = f"{processing_type}处理完成"
            content = f"您的{processing_type}处理已完成，可以查看结果了。"
            action_type = 'view_result'
            action_data = {'record_id': record_id} if record_id else None
        elif status == 'failed':
            title = f"{processing_type}处理失败"
            content = f"您的{processing_type}处理失败，请重试或联系客服。"
            action_type = 'retry'
            action_data = {'record_id': record_id} if record_id else None
        else:
            title = f"{processing_type}处理中"
            content = f"您的{processing_type}正在处理中，请稍候。"
            action_type = None
            action_data = None
        
        notification = Notification.create_processing_notification(
            user_id=user_id,
            title=title,
            content=content,
            priority='normal',
            action_type=action_type,
            action_data=action_data
        )
        
        db.session.commit()
        return notification
        
    except Exception as e:
        current_app.logger.error(f"创建处理通知失败: {str(e)}")
        db.session.rollback()
        return None

def create_welcome_notification(user_id):
    """创建欢迎通知"""
    try:
        notification = Notification.create_system_notification(
            user_id=user_id,
            title="欢迎使用AI图像处理平台",
            content="欢迎您注册AI图像处理平台！您可以使用我们的各种图像处理功能，包括美颜、滤镜、背景处理等。如有任何问题，请随时联系我们。",
            priority='normal',
            action_type='settings',
            action_data={'tab': 'profile'}
        )
        
        db.session.commit()
        return notification
        
    except Exception as e:
        current_app.logger.error(f"创建欢迎通知失败: {str(e)}")
        db.session.rollback()
        return None