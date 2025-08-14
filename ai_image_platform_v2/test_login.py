#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试用户登录API
"""

import requests
import json

def test_login():
    """测试用户登录功能"""
    
    # API端点
    login_url = "http://localhost:5002/api/users/login"
    
    # 测试数据
    test_data = {
        "username": "admin",
        "password": "admin123"
    }
    
    print("=== 测试用户登录API ===")
    print(f"请求URL: {login_url}")
    print(f"请求数据: {json.dumps(test_data, ensure_ascii=False, indent=2)}")
    print()
    
    try:
        # 发送POST请求
        response = requests.post(
            login_url,
            json=test_data,
            headers={
                "Content-Type": "application/json"
            },
            timeout=10
        )
        
        print(f"响应状态码: {response.status_code}")
        print(f"响应头: {dict(response.headers)}")
        print()
        
        # 解析响应
        if response.headers.get('content-type', '').startswith('application/json'):
            response_data = response.json()
            print(f"响应数据: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
            
            if response.status_code == 200:
                print("\n✅ 登录成功！")
                if 'data' in response_data and 'token' in response_data['data']:
                    token = response_data['data']['token']
                    print(f"获取到Token: {token[:50]}...")
                    
                    # 测试token验证
                    test_token_verification(token)
                    
            else:
                print(f"\n❌ 登录失败: {response_data.get('message', '未知错误')}")
        else:
            print(f"响应内容: {response.text}")
            print("\n❌ 响应不是JSON格式")
            
    except requests.exceptions.ConnectionError:
        print("❌ 连接失败: 无法连接到后端服务，请确保后端服务正在运行")
    except requests.exceptions.Timeout:
        print("❌ 请求超时")
    except requests.exceptions.RequestException as e:
        print(f"❌ 请求异常: {e}")
    except json.JSONDecodeError:
        print("❌ 响应JSON解析失败")
    except Exception as e:
        print(f"❌ 未知错误: {e}")

def test_token_verification(token):
    """测试token验证"""
    
    verify_url = "http://localhost:5002/api/users/verify-token"
    
    print("\n=== 测试Token验证 ===")
    print(f"请求URL: {verify_url}")
    
    try:
        response = requests.post(
            verify_url,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            timeout=10
        )
        
        print(f"响应状态码: {response.status_code}")
        
        if response.headers.get('content-type', '').startswith('application/json'):
            response_data = response.json()
            print(f"响应数据: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
            
            if response.status_code == 200:
                print("\n✅ Token验证成功！")
            else:
                print(f"\n❌ Token验证失败: {response_data.get('message', '未知错误')}")
        else:
            print(f"响应内容: {response.text}")
            
    except Exception as e:
        print(f"❌ Token验证异常: {e}")

def test_user_registration():
    """测试用户注册功能"""
    
    register_url = "http://localhost:5002/api/users/register"
    
    # 测试数据
    test_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpass123"
    }
    
    print("\n=== 测试用户注册API ===")
    print(f"请求URL: {register_url}")
    print(f"请求数据: {json.dumps(test_data, ensure_ascii=False, indent=2)}")
    
    try:
        response = requests.post(
            register_url,
            json=test_data,
            headers={
                "Content-Type": "application/json"
            },
            timeout=10
        )
        
        print(f"响应状态码: {response.status_code}")
        
        if response.headers.get('content-type', '').startswith('application/json'):
            response_data = response.json()
            print(f"响应数据: {json.dumps(response_data, ensure_ascii=False, indent=2)}")
            
            if response.status_code == 201:
                print("\n✅ 注册成功！")
            elif response.status_code == 409:
                print("\n⚠️ 用户已存在（这是正常的）")
            else:
                print(f"\n❌ 注册失败: {response_data.get('message', '未知错误')}")
        else:
            print(f"响应内容: {response.text}")
            
    except Exception as e:
        print(f"❌ 注册测试异常: {e}")

if __name__ == "__main__":
    print("开始测试AI图片处理平台API...\n")
    
    # 测试注册
    test_user_registration()
    
    # 测试登录
    test_login()
    
    print("\n测试完成！")