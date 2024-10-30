from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from database import Base

class Prediction(Base):
    __tablename__ = "predictions"
    id = Column(Integer, primary_key=True, index=True)
    confirm = Column(Integer)
    content = Column(String)
    notifications = relationship("Notification", back_populates="prediction")

class Notification(Base):
    __tablename__ = "notifications"
    id = Column(Integer, primary_key=True, index=True)
    location = Column(Integer)
    cctv = Column(Integer)
    time = Column(String)
    pred_id = Column(Integer, ForeignKey("predictions.id"))
    prediction = relationship("Prediction", back_populates="notifications")

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(length=128), unique=True, index=True)
    salt = Column(String(length=128))
    password = Column(String(length=128))