#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试图片上传功能
"""

import requests
import json
from PIL import Image
import io
import os

# 配置
BASE_URL = 'http://localhost:5002'
USERNAME = 'admin'
PASSWORD = 'admin123'

def create_test_image():
    """创建测试图片"""
    # 创建一个简单的测试图片
    img = Image.new('RGB', (100, 100), color='red')
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    return img_bytes

def login():
    """用户登录"""
    print("\n=== 测试用户登录 ===")
    url = f'{BASE_URL}/api/users/login'
    data = {
        'username': USERNAME,
        'password': PASSWORD
    }
    
    try:
        response = requests.post(url, json=data)
        print(f"登录请求状态码: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"登录成功: {result.get('message')}")
            token = result.get('data', {}).get('token')
            print(f"获取到Token: {token[:20]}..." if token else "未获取到Token")
            return token
        else:
            print(f"登录失败: {response.text}")
            return None
    except Exception as e:
        print(f"登录请求异常: {e}")
        return None

def test_upload(token):
    """测试图片上传"""
    print("\n=== 测试图片上传 ===")
    url = f'{BASE_URL}/api/images/upload'
    
    headers = {
        'Authorization': f'Bearer {token}'
    }
    
    # 创建测试图片
    img_bytes = create_test_image()
    
    files = {
        'file': ('test_image.jpg', img_bytes, 'image/jpeg')
    }
    
    data = {
        'title': '测试图片',
        'description': '这是一个测试上传的图片',
        'tags': json.dumps(['测试', '红色'])
    }
    
    try:
        response = requests.post(url, headers=headers, files=files, data=data)
        print(f"上传请求状态码: {response.status_code}")
        print(f"响应内容: {response.text}")
        
        if response.status_code in [200, 201]:
            result = response.json()
            print(f"上传成功: {result.get('message')}")
            image_data = result.get('data')
            if image_data:
                print(f"图片ID: {image_data.get('id')}")
                print(f"文件名: {image_data.get('filename')}")
                print(f"访问URL: {image_data.get('url')}")
            return True
        else:
            print(f"上传失败: {response.text}")
            return False
    except Exception as e:
        print(f"上传请求异常: {e}")
        return False

def test_get_images(token):
    """测试获取图片列表"""
    print("\n=== 测试获取图片列表 ===")
    url = f'{BASE_URL}/api/images'
    
    headers = {
        'Authorization': f'Bearer {token}'
    }
    
    try:
        response = requests.get(url, headers=headers)
        print(f"获取图片列表状态码: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"获取成功: {result.get('message')}")
            images = result.get('data', {}).get('images', [])
            print(f"图片数量: {len(images)}")
            for img in images:
                print(f"  - ID: {img.get('id')}, 文件名: {img.get('filename')}, 标题: {img.get('title')}")
            return True
        else:
            print(f"获取失败: {response.text}")
            return False
    except Exception as e:
        print(f"获取请求异常: {e}")
        return False

def test_health_check():
    """测试健康检查"""
    print("\n=== 测试健康检查 ===")
    url = f'{BASE_URL}/api/health'
    
    try:
        response = requests.get(url)
        print(f"健康检查状态码: {response.status_code}")
        print(f"响应内容: {response.text}")
        return response.status_code == 200
    except Exception as e:
        print(f"健康检查异常: {e}")
        return False

def main():
    """主函数"""
    print("开始测试图片上传功能...")
    
    # 测试健康检查
    if not test_health_check():
        print("健康检查失败，但继续测试其他功能")
    
    # 登录获取token
    token = login()
    if not token:
        print("登录失败，无法继续测试")
        return
    
    # 测试图片上传
    if test_upload(token):
        print("\n图片上传测试成功！")
    else:
        print("\n图片上传测试失败！")
    
    # 测试获取图片列表
    if test_get_images(token):
        print("\n获取图片列表测试成功！")
    else:
        print("\n获取图片列表测试失败！")
    
    print("\n测试完成！")

if __name__ == '__main__':
    main()