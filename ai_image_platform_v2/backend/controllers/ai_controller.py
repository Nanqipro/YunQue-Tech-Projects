# -*- coding: utf-8 -*-
"""
AI控制器
处理AI相关的API请求，包括图像分析和智能建议
"""

from flask import Blueprint, request, jsonify, current_app
import os
from datetime import datetime

from app.models.image import Image
from app.models import db
from utils.auth import token_required
from services.ai_service import ai_service
from config.config import Config

# 创建蓝图
ai_bp = Blueprint('ai', __name__, url_prefix='/api/ai')

@ai_bp.route('/analyze', methods=['POST'])
@token_required
def analyze_image(current_user):
    """分析图片内容"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({
                'success': False,
                'message': '缺少图片ID'
            }), 400
        
        image_id = data['image_id']
        analysis_type = data.get('analysis_type', 'general_analysis')
        
        # 验证图片是否存在
        image = Image.query.filter_by(id=image_id).first()
        
        if not image:
            return jsonify({
                'success': False,
                'message': '图片不存在'
            }), 404
        
        # 检查图片文件是否存在
        if not os.path.exists(image.file_path):
            return jsonify({
                'success': False,
                'message': '图片文件不存在'
            }), 404
        
        # 调用AI服务进行分析
        result = ai_service.analyze_image(image.file_path, analysis_type)
        
        # 记录分析结果到数据库（可选）
        if result['success']:
            # 这里可以添加分析记录的保存逻辑
            pass
        
        return jsonify(result)
        
    except Exception as e:
        current_app.logger.error(f"图像分析错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'分析失败: {str(e)}'
        }), 500

@ai_bp.route('/beauty-suggestions', methods=['POST'])
def get_beauty_suggestions():
    """获取美颜建议"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({
                'success': False,
                'message': '缺少图片ID'
            }), 400
        
        image_id = data['image_id']
        
        # 验证图片是否存在
        image = Image.query.filter_by(id=image_id).first()
        
        if not image:
            return jsonify({
                'success': False,
                'message': '图片不存在或无权限访问'
            }), 404
        
        # 检查图片文件是否存在
        if not os.path.exists(image.file_path):
            return jsonify({
                'success': False,
                'message': '图片文件不存在'
            }), 404
        
        # 获取美颜建议
        result = ai_service.get_beauty_suggestions(image.file_path)
        
        return jsonify(result)
        
    except Exception as e:
        current_app.logger.error(f"美颜建议获取错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'获取建议失败: {str(e)}'
        }), 500

@ai_bp.route('/style-recommendations', methods=['POST'])
@token_required
def get_style_recommendations(current_user):
    """获取风格推荐"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({
                'success': False,
                'message': '缺少图片ID'
            }), 400
        
        image_id = data['image_id']
        
        # 验证图片是否存在且属于当前用户
        image = Image.query.filter_by(
            id=image_id,
            user_id=current_user.id
        ).first()
        
        if not image:
            return jsonify({
                'success': False,
                'message': '图片不存在或无权限访问'
            }), 404
        
        # 检查图片文件是否存在
        if not os.path.exists(image.file_path):
            return jsonify({
                'success': False,
                'message': '图片文件不存在'
            }), 404
        
        # 获取风格推荐
        result = ai_service.get_style_recommendations(image.file_path)
        
        return jsonify(result)
        
    except Exception as e:
        current_app.logger.error(f"风格推荐获取错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'获取推荐失败: {str(e)}'
        }), 500

@ai_bp.route('/processing-suggestions', methods=['POST'])
@token_required
def get_processing_suggestions(current_user):
    """获取处理建议"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({
                'success': False,
                'message': '缺少图片ID'
            }), 400
        
        image_id = data['image_id']
        
        # 验证图片是否存在且属于当前用户
        image = Image.query.filter_by(
            id=image_id,
            user_id=current_user.id
        ).first()
        
        if not image:
            return jsonify({
                'success': False,
                'message': '图片不存在或无权限访问'
            }), 404
        
        # 检查图片文件是否存在
        if not os.path.exists(image.file_path):
            return jsonify({
                'success': False,
                'message': '图片文件不存在'
            }), 404
        
        # 生成处理建议
        result = ai_service.generate_processing_suggestions(image.file_path)
        
        return jsonify(result)
        
    except Exception as e:
        current_app.logger.error(f"处理建议生成错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'生成建议失败: {str(e)}'
        }), 500

