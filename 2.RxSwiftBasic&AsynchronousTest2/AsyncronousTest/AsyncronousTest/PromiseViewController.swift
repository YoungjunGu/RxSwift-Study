//
//  ViewController.swift
//  AsyncronousTest
//
//  Created by youngjun goo on 2019/10/08.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import PromiseKit
import UIKit

class PromiseViewController: UIViewController {
    // MARK: - Field
    
    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    // MARK: - IBAction

    @IBAction func onLoadImage(_ sender: Any) {
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
}

