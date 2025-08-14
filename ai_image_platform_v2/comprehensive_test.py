#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI图像处理平台全面测试脚本
包含功能测试、边界测试、性能测试、安全测试
"""

import requests
import json
import time
import os
import base64
import threading
from datetime import datetime
import hashlib
import concurrent.futures

class ComprehensiveTester:
    def __init__(self, base_url="http://127.0.0.1:5002"):
        self.base_url = base_url
        self.api_url = f"{base_url}/api"
        self.test_results = []
        self.test_users = []
        
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
        
        status_icon = "✅" if status == "PASS" else "❌" if status == "FAIL" else "⚠️"
        print(f"{status_icon} {test_name}: {message}")
        
    def create_test_user(self, suffix=""):
        """创建测试用户"""
        timestamp = int(time.time())
        username = f"testuser_{timestamp}{suffix}"
        email = f"test{timestamp}{suffix}@example.com"
        
        user_data = {
            "username": username,
            "email": email,
            "password": "testpass123"
        }
        
        try:
            response = requests.post(
                f"{self.api_url}/users/register",
                json=user_data,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code in [200, 201]:
                data = response.json()
                if data.get('success'):
                    self.test_users.append(user_data)
                    return user_data
            return None
        except:
            return None
    
    def get_auth_token(self, user):
        """获取用户认证token"""
        try:
            response = requests.post(
                f"{self.api_url}/users/login",
                json={"username": user["username"], "password": user["password"]},
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    return data['data']['token']
            return None
        except:
            return None
    
    def test_concurrent_registrations(self):
        """测试并发用户注册"""
        def register_user(index):
            timestamp = int(time.time()) + index
            user_data = {
                "username": f"concurrent_user_{timestamp}",
                "email": f"concurrent{timestamp}@example.com",
                "password": "testpass123"
            }
            
            try:
                response = requests.post(
                    f"{self.api_url}/users/register",
                    json=user_data,
                    headers={'Content-Type': 'application/json'}
                )
                return response.status_code in [200, 201]
            except:
                return False
        
        # 并发创建10个用户
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(register_user, i) for i in range(10)]
            results = [future.result() for future in concurrent.futures.as_completed(futures)]
        
        success_count = sum(results)
        if success_count >= 8:  # 允许一定的失败率
            self.log_test("并发用户注册", "PASS", f"成功创建 {success_count}/10 个用户")
        else:
            self.log_test("并发用户注册", "FAIL", f"只成功创建 {success_count}/10 个用户")
    
    def test_duplicate_user_registration(self):
        """测试重复用户注册"""
        user = self.create_test_user("_duplicate")
        if not user:
            self.log_test("重复用户注册", "FAIL", "无法创建第一个用户")
            return
        
        # 尝试注册相同用户名
        try:
            response = requests.post(
                f"{self.api_url}/users/register",
                json=user,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 409:  # Conflict
                self.log_test("重复用户注册", "PASS", "正确拒绝重复用户名")
            else:
                self.log_test("重复用户注册", "FAIL", f"未正确处理重复注册，状态码: {response.status_code}")
        except Exception as e:
            self.log_test("重复用户注册", "FAIL", f"测试异常: {str(e)}")
    
    def test_invalid_login_attempts(self):
        """测试无效登录尝试"""
        invalid_logins = [
            {"username": "nonexistent", "password": "wrongpass"},
            {"username": "", "password": ""},
            {"username": "test", "password": ""},
            {"username": "", "password": "pass"},
        ]
        
        for login_data in invalid_logins:
            try:
                response = requests.post(
                    f"{self.api_url}/users/login",
                    json=login_data,
                    headers={'Content-Type': 'application/json'}
                )
                
                if response.status_code not in [200, 201]:
                    continue  # 这是期望的行为
                else:
                    self.log_test("无效登录测试", "FAIL", f"错误地允许了无效登录: {login_data}")
                    return
            except:
                continue
        
        self.log_test("无效登录测试", "PASS", "正确拒绝所有无效登录尝试")
    
    def test_large_file_upload(self):
        """测试大文件上传"""
        user = self.create_test_user("_filetest")
        if not user:
            self.log_test("大文件上传", "FAIL", "无法创建测试用户")
            return
            
        token = self.get_auth_token(user)
        if not token:
            self.log_test("大文件上传", "FAIL", "无法获取认证token")
            return
        
        # 创建一个大一点的测试图片 (约100KB)
        large_image_data = base64.b64decode(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
        ) * 1000  # 重复数据以增加大小
        
        try:
            with open("large_test.png", "wb") as f:
                f.write(large_image_data)
            
            with open("large_test.png", "rb") as f:
                files = {'file': ('large_test.png', f, 'image/png')}
                response = requests.post(
                    f"{self.api_url}/images/upload",
                    files=files,
                    headers={'Authorization': f'Bearer {token}'}
                )
            
            os.remove("large_test.png")
            
            if response.status_code in [200, 201]:
                self.log_test("大文件上传", "PASS", "大文件上传成功")
            else:
                self.log_test("大文件上传", "FAIL", f"大文件上传失败，状态码: {response.status_code}")
                
        except Exception as e:
            self.log_test("大文件上传", "FAIL", f"大文件上传异常: {str(e)}")
    
    def test_invalid_file_upload(self):
        """测试无效文件上传"""
        user = self.create_test_user("_invalidfile")
        if not user:
            self.log_test("无效文件上传", "FAIL", "无法创建测试用户")
            return
            
        token = self.get_auth_token(user)
        if not token:
            self.log_test("无效文件上传", "FAIL", "无法获取认证token")
            return
        
        # 测试上传非图片文件
        try:
            with open("test_text.txt", "w") as f:
                f.write("This is not an image file")
            
            with open("test_text.txt", "rb") as f:
                files = {'file': ('test_text.txt', f, 'text/plain')}
                response = requests.post(
                    f"{self.api_url}/images/upload",
                    files=files,
                    headers={'Authorization': f'Bearer {token}'}
                )
            
            os.remove("test_text.txt")
            
            if response.status_code == 400:  # Bad Request
                self.log_test("无效文件上传", "PASS", "正确拒绝非图片文件")
            else:
                self.log_test("无效文件上传", "FAIL", f"未正确拒绝非图片文件，状态码: {response.status_code}")
                
        except Exception as e:
            self.log_test("无效文件上传", "FAIL", f"无效文件上传测试异常: {str(e)}")
    
    def test_processing_performance(self):
        """测试图片处理性能"""
        user = self.create_test_user("_performance")
        if not user:
            self.log_test("处理性能测试", "FAIL", "无法创建测试用户")
            return
            
        token = self.get_auth_token(user)
        if not token:
            self.log_test("处理性能测试", "FAIL", "无法获取认证token")
            return
        
        # 先上传一张图片
        test_image_data = base64.b64decode(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
        )
        
        try:
            with open("perf_test.png", "wb") as f:
                f.write(test_image_data)
            
            with open("perf_test.png", "rb") as f:
                files = {'file': ('perf_test.png', f, 'image/png')}
                upload_response = requests.post(
                    f"{self.api_url}/images/upload",
                    files=files,
                    headers={'Authorization': f'Bearer {token}'}
                )
            
            os.remove("perf_test.png")
            
            if upload_response.status_code not in [200, 201]:
                self.log_test("处理性能测试", "FAIL", "图片上传失败")
                return
            
            image_id = upload_response.json()['data']['id']
            
            # 测试美颜处理性能
            start_time = time.time()
            beauty_response = requests.post(
                f"{self.api_url}/processing/beauty",
                json={
                    "image_id": image_id,
                    "smoothing": 0.3,
                    "whitening": 0.4,
                    "eye_enhancement": 0.6,
                    "lip_enhancement": 0.25,
                    "ai_mode": True
                },
                headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
            )
            processing_time = time.time() - start_time
            
            if beauty_response.status_code == 200 and processing_time < 30:  # 30秒内完成
                self.log_test("处理性能测试", "PASS", f"美颜处理耗时: {processing_time:.2f}秒")
            else:
                self.log_test("处理性能测试", "FAIL", f"美颜处理超时或失败，耗时: {processing_time:.2f}秒")
                
        except Exception as e:
            self.log_test("处理性能测试", "FAIL", f"性能测试异常: {str(e)}")
    
    def test_api_rate_limiting(self):
        """测试API限流"""
        user = self.create_test_user("_ratelimit")
        if not user:
            self.log_test("API限流测试", "SKIP", "无法创建测试用户")
            return
            
        token = self.get_auth_token(user)
        if not token:
            self.log_test("API限流测试", "SKIP", "无法获取认证token")
            return
        
        # 快速发送多个请求
        responses = []
        for i in range(20):
            try:
                response = requests.post(
                    f"{self.api_url}/users/verify-token",
                    headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
                )
                responses.append(response.status_code)
            except:
                continue
        
        # 检查是否有限流响应（429 Too Many Requests）
        if 429 in responses:
            self.log_test("API限流测试", "PASS", "API正确实施了限流")
        else:
            self.log_test("API限流测试", "WARNING", "未检测到API限流机制")
    
    def test_error_response_format(self):
        """测试错误响应格式"""
        # 测试无效JSON
        try:
            response = requests.post(
                f"{self.api_url}/users/login",
                data="invalid json",
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code >= 400:
                try:
                    error_data = response.json()
                    if 'message' in error_data or 'error' in error_data:
                        self.log_test("错误响应格式", "PASS", "错误响应格式正确")
                    else:
                        self.log_test("错误响应格式", "WARNING", "错误响应缺少错误信息")
                except:
                    self.log_test("错误响应格式", "WARNING", "错误响应不是有效JSON")
            else:
                self.log_test("错误响应格式", "FAIL", "未正确处理无效请求")
                
        except Exception as e:
            self.log_test("错误响应格式", "FAIL", f"测试异常: {str(e)}")
    
    def test_token_expiration(self):
        """测试token过期处理"""
        # 创建一个假的过期token
        fake_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE2MzQwNDU4MDB9.invalid"
        
        try:
            response = requests.post(
                f"{self.api_url}/users/verify-token",
                headers={'Authorization': f'Bearer {fake_token}', 'Content-Type': 'application/json'}
            )
            
            if response.status_code == 401:
                self.log_test("Token过期处理", "PASS", "正确处理过期token")
            else:
                self.log_test("Token过期处理", "FAIL", f"未正确处理过期token，状态码: {response.status_code}")
                
        except Exception as e:
            self.log_test("Token过期处理", "FAIL", f"测试异常: {str(e)}")
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始AI图像处理平台全面测试")
        print("=" * 70)
        
        # 基础功能测试
        print("\n📋 基础功能测试")
        print("-" * 30)
        self.test_duplicate_user_registration()
        self.test_invalid_login_attempts()
        
        # 文件处理测试
        print("\n📁 文件处理测试")
        print("-" * 30)
        self.test_large_file_upload()
        self.test_invalid_file_upload()
        
        # 性能测试
        print("\n⚡ 性能测试")
        print("-" * 30)
        self.test_processing_performance()
        self.test_concurrent_registrations()
        
        # 安全测试
        print("\n🔒 安全测试")
        print("-" * 30)
        self.test_api_rate_limiting()
        self.test_token_expiration()
        
        # 错误处理测试
        print("\n❌ 错误处理测试")
        print("-" * 30)
        self.test_error_response_format()
        
        # 生成测试报告
        self.generate_comprehensive_report()
    
    def generate_comprehensive_report(self):
        """生成全面测试报告"""
        print("\n" + "=" * 70)
        print("📊 全面测试报告")
        print("=" * 70)
        
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
        
        if total_tests > 0:
            success_rate = (passed_tests / total_tests) * 100
            print(f"成功率: {success_rate:.1f}%")
        
        # 按类别分析
        categories = {
            "基础功能": ["重复用户注册", "无效登录"],
            "文件处理": ["大文件上传", "无效文件上传"],
            "性能": ["处理性能", "并发"],
            "安全": ["API限流", "Token过期"],
            "错误处理": ["错误响应格式"]
        }
        
        print(f"\n📋 分类测试结果:")
        for category, keywords in categories.items():
            category_results = [r for r in self.test_results if any(kw in r['test_name'] for kw in keywords)]
            if category_results:
                passed = len([r for r in category_results if r['status'] == 'PASS'])
                total = len(category_results)
                print(f"  {category}: {passed}/{total} 通过")
        
        # 问题总结
        failed_results = [r for r in self.test_results if r['status'] == 'FAIL']
        if failed_results:
            print(f"\n❌ 需要关注的问题:")
            for result in failed_results:
                print(f"  - {result['test_name']}: {result['message']}")
        
        warning_results = [r for r in self.test_results if r['status'] == 'WARNING']
        if warning_results:
            print(f"\n⚠️  建议改进的地方:")
            for result in warning_results:
                print(f"  - {result['test_name']}: {result['message']}")
        
        # 总体评估
        print(f"\n🎯 总体评估:")
        if failed_tests == 0 and warning_tests <= 3:
            print("  🎉 平台功能完善，质量优秀！")
        elif failed_tests <= 2 and warning_tests <= 5:
            print("  ✅ 平台功能良好，少数地方需要优化")
        else:
            print("  ⚠️  平台需要进一步完善和优化")
        
        # 保存详细报告
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = f"comprehensive_report_{timestamp}.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(self.test_results, f, ensure_ascii=False, indent=2)
        
        print(f"\n📄 详细测试报告已保存到: {report_file}")

def main():
    """主函数"""
    print("🔍 检查服务状态...")
    try:
        response = requests.get("http://127.0.0.1:5002/api/health", timeout=5)
        print("✅ 后端服务可访问")
    except:
        print("❌ 无法连接到后端服务")
        print("💡 请确保后端服务正在运行:")
        print("   cd backend && source venv/bin/activate && python run.py")
        return
    
    # 运行全面测试
    tester = ComprehensiveTester()
    tester.run_all_tests()

if __name__ == "__main__":
    main()
