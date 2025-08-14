from flask import Blueprint, request, jsonify, send_file, current_app
import os
import uuid
from datetime import datetime
import mimetypes

from app.models.image import Image
from app.models.processing_record import ProcessingRecord
from app.models import db
from utils.auth import token_required
from services.image_processing_service import ImageProcessingService
from config.config import Config

processing_bp = Blueprint('processing', __name__, url_prefix='/api/processing')

@processing_bp.route('/beauty', methods=['POST'])
@token_required
def apply_beauty(current_user):
    """应用美颜效果"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({'error': '请提供图片ID'}), 400
        
        image_id = data['image_id']
        image = Image.query.filter_by(id=image_id, user_id=current_user.id).first()
        
        if not image:
            return jsonify({'error': '图片不存在或无权限访问'}), 404
        
        # 获取增强的美颜参数
        params = {
            'smoothing': data.get('smoothing', 0.6),  # 磨皮强度 0-1
            'whitening': data.get('whitening', 0.55),  # 美白强度 0-1
            'eye_enhancement': data.get('eye_enhancement', 0.65),  # 眼部增强 0-1
            'lip_enhancement': data.get('lip_enhancement', 0.45),   # 唇部增强 0-1
            'ai_mode': data.get('ai_mode', True),  # AI智能模式
            'detail_enhancement': data.get('detail_enhancement', 0.3),  # 细节增强 0-1
            'color_harmony': data.get('color_harmony', 0.4),  # 色彩和谐 0-1
            'noise_reduction': data.get('noise_reduction', 0.25)  # 降噪强度 0-1
        }
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='beauty',
            user_id=current_user.id,  # 使用当前认证用户的ID
            image_id=image.id,
            parameters=str(params)
        )
        
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        
        try:
            # 调用图片处理服务
            result_path = ImageProcessingService.apply_beauty(
                image.file_path, 
                params,
                current_user.id
            )
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, 'AI美颜', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'success': True,
                'message': 'AI美颜处理完成',
                'data': {
                    'record_id': record.id,
                    'result_url': record.result_url
                }
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            raise e
        
    except Exception as e:
        current_app.logger.error(f"美颜处理失败: {str(e)}")
        return jsonify({'error': '美颜处理失败'}), 500

@processing_bp.route('/filter', methods=['POST'])
@token_required
def apply_filter(current_user):
    """应用滤镜效果"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data or 'filter_type' not in data:
            return jsonify({'error': '请提供图片ID和滤镜类型'}), 400
        
        image_id = data['image_id']
        filter_type = data['filter_type']
        
        # 查找用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 获取滤镜参数
        params = {
            'filter_type': filter_type,
            'intensity': data.get('intensity', 80)  # 滤镜强度 0-100
        }
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='filter',
            user_id=current_user.id,
            image_id=image.id,
            parameters=str(params)
        )
        
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        db.session.commit()
        
        try:
            # 调用图片处理服务
            result_path = ImageProcessingService.apply_filter(
                image.file_path,
                filter_type,
                params.get('intensity', 80),
                current_user.id
            )
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, '滤镜处理', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'success': True,
                'message': '滤镜处理完成',
                'data': {
                    'record_id': record.id,
                    'result_url': record.result_url
                }
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            db.session.commit()
            raise e
        
    except Exception as e:
        current_app.logger.error(f"滤镜处理失败: {str(e)}")
        return jsonify({'error': '滤镜处理失败'}), 500

