import pytest
import io
from PIL import Image as PILImage
from app.models.image import Image
from app.models.processing_record import ProcessingRecord
from app.models import db


class TestBeautyProcessing:
    """美颜处理测试"""
    
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
    
    def test_beauty_processing_success(self, client, auth_headers, uploaded_image):
        """测试美颜处理成功"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/beauty', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'smoothing': 0.5,
                                 'whitening': 0.3,
                                 'eye_enhancement': 0.2,
                                 'lip_enhancement': 0.1
                             })
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'record_id' in data['data']
        assert data['data']['status'] == 'completed'
    
    def test_beauty_processing_missing_image_id(self, client, auth_headers):
        """测试缺少图片ID"""
        response = client.post('/api/processing/beauty', 
                             headers=auth_headers,
                             json={
                                 'smoothing': 0.5,
                                 'whitening': 0.3
                             })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '图片ID不能为空' in data['error']
    
    def test_beauty_processing_invalid_image_id(self, client, auth_headers):
        """测试无效图片ID"""
        response = client.post('/api/processing/beauty', 
                             headers=auth_headers,
                             json={
                                 'image_id': 999999,
                                 'smoothing': 0.5
                             })
        
        assert response.status_code == 404
        data = response.get_json()
        assert '图片不存在' in data['error']
    
    def test_beauty_processing_invalid_parameters(self, client, auth_headers, uploaded_image):
        """测试无效的美颜参数"""
        image_id = uploaded_image['image_id']
        
        # 测试超出范围的参数
        response = client.post('/api/processing/beauty', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'smoothing': 1.5,  # 超出0-1范围
                                 'whitening': -0.1   # 负值
                             })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '参数值必须在0-1之间' in data['error']
    
    def test_beauty_processing_unauthorized(self, client, uploaded_image):
        """测试未授权的美颜处理"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/beauty', 
                             json={
                                 'image_id': image_id,
                                 'smoothing': 0.5
                             })
        
        assert response.status_code == 401
        data = response.get_json()
        assert '缺少认证token' in data['error']


class TestIDPhotoGeneration:
    """证件照生成测试"""
    
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
    
    def test_id_photo_generation_success(self, client, auth_headers, uploaded_image):
        """测试证件照生成成功"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/id-photo', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'photo_type': '1寸',
                                 'background_color': 'white',
                                 'auto_crop': True
                             })
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'record_id' in data['data']
        assert data['data']['status'] == 'completed'
    
    def test_id_photo_different_sizes(self, client, auth_headers, uploaded_image):
        """测试不同尺寸的证件照"""
        image_id = uploaded_image['image_id']
        photo_types = ['1寸', '2寸', '小2寸', '护照']
        
        for photo_type in photo_types:
            response = client.post('/api/processing/id-photo', 
                                 headers=auth_headers,
                                 json={
                                     'image_id': image_id,
                                     'photo_type': photo_type,
                                     'background_color': 'white'
                                 })
            
            assert response.status_code == 200, f"Failed for photo type: {photo_type}"
            data = response.get_json()
            assert data['success'] is True
    
    def test_id_photo_different_backgrounds(self, client, auth_headers, uploaded_image):
        """测试不同背景色的证件照"""
        image_id = uploaded_image['image_id']
        background_colors = ['white', 'blue', 'red']
        
        for bg_color in background_colors:
            response = client.post('/api/processing/id-photo', 
                                 headers=auth_headers,
                                 json={
                                     'image_id': image_id,
                                     'photo_type': '1寸',
                                     'background_color': bg_color
                                 })
            
            assert response.status_code == 200, f"Failed for background: {bg_color}"
            data = response.get_json()
            assert data['success'] is True
    
    def test_id_photo_invalid_photo_type(self, client, auth_headers, uploaded_image):
        """测试无效的证件照类型"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/id-photo', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'photo_type': '无效尺寸',
                                 'background_color': 'white'
                             })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '不支持的证件照类型' in data['error']
    
    def test_id_photo_missing_parameters(self, client, auth_headers, uploaded_image):
        """测试缺少必要参数"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/id-photo', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id
                                 # 缺少photo_type和background_color
                             })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '证件照类型和背景色不能为空' in data['error']


class TestProcessingRecords:
    """处理记录测试"""
    
    @pytest.fixture
    def processing_record(self, client, auth_headers, uploaded_image):
        """创建一个处理记录"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/beauty', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'smoothing': 0.5
                             })
        
        assert response.status_code == 200
        return response.get_json()['data']
    
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
    
    def test_get_processing_result_success(self, client, auth_headers, processing_record):
        """测试获取处理结果成功"""
        record_id = processing_record['record_id']
        
        response = client.get(f'/api/processing/{record_id}/result', headers=auth_headers)
        
        assert response.status_code == 200
        # 检查返回的是图片数据
        assert response.content_type.startswith('image/')
    
    def test_get_processing_result_not_found(self, client, auth_headers):
        """测试获取不存在的处理结果"""
        response = client.get('/api/processing/999999/result', headers=auth_headers)
        
        assert response.status_code == 404
        data = response.get_json()
        assert '处理记录不存在' in data['error']
    
    def test_get_processing_status_success(self, client, auth_headers, processing_record):
        """测试获取处理状态成功"""
        record_id = processing_record['record_id']
        
        response = client.get(f'/api/processing/{record_id}/status', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'status' in data['data']
        assert data['data']['status'] in ['pending', 'processing', 'completed', 'failed']
    
    def test_get_user_processing_history(self, client, auth_headers, processing_record):
        """测试获取用户处理历史"""
        response = client.get('/api/processing/history', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'records' in data['data']
        assert len(data['data']['records']) >= 1
        assert 'pagination' in data['data']


class TestFilterProcessing:
    """滤镜处理测试"""
    
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
    
    def test_apply_filter_success(self, client, auth_headers, uploaded_image):
        """测试应用滤镜成功"""
        image_id = uploaded_image['image_id']
        filters = ['vintage', 'black_white', 'sepia', 'cool', 'warm']
        
        for filter_type in filters:
            response = client.post('/api/processing/filter', 
                                 headers=auth_headers,
                                 json={
                                     'image_id': image_id,
                                     'filter_type': filter_type,
                                     'intensity': 0.5
                                 })
            
            assert response.status_code == 200, f"Failed for filter: {filter_type}"
            data = response.get_json()
            assert data['success'] is True
    
    def test_apply_invalid_filter(self, client, auth_headers, uploaded_image):
        """测试应用无效滤镜"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/filter', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'filter_type': 'invalid_filter'
                             })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '不支持的滤镜类型' in data['error']


class TestColorAdjustment:
    """颜色调整测试"""
    
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
    
    def test_adjust_color_success(self, client, auth_headers, uploaded_image):
        """测试颜色调整成功"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/color', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'brightness': 0.1,
                                 'contrast': 0.2,
                                 'saturation': 0.1,
                                 'hue': 0.05
                             })
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['success'] is True
        assert 'record_id' in data['data']
    
    def test_adjust_color_invalid_range(self, client, auth_headers, uploaded_image):
        """测试颜色调整参数超出范围"""
        image_id = uploaded_image['image_id']
        
        response = client.post('/api/processing/color', 
                             headers=auth_headers,
                             json={
                                 'image_id': image_id,
                                 'brightness': 2.0,  # 超出范围
                                 'contrast': -2.0    # 超出范围
                             })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '参数值超出有效范围' in data['error']