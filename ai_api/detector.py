from detectron2.engine import DefaultTrainer
from detectron2.config import get_cfg
from detectron2 import model_zoo
from detectron2.utils.visualizer import Visualizer, ColorMode
from detectron2.engine import DefaultPredictor
from detectron2.data import MetadataCatalog
import cv2
import matplotlib.pyplot as plt
import os

class CowBehaviorDetector:
    def __init__(self, model_path: str, score_threshold: float = 0.7, device: str = "cpu", save_dir: str = "./static/pred_image"):
        self.model_path = model_path
        self.score_threshold = score_threshold
        self.device = device
        self.save_dir = save_dir  # 이미지 저장 경로 설정

        self.categories = [{'id': 1, 'name': 'standing'}, 
                           {'id': 2, 'name': 'lying'}, 
                           {'id': 3, 'name': 'eating'}, 
                           {'id': 4, 'name': 'head shaking'}, 
                           {'id': 5, 'name': 'tailing'}, 
                           {'id': 6, 'name': 'sitting'}, 
                           {'id': 7, 'name': 'mounting'}]
        
        # 메타데이터 등록
        self._register_metadata()
        
        # 모델 설정 초기화
        self.cfg = get_cfg()
        self.cfg.merge_from_file(model_zoo.get_config_file("COCO-Detection/faster_rcnn_R_50_FPN_3x.yaml"))
        self.cfg.MODEL.WEIGHTS = os.path.join(self.model_path)
        self.cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = self.score_threshold
        self.cfg.MODEL.ROI_HEADS.NUM_CLASSES = len(self.categories)
        self.cfg.MODEL.DEVICE = self.device

        # Predictor 생성
        self.predictor = DefaultPredictor(self.cfg)
    
    def _register_metadata(self):
        thing_classes = [category['name'] for category in self.categories]
        MetadataCatalog.get("cow_polygon_val").set(thing_classes=thing_classes)

    def _save_image(self, image, visualizer, image_name):
        save_path = os.path.join(self.save_dir, f"{image_name}.jpg")
        plt.figure(figsize=(10, 10))
        plt.imshow(visualizer.get_image()[:, :, ::-1])
        plt.axis("off")
        plt.savefig(save_path, bbox_inches='tight')

    def predict(self, image_path: str, image_name: str):
        try:
            image = cv2.imread(image_path)
            if image is None:
                raise ValueError(f"Image at path {image_path} could not be loaded.")
                
            outputs = self.predictor(image)

            instances = outputs["instances"].to("cpu")
            boxes = instances.pred_boxes if instances.has("pred_boxes") else None
            scores = instances.scores if instances.has("scores") else None
            classes = instances.pred_classes if instances.has("pred_classes") else None

            metadata = MetadataCatalog.get("cow_polygon_val")

            visualizer = Visualizer(image[:, :, ::-1], metadata=metadata, scale=1.2, instance_mode=ColorMode.IMAGE_BW)
            visualizer = visualizer.draw_instance_predictions(outputs["instances"].to("cpu"))
            self._save_image(image, visualizer, image_name)
            
            return {
                "boxes": boxes.tensor.numpy().tolist(),
                "scores": scores.numpy().tolist(),
                "classes": [metadata.thing_classes[i] for i in classes]
            }
        except Exception as e:
            print(f"Error during prediction: {e}")
            return None