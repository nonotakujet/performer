//
//  MovieViewCell.swift
//  performer
//
//  Created by Taku Nonomura on 2018/09/17.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

class MovieViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
