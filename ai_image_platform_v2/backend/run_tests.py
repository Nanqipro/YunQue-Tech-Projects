#!/usr/bin/env python3
"""
测试运行脚本
提供不同的测试运行选项
"""

import os
import sys
import subprocess
import argparse


def run_command(cmd):
    """运行命令并返回结果"""
    print(f"运行命令: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr, file=sys.stderr)
    
    return result.returncode


def run_all_tests():
    """运行所有测试"""
    print("=== 运行所有测试 ===")
    return run_command("python -m pytest")


def run_unit_tests():
    """运行单元测试"""
    print("=== 运行单元测试 ===")
    return run_command('python -m pytest -m "unit"')


def run_integration_tests():
    """运行集成测试"""
    print("=== 运行集成测试 ===")
    return run_command('python -m pytest -m "integration"')


def run_user_tests():
    """运行用户相关测试"""
    print("=== 运行用户相关测试 ===")
    return run_command("python -m pytest tests/test_user_controller.py")


def run_image_tests():
    """运行图片相关测试"""
    print("=== 运行图片相关测试 ===")
    return run_command("python -m pytest tests/test_image_controller.py")


def run_processing_tests():
    """运行图片处理测试"""
    print("=== 运行图片处理测试 ===")
    return run_command("python -m pytest tests/test_processing_controller.py")


def run_coverage_report():
    """生成覆盖率报告"""
    print("=== 生成覆盖率报告 ===")
    return run_command("python -m pytest --cov-report=html --cov-report=term")


def run_specific_test(test_path):
    """运行特定测试"""
    print(f"=== 运行特定测试: {test_path} ===")
    return run_command(f"python -m pytest {test_path}")


def setup_test_environment():
    """设置测试环境"""
    print("=== 设置测试环境 ===")
    
    # 设置环境变量
    os.environ['FLASK_ENV'] = 'testing'
    os.environ['TESTING'] = 'True'
    
    # 检查依赖
    print("检查测试依赖...")
    required_packages = ['pytest', 'pytest-flask', 'pytest-cov']
    
    for package in required_packages:
        package_name = package.replace("-", "_")
        result = run_command(f"python -c 'import {package_name}'")
        if result != 0:
            print(f"缺少依赖: {package}")
            print(f"请运行: pip install {package}")
            return False
    
    print("测试环境检查完成")
    return True


def main():
    parser = argparse.ArgumentParser(description='AI图片处理平台测试运行器')
    parser.add_argument('--all', action='store_true', help='运行所有测试')
    parser.add_argument('--unit', action='store_true', help='运行单元测试')
    parser.add_argument('--integration', action='store_true', help='运行集成测试')
    parser.add_argument('--user', action='store_true', help='运行用户相关测试')
    parser.add_argument('--image', action='store_true', help='运行图片相关测试')
    parser.add_argument('--processing', action='store_true', help='运行图片处理测试')
    parser.add_argument('--coverage', action='store_true', help='生成覆盖率报告')
    parser.add_argument('--setup', action='store_true', help='设置测试环境')
    parser.add_argument('--test', type=str, help='运行特定测试文件或函数')
    parser.add_argument('--verbose', '-v', action='store_true', help='详细输出')
    
    args = parser.parse_args()
    
    # 如果没有参数，显示帮助
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    # 设置详细输出
    if args.verbose:
        os.environ['PYTEST_VERBOSE'] = '1'
    
    exit_code = 0
    
    try:
        if args.setup:
            if not setup_test_environment():
                exit_code = 1
        
        elif args.all:
            exit_code = run_all_tests()
        
        elif args.unit:
            exit_code = run_unit_tests()
        
        elif args.integration:
            exit_code = run_integration_tests()
        
        elif args.user:
            exit_code = run_user_tests()
        
        elif args.image:
            exit_code = run_image_tests()
        
        elif args.processing:
            exit_code = run_processing_tests()
        
        elif args.coverage:
            exit_code = run_coverage_report()
        
        elif args.test:
            exit_code = run_specific_test(args.test)
        
        else:
            print("请指定要运行的测试类型")
            parser.print_help()
            exit_code = 1
    
    except KeyboardInterrupt:
        print("\n测试被用户中断")
        exit_code = 1
    
    except Exception as e:
        print(f"运行测试时发生错误: {e}")
        exit_code = 1
    
    sys.exit(exit_code)


if __name__ == '__main__':
    main()