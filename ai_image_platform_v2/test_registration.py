#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
用户注册功能测试脚本
用于测试后端注册接口是否正常工作
"""

import requests
import json
import time
import random

# 配置
API_BASE_URL = "http://localhost:5002/api"
TEST_USERS = [
    {
        "username": f"testuser_{int(time.time())}",
        "email": f"test_{int(time.time())}@example.com",
        "password": "test123456"
    },
    {
        "username": f"demo_{random.randint(1000, 9999)}",
        "email": f"demo_{random.randint(1000, 9999)}@test.com",
        "password": "demo123456"
    }
]

def test_registration():
    """测试用户注册功能"""
    print("=== 用户注册功能测试 ===\n")
    
    for i, user_data in enumerate(TEST_USERS, 1):
        print(f"测试用户 {i}: {user_data['username']}")
        
        try:
            # 发送注册请求
            response = requests.post(
                f"{API_BASE_URL}/users/register",
                json=user_data,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            print(f"状态码: {response.status_code}")
            print(f"响应: {response.text}")
            
            if response.status_code == 201:
                print("✅ 注册成功!")
                user_info = response.json()
                print(f"用户ID: {user_info['data']['user']['id']}")
            elif response.status_code == 409:
                print("⚠️  用户已存在 (这是正常的)")
            else:
                print(f"❌ 注册失败: {response.status_code}")
                
        except requests.exceptions.ConnectionError:
            print("❌ 连接失败: 请确保后端服务正在运行")
        except requests.exceptions.Timeout:
            print("❌ 请求超时")
        except Exception as e:
            print(f"❌ 其他错误: {e}")
        
        print("-" * 50)
    
    print("\n=== 测试完成 ===")
    print("如果看到 '用户已存在' 错误，这是正常的，说明用户名冲突检测工作正常")
    print("请尝试使用不同的用户名进行注册")

def test_login():
    """测试用户登录功能"""
    print("\n=== 用户登录功能测试 ===\n")
    
    # 使用第一个测试用户尝试登录
    user_data = TEST_USERS[0]
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/users/login",
            json={
                "username": user_data["username"],
                "password": user_data["password"]
            },
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"登录状态码: {response.status_code}")
        print(f"登录响应: {response.text}")
        
        if response.status_code == 200:
            print("✅ 登录成功!")
            login_info = response.json()
            if 'token' in login_info['data']:
                print("✅ 获取到认证令牌")
        else:
            print(f"❌ 登录失败: {response.status_code}")
            
    except Exception as e:
        print(f"❌ 登录测试失败: {e}")

def check_service_health():
    """检查服务健康状态"""
    print("=== 服务健康检查 ===\n")
    
    try:
        response = requests.get(f"{API_BASE_URL}/health", timeout=5)
        print(f"健康检查状态码: {response.status_code}")
        
        if response.status_code == 200:
            health_data = response.json()
            print("✅ 服务正常运行")
            print(f"状态: {health_data.get('status', 'unknown')}")
            print(f"版本: {health_data.get('version', 'unknown')}")
        else:
            print(f"⚠️  服务状态异常: {response.status_code}")
            
    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到服务，请检查后端是否启动")
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")

if __name__ == "__main__":
    print("AI图像处理平台 - 用户注册测试")
    print("=" * 50)
    
    # 检查服务健康状态
    check_service_health()
    
    # 测试注册功能
    test_registration()
    
    # 测试登录功能
    test_login()
    
    print("\n=== 测试总结 ===")
    print("1. 如果看到 '用户已存在' 错误，这是正常的冲突检测")
    print("2. 请在前端使用不同的用户名进行注册")
    print("3. 建议的用户名格式: 用户名_时间戳 (如: myuser_1234567890)")
    print("4. 确保密码长度至少6个字符")
