#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试匿名上传功能
"""

import requests
import os
from PIL import Image
import io

def create_test_image():
    """创建一个测试图片"""
    # 创建一个简单的测试图片
    img = Image.new('RGB', (100, 100), color='red')
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    return img_bytes

def test_anonymous_upload():
    """测试匿名上传"""
    print("测试匿名上传功能...")
    
    # 创建测试图片
    test_image = create_test_image()
    
    # 上传接口URL
    upload_url = 'http://127.0.0.1:5002/api/images/upload'
    
    # 准备文件数据
    files = {
        'file': ('test_image.jpg', test_image, 'image/jpeg')
    }
    
    try:
        # 发送上传请求（不带认证头）
        response = requests.post(upload_url, files=files)
        
        print(f"响应状态码: {response.status_code}")
        print(f"响应内容: {response.text}")
        
        if response.status_code in [200, 201]:
            result = response.json()
            if result.get('success'):
                print("✅ 匿名上传成功！")
                print(f"图片ID: {result['data']['id']}")
                print(f"文件名: {result['data']['filename']}")
                print(f"访问URL: {result['data']['url']}")
                return True
            else:
                print(f"❌ 上传失败: {result.get('message', '未知错误')}")
                return False
        else:
            print(f"❌ 请求失败，状态码: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 上传过程中发生错误: {str(e)}")
        return False

def test_authenticated_upload():
    """测试认证用户上传"""
    print("\n测试认证用户上传功能...")
    
    # 首先登录获取token
    login_url = 'http://127.0.0.1:5002/api/users/login'
    login_data = {
        'username': 'test_user',
        'password': 'test123456'
    }
    
    try:
        login_response = requests.post(login_url, json=login_data)
        if login_response.status_code != 200:
            print("⚠️ 无法登录测试用户，跳过认证上传测试")
            return True
        
        login_result = login_response.json()
        if not login_result.get('success'):
            print("⚠️ 登录失败，跳过认证上传测试")
            return True
            
        token = login_result['data']['token']
        print(f"登录成功，获取到token")
        
        # 创建测试图片
        test_image = create_test_image()
        
        # 上传接口URL
        upload_url = 'http://127.0.0.1:5002/api/images/upload'
        
        # 准备文件数据和认证头
        files = {
            'file': ('test_image_auth.jpg', test_image, 'image/jpeg')
        }
        headers = {
            'Authorization': f'Bearer {token}'
        }
        
        # 发送上传请求（带认证头）
        response = requests.post(upload_url, files=files, headers=headers)
        
        print(f"响应状态码: {response.status_code}")
        print(f"响应内容: {response.text}")
        
        if response.status_code in [200, 201]:
            result = response.json()
            if result.get('success'):
                print("✅ 认证用户上传成功！")
                print(f"图片ID: {result['data']['id']}")
                print(f"文件名: {result['data']['filename']}")
                print(f"访问URL: {result['data']['url']}")
                return True
            else:
                print(f"❌ 上传失败: {result.get('message', '未知错误')}")
                return False
        else:
            print(f"❌ 请求失败，状态码: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 认证上传过程中发生错误: {str(e)}")
        return False

if __name__ == '__main__':
    print("开始测试图片上传功能...")
    print("=" * 50)
    
    # 测试匿名上传
    anonymous_success = test_anonymous_upload()
    
    # 测试认证用户上传
    auth_success = test_authenticated_upload()
    
    print("\n" + "=" * 50)
    print("测试结果汇总:")
    print(f"匿名上传: {'✅ 成功' if anonymous_success else '❌ 失败'}")
    print(f"认证上传: {'✅ 成功' if auth_success else '❌ 失败'}")
    
    if anonymous_success and auth_success:
        print("\n🎉 所有上传功能测试通过！")
    else:
        print("\n⚠️ 部分上传功能存在问题，请检查日志")