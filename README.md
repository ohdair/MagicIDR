# 앱 화면
사각형을 감지하여 공유할 수 있는 앱
- 감지된 사각형을 자동/수동으로 촬영
- 촬영음 유/무 결정
- 수동으로 촬영된 이미지를 모서리/변을 터치에 따라 수정할 수 있는 모드 지원
- 촬영된 이미지 삭제 및 회전 그리고 공유 기능
  
|메인화면|편집화면|미리보기화면|
|:---:|:---:|:---:|
|<img src="https://github.com/ohdair/MagicIDR/assets/79438622/e8a0e37f-7eb4-4bd1-ae44-e81104c0839f" width=200>|<img src="https://github.com/ohdair/MagicIDR/assets/79438622/6746e161-9bdd-48df-8ef3-a825030efbbf" width=200>|<img src="https://github.com/ohdair/MagicIDR/assets/79438622/c7b1fa7f-bf4d-4236-bede-1efa84b55de5" width=200>|

# 앱 동작

|자동촬영|UI 변경|편집화면|
|:---:|:---:|:---:|
|<img src="https://github.com/ohdair/MagicIDR/assets/79438622/013b2320-28a6-41c1-8b18-3394e155a4fe" width=200>|<img src="https://github.com/ohdair/MagicIDR/assets/79438622/eeb59e17-f8ba-408e-9762-4412acb4d498" width=200>|<img src="https://github.com/ohdair/MagicIDR/assets/79438622/3511d04e-d1e0-458d-9307-94c08e96c688" width=200>|

## 흐름에 따른 다이어그램
각 View에 따라 유저 제스처에 대한 동작을 다이어그램으로 표현

<img width="600" alt="스크린샷 2024-02-05 오후 9 10 47" src="https://github.com/ohdair/MagicIDR/assets/79438622/352fd438-f0c3-4b9b-a951-3ed378a5f726">

## 촬영 모드
프레임워크 `AVFoundation`를 활용
1. 카메라 촬영하는 영상의 데이터에서 이미지를 View에 반영
2. 촬영 버튼을 클릭 시, Capture된 이미지를 가져옴
3. 1번에서 받아온 이미지에서 `CIDetector`를 사용하여 사각형을 감지
4. (자동 모드) 3번에서 감지 시간이 1.5초 후 촬영
5. 촬영되면 좌측 하단 미리보기에 마지막 이미지 및 갯수를 표현
6. 모드 변경을 위한 Custom Button 추가

#### ◼︎ Async/Await 함수 생성
이미지 데이터를 CIImage로 만들고 넘기기 위해 `Async/Await` 함수를 만들어서 전달
```swift
class Scanner: NSObject {
    private var scanSuccessBlock: ((CIImage?) -> Void)?

    func scan() async -> CIImage? {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    
        return await withCheckedContinuation { continuation in
            scanSuccessBlock = { image in
                continuation.resume(returning: image)
            }
        }
    }
}

extension Scanner: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            scanSuccessBlock?(nil)
            return
        }

        if let data = photo.fileDataRepresentation() {
            let image = CIImage(data: data)
            scanSuccessBlock?(image)
        }
    }
}
```
#### ◼︎ 촬영음을 음소거 가능하도록 옵션 추가
국가마다 촬영음의 유무가 있겠지만, 기능을 추가할 수 있도록 코드를 반영
<img width="600" src="https://github.com/ohdair/MagicIDR/assets/79438622/86052ef5-39ec-4f19-a4f2-8e2fc21992c1">

```swift
extension Scanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if isMuted {
            AudioServicesDisposeSystemSoundID(1108)
        } else {
            AudioServicesPlaySystemSound(1108)
        }
    }
}
```

#### ◼︎ 인식되는 시간을 Timer로 활용하여 측정
약 1.5초를 인식하는 동안 애니메이션과 연동할 수 있도록 진행상황을 delegate로 전달
16.7%의 진행도를 보여주며, 1.5초가 도달하게 되었다면 촬영할 수 있도록 delegate로 전달

```swift
class AutoDetector {
    // ...
    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    @objc private func fireTimer() {
        processing += 0.167
        delegate?.autoDectectorDidDetected(self, processing: processing)

        if processing >= 1.0 {
            delegate?.autoDectectorCompleted(self)
            resetTimer()
        }
    }
}
```

#### ◼︎ 감지된 사각형을 View에 표현
`CIDetector`의 `CIDetectorTypeRectangle` 필터를 사용하여 이미지 내 사각형을 감지
감지된 `CIRectangleFeature`의 값은 촬영된 이미지 내 사각형의 좌표로 보정이 필요
좌우 반전, 각도 변경 등 디바이스의 크기와 맞추기 위해 값을 보정

