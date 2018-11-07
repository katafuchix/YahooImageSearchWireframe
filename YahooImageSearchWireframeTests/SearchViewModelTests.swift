//
//  SearchViewModelTests.swift
//  ImageSearchSample+WireframeTests
//
//  Created by cano on 2018/11/07.
//  Copyright © 2018 cano. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import RxCocoa
import RxBlocking
import RxTest

@testable import YahooImageSearchWireframe

class SearchViewModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGettingSearchPhotos() {
        XCTContext.runActivity(named: "画像検索結果取得成功") { _ in

            let urls: [URL] = [URL(string: "aaa")!, URL(string: "bbb")!]
            let stub = SearchServiceStub(result: .succeeded(urls), parameters: ["p":"word"])
            let spy  = SearchWireframeSpy()
            let searchTap = PublishRelay<Void>()

            let viewModel = SearchViewModel(
                inputs: (
                    Driver<String>.just("word"),
                    searchTap.asSignal()
                ),
                dependencies: (
                    searchService: stub,
                    wireframe: spy
            ))

            let gerringUrls = try! viewModel.urls.toBlocking().first()!
            XCTAssertEqual(urls, gerringUrls)

        }

        XCTContext.runActivity(named: "画像検索結果取得失敗") { _ in

            let stub = SearchServiceStub(result: .failed(SearchServiceFetchError.noExistsError), parameters: ["p":"word"])
            let spy  = SearchWireframeSpy()
            let searchTap = PublishRelay<Void>()

            let viewModel = SearchViewModel(
                inputs: (
                    Driver<String>.just("word"),
                    searchTap.asSignal()
                ),
                dependencies: (
                    searchService: stub,
                    wireframe: spy
            ))

            let error = try! viewModel.error.toBlocking().first()!
            XCTAssertNotNil(error)
            XCTAssertEqual(spy.callArgs, [.showAlert])

        }
    }

    func testPhotoListSelectEvent() {
        XCTContext.runActivity(named: "画像一覧画面へ遷移成功") { _ in

            let urls: [URL] = [URL(string: "aaa")!, URL(string: "bbb")!]
            let stub = SearchServiceStub(result: .succeeded(urls), parameters: ["p":"word"])
            let spy  = SearchWireframeSpy()
            let searchTap = PublishRelay<Void>()

            let viewModel = SearchViewModel(
                inputs: (
                    Driver<String>.just("word"),
                    searchTap.asSignal()
                ),
                dependencies: (
                    searchService: stub,
                    wireframe: spy
            ))

            _ = try! viewModel.urls.toBlocking().first()!
            viewModel.photoSelect.accept(0)
            XCTAssertEqual(spy.callArgs, [.showPhotoList])
        }
    }
}
