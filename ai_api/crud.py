from sqlalchemy import func
from sqlalchemy.orm import Session
import models, schemas
from pydantic_core import from_json

def create_notification(db: Session, location: int, cctv: int, time: str, pred_id: int):
    db_notification = models.Notification(location=location, cctv=cctv, time=time, read=0, pred_id=pred_id)
    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    return db_notification

def get_notifications(db: Session,  skip: int = 0, limit: int = 100):
    return db.query(models.Notification).filter(models.Notification.read == 0).order_by(models.Notification.time.desc()).offset(skip).limit(limit).all()

def update_notification_read(db: Session, noti_id: int):
    db_notification = db.query(models.Notification).filter(models.Notification.id == noti_id).first()
    if db_notification:
        db_notification.read = 1
        db.commit()
        db.refresh(db_notification)
    return db_notification

def create_prediction(db: Session, prediction: schemas.PredictionCreate):
    db_prediction = models.Prediction(content=prediction.model_dump_json())
    db.add(db_prediction)
    db.commit()
    db.refresh(db_prediction)
    content = from_json(db_prediction.content)
    return schemas.Prediction(id=db_prediction.id, boxes=content["boxes"], scores=content["scores"], classes=content["classes"])

def get_frequency(db: Session, date: str):
    data = db.query(models.Notification.location, func.count(models.Notification.id)).filter(func.date(models.Notification.time) == date).group_by(models.Notification.location).all()
    frequency_list = [{"location": row[0], "count": row[1]} for row in data]
    return frequency_list