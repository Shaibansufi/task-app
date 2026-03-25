from sqlalchemy import Column, String
from database import Base

class TaskModel(Base):
    __tablename__ = "tasks"

    id = Column(String, primary_key=True, index=True)  # UUID string
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    due_date = Column(String, nullable=False)
    status = Column(String, nullable=False)
    blocked_by = Column(String, nullable=True)