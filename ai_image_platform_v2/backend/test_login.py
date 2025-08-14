#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试登录API
"""

import requests
import json

def test_login():
    url = 'http://127.0.0.1:5002/api/users/login'
    data = {
        'username': 'admin',
        'password': 'admin123'
    }
    
    try:
        response = requests.post(url, json=data)
        print(f'状态码: {response.status_code}')
        print(f'响应头: {dict(response.headers)}')
        print(f'响应内容: {response.text}')
        
        if response.status_code == 200:
            result = response.json()
            print(f'登录成功: {result}')
        else:
            print(f'登录失败: {response.status_code}')
            
    except Exception as e:
        print(f'请求异常: {e}')

if __name__ == '__main__':
    test_login()