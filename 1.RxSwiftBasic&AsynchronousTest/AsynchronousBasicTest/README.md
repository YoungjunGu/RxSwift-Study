# chapter1. RxSwift Basic



## RxSwift란?

Reactive란 **"반응하는, 반응을 보이는"** 이란 사전적 정의를 갖는다. 

<img width="763" alt="image" src="https://user-images.githubusercontent.com/33486820/66268934-5e2bde00-e87d-11e9-882d-ce8522caa277.png">


ReactiveX 사이트에 명시 되어있는 말이다. 

> **"관찰 가능한(Observable)** 흐름과 함께 비동기 프로그래밍을 위한 API 이다"

뜻 풀이를 그대로하면 위와 같은 의미를 갖는다. 그 의미를 조금 더 자세하게 보면 아래와 같은 키워드로 나타내고 있다

<img width="748" alt="image" src="https://user-images.githubusercontent.com/33486820/66268941-756acb80-e87d-11e9-94eb-2a4f38211f52.png">  


> **옵저버패턴** 과 **이터레이터패턴**, 그리고 **함수형 프로그래밍** 을 이용한 **반응형 프로그램** 으로써 **비동기식**프로그램 개발에 용이하다.

## Apple의 Cocoa and UIKit Asynchronous API

Applie은 iOS SDK에서 비동기식 코드를 작성 할 수 있도록 아래와 같은 방법들을 제공하고 있다.

- Notification Center
- Delegate Pattern
- Grand Central Dispatch(GCD)
- Closures(클로저)

대부분의 클래스들은 개발자의 의도와 다르게 비동기 적으로 수행하고 마찬가지로 UI 요소들의 구성은 본질적으로 비동기적이다. 따라서 개발자는 앱 코드를 작성했을때 매번 어떤 순서로 작동한다라고 가정하는 것은 불가능하다. 앱 내의 코드는 사용자와의 interaction(상호작용), Networking, iOS Event 등의 외부적인 요인에 의해 완전히 다른 순서로 실행 될 수 있다.

> 가장 큰 문제점은 개발자가 위에서 제공하는 방법을 톨해 비동기 코드를 부분별로 나눠쓰기가 매우 까다롭고 순서를 앞에서 보장하여 코딩하는 것이 불가능하다. 그리고 마찬가지로 코드를 추적하는 것이 불가능하다.  



## 비동기 프로그래밍의 필요성  



앞에서 언급했듯이 "우리가 작성한 클래스나 함수는 우리가 원하는 순서대로 작동 되지않는다." 를 생각하면서 간단한 예제를 통해 실습을 해보겠다.  

```swift
    func downLoadFile() {
        downLoadLabel.text = "다운로드 중..."
        Thread.sleep(forTimeInterval: 5)
        downLoadLabel.text = "다운로드 완료"
    }
```

파일을 다운로드 받는데 5초가 걸린다고 가정하고 위와 같이 Swift에서 기본으로 제공하는 `Thread.slepp()` 메서드를 이용했다. 그리고 다운로드가 종료가 되면 레이블의 텍스트를 완료로 변경시키는 작업이다.

하지만 위의 결과로 다운로드 중이라는 텍스트는 보이지 않고 실제로 **앱이 5초 멈춰있는 상태처럼 보인다**. iOS에서는 보통 네트워킹이나 이런식으로 Thread를 이용해야하는 경우 **Grand Central Dispatch(GCD)** 를 사용하여 작업한다.

- GCD를 이용

```swift
    func downLoadFile() {
        downLoadLabel.text = "다운로드 중..."
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 5)
            self.downLoadLabel.text = "다운로드 완료"
        }
    }
```

하지만 위의 코드를 실행하면 5초뒤에 아래와 같은 에러가 발생하면서 앱은 종료가 된다.

<img width="767" alt="image" src="https://user-images.githubusercontent.com/33486820/66268949-89163200-e87d-11e9-9631-10f6525f3dcf.png">  


GCD를 사용하는 것 중의 가장 기본이 되는 것이 **UI의 변경은 오직 메인 스레드에서만 ** 을 숙지하고 있어야한다. 그렇기 때문에 아래와 같이 다시 코드를 변경 시켜 주어야 한다.

```swift
    func downLoadFile() {
        downLoadLabel.text = "다운로드 중..."
        DispatchQueue.global().async { [unowned self] in
            Thread.sleep(forTimeInterval: 5)
            DispatchQueue.main.async { [unowned self] in
                 self.downLoadLabel.text = "다운로드 완료"
            }
        }
    }
```

실제상황과 매우 흡사하게 다운 받을 File이라는 구조체를 만들고 다운로드 받은 파일을 비동기적으로 반환 받기 위해 `@escaping closure`를 사용해서 코드를 작성해보겠다.

