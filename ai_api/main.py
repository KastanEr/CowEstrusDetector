
from fastapi import FastAPI, Depends, HTTPException, File, Request, UploadFile, Form
from fastapi.responses import FileResponse, HTMLResponse, RedirectResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from pydantic import ValidationError
from database import init_db, SessionLocal
import crud, models, schemas
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
    image_name = current_time

    results = detector.predict(image_path=image_path, image_name=image_name)

    if "mounting" in results["classes"]:
        try:
            prediction = schemas.PredictionBase.model_validate(results)
        except ValidationError:
            raise HTTPException(status_code=422, detail="Validation Error")

        prediction = crud.create_prediction(db, prediction)
        if not prediction:
            raise HTTPException(status_code=404, detail="Prediction creation failed")

        notification = crud.create_notification(db, location, cctv, current_time, prediction.id)
        if not notification:
            raise HTTPException(status_code=404, detail="Notification creation failed")

    return JSONResponse(content={"image_name": image_name})

@app.get("/notifications", response_model=List[schemas.Notification])
async def get_notification(db: Session = Depends(get_db)):
    notifications = crud.get_notifications(db)
    return notifications

@app.put("/notifications/read/{id}")
async def read_notification(id: int, db: Session = Depends(get_db)):
    if crud.update_notification_read(id, db):
        return {"message": "Notification marked as read", "noti_id": id}
    else:
        raise HTTPException(status_code=404, detail="Notification not found")
    
@app.get("/frequency", response_model=List[schemas.Frequency])
async def get_frequency(date: str, db: Session = Depends(get_db)):
    frequency = crud.get_frequency(db, date)
    return frequency