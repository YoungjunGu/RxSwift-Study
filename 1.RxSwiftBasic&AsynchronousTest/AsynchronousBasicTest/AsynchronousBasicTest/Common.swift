//
//  Common.swift
//  AsynchronousBasicTest
//
//  Created by youngjun goo on 2019/10/12.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import Foundation

struct File{
    let name: String
    let size: Int
}

enum DownloadError: Error {
    case sizeError
    case timeError
}

extension DownloadError: LocalizedError {
    var error: String? {
        switch self {
        case .sizeError:
            return NSLocalizedString("Size가 너무 큰 파일입니다", comment: "DownloadError")
        case .timeError:
            return NSLocalizedString("파일 다운로드 응답시간 초과입니다.", comment: "DownloadError")
        }
    }
}
