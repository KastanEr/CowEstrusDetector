from typing import List

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

from fastapi.middleware.cors import CORSMiddleware

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post('/users/', response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail='username already registered')
    return crud.create_user(db=db, user=user)

@app.get('/users/', response_model=List[schemas.User])
def get_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = crud.get_users(db, skip=skip, limit=limit)
    return users

@app.get('/users/{username}', response_model=schemas.User)
def get_user(username: str, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, username=username)
    if db_user is None:
        raise HTTPException(status_code=404, detail='User not found')
    return db_user

@app.get('/users/{username}/verify/', response_model=schemas.UserDetail)
def verify_user(username: str, password: str, db: Session = Depends(get_db)):
    db_user = crud.verify_user(db, username=username, password=password)
    if db_user is None:
        raise HTTPException(status_code=404, detail='User authentication failed')
    return db_user

@app.get('/users/{username}/pastes', response_model=List[schemas.Paste])
def get_pastes(username: str, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    pastes = crud.get_pastes(db, username=username, skip=skip, limit=limit)
    if pastes is None:
        raise HTTPException(status_code=404, detail='User not found')
    return pastes

@app.post('/users/{username}/pastes', response_model=schemas.Paste)
def create_paste(username: str, password: str, paste: schemas.PasteCreate, db: Session = Depends(get_db)):
    db_paste = crud.create_paste(db, username=username, password=password, paste=paste)
    if db_paste is None:
        raise HTTPException(status_code=404, detail='User authentication failed')
    return db_paste

@app.get('/pastes/', response_model=List[schemas.Paste])
def get_pastes(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    pastes = crud.get_pastes(db, username=None, skip=skip, limit=limit)
    return pastes