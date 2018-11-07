//
//  SearchService.swift
//  ImageSearchSample+Wireframe
//
//  Created by cano on 2018/11/06.
//  Copyright © 2018 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import HTMLReader

enum SearchServiceFetchError: Error {
    case fetchError(Error?)
    case noExistsError
}

protocol SearchServiceType {
    func getImageUrls(_ parameters:[String:String]) -> Observable<[URL]>
}

struct SearchService: SearchServiceType {

    static let shared = SearchService()
    private init() { }

    func getImageUrls(_ parameters:[String:String]) -> Observable<[URL]>
    {
        return Observable<[URL]>.create { (observer) -> Disposable in
            let request = self.getRequest(parameters).responseString{ response in
                guard let html = response.result.value else{ return }
                guard let data = html.data(using: .utf8) else { return }
                let home = HTMLDocument(data: data, contentTypeHeader:"text/html")
                guard let div = home.firstNode(matchingSelector: "#gridlist") else {
                    print("Failed to match .repository-meta-content, maybe the HTML changed?")
                    return
                }
                var ret = [URL]()
                let columns = div.nodes(matchingSelector: "div")
                for column in columns {
                    let ass = column.nodes(matchingSelector: "a").map({ $0.attributes["href"]})
                    if ass.count == 0 { continue }

                    let ims = column.nodes(matchingSelector: "img").map({ $0.attributes["src"]})
                    if ims.count == 0 { continue }

                    let link = ims[0]
                    if let imageLink = link {
                        if let url = URL(string: imageLink) {
                            if ret.contains(url){ continue }
                            ret.append(url)
                        }
                    }
                }
                observer.onNext(ret)
                if let error = response.error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create { request.cancel() }
        }
    }

    func getRequest(_ parameters: [String : String])->DataRequest
    {
        let headers: HTTPHeaders = [
            "User-Agent": Constants.mail
        ]
        // Yahoo画像検索
        return Alamofire.request(URL(string:"https://search.yahoo.co.jp/image/search")!, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
    }
}
