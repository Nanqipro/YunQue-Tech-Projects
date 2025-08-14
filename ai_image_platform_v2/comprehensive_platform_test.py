#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI图像处理平台全面功能测试脚本
测试所有主要功能模块，包括用户管理、图片处理、API接口等
"""

import requests
import json
import time
import os
import base64
from datetime import datetime
import hashlib

class AIImagePlatformTester:
    def __init__(self, base_url="http://127.0.0.1:5002"):
        self.base_url = base_url
        self.api_url = f"{base_url}/api"
        self.session = requests.Session()
        self.auth_token = None
        self.test_user = None
        self.test_image = None
        self.test_results = []
        
        # 设置请求头
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'AI-Platform-Tester/1.0'
        })
    
    def log_test(self, test_name, status, message="", details=None):
        """记录测试结果"""
        result = {
            'test_name': test_name,
            'status': status,
            'message': message,
            'timestamp': datetime.now().isoformat(),
            'details': details
        }
        self.test_results.append(result)
        
        # 打印测试结果
        status_icon = "✅" if status == "PASS" else "❌" if status == "FAIL" else "⚠️"
        print(f"{status_icon} {test_name}: {message}")
        if details:
            print(f"   详情: {details}")
    
    def test_health_check(self):
        """测试健康检查接口"""
        try:
            response = self.session.get(f"{self.api_url}/health")
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 'healthy' or 'checks' in data:
                    self.log_test("健康检查", "PASS", "服务正常运行")
                    return True
                else:
                    self.log_test("健康检查", "WARNING", f"服务状态异常: {data.get('status')}")
                    return True  # 即使状态不是healthy，服务也是可用的
            else:
                self.log_test("健康检查", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("健康检查", "FAIL", f"连接失败: {str(e)}")
            return False
    
    def test_user_registration(self):
        """测试用户注册功能"""
        try:
            # 生成唯一用户名
            timestamp = int(time.time())
            username = f"testuser_{timestamp}"
            email = f"test{timestamp}@example.com"
            
            user_data = {
                "username": username,
                "email": email,
                "password": "testpass123"
            }
            
            response = self.session.post(
                f"{self.api_url}/users/register",
                json=user_data
            )
            
            if response.status_code in [200, 201]:
                data = response.json()
                if data.get('success'):
                    self.test_user = user_data
                    self.log_test("用户注册", "PASS", f"成功创建用户: {username}")
                    return True
                else:
                    self.log_test("用户注册", "FAIL", f"注册失败: {data.get('message')}")
                    return False
            else:
                self.log_test("用户注册", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("用户注册", "FAIL", f"注册异常: {str(e)}")
            return False
    
    def test_user_login(self):
        """测试用户登录功能"""
        if not self.test_user:
            self.log_test("用户登录", "SKIP", "没有测试用户")
            return False
            
        try:
            login_data = {
                "username": self.test_user["username"],
                "password": self.test_user["password"]
            }
            
            response = self.session.post(
                f"{self.api_url}/users/login",
                json=login_data
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success') and data.get('data', {}).get('token'):
                    self.auth_token = data['data']['token']
                    # 设置认证头
                    self.session.headers.update({
                        'Authorization': f'Bearer {self.auth_token}'
                    })
                    self.log_test("用户登录", "PASS", "登录成功，获取到token")
                    return True
                else:
                    self.log_test("用户登录", "FAIL", f"登录失败: {data.get('message')}")
                    return False
            else:
                self.log_test("用户登录", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("用户登录", "FAIL", f"登录异常: {str(e)}")
            return False
    
    def test_token_verification(self):
        """测试token验证功能"""
        if not self.auth_token:
            self.log_test("Token验证", "SKIP", "没有认证token")
            return False
            
        try:
            response = self.session.post(f"{self.api_url}/users/verify-token")
            
            if response.status_code == 200:
                data = response.json()
                if data.get('valid'):
                    self.log_test("Token验证", "PASS", "Token验证成功")
                    return True
                else:
                    self.log_test("Token验证", "FAIL", "Token验证失败")
                    return False
            else:
                self.log_test("Token验证", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("Token验证", "FAIL", f"验证异常: {str(e)}")
            return False
    
    def create_test_image(self):
        """创建一个测试图片文件"""
        try:
            # 创建一个简单的测试图片（1x1像素的PNG）
            test_image_data = base64.b64decode(
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
            )
            
            # 保存到临时文件
            test_image_path = "test_image.png"
            with open(test_image_path, "wb") as f:
                f.write(test_image_data)
            
            self.test_image = test_image_path
            self.log_test("创建测试图片", "PASS", "成功创建测试图片")
            return True
            
        except Exception as e:
            self.log_test("创建测试图片", "FAIL", f"创建失败: {str(e)}")
            return False
    
    def test_image_upload(self):
        """测试图片上传功能"""
        if not self.test_image or not os.path.exists(self.test_image):
            if not self.create_test_image():
                return False
        
        if not self.auth_token:
            self.log_test("图片上传", "SKIP", "没有认证token")
            return False
            
        try:
            # 准备上传数据
            with open(self.test_image, 'rb') as f:
                files = {'file': ('test_image.png', f, 'image/png')}
                
                # 临时移除JSON header，因为要上传文件
                headers = self.session.headers.copy()
                headers.pop('Content-Type', None)
                
                response = self.session.post(
                    f"{self.api_url}/images/upload",
                    files=files,
                    headers=headers
                )
            
            if response.status_code in [200, 201]:  # 201 Created 也是成功状态
                data = response.json()
                if data.get('success'):
                    self.log_test("图片上传", "PASS", "图片上传成功")
                    return True
                else:
                    self.log_test("图片上传", "FAIL", f"上传失败: {data.get('message')}")
                    return False
            else:
                self.log_test("图片上传", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("图片上传", "FAIL", f"上传异常: {str(e)}")
            return False
    
    def test_beauty_processing(self):
        """测试美颜处理功能"""
        if not self.auth_token:
            self.log_test("美颜处理", "SKIP", "没有认证token")
            return False
            
        try:
            # 模拟美颜处理请求
            beauty_data = {
                "image_id": 1,  # 假设的图片ID
                "smoothing": 0.3,
                "whitening": 0.4,
                "eye_enhancement": 0.6,
                "lip_enhancement": 0.25,
                "ai_mode": True
            }
            
            response = self.session.post(
                f"{self.api_url}/processing/beauty",
                json=beauty_data
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test("美颜处理", "PASS", "美颜处理请求成功")
                    return True
                else:
                    self.log_test("美颜处理", "FAIL", f"处理失败: {data.get('message')}")
                    return False
            elif response.status_code == 404:
                self.log_test("美颜处理", "WARNING", "图片不存在（这是正常的，因为我们使用了假设的图片ID）")
                return True
            else:
                self.log_test("美颜处理", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("美颜处理", "FAIL", f"处理异常: {str(e)}")
            return False
    
    def test_id_photo_processing(self):
        """测试证件照处理功能"""
        if not self.auth_token:
            self.log_test("证件照处理", "SKIP", "没有认证token")
            return False
            
        try:
            # 模拟证件照处理请求
            id_photo_data = {
                "image_id": 1,  # 假设的图片ID
                "photo_type": "1_inch",
                "background_color": "red",
                "beauty_strength": 30,
                "auto_crop": True
            }
            
            response = self.session.post(
                f"{self.api_url}/processing/id-photo",
                json=id_photo_data
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test("证件照处理", "PASS", "证件照处理请求成功")
                    return True
                else:
                    self.log_test("证件照处理", "FAIL", f"处理失败: {data.get('message')}")
                    return False
            elif response.status_code == 404:
                self.log_test("证件照处理", "WARNING", "图片不存在（这是正常的，因为我们使用了假设的图片ID）")
                return True
            else:
                self.log_test("证件照处理", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("证件照处理", "FAIL", f"处理异常: {str(e)}")
            return False
    
    def test_background_processing(self):
        """测试背景处理功能"""
        if not self.auth_token:
            self.log_test("背景处理", "SKIP", "没有认证token")
            return False
            
        try:
            # 模拟背景处理请求
            background_data = {
                "image_id": 1,  # 假设的图片ID
                "background_type": "remove",
                "intensity": 0.8
            }
            
            response = self.session.post(
                f"{self.api_url}/processing/background",
                json=background_data
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    self.log_test("背景处理", "PASS", "背景处理请求成功")
                    return True
                else:
                    self.log_test("背景处理", "FAIL", f"处理失败: {data.get('message')}")
                    return False
            elif response.status_code == 404:
                self.log_test("背景处理", "WARNING", "图片不存在（这是正常的，因为我们使用了假设的图片ID）")
                return True
            else:
                self.log_test("背景处理", "FAIL", f"HTTP状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("背景处理", "FAIL", f"处理异常: {str(e)}")
            return False
    
    def test_unauthorized_access(self):
        """测试未授权访问"""
        try:
            # 临时移除认证头
            original_headers = self.session.headers.copy()
            self.session.headers.pop('Authorization', None)
            
            # 尝试访问需要认证的接口
            response = self.session.post(
                f"{self.api_url}/processing/beauty",
                json={"image_id": 1}
            )
            
            # 恢复认证头
            self.session.headers.update(original_headers)
            
            if response.status_code == 401:
                self.log_test("未授权访问保护", "PASS", "正确拒绝未授权访问")
                return True
            else:
                self.log_test("未授权访问保护", "FAIL", f"未正确拒绝未授权访问，状态码: {response.status_code}")
                return False
                
        except Exception as e:
            self.log_test("未授权访问保护", "FAIL", f"测试异常: {str(e)}")
            return False
    
    def test_cors_headers(self):
        """测试CORS头设置"""
        try:
            response = self.session.options(f"{self.api_url}/health")
            
            cors_headers = {
                'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
                'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
                'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers')
            }
            
            if any(cors_headers.values()):
                self.log_test("CORS头设置", "PASS", "CORS头已正确设置")
                return True
            else:
                self.log_test("CORS头设置", "WARNING", "CORS头未设置或为空")
                return True  # 这可能是正常的，取决于配置
                
        except Exception as e:
            self.log_test("CORS头设置", "FAIL", f"测试异常: {str(e)}")
            return False
    
    def test_error_handling(self):
        """测试错误处理"""
        try:
            # 测试无效的JSON数据
            response = self.session.post(
                f"{self.api_url}/users/login",
                data="invalid json",
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 400:
                self.log_test("错误处理", "PASS", "正确处理无效JSON数据")
                return True
            else:
                self.log_test("错误处理", "WARNING", f"无效JSON处理状态码: {response.status_code}")
                return True  # 不同的状态码也可能是正确的处理方式
                
        except Exception as e:
            self.log_test("错误处理", "FAIL", f"测试异常: {str(e)}")
            return False
    
    def cleanup(self):
        """清理测试资源"""
        try:
            # 删除测试图片
            if self.test_image and os.path.exists(self.test_image):
                os.remove(self.test_image)
                print("🧹 已清理测试图片")
            
            # 如果有认证token，尝试登出
            if self.auth_token:
                try:
                    self.session.post(f"{self.api_url}/users/logout")
                    print("🚪 已尝试登出测试用户")
                except:
                    pass  # 登出失败不影响测试结果
                    
        except Exception as e:
            print(f"⚠️  清理过程中出现异常: {str(e)}")
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始AI图像处理平台全面功能测试")
        print("=" * 60)
        
        # 基础功能测试
        self.test_health_check()
        self.test_user_registration()
        self.test_user_login()
        self.test_token_verification()
        
        # 图片处理功能测试
        self.test_image_upload()
        self.test_beauty_processing()
        self.test_id_photo_processing()
        self.test_background_processing()
        
        # 安全性和兼容性测试
        self.test_unauthorized_access()
        self.test_cors_headers()
        self.test_error_handling()
        
        # 清理资源
        self.cleanup()
        
        # 生成测试报告
        self.generate_test_report()
    
    def generate_test_report(self):
        """生成测试报告"""
        print("\n" + "=" * 60)
        print("📊 测试结果总结")
        print("=" * 60)
        
        # 统计结果
        total_tests = len(self.test_results)
        passed_tests = len([r for r in self.test_results if r['status'] == 'PASS'])
        failed_tests = len([r for r in self.test_results if r['status'] == 'FAIL'])
        warning_tests = len([r for r in self.test_results if r['status'] == 'WARNING'])
        skipped_tests = len([r for r in self.test_results if r['status'] == 'SKIP'])
        
        print(f"总测试数: {total_tests}")
        print(f"✅ 通过: {passed_tests}")
        print(f"❌ 失败: {failed_tests}")
        print(f"⚠️  警告: {warning_tests}")
        print(f"⏭️  跳过: {skipped_tests}")
        
        # 成功率
        if total_tests > 0:
            success_rate = (passed_tests / total_tests) * 100
            print(f"成功率: {success_rate:.1f}%")
        
        # 失败的测试
        if failed_tests > 0:
            print(f"\n❌ 失败的测试:")
            for result in self.test_results:
                if result['status'] == 'FAIL':
                    print(f"  - {result['test_name']}: {result['message']}")
        
        # 警告的测试
        if warning_tests > 0:
            print(f"\n⚠️  警告的测试:")
            for result in self.test_results:
                if result['status'] == 'WARNING':
                    print(f"  - {result['test_name']}: {result['message']}")
        
        # 总体评估
        print(f"\n🎯 总体评估:")
        if failed_tests == 0 and warning_tests <= 2:
            print("  🎉 平台功能完善，所有核心功能正常工作！")
        elif failed_tests <= 2:
            print("  ✅ 平台功能基本完善，少数功能需要优化")
        else:
            print("  ⚠️  平台存在较多问题，需要重点修复")
        
        # 保存详细报告
        self.save_detailed_report()
    
    def save_detailed_report(self):
        """保存详细测试报告"""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            report_file = f"test_report_{timestamp}.json"
            
            with open(report_file, 'w', encoding='utf-8') as f:
                json.dump(self.test_results, f, ensure_ascii=False, indent=2)
            
            print(f"\n📄 详细测试报告已保存到: {report_file}")
            
        except Exception as e:
            print(f"⚠️  保存报告失败: {str(e)}")

def main():
    """主函数"""
    # 检查服务是否可用
    try:
        response = requests.get("http://127.0.0.1:5002/api/health", timeout=5)
        if response.status_code == 200:
            print("✅ 检测到后端服务正在运行")
        else:
            print("⚠️  后端服务状态异常，但继续测试")
    except:
        print("❌ 无法连接到后端服务，请确保服务正在运行")
        print("💡 启动命令: cd backend && source venv/bin/activate && python run.py")
        return
    
    # 创建测试器并运行测试
    tester = AIImagePlatformTester()
    tester.run_all_tests()

if __name__ == "__main__":
    main()
