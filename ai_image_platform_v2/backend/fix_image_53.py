from app.models.image import Image
from app.models import db
from app import create_app

app = create_app()
with app.app_context():
    # 查找图片ID 54
    img = Image.query.filter_by(id=54).first()
    
    if img:
        print(f'找到图片ID 54: {img.filename}')
        print(f'当前user_id: {img.user_id}')
        
        if img.user_id is None:
            # 更新user_id为1
            img.user_id = 1
            db.session.commit()
            print(f'已更新图片ID 54的user_id为1')
        else:
            print(f'图片ID 54的user_id已经是: {img.user_id}')
            
        print(f'文件路径: {img.file_path}')
    else:
        print('未找到图片ID 54')
        
        # 查找最新的几张图片
        latest_imgs = Image.query.order_by(Image.id.desc()).limit(5).all()
        print('\n最新的5张图片:')
        for img in latest_imgs:
            print(f'ID: {img.id}, user_id: {img.user_id}, filename: {img.filename}')