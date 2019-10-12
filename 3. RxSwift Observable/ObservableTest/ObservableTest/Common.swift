//
//  Common.swift
//  ObservableTest
//
//  Created by youngjun goo on 2019/10/11.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import UIKit

let LARGE_IMAGE_URL = "https://picsum.photos/1024/768/?random"
let LARGER_IMAGE_URL = "https://picsum.photos/1280/720/?random"
let LARGEST_IMAGE_URL = "https://picsum.photos/2560/1440/?random"

func syncLoadImage(from imageUrl: String) -> UIImage? {
    guard let url = URL(string: imageUrl) else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }

    let image = UIImage(data: data)
    return image
}

func asyncLoadImage(from imageUrl: String, completed: @escaping (UIImage?) -> Void) {
    DispatchQueue.global().async {
        let image = syncLoadImage(from: imageUrl)
        completed(image)
    }
}
