#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
认证头修复验证测试脚本
测试证件照生成API的认证头设置
"""

import requests
import json
import time

# 配置
BASE_URL = "http://127.0.0.1:5002"
API_URL = f"{BASE_URL}/api"

def test_health_check():
    """测试健康检查"""
    print("🔍 测试健康检查...")
    try:
        response = requests.get(f"{API_URL}/health")
        print(f"✅ 健康检查成功: {response.status_code}")
        return True
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")
        return False

def test_user_registration():
    """测试用户注册"""
    print("\n🔍 测试用户注册...")
    
    # 生成唯一用户名
    timestamp = int(time.time())
    username = f"testuser_{timestamp}"
    email = f"test{timestamp}@example.com"
    
    data = {
        "username": username,
        "email": email,
        "password": "testpass123"
    }
    
    try:
        response = requests.post(
            f"{API_URL}/users/register",
            json=data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code in [200, 201]:  # 200 OK 或 201 Created 都是成功
            result = response.json()
            if result.get("success"):
                print(f"✅ 用户注册成功: {username}")
                return username, email
            else:
                print(f"❌ 用户注册失败: {result.get('message')}")
                return None, None
        else:
            print(f"❌ 用户注册HTTP错误: {response.status_code}")
            return None, None
            
    except Exception as e:
        print(f"❌ 用户注册异常: {e}")
        return None, None

def test_user_login(username, password):
    """测试用户登录"""
    print(f"\n🔍 测试用户登录: {username}...")
    
    data = {
        "username": username,
        "password": password
    }
    
    try:
        response = requests.post(
            f"{API_URL}/users/login",
            json=data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get("success") and result.get("data", {}).get("token"):
                token = result["data"]["token"]
                print(f"✅ 用户登录成功，获取到token")
                return token
            else:
                print(f"❌ 用户登录失败: {result.get('message')}")
                return None
        else:
            print(f"❌ 用户登录HTTP错误: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"❌ 用户登录异常: {e}")
        return None

def test_id_photo_with_auth(token):
    """测试带认证的证件照生成请求"""
    print(f"\n🔍 测试带认证的证件照生成...")
    
    # 模拟证件照参数
    data = {
        "image_id": 1,  # 假设的图片ID
        "photo_type": "1_inch",
        "background_color": "red",
        "beauty_strength": 30,
        "auto_crop": True
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }
    
    try:
        response = requests.post(
            f"{API_URL}/processing/id-photo",
            json=data,
            headers=headers
        )
        
        print(f"📊 请求头信息:")
        print(f"   Authorization: {headers.get('Authorization', 'None')}")
        print(f"   Content-Type: {headers.get('Content-Type', 'None')}")
        
        print(f"📊 响应信息:")
        print(f"   状态码: {response.status_code}")
        print(f"   响应头: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ 证件照生成请求成功")
            print(f"   响应内容: {json.dumps(result, indent=2, ensure_ascii=False)}")
        elif response.status_code == 401:
            print(f"❌ 认证失败 - 可能是token无效或认证头未正确设置")
        elif response.status_code == 404:
            print(f"⚠️  图片不存在 - 这是正常的，因为我们使用了假设的图片ID")
        else:
            print(f"⚠️  其他错误: {response.status_code}")
            
        return response.status_code
        
    except Exception as e:
        print(f"❌ 证件照生成请求异常: {e}")
        return None

def test_id_photo_without_auth():
    """测试不带认证的证件照生成请求"""
    print(f"\n🔍 测试不带认证的证件照生成...")
    
    data = {
        "image_id": 1,
        "photo_type": "1_inch",
        "background_color": "red",
        "beauty_strength": 30,
        "auto_crop": True
    }
    
    headers = {
        "Content-Type": "application/json"
        # 故意不设置Authorization头
    }
    
    try:
        response = requests.post(
            f"{API_URL}/processing/id-photo",
            json=data,
            headers=headers
        )
        
        print(f"📊 请求头信息:")
        print(f"   Authorization: {headers.get('Authorization', 'None')}")
        print(f"   Content-Type: {headers.get('Content-Type', 'None')}")
        
        print(f"📊 响应信息:")
        print(f"   状态码: {response.status_code}")
        
        if response.status_code == 401:
            print(f"✅ 正确拒绝未认证请求")
        else:
            print(f"⚠️  意外响应: {response.status_code}")
            
        return response.status_code
        
    except Exception as e:
        print(f"❌ 无认证请求异常: {e}")
        return None

def main():
    """主测试函数"""
    print("🚀 开始认证头修复验证测试")
    print("=" * 50)
    
    # 1. 健康检查
    if not test_health_check():
        print("❌ 服务不可用，停止测试")
        return
    
    # 2. 用户注册
    username, email = test_user_registration()
    if not username:
        print("❌ 无法创建测试用户，停止测试")
        return
    
    # 3. 用户登录
    token = test_user_login(username, "testpass123")
    if not token:
        print("❌ 无法获取认证token，停止测试")
        return
    
    # 4. 测试带认证的请求
    auth_status = test_id_photo_with_auth(token)
    
    # 5. 测试不带认证的请求
    no_auth_status = test_id_photo_without_auth()
    
    # 6. 结果总结
    print("\n" + "=" * 50)
    print("📋 测试结果总结:")
    
    if auth_status == 200 or auth_status == 404:  # 404是正常的，因为图片不存在
        print("✅ 带认证请求: 认证头设置正确")
    else:
        print("❌ 带认证请求: 认证头设置可能有问题")
    
    if no_auth_status == 401:
        print("✅ 无认证请求: 正确拒绝未认证访问")
    else:
        print("⚠️  无认证请求: 响应不符合预期")
    
    print("\n🎯 认证头修复验证完成！")

if __name__ == "__main__":
    main()