```swift
import UIKit


struct File{
    let name: String
    let size: Int
}


class ViewController: UIViewController {
    
    @IBOutlet weak var downLoadLabel: UILabel! {
        didSet {
            self.downLoadLabel.numberOfLines = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.downLoadLabel.text = "다운로드 중..."
        downLoadFile { [unowned self] (file) in
            self.downLoadLabel.text = "파일 이름 : \(file.name) \n 파일 크기: \(file.size) Bytes"
        }
        
    }
    
    
    func downLoadFile(completion: @escaping (File) -> Void) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 5)
            let file = File(name: "비동기파일", size: 42512)
            DispatchQueue.main.async {
                completion(file)
            }
        }
    }   
}
```

![Oct-06-2019 20-16-11](https://user-images.githubusercontent.com/33486820/66271748-e1a8f780-e89c-11e9-9623-1dfa5a95604c.gif)


escaping closure 를 사용하여 thread sleep 이 안전하게 완료가 되면 내부에서 만드는 file 구조체 객체를 반환하여 해당 정보를 바탕으로 레이블의 텍스트를 변경시켰다.

항상 UI의 변경은 Main Thread에서 일어 난다는 것을 유념하고 위의 함수에서는 다른 쓰레드에서 5초 동안 실행이 이루어지고 Main 쓰레드에서 completion 함수를 호출해준다.



여기 까지가 Apple에서 제공하는 비동기프로그래밍 방법을 토대로 간단하게 예제를 작성해보았다. 하지만 위의 비동기식 코드에도 몇가지 문제점이 존재한다.

1. 코드의 길이가 늘어나 가독성이 떨어진다.
2. 개발자가 쓰레드를 관리하기에 어렵고 복잡하다.
3. 작업이 실행 되고 있는 도중 앱이 백그라운드 상태로 가면 실행되고 있는 작업을 해제해줄 방법이 없다.(ex.서버에서 대용량 다운로드 파일을 할 경우 다운로드가 완료되고 그다음 작업을 수행 할 수 없다)
4. 메모리의 누수가 발생한다.
5. `escaping closure`를 사용하여 작업이 완료된 결과값을 받는데 이는 코드가 길어진다는 1번의 문제점과 동일
6. 실행 도중의 에러에 대한 관리가 어렵다. 프로토콜로 에러코드를 작성해놓고 사용한다지만 위와 같이 다운로드 받는 도중에 에러가 발생하면 어떻게 에러 처리를 해야할지 애매하다.

위와 같이 기존의 비동기 방식을 이용하면 문제점이 몇가지 발생한다. 가령 서버통신을 할 경우에 위와 같은 상황을 많이 겪는다. 대부분 어느정도 시간이 걸리는 작업, 다운로드나 실행시간이 긴 작업을 할 경우 해당 작업을 **관찰**하고 있어야하는 필요성을 느끼게 해주는 문제점 들이다.



이런 문제점을 보완하기 위해 ReactiveX의 개념이 등장했고 등장 배경은 이러하다

> **관찰 가능한 (Observable)** 한 이벤트들에 대해 **구독(Subscribe)** 를 하며 대응하자!  


## 비동기 프로그래밍 용어  

### Statem and Specifically, Shared Mutable State

많은 CS 영역에서 언급되고 있는 state라는 용어 한마디로 그 현재의 상태를 의미한다. 



### 명령형 프로그래밍 vs 선언형 프로그래밍

[Gaki Blog - 함수형 프로그래밍](https://gaki2745.github.io/FunctionalProgramming) 참고



### 부수작용들

부수작용이란 현재 스코프 이외의 state에서 일어나는 모든 변화를 뜻한다. 예를 들어 위의 코드에서 `downLoadLabel` 의 텍스트를 변경하거나 추가하는 것은 디스크에 저장된 데이터를 수정한다는 것이고 이는 메모리를 가져오고 적재하는 과정이 발생한다  결국 부수작용이 발생한다는 것이다.

여기서 비동기 제어의 관점은 **부수작용의 추적과컨트롤** 이다. RxSwift는 이를 가능하게 해준다.



### Reactive Stystem(반응형 시스템)

사실 웹이나 안드로이드 등에서도 언급이 되는 말인데 상당히 추상적인 말이다. 뿐만 아니라 iOS에서도 이들의 공통된 특성을 확인할 수 있다.

- `반응(Resposive)` :항상 UI를 최신 상태로 유지하며, 가장 최근의 앱 state를 표시한다.
- `복원력(Resilient)`: 각각의 행동들은 독립적으로 정의되며, 에러 복구를 위해 유연하게 제공된다.
- `탄력성(Elastic)`: 코드는 다양한 작업 부하를 처리하고, 종종 lazy full 기반의 데이터 수집, 이벤트 제한 및 리소스 공유와 같은 기능을 구현한다.
- `메시지 전달(Message driven)`: 구성요소는 메시지 기반 통신을 사용하여 재사용 및 고유한 기능을 개선하고, 라이프 사이클과 클래스 구현을 분리한다.



<hr>

## Reference 

- [마기의 개발블로그 - RxSwift 알아보기](https://magi82.github.io/ios-rxswift-01/?source=post_page-----4b5187d07a33----------------------)
- [ReactiveX Documents](http://reactivex.io/intro.html)
- [RxSwift 순한맛](https://mym0404.blog.me/221585744991)
