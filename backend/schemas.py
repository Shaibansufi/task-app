from pydantic import BaseModel
from typing import Optional

class Task(BaseModel):
    id: Optional[str]
    title: str
    description: str
    due_date: str
    status: str
    blocked_by: Optional[str]

    class Config:
        orm_mode = True