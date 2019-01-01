//
//  TopViewCell.swift
//  performer
//
//  Created by Taku Nonomura on 2018/10/01.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

class TopViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!

    // Viewをセットアップします.
    public func setUp(movieId: String) {
        label.text = movieId
        loadThumbnail(movieId: movieId)
    }

    /// サムネイルをロードします.
    private func loadThumbnail(movieId: String) {
        let path = String(format: "%@/%@/images/%@-00001.png", Const.BASE_URL, movieId, movieId)
        self.thumbnail.loadImageAsynchronously(urlString: path)
    }
}

