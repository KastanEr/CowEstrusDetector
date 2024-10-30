from pydantic import BaseModel, field_validator
from typing import List

class PredictionBase(BaseModel):
    boxes: List[List[float]]
    scores: List[float]
    classes: List[str]
    confirm: int # 0: 확인 안함, 1: 확인, 2: 확인했는데 결과가 다름

    class Config:
        from_attributes = True

class PredictionCreate(PredictionBase):
    pass

class Prediction(PredictionBase):
    id: int

class NotificationBase(BaseModel):
    location: int
    cctv: int
    time: str
    pred_id: int

class NotificationCreate(NotificationBase):
    pass

class Notification(NotificationBase):
    id: int

    class Config:
        from_attributes = True

class LocationFrequency(BaseModel):
    location: int
    count: int

class TimeFrequency(BaseModel):
    time: int
    count: int

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int

    class Config:
        from_attributes = True

class UserDetail(User):
    salt: str