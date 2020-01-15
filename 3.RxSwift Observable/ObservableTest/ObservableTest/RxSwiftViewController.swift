//
//  ViewController.swift
//  ObservableTest
//
//  Created by youngjun goo on 2019/10/11.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import RxSwift
import UIKit


class RxSwiftViewController: UIViewController {
    // MARK: - Field
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!
    
    //var disposable: Disposable?
    var disposeBag: DisposeBag = DisposeBag()
    var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flatMapTest()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Deinit ViewController")
    }
    // MARK: - IBOutlet
    
    func timeOutObservableTest() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
        
        // RxSwift 5 부터 deprecated
        // Observable<Int>.interval(1, scheduler: MainScheduler.instance).take(10)
        
        // Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        
        let disposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(10)
            .subscribe(onNext: { (event) in
                print(event)
            }, onError: { (error) in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("onDisposed")
            })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // deinit
            // 13 부터 deprecated
            // UIApplication.shared.keyWindow?.rootViewController = nil
            disposable.dispose()
            UIApplication.shared.windows.first?.rootViewController = nil
        }
    }
    // MARK: - IBAction
    
    @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil
        
        rxswiftLoadImage(from: LARGER_IMAGE_URL)
            .observeOn(MainScheduler.instance)
            .subscribe({ result in
                switch result {
                case let .next(image):
                    self.imageView.image = image
                    
                case let .error(err):
                    print(err.localizedDescription)
                    
                case .completed:
                    break
                }
            })
            // 삽입
            .disposed(by: disposeBag)
        // disposeBag.insert(disposable)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        // DisposeBag 은 .dispose() 와 같은 메서드를 지원하지 않아 단순하게 새로 생성하면 초기화가 된다.
        disposeBag = DisposeBag()
    }
    
    // MARK: - RxSwift
    
    func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> {
        return Observable.create { seal in
            asyncLoadImage(from: imageUrl) { image in
                // fulfill 대신 onNext() 를 통해 제어
                seal.onNext(image)
                seal.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func flatMapTest() {
        disposeBag = DisposeBag()
        
        // 초기 element 1, 2, 3
        let element1 = Element(element: BehaviorSubject(value: 1))
        let element2 = Element(element: BehaviorSubject(value: 2))
        let element3 = Element(element: BehaviorSubject(value: 3))
        var elementS = [Element]()
        
        elementS.append(Element(element: BehaviorSubject(value: 6)))
        elementS.append(Element(element: BehaviorSubject(value: 7)))

        let finalSequence = PublishSubject<Element>()
        // transform된 element를 subscribe한다. 이벤트가 발생할시 값을 출력하게 했다.
        finalSequence
            .flatMapLatest { $0.element }
            .subscribe(onNext: {
                print($0 * 10)
            })
            .disposed(by: disposeBag)
        
        finalSequence.onNext(element1)
        finalSequence.onNext(element2)
        // 무시됨 현재 마지막 Sequence: element2
        element1.element.onNext(3)
        finalSequence.onNext(element3)
        // 무시됨 현재 마지막 Sequence: element3
        element1.element.onNext(4)
        element2.element.onNext(5)
        // final Sequence에 전달됨
        element3.element.onNext(6)
        
//        elementS.forEach {
//            finalSequence.onNext($0)
//        }
        
        finalSequence.dispose()
        
        /*
         
         student.onNext(ryan)
         
         ryan.score.onNext(85)
         ryan.score.onNext(95)
         
         student.onNext(charlotte)
         charlotte.score.onNext(100)
         */
        
    }
    
    
}
