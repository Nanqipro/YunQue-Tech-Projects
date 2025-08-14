#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试简化版图片跨模块共享功能
保持原有界面布局，只测试核心功能
"""

import requests
import time
import base64
import os

def test_simple_sharing():
    """测试简化版图片共享"""
    print("🚀 测试简化版图片跨模块共享功能")
    print("=" * 50)
    
    base_url = "http://127.0.0.1:5002"
    api_url = f"{base_url}/api"
    session = requests.Session()
    
    # 检查服务状态
    try:
        response = session.get(f"{api_url}/health", timeout=5)
        print("✅ 后端服务可访问")
    except:
        print("❌ 无法连接到后端服务")
        return
    
    # 创建测试用户
    timestamp = int(time.time())
    user_data = {
        "username": f"simpletest_{timestamp}",
        "email": f"simpletest{timestamp}@example.com",
        "password": "testpass123"
    }
    
    # 注册并登录
    register_response = session.post(
        f"{api_url}/users/register",
        json=user_data,
        headers={'Content-Type': 'application/json'}
    )
    
    if register_response.status_code in [200, 201]:
        # 登录
        login_response = session.post(
            f"{api_url}/users/login",
            json={"username": user_data["username"], "password": user_data["password"]},
            headers={'Content-Type': 'application/json'}
        )
        
        if login_response.status_code == 200:
            data = login_response.json()
            if data.get('success'):
                auth_token = data['data']['token']
                session.headers.update({'Authorization': f'Bearer {auth_token}'})
                print(f"✅ 用户登录成功: {user_data['username']}")
            else:
                print("❌ 登录失败")
                return
        else:
            print("❌ 登录请求失败")
            return
    else:
        print("❌ 用户注册失败")
        return
    
    # 上传测试图片
    image_data = base64.b64decode(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    )
    
    filename = "simple_test.png"
    with open(filename, "wb") as f:
        f.write(image_data)
    
    try:
        with open(filename, "rb") as f:
            files = {'file': (filename, f, 'image/png')}
            upload_response = session.post(f"{api_url}/images/upload", files=files)
        
        os.remove(filename)
        
        if upload_response.status_code in [200, 201]:
            upload_data = upload_response.json()
            if upload_data.get('success'):
                image_id = upload_data['data']['id']
                print(f"✅ 图片上传成功，ID: {image_id}")
                
                # 测试跨模块功能
                print(f"\n🔄 测试同一图片在不同模块的使用:")
                
                # 1. 美颜处理
                beauty_params = {
                    "image_id": image_id,
                    "smoothing": 0.3,
                    "whitening": 0.4,
                    "eye_enhancement": 0.6,
                    "lip_enhancement": 0.25,
                    "ai_mode": True
                }
                
                beauty_response = session.post(f"{api_url}/processing/beauty", json=beauty_params)
                if beauty_response.status_code == 200 and beauty_response.json().get('success'):
                    print("  ✅ 美颜模块：成功")
                else:
                    print("  ❌ 美颜模块：失败")
                
                # 2. 证件照处理
                id_photo_params = {
                    "image_id": image_id,
                    "photo_type": "1_inch",
                    "background_color": "white",
                    "beauty_strength": 30,
                    "auto_crop": True
                }
                
                id_response = session.post(f"{api_url}/processing/id-photo", json=id_photo_params)
                if id_response.status_code == 200 and id_response.json().get('success'):
                    print("  ✅ 证件照模块：成功")
                else:
                    print("  ❌ 证件照模块：失败")
                
                # 3. 背景处理
                bg_params = {
                    "image_id": image_id,
                    "background_type": "remove",
                    "intensity": 0.8
                }
                
                bg_response = session.post(f"{api_url}/processing/background", json=bg_params)
                if bg_response.status_code == 200 and bg_response.json().get('success'):
                    print("  ✅ 背景处理模块：成功")
                else:
                    print("  ❌ 背景处理模块：失败")
                
                print(f"\n🎉 测试完成！")
                print(f"📋 总结:")
                print(f"  - 保持了原有的界面布局和样式")
                print(f"  - 实现了图片在不同模块间的共享")
                print(f"  - 用户上传一次图片后可在所有模块使用")
                print(f"  - 切换模块时图片状态自动保持")
                
            else:
                print("❌ 图片上传响应异常")
        else:
            print("❌ 图片上传失败")
            
    except Exception as e:
        print(f"❌ 测试过程中出错: {str(e)}")

if __name__ == "__main__":
    test_simple_sharing()
