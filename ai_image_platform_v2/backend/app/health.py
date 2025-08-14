# -*- coding: utf-8 -*-
"""
健康检查模块
提供应用健康状态检查功能
"""

from flask import Blueprint, jsonify, current_app
from sqlalchemy import text
from datetime import datetime
import os
import psutil
import redis
from .models import db

# 创建健康检查蓝图
health_bp = Blueprint('health', __name__)


@health_bp.route('/health', methods=['GET'])
def health_check():
    """
    应用健康检查
    
    Returns:
        JSON: 健康状态信息
    """
    try:
        health_status = {
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'version': '2.0.0',
            'environment': current_app.config.get('ENV', 'unknown'),
            'checks': {}
        }
        
        # 数据库连接检查
        try:
            db.session.execute(text('SELECT 1'))
            health_status['checks']['database'] = {
                'status': 'healthy',
                'message': 'Database connection successful'
            }
        except Exception as e:
            health_status['checks']['database'] = {
                'status': 'unhealthy',
                'message': f'Database connection failed: {str(e)}'
            }
            health_status['status'] = 'unhealthy'
        
        # Redis连接检查
        try:
            redis_url = current_app.config.get('REDIS_URL')
            if redis_url:
                r = redis.from_url(redis_url)
                r.ping()
                health_status['checks']['redis'] = {
                    'status': 'healthy',
                    'message': 'Redis connection successful'
                }
            else:
                health_status['checks']['redis'] = {
                    'status': 'skipped',
                    'message': 'Redis not configured'
                }
        except Exception as e:
            health_status['checks']['redis'] = {
                'status': 'unhealthy',
                'message': f'Redis connection failed: {str(e)}'
            }
            health_status['status'] = 'unhealthy'
        
        # 文件系统检查
        try:
            upload_folder = current_app.config.get('UPLOAD_FOLDER')
            if upload_folder and os.path.exists(upload_folder):
                # 检查磁盘空间
                disk_usage = psutil.disk_usage(upload_folder)
                free_space_gb = disk_usage.free / (1024**3)
                
                if free_space_gb > 1:  # 至少1GB可用空间
                    health_status['checks']['filesystem'] = {
                        'status': 'healthy',
                        'message': f'Filesystem healthy, {free_space_gb:.2f}GB free'
                    }
                else:
                    health_status['checks']['filesystem'] = {
                        'status': 'warning',
                        'message': f'Low disk space: {free_space_gb:.2f}GB free'
                    }
            else:
                health_status['checks']['filesystem'] = {
                    'status': 'unhealthy',
                    'message': 'Upload folder not accessible'
                }
                health_status['status'] = 'unhealthy'
        except Exception as e:
            health_status['checks']['filesystem'] = {
                'status': 'unhealthy',
                'message': f'Filesystem check failed: {str(e)}'
            }
            health_status['status'] = 'unhealthy'
        
        # 内存使用检查
        try:
            memory = psutil.virtual_memory()
            memory_usage_percent = memory.percent
            
            if memory_usage_percent < 80:
                health_status['checks']['memory'] = {
                    'status': 'healthy',
                    'message': f'Memory usage: {memory_usage_percent:.1f}%'
                }
            elif memory_usage_percent < 90:
                health_status['checks']['memory'] = {
                    'status': 'warning',
                    'message': f'High memory usage: {memory_usage_percent:.1f}%'
                }
            else:
                health_status['checks']['memory'] = {
                    'status': 'critical',
                    'message': f'Critical memory usage: {memory_usage_percent:.1f}%'
                }
                health_status['status'] = 'unhealthy'
        except Exception as e:
            health_status['checks']['memory'] = {
                'status': 'unknown',
                'message': f'Memory check failed: {str(e)}'
            }
        
        # CPU使用检查
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            
            if cpu_percent < 80:
                health_status['checks']['cpu'] = {
                    'status': 'healthy',
                    'message': f'CPU usage: {cpu_percent:.1f}%'
                }
            elif cpu_percent < 95:
                health_status['checks']['cpu'] = {
                    'status': 'warning',
                    'message': f'High CPU usage: {cpu_percent:.1f}%'
                }
            else:
                health_status['checks']['cpu'] = {
                    'status': 'critical',
                    'message': f'Critical CPU usage: {cpu_percent:.1f}%'
                }
        except Exception as e:
            health_status['checks']['cpu'] = {
                'status': 'unknown',
                'message': f'CPU check failed: {str(e)}'
            }
        
        # 根据检查结果确定HTTP状态码
        if health_status['status'] == 'healthy':
            return jsonify(health_status), 200
        else:
            return jsonify(health_status), 503
            
    except Exception as e:
        error_response = {
            'status': 'error',
            'timestamp': datetime.utcnow().isoformat(),
            'message': f'Health check failed: {str(e)}'
        }
        return jsonify(error_response), 500


@health_bp.route('/health/ready', methods=['GET'])
def readiness_check():
    """
    就绪状态检查
    检查应用是否准备好接收请求
    
    Returns:
        JSON: 就绪状态信息
    """
    try:
        # 检查数据库连接
        db.session.execute(text('SELECT 1'))
        
        # 检查上传目录
        upload_folder = current_app.config.get('UPLOAD_FOLDER')
        if not upload_folder or not os.path.exists(upload_folder):
            raise Exception('Upload folder not accessible')
        
        return jsonify({
            'status': 'ready',
            'timestamp': datetime.utcnow().isoformat(),
            'message': 'Application is ready to serve requests'
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'not_ready',
            'timestamp': datetime.utcnow().isoformat(),
            'message': f'Application not ready: {str(e)}'
        }), 503


@health_bp.route('/health/live', methods=['GET'])
def liveness_check():
    """
    存活状态检查
    检查应用是否仍在运行
    
    Returns:
        JSON: 存活状态信息
    """
    return jsonify({
        'status': 'alive',
        'timestamp': datetime.utcnow().isoformat(),
        'message': 'Application is alive'
    }), 200


@health_bp.route('/health/metrics', methods=['GET'])
def metrics():
    """
    应用指标
    提供应用运行指标信息
    
    Returns:
        JSON: 指标信息
    """
    try:
        # 系统指标
        memory = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # 磁盘使用
        upload_folder = current_app.config.get('UPLOAD_FOLDER', '/')
        disk_usage = psutil.disk_usage(upload_folder)
        
        # 数据库统计（如果可用）
        db_stats = {}
        try:
            from .models.user import User
            from .models.image import Image
            from .models.processing_record import ProcessingRecord
            
            db_stats = {
                'users_count': User.query.count(),
                'images_count': Image.query.count(),
                'processing_records_count': ProcessingRecord.query.count()
            }
        except Exception:
            db_stats = {'error': 'Database statistics unavailable'}
        
        metrics_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'system': {
                'cpu_percent': cpu_percent,
                'memory': {
                    'total': memory.total,
                    'available': memory.available,
                    'percent': memory.percent,
                    'used': memory.used,
                    'free': memory.free
                },
                'disk': {
                    'total': disk_usage.total,
                    'used': disk_usage.used,
                    'free': disk_usage.free,
                    'percent': (disk_usage.used / disk_usage.total) * 100
                }
            },
            'database': db_stats,
            'application': {
                'version': '2.0.0',
                'environment': current_app.config.get('ENV', 'unknown'),
                'debug': current_app.debug
            }
        }
        
        return jsonify(metrics_data), 200
        
    except Exception as e:
        return jsonify({
            'error': f'Failed to collect metrics: {str(e)}',
            'timestamp': datetime.utcnow().isoformat()
        }), 500