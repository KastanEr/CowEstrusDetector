from pydantic import BaseModel, field_validator
from typing import List, Any
import json


class PredictionBase(BaseModel):
    boxes: List[List[float]]
    scores: List[float]
    classes: List[str]

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
    read: int
    pred_id: int

class NotificationCreate(NotificationBase):
    pass

class Notification(NotificationBase):
    id: int

    class Config:
        from_attributes = True

class Frequency(BaseModel):
    location: int
    count: int