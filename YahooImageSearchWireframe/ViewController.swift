//
//  ViewController.swift
//  ImageSearchSample
//
//  Created by cano on 2018/03/17.
//  Copyright © 2018年 cano. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.contentInset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        }
    }
    private var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // ViewModel初期化
        self.viewModel = SearchViewModel(
            inputs: (
                self.textField.rx.text.orEmpty.asDriver(),
                self.button.rx.tap.asSignal()
            ),
            dependencies: (
                searchService: SearchService.shared,
                wireframe: SearchWireframe(viewController: self)
        ))

        // 検索可能な場合は検索ボタンを押下可能に
        self.viewModel.isSearchButtonEnabled.asObservable()
            .bind(to: self.button.rx.isEnabled)
            .disposed(by: self.rx.disposeBag)

        // 検索結果をコレクションで表示
        self.viewModel.urls.asObservable().bind(to:self.collectionView.rx.items(cellIdentifier: "ImageCollectionViewCell", cellType: ImageCollectionViewCell.self))
            { (index, element, cell) in
                cell.configure(element)
            }.disposed(by: self.rx.disposeBag)

        // 画像をスライド表示
        self.collectionView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            self.viewModel.photoSelect.accept(indexPath.row)
        }).disposed(by: self.rx.disposeBag)

        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.rx.disposeBag)

        // キーボードを下げる
        self.textField.rx.controlEvent(.editingDidEndOnExit).asDriver()
            .drive(onNext: { [weak self] _ in
                self?.textField.resignFirstResponder()
            }).disposed(by: self.rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    //セルの間の余白設定
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    //セルのサイズを指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.collectionView.frame.width-24*3)/3
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

