//
//  ImageCollectionViewCell.swift
//  ImageSearchSample
//
//  Created by cano on 2018/06/20.
//  Copyright © 2018年 cano. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    func configure(_ url: URL) {
        self.imageView.af_setImage(withURL: url)
    }
}
