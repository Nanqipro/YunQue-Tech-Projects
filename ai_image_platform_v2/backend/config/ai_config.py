# -*- coding: utf-8 -*-
"""
AI模型配置文件
支持通义千问等大模型的配置
"""

import os
from typing import Dict, Any

class AIModelConfig:
    """AI模型基础配置类"""
    
    # 通义千问配置
    QWEN_API_KEY = os.environ.get('QWEN_API_KEY') or ''
    QWEN_API_URL = os.environ.get('QWEN_API_URL') or 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation'
    QWEN_MODEL_NAME = os.environ.get('QWEN_MODEL_NAME') or 'qwen-turbo'
    
    # 图像理解模型配置
    QWEN_VL_MODEL_NAME = os.environ.get('QWEN_VL_MODEL_NAME') or 'qwen-vl-plus'
    QWEN_VL_API_URL = os.environ.get('QWEN_VL_API_URL') or 'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation'
    
    # 模型参数配置
    DEFAULT_TEMPERATURE = 0.7
    DEFAULT_MAX_TOKENS = 2000
    DEFAULT_TOP_P = 0.8
    
    # 请求配置
    REQUEST_TIMEOUT = 30  # 秒
    MAX_RETRIES = 3
    RETRY_DELAY = 1  # 秒
    
    # 图像处理相关配置
    SUPPORTED_IMAGE_FORMATS = ['jpg', 'jpeg', 'png', 'bmp', 'webp']
    MAX_IMAGE_SIZE_MB = 10
    IMAGE_QUALITY_THRESHOLD = 0.8
    
    # AI功能开关
    ENABLE_IMAGE_ANALYSIS = True
    ENABLE_SMART_ENHANCEMENT = True
    ENABLE_STYLE_TRANSFER = True
    ENABLE_OBJECT_DETECTION = True
    ENABLE_FACE_RECOGNITION = True
    
    @classmethod
    def get_qwen_config(cls) -> Dict[str, Any]:
        """获取通义千问配置"""
        return {
            'api_key': cls.QWEN_API_KEY,
            'api_url': cls.QWEN_API_URL,
            'model_name': cls.QWEN_MODEL_NAME,
            'temperature': cls.DEFAULT_TEMPERATURE,
            'max_tokens': cls.DEFAULT_MAX_TOKENS,
            'top_p': cls.DEFAULT_TOP_P,
            'timeout': cls.REQUEST_TIMEOUT,
            'max_retries': cls.MAX_RETRIES,
            'retry_delay': cls.RETRY_DELAY
        }
    
    @classmethod
    def get_qwen_vl_config(cls) -> Dict[str, Any]:
        """获取通义千问视觉模型配置"""
        return {
            'api_key': cls.QWEN_API_KEY,
            'api_url': cls.QWEN_VL_API_URL,
            'model_name': cls.QWEN_VL_MODEL_NAME,
            'temperature': cls.DEFAULT_TEMPERATURE,
            'max_tokens': cls.DEFAULT_MAX_TOKENS,
            'top_p': cls.DEFAULT_TOP_P,
            'timeout': cls.REQUEST_TIMEOUT,
            'max_retries': cls.MAX_RETRIES,
            'retry_delay': cls.RETRY_DELAY
        }
    
    @classmethod
    def validate_config(cls) -> bool:
        """验证配置是否完整"""
        if not cls.QWEN_API_KEY:
            print("警告: QWEN_API_KEY 未设置")
            return False
        return True
    
    @classmethod
    def get_image_analysis_prompts(cls) -> Dict[str, str]:
        """获取图像分析提示词模板"""
        return {
            'general_analysis': """
请分析这张图片，包括以下方面：
1. 图片内容描述
2. 图片质量评估
3. 色彩分析
4. 构图分析
5. 改进建议
请用中文回答，格式清晰。
""",
            'beauty_analysis': """
请分析这张人像照片，提供美颜建议：
1. 皮肤状态分析
2. 五官特点
3. 光线和角度评估
4. 美颜参数建议（磨皮、美白、眼部增强等）
5. 整体优化建议
请用中文回答，提供具体的参数建议。
""",
            'style_recommendation': """
请为这张图片推荐合适的滤镜和风格：
1. 图片风格分析
2. 适合的滤镜类型
3. 色调调整建议
4. 艺术风格建议
5. 后期处理建议
请用中文回答，提供具体的处理建议。
""",
            'composition_analysis': """
请分析这张图片的构图：
1. 构图类型识别
2. 视觉焦点分析
3. 平衡性评估
4. 裁剪建议
5. 构图优化建议
请用中文回答，提供具体的改进建议。
"""
        }

class DevelopmentAIConfig(AIModelConfig):
    """开发环境AI配置"""
    # 开发环境可以使用较低的参数以节省成本
    DEFAULT_TEMPERATURE = 0.5
    DEFAULT_MAX_TOKENS = 1000
    REQUEST_TIMEOUT = 20

class ProductionAIConfig(AIModelConfig):
    """生产环境AI配置"""
    # 生产环境使用更稳定的参数
    DEFAULT_TEMPERATURE = 0.7
    DEFAULT_MAX_TOKENS = 2000
    REQUEST_TIMEOUT = 30
    MAX_RETRIES = 5

class TestingAIConfig(AIModelConfig):
    """测试环境AI配置"""
    # 测试环境禁用所有AI功能
    ENABLE_IMAGE_ANALYSIS = False
    ENABLE_SMART_ENHANCEMENT = False
    ENABLE_STYLE_TRANSFER = False
    ENABLE_OBJECT_DETECTION = False
    ENABLE_FACE_RECOGNITION = False
    
    # 使用模拟的API密钥
    QWEN_API_KEY = 'test_api_key'

# AI配置字典
ai_config = {
    'development': DevelopmentAIConfig,
    'production': ProductionAIConfig,
    'testing': TestingAIConfig,
    'default': DevelopmentAIConfig
}