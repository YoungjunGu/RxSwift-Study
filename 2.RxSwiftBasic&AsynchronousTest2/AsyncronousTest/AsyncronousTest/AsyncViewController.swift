//
//  AsyncViewController.swift
//  AsyncronousTest
//
//  Created by youngjun goo on 2019/10/08.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import UIKit

class AsyncViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0
    let IMAGE_URL = "https://picsum.photos/1280/720/?random"

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

    @IBAction func onLoadSync(_ sender: Any) {
        let image = loadImage(from: IMAGE_URL)
        imageView.image = image
    }

    @IBAction func onLoadAsync(_ sender: Any) {
        // TODO: async
        // Queue 에는 sync async ConcurrencyQueue와 serialQueue 총 네개존재
        DispatchQueue.global().async {
            // async하게 작용
            let image = self.loadImage(from: self.IMAGE_URL)
            // UI업데이트는 main에서
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

    private func loadImage(from imageUrl: String) -> UIImage? {
        guard let url = URL(string: imageUrl) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }

        let image = UIImage(data: data)
        return image
    }
}