@processing_bp.route('/color-adjust', methods=['POST'])
@token_required
def adjust_color(current_user):
    """调整颜色"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({'error': '请提供图片ID'}), 400
        
        image_id = data['image_id']
        # 查找图片，允许访问用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 获取颜色调整参数
        params = {
            'brightness': data.get('brightness', 0),    # 亮度 -100 到 100
            'contrast': data.get('contrast', 0),        # 对比度 -100 到 100
            'saturation': data.get('saturation', 0),    # 饱和度 -100 到 100
            'hue': data.get('hue', 0),                  # 色相 -180 到 180
            'gamma': data.get('gamma', 1.0)             # 伽马值 0.1 到 3.0
        }
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='color',
            user_id=current_user.id,
            image_id=image.id,
            parameters=str(params)
        )
        
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        db.session.commit()
        
        try:
            # 调用图片处理服务
            result_path = ImageProcessingService.adjust_color(
                image.file_path,
                params,
                current_user.id
            )
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, '颜色调整', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'success': True,
                'message': '颜色调整完成',
                'data': {
                    'record_id': record.id,
                    'result_url': record.result_url
                }
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            db.session.commit()
            raise e
        
    except Exception as e:
        current_app.logger.error(f"颜色调整失败: {str(e)}")
        return jsonify({'error': '颜色调整失败'}), 500

@processing_bp.route('/id-photo', methods=['POST'])
@token_required
def generate_id_photo(current_user):
    """生成证件照"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({'error': '请提供图片ID'}), 400
        
        image_id = data['image_id']
        # 查找图片，允许访问用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 获取证件照参数
        params = {
            'photo_type': data.get('photo_type', '1_inch'),  # 1_inch, 2_inch, passport, id_card
            'background_color': data.get('background_color', 'white'),  # white, blue, red
            'beauty_strength': data.get('beauty_strength', 30),  # 美颜强度 0-100
            'auto_crop': data.get('auto_crop', True)
        }
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='id_photo',
            user_id=current_user.id,
            image_id=image.id,
            parameters=str(params)
        )
        
        record.file_size_before = image.file_size
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        db.session.commit()
        
        try:
            # 调用图片处理服务
            result_path = ImageProcessingService.generate_id_photo(
                image.file_path,
                params,
                current_user.id
            )
            
            # 获取处理后文件大小
            file_size_after = os.path.getsize(result_path)
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, '证件照生成', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'success': True,
                'message': '证件照生成完成',
                'data': {
                    'record_id': record.id,
                    'result_url': record.result_url
                }
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            db.session.commit()
            raise e
        
    except Exception as e:
        current_app.logger.error(f"证件照生成失败: {str(e)}")
        return jsonify({'error': '证件照生成失败'}), 500

@processing_bp.route('/background-blur', methods=['POST'])
@token_required
def blur_background(current_user):
    """背景虚化"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({'error': '请提供图片ID'}), 400
        
        image_id = data['image_id']
        # 查找用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 获取背景虚化参数
        params = {
            'blur_strength': data.get('blur_strength', 15),  # 虚化强度 1-50
            'edge_softness': data.get('edge_softness', 5)    # 边缘柔化 1-20
        }
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='background',
            user_id=current_user.id,
            image_id=image.id,
            parameters=str(params)
        )
        
        record.file_size_before = image.file_size
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        db.session.commit()
        
        try:
            # 调用图片处理服务
            result_path = ImageProcessingService.blur_background(
                image.file_path,
                params,
                current_user.id
            )
            
            # 获取处理后文件大小
            file_size_after = os.path.getsize(result_path)
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, '背景虚化', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'message': '背景虚化完成',
                'record_id': record.id,
                'result_url': record.result_url
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            db.session.commit()
            raise e
        
    except Exception as e:
        current_app.logger.error(f"背景虚化失败: {str(e)}")
        return jsonify({'error': '背景虚化失败'}), 500

@processing_bp.route('/background', methods=['POST'])
@token_required
def process_background(current_user):
    """背景处理（移除、替换、模糊）"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({'error': '请提供图片ID'}), 400
        
        image_id = data['image_id']
        # 查找用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 获取背景处理参数
        background_type = data.get('background_type', 'remove')  # remove, replace, blur
        params = {
            'background_type': background_type,
            'intensity': data.get('intensity', 0.8),  # 处理强度 0-1
        }
        
        # 根据背景类型添加特定参数
        if background_type == 'replace':
            params['background_color'] = data.get('background_color', '#FFFFFF')
            params['background_image'] = data.get('background_image')
        elif background_type == 'blur':
            params['blur_strength'] = data.get('blur_strength', 15)
            params['edge_softness'] = data.get('edge_softness', 5)
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='background',
            user_id=current_user.id,
            image_id=image.id,
            parameters=str(params)
        )
        
        record.file_size_before = image.file_size
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        db.session.commit()
        
        try:
            # 调用图片处理服务
            if background_type == 'remove':
                result_path = ImageProcessingService.remove_background(
                    image.file_path,
                    params,
                    current_user.id
                )
            elif background_type == 'replace':
                result_path = ImageProcessingService.replace_background(
                    image.file_path,
                    params,
                    current_user.id
                )
            elif background_type == 'blur':
                result_path = ImageProcessingService.blur_background(
                    image.file_path,
                    params,
                    current_user.id
                )
            else:
                raise ValueError(f"不支持的背景处理类型: {background_type}")
            
            # 获取处理后文件大小
            file_size_after = os.path.getsize(result_path)
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, f'背景{background_type}', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'success': True,
                'message': f'背景{background_type}处理完成',
                'data': {
                    'record_id': record.id,
                    'result_url': record.result_url
                }
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            db.session.commit()
            raise e
        
    except Exception as e:
        current_app.logger.error(f"背景处理失败: {str(e)}")
        return jsonify({'error': '背景处理失败'}), 500

