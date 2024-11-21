# 소 발정 탐지 API
소의 행동 데이터를 학습시킨 Detectron2 모델을 통해 소의 발정 행동을 탐지하고 시간 및 구역별 발정 빈도를 제공합니다. 이 API는 FastAPI를 사용한 RESTful API 서버이며, JWT 기반 사용자 인증 기능을 지원합니다.

## 주요 기능
- **소 발정 행동 탐지**: 이미지에서 소의 행동을 분석하여 발정 행동 여부를 탐지합니다.
- **발정 빈도 통계**: 시간대와 구역에 따른 소의 발정 빈도를 조회할 수 있는 통계 기능을 제공합니다.
- **회원 가입 및 사용자 관리**: 새로운 사용자를 등록하고, 비밀번호를 해시 처리하여 안전하게 저장합니다.
- **JWT 인증**: 로그인 후 JWT 토큰을 발급하고, 각 API 요청에 대해 토큰을 검증하여 사용자 인증을 수행합니다.

## 시스템 다이어그램
![System Architecture Diagram](assets/system-diagram.png)

## 요구사항
- Python 3.10+
- Detectorn2
- FastAPI
- SQLAlchemy
- SQLite3
- FCM
- Docker (옵션)

## 설치 및 실행 방법
1. **프로젝트 클론**
   ```bash
   git clone https://github.com/KastanEr/CowEstrusDetector.git
   ```
   ```bash
   cd CowEstrusDetector/ai_api
   ```  

