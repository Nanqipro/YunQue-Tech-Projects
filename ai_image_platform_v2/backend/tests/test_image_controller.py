import pytest
import io
import os
from PIL import Image as PILImage
from app.models.image import Image
from app.models import db


class TestImageUpload:
    """图片上传测试"""
    
    def test_upload_success(self, client, auth_headers, sample_image):
        """测试成功上传图片"""
        data = {
            'file': (sample_image, 'test.png', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        assert response.status_code == 201
        data = response.get_json()
        assert data['success'] is True
        assert 'image_id' in data['data']
        assert data['data']['original_filename'] == 'test.png'
        assert data['data']['format'] == 'PNG'
    
    def test_upload_no_file(self, client, auth_headers):
        """测试未选择文件"""
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data={},
                             content_type='multipart/form-data')
        
        assert response.status_code == 400
        data = response.get_json()
        assert '没有选择文件' in data['error']
    
    def test_upload_empty_filename(self, client, auth_headers):
        """测试空文件名"""
        data = {
            'file': (io.BytesIO(b'test'), '', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        assert response.status_code == 400
        data = response.get_json()
        assert '没有选择文件' in data['error']
    
    def test_upload_invalid_format(self, client, auth_headers):
        """测试不支持的文件格式"""
        # 创建一个文本文件
        text_file = io.BytesIO(b'This is not an image')
        data = {
            'file': (text_file, 'test.txt', 'text/plain')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        assert response.status_code == 400
        data = response.get_json()
        assert '不支持的文件格式' in data['error']
    
    def test_upload_unauthorized(self, client, sample_image):
        """测试未授权上传"""
        data = {
            'file': (sample_image, 'test.png', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             data=data,
                             content_type='multipart/form-data')
        
        assert response.status_code == 401
        data = response.get_json()
        assert '缺少认证token' in data['error']
    
    def test_upload_large_image(self, client, auth_headers):
        """测试上传大图片"""
        # 创建一个较大的图片
        large_img = PILImage.new('RGB', (3000, 3000), color='blue')
        img_bytes = io.BytesIO()
        large_img.save(img_bytes, format='PNG')
        img_bytes.seek(0)
        
        data = {
            'file': (img_bytes, 'large_test.png', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        # 应该成功上传，但可能会被调整大小
        assert response.status_code == 201
        data = response.get_json()
        assert data['success'] is True


class TestImageRetrieval:
    """图片获取测试"""
    
    @pytest.fixture
    def uploaded_image(self, client, auth_headers, sample_image):
        """上传一张测试图片"""
        data = {
            'file': (sample_image, 'test.png', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        assert response.status_code == 201
        return response.get_json()['data']
    
    def test_get_image_info_success(self, client, auth_headers, uploaded_image):
        """测试获取图片信息成功"""
        image_id = uploaded_image['image_id']
        
        response = client.get(f'/api/images/{image_id}', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert data['data']['image_id'] == image_id
        assert data['data']['original_filename'] == 'test.png'
    
    def test_get_image_info_not_found(self, client, auth_headers):
        """测试获取不存在的图片信息"""
        response = client.get('/api/images/999999', headers=auth_headers)
        
        assert response.status_code == 404
        data = response.get_json()
        assert '图片不存在' in data['error']
    
    def test_get_image_info_unauthorized(self, client, uploaded_image):
        """测试未授权获取图片信息"""
        image_id = uploaded_image['image_id']
        
        response = client.get(f'/api/images/{image_id}')
        
        assert response.status_code == 401
        data = response.get_json()
        assert '缺少认证token' in data['error']
    
    def test_get_user_images_success(self, client, auth_headers, uploaded_image):
        """测试获取用户图片列表成功"""
        response = client.get('/api/images', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert len(data['data']['images']) >= 1
        assert 'pagination' in data['data']
    
    def test_get_user_images_with_pagination(self, client, auth_headers):
        """测试分页获取用户图片"""
        response = client.get('/api/images?page=1&per_page=5', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert data['data']['pagination']['page'] == 1
        assert data['data']['pagination']['per_page'] == 5


class TestImageDeletion:
    """图片删除测试"""
    
    @pytest.fixture
    def uploaded_image(self, client, auth_headers, sample_image):
        """上传一张测试图片"""
        data = {
            'file': (sample_image, 'test.png', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        assert response.status_code == 201
        return response.get_json()['data']
    
    def test_delete_image_success(self, client, auth_headers, uploaded_image):
        """测试成功删除图片"""
        image_id = uploaded_image['image_id']
        
        response = client.delete(f'/api/images/{image_id}', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert '删除成功' in data['message']
        
        # 验证图片已被删除
        response = client.get(f'/api/images/{image_id}', headers=auth_headers)
        assert response.status_code == 404
    
    def test_delete_image_not_found(self, client, auth_headers):
        """测试删除不存在的图片"""
        response = client.delete('/api/images/999999', headers=auth_headers)
        
        assert response.status_code == 404
        data = response.get_json()
        assert '图片不存在' in data['error']
    
    def test_delete_image_unauthorized(self, client, uploaded_image):
        """测试未授权删除图片"""
        image_id = uploaded_image['image_id']
        
        response = client.delete(f'/api/images/{image_id}')
        
        assert response.status_code == 401
        data = response.get_json()
        assert '缺少认证token' in data['error']


class TestImageValidation:
    """图片验证测试"""
    
    def test_validate_supported_formats(self, client, auth_headers):
        """测试支持的图片格式"""
        formats = ['PNG', 'JPEG', 'GIF', 'BMP', 'WEBP']
        
        for fmt in formats:
            # 创建不同格式的测试图片
            img = PILImage.new('RGB', (100, 100), color='red')
            img_bytes = io.BytesIO()
            img.save(img_bytes, format=fmt)
            img_bytes.seek(0)
            
            data = {
                'file': (img_bytes, f'test.{fmt.lower()}', f'image/{fmt.lower()}')
            }
            
            response = client.post('/api/images/upload', 
                                 headers=auth_headers,
                                 data=data,
                                 content_type='multipart/form-data')
            
            assert response.status_code == 201, f"Failed to upload {fmt} format"
    
    def test_image_size_limits(self, client, auth_headers):
        """测试图片大小限制"""
        # 创建一个非常小的图片
        small_img = PILImage.new('RGB', (1, 1), color='red')
        img_bytes = io.BytesIO()
        small_img.save(img_bytes, format='PNG')
        img_bytes.seek(0)
        
        data = {
            'file': (img_bytes, 'small_test.png', 'image/png')
        }
        
        response = client.post('/api/images/upload', 
                             headers=auth_headers,
                             data=data,
                             content_type='multipart/form-data')
        
        # 小图片应该能正常上传
        assert response.status_code == 201