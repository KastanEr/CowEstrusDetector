
from fastapi import FastAPI, Depends, HTTPException, File, Request, UploadFile, Form
from fastapi.responses import FileResponse, HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import ValidationError
from database import init_db, SessionLocal
import crud, schemas, auth
from datetime import datetime, timedelta
from detector import CowBehaviorDetector
from typing import List
import os

model_path = "model.pth"
save_dir = "./static/pred_image"

if not os.path.exists(save_dir):
    os.makedirs(save_dir)

detector = CowBehaviorDetector(model_path=model_path)

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

init_db()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

UPLOAD_DIR = "./static/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.get("/", response_class=HTMLResponse)
async def get_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/result", response_class=HTMLResponse)
async def read_result(request: Request):
    return templates.TemplateResponse("result.html", {"request": request})

@app.get("/image/{image_name}")
async def get_image(image_name: str):
    try:
        image_path = f"./static/pred_image/{image_name}"
        return FileResponse(image_path, media_type="image/jpeg")
    except Exception as e:
        raise HTTPException(status_code=404, detail="Image not found")

@app.post("/upload/")
async def upload_file_and_predict(request: Request, location: int = Form(...), cctv: int = Form(...), file: UploadFile = File(...), db: Session = Depends(get_db)):
    current_time = datetime.now() + timedelta(hours=9)
    current_time = current_time.strftime("%Y-%m-%d %H:%M:%S")

    file_location = f"{UPLOAD_DIR}/{file.filename}"
    with open(file_location, "wb") as f:
        f.write(file.file.read())

    image_path = file_location

    results, visualizer = detector.predict(image_path=image_path)

    if results is None:
        raise HTTPException(status_code=422, detail="Prediction failed")

    try:
        results["confirm"] = 0
        prediction = schemas.PredictionBase.model_validate(results)
    except ValidationError:
        raise HTTPException(status_code=422, detail="Validation Error")
    
    prediction = crud.create_prediction(db, prediction)

    if not prediction:
        raise HTTPException(status_code=404, detail="Prediction creation failed")
    
    detector.save_image(visualizer, prediction.id)

    if "mounting" in results["classes"]:
        notification = crud.create_notification(db, location, cctv, current_time, prediction.id)
        if not notification:
            raise HTTPException(status_code=404, detail="Notification creation failed")

    return JSONResponse(content={"image_name": f"{prediction.id}"})

@app.get("/notifications", response_model=List[schemas.Notification])
async def get_notifications(skip: int = 0, limit: int = 100, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    auth.decode_token(token)
    notifications = crud.get_notifications(db, skip, limit)
    return notifications

@app.get("/history", response_model=List[schemas.Notification])
async def get_history(date: str, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    auth.decode_token(token)
    history = crud.get_history(db, date)
    return history

@app.get("/predictions", response_model=List[schemas.Prediction])
async def get_predictions(skip: int = 0, limit: int = 100, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    auth.decode_token(token)
    predictions = crud.get_predictions(db, skip, limit)
    return predictions

@app.put("/predictions/confirm/{id}")
async def confirm_prediction(id: int, confirm: int, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    auth.decode_token(token)
    if crud.update_prediction_confirm(db, id, confirm):
        return {"id": id, "confirm": confirm}
    else:
        raise HTTPException(status_code=404, detail="Prediction not found")

@app.get("/frequency/location", response_model=List[schemas.LocationFrequency])
async def get_location_frequency(start_date: str, end_date: str, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    auth.decode_token(token)
    frequency = crud.get_location_frequency(db, start_date, end_date)
    return frequency

@app.get("/frequency/time", response_model=List[schemas.TimeFrequency])
async def get_time_frequency(start_date: str, end_date: str, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    auth.decode_token(token)
    frequency = crud.get_time_frequency(db, start_date, end_date)
    return frequency

@app.post('/users/', response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail='username already registered')
    return crud.create_user(db=db, user=user)

@app.get('/users/{username}', response_model=schemas.User)
def get_user(username: str, db: Session = Depends(get_db)):
    user = crud.get_user(db, username=username)
    if user is None:
        raise HTTPException(status_code=404, detail='User not found')
    return user

@app.get('/users/', response_model=List[schemas.User])
def get_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = crud.get_users(db, skip=skip, limit=limit)
    return users

@app.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = auth.authenticate_user(db, form_data.username, form_data.password)
    if user is None:
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    access_token = auth.create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}