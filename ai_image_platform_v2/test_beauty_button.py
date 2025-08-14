#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试美颜按钮功能的脚本
"""

import requests
import time
import base64
import os

def test_beauty_button():
    """测试美颜按钮功能"""
    print("🎨 测试美颜按钮功能")
    print("=" * 50)
    
    base_url = "http://127.0.0.1:5002"
    api_url = f"{base_url}/api"
    session = requests.Session()
    
    # 检查服务状态
    try:
        response = session.get(f"{api_url}/health", timeout=5)
        print("✅ 后端服务正常")
    except:
        print("❌ 后端服务不可访问")
        return
    
    # 创建测试用户
    timestamp = int(time.time())
    user_data = {
        "username": f"beautytest_{timestamp}",
        "email": f"beautytest{timestamp}@example.com",
        "password": "testpass123"
    }
    
    # 注册和登录
    register_response = session.post(
        f"{api_url}/users/register",
        json=user_data,
        headers={'Content-Type': 'application/json'}
    )
    
    if register_response.status_code not in [200, 201]:
        print(f"❌ 用户注册失败: {register_response.status_code}")
        return
    
    login_response = session.post(
        f"{api_url}/users/login",
        json={"username": user_data["username"], "password": user_data["password"]},
        headers={'Content-Type': 'application/json'}
    )
    
    if login_response.status_code != 200:
        print(f"❌ 用户登录失败: {login_response.status_code}")
        return
    
    data = login_response.json()
    if not data.get('success'):
        print(f"❌ 登录响应失败: {data.get('message')}")
        return
    
    auth_token = data['data']['token']
    session.headers.update({'Authorization': f'Bearer {auth_token}'})
    print("✅ 用户登录成功")
    
    # 上传图片
    print("📷 上传测试图片")
    
    image_data = base64.b64decode(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    )
    
    filename = "beauty_test.png"
    with open(filename, "wb") as f:
        f.write(image_data)
    
    try:
        with open(filename, "rb") as f:
            files = {'file': (filename, f, 'image/png')}
            upload_response = session.post(f"{api_url}/images/upload", files=files)
        
        os.remove(filename)
        
        if upload_response.status_code not in [200, 201]:
            print(f"❌ 图片上传失败: {upload_response.status_code}")
            return
        
        upload_data = upload_response.json()
        if not upload_data.get('success'):
            print(f"❌ 图片上传响应失败: {upload_data.get('message')}")
            return
        
        image_id = upload_data['data']['id']
        print(f"✅ 图片上传成功，ID: {image_id}")
        
    except Exception as e:
        print(f"❌ 图片上传异常: {str(e)}")
        return
    
    # 测试美颜处理
    print("\n🎨 测试美颜处理")
    
    beauty_params = {
        "image_id": image_id,
        "smoothing": 0.3,      # 磨皮强度 30%
        "whitening": 0.4,      # 美白程度 40%
        "eye_enhancement": 0.6, # 眼部增强 60%
        "lip_enhancement": 0.25, # 唇部调整 25%
        "ai_mode": True
    }
    
    print(f"美颜参数: {beauty_params}")
    
    beauty_response = session.post(f"{api_url}/processing/beauty", json=beauty_params)
    
    print(f"响应状态码: {beauty_response.status_code}")
    
    if beauty_response.status_code == 200:
        beauty_data = beauty_response.json()
        print(f"响应数据: {beauty_data}")
        
        if beauty_data.get('success'):
            print("✅ 美颜处理成功")
            result_url = beauty_data.get('data', {}).get('result_url')
            if result_url:
                print(f"结果URL: {result_url}")
                
                # 测试结果获取
                result_response = session.get(f"{base_url}{result_url}")
                if result_response.status_code == 200:
                    print("✅ 美颜结果获取成功")
                    print(f"结果文件大小: {len(result_response.content)} bytes")
                else:
                    print(f"❌ 美颜结果获取失败: {result_response.status_code}")
            else:
                print("⚠️ 缺少结果URL")
        else:
            print(f"❌ 美颜处理失败: {beauty_data.get('message')}")
    else:
        print(f"❌ 美颜处理请求失败")
        print(f"错误详情: {beauty_response.text}")
    
    print(f"\n💡 前端美颜按钮调试要点:")
    print(f"1. 检查浏览器Console是否有JavaScript错误")
    print(f"2. 确认点击按钮时是否输出'美颜按钮被点击'日志")
    print(f"3. 确认'processBeautyImage 函数被调用'日志")
    print(f"4. 检查currentImage和authToken是否正确设置")
    print(f"5. 检查按钮是否被正确启用（不是disabled状态）")
    
    print(f"\n🔧 如果按钮点击无效果:")
    print(f"- 打开开发者工具Console查看错误信息")
    print(f"- 检查按钮事件绑定是否成功")
    print(f"- 确认简化版图片管理器正确加载")
    print(f"- 尝试刷新页面重新操作")

if __name__ == "__main__":
    test_beauty_button()
