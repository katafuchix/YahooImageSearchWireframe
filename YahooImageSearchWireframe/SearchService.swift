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
                
                /*let home = HTMLDocument(data: data, contentTypeHeader:"text/html")
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
                }*/
                
                guard let str = String(data: data, encoding: .utf8) else { return }
                var ret = [URL]()
                let pattern = "(https?)://msp.c.yimg.jp/([A-Z0-9a-z._%+-/]{2,1024}).jpg"
                let regex = try! NSRegularExpression(pattern: pattern, options: [])
                let results = regex.matches(in: str, options: [], range: NSRange(0..<str.count))
                
                ret = results.map { result in
                    let start = str.index(str.startIndex, offsetBy: result.range(at: 0).location)
                    let end = str.index(start, offsetBy: result.range(at: 0).length)
                    let text = String(str[start..<end])
                    return text
                }.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
                .map { URL(string: $0)! }
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
