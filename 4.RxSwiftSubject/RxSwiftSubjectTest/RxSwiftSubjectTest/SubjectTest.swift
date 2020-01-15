//
//  SubjectTest.swift
//  RxSwiftSubjectTest
//
//  Created by youngjun goo on 2019/12/30.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import Foundation
import RxSwift


class RxSwiftSubject {
    
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
       
       func behaviorSujectTest() {
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
       
       func combineLatestTest() {
           let disposeBag = DisposeBag()
           let korean = Observable.from(["가","나", "다"])
           let english = Observable.from(["A","B","C"])
           Observable.combineLatest(
               korean,
               english
           ) { ($0, $1) }
               .subscribe {
                   print($0)
           }
           .disposed(by: disposeBag)
       }
       
       func mergeTest() {
           let disposeBag = DisposeBag()
           let redTeam = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
               .map{ "red: \($0)" }
           let bluTeam = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
               .map{ "blue: \($0)" }
           
           let startTime = Date().timeIntervalSince1970
           
           Observable
               .of(redTeam, bluTeam)
               .merge()
               .subscribe {
                   print("\($0): \(Int(Date().timeIntervalSince1970 - startTime))")
           }
           .disposed(by: disposeBag)
       }
       
       func switchLatestTest() {
           let disposeBag = DisposeBag()
           let subjectA = PublishSubject<String>()
           let subjectB = PublishSubject<String>()
           let switchTest = BehaviorSubject<Observable<String>>(value: subjectA)
           switchTest.switchLatest().subscribe {
               print($0)
           }.disposed(by: disposeBag)
           subjectA.onNext("A-1")
           switchTest.onNext(subjectB)
           subjectA.onNext("A-2")
           subjectB.onNext("B-1")
           subjectB.onNext("B-2")
       }
       
       
       func zipTest() {
           let disposeBag = DisposeBag()
           let korean = Observable<String>.from(["가", "나", "다", "라"])
           let number = Observable<Int>.from([1, 2, 3])
           
           Observable
               .zip(
                   korean,
                   number
           )
               .subscribe {
                   print($0)
           }
           .disposed(by: disposeBag)
       }
       
       func concastTest() {
           let disposeBag = DisposeBag()
           let korean = Observable<String>.from(["가", "나", "다", "라"])
           let english = Observable<String>.from(["A","B","C"])
           
           korean
               .concat(english)
               .subscribe {
                   print($0)
           }
           .disposed(by: disposeBag)
       }
       
       func concatSubjectTest() {
           let disposeBag = DisposeBag()
           let subjectA = PublishSubject<String>()
           let subjectB = PublishSubject<String>()
           
           subjectA.subscribe {
               print($0)
           }
           .disposed(by: disposeBag)
           
           subjectB.subscribe {
               print($0)
           }
           .disposed(by: disposeBag)
           
           
           Observable
               .concat([subjectA, subjectB])
               .subscribe {
                   print("concat event: \($0)")
           }
           .disposed(by: disposeBag)
           
           subjectA.onNext("A - event1")
           subjectA.onNext("A - event2")
           subjectA.onCompleted()
           subjectB.onNext("B - evnet1")
           subjectB.onNext("B - event2")
          //  subjectB.onError(MyError.anError)
       // subjectA.onNext("A - event3")
           subjectB.onCompleted()
       }
       
       func ambTest() {
           let disposeBag = DisposeBag()
           let first = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance).map {
               "first: \($0)"
           }
           let second = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance).map {
               "second: \($0)"
           }
           let third = Observable<Int>.interval(.seconds(4), scheduler: MainScheduler.instance).map {
               "third: \($0)"
           }
           
           first.amb(second).amb(third).subscribe(onNext: { e in
               print(e)
               })
               .disposed(by: disposeBag)
       }
}
