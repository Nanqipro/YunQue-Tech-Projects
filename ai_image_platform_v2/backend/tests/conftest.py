import pytest
import tempfile
import os
from app import create_app
from app.models import db
from app.models.user import User
from app.models.image import Image
from config.config import TestingConfig


@pytest.fixture
def app():
    """创建测试应用实例"""
    # 创建临时目录用于文件上传
    temp_dir = tempfile.mkdtemp()
    
    # 测试配置
    test_config = {
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:',
        'UPLOAD_FOLDER': temp_dir,
        'SECRET_KEY': 'test-secret-key',
        'JWT_SECRET_KEY': 'test-jwt-secret',
        'WTF_CSRF_ENABLED': False
    }
    
    app = create_app('testing')
    app.config.update(test_config)
    
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()
    
    # 清理临时目录
    import shutil
    shutil.rmtree(temp_dir, ignore_errors=True)


@pytest.fixture
def client(app):
    """创建测试客户端"""
    return app.test_client()


@pytest.fixture
def runner(app):
    """创建CLI测试运行器"""
    return app.test_cli_runner()


@pytest.fixture
def test_user(app):
    """创建测试用户"""
    with app.app_context():
        user = User()
        user.username = 'testuser'
        user.email = 'test@example.com'
        user.set_password('testpassword123')
        db.session.add(user)
        db.session.commit()
        return user


@pytest.fixture
def auth_headers(client, test_user):
    """获取认证头"""
    response = client.post('/api/users/login', json={
        'username': 'testuser',
        'password': 'testpassword123'
    })
    
    assert response.status_code == 200
    data = response.get_json()
    token = data['token']
    
    return {'Authorization': f'Bearer {token}'}


@pytest.fixture
def sample_image():
    """创建测试图片"""
    from PIL import Image as PILImage
    import io
    
    # 创建一个简单的测试图片
    img = PILImage.new('RGB', (100, 100), color='red')
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='PNG')
    img_bytes.seek(0)
    
    return img_bytes