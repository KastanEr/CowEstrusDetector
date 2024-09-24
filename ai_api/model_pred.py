from detectron2.engine import DefaultTrainer
from detectron2.config import get_cfg
from detectron2 import model_zoo
from detectron2.utils.visualizer import Visualizer, ColorMode
from detectron2.engine import DefaultPredictor
from detectron2.data import MetadataCatalog
import cv2
import matplotlib.pyplot as plt
import os
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.responses import FileResponse
from fastapi.responses import RedirectResponse
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.requests import Request
from datetime import datetime, timedelta

# 메타데이터 등록
ADE_CATEGORIES = [{'id': 1, 'name': 'standing'}, 
                  {'id': 2, 'name': 'lying'}, 
                  {'id': 3, 'name': 'eating'}, 
                  {'id': 4, 'name': 'head shaking'}, 
                  {'id': 5, 'name': 'tailing'}, 
                  {'id': 6, 'name': 'sitting'}, 
                  {'id': 7, 'name': 'mounting'}]

# 메타데이터를 등록하는 함수
def register_metadata():
    thing_classes = [category['name'] for category in ADE_CATEGORIES]
    MetadataCatalog.get("cow_polygon_val").set(thing_classes=thing_classes)

register_metadata()

# 1. 모델 설정 가져오기
cfg = get_cfg()
cfg.merge_from_file(model_zoo.get_config_file("COCO-Detection/faster_rcnn_R_50_FPN_3x.yaml"))

dir = "./"
# 2. 학습된 가중치 로드
cfg.MODEL.WEIGHTS = os.path.join(dir, "model_final.pth")
cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.7  # 예측 시 사용할 점수 임계값 설정 70퍼이상만 표시
cfg.MODEL.ROI_HEADS.NUM_CLASSES = len(ADE_CATEGORIES)  # 클래스 수 설정
cfg.MODEL.DEVICE = "cpu"

# 3. Predictor 생성
predictor = DefaultPredictor(cfg)

db = []

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

UPLOAD_DIR = "./static/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/image/{image_name}")
async def get_image(image_name: str):
    try:
        image_path = f"./static/pred_image/{image_name}"
        return FileResponse(image_path, media_type="image/jpeg")
    except Exception as e:
        raise HTTPException(status_code=404, detail="Image not found")

@app.post("/upload/")
async def upload_file_and_predict(request: Request, file: UploadFile = File(...)):
    file_location = f"{UPLOAD_DIR}/{file.filename}"
    with open(file_location, "wb") as f:
        f.write(file.file.read())

    # 4. 이미지 예측
    image_path = file_location
    image = cv2.imread(image_path)
    outputs = predictor(image)

    # 5. 예측 결과 출력
    instances = outputs["instances"].to("cpu")
    boxes = instances.pred_boxes if instances.has("pred_boxes") else None
    scores = instances.scores if instances.has("scores") else None
    classes = instances.pred_classes if instances.has("pred_classes") else None

    # print("Predicted classes:", classes)
    # print("Predicted scores:", scores)
    # print("Predicted boxes:", boxes)

    # 6. 결과 시각화
    metadata = MetadataCatalog.get("cow_polygon_val")
    v = Visualizer(image[:, :, ::-1], metadata=metadata, scale=1.2, instance_mode=ColorMode.IMAGE_BW)
    v = v.draw_instance_predictions(outputs["instances"].to("cpu"))

    predicted_class_names = [metadata.thing_classes[i] for i in classes]
    # print("Predicted class names:", predicted_class_names)

    # OpenCV 대신 matplotlib으로 이미지 출력
    plt.figure(figsize=(10, 10))
    plt.imshow(v.get_image()[:, :, ::-1])
    plt.axis("off")
    plt.savefig(f"./static/pred_image/image.jpg", bbox_inches='tight')

    if 'mounting' in predicted_class_names:
        current_time = datetime.now() + timedelta(hours=9)
        current_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
        db.append({'title': '제 1구획에서 승가 행위가 감지되었습니다.', 'location': '제 1구획', 'cctv': 'CCTV_03', 'time': current_time, 'class': '승가 행위'})
    return RedirectResponse(url="/result", status_code=302)

@app.get("/result", response_class=HTMLResponse)
async def read_result(request: Request):
    return templates.TemplateResponse("result.html", {"request": request})

@app.get("/history")
async def get_history():
    return db