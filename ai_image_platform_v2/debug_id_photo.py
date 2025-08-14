#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
调试证件照功能的脚本
检查用户登录、图片上传和证件照生成的完整流程
"""

import requests
import time
import base64
import os

def debug_id_photo_feature():
    """调试证件照功能"""
    print("🔍 调试证件照功能")
    print("=" * 50)
    
    base_url = "http://127.0.0.1:5002"
    api_url = f"{base_url}/api"
    session = requests.Session()
    
    # 1. 检查服务状态
    try:
        response = session.get(f"{api_url}/health", timeout=5)
        print("✅ 后端服务正常")
    except:
        print("❌ 后端服务不可访问")
        return
    
    # 2. 创建测试用户
    timestamp = int(time.time())
    user_data = {
        "username": f"idphoto_{timestamp}",
        "email": f"idphoto{timestamp}@example.com", 
        "password": "testpass123"
    }
    
    print(f"\n👤 创建测试用户: {user_data['username']}")
    
    # 注册
    register_response = session.post(
        f"{api_url}/users/register",
        json=user_data,
        headers={'Content-Type': 'application/json'}
    )
    
    if register_response.status_code not in [200, 201]:
        print(f"❌ 用户注册失败: {register_response.status_code}")
        return
    
    # 登录
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
    
    # 3. 验证token
    verify_response = session.post(f"{api_url}/users/verify-token")
    if verify_response.status_code == 200 and verify_response.json().get('valid'):
        print("✅ Token验证成功")
    else:
        print("❌ Token验证失败")
        return
    
    # 4. 上传图片
    print(f"\n📷 上传测试图片")
    
    image_data = base64.b64decode(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    )
    
    filename = "debug_image.png"
    with open(filename, "wb") as f:
        f.write(image_data)
    
    try:
        with open(filename, "rb") as f:
            files = {'file': (filename, f, 'image/png')}
            upload_response = session.post(f"{api_url}/images/upload", files=files)
        
        os.remove(filename)
        
        if upload_response.status_code not in [200, 201]:
            print(f"❌ 图片上传失败: {upload_response.status_code}")
            print(f"响应: {upload_response.text}")
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
    
    # 5. 测试证件照生成
    print(f"\n🎫 测试证件照生成")
    
    id_photo_params = {
        "image_id": image_id,
        "photo_type": "1_inch",
        "background_color": "white",
        "beauty_strength": 30,
        "auto_crop": True
    }
    
    print(f"参数: {id_photo_params}")
    
    id_photo_response = session.post(
        f"{api_url}/processing/id-photo",
        json=id_photo_params
    )
    
    print(f"响应状态码: {id_photo_response.status_code}")
    
    if id_photo_response.status_code == 200:
        id_photo_data = id_photo_response.json()
        print(f"响应数据: {id_photo_data}")
        
        if id_photo_data.get('success'):
            print("✅ 证件照生成成功")
            result_url = id_photo_data.get('data', {}).get('result_url')
            if result_url:
                print(f"结果URL: {result_url}")
            else:
                print("⚠️ 缺少结果URL")
        else:
            print(f"❌ 证件照生成失败: {id_photo_data.get('message')}")
    else:
        print(f"❌ 证件照生成请求失败")
        print(f"错误详情: {id_photo_response.text}")
    
    # 6. 给出前端使用指导
    print(f"\n💡 前端使用指导:")
    print(f"1. 确保用户已登录 ✅")
    print(f"2. 确保已上传图片 ✅") 
    print(f"3. 点击侧边栏的'证件照生成'切换到证件照模块")
    print(f"4. 在右侧控制面板中会显示证件照生成按钮")
    print(f"5. 按钮应该是启用状态（不是disabled）")
    print(f"6. 点击'生成证件照'按钮即可处理")
    
    print(f"\n🔧 如果按钮仍然禁用，请检查:")
    print(f"- 浏览器控制台是否有JavaScript错误")
    print(f"- currentUser 和 currentImage 变量是否正确设置")
    print(f"- 是否正确切换到了证件照模块")

if __name__ == "__main__":
    debug_id_photo_feature()
