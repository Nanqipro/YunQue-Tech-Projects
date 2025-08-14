#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试后端API功能的脚本
"""

import requests
import json
import os
from PIL import Image as PILImage
import io

# API基础URL
API_BASE_URL = 'http://localhost:5002/api'

def test_image_upload():
    """测试图片上传功能"""
    print("\n=== 测试图片上传 ===")
    
    # 创建一个测试图片
    test_image = PILImage.new('RGB', (100, 100), color='red')
    img_buffer = io.BytesIO()
    test_image.save(img_buffer, format='JPEG')
    img_buffer.seek(0)
    
    files = {'file': ('test.jpg', img_buffer, 'image/jpeg')}
    
    try:
        response = requests.post(f'{API_BASE_URL}/images/upload', files=files)
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                return data['data']['id']
            else:
                print(f"上传失败: {data.get('message')}")
        return None
    except Exception as e:
        print(f"上传异常: {e}")
        return None

def test_beauty_suggestions(image_id):
    """测试美颜建议API"""
    print("\n=== 测试美颜建议API ===")
    
    data = {'image_id': image_id}
    
    try:
        response = requests.post(
            f'{API_BASE_URL}/ai/beauty-suggestions',
            json=data,
            headers={'Content-Type': 'application/json'}
        )
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return response.status_code == 200
    except Exception as e:
        print(f"请求异常: {e}")
        return False

def test_beauty_processing(image_id):
    """测试美颜处理API"""
    print("\n=== 测试美颜处理API ===")
    
    data = {
        'image_id': image_id,
        'smoothing': 0.6,
        'whitening': 0.5,
        'eye_enhancement': 0.4,
        'lip_enhancement': 0.3
    }
    
    try:
        response = requests.post(
            f'{API_BASE_URL}/processing/beauty',
            json=data,
            headers={'Content-Type': 'application/json'}
        )
        print(f"状态码: {response.status_code}")
        print(f"响应: {response.text}")
        return response.status_code == 200
    except Exception as e:
        print(f"请求异常: {e}")
        return False

def test_api_routes():
    """测试API路由是否存在"""
    print("\n=== 测试API路由 ===")
    
    routes = [
        '/api/ai/beauty-suggestions',
        '/api/processing/beauty',
        '/api/images/upload'
    ]
    
    for route in routes:
        try:
            # 使用OPTIONS请求检查路由是否存在
            response = requests.options(f'http://localhost:5002{route}')
            print(f"{route}: 状态码 {response.status_code}")
        except Exception as e:
            print(f"{route}: 连接失败 - {e}")

def main():
    print("开始测试后端API功能...")
    
    # 测试路由是否存在
    test_api_routes()
    
    # 测试图片上传
    image_id = test_image_upload()
    
    if image_id:
        print(f"\n上传成功，图片ID: {image_id}")
        
        # 测试美颜建议
        test_beauty_suggestions(image_id)
        
        # 测试美颜处理
        test_beauty_processing(image_id)
    else:
        print("\n图片上传失败，跳过后续测试")
        
        # 即使上传失败，也测试API路由
        print("\n尝试使用虚拟ID测试API...")
        test_beauty_suggestions(1)
        test_beauty_processing(1)

if __name__ == '__main__':
    main()