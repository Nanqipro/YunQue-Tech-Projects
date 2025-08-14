#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试控制面板功能的脚本
"""

import requests
import time
import base64
import os

def test_control_panel():
    """测试控制面板功能"""
    print("🎛️ 测试控制面板功能")
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
        "username": f"paneltest_{timestamp}",
        "email": f"paneltest{timestamp}@example.com",
        "password": "testpass123"
    }
    
    print(f"👤 创建测试用户: {user_data['username']}")
    
    # 注册用户
    register_response = session.post(
        f"{api_url}/users/register",
        json=user_data,
        headers={'Content-Type': 'application/json'}
    )
    
    if register_response.status_code not in [200, 201]:
        print(f"❌ 用户注册失败: {register_response.status_code}")
        return
    
    # 登录用户
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
    
    filename = "panel_test.png"
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
    
    # 测试美颜功能（验证控制面板参数是否生效）
    print("\n🎨 测试美颜处理（验证控制面板）")
    
    beauty_params = {
        "image_id": image_id,
        "smoothing": 0.5,      # 磨皮强度
        "whitening": 0.6,      # 美白程度
        "eye_enhancement": 0.7, # 眼部增强
        "lip_enhancement": 0.3, # 唇部调整
        "ai_mode": True
    }
    
    beauty_response = session.post(f"{api_url}/processing/beauty", json=beauty_params)
    
    if beauty_response.status_code == 200:
        beauty_data = beauty_response.json()
        if beauty_data.get('success'):
            print("✅ 美颜处理成功 - 控制面板参数已生效")
        else:
            print(f"❌ 美颜处理失败: {beauty_data.get('message')}")
    else:
        print(f"❌ 美颜处理请求失败: {beauty_response.status_code}")
    
    print(f"\n💡 前端控制面板检查要点:")
    print(f"1. 登录后右侧控制面板应该可用")
    print(f"2. 上传图片后美颜面板应该启用（不是灰色）")
    print(f"3. 滑块和按钮应该可以交互")
    print(f"4. 切换不同功能模块时，控制面板内容应该更新")
    print(f"5. 开发者工具Console中不应该有JavaScript错误")
    
    print(f"\n🔧 如果控制面板无法使用:")
    print(f"- 检查浏览器Console是否有错误")
    print(f"- 检查是否正确切换到了对应的功能模块")
    print(f"- 检查简化版图片管理器是否正确加载")
    print(f"- 尝试刷新页面重新登录和上传")

if __name__ == "__main__":
    test_control_panel()
