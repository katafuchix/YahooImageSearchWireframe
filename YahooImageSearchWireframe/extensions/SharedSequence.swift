//
//  SharedSequence.swift
//  ImageSearchSample+Wireframe
//
//  Created by cano on 2018/11/06.
//  Copyright © 2018 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// https://speakerdeck.com/parakeety/merukariatutefalserxswiftshi-zhuang-gaido
extension SharedSequence {

    /// split result to E and Error
    ///
    /// - Parameter result: Driver<Result<E>>
    /// - Returns: Driver<E>, Driver<Error>
    static func split(result: Driver<Result<E>>) -> (response: Driver<E>, error: Driver<Error>) {
        let responseDriver = result.flatMap { result -> Driver<E> in
            switch result {
            case .succeeded(let response):
                return Driver.just(response)
            case .failed:
                return Driver.empty()
            } }
        let errorDriver = result.flatMap { result -> Driver<Error> in
            switch result {
            case .succeeded:
                return Driver.empty()
            case .failed(let error):
                return Driver.just(error)
            } }
        return (responseDriver, errorDriver)
    }
}
