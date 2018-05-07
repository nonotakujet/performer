//
//  StampView.swift
//  performer
//
//  Created by Taku Nonomura on 2018/05/08.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

class StampView {
    
    // Stampの各ImageViewを管理するRootView
    var rootView: UIView!
    // このViewで管理されるスタンプのUIImageView
    var image : UIImageView!

    /// initializer.
    init() {
        // NullのRootViewを生成.
        rootView = UIView()
        rootView.frame = CGRect(x:0, y:0, width:0, height:0)
    }
    
    /// このViewのNodeを返します.
    func GetViewNode() -> UIView! {
        return rootView
    }
    
    /// stampを生成します.
    func instantiateStamp(filePath: String) {
        image = UIImageView()
        image.image = UIImage(named: filePath)
        image.frame = CGRect(x:0, y:0, width:128, height:128)
        image.center = CGPoint(x:100, y:300)
        rootView.addSubview(image)
    }
}
