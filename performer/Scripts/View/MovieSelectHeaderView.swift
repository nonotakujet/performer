//
//  MovieSelectHeaderView.swift
//  performer
//
//  Created by Taku Nonomura on 2018/09/20.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

protocol MovieSelectHeaderButtonDelegate : class {
    func onPost();
    func onBack();
}

class MovieSelectHeaderView: UICollectionReusableView {
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    /// button delegate
    weak var buttonDelegate : MovieSelectHeaderButtonDelegate? = nil

    func activate() {
        // ボタンのcallback登録.
        postButton.addTarget(self, action: #selector(self.onPostButton), for: UIControlEvents.touchUpInside)
        backButton.addTarget(self, action: #selector(self.onBackButton), for: UIControlEvents.touchUpInside)
    }

    func setPostButtonEnable(isEnabled: Bool)
    {
        postButton.isEnabled = isEnabled;
    }

    /// ボタンが押された時のcallback.
    @objc func onPostButton(sender: UIButton) {
        self.buttonDelegate?.onPost();
    }

    /// ボタンが押された時のcallback.
    @objc func onBackButton(sender: UIButton) {
        self.buttonDelegate?.onBack();
    }
}
