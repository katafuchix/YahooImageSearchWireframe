//
//  ObservableConvertibleType.swift
//  ImageSearchSample+Wireframe
//
//  Created by cano on 2018/11/06.
//  Copyright © 2018 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// https://speakerdeck.com/parakeety/merukariatutefalserxswiftshi-zhuang-gaido
enum Result<Response> {
    case succeeded(Response)
    case failed(Error)
}

extension ObservableConvertibleType {
    func resultDriver() -> Driver<Result<E>> {
        return self.asObservable()
            .map { Result.succeeded($0) }
            .asDriver { Driver.just(Result.failed($0)) }
    }
}
