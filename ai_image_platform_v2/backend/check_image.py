from app.models.image import Image
from app.models import db
from app import create_app

app = create_app()
with app.app_context():
    # 查找图片ID 53
    img = Image.query.filter_by(id=53, user_id=1).first()
    print(f'图片53存在: {img is not None}')
    
    if img:
        print(f'图片路径: {img.file_path}')
    else:
        print('查找所有图片:')
        all_imgs = Image.query.order_by(Image.id.desc()).all()
        print(f'总图片数: {len(all_imgs)}')
        
        # 显示最新的10张图片
        print('\n最新的10张图片:')
        for i in all_imgs[:10]:
            print(f'ID: {i.id}, user_id: {i.user_id}, filename: {i.filename}, path: {i.file_path}')
        
        # 查找用户1的所有图片
        user1_imgs = Image.query.filter_by(user_id=1).order_by(Image.id.desc()).all()
        print(f'\n用户1的图片数: {len(user1_imgs)}')
        for img in user1_imgs:
            print(f'ID: {img.id}, filename: {img.filename}, path: {img.file_path}')
        
        # 查找所有用户的图片（包括user_id为None的）
        all_user_imgs = Image.query.order_by(Image.id.desc()).all()
        print(f'\n所有用户的图片:')
        for img in all_user_imgs:
            print(f'ID: {img.id}, user_id: {img.user_id}, filename: {img.filename}')