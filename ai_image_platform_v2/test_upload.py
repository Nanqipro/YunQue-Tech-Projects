#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试图片上传API
"""

import requests
import json
import os
from PIL import Image
import io

def create_test_image():
    """创建一个测试图片"""
    # 创建一个简单的测试图片
    img = Image.new('RGB', (300, 200), color='red')
    
    # 保存为字节流
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    
    return img_bytes

def login_and_get_token():
    """登录并获取token"""
    login_url = "http://localhost:5002/api/users/login"
    
    login_data = {
        "username": "admin",
        "password": "admin123"
    }
    
    try:
        response = requests.post(login_url, json=login_data)
        
        if response.status_code == 200:
            data = response.json()
            return data['data']['token']
        else:
            print(f"登录失败: {response.json()}")
            return None
            
    except Exception as e:
        print(f"登录异常: {e}")
        return None

def test_image_upload():
    """测试图片上传功能"""
    
    print("=== 测试图片上传API ===")
    
    # 先登录获取token
    token = login_and_get_token()
    if not token:
        print("❌ 无法获取登录token，测试终止")
        return
    
    print(f"✅ 登录成功，获取到token: {token[:50]}...")
    
    # 创建测试图片
    test_image = create_test_image()
    
    # 上传API端点
    upload_url = "http://localhost:5002/api/images/upload"
    
    # 准备文件和数据
    files = {
        'file': ('test_image.jpg', test_image, 'image/jpeg')
    }
    
    data = {
        'title': '测试图片',
        'description': '这是一个Python测试上传的图片',
        'tags': 'test,python,upload'
    }
    
    headers = {
        'Authorization': f'Bearer {token}'
    }
    
    print(f"请求URL: {upload_url}")
    print(f"上传数据: {data}")
    print()
    
    try:
        response = requests.post(
            upload_url,
            files=files,
            data=data,
            headers=headers,
            timeout=30
        )
        
        print(f"响应状态码: {response.status_code}")
        
        if response.headers.get('content-type', '').startswith('application/json'):
            response_data = response.json()
            print(f"响应数据: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
            
            if response.status_code == 201:
                print("\n✅ 图片上传成功！")
                
                # 获取上传的图片信息
                image_info = response_data.get('data', {})
                image_id = image_info.get('id')
                
                if image_id:
                    print(f"图片ID: {image_id}")
                    print(f"图片URL: {image_info.get('url', 'N/A')}")
                    
                    # 测试获取图片列表
                    test_get_images(token)
                    
            else:
                print(f"\n❌ 图片上传失败: {response_data.get('message', '未知错误')}")
        else:
            print(f"响应内容: {response.text}")
            print("\n❌ 响应不是JSON格式")
            
    except requests.exceptions.ConnectionError:
        print("❌ 连接失败: 无法连接到后端服务")
    except requests.exceptions.Timeout:
        print("❌ 请求超时")
    except Exception as e:
        print(f"❌ 上传异常: {e}")

def test_get_images(token):
    """测试获取图片列表"""
    
    print("\n=== 测试获取图片列表 ===")
    
    list_url = "http://localhost:5002/api/images"
    
    headers = {
        'Authorization': f'Bearer {token}'
    }
    
    try:
        response = requests.get(list_url, headers=headers, timeout=10)
        
        print(f"响应状态码: {response.status_code}")
        
        if response.headers.get('content-type', '').startswith('application/json'):
            response_data = response.json()
            print(f"响应数据: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
            
            if response.status_code == 200:
                print("\n✅ 获取图片列表成功！")
                
                images = response_data.get('data', {}).get('images', [])
                print(f"图片总数: {len(images)}")
                
                for img in images:
                    print(f"- 图片ID: {img.get('id')}, 标题: {img.get('title')}, 创建时间: {img.get('created_at')}")
                    
            else:
                print(f"\n❌ 获取图片列表失败: {response_data.get('message', '未知错误')}")
        else:
            print(f"响应内容: {response.text}")
            
    except Exception as e:
        print(f"❌ 获取图片列表异常: {e}")

def test_health_check():
    """测试健康检查"""
    
    print("\n=== 测试健康检查 ===")
    
    health_url = "http://localhost:5002/api/health"
    
    try:
        response = requests.get(health_url, timeout=5)
        
        print(f"响应状态码: {response.status_code}")
        
        if response.headers.get('content-type', '').startswith('application/json'):
            response_data = response.json()
            print(f"响应数据: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
            
            if response.status_code == 200:
                print("\n✅ 健康检查通过！")
            else:
                print(f"\n❌ 健康检查失败")
        else:
            print(f"响应内容: {response.text}")
            
    except Exception as e:
        print(f"❌ 健康检查异常: {e}")

if __name__ == "__main__":
    print("开始测试AI图片处理平台完整功能...\n")
    
    # 测试健康检查
    test_health_check()
    
    # 测试图片上传
    test_image_upload()
    
    print("\n测试完成！")