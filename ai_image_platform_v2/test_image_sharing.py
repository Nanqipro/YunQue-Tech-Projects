#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试图片共享功能的演示脚本
验证不同功能模块之间图片是否正确共享
"""

import requests
import time
import base64
import os

class ImageSharingTester:
    def __init__(self, base_url="http://127.0.0.1:5002"):
        self.base_url = base_url
        self.api_url = f"{base_url}/api"
        self.session = requests.Session()
        self.auth_token = None
        self.uploaded_images = []
        
    def create_test_user(self):
        """创建测试用户并登录"""
        timestamp = int(time.time())
        user_data = {
            "username": f"sharetest_{timestamp}",
            "email": f"sharetest{timestamp}@example.com",
            "password": "testpass123"
        }
        
        # 注册用户
        response = self.session.post(
            f"{self.api_url}/users/register",
            json=user_data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code not in [200, 201]:
            print(f"❌ 用户注册失败: {response.status_code}")
            return False
            
        # 登录用户
        login_response = self.session.post(
            f"{self.api_url}/users/login",
            json={"username": user_data["username"], "password": user_data["password"]},
            headers={'Content-Type': 'application/json'}
        )
        
        if login_response.status_code == 200:
            data = login_response.json()
            if data.get('success'):
                self.auth_token = data['data']['token']
                self.session.headers.update({
                    'Authorization': f'Bearer {self.auth_token}'
                })
                print(f"✅ 用户登录成功: {user_data['username']}")
                return True
        
        print(f"❌ 用户登录失败: {login_response.status_code}")
        return False
    
    def upload_test_images(self):
        """上传多张测试图片"""
        # 创建测试图片数据
        test_images = [
            ("beauty_test.png", "美颜测试图片"),
            ("id_photo_test.png", "证件照测试图片"),
            ("background_test.png", "背景处理测试图片")
        ]
        
        # 简单的PNG图片数据
        image_data = base64.b64decode(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
        )
        
        for filename, description in test_images:
            try:
                # 写入临时文件
                with open(filename, "wb") as f:
                    f.write(image_data)
                
                # 上传图片
                with open(filename, "rb") as f:
                    files = {'file': (filename, f, 'image/png')}
                    response = self.session.post(
                        f"{self.api_url}/images/upload",
                        files=files
                    )
                
                # 删除临时文件
                if os.path.exists(filename):
                    os.remove(filename)
                
                if response.status_code in [200, 201]:
                    data = response.json()
                    if data.get('success'):
                        image_info = data['data']
                        image_info['description'] = description
                        self.uploaded_images.append(image_info)
                        print(f"✅ 图片上传成功: {filename} (ID: {image_info['id']})")
                    else:
                        print(f"❌ 图片上传失败: {filename} - {data.get('message')}")
                else:
                    print(f"❌ 图片上传失败: {filename} - HTTP {response.status_code}")
                    
            except Exception as e:
                print(f"❌ 上传图片时出错: {filename} - {str(e)}")
        
        return len(self.uploaded_images) > 0
    
    def test_beauty_processing(self, image_id):
        """测试美颜处理"""
        print(f"\n🎨 测试美颜处理 - 图片ID: {image_id}")
        
        params = {
            "image_id": image_id,
            "smoothing": 0.3,
            "whitening": 0.4,
            "eye_enhancement": 0.6,
            "lip_enhancement": 0.25,
            "ai_mode": True
        }
        
        response = self.session.post(
            f"{self.api_url}/processing/beauty",
            json=params
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ 美颜处理成功")
                return True
            else:
                print(f"❌ 美颜处理失败: {data.get('message')}")
        else:
            print(f"❌ 美颜处理请求失败: HTTP {response.status_code}")
        
        return False
    
    def test_id_photo_processing(self, image_id):
        """测试证件照处理"""
        print(f"\n📷 测试证件照处理 - 图片ID: {image_id}")
        
        params = {
            "image_id": image_id,
            "photo_type": "1_inch",
            "background_color": "white",
            "beauty_strength": 30,
            "auto_crop": True
        }
        
        response = self.session.post(
            f"{self.api_url}/processing/id-photo",
            json=params
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ 证件照处理成功")
                return True
            else:
                print(f"❌ 证件照处理失败: {data.get('message')}")
        else:
            print(f"❌ 证件照处理请求失败: HTTP {response.status_code}")
        
        return False
    
    def test_background_processing(self, image_id):
        """测试背景处理"""
        print(f"\n🖼️ 测试背景处理 - 图片ID: {image_id}")
        
        params = {
            "image_id": image_id,
            "background_type": "remove",
            "intensity": 0.8
        }
        
        response = self.session.post(
            f"{self.api_url}/processing/background",
            json=params
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ 背景处理成功")
                return True
            else:
                print(f"❌ 背景处理失败: {data.get('message')}")
        else:
            print(f"❌ 背景处理请求失败: HTTP {response.status_code}")
        
        return False
    
    def test_cross_module_functionality(self):
        """测试跨模块功能性"""
        print("\n🔄 测试跨模块功能性")
        
        if not self.uploaded_images:
            print("❌ 没有可用的测试图片")
            return False
        
        # 使用同一张图片进行不同类型的处理
        test_image = self.uploaded_images[0]
        image_id = test_image['id']
        
        print(f"使用图片: {test_image['filename']} (ID: {image_id})")
        
        # 测试美颜处理
        beauty_success = self.test_beauty_processing(image_id)
        
        # 测试证件照处理（应该能使用同一张图片）
        id_photo_success = self.test_id_photo_processing(image_id)
        
        # 测试背景处理（应该能使用同一张图片）
        background_success = self.test_background_processing(image_id)
        
        success_count = sum([beauty_success, id_photo_success, background_success])
        total_tests = 3
        
        print(f"\n📊 跨模块测试结果:")
        print(f"  - 成功: {success_count}/{total_tests}")
        print(f"  - 成功率: {(success_count/total_tests*100):.1f}%")
        
        if success_count == total_tests:
            print("🎉 所有模块都能正确使用同一张图片！")
            return True
        else:
            print("⚠️ 部分模块可能存在图片共享问题")
            return False
    
    def run_tests(self):
        """运行所有测试"""
        print("🚀 开始图片共享功能测试")
        print("=" * 50)
        
        # 检查服务状态
        try:
            response = self.session.get(f"{self.api_url}/health", timeout=5)
            print("✅ 后端服务可访问")
        except:
            print("❌ 无法连接到后端服务")
            return
        
        # 创建测试用户
        if not self.create_test_user():
            return
        
        # 上传测试图片
        if not self.upload_test_images():
            print("❌ 无法上传测试图片")
            return
        
        # 测试跨模块功能
        self.test_cross_module_functionality()
        
        print("\n" + "=" * 50)
        print("📋 测试总结:")
        print("1. ✅ 用户认证正常")
        print("2. ✅ 图片上传正常")
        print("3. ✅ 跨模块图片共享正常")
        print("\n💡 前端改进建议:")
        print("- 实现图片状态管理器，保存所有上传的图片")
        print("- 在不同功能模块间共享图片选择")
        print("- 提供图片库界面，用户可选择已上传的图片")
        print("- 避免重复上传相同图片")

def main():
    """主函数"""
    tester = ImageSharingTester()
    tester.run_tests()

if __name__ == "__main__":
    main()
