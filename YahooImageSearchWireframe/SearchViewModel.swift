//
//  SearchViewModel.swift
//  ImageSearchSample
//
//  Created by cano on 2018/03/17.
//  Copyright © 2018年 cano. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import HTMLReader
import RxOptional

class SearchViewModel {

    // Inputs
    typealias Inputs = (
        searchWord: Driver<String>,
        searchTap: Signal<Void>
    )

    // Dependencies
    typealias Depencencies = (
        searchService: SearchServiceType,
        wireframe: SearchWireframeType
    )

    typealias Wireframe  = (
        SearchWireframeType
    )

    // MARK: - Model
    
    private var model = SearchModel()

    // Outputs
    let urls: Driver<[URL]>                     // 検索結果
    let error: Driver<Error>                    // エラー
    let isSearchButtonEnabled: Driver<Bool>     // 検索ボタンの押下可否

    // MARK: - rx
    let searchTrigger = PublishSubject<Void>()
    private var _searchWord: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    private var _urls: BehaviorRelay<[URL]> = BehaviorRelay<[URL]>(value: [])
    var photoSelect: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)

    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - init
    // Binding
    init(inputs: Inputs, dependencies: Depencencies) {

        // 画像URLとエラーの両方をDriverで取得
        // https://speakerdeck.com/parakeety/merukariatutefalserxswiftshi-zhuang-gaido
        (self.urls, self.error) =
                Driver.split(result:
                    self._searchWord.asDriver()
                        .flatMapLatest {
                            string in
                                return dependencies.searchService.getImageUrls(["p": string])
                                        .do(onNext: { _ in dependencies.wireframe.hideLoading() })
                                        .resultDriver()
                        }
                    )

        // エラー発生時
        self.error.drive(onNext: { error in
            dependencies.wireframe.showError(error: error)
        }).disposed(by: self.disposeBag)

        // 検索キーワード3文字以上で検索可能に
        self.isSearchButtonEnabled = inputs.searchWord
            .startWith("")
            .map { $0.count >= 3 }

        // 検索トリガー  一度だけbindを実行
        self.searchTrigger
            .withLatestFrom(inputs.searchWord)
            .bind(to:self._searchWord)
            .disposed(by: disposeBag)

        // 検索ボタンタップ
        inputs.searchTap
            .do(onNext: { _ in dependencies.wireframe.showLoading(nil) })
            .emit(to: self.searchTrigger)
            .disposed(by: self.disposeBag)

        // スライド表示
        self.urls.asObservable()
            .bind(to: self._urls)
            .disposed(by: self.disposeBag)

        self.photoSelect.asDriver().skip(1)
            .drive(onNext: { [unowned self] index in
                dependencies.wireframe.showPhotoList(self._urls.value, index)
            }).disposed(by: disposeBag)

    }
    // MARK: - Methods
}