@processing_bp.route('/repair', methods=['POST'])
@token_required
def repair_image(current_user):
    """智能修复"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({'error': '请提供图片ID'}), 400
        
        image_id = data['image_id']
        image = Image.query.filter_by(id=image_id, user_id=current_user.id).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 获取修复参数
        params = {
            'repair_type': data.get('repair_type', 'auto'),  # auto, scratch, noise
            'strength': data.get('strength', 50)             # 修复强度 1-100
        }
        
        # 创建处理记录
        record = ProcessingRecord(
            processing_type='repair',
            user_id=current_user.id,
            image_id=image.id,
            parameters=str(params)
        )
        
        record.file_size_before = image.file_size
        db.session.add(record)
        db.session.commit()
        
        # 开始处理
        record.mark_as_processing()
        db.session.commit()
        
        try:
            # 调用图片处理服务
            result_path = ImageProcessingService.repair_image(
                image.file_path,
                params,
                current_user.id
            )
            
            # 获取处理后文件大小
            file_size_after = os.path.getsize(result_path)
            
            # 完成处理
            record.mark_as_completed(result_path)
            db.session.commit()
            
            # 创建处理完成通知
            try:
                from controllers.notification_controller import create_processing_notification
                create_processing_notification(current_user.id, '智能修复', 'completed', record.id)
            except Exception as e:
                current_app.logger.warning(f"创建处理通知失败: {str(e)}")
            
            return jsonify({
                'message': '智能修复完成',
                'record_id': record.id,
                'result_url': record.result_url
            }), 200
            
        except Exception as e:
            record.mark_as_failed(str(e))
            db.session.commit()
            raise e
        
    except Exception as e:
        current_app.logger.error(f"智能修复失败: {str(e)}")
        return jsonify({'error': '智能修复失败'}), 500

@processing_bp.route('/<int:record_id>/result', methods=['GET'])
def get_processing_result(record_id):
    """获取处理结果文件（美颜处理不需要认证）"""
    try:
        record = ProcessingRecord.query.filter_by(id=record_id).first()
        
        if not record:
            return jsonify({'error': '处理记录不存在'}), 404
        
        if record.status != 'completed' or not record.result_path:
            return jsonify({'error': '处理结果不可用'}), 404
        
        if not os.path.exists(record.result_path):
            return jsonify({'error': '结果文件不存在'}), 404
        
        # 获取MIME类型
        mimetype = mimetypes.guess_type(record.result_path)[0]
        
        return send_file(
            record.result_path,
            mimetype=mimetype,
            as_attachment=False
        )
        
    except Exception as e:
        current_app.logger.error(f"获取处理结果失败: {str(e)}")
        return jsonify({'error': '获取处理结果失败'}), 500

@processing_bp.route('/auth/<int:record_id>/result', methods=['GET'])
@token_required
def get_processing_result_auth(current_user, record_id):
    """获取处理结果文件（需要认证的版本）"""
    try:
        record = ProcessingRecord.query.filter_by(
            id=record_id, 
            user_id=current_user.id
        ).first()
        
        if not record:
            return jsonify({'error': '处理记录不存在'}), 404
        
        if record.status != 'completed' or not record.result_path:
            return jsonify({'error': '处理结果不可用'}), 404
        
        if not os.path.exists(record.result_path):
            return jsonify({'error': '结果文件不存在'}), 404
        
        # 获取MIME类型
        mimetype = mimetypes.guess_type(record.result_path)[0]
        
        return send_file(
            record.result_path,
            mimetype=mimetype,
            as_attachment=False
        )
        
    except Exception as e:
        current_app.logger.error(f"获取处理结果失败: {str(e)}")
        return jsonify({'error': '获取处理结果失败'}), 500

@processing_bp.route('/records', methods=['GET'])
@token_required
def get_processing_records(current_user):
    """获取处理记录列表"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 100)
        tool_type = request.args.get('tool_type')
        
        pagination = ProcessingRecord.get_user_records(
            current_user.id, page, per_page, tool_type
        )
        
        return jsonify({
            'records': [record.to_dict() for record in pagination.items],
            'pagination': {
                'page': pagination.page,
                'pages': pagination.pages,
                'per_page': pagination.per_page,
                'total': pagination.total,
                'has_next': pagination.has_next,
                'has_prev': pagination.has_prev
            }
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取处理记录失败: {str(e)}")
        return jsonify({'error': '获取处理记录失败'}), 500

@processing_bp.route('/records/<int:record_id>', methods=['GET'])
@token_required
def get_processing_record(current_user, record_id):
    """获取单个处理记录"""
    try:
        record = ProcessingRecord.query.filter_by(
            id=record_id,
            user_id=current_user.id
        ).first()
        
        if not record:
            return jsonify({'error': '处理记录不存在'}), 404
        
        return jsonify({
            'record': record.to_dict(include_result=True)
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取处理记录失败: {str(e)}")
        return jsonify({'error': '获取处理记录失败'}), 500