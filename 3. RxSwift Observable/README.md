# Observable

비동기 프로그래밍의 기본은 관찰할 수 있는 이벤트(Observable) 가 발생하는 시점을 관찰, 구독(Subscribe) 함에 있다. 그중에 RxSwift에서 제공하는 **Observable**이라는 클래스는 관찰할 수 있는 이벤트 그 자체를 의미한다.



## Observable 이란?

Rx에서 핵심이 되는 기능이다.  Observable 들은 일정 기간 동안 계속해서 **이벤트** 를 생성하며, 이러한 과정을 보통 **emitting(방출)** 이라고 표현한다. 그리고 각각의 이벤트들은 숫자나 커스텀한 인스턴스 등과 같은 값을 가질 수 있으며, 또는 탭과 같은 제스처를 인식할 수 있다.

이러한 개념들을 가장 잘 이해할 수 있는 방법은 marble diagrams를 이용하는 것이다

> marble diagram: 시간의 흐름에 따라서 값을 표시하는 방식으로 왼쪽에서 오른쪽으로 흐른다고 가정한다. 
>
> 참고 : [RxMarble](https://rxmarbles.com)

이전에 Escaping 클로저를 통해 File 객체를 다운로드 완료하면 반환하는 코드를 작성했다.

```swift
 
    func downLoadFile(completion: @escaping (File) -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 5)
            let file = File(name: "비동기파일", size: 42512)
            DispatchQueue.main.async {
                completion(file)
            }
        }
    }
```

이를 RxSwift Observable 의 개념을 활용하여 다음과 같이 변경할 수 있다.

```swift
	func downLodFileObservable() -> Observable<File>{
		return Observable<File>.create{observer in
			let file = File(name: "비동기파일", size: 42512)
      print("file이 생성되었습니다")
			observer.on(.next(file))
			observer.on(.completed)
			return Disposables.create()
		}
	}
```

가장 큰 변화는 completion 의 인자로 넣어주던 Escaping 메서드가 사라지고 **Observable** 타입을 반환한다. Observable 타입은 제네릭 클래스 이기 때문에 기본 구조체 타입 뿐만아니라 인스턴스등 어떤 타입이던지 들어올 수 있다. 

Observable **관찰 가능한 이벤트** 를 의미한다고 했다. 이는 Observable은 생성 될때 곧바로 그 안에 명시된 코드가 실행되는 것은 아니다. `.subscribe()` 메서드를 이용해 구독을 당할때 비로서야 그 안에 명시된 코드가 실행되고 이벤트를 전송한다.

즉 , `downLodFileObservable` 함수가 호출 되어 Observable이 만들어 질때 안의 "file이 생성되었습니다" 가 출력이 되는 것이 아니라 **Observable을 subscribe 메서드를 이용해서 관찰하기 시작한 후에야 File 객체가 만들어져서 출력된다**

아래와 같이 File을 다운로드 받기위해 함수를 호출 해보겠다.

```swift
// 현재 fileObservable 상수는 Observable 타입 인스턴스
let fileObservable = downLodFileObservable()
```

현재 상황에서는 함수를 호출 했기에 예상한 `print("file이 생성되었습니다")` 가 호출될거 같지만 아무것도 호출이 되지 않는다. 

그리고 `.subscribe` 메서드를 통해 이제 구독을 해보겠다

```swift
   fileObservable.subscribe { [unowned self] event in
 //file이 생성되었습니다
       switch event {
           case .next(let file):
               print("onNext : \(file)")
               self.downLoadLabel.text = file.name
           case .error(let error):
               print("onError : \(error)")
           case .completed:
               print("onComplete")
        }
   }
//onNext : File(name: "비동기파일", size: 42512)
//onComplete
```

위와 같이 Observable은 해당 인스턴스 타입의 Observable이 생성될때 **어떻게 이벤트를 발생시키고 언제 종료하고, 어느 상황에서 에러가 발생하게 할지를 결정해주는 역할** 을한다.



## Observable의 생명주기

위에서 간략하게 나마 Observable이 어떻게 동작하는지 살펴보았다. 과연 이 Observable이 언제 생성되고 언제 종료가 되는지 도식화를 해보겠다.

<img width="596" alt="image" src="https://user-images.githubusercontent.com/33486820/66701286-b22f3a80-ed35-11e9-9680-9d9f5cce2ad4.png">

위의 Marble Diagram 에서 3가지 구성요소가 있다. Observable 에서는 `.next` 이벤트를 통해 각각의 요소들을 방출하는 것이 가능하다. 위의 다이어그램에서 1,2,3 의 요소들은 tap 이벤트를 방출 한 뒤 완전 종료가 된다고 하자. 이것을 완벽하게 문제없이 수행을 하게 되면 `.compeleted` 이벤트를 통해 정상 종료 된다. 

<img width="592" alt="image" src="https://user-images.githubusercontent.com/33486820/66701318-12be7780-ed36-11e9-833f-9eb7234e3e39.png">

하지만 위의 다이어그램처럼 3의 요소에서 에러가 발생하게 되면 Observable 종료 되었다는 측면에서는 정상적으로 3개를 완료했거나 에러가발생했거나는 동일하지만  3의 요소는 `.completed` 가 아닌 `.error` 이벤트를 통해 종료되었다.

##### Observable 3가지 이벤트

- `.next`: 정상적으 이벤트(데이터)를 전달시키는 것
- `.error`: 데티어 전달 과정에서 무언가 에러가 난 상황을 알려준다. 이 이벤트를 방출하면 완전 종료 된다.
- `.completed` : 모든 데이터 전송이 끝난 상황을 의미한다. 이 이벤트를 방출하면 완전 종료 된다.

RxSwift 에서는 이 3개의 이벤트를 enum으로 관리하는데 이를 좀더 실전에 가까운 예제를 확인해보자

##### 실전예제 : File의 사이즈에 제한을 두고 다운로드

```swift
enum DownloadError: Error {
    case sizeError
    case timeError
}

extension DownloadError: LocalizedError {
    var error: String? {
        switch self {
        case .sizeError:
            return NSLocalizedString("Size가 너무 큰 파일입니다", comment: "DownloadError")
        case .timeError:
            return NSLocalizedString("파일 다운로드 응답시간 초과입니다.", comment: "DownloadError")
        }
    }
}

    func downLoadFileObservableLimitSize() -> Observable<File> {
        return Observable<File>.create { observer in
            let files = [
                File(name: "file1", size: 3000),
                File(name: "file2", size: 5000),
                File(name: "file3", size: 7000),
                File(name: "file4", size: 10000)
            ]
            
            for file in files {
                if file.size > 7000 {
                    observer.on(.error(DownloadError.sizeError))
                } else {
                    observer.on(.next(file))
                }
            }
            
            observer.on(.completed)
            return Disposables.create()
        }
    }

```

다운로드 받는 file의 사이즈가 7000 이상이면 에러가 발생하게 Observable을 반환하는 함수를 구현했다. 이제 이 함수를 `.subscribe()` 를 통해 구독하면 아래와 같이 결과가 나온다.

```swift
        let fileObservable = downLoadFileObservableLimitSize()
        
            
        fileObservable.subscribe { [unowned self] event in
            switch event {
            case .next(let file):
                print("onNext : \(file)")
                self.downLoadLabel.text = file.name
            case .error(let error):
                print("onError : \(error)")
            case .completed:
                print("onComplete")
            }
        }

//onNext : File(name: "file1", size: 3000)
//onNext : File(name: "file2", size: 5000)
//onError : sizeError
```

size가 7000인 이상인 파일이 드렁오면 onError 를 호출하고 그 뒤의 파일들의 작업의 작업 즉 다음 이벤트들이 전송되지 않고 `onComplete` 함수가 호출되지 않은채 종료가 된다.

만약 files의 배열의 모든 file의 사이즈가 7000 미만이었으면 정상적으로 `.next` 이벤트가 모든 file 인자를 거쳐 마지막에 `onComplete` 함수가 호출되고 정상종료가 된다.



## Observable 생성

위의 예제에서는 `create`를 사용해서 Observable 객체를 만들었지만 이 외에도 `just` 와 `from` 두가지가 더 존재한다.

### 1. just

<img width="635" alt="image" src="https://user-images.githubusercontent.com/33486820/66702511-684d5100-ed43-11e9-88e0-5a593036c238.png">

Just의 역할은 Marble Diagram에서 보면 Source 즉 가곡된 데이터를 그대로 전달해주는 연산이다. 

```swift
	func downLodFileObservable() -> Observable<File>{
		let file = File(name: "비동기파일", size: 12512)
		return Observable.just(file)
	}
```

위와 같이 File 객체를 그대로 전달해주는 Observable 객체를 만들어 줄 수 있다.

### 2. from

from의 경우는 배열, 딕셔너리 등의 컬렉션에서 **연속적인 데이터** 를 전달해주는 Observable을 만들어준다.

<img width="649" alt="image" src="https://user-images.githubusercontent.com/33486820/66702630-a9923080-ed44-11e9-9d81-dd28cea46935.png">

```swift
    func downLoadFileObservableLimitSize() -> Observable<File> {
            let files = [
                File(name: "file1", size: 3000),
                File(name: "file2", size: 5000),
                File(name: "file3", size: 7000),
                File(name: "file4", size: 10000)
            ]
      			return Observable.from(videos)
		}
```





## Observable 구독(Subscribe)

RxSwift를 알기 이전에 모두 `NotificationCenter` 를 사용하여 변화를 감지해 왔다. 아래는 `NotificationCenter`를 활용한 KVO(Key-Value Observing) 방식이다.

```swift
 let observer = NotificationCenter.default.addObserver(
 	forName: .UIKeyboardDidChangeFrame,
 	object: nil,
 	queue: nil
 ) { notification in
 	// Handle receiving notification
 }
```

`NotificationCenter` 를 활용하게 되면 `.default` 싱글턴 인스턴스에만 `.addObserver` 를 통해서 사용가능했다. 하지만 RxSwift의 Observable은 그렇지 않다

> **Observable은 단순한 정의** 일 뿐 "이런 이벤트가 있을 것이다" 하고 명시 할뿐, 구독(subscribe) 되기 전에는 아무런 이벤트도 보내지 않는다.

Observable은 Swift 기본 라이브러리의 반복문에서 `.next()` 를 구현하는 것과 매우 유사하다.

```swift
 let sequence = 0..<3
 var iterator = sequence.makeIterater()
 while let n = iterator.next() {
 	print(n)
 }
 
/*
0
1
2
*/
```

Observable의 구독은 이것보다 더 간단하며 또한 위에서 언급한 3가지 이벤트 타입(**next, error, completed**)에 대해서 handler를 추가할 수 있다.



### `.subscribe()` 

```swift
 example(of: "subscribe") {
     let one = 1
     let two = 2
     let three = 3
     
     let observable = Observable.of(one, two, three)
     observable.subscribe({ (event) in
    	 print(event)
 	})
 	
 	/*
 	 next(1)
 	 next(2)
 	 next(3)
 	 completed
 	*/
 }
```

위의 예제 코드에서 `.subscrivbe` 는 escaping 클로저로 Int 타입을 Evnet로 갖는다. escaping에 대한 리턴 값은 Void 이고 전체 `.subscribe` 는 `Disposable` 를 리턴한다. one, two , three 이 세개의 요소들에 대해 `.next` 이벤트를 방출했다. 그리고 최종적으로 error가 발생하지 않고 모든 요소들에 대한 이벤트를 완전 종료 했기 때문에 `.completed` 를 방출했다.



### `.subscribe(onNext:)`

```swift
 observable.subscribe(onNext: { (element) in
 	print(element)
 })
 
 /*
  1
  2
  3
 */
```

축약형으로 많이 사용한다. `.onNext` 클로저는 `.next` 이벤트만을 전달인자로 취한 다음 핸들링하고 다른 것들은 모두 무시한다. 



### `.empty()`

요소를 하나도 가지지 않는 Observable 의 경우 `.empty()` 연산자를 통해 `completed` 이벤트만 방출하게 된다.

```swift
example(of: "empty") {
     let observable = Observable<Void>.empty()
     
     observable.subscribe(
       // .next 이벤트 핸들링
         onNext: { (element) in
             print(element)
     },
       // .completed 이벤트 핸들링
         onCompleted: {
             print("Completed")
     }
     )
 }
 
 /*
  Completed
 */
```

Observable은 제네릭 타입으로 반드시 특정 타입으로 정의가 되어야한다. 타입추론할 것이 없으면 Void 형으로 위와 같이 명시적으로 정의를 해주어야 한다. 이 메서드의 용도는 다음과 같다

- 즉시 종료할 수 있는 Observable를 리턴하고 싶을때 (바로 .completed 이벤트로 넘어감)
- 의도적으로 0개의 값을 가지는 Observable을 리턴하고 싶을때 (개발자가 의도로 아무 Source도 없는 Observable 생성 가능)



### `.never()`

`.empty()` 와 반대되는 기능을 한다. 이렇게 하면 Completed 가 피린트 되지 않는다.

```swift
 example(of: "never") {
     let observable = Observable<Any>.never()
     
     observable
         .subscribe(
             onNext: { (element) in
                 print(element)
         },
             onCompleted: {
                 print("Completed")
         }
     )
 }
```



### `.range()`

```swift
 example(of: "range") {
     
     //1 range 연산자를 이용해 start ~ count 크기 만큼의 값을 갖는 Observable 생성
     let observable = Observable<Int>.range(start: 1, count: 10)
     
     observable
         .subscribe(onNext: { (i) in
             
             //2 방출된 Source에 대한 n번째 피보나치 숫자를 계산하고 출력
             let n = Double(i)
             let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
             print(fibonacci)
         })
 }
```

> 결론 : Observable 에서 반환해야할 source(데이터)가 옳은지 핸들링을 해서 subscribe 에게 " 이렇게 이벤트를 방출 하겠다" 라고 정의할 뿐이다. 그렇기 때문에 Observable에서 명확하게 `.next` `.error` `.completed` 이 세개의 이벤트가 방출 될지를 고려하면서 핸들링 해야한다. 그리고 Subscribe를 통해 비로소 Observable에서 반환하는 모든 요소들의 이벤트들을 핸들링한다.



<hr>

## Reference

- https://github.com/fimuxd/RxSwift
- [순한맛 RxSwift](https://mym0404.blog.me/221585744991)
- [Reactive X: Observable](http://reactivex.io/documentation/ko/observable.html)
- [RxJs Marbles](https://rxmarbles.com)



