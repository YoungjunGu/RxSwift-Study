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

    var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Deinit ViewController")
    }
    // MARK: - IBOutlet
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!
    
    //var disposable: Disposable?
    var disposeBag: DisposeBag = DisposeBag()
    
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
    
    
}
