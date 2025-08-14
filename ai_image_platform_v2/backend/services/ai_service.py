# -*- coding: utf-8 -*-
"""
AI服务模块
集成通义千问大模型，提供图像分析和智能处理建议
"""

import requests
import json
import base64
import time
from typing import Dict, Any, Optional, List
from PIL import Image
import io
import os
from config.config import Config

class AIService:
    """AI服务类，处理与通义千问大模型的交互"""
    
    def __init__(self):
        self.ai_config = Config.get_ai_config()
        self.qwen_config = self.ai_config.get_qwen_config()
        self.qwen_vl_config = self.ai_config.get_qwen_vl_config()
        self.prompts = self.ai_config.get_image_analysis_prompts()
    
    def _encode_image_to_base64(self, image_path: str) -> str:
        """将图片编码为base64格式"""
        try:
            with open(image_path, 'rb') as image_file:
                image_data = image_file.read()
                return base64.b64encode(image_data).decode('utf-8')
        except Exception as e:
            raise Exception(f"图片编码失败: {str(e)}")
    
    def _make_request(self, url: str, headers: Dict, data: Dict, max_retries: int = 3) -> Dict:
        """发送HTTP请求，支持重试"""
        for attempt in range(max_retries):
            try:
                response = requests.post(
                    url,
                    headers=headers,
                    json=data,
                    timeout=self.qwen_config['timeout']
                )
                
                if response.status_code == 200:
                    return response.json()
                else:
                    error_msg = f"API请求失败，状态码: {response.status_code}, 响应: {response.text}"
                    if attempt == max_retries - 1:
                        raise Exception(error_msg)
                    print(f"请求失败，正在重试... (尝试 {attempt + 1}/{max_retries})")
                    
            except requests.exceptions.Timeout:
                if attempt == max_retries - 1:
                    raise Exception("请求超时")
                print(f"请求超时，正在重试... (尝试 {attempt + 1}/{max_retries})")
                
            except requests.exceptions.RequestException as e:
                if attempt == max_retries - 1:
                    raise Exception(f"请求异常: {str(e)}")
                print(f"请求异常，正在重试... (尝试 {attempt + 1}/{max_retries})")
            
            # 等待后重试
            if attempt < max_retries - 1:
                time.sleep(self.qwen_config['retry_delay'])
        
        raise Exception("所有重试都失败了")
    
    def analyze_image(self, image_path: str, analysis_type: str = 'general_analysis') -> Dict[str, Any]:
        """分析图片内容"""
        try:
            if not self.ai_config.ENABLE_IMAGE_ANALYSIS:
                return {
                    'success': False,
                    'message': 'AI图像分析功能已禁用',
                    'analysis': ''
                }
            
            if not self.qwen_vl_config['api_key']:
                return {
                    'success': False,
                    'message': '未配置API密钥',
                    'analysis': ''
                }
            
            # 编码图片
            image_base64 = self._encode_image_to_base64(image_path)
            
            # 获取分析提示词
            prompt = self.prompts.get(analysis_type, self.prompts['general_analysis'])
            
            # 构建请求数据
            headers = {
                'Authorization': f'Bearer {self.qwen_vl_config["api_key"]}',
                'Content-Type': 'application/json'
            }
            
            data = {
                'model': self.qwen_vl_config['model_name'],
                'input': {
                    'messages': [
                        {
                            'role': 'user',
                            'content': [
                                {
                                    'image': f'data:image/jpeg;base64,{image_base64}'
                                },
                                {
                                    'text': prompt
                                }
                            ]
                        }
                    ]
                },
                'parameters': {
                    'temperature': self.qwen_vl_config['temperature'],
                    'max_tokens': self.qwen_vl_config['max_tokens'],
                    'top_p': self.qwen_vl_config['top_p']
                }
            }
            
            # 发送请求
            response = self._make_request(
                self.qwen_vl_config['api_url'],
                headers,
                data,
                self.qwen_vl_config['max_retries']
            )
            
            # 解析响应
            # 尝试不同的响应格式
            analysis_result = None
            
            # 格式1: output.text (文本模型)
            if 'output' in response and 'text' in response['output']:
                analysis_result = response['output']['text']
            # 格式2: output.choices[0].message.content (视觉模型)
            elif 'output' in response and 'choices' in response['output'] and len(response['output']['choices']) > 0:
                choice = response['output']['choices'][0]
                if 'message' in choice and 'content' in choice['message']:
                    analysis_result = choice['message']['content']
            # 格式3: choices[0].message.content (直接在根级别)
            elif 'choices' in response and len(response['choices']) > 0:
                choice = response['choices'][0]
                if 'message' in choice and 'content' in choice['message']:
                    analysis_result = choice['message']['content']
            # 格式4: 直接在choices中查找content
            elif 'choices' in response and len(response['choices']) > 0:
                choice = response['choices'][0]
                if 'content' in choice:
                    analysis_result = choice['content']
            
            if analysis_result:
                return {
                    'success': True,
                    'message': '分析完成',
                    'analysis': analysis_result,
                    'analysis_type': analysis_type
                }
            else:
                # 添加更详细的调试信息
                debug_info = {
                    'response_keys': list(response.keys()) if isinstance(response, dict) else 'not_dict',
                    'has_choices': 'choices' in response if isinstance(response, dict) else False,
                    'choices_length': len(response.get('choices', [])) if isinstance(response, dict) else 0
                }
                
                if isinstance(response, dict) and 'choices' in response and len(response['choices']) > 0:
                    choice = response['choices'][0]
                    debug_info['first_choice_keys'] = list(choice.keys()) if isinstance(choice, dict) else 'not_dict'
                    if isinstance(choice, dict) and 'message' in choice:
                        debug_info['message_keys'] = list(choice['message'].keys()) if isinstance(choice['message'], dict) else 'not_dict'
                
                return {
                    'success': False,
                    'message': '响应格式异常',
                    'analysis': '',
                    'raw_response': response,
                    'debug_info': debug_info
                }
                
        except Exception as e:
            return {
                'success': False,
                'message': f'图像分析失败: {str(e)}',
                'analysis': ''
            }
    
    def get_beauty_suggestions(self, image_path: str) -> Dict[str, Any]:
        """获取美颜建议"""
        return self.analyze_image(image_path, 'beauty_analysis')
    
    def get_style_recommendations(self, image_path: str) -> Dict[str, Any]:
        """获取风格推荐"""
        return self.analyze_image(image_path, 'style_recommendation')
    
    def get_composition_analysis(self, image_path: str) -> Dict[str, Any]:
        """获取构图分析"""
        return self.analyze_image(image_path, 'composition_analysis')
    
    def get_ai_beauty_processing(self, image_path: str, beauty_params: Dict[str, Any]) -> Dict[str, Any]:
        """AI智能美颜处理建议"""
        try:
            if not self.ai_config.ENABLE_IMAGE_ANALYSIS:
                return {
                    'success': False,
                    'message': 'AI功能已禁用',
                    'suggestions': {}
                }
            
            # 编码图片
            image_base64 = self._encode_image_to_base64(image_path)
            
            # 构建增强版美颜分析提示词
            beauty_prompt = f"""
作为专业的AI美颜分析师，请深度分析这张人像照片，并基于以下用户参数提供智能优化建议：

用户当前设置：
- 磨皮强度: {beauty_params.get('smoothing', 50)}%
- 美白强度: {beauty_params.get('whitening', 30)}%
- 眼部增强: {beauty_params.get('eye_enhancement', 20)}%
- 唇部增强: {beauty_params.get('lip_enhancement', 15)}%

请进行以下专业分析：

1. **人脸特征深度分析**：
   - 肤质状态（毛孔、纹理、瑕疵）
   - 肤色分析（色调、均匀度、亮度）
   - 五官特点（眼部形状、唇部特征、面部轮廓）
   - 光线条件（明暗分布、阴影处理需求）

2. **智能参数优化**：
   - 基于肤质状态调整磨皮强度
   - 根据肤色特点优化美白参数
   - 针对眼部特征定制增强方案
   - 根据唇部条件调整增强强度

3. **处理策略建议**：
   - 重点处理区域识别
   - 保护区域标识
   - 处理顺序建议
   - 效果预期描述

请严格按照以下JSON格式返回分析结果：
{{
  "face_analysis": {{
    "skin_condition": "肤质详细描述",
    "skin_tone": "肤色分析",
    "facial_features": "五官特点分析",
    "lighting_assessment": "光线条件评估"
  }},
  "optimization_suggestions": {{
    "smoothing_advice": "磨皮优化建议",
    "whitening_advice": "美白优化建议",
    "eye_enhancement_advice": "眼部增强建议",
    "lip_enhancement_advice": "唇部增强建议"
  }},
  "recommended_params": {{
    "smoothing": 数值(0-100),
    "whitening": 数值(0-100),
    "eye_enhancement": 数值(0-100),
    "lip_enhancement": 数值(0-100)
  }},
  "processing_strategy": {{
    "focus_areas": ["重点处理区域列表"],
    "protection_areas": ["需要保护的区域"],
    "processing_order": ["处理步骤顺序"],
    "expected_effect": "预期效果描述"
  }},
  "confidence_score": 数值(0-1),
  "additional_tips": "额外处理建议"
}}

注意：参数值应在0-100范围内，confidence_score表示分析的可信度。
"""
            
            # 构建请求数据
            headers = {
                'Authorization': f'Bearer {self.qwen_vl_config["api_key"]}',
                'Content-Type': 'application/json'
            }
            
            data = {
                'model': self.qwen_vl_config['model_name'],
                'input': {
                    'messages': [
                        {
                            'role': 'user',
                            'content': [
                                {
                                    'image': f'data:image/jpeg;base64,{image_base64}'
                                },
                                {
                                    'text': beauty_prompt
                                }
                            ]
                        }
                    ]
                },
                'parameters': {
                    'temperature': 0.3,  # 降低随机性，获得更一致的建议
                    'max_tokens': 1000,
                    'top_p': 0.8
                }
            }
            
            # 发送请求
            response = self._make_request(
                self.qwen_vl_config['api_url'],
                headers,
                data,
                self.qwen_vl_config['max_retries']
            )
            
            # 解析响应
            analysis_result = None
            if 'output' in response and 'choices' in response['output'] and len(response['output']['choices']) > 0:
                choice = response['output']['choices'][0]
                if 'message' in choice and 'content' in choice['message']:
                    analysis_result = choice['message']['content']
            
            if analysis_result:
                return {
                    'success': True,
                    'message': 'AI美颜分析完成',
                    'ai_suggestions': analysis_result,
                    'original_params': beauty_params
                }
            else:
                return {
                    'success': False,
                    'message': '响应格式异常',
                    'suggestions': {}
                }
                
        except Exception as e:
            return {
                'success': False,
                'message': f'AI美颜分析失败: {str(e)}',
                'suggestions': {}
            }
    
    def get_ai_id_photo_processing(self, image_path: str, id_params: Dict[str, Any]) -> Dict[str, Any]:
        """AI智能证件照生成建议"""
        try:
            if not self.ai_config.ENABLE_IMAGE_ANALYSIS:
                return {
                    'success': False,
                    'message': 'AI功能已禁用',
                    'suggestions': {}
                }
            
            # 编码图片
            image_base64 = self._encode_image_to_base64(image_path)
            
            # 构建证件照分析提示词
            id_photo_prompt = f"""
请分析这张照片，并根据以下证件照要求提供智能处理建议：
- 照片类型: {id_params.get('photo_type', '1_inch')}
- 背景颜色: {id_params.get('background_color', 'white')}
- 自动裁剪: {id_params.get('auto_crop', True)}
- 美颜强度: {id_params.get('beauty_strength', 30)}

请提供以下分析：
1. 人脸位置和角度分析
2. 证件照标准符合度评估
3. 裁剪建议（头部位置、比例）
4. 光线和曝光优化建议
5. 背景处理建议

请以JSON格式返回结果，包含：
{{
  "face_position_analysis": "人脸位置分析",
  "compliance_assessment": "标准符合度评估",
  "cropping_suggestions": {{
    "recommended_crop_area": "建议裁剪区域",
    "head_position": "头部位置调整建议"
  }},
  "lighting_optimization": "光线优化建议",
  "background_processing": "背景处理建议",
  "overall_quality_score": "整体质量评分(1-10)"
}}
"""
            
            # 构建请求数据
            headers = {
                'Authorization': f'Bearer {self.qwen_vl_config["api_key"]}',
                'Content-Type': 'application/json'
            }
            
            data = {
                'model': self.qwen_vl_config['model_name'],
                'input': {
                    'messages': [
                        {
                            'role': 'user',
                            'content': [
                                {
                                    'image': f'data:image/jpeg;base64,{image_base64}'
                                },
                                {
                                    'text': id_photo_prompt
                                }
                            ]
                        }
                    ]
                },
                'parameters': {
                    'temperature': 0.3,
                    'max_tokens': 1200,
                    'top_p': 0.8
                }
            }
            
            # 发送请求
            response = self._make_request(
                self.qwen_vl_config['api_url'],
                headers,
                data,
                self.qwen_vl_config['max_retries']
            )
            
            # 解析响应
            analysis_result = None
            if 'output' in response and 'choices' in response['output'] and len(response['output']['choices']) > 0:
                choice = response['output']['choices'][0]
                if 'message' in choice and 'content' in choice['message']:
                    analysis_result = choice['message']['content']
            
            if analysis_result:
                return {
                    'success': True,
                    'message': 'AI证件照分析完成',
                    'ai_suggestions': analysis_result,
                    'original_params': id_params
                }
            else:
                return {
                    'success': False,
                    'message': '响应格式异常',
                    'suggestions': {}
                }
                
        except Exception as e:
            return {
                'success': False,
                'message': f'AI证件照分析失败: {str(e)}',
                'suggestions': {}
            }
    
    def generate_processing_suggestions(self, image_path: str) -> Dict[str, Any]:
        """生成综合处理建议"""
        try:
            if not self.ai_config.ENABLE_SMART_ENHANCEMENT:
                return {
                    'success': False,
                    'message': 'AI智能增强功能已禁用',
                    'suggestions': []
                }
            
            # 进行综合分析
            general_analysis = self.analyze_image(image_path, 'general_analysis')
            
            if not general_analysis['success']:
                return general_analysis
            
            # 基于分析结果生成具体的处理建议
            suggestions = self._parse_suggestions_from_analysis(general_analysis['analysis'])
            
            return {
                'success': True,
                'message': '建议生成完成',
                'suggestions': suggestions,
                'analysis': general_analysis['analysis']
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'建议生成失败: {str(e)}',
                'suggestions': []
            }
    
    def _parse_suggestions_from_analysis(self, analysis_text: str) -> List[Dict[str, Any]]:
        """从分析文本中解析出具体的处理建议"""
        suggestions = []
        
        # 基于关键词匹配生成建议
        analysis_lower = analysis_text.lower()
        
        # 美颜相关建议
        if any(keyword in analysis_lower for keyword in ['人像', '肖像', '脸部', '皮肤']):
            suggestions.append({
                'type': 'beauty',
                'title': '美颜处理',
                'description': '检测到人像，建议进行美颜处理',
                'params': {
                    'smoothing': 30,
                    'whitening': 20,
                    'eye_enhancement': 15,
                    'lip_enhancement': 10
                },
                'priority': 'high'
            })
        
        # 色彩调整建议
        if any(keyword in analysis_lower for keyword in ['暗', '亮度', '对比度', '饱和度']):
            suggestions.append({
                'type': 'color_adjust',
                'title': '色彩调整',
                'description': '建议调整图片的色彩参数',
                'params': {
                    'brightness': 10,
                    'contrast': 15,
                    'saturation': 5
                },
                'priority': 'medium'
            })
        
        # 滤镜建议
        if any(keyword in analysis_lower for keyword in ['风格', '艺术', '复古', '现代']):
            filter_type = 'vintage' if '复古' in analysis_lower else 'cool'
            suggestions.append({
                'type': 'filter',
                'title': '滤镜效果',
                'description': f'建议应用{filter_type}滤镜',
                'params': {
                    'filter_type': filter_type,
                    'intensity': 60
                },
                'priority': 'low'
            })
        
        # 如果没有特定建议，提供通用建议
        if not suggestions:
            suggestions.append({
                'type': 'color_adjust',
                'title': '基础优化',
                'description': '建议进行基础的色彩优化',
                'params': {
                    'brightness': 5,
                    'contrast': 10,
                    'saturation': 5
                },
                'priority': 'medium'
            })
        
        return suggestions
    
    def validate_api_connection(self) -> Dict[str, Any]:
        """验证API连接"""
        try:
            if not self.qwen_config['api_key']:
                return {
                    'success': False,
                    'message': '未配置API密钥'
                }
            
            # 发送简单的测试请求
            headers = {
                'Authorization': f'Bearer {self.qwen_config["api_key"]}',
                'Content-Type': 'application/json'
            }
            
            data = {
                'model': self.qwen_config['model_name'],
                'input': {
                    'messages': [
                        {
                            'role': 'user',
                            'content': '你好，请回复"连接成功"'
                        }
                    ]
                },
                'parameters': {
                    'max_tokens': 10
                }
            }
            
            response = self._make_request(
                self.qwen_config['api_url'],
                headers,
                data,
                1  # 只尝试一次
            )
            
            return {
                'success': True,
                'message': 'API连接正常',
                'response': response
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'API连接失败: {str(e)}'
            }

# 全局AI服务实例
ai_service = AIService()