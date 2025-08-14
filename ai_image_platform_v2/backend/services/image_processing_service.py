import cv2
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter
import os
import uuid
from datetime import datetime
from services.ai_service import AIService
import json
import math
from rembg import remove, new_session

class ImageProcessingService:
    """图片处理服务类"""
    
    @staticmethod
    def _get_output_path(user_id, tool_name, extension='.jpg'):
        """生成输出文件路径"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{tool_name}_{timestamp}_{uuid.uuid4().hex[:8]}{extension}"
        
        # 处理user_id为None的情况
        user_folder = str(user_id) if user_id is not None else 'anonymous'
        
        # 获取当前工作目录的绝对路径
        base_dir = os.path.abspath(os.getcwd())
        output_dir = os.path.join(base_dir, 'static', 'uploads', 'processed', user_folder)
        os.makedirs(output_dir, exist_ok=True)
        
        return os.path.join(output_dir, filename)
    
    @staticmethod
    def apply_beauty(image_path, params, user_id):
        """应用AI智能美颜效果 - 增强版"""
        try:
            # 读取图片
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("无法读取图片文件")
            
            # 转换为RGB
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            
            # 使用用户提供的参数，确保有默认值（0-1范围）
            final_params = {
                'smoothing': params.get('smoothing', 0.6),
                'whitening': params.get('whitening', 0.55),
                'eye_enhancement': params.get('eye_enhancement', 0.65),
                'lip_enhancement': params.get('lip_enhancement', 0.45)
            }
            
            # AI智能分析和参数优化（暂时禁用以避免错误）
            ai_result = {'success': False, 'message': 'AI功能已禁用以提升稳定性'}
            # 注释掉AI服务调用，避免初始化错误
            # try:
            #     # 初始化AI服务
            #     ai_service = AIService()
            #     
            #     # 快速检查AI配置
            #     if hasattr(ai_service, 'ai_config') and ai_service.ai_config.ENABLE_IMAGE_ANALYSIS:
            #         # 获取AI美颜建议
            #         ai_result = ai_service.get_ai_beauty_processing(image_path, params)
            # except Exception as e:
            #     # AI服务调用失败，继续使用默认参数
            #     print(f"AI服务调用失败，使用默认参数: {str(e)}")
            #     ai_result = {'success': False, 'message': f'AI服务不可用: {str(e)}'}
            
            # 人脸检测和区域分割
            face_regions = ImageProcessingService._detect_face_regions(img_rgb)
            
            # 智能磨皮处理（基于人脸区域）
            smoothing = final_params.get('smoothing', 0.5) * 100  # 转换为0-100范围
            if smoothing > 0:
                img_rgb = ImageProcessingService._apply_advanced_skin_smoothing(img_rgb, smoothing, face_regions)
            
            # 智能美白处理（保护眼部和唇部）
            whitening = final_params.get('whitening', 0.3) * 100  # 转换为0-100范围
            if whitening > 0:
                img_rgb = ImageProcessingService._apply_intelligent_whitening(img_rgb, whitening, face_regions)
            
            # 精准眼部增强
            eye_enhancement = final_params.get('eye_enhancement', 0.2) * 100  # 转换为0-100范围
            if eye_enhancement > 0:
                img_rgb = ImageProcessingService._enhance_eyes_advanced(img_rgb, eye_enhancement, face_regions)
            
            # 精准唇部增强
            lip_enhancement = final_params.get('lip_enhancement', 0.15) * 100  # 转换为0-100范围
            if lip_enhancement > 0:
                img_rgb = ImageProcessingService._enhance_lips_advanced(img_rgb, lip_enhancement, face_regions)
            
            # 整体色彩和谐调整
            img_rgb = ImageProcessingService._apply_color_harmony(img_rgb)
            
            # 细节锐化和噪声抑制
            img_rgb = ImageProcessingService._apply_detail_enhancement(img_rgb)
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(user_id, 'ai_beauty')
            
            # 转换回BGR并保存
            img_bgr = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)
            cv2.imwrite(output_path, img_bgr, [cv2.IMWRITE_JPEG_QUALITY, 98])  # 提高保存质量
            
            # 返回处理结果和AI建议
            result = {
                'output_path': output_path,
                'ai_analysis': ai_result,
                'final_params': final_params,
                'original_params': params,
                'face_detected': len(face_regions) > 0
            }
            
            return output_path
            
        except Exception as e:
            raise Exception(f"AI美颜处理失败: {str(e)}")
    
    @staticmethod
    def _apply_skin_smoothing(img, strength):
        """高级磨皮处理"""
        strength_factor = strength / 100.0
        
        # 多层磨皮处理
        # 第一层：双边滤波
        d1 = max(5, int(15 * strength_factor))
        sigma_color1 = max(40, int(120 * strength_factor))
        sigma_space1 = max(40, int(120 * strength_factor))
        smoothed1 = cv2.bilateralFilter(img, d1, sigma_color1, sigma_space1)
        
        # 第二层：高斯模糊
        kernel_size = max(3, int(7 * strength_factor))
        if kernel_size % 2 == 0:
            kernel_size += 1
        smoothed2 = cv2.GaussianBlur(smoothed1, (kernel_size, kernel_size), 0)
        
        # 第三层：表面模糊（保边缘）
        smoothed3 = cv2.edgePreservingFilter(smoothed2, flags=1, sigma_s=50, sigma_r=0.4)
        
        # 多层混合 - 增强效果
        alpha1 = 0.6 * strength_factor
        alpha2 = 0.4 * strength_factor
        alpha3 = 0.3 * strength_factor
        
        result = cv2.addWeighted(img, 1 - alpha1, smoothed1, alpha1, 0)
        result = cv2.addWeighted(result, 1 - alpha2, smoothed2, alpha2, 0)
        result = cv2.addWeighted(result, 1 - alpha3, smoothed3, alpha3, 0)
        
        return result
    
    @staticmethod
    def _detect_face_regions(img):
        """检测人脸区域和关键点"""
        try:
            # 使用OpenCV的人脸检测器
            face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
            eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')
            mouth_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_smile.xml')
            
            # 转换为灰度图进行检测
            gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
            
            # 检测人脸
            faces = face_cascade.detectMultiScale(gray, 1.1, 4)
            
            face_regions = []
            for (x, y, w, h) in faces:
                face_region = {
                    'face': (x, y, w, h),
                    'eyes': [],
                    'mouth': []
                }
                
                # 在人脸区域内检测眼部
                roi_gray = gray[y:y+h, x:x+w]
                eyes = eye_cascade.detectMultiScale(roi_gray, 1.1, 3)
                for (ex, ey, ew, eh) in eyes:
                    face_region['eyes'].append((x+ex, y+ey, ew, eh))
                
                # 在人脸下半部分检测嘴部
                mouth_roi = roi_gray[int(h*0.5):h, 0:w]
                mouths = mouth_cascade.detectMultiScale(mouth_roi, 1.1, 3)
                for (mx, my, mw, mh) in mouths:
                    face_region['mouth'].append((x+mx, y+int(h*0.5)+my, mw, mh))
                
                face_regions.append(face_region)
            
            return face_regions
        except Exception as e:
            print(f"人脸检测失败: {str(e)}")
            return []
    
    @staticmethod
    def _apply_advanced_skin_smoothing(img, strength, face_regions):
        """高级智能磨皮处理"""
        strength_factor = strength / 100.0
        result = img.copy()
        
        if not face_regions:
            # 如果没有检测到人脸，使用全图处理
            return ImageProcessingService._apply_skin_smoothing(img, strength)
        
        for face_region in face_regions:
            x, y, w, h = face_region['face']
            
            # 扩展处理区域，包含颈部
            expand_ratio = 0.3
            ex = max(0, int(x - w * expand_ratio))
            ey = max(0, int(y - h * expand_ratio * 0.5))
            ew = min(img.shape[1] - ex, int(w * (1 + 2 * expand_ratio)))
            eh = min(img.shape[0] - ey, int(h * (1 + expand_ratio)))
            
            # 提取人脸区域
            face_img = result[ey:ey+eh, ex:ex+ew]
            
            # 优化的多层次磨皮处理，减少过度效果
            # 第一层：温和的双边滤波
            d1 = max(5, int(15 * strength_factor))  # 减小滤波窗口
            sigma_color1 = max(40, int(100 * strength_factor))  # 降低颜色相似性阈值
            sigma_space1 = max(40, int(100 * strength_factor))  # 降低空间距离阈值
            smoothed1 = cv2.bilateralFilter(face_img, d1, sigma_color1, sigma_space1)
            
            # 第二层：轻微的边缘保护滤波
            smoothed2 = cv2.edgePreservingFilter(smoothed1, flags=2, sigma_s=50, sigma_r=0.2)
            
            # 第三层：非常轻微的高斯模糊
            kernel_size = max(3, int(7 * strength_factor))  # 减小模糊核大小
            if kernel_size % 2 == 0:
                kernel_size += 1
            smoothed3 = cv2.GaussianBlur(smoothed2, (kernel_size, kernel_size), 0)
            
            # 创建自然的椭圆形蒙版，避免圆形边界效果
            mask = np.ones((eh, ew), dtype=np.float32)
            
            # 使用椭圆形蒙版，更符合人脸形状
            center_x, center_y = ew // 2, eh // 2
            cv2.ellipse(mask, (center_x, center_y), (ew//3, eh//3), 0, 0, 360, 1.0, -1)
            
            # 使用高斯模糊创建平滑的边缘过渡
            mask = cv2.GaussianBlur(mask, (51, 51), 0)
            
            # 调整蒙版强度，确保边缘自然过渡
            mask = np.clip(mask * 0.8 + 0.2, 0.2, 1.0)
            
            # 优化的多层混合处理，减少过度处理
            # 降低处理强度，使效果更自然
            alpha1 = 0.25 * strength_factor  # 降低双边滤波强度
            alpha2 = 0.15 * strength_factor  # 降低边缘保护滤波强度
            alpha3 = 0.1 * strength_factor   # 降低高斯模糊强度
            
            blended = face_img.copy().astype(np.float32)
            
            # 使用更温和的混合方式
            for c in range(3):
                # 第一层：轻微的双边滤波
                blended[:, :, c] = (
                    face_img[:, :, c] * (1 - alpha1 * mask) +
                    smoothed1[:, :, c] * alpha1 * mask
                )
                
                # 第二层：更轻微的边缘保护
                blended[:, :, c] = (
                    blended[:, :, c] * (1 - alpha2 * mask) +
                    smoothed2[:, :, c] * alpha2 * mask
                )
                
                # 第三层：最轻微的整体平滑
                blended[:, :, c] = (
                    blended[:, :, c] * (1 - alpha3 * mask) +
                    smoothed3[:, :, c] * alpha3 * mask
                )
            
            result[ey:ey+eh, ex:ex+ew] = np.clip(blended, 0, 255).astype(np.uint8)
        
        return result
    
    @staticmethod
    def _apply_intelligent_whitening(img, strength, face_regions):
        """智能美白处理（保护眼部和唇部）"""
        strength_factor = strength / 100.0
        result = img.copy()
        
        if not face_regions:
            # 如果没有检测到人脸，使用全图处理
            return ImageProcessingService._apply_whitening(img, strength)
        
        for face_region in face_regions:
            x, y, w, h = face_region['face']
            
            # 创建人脸蒙版
            face_mask = np.zeros(img.shape[:2], dtype=np.uint8)
            cv2.rectangle(face_mask, (x, y), (x+w, y+h), 255, -1)
            
            # 创建眼部和唇部保护蒙版
            protection_mask = np.ones(img.shape[:2], dtype=np.float32)
            
            # 保护眼部区域
            for (ex, ey, ew, eh) in face_region['eyes']:
                cv2.ellipse(protection_mask, (ex+ew//2, ey+eh//2), (ew//2+5, eh//2+5), 0, 0, 360, 0.3, -1)
            
            # 保护唇部区域
            for (mx, my, mw, mh) in face_region['mouth']:
                cv2.ellipse(protection_mask, (mx+mw//2, my+mh//2), (mw//2+3, mh//2+3), 0, 0, 360, 0.4, -1)
            
            # 转换为LAB色彩空间
            lab = cv2.cvtColor(result, cv2.COLOR_RGB2LAB)
            l_channel, a_channel, b_channel = cv2.split(lab)
            
            # 自适应直方图均衡化
            clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
            l_enhanced = clahe.apply(l_channel)
            
            # 智能亮度提升
            brightness_boost = int(50 * strength_factor)
            l_brightened = cv2.add(l_enhanced, brightness_boost)
            
            # 应用人脸蒙版和保护蒙版
            face_mask_norm = face_mask.astype(np.float32) / 255.0
            combined_mask = face_mask_norm * protection_mask * strength_factor
            
            l_final = l_channel.astype(np.float32) * (1 - combined_mask) + l_brightened.astype(np.float32) * combined_mask
            l_final = np.clip(l_final, 0, 255).astype(np.uint8)
            
            # 重新合并通道
            lab_enhanced = cv2.merge([l_final, a_channel, b_channel])
            result = cv2.cvtColor(lab_enhanced, cv2.COLOR_LAB2RGB)
        
        return result
    
    @staticmethod
    def _enhance_eyes_advanced(img, strength, face_regions):
        """精准眼部增强"""
        strength_factor = strength / 100.0
        result = img.copy()
        
        if not face_regions:
            # 如果没有检测到人脸，使用原有方法
            return ImageProcessingService._enhance_eyes(img, strength)
        
        for face_region in face_regions:
            for (ex, ey, ew, eh) in face_region['eyes']:
                # 扩展眼部区域
                expand = 10
                ex_exp = max(0, ex - expand)
                ey_exp = max(0, ey - expand)
                ew_exp = min(img.shape[1] - ex_exp, ew + 2 * expand)
                eh_exp = min(img.shape[0] - ey_exp, eh + 2 * expand)
                
                # 提取眼部区域
                eye_region = result[ey_exp:ey_exp+eh_exp, ex_exp:ex_exp+ew_exp]
                
                # 转换为PIL图像进行精细处理
                pil_eye = Image.fromarray(eye_region)
                
                # 增强对比度（突出眼部轮廓）
                contrast_enhancer = ImageEnhance.Contrast(pil_eye)
                enhanced = contrast_enhancer.enhance(1 + 0.8 * strength_factor)
                
                # 增强锐度（使眼部更清晰）
                sharpness_enhancer = ImageEnhance.Sharpness(enhanced)
                enhanced = sharpness_enhancer.enhance(1 + 0.9 * strength_factor)
                
                # 轻微增强亮度（使眼部更有神）
                brightness_enhancer = ImageEnhance.Brightness(enhanced)
                enhanced = brightness_enhancer.enhance(1 + 0.3 * strength_factor)
                
                # 增强饱和度（使眼部颜色更鲜明）
                color_enhancer = ImageEnhance.Color(enhanced)
                enhanced = color_enhancer.enhance(1 + 0.4 * strength_factor)
                
                # 转换回numpy数组
                enhanced_eye = np.array(enhanced)
                
                # 创建椭圆蒙版进行自然混合
                mask = np.zeros((eh_exp, ew_exp), dtype=np.float32)
                cv2.ellipse(mask, (ew_exp//2, eh_exp//2), (ew_exp//2-5, eh_exp//2-3), 0, 0, 360, 1.0, -1)
                
                # 高斯模糊蒙版边缘
                mask = cv2.GaussianBlur(mask, (15, 15), 0)
                
                # 应用蒙版混合
                for c in range(3):
                    result[ey_exp:ey_exp+eh_exp, ex_exp:ex_exp+ew_exp, c] = (
                        eye_region[:, :, c] * (1 - mask * 0.8) +
                        enhanced_eye[:, :, c] * mask * 0.8
                    )
        
        return result
    
    @staticmethod
    def _enhance_lips_advanced(img, strength, face_regions):
        """精准唇部增强"""
        strength_factor = strength / 100.0
        result = img.copy()
        
        if not face_regions:
            # 如果没有检测到人脸，使用原有方法
            return ImageProcessingService._enhance_lips(img, strength)
        
        for face_region in face_regions:
            for (mx, my, mw, mh) in face_region['mouth']:
                # 扩展唇部区域
                expand = 8
                mx_exp = max(0, mx - expand)
                my_exp = max(0, my - expand)
                mw_exp = min(img.shape[1] - mx_exp, mw + 2 * expand)
                mh_exp = min(img.shape[0] - my_exp, mh + 2 * expand)
                
                # 提取唇部区域
                lip_region = result[my_exp:my_exp+mh_exp, mx_exp:mx_exp+mw_exp]
                
                # HSV色彩空间处理
                hsv_lip = cv2.cvtColor(lip_region, cv2.COLOR_RGB2HSV)
                
                # 增强饱和度（使唇色更鲜艳）
                hsv_lip[:, :, 1] = cv2.multiply(hsv_lip[:, :, 1], 1 + 0.5 * strength_factor)
                
                # 轻微调整色相（偏向红色）
                hue_shift = int(5 * strength_factor)
                hsv_lip[:, :, 0] = np.clip(hsv_lip[:, :, 0].astype(np.int16) + hue_shift, 0, 179).astype(np.uint8)
                
                # 增加亮度（使唇部更有光泽）
                hsv_lip[:, :, 2] = cv2.add(hsv_lip[:, :, 2], int(20 * strength_factor))
                
                # 转换回RGB
                enhanced_lip = cv2.cvtColor(hsv_lip, cv2.COLOR_HSV2RGB)
                
                # 创建椭圆蒙版
                mask = np.zeros((mh_exp, mw_exp), dtype=np.float32)
                cv2.ellipse(mask, (mw_exp//2, mh_exp//2), (mw_exp//2-3, mh_exp//2-2), 0, 0, 360, 1.0, -1)
                
                # 高斯模糊蒙版边缘
                mask = cv2.GaussianBlur(mask, (11, 11), 0)
                
                # 应用蒙版混合
                for c in range(3):
                    result[my_exp:my_exp+mh_exp, mx_exp:mx_exp+mw_exp, c] = (
                        lip_region[:, :, c] * (1 - mask * 0.7) +
                        enhanced_lip[:, :, c] * mask * 0.7
                    )
        
        return result
    
    @staticmethod
    def _apply_color_harmony(img):
        """整体色彩和谐调整"""
        # 转换为LAB色彩空间进行色彩调整
        lab = cv2.cvtColor(img, cv2.COLOR_RGB2LAB)
        l, a, b = cv2.split(lab)
        
        # 轻微调整色彩平衡
        a = cv2.multiply(a, 0.98)  # 减少绿色-红色偏移
        b = cv2.multiply(b, 1.02)  # 增加蓝色-黄色偏移，使肤色更温暖
        
        # 重新合并
        lab_adjusted = cv2.merge([l, a, b])
        result = cv2.cvtColor(lab_adjusted, cv2.COLOR_LAB2RGB)
        
        # HSV微调
        hsv = cv2.cvtColor(result, cv2.COLOR_RGB2HSV)
        h, s, v = cv2.split(hsv)
        
        # 轻微降低饱和度，使整体更自然
        s = cv2.multiply(s, 0.96)
        
        # 重新合并
        hsv_adjusted = cv2.merge([h, s, v])
        result = cv2.cvtColor(hsv_adjusted, cv2.COLOR_HSV2RGB)
        
        return result
    
    @staticmethod
    def _apply_detail_enhancement(img):
        """细节锐化和噪声抑制"""
        # 使用非锐化掩模进行细节增强
        gaussian = cv2.GaussianBlur(img, (0, 0), 2.0)
        unsharp_mask = cv2.addWeighted(img, 1.5, gaussian, -0.5, 0)
        
        # 双边滤波去除噪声同时保持边缘
        denoised = cv2.bilateralFilter(unsharp_mask, 9, 75, 75)
        
        # 混合原图和处理后的图像
        result = cv2.addWeighted(img, 0.7, denoised, 0.3, 0)
        
        return result
    
    @staticmethod
    def _apply_whitening(img, strength):
        """高级美白处理"""
        strength_factor = strength / 100.0
        
        # 转换为LAB色彩空间进行更精确的亮度调整
        lab = cv2.cvtColor(img, cv2.COLOR_RGB2LAB)
        l_channel, a_channel, b_channel = cv2.split(lab)
        
        # 对L通道进行自适应直方图均衡化
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l_channel = clahe.apply(l_channel)
        
        # 增加亮度，但避免过曝 - 增强效果
        brightness_boost = int(40 * strength_factor)
        l_channel = cv2.add(l_channel, brightness_boost)
        
        # 重新合并通道
        lab = cv2.merge([l_channel, a_channel, b_channel])
        result = cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)
        
        # 使用HSV进行额外的肤色优化
        hsv = cv2.cvtColor(result, cv2.COLOR_RGB2HSV)
        
        # 轻微降低饱和度，使肤色更自然
        hsv[:, :, 1] = cv2.multiply(hsv[:, :, 1], 0.95)
        
        # 转换回RGB
        result = cv2.cvtColor(hsv, cv2.COLOR_HSV2RGB)
        
        # 与原图混合，避免过度处理 - 增强效果
        alpha = 0.85 * strength_factor
        result = cv2.addWeighted(img, 1 - alpha, result, alpha, 0)
        
        return result
    
    @staticmethod
    def _enhance_eyes(img, strength):
        """高级眼部增强"""
        strength_factor = strength / 100.0
        
        # 转换为PIL图像进行处理
        pil_img = Image.fromarray(img)
        
        # 增强对比度，突出眼部轮廓 - 增强效果
        contrast_enhancer = ImageEnhance.Contrast(pil_img)
        enhanced = contrast_enhancer.enhance(1 + 0.5 * strength_factor)
        
        # 增强锐度，使眼部更清晰 - 增强效果
        sharpness_enhancer = ImageEnhance.Sharpness(enhanced)
        enhanced = sharpness_enhancer.enhance(1 + 0.6 * strength_factor)
        
        # 轻微增强亮度，使眼部更有神 - 增强效果
        brightness_enhancer = ImageEnhance.Brightness(enhanced)
        enhanced = brightness_enhancer.enhance(1 + 0.2 * strength_factor)
        
        # 转换回numpy数组
        result = np.array(enhanced)
        
        # 使用HSV调整，增强眼部色彩
        hsv = cv2.cvtColor(result, cv2.COLOR_RGB2HSV)
        
        # 轻微增加饱和度，使眼部颜色更鲜明 - 增强效果
        hsv[:, :, 1] = cv2.multiply(hsv[:, :, 1], 1 + 0.3 * strength_factor)
        
        result = cv2.cvtColor(hsv, cv2.COLOR_HSV2RGB)
        
        # 与原图混合，保持自然效果 - 增强效果
        alpha = 0.75 * strength_factor
        result = cv2.addWeighted(img, 1 - alpha, result, alpha, 0)
        
        return result
    
    @staticmethod
    def _enhance_lips(img, strength):
        """高级唇部增强"""
        strength_factor = strength / 100.0
        
        # 转换为HSV进行色彩调整
        hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
        
        # 增强红色区域的饱和度（唇部通常偏红）
        # 创建红色掩码
        lower_red1 = np.array([0, 50, 50])
        upper_red1 = np.array([10, 255, 255])
        lower_red2 = np.array([170, 50, 50])
        upper_red2 = np.array([180, 255, 255])
        
        mask1 = cv2.inRange(hsv, lower_red1, upper_red1)
        mask2 = cv2.inRange(hsv, lower_red2, upper_red2)
        red_mask = cv2.bitwise_or(mask1, mask2)
        
        # 对红色区域增强饱和度和亮度 - 增强效果
        hsv_enhanced = hsv.copy()
        hsv_enhanced[:, :, 1] = cv2.multiply(hsv_enhanced[:, :, 1], 1 + 0.6 * strength_factor)
        hsv_enhanced[:, :, 2] = cv2.multiply(hsv_enhanced[:, :, 2], 1 + 0.3 * strength_factor)
        
        # 只在红色区域应用增强
        hsv_result = hsv.copy()
        hsv_result[red_mask > 0] = hsv_enhanced[red_mask > 0]
        
        # 转换回RGB
        result = cv2.cvtColor(hsv_result, cv2.COLOR_HSV2RGB)
        
        # 额外的唇部光泽效果
        pil_img = Image.fromarray(result)
        
        # 轻微增加对比度，使唇部更立体 - 增强效果
        contrast_enhancer = ImageEnhance.Contrast(pil_img)
        enhanced = contrast_enhancer.enhance(1 + 0.25 * strength_factor)
        
        result = np.array(enhanced)
        
        # 与原图混合，保持自然效果 - 增强效果
        alpha = 0.7 * strength_factor
        result = cv2.addWeighted(img, 1 - alpha, result, alpha, 0)
        
        return result
    
    @staticmethod
    def apply_filter(image_path, filter_type, intensity, user_id):
        """应用滤镜效果"""
        try:
            # 读取图片
            pil_img = Image.open(image_path)
            
            # 根据滤镜类型应用不同效果
            if filter_type == 'vintage':
                filtered_img = ImageProcessingService._apply_vintage_filter(pil_img, intensity)
            elif filter_type == 'black_white':
                filtered_img = ImageProcessingService._apply_bw_filter(pil_img, intensity)
            elif filter_type == 'sepia':
                filtered_img = ImageProcessingService._apply_sepia_filter(pil_img, intensity)
            elif filter_type == 'cool':
                filtered_img = ImageProcessingService._apply_cool_filter(pil_img, intensity)
            elif filter_type == 'warm':
                filtered_img = ImageProcessingService._apply_warm_filter(pil_img, intensity)
            else:
                raise ValueError(f"不支持的滤镜类型: {filter_type}")
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(user_id, f'filter_{filter_type}')
            filtered_img.save(output_path, 'JPEG', quality=95)
            
            return output_path
            
        except Exception as e:
            raise Exception(f"滤镜处理失败: {str(e)}")
    
    @staticmethod
    def _apply_vintage_filter(img, intensity):
        """复古滤镜"""
        # 降低饱和度
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(0.7)
        
        # 增加暖色调
        img_array = np.array(img)
        img_array[:, :, 0] = np.clip(img_array[:, :, 0] * 1.1, 0, 255)  # 增加红色
        img_array[:, :, 1] = np.clip(img_array[:, :, 1] * 1.05, 0, 255)  # 略增加绿色
        
        result = Image.fromarray(img_array.astype(np.uint8))
        
        # 根据强度混合
        alpha = intensity / 100.0
        return Image.blend(img, result, alpha)
    
    @staticmethod
    def _apply_bw_filter(img, intensity):
        """黑白滤镜"""
        bw_img = img.convert('L').convert('RGB')
        alpha = intensity / 100.0
        return Image.blend(img, bw_img, alpha)
    
    @staticmethod
    def _apply_sepia_filter(img, intensity):
        """棕褐色滤镜"""
        img_array = np.array(img)
        
        # 棕褐色变换矩阵
        sepia_filter = np.array([
            [0.393, 0.769, 0.189],
            [0.349, 0.686, 0.168],
            [0.272, 0.534, 0.131]
        ])
        
        sepia_img = img_array.dot(sepia_filter.T)
        sepia_img = np.clip(sepia_img, 0, 255)
        
        result = Image.fromarray(sepia_img.astype(np.uint8))
        
        alpha = intensity / 100.0
        return Image.blend(img, result, alpha)
    
    @staticmethod
    def _apply_cool_filter(img, intensity):
        """冷色调滤镜"""
        img_array = np.array(img)
        img_array[:, :, 2] = np.clip(img_array[:, :, 2] * 1.2, 0, 255)  # 增加蓝色
        
        result = Image.fromarray(img_array.astype(np.uint8))
        
        alpha = intensity / 100.0
        return Image.blend(img, result, alpha)
    
    @staticmethod
    def _apply_warm_filter(img, intensity):
        """暖色调滤镜"""
        img_array = np.array(img)
        img_array[:, :, 0] = np.clip(img_array[:, :, 0] * 1.15, 0, 255)  # 增加红色
        img_array[:, :, 1] = np.clip(img_array[:, :, 1] * 1.05, 0, 255)  # 略增加绿色
        
        result = Image.fromarray(img_array.astype(np.uint8))
        
        alpha = intensity / 100.0
        return Image.blend(img, result, alpha)
    
    @staticmethod
    def adjust_color(image_path, params, user_id):
        """调整颜色"""
        try:
            pil_img = Image.open(image_path)
            
            # 亮度调整
            brightness = params.get('brightness', 0)
            if brightness != 0:
                enhancer = ImageEnhance.Brightness(pil_img)
                pil_img = enhancer.enhance(1 + brightness / 100.0)
            
            # 对比度调整
            contrast = params.get('contrast', 0)
            if contrast != 0:
                enhancer = ImageEnhance.Contrast(pil_img)
                pil_img = enhancer.enhance(1 + contrast / 100.0)
            
            # 饱和度调整
            saturation = params.get('saturation', 0)
            if saturation != 0:
                enhancer = ImageEnhance.Color(pil_img)
                pil_img = enhancer.enhance(1 + saturation / 100.0)
            
            # 色相调整（简化实现）
            hue = params.get('hue', 0)
            if hue != 0:
                pil_img = ImageProcessingService._adjust_hue(pil_img, hue)
            
            # 伽马调整
            gamma = params.get('gamma', 1.0)
            if gamma != 1.0:
                pil_img = ImageProcessingService._adjust_gamma(pil_img, gamma)
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(user_id, 'color_adjust')
            pil_img.save(output_path, 'JPEG', quality=95)
            
            return output_path
            
        except Exception as e:
            raise Exception(f"颜色调整失败: {str(e)}")
    
    @staticmethod
    def _adjust_hue(img, hue_shift):
        """色相调整"""
        img_array = np.array(img)
        hsv = cv2.cvtColor(img_array, cv2.COLOR_RGB2HSV)
        
        # 调整色相
        hsv[:, :, 0] = (hsv[:, :, 0] + hue_shift) % 180
        
        rgb = cv2.cvtColor(hsv, cv2.COLOR_HSV2RGB)
        return Image.fromarray(rgb)
    
    @staticmethod
    def _adjust_gamma(img, gamma):
        """伽马调整"""
        img_array = np.array(img)
        
        # 伽马校正
        gamma_corrected = np.power(img_array / 255.0, gamma) * 255.0
        gamma_corrected = np.clip(gamma_corrected, 0, 255)
        
        return Image.fromarray(gamma_corrected.astype(np.uint8))
    
    @staticmethod
    def blur_background(image_path, params, user_id):
        """背景虚化"""
        try:
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("无法读取图片文件")
            
            blur_strength = params.get('blur_strength', 15)
            
            # 简化的背景虚化：对整个图片应用高斯模糊
            # 实际应用中需要前景检测和分割
            blurred = cv2.GaussianBlur(img, (blur_strength * 2 + 1, blur_strength * 2 + 1), 0)
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(user_id, 'background_blur')
            cv2.imwrite(output_path, blurred, [cv2.IMWRITE_JPEG_QUALITY, 95])
            
            return output_path
            
        except Exception as e:
            raise Exception(f"背景虚化失败: {str(e)}")
    
    @staticmethod
    def remove_background(image_path, params, user_id):
        """背景移除"""
        try:
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("无法读取图片文件")
            
            intensity = params.get('intensity', 0.8)
            
            # 使用改进的人像分割算法
            mask2 = ImageProcessingService._create_person_mask(img)
            
            # 确保掩码是浮点格式
            if mask2.dtype != np.float32:
                mask2 = mask2.astype(np.float32) / 255.0
            
            # 扩展掩码到3通道
            mask_3d = mask2[:, :, np.newaxis]
            
            # 应用掩码移除背景（使用浮点运算确保精度）
            img_float = img.astype(np.float32)
            result_float = img_float * mask_3d
            result = result_float.astype(np.uint8)
            
            # 将背景设为透明（保存为PNG）
            # 转换为RGBA
            result_rgba = cv2.cvtColor(result, cv2.COLOR_BGR2RGBA)
            alpha_channel = (mask2 * 255).astype(np.uint8)
            result_rgba[:, :, 3] = alpha_channel  # 设置alpha通道
            
            # 保存结果为PNG格式以支持透明背景
            output_path = ImageProcessingService._get_output_path(user_id, 'background_remove', '.png')
            cv2.imwrite(output_path, result_rgba)
            
            return output_path
            
        except Exception as e:
            raise Exception(f"背景移除失败: {str(e)}")
    
    @staticmethod
    def replace_background(image_path, params, user_id):
        """背景替换"""
        try:
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("无法读取图片文件")
            
            intensity = params.get('intensity', 0.8)
            background_color = params.get('background_color', '#FFFFFF')
            
            # 解析背景颜色
            if background_color.startswith('#'):
                # 十六进制颜色转BGR
                hex_color = background_color[1:]
                r = int(hex_color[0:2], 16)
                g = int(hex_color[2:4], 16)
                b = int(hex_color[4:6], 16)
                bg_color = (b, g, r)  # OpenCV使用BGR格式
            else:
                # 预定义颜色（BGR格式）
                color_map = {
                    'white': (255, 255, 255),
                    'black': (0, 0, 0),
                    'red': (69, 53, 220),     # 证件照红色
                    'green': (0, 255, 0),
                    'blue': (219, 142, 67),   # 证件照蓝色
                    'yellow': (0, 255, 255),
                    'cyan': (255, 255, 0),
                    'magenta': (255, 0, 255)
                }
                bg_color = color_map.get(background_color.lower(), (255, 255, 255))
            
            height, width = img.shape[:2]
            
            # 使用改进的人像分割算法
            mask = ImageProcessingService._create_person_mask(img)
            
            # 对掩码进行形态学处理，提高边缘质量
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
            mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
            mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
            
            # 高斯模糊边缘，使过渡更自然
            mask_float = mask.astype(np.float32) / 255.0
            mask_blurred = cv2.GaussianBlur(mask_float, (3, 3), 1.0)
            
            # 创建前景掩码
            mask2 = mask_blurred
            
            # 创建新背景
            new_background = np.full((height, width, 3), bg_color, dtype=np.uint8)
            
            # 确保掩码是浮点格式
            if mask2.dtype != np.float32:
                mask2 = mask2.astype(np.float32) / 255.0
            
            # 扩展掩码到3通道
            mask_3d = mask2[:, :, np.newaxis]
            inv_mask_3d = 1.0 - mask_3d
            
            # 合成图像：前景 + 新背景（使用浮点运算确保精度）
            img_float = img.astype(np.float32)
            bg_float = new_background.astype(np.float32)
            
            result_float = img_float * mask_3d + bg_float * inv_mask_3d
            result = result_float.astype(np.uint8)
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(user_id, 'background_replace')
            cv2.imwrite(output_path, result, [cv2.IMWRITE_JPEG_QUALITY, 95])
            
            return output_path
            
        except Exception as e:
            raise Exception(f"背景替换失败: {str(e)}")
    
    @staticmethod
    def _create_person_mask(img):
        """
        使用 rembg 深度学习模型创建高质量人像掩码
        """
        try:
            # 将 OpenCV 图像转换为 PIL 图像
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            pil_img = Image.fromarray(img_rgb)
            
            # 使用 rembg 移除背景，获得带透明通道的图像
            session = new_session('u2net')  # 使用 u2net 模型，适合人像
            output = remove(pil_img, session=session)
            
            # 提取 alpha 通道作为掩码
            output_array = np.array(output)
            if output_array.shape[2] == 4:  # RGBA
                alpha_channel = output_array[:, :, 3]
            else:
                # 如果没有 alpha 通道，创建基于非黑色像素的掩码
                gray_output = cv2.cvtColor(output_array, cv2.COLOR_RGB2GRAY)
                alpha_channel = np.where(gray_output > 10, 255, 0).astype(np.uint8)
            
            # 对掩码进行轻微的形态学处理以平滑边缘
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
            alpha_channel = cv2.morphologyEx(alpha_channel, cv2.MORPH_CLOSE, kernel)
            
            # 轻微的高斯模糊以平滑边缘
            alpha_channel = cv2.GaussianBlur(alpha_channel, (3, 3), 0)
            
            return alpha_channel
            
        except Exception as e:
            print(f"rembg 处理失败，使用备选方案: {str(e)}")
            # 备选方案：使用改进的 GrabCut
            return ImageProcessingService._create_person_mask_fallback(img)
    
    @staticmethod
    def _create_person_mask_fallback(img):
        """
        备选的人像掩码创建方法（当 rembg 失败时使用）
        """
        height, width = img.shape[:2]
        
        # 使用改进的 GrabCut 算法
        mask = np.zeros((height, width), np.uint8)
        
        # 定义前景区域（中心区域，更保守的估计）
        margin_x = int(width * 0.2)
        margin_y = int(height * 0.15)
        rect = (margin_x, margin_y, width - 2*margin_x, height - 2*margin_y)
        
        # 初始化前景和背景模型
        bgd_model = np.zeros((1, 65), np.float64)
        fgd_model = np.zeros((1, 65), np.float64)
        
        try:
            # 应用 GrabCut 算法
            cv2.grabCut(img, mask, rect, bgd_model, fgd_model, 5, cv2.GC_INIT_WITH_RECT)
            
            # 进一步优化
            cv2.grabCut(img, mask, None, bgd_model, fgd_model, 3, cv2.GC_INIT_WITH_MASK)
            
            # 创建最终掩码
            final_mask = np.where((mask == 2) | (mask == 0), 0, 255).astype(np.uint8)
            
            # 形态学处理
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
            final_mask = cv2.morphologyEx(final_mask, cv2.MORPH_CLOSE, kernel)
            final_mask = cv2.GaussianBlur(final_mask, (3, 3), 0)
            
            return final_mask
            
        except Exception as e:
            print(f"GrabCut 也失败了，使用简单椭圆掩码: {str(e)}")
            # 最后的备选方案：简单的椭圆掩码
            mask = np.zeros((height, width), dtype=np.uint8)
            center_x, center_y = width // 2, height // 2
            cv2.ellipse(mask, (center_x, center_y), (width//3, height//2), 0, 0, 360, 255, -1)
            return mask
    
    @staticmethod
    def repair_image(image_path, params, user_id):
        """智能修复"""
        try:
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("无法读取图片文件")
            
            repair_type = params.get('repair_type', 'auto')
            strength = params.get('strength', 50)
            
            if repair_type == 'noise':
                # 降噪处理
                repaired = cv2.fastNlMeansDenoisingColored(img, None, strength/10, strength/10, 7, 21)
            elif repair_type == 'scratch':
                # 划痕修复（使用形态学操作）
                kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
                repaired = cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
            else:
                # 自动修复（组合多种方法）
                # 先降噪
                repaired = cv2.fastNlMeansDenoisingColored(img, None, strength/20, strength/20, 7, 21)
                # 再进行轻微的形态学处理
                kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2, 2))
                repaired = cv2.morphologyEx(repaired, cv2.MORPH_CLOSE, kernel)
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(user_id, 'repair')
            cv2.imwrite(output_path, repaired, [cv2.IMWRITE_JPEG_QUALITY, 95])
            
            return output_path
            
        except Exception as e:
            raise Exception(f"智能修复失败: {str(e)}")
    
    @staticmethod
    def generate_id_photo(image_path, params, user_id):
        """AI智能证件照生成"""
        try:
            # 初始化AI服务
            ai_service = AIService()
            
            # 获取AI证件照分析建议
            ai_result = ai_service.get_ai_id_photo_processing(image_path, params)
            
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError("无法读取图片文件")
            
            # 获取证件照参数
            photo_type = params.get('photo_type', '1_inch')  # 1_inch, 2_inch, passport
            background_color = params.get('background_color', 'white')  # white, blue, red
            auto_crop = params.get('auto_crop', True)
            beauty_strength = params.get('beauty_strength', 30)
            
            # 定义证件照尺寸（像素）
            size_map = {
                '1_inch': (295, 413),    # 1寸照片
                '2_inch': (413, 579),    # 2寸照片
                'passport': (390, 567),  # 护照照片
                'id_card': (358, 441)    # 身份证照片
            }
            
            target_size = size_map.get(photo_type, (295, 413))
            
            # 转换为RGB
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            pil_img = Image.fromarray(img_rgb)
            
            # 如果AI分析成功，根据AI建议进行优化处理
            if ai_result['success'] and ai_result.get('ai_suggestions'):
                try:
                    # 尝试从AI建议中提取处理建议
                    ai_suggestions = ai_result['ai_suggestions']
                    if isinstance(ai_suggestions, str):
                        # 查找JSON部分
                        start_idx = ai_suggestions.find('{')
                        end_idx = ai_suggestions.rfind('}') + 1
                        if start_idx != -1 and end_idx > start_idx:
                            json_str = ai_suggestions[start_idx:end_idx]
                            ai_params = json.loads(json_str)
                            
                            # 根据AI建议调整处理策略
                            if 'lighting_optimization' in ai_params:
                                # 应用光线优化
                                pil_img = ImageProcessingService._apply_lighting_optimization(pil_img)
                            
                            if 'overall_quality_score' in ai_params:
                                try:
                                    quality_score = float(ai_params['overall_quality_score'])
                                    if quality_score < 7:  # 质量较低时增强处理
                                        beauty_strength = min(beauty_strength + 20, 80)
                                except (ValueError, TypeError):
                                    pass
                                    
                except (json.JSONDecodeError, KeyError) as e:
                    print(f"AI建议解析失败，使用默认处理: {str(e)}")
            
            # 应用美颜处理（基于AI建议调整的强度）
            if beauty_strength > 0:
                pil_img = ImageProcessingService._apply_id_photo_beauty(pil_img, beauty_strength)
            
            # 如果启用自动裁剪，进行人脸检测和裁剪
            if auto_crop:
                pil_img = ImageProcessingService._auto_crop_face(pil_img)
            
            # 调整图片尺寸
            pil_img = pil_img.resize(target_size, Image.Resampling.LANCZOS)
            
            # 先保存调整后的图片到临时文件
            temp_path = ImageProcessingService._get_output_path(
                user_id, f'temp_id_photo_{photo_type}'
            )
            pil_img.save(temp_path, 'JPEG', quality=95)
            
            # 使用背景替换功能进行换底
            replace_params = {
                'background_color': background_color,
                'intensity': 0.8
            }
            
            # 调用背景替换功能
            replaced_bg_path = ImageProcessingService.replace_background(
                temp_path, replace_params, user_id
            )
            
            # 重新加载处理后的图片
            result_img = Image.open(replaced_bg_path)
            
            # 删除临时文件
            if os.path.exists(temp_path):
                os.remove(temp_path)
            
            # 应用证件照优化
            result_img = ImageProcessingService._optimize_id_photo(result_img)
            
            # 保存结果
            output_path = ImageProcessingService._get_output_path(
                user_id, f'ai_id_photo_{photo_type}'
            )
            result_img.save(output_path, 'JPEG', quality=95)
            
            return output_path
            
        except Exception as e:
            raise Exception(f"AI证件照生成失败: {str(e)}")
    
    @staticmethod
    def _auto_crop_face(img):
        """自动裁剪人脸区域"""
        # 简化版本：中心裁剪
        # 实际应用中需要使用人脸检测算法
        width, height = img.size
        
        # 计算裁剪区域（保持3:4比例）
        if width > height:
            # 横向图片，以高度为基准
            new_width = int(height * 3 / 4)
            left = (width - new_width) // 2
            crop_box = (left, 0, left + new_width, height)
        else:
            # 纵向图片，以宽度为基准
            new_height = int(width * 4 / 3)
            top = max(0, (height - new_height) // 4)  # 稍微偏上裁剪
            crop_box = (0, top, width, min(height, top + new_height))
        
        return img.crop(crop_box)
    
    @staticmethod
    def _create_id_photo_background(size, color):
        """创建证件照背景"""
        color_map = {
            'white': (255, 255, 255),
            'blue': (67, 142, 219),
            'red': (220, 53, 69)
        }
        
        bg_color = color_map.get(color, (255, 255, 255))
        return Image.new('RGB', size, bg_color)
    
    @staticmethod
    def _optimize_id_photo(img):
        """优化证件照效果"""
        # 轻微锐化
        img = img.filter(ImageFilter.UnsharpMask(radius=1, percent=120, threshold=3))
        
        # 轻微对比度增强
        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(1.1)
        
        # 轻微亮度调整
        enhancer = ImageEnhance.Brightness(img)
        img = enhancer.enhance(1.05)
        
        return img
    
    @staticmethod
    def _apply_lighting_optimization(img):
        """应用光线优化"""
        # 自动亮度和对比度调整
        enhancer = ImageEnhance.Brightness(img)
        img = enhancer.enhance(1.1)
        
        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(1.15)
        
        # 轻微的色彩平衡调整
        img_array = np.array(img)
        
        # 增强肤色
        img_array[:, :, 0] = np.clip(img_array[:, :, 0] * 1.05, 0, 255)  # 红色通道
        img_array[:, :, 1] = np.clip(img_array[:, :, 1] * 1.02, 0, 255)  # 绿色通道
        
        return Image.fromarray(img_array.astype(np.uint8))
    
    @staticmethod
    def _apply_id_photo_beauty(img, strength):
        """应用证件照专用美颜"""
        strength_factor = strength / 100.0
        
        # 转换为numpy数组进行处理
        img_array = np.array(img)
        img_cv = cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR)
        
        # 轻度磨皮（适合证件照）
        if strength_factor > 0.2:
            d = max(5, int(7 * strength_factor))
            sigma_color = max(30, int(50 * strength_factor))
            sigma_space = max(30, int(50 * strength_factor))
            img_cv = cv2.bilateralFilter(img_cv, d, sigma_color, sigma_space)
        
        # 轻微美白
        if strength_factor > 0.1:
            hsv = cv2.cvtColor(img_cv, cv2.COLOR_BGR2HSV)
            hsv[:, :, 2] = cv2.add(hsv[:, :, 2], int(15 * strength_factor))
            img_cv = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
        
        # 转换回PIL格式
        img_rgb = cv2.cvtColor(img_cv, cv2.COLOR_BGR2RGB)
        result_img = Image.fromarray(img_rgb)
        
        # 轻微锐化以保持清晰度
        result_img = result_img.filter(ImageFilter.UnsharpMask(radius=0.5, percent=100, threshold=2))
        
        return result_img