//
//  ViewController.swift
//  AsynchronousBasicTest
//
//  Created by youngjun goo on 2019/10/06.
//  Copyright © 2019 youngjun goo. All rights reserved.
//


import UIKit
import RxSwift


class ViewController: UIViewController {
    
    @IBOutlet weak var downLoadLabel: UILabel! {
        didSet {
            self.downLoadLabel.numberOfLines = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        self.downLoadLabel.text = "다운로드 중..."
        //        downLoadFile { [unowned self] (file) in
        //            self.downLoadLabel.text = "파일 이름 : \(file.name) \n 파일 크기: \(file.size) Bytes"
        //        }
        
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
    
    func downLodFileObservable() -> Observable<File> {
        return Observable<File>.create{observer in
            let file = File(name: "비동기파일", size: 42512)
            print("file이 생성되었습니다")
            observer.on(.next(file))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
    func downLoadFileObservableLimitSize() -> Observable<File> {
        return Observable<File>.create { observer in
            let files = [
                File(name: "file1", size: 3000),
                File(name: "file2", size: 5000),
                File(name: "file3", size: 6000),
                File(name: "file4", size: 4000)
            ]
            
            for file in files {
                if file.size >= 7000 {
                    observer.on(.error(DownloadError.sizeError))
                } else {
                    observer.on(.next(file))
                }
            }
            
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
}
