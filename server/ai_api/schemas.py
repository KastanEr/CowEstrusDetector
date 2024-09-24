from typing import List, Union

from pydantic import BaseModel

class PredictResult(BaseModel):
    username: str