## 미리보기 모드
촬영된 이미지들을 유저의 `slide` 제스쳐를 통해 이미지를 한 장씩 볼 수 있도록 표현
촬영된 이미지를 반시계 회전/삭제를 할 수 있는 모드

#### ◼︎ UIPageViewController를 사용하여 표현
`slide`를 통해 좌, 우로 촬영된 이미지를 볼 수 있도록 표현
이미지가 삭제되는 index에 따라 애니메이션을 다르게 표현

```swift
@objc private func deleteImage() {
    // 현재 content의 pageIndex 탐색
    guard let viewController =  self.pageViewController.viewControllers?.first,
          let contentController = viewController as? ContentViewController,
          let currentIndex = contentController.pageIndex else {
        return
    }

    images.remove(at: currentIndex)

    // 데이터가 없다면 촬영 모드로 돌아가기
    guard !images.isEmpty else {
        delegate?.previewViewControllerWillDisappear(self, images: images)
        navigationController?.popViewController(animated: true)
        return
    }

    // 삭제된 index가 마지막 번호였다면 index - 1로 .reverse 형태로 표현
    guard currentIndex != images.count else {
        let willAppearController = contentViewController(atIndex: currentIndex - 1)!
        pageViewController.setViewControllers([willAppearController],
                                              direction: .reverse,
                                              animated: true)
        setTitle(withIndex: currentIndex - 1)
        return
    }

    // 위 조건을 제외한 모든 경우의 수는 삭제된 index의 데이터로 .forward 형태로 표현
    let willAppearController = contentViewController(atIndex: currentIndex)!
    pageViewController.setViewControllers([willAppearController],
                                          direction: .forward,
                                          animated: true)

    setTitle(withIndex: currentIndex)
}
```

#### ◼︎ 이미지의 정보를 읽어와 반시계로 회전
해당 이미지의 orientation을 읽어서 새로운 이미지로 생성하도록
`UIImage(ciImage:scale:orientation:)`를 사용하여 반환

```swift
func rotateCounterClockwise() -> UIImage? {
    var newOrientation: UIImage.Orientation?

    switch self.imageOrientation {
    case .up:
        newOrientation = .left
    case .down:
        newOrientation = .right
    case .left:
        newOrientation = .down
    case .right:
        newOrientation = .up
    default:
        break
    }

    // ...
}
```

## 편집 모드
촬영된 이미지에서 감지된 사각형이 있다면 이미지를 자를 수 있는 사각형이 존재
터치에 따라 사각형의 모양을 변경할 수 있도록 표현

#### ◼︎ 감지된 사각형 모서리의 좌표를 표현하는 View
`func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)` 함수를 재정의하여 표현
터치를 할 떄마다 View가 놓여지는 위치 및 사각형을 다시 그릴 수 있도록 표현

#### ◼︎ 사각형을 그리는 path
`func draw(_ rect: CGRect)` 함수를 재정의하여 path를 표현
사각형 모서리들의 좌표가 달라질 때마다 새로 그려질 수 있도록 `setNeedsDisplay()`를 호출
좌표들을 사용하여 context 위에 path를 그리기

#### ◼︎ 사각형의 변을 터치하여도 모서리들의 좌표가 변경 가능한 View
View는 `frame`을 기반으로 그려지기 때문에 직선의 형태에 터치할 때에만 변경할 수 있도록
`func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?`를 재정의하여서 사용
내부 속성으로 좌표를 가지고 있어 직선과 터치하는 부분의 거리를 측정

```swift
override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let line = line(start: startPoint, end: endPoint)
    let distance = distance(to: line, from: point)
    if distance <= 10 {
        return self
    }
    return nil
}
```

또한, superView를 넘어가지 않도록 하기 위해서 `outOfSuperview`로 참/거짓을 확인
제스처가 넘어가더라도 이동하지 못하도록 방지

```swift
private func outOfSuperview(through point: CGPoint) -> Bool {
    guard let superview else {
        return true
    }

    let limitX = superview.bounds.maxX
    let limitY = superview.bounds.maxY

    guard startPoint.x + point.x > 0,
          startPoint.x + point.x < limitX,
          endPoint.x + point.x > 0,
          endPoint.x + point.x < limitX,
          startPoint.y + point.y > 0,
          startPoint.y + point.y < limitY,
          endPoint.y + point.y > 0,
          endPoint.y + point.y < limitY else {
        return true
    }

    return false
}
```
---
## 변경된 UI
SwiftUI로 연결된 촬영 수동/자동 모드 및 촬영음 유/무를 선택하는 애니메이션을 추가한 View
이미지를 탭하면 옵션을 선택할 수 있는 애니메이션 추가

```swift
private lazy var abilitiesController = UIHostingController(rootView: abilitiesView)

view.addSubview(abilitiesController.view)
abilitiesController.view.backgroundColor = .clear
```
