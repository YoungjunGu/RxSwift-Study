//
//  ViewController.swift
//  AsynchronousBasicTest
//
//  Created by youngjun goo on 2019/10/06.
//  Copyright © 2019 youngjun goo. All rights reserved.
//


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