2. **모델 다운로드**  
   [Google Drive 링크](https://drive.google.com/file/d/1JaSq2qgo8gM3uOHgEdYbvLdcjxNwMMQl/view?usp=share_link)를 클릭하여 모델 파일을 다운로드하고, 다운로드한 파일을 프로젝트의 루트 디렉토리 아래 `ai_api` 폴더에 배치하세요.  

3. **요구사항 설치**
   ```bash
   apt update
   ```
   패키지 목록을 업데이트합니다.
   ```bash
   apt install net-tools vim git python3-dev python3-venv python3-pip libgl1-mesa-glx libglib2.0-0
   ```
   필요한 시스템 패키지를 설치합니다.
   ```bash
   pip install torch torchvision opencv-python fastapi uvicorn sqlalchemy pyjwt python-multipart pyfcm
   ```
   Python의 필수 라이브러리를 설치합니다.
   ```bash
   pip install 'git+https://github.com/facebookresearch/detectron2.git'
   ```
   Detectron2 모델을 설치합니다.

4. **API 실행**
   ```bash
   uvicorn main:app --host 0.0.0.0 --reload
   ```

5. **Swagger UI 접속**  
   서버가 실행된 후 http://localhost:8000/docs 에서 API 문서를 확인하고 테스트할 수 있습니다.

## 모델 학습과정 및 성능 안내
### 학습 데이터
  - AIHub에서 제공하는 한우의 발정 행동 데이터 사용
    - 소(한우, 젖소) 및 돼지 발정행동 데이터를 이용하여 Detectron2 모델에 학습하였습니다.
    - AI HUB(https://www.aihub.or.kr/)
  - 모델 구현 과정은 다음과 같은 단계로 이루어졌습니다.
    1. 데이터 전처리  
        - 먼저, AIHub에서 제공하는 원천 데이터에서 이상 파일들을 제거하는 전처리 과정을 거쳤습니다. 이 과정에서 이미지와 JSON 파일이 뒤섞이거나 손상된 파일, 형식에 맞지 않은 파일 등을 제거하였습니다. 이를 통해 모델 학습에 적합한 데이터셋을 확보하였습니다.
    2. 데이터셋 변환  
        - 전처리된 데이터를 Detectron2 모델에서 사용할 수 있도록 COCO 형식으로 변환하였습니다.
        - Detectron2 모델 출처(https://github.com/facebookresearch/detectron2/)
  - 학습데이터는 COCO 형식을 사용했습니다.
    - COCO 형식은 다음과 같은 요소를 포함합니다.
      - 이미지 정보: 이미지 파일명, 경로, 크기 등의 메타데이터.
      - 어노테이션 정보: 각 객체의 경계 상자(bounding box), 카테고리(소의 행동), 세그멘테이션(Polygon, keypoints) 등의 정보.
  - AI hub 데이터에서 mounting에 대한 라벨 데이터가 전체 데이터비율에 있어서 5% 미만으로 존재하여 모델 학습후 mounting에 대해 예측 못하는 결과가 발생했습니다. 이러한 문제를 해결하기 위해 mounting 데이터에 대해 데이터 증강을 실시하여, 해당 클래스에 해당하는 대상을 더 잘 찾을 수 있도록 보완하였습니다. 또한 mounting 행동에 대해 예측시 과적합 문제가 있을 수 있기 때문에, 영상데이터에서 mounting 하는 부분을 더 찾아 라벨링 작업을 수행한 후 이들을 이용하여 추가적인 학습을 진행하였습니다.

### 학습 과정
  1. 데이터셋 등록
     - 변환된 COCO 형식의 어노테이션 파일들을 Detectron2에 등록하기 위해 다음과 같은 작업을 수행하였습니다.
       - register_coco_instances 함수를 이용하여 커스텀 데이터셋을 등록.
       - _get_ade_instances_meta 함수를 통해 메타데이터를 업데이트 했습니다.

  2. 모델 학습 설정
     - 데이터셋 등록이 완료된 후, 모델 학습을 위한 설정을 진행하였습니다.
       - Iteration 설정: 이번 프로젝트에서는 총 191,940번의 iteration을 수행하도록 설정하였습니다. 이는 30 epoch에 해당하며, 충분한 학습을 통해 모델의 성능을 극대화하기 위함입니다.
     - 사전학습 가중치 설정: Detectron2의 모델 저장소에서 제공하는 사전 학습된 Faster R-CNN R50-FPN 3x 모델의 가중치를 사용하였습니다.
     - GPU 사용: RTX 3090ti를 사용하여 학습을 진행했습니다.

  3. 모델 학습
     - GPU 서버에서 학습을 진행하였습니다. 이 과정에서 다음과 같은 추가 설정을 수행하였습니다:
     - 하이퍼파라미터 Dataloader 설정: 병렬 처리를 위해 데이터 로더의 워커(worker) 수를 8로 설정하였습니다.
     - 배치 크기 및 학습률 설정: 한 번에 학습하는 이미지 수와 학습률을 각각 2와 0.00025로 설정하였습니다. 모델이 학습된 후에는 검증을 진행했습니다.

  4. 모델 평가  
  모델의 성능을 정량적으로 평가하기 위해 COCO 형식의 평가자(COCOEvaluator)를 사용하여 검증 데이터셋에 대한 추론을 수행하였습니다. 이를 위해 Detectron2 라이브러리에서 제공하는 평가 도구를 활용하였습니다.

### 모델 성능
- 카테고리별 성능
  - 높은 성능: standing, lying, eating 카테고리에서 높은 AP 값을 보였습니다. 이는 모델이 이 행동들을 잘 탐지할 수 있음을 나타냅니다.
  - 중간 성능: head shaking, tailing 카테고리는 중간 수준의 성능을 보였습니다.
  - 낮은 성능: sitting과 mounting 카테고리는 상대적으로 낮은 AP로, 모델이 이 두 행동을 잘 탐지하지 못했음을 의미합니다. 이는 이 행동들이 데이터셋 내에서 상대적으로 적게 있어 모델이 충분히 학습하지 못한 것으로 파악됩니다.
- 크기별 성능
  - 중간 크기 객체에 대한 성능이 낮은 반면, 큰 객체에 대해서는 좋은 성능을 보입니다.