@ai_bp.route('/composition-analysis', methods=['POST'])
@token_required
def get_composition_analysis(current_user):
    """获取构图分析"""
    try:
        data = request.get_json()
        
        if not data or 'image_id' not in data:
            return jsonify({
                'success': False,
                'message': '缺少图片ID'
            }), 400
        
        image_id = data['image_id']
        
        # 验证图片是否存在且属于当前用户
        image = Image.query.filter_by(
            id=image_id,
            user_id=current_user.id
        ).first()
        
        if not image:
            return jsonify({
                'success': False,
                'message': '图片不存在或无权限访问'
            }), 404
        
        # 检查图片文件是否存在
        if not os.path.exists(image.file_path):
            return jsonify({
                'success': False,
                'message': '图片文件不存在'
            }), 404
        
        # 获取构图分析
        result = ai_service.get_composition_analysis(image.file_path)
        
        return jsonify(result)
        
    except Exception as e:
        current_app.logger.error(f"构图分析错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'分析失败: {str(e)}'
        }), 500

@ai_bp.route('/config', methods=['GET'])
@token_required
def get_ai_config(current_user):
    """获取AI配置信息"""
    try:
        ai_config = Config.get_ai_config()
        
        # 返回安全的配置信息（不包含API密钥）
        safe_config = {
            'features': {
                'image_analysis': ai_config.ENABLE_IMAGE_ANALYSIS,
                'smart_enhancement': ai_config.ENABLE_SMART_ENHANCEMENT,
                'style_transfer': ai_config.ENABLE_STYLE_TRANSFER,
                'object_detection': ai_config.ENABLE_OBJECT_DETECTION,
                'face_recognition': ai_config.ENABLE_FACE_RECOGNITION
            },
            'limits': {
                'max_image_size_mb': ai_config.MAX_IMAGE_SIZE_MB,
                'supported_formats': ai_config.SUPPORTED_IMAGE_FORMATS
            },
            'model_info': {
                'text_model': ai_config.QWEN_MODEL_NAME,
                'vision_model': ai_config.QWEN_VL_MODEL_NAME
            }
        }
        
        return jsonify({
            'success': True,
            'config': safe_config
        })
        
    except Exception as e:
        current_app.logger.error(f"获取AI配置错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'获取配置失败: {str(e)}'
        }), 500

@ai_bp.route('/test-connection', methods=['GET'])
@token_required
def test_ai_connection(current_user):
    """测试AI服务连接"""
    try:
        # 只有管理员可以测试连接
        if not current_user.is_admin:
            return jsonify({
                'success': False,
                'message': '权限不足'
            }), 403
        
        result = ai_service.validate_api_connection()
        
        return jsonify(result)
        
    except Exception as e:
        current_app.logger.error(f"AI连接测试错误: {str(e)}")
        return jsonify({
            'success': False,
            'message': f'连接测试失败: {str(e)}'
        }), 500

@ai_bp.route('/health', methods=['GET'])
def health_check():
    """AI服务健康检查"""
    try:
        ai_config = Config.get_ai_config()
        
        health_status = {
            'status': 'healthy',
            'features_enabled': {
                'image_analysis': ai_config.ENABLE_IMAGE_ANALYSIS,
                'smart_enhancement': ai_config.ENABLE_SMART_ENHANCEMENT,
                'style_transfer': ai_config.ENABLE_STYLE_TRANSFER,
                'object_detection': ai_config.ENABLE_OBJECT_DETECTION,
                'face_recognition': ai_config.ENABLE_FACE_RECOGNITION
            },
            'api_configured': bool(ai_config.QWEN_API_KEY),
            'timestamp': datetime.now().isoformat()
        }
        
        return jsonify(health_status)
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500