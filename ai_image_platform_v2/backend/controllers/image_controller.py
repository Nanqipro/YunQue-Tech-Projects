from flask import Blueprint, request, jsonify, send_file, current_app
from werkzeug.utils import secure_filename
from PIL import Image as PILImage
import os
import uuid
from datetime import datetime
import mimetypes

from app.models.image import Image
from app.models.user import User
from app.models import db
from utils.auth import token_required
from utils.image_utils import create_thumbnail, validate_image
from config.config import Config

image_bp = Blueprint('image', __name__, url_prefix='/api/images')

@image_bp.route('/upload', methods=['POST'])
@token_required
def upload_image(current_user):
    """上传图片（需要登录）"""
    current_app.logger.info(f"收到图片上传请求，Content-Type: {request.content_type}")
    current_app.logger.info(f"请求文件: {list(request.files.keys())}")
    current_app.logger.info(f"请求表单: {list(request.form.keys())}")
    current_app.logger.info(f"用户认证成功: {current_user.id}")
    
    try:
        if 'file' not in request.files:
            current_app.logger.error("请求中没有找到'file'字段")
            return jsonify({'error': '没有选择文件'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': '没有选择文件'}), 400
        
        # 验证文件类型
        if not validate_image(file):
            return jsonify({'error': '不支持的文件格式'}), 400
        
        # 生成安全的文件名
        original_filename = secure_filename(file.filename)
        file_extension = os.path.splitext(original_filename)[1].lower()
        unique_filename = f"{uuid.uuid4().hex}{file_extension}"
        
        # 创建上传目录
        upload_dir = os.path.join(current_app.config['UPLOAD_FOLDER'], 'images')
        os.makedirs(upload_dir, exist_ok=True)
        
        # 保存文件
        file_path = os.path.join(upload_dir, unique_filename)
        file.save(file_path)
        
        # 获取图片信息
        with PILImage.open(file_path) as img:
            width, height = img.size
            format = img.format
            color_mode = img.mode
        
        # 获取文件大小
        file_size = os.path.getsize(file_path)
        
        # 创建缩略图
        thumbnail_path = create_thumbnail(file_path, upload_dir)
        
        # 保存到数据库
        image = Image(
            filename=unique_filename,
            original_filename=original_filename,
            file_path=file_path,
            file_size=file_size,
            width=width,
            height=height,
            format=format,
            user_id=current_user.id
        )
        
        image.color_mode = color_mode
        image.thumbnail_path = thumbnail_path
        
        # 处理可选参数
        if 'title' in request.form:
            image.title = request.form['title']
        if 'description' in request.form:
            image.description = request.form['description']
        if 'tags' in request.form:
            tags = request.form['tags'].split(',')
            image.set_tags([tag.strip() for tag in tags if tag.strip()])
        if 'is_public' in request.form:
            image.is_public = request.form['is_public'].lower() == 'true'
        
        db.session.add(image)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': '图片上传成功',
            'data': {
                'id': image.id,
                'filename': image.original_filename,
                'size': image.file_size,
                'url': f'http://localhost:5002/api/images/{image.id}/file'
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"图片上传失败: {str(e)}")
        return jsonify({'error': '图片上传失败'}), 500

@image_bp.route('/', methods=['GET'])
@token_required
def get_images(current_user):
    """获取用户图片列表"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 100)
        
        pagination = Image.get_user_images(current_user.id, page, per_page)
        
        return jsonify({
            'images': [image.to_dict() for image in pagination.items],
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
        current_app.logger.error(f"获取图片列表失败: {str(e)}")
        return jsonify({'error': '获取图片列表失败'}), 500

@image_bp.route('/<int:image_id>', methods=['GET'])
@token_required
def get_image(current_user, image_id):
    """获取单个图片信息"""
    try:
        # 查找用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        return jsonify({
            'image': image.to_dict(include_path=True)
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"获取图片信息失败: {str(e)}")
        return jsonify({'error': '获取图片信息失败'}), 500

@image_bp.route('/<int:image_id>/file', methods=['GET'])
def get_image_file(image_id):
    """获取图片文件"""
    try:
        image = Image.query.get_or_404(image_id)
        
        # 检查文件是否存在
        if not os.path.exists(image.file_path):
            return jsonify({'error': '文件不存在'}), 404
        
        # 获取MIME类型
        mimetype = mimetypes.guess_type(image.file_path)[0]
        
        return send_file(
            image.file_path,
            mimetype=mimetype,
            as_attachment=False,
            download_name=image.original_filename
        )
        
    except Exception as e:
        current_app.logger.error(f"获取图片文件失败: {str(e)}")
        return jsonify({'error': '获取图片文件失败'}), 500

@image_bp.route('/<int:image_id>/thumbnail', methods=['GET'])
def get_image_thumbnail(image_id):
    """获取图片缩略图"""
    try:
        image = Image.query.get_or_404(image_id)
        
        # 如果有缩略图，返回缩略图
        if image.thumbnail_path and os.path.exists(image.thumbnail_path):
            return send_file(
                image.thumbnail_path,
                mimetype='image/jpeg',
                as_attachment=False
            )
        
        # 否则返回原图
        if os.path.exists(image.file_path):
            return send_file(
                image.file_path,
                mimetype=mimetypes.guess_type(image.file_path)[0],
                as_attachment=False
            )
        
        return jsonify({'error': '文件不存在'}), 404
        
    except Exception as e:
        current_app.logger.error(f"获取缩略图失败: {str(e)}")
        return jsonify({'error': '获取缩略图失败'}), 500

@image_bp.route('/<int:image_id>', methods=['PUT'])
@token_required
def update_image(current_user, image_id):
    """更新图片信息"""
    try:
        # 查找用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        data = request.get_json()
        
        # 更新可修改的字段
        if 'title' in data:
            image.title = data['title']
        if 'description' in data:
            image.description = data['description']
        if 'tags' in data:
            image.set_tags(data['tags'])
        if 'is_public' in data:
            image.is_public = data['is_public']
        
        image.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'message': '图片信息更新成功',
            'image': image.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"更新图片信息失败: {str(e)}")
        return jsonify({'error': '更新图片信息失败'}), 500

@image_bp.route('/<int:image_id>', methods=['DELETE'])
@token_required
def delete_image(current_user, image_id):
    """删除图片"""
    try:
        # 查找用户自己的图片或匿名上传的图片
        image = Image.query.filter(
            Image.id == image_id,
            (Image.user_id == current_user.id) | (Image.user_id.is_(None))
        ).first()
        
        if not image:
            return jsonify({'error': '图片不存在'}), 404
        
        # 删除文件
        image.delete_files()
        
        # 删除数据库记录
        db.session.delete(image)
        db.session.commit()
        
        return jsonify({'message': '图片删除成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"删除图片失败: {str(e)}")
        return jsonify({'error': '删除图片失败'}), 500

@image_bp.route('/public', methods=['GET'])
def get_public_images():
    """获取公开图片列表"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 100)
        
        pagination = Image.get_public_images(page, per_page)
        
        return jsonify({
            'images': [image.to_dict() for image in pagination.items],
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
        current_app.logger.error(f"获取公开图片列表失败: {str(e)}")
        return jsonify({'error': '获取公开图片列表失败'}), 500