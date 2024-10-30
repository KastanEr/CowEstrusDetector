from sqlalchemy import func, and_, extract
from sqlalchemy.orm import Session
import models, schemas
from pydantic_core import from_json
import hashlib, secrets

def create_notification(db: Session, location: int, cctv: int, time: str, pred_id: int):
    db_notification = models.Notification(location=location, cctv=cctv, time=time, pred_id=pred_id)
    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    return db_notification

def get_notifications(db: Session,  skip: int = 0, limit: int = 100):
    return db.query(models.Notification).order_by(models.Notification.time.desc()).offset(skip).limit(limit).all()

def get_history(db: Session, date: str):
    return db.query(models.Notification).filter(func.date(models.Notification.time) == date).order_by(models.Notification.time.desc()).all()

def create_prediction(db: Session, prediction: schemas.PredictionCreate):
    db_prediction = models.Prediction(content=prediction.model_dump_json(), confirm=0)
    db.add(db_prediction)
    db.commit()
    db.refresh(db_prediction)
    content = from_json(db_prediction.content)
    return schemas.Prediction(id=db_prediction.id, boxes=content["boxes"], scores=content["scores"], classes=content["classes"], confirm=db_prediction.confirm)

def get_predictions(db: Session,  skip: int = 0, limit: int = 100):
    db_predictions = db.query(models.Prediction).offset(skip).limit(limit).all()
    prediction_list = []
    for prediction in db_predictions:
        content = from_json(prediction.content)
        prediction_list.append(schemas.Prediction(id=prediction.id,boxes=content["boxes"], scores=content["scores"], classes=content["classes"], confirm=prediction.confirm))
    return prediction_list

def update_prediction_confirm(db: Session, id: int, confirm: int,):
    db_prediction = db.query(models.Prediction).filter(models.Prediction.id == id).first()
    if db_prediction:
        db_prediction.confirm = confirm
        db.commit()
        db.refresh(db_prediction)
    return db_prediction

def get_location_frequency(db: Session, start_date: str, end_date: str):
    data = (
        db.query(models.Notification.location, func.count(models.Notification.id))
        .filter(and_(
            func.date(models.Notification.time) >= start_date,
            func.date(models.Notification.time) <= end_date
        ))
        .group_by(models.Notification.location)
        .all()
    )
    frequency_list = [{"location": row[0], "count": row[1]} for row in data]
    return frequency_list

def get_time_frequency(db: Session, start_date: str, end_date: str):
    data = (
        db.query(extract('hour', models.Notification.time).label('hour'), func.count(models.Notification.id).label('count'))
        .filter(and_(
            func.date(models.Notification.time) >= start_date,
            func.date(models.Notification.time) <= end_date
        ))
        .group_by('hour')
        .order_by('hour')
        .all()
    )
    frequency_list = [{"time": item.hour, "count": item.count} for item in data]
    return frequency_list

def create_user(db: Session, user: schemas.UserCreate):
    m = hashlib.sha256()
    salt = secrets.token_bytes(16).hex()
    m.update(user.password.encode('utf-8'))
    m.update(bytes.fromhex(salt))
    password = m.hexdigest()

    db_user = models.User(username=user.username, salt=salt, password=password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_user(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).order_by(models.User.id.asc()).offset(skip).limit(limit).all()