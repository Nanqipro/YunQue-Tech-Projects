from PIL import Image, ImageOps
import os
import mimetypes
from werkzeug.utils import secure_filename

# 支持的图片格式
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'tiff'}
ALLOWED_MIMETYPES = {
    'image/png',
    'image/jpeg', 
    'image/jpg',
    'image/gif',
    'image/bmp',
    'image/webp',
    'image/tiff'
}

# 最大文件大小（字节）
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

# 缩略图尺寸
THUMBNAIL_SIZE = (300, 300)

def validate_image(file):
    """验证上传的图片文件"""
    try:
        # 检查文件名
        if not file.filename:
            return False
        
        # 检查文件扩展名
        filename = secure_filename(file.filename.lower())
        if '.' not in filename:
            return False
        
        extension = filename.rsplit('.', 1)[1]
        if extension not in ALLOWED_EXTENSIONS:
            return False
        
        # 检查MIME类型
        if file.content_type not in ALLOWED_MIMETYPES:
            return False
        
        # 检查文件大小
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)  # 重置文件指针
        
        if file_size > MAX_FILE_SIZE:
            return False
        
        if file_size == 0:
            return False
        
        # 尝试打开图片验证格式
        try:
            with Image.open(file) as img:
                img.verify()
            file.seek(0)  # 重置文件指针
            return True
        except Exception:
            file.seek(0)  # 重置文件指针
            return False
            
    except Exception:
        return False

def create_thumbnail(image_path, output_dir, size=THUMBNAIL_SIZE):
    """创建缩略图"""
    try:
        # 打开原图
        with Image.open(image_path) as img:
            # 转换为RGB（处理RGBA等格式）
            if img.mode in ('RGBA', 'LA', 'P'):
                # 创建白色背景
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # 创建缩略图（保持宽高比）
            img.thumbnail(size, Image.Resampling.LANCZOS)
            
            # 生成缩略图文件名
            base_name = os.path.splitext(os.path.basename(image_path))[0]
            thumbnail_filename = f"{base_name}_thumb.jpg"
            thumbnail_path = os.path.join(output_dir, thumbnail_filename)
            
            # 保存缩略图
            img.save(thumbnail_path, 'JPEG', quality=85, optimize=True)
            
            return thumbnail_path
            
    except Exception as e:
        print(f"创建缩略图失败: {e}")
        return None

def get_image_info(image_path):
    """获取图片信息"""
    try:
        with Image.open(image_path) as img:
            info = {
                'width': img.width,
                'height': img.height,
                'format': img.format,
                'mode': img.mode,
                'size': os.path.getsize(image_path)
            }
            
            # 获取EXIF信息（如果有）
            if hasattr(img, '_getexif') and img._getexif():
                info['has_exif'] = True
            else:
                info['has_exif'] = False
            
            return info
            
    except Exception as e:
        print(f"获取图片信息失败: {e}")
        return None

def resize_image(image_path, output_path, max_width=None, max_height=None, quality=85):
    """调整图片尺寸"""
    try:
        with Image.open(image_path) as img:
            # 转换为RGB
            if img.mode in ('RGBA', 'LA', 'P'):
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # 计算新尺寸
            width, height = img.size
            
            if max_width and max_height:
                # 按比例缩放到指定尺寸内
                img.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)
            elif max_width:
                # 按宽度缩放
                ratio = max_width / width
                new_height = int(height * ratio)
                img = img.resize((max_width, new_height), Image.Resampling.LANCZOS)
            elif max_height:
                # 按高度缩放
                ratio = max_height / height
                new_width = int(width * ratio)
                img = img.resize((new_width, max_height), Image.Resampling.LANCZOS)
            
            # 保存图片
            img.save(output_path, 'JPEG', quality=quality, optimize=True)
            
            return True
            
    except Exception as e:
        print(f"调整图片尺寸失败: {e}")
        return False

def compress_image(image_path, output_path, quality=75, max_size=None):
    """压缩图片"""
    try:
        with Image.open(image_path) as img:
            # 转换为RGB
            if img.mode in ('RGBA', 'LA', 'P'):
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # 如果指定了最大尺寸，先调整尺寸
            if max_size:
                img.thumbnail(max_size, Image.Resampling.LANCZOS)
            
            # 保存压缩图片
            img.save(output_path, 'JPEG', quality=quality, optimize=True)
            
            return True
            
    except Exception as e:
        print(f"压缩图片失败: {e}")
        return False

def is_image_file(filename):
    """检查文件是否为图片"""
    if not filename:
        return False
    
    # 检查扩展名
    if '.' not in filename:
        return False
    
    extension = filename.rsplit('.', 1)[1].lower()
    return extension in ALLOWED_EXTENSIONS

def get_safe_filename(filename):
    """获取安全的文件名"""
    return secure_filename(filename)

def calculate_aspect_ratio(width, height):
    """计算宽高比"""
    if height == 0:
        return 0
    return width / height

def get_image_orientation(image_path):
    """获取图片方向"""
    try:
        with Image.open(image_path) as img:
            width, height = img.size
            
            if width > height:
                return 'landscape'  # 横向
            elif height > width:
                return 'portrait'   # 纵向
            else:
                return 'square'     # 正方形
                
    except Exception:
        return 'unknown'

def auto_orient_image(image_path, output_path=None):
    """自动调整图片方向（基于EXIF）"""
    try:
        if output_path is None:
            output_path = image_path
        
        with Image.open(image_path) as img:
            # 使用ImageOps.exif_transpose自动调整方向
            oriented_img = ImageOps.exif_transpose(img)
            
            # 如果方向有变化，保存图片
            if oriented_img != img:
                oriented_img.save(output_path, quality=95, optimize=True)
                return True
            
            return False
            
    except Exception as e:
        print(f"自动调整图片方向失败: {e}")
        return False