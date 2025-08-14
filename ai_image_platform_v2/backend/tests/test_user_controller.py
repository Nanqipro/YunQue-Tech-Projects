import pytest
import json
from app.models.user import User
from app.models import db


class TestUserRegistration:
    """用户注册测试"""
    
    def test_register_success(self, client):
        """测试成功注册"""
        response = client.post('/api/users/register', json={
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'password123',
            'nickname': '新用户'
        })
        
        assert response.status_code == 201
        data = response.get_json()
        assert data['user']['username'] == 'newuser'
        assert data['user']['email'] == 'newuser@example.com'
    
    def test_register_missing_fields(self, client):
        """测试缺少必填字段"""
        response = client.post('/api/users/register', json={
            'username': 'newuser'
            # 缺少email和password
        })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '用户名、邮箱和密码不能为空' in data['error']
    
    def test_register_invalid_username(self, client):
        """测试无效用户名"""
        # 用户名太短
        response = client.post('/api/users/register', json={
            'username': 'ab',
            'email': 'test@example.com',
            'password': 'password123'
        })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '用户名长度必须在3-50个字符之间' in data['error']
    
    def test_register_invalid_email(self, client):
        """测试无效邮箱"""
        response = client.post('/api/users/register', json={
            'username': 'testuser',
            'email': 'invalid-email',
            'password': 'password123'
        })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '邮箱格式不正确' in data['error']
    
    def test_register_weak_password(self, client):
        """测试弱密码"""
        response = client.post('/api/users/register', json={
            'username': 'testuser',
            'email': 'test@example.com',
            'password': '123'  # 密码太短
        })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '密码长度至少6个字符' in data['error']
    
    def test_register_duplicate_username(self, client, test_user):
        """测试重复用户名"""
        response = client.post('/api/users/register', json={
            'username': 'testuser',  # 已存在的用户名
            'email': 'another@example.com',
            'password': 'password123'
        })
        
        assert response.status_code == 409
        data = response.get_json()
        assert '用户名已存在' in data['error']
    
    def test_register_duplicate_email(self, client, test_user):
        """测试重复邮箱"""
        response = client.post('/api/users/register', json={
            'username': 'anotheruser',
            'email': 'test@example.com',  # 已存在的邮箱
            'password': 'password123'
        })
        
        assert response.status_code == 409
        data = response.get_json()
        assert '邮箱已被注册' in data['error']


class TestUserLogin:
    """用户登录测试"""
    
    def test_login_success_with_username(self, client, test_user):
        """测试用户名登录成功"""
        response = client.post('/api/users/login', json={
            'username': 'testuser',
            'password': 'testpassword123'
        })
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'token' in data
        assert data['user']['username'] == 'testuser'
    
    def test_login_success_with_email(self, client, test_user):
        """测试邮箱登录成功"""
        response = client.post('/api/users/login', json={
            'username': 'test@example.com',  # 使用邮箱登录
            'password': 'testpassword123'
        })
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'token' in data
    
    def test_login_missing_fields(self, client):
        """测试缺少登录字段"""
        response = client.post('/api/users/login', json={
            'username': 'testuser'
            # 缺少password
        })
        
        assert response.status_code == 400
        data = response.get_json()
        assert '用户名和密码不能为空' in data['error']
    
    def test_login_user_not_found(self, client):
        """测试用户不存在"""
        response = client.post('/api/users/login', json={
            'username': 'nonexistentuser',
            'password': 'password123'
        })
        
        assert response.status_code == 404
        data = response.get_json()
        assert '用户不存在' in data['error']
    
    def test_login_wrong_password(self, client, test_user):
        """测试密码错误"""
        response = client.post('/api/users/login', json={
            'username': 'testuser',
            'password': 'wrongpassword'
        })
        
        assert response.status_code == 401
        data = response.get_json()
        assert '密码错误' in data['error']


class TestUserProfile:
    """用户资料测试"""
    
    def test_get_profile_success(self, client, auth_headers):
        """测试获取用户资料成功"""
        response = client.get('/api/users/profile', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['user']['username'] == 'testuser'
        assert data['user']['email'] == 'test@example.com'
    
    def test_get_profile_unauthorized(self, client):
        """测试未授权访问用户资料"""
        response = client.get('/api/users/profile')
        
        assert response.status_code == 401
        data = response.get_json()
        assert '缺少访问令牌' in data['error']
    
    def test_update_profile_success(self, client, auth_headers):
        """测试更新用户资料成功"""
        response = client.put('/api/users/profile', 
                            headers=auth_headers,
                            json={
                                'nickname': '更新的昵称',
                                'avatar_url': 'https://example.com/avatar.jpg'
                            })
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['user']['nickname'] == '更新的昵称'
    
    def test_verify_token_success(self, client, auth_headers):
        """测试验证token成功"""
        response = client.post('/api/users/verify-token', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['valid'] is True
        assert data['user']['username'] == 'testuser'
    
    def test_logout_success(self, client, auth_headers):
        """测试登出成功"""
        response = client.post('/api/users/logout', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert '登出成功' in data['message']


class TestUserStats:
    """用户统计测试"""
    
    def test_get_stats_success(self, client, auth_headers):
        """测试获取用户统计成功"""
        response = client.get('/api/users/stats', headers=auth_headers)
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'stats' in data
        assert 'images' in data['stats']
        assert 'processing' in data['stats']
        assert 'storage' in data['stats']