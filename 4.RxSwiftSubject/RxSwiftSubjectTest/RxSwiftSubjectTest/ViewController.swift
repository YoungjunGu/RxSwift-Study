//
//  ViewController.swift
//  RxSwiftSubjectTest
//
//  Created by youngjun goo on 2019/12/23.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asyncSubject()
        
    }
    
    func publishSubjectTest() {
        let subject = PublishSubject<String>()
        // 아직 구독 되지 않았기 떄문에 출력 x
        subject.onNext("Is anyone listening?")
        // 첫번째 subscriber가 구독을 실시함 -> 이때 부터 이벤트 발행 가능
        let subscriptionOne = subject
            .subscribe(onNext: { (string) in
                print("1)", string)
            })
        subject.on(.next("1"))
        subject.onNext("2")
        
        // 1: 두번째 Subscriber가 구독함
        let subscriptionTwo = subject
            .subscribe({ (event) in
                // 출력될 이벤트에 2)를 붙여서 출력함
                print("2)", event.element ?? event)
            })
        
        // 2: 이벤트 3을 subject에 추가
        subject.onNext("3")
        
        // 3: subscriber 1 dispose호출로 방출 -> 구독 취소로 종료
        subscriptionOne.dispose()
        subject.onNext("4")
        
        // 4: subject complete로 종료
        subject.onCompleted()
        
        // 5: 기존의 subject를 완전 종료를 시킨다
        subject.onNext("5")
        
        // 6: 두번째 구독자도 완전 종료를 시킨다.
        subscriptionTwo.dispose()
        
        let disposeBag = DisposeBag()
        
        // 7: subject가 완전 종료 된 후에 구독해봤자 생명을 불어 넣을 순 없다! 하지만 complete 이벤트는 방출한다.
        subject
            .subscribe {
                print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
        
        subject.onNext("?")
    }
    
    enum MyError: Error {
        case anError
    }
    
    func behaviorSuject() {
        let subject = BehaviorSubject(value: "Initial value")
        let disposeBag = DisposeBag()
        
        // 5
        subject
            .subscribe{
                print("1)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
        
        // 6
        subject.onNext("X")
        
        // 7
        subject.onError(MyError.anError)
        
        // 8
        subject
            .subscribe {
                print("2)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    }
    
    func replaySubject() {
        // 1: 미리 버퍼 사이즈를 지정한다 -> 2
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        let disposeBag = DisposeBag()
        
        // 2
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        
        // 3
        subject
            .subscribe {
                print("1)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
        
        subject
            .subscribe {
                print("2)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
        
        subject.onNext("4")
        subject.onError(MyError.anError)
        subject.dispose()
        
        subject
            .subscribe {
                print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    }
    
    func asyncSubject() {
        
        let subject = AsyncSubject<String>()
        let disposeBag = DisposeBag()
        
        subject
            .subscribe {
                print("1)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        subject.onError(MyError.anError)
    }
    
    
}

