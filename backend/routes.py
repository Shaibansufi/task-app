from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import time, uuid
from models import TaskModel
from schemas import Task
from database import get_db

router = APIRouter()

# GET all tasks
@router.get("/tasks", response_model=list[Task])
def get_tasks(db: Session = Depends(get_db)):
    return db.query(TaskModel).all()

# CREATE task
@router.post("/tasks", response_model=Task)
def create_task(task: Task, db: Session = Depends(get_db)):
    time.sleep(2)
    db_task = TaskModel(
        id=str(uuid.uuid4()),
        title=task.title,
        description=task.description,
        due_date=task.due_date,
        status=task.status,
        blocked_by=task.blocked_by
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

# UPDATE task
@router.put("/tasks/{task_id}", response_model=Task)
def update_task(task_id: str, task: Task, db: Session = Depends(get_db)):
    time.sleep(2)
    db_task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db_task.title = task.title
    db_task.description = task.description
    db_task.due_date = task.due_date
    db_task.status = task.status
    db_task.blocked_by = task.blocked_by
    db.commit()
    db.refresh(db_task)
    return db_task

# DELETE task
@router.delete("/tasks/{task_id}")
def delete_task(task_id: str, db: Session = Depends(get_db)):
    db_task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(db_task)
    db.commit()
    return {"message": "Deleted"}