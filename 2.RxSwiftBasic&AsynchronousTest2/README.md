# iOS 비동기 처리 방식 

## DispatchQueue를 이용한 처리 

```swift
    @IBAction func loadImageAsync(_ sender: Any) {
        // TODO: async
        // Queue 에는 sync async ConcurrencyQueue와 serialQueue 총 네개존재
        DispatchQueue.global().async {
            // async하게 작용
            let image = self.getImage(from: self.IMAGE_URL)
            // UI업데이트는 main에서
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

        private func getImage(from imageUrl: String) -> UIImage? {
        guard let url = URL(string: imageUrl) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }

        let image = UIImage(data: data)
        return image
    }
```

iOS에서 기본으로 제공하는 DispatchQueue를 이용해서 이미지를 다운로드 받는 코드이다. 우선 DispatchQueue에서 제공하는 큐는 네가지의 종류가 있다.

- ConcurrencyQueue  sync / async
- SerialQueue sync / async

위의 코드에선 기본으로 제공하는 DispatchQueue를 이용하여 global Queue와 main Queue를 나누어 수행 해 주었다. 이미지를 받아오는 작업을 크게 global async 로 그 안에 UI를 변경하는 작업 즉 imageView를 변경시킨 작업은 main 스레드 에서 작업하도록 main Queue를 사용하였다.

##### 

## PromiseKit을 이용한 처리

iOS의 비동기 제어를 위한 외부라이브러리 중 많은 사람들이 사용하는 PromiseKit 이다. 간단하게 사용법을 정리하겠다.

#### Escaping Closure 사용

우선 DisaptchQueue를 이스케이핑 클로저 함수 내부에 넣어 이미지를 받아오는 작업을 하고 난 다음 성공한 이미지 객체를 반환하는 코드를 작성한다.

```swift
func asyncLoadImage(from imageUrl: String, completed: @escaping (UIImage?) -> Void) {
    DispatchQueue.global().async {
    		guard let url = URL(string: imageUrl) else { return nil }
    		guard let data = try? Data(contentsOf: url) else { return nil }
    		let image = UIImage(data: data)
        completed(image)
    }
}

 @IBAction func loadImageAsync(_ sender: Any) {
        imageView.image = nil
        
        // 함수가 Promise<Image> 객체를 반환하기 때문에 .done .catch로 제어가 가능하다.
        promiseLoadImage(from: LARGER_IMAGE_URL)
            .done { image in
                self.imageView.image = image
            }.catch { error in
                print(error.localizedDescription)
            }
    }

    // MARK: - PromiseKit

    func promiseLoadImage(from imageUrl: String) -> Promise<UIImage?> {
        return Promise<UIImage?>() { seal in
            // 비동기적으로 이미지 다운로드
            asyncLoadImage(from: imageUrl) { image in
                // seal 에게 완료가 되었는지 넘겨준다.
                seal.fulfill(image)
            }
        }
    }
```

위에서 `promiseLoadImage(from:)` 함수 에서 비동기적으로 이미지 파일을 다운 받고 성공을 하면 seal 객체에 `fulfill()` 매서드를 통해 이미지를 넘겨 준다. 마찬가지로 이 함수는 PromiseKit의 `Promise<T>` 를 반환하는 함수기 때문에 `.done` 과 `.catch` 로 핸들링이 가능하다.



## BoltsSwift를 이용한 제어

BoltsSwift도 비동기 제어를 위한 외부라이브러리이다. 기본적인 구조는 PromiseKit과 비슷하다 제공하는 함수만 다를 뿐이다.

```swift
 @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil

        boltsLoadImage(from: LARGER_IMAGE_URL)
            .continueWith(continuation: { task in
                DispatchQueue.main.async {
                    let image = task.result
                    self.imageView.image = image
                }
            })
    }

    // MARK: - Bolts

    func boltsLoadImage(from imageUrl: String) -> Task<UIImage> {
        let taskCompletionSource = TaskCompletionSource<UIImage>()
        asyncLoadImage(from: imageUrl, completed: { image in
            guard let image = image else {
                taskCompletionSource.cancel()
                return
            }
            taskCompletionSource.set(result: image)
        })
        return taskCompletionSource.task
    }
```

Bolt에서는 Task<T> 라는 객체를 사용한다 그리고  `taskCompletionSource<T>` 객체를 사용하여 이스케이핑 클로져 함수의 반환 값을 핸들링 한다. 옵셔널 바인딩을 통해 값을 가져오는데 실패하면 `.cancel()` 값을 가져오는데 성공하면 성공한 값을 `.set()` 을 통해 `taskCompletionSource` 의 task 값을 설정한다.

그렇게 성공한 값은 `.continueWith()` 메서드를 통해 성공한 값은 클로저로 작성한 task 매개변수의 result를 통해 접근하여 가져올 수 있다.



## RxSwif의 제어 방식

사실 기존의 Async(비동기) 하게 무언가를 작업을 수행하는 궁극 적인 목적은 위의 외부라이브러리나 다  동일하다.

>  RxSwift 에서 궁극적으로 추구하는 것은 **조금 더 쉽게, 조금 더 간결하게**  이다.