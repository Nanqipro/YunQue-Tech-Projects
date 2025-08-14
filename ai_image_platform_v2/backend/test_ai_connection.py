#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI服务连接测试脚本
"""

import os
import sys

# 加载环境变量
try:
    from dotenv import load_dotenv
    # 加载项目根目录的.env文件
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    env_path = os.path.join(project_root, '.env')
    if os.path.exists(env_path):
        load_dotenv(env_path)
        print(f"已加载环境变量文件: {env_path}")
    else:
        print(f"环境变量文件不存在: {env_path}")
except ImportError:
    print("警告: python-dotenv 未安装，无法加载 .env 文件")

# 添加项目根目录到Python路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config.config import Config
from services.ai_service import AIService

def test_ai_connection():
    """
    测试AI服务连接
    """
    print("=== AI服务连接测试 ===")
    
    # 直接检查环境变量
    import os
    print(f"直接读取环境变量 QWEN_API_KEY: {os.environ.get('QWEN_API_KEY', '未设置')}")
    print(f"直接读取环境变量 AI_CONFIG_ENV: {os.environ.get('AI_CONFIG_ENV', '未设置')}")
    print()
    
    # 获取AI配置
    ai_config = Config.get_ai_config()
    print(f"AI配置环境: {Config.AI_CONFIG_ENV}")
    print(f"API密钥配置: {'已配置' if ai_config.QWEN_API_KEY else '未配置'}")
    print(f"API密钥前缀: {ai_config.QWEN_API_KEY[:10]}..." if ai_config.QWEN_API_KEY else "无API密钥")
    print(f"图像分析功能: {'启用' if ai_config.ENABLE_IMAGE_ANALYSIS else '禁用'}")
    print()
    
    # 测试AI服务连接
    print("=== 验证API连接 ===")
    ai_service = AIService()
    
    try:
        # 验证连接
        result = ai_service.validate_api_connection()
        print(f"连接测试结果: {result}")
        
        if result['success']:
            print("✅ AI服务连接成功")
        else:
            print(f"❌ AI服务连接失败: {result['message']}")
            
    except Exception as e:
        print(f"❌ 连接测试异常: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    test_ai_connection()