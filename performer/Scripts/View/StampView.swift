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
    func instantiateStamp(filePath: String, posX: CGFloat) {

        // imageViewの生成.
        let image = UIImageView()
        image.image = UIImage(named: filePath)
        image.alpha = 0
        image.frame = CGRect(x:0, y:0, width:128, height:128)
        image.center = CGPoint(x: posX, y: 400.0)
        rootView.addSubview(image)
        
        // animation
        UIView.animate(
            withDuration: 0.1,
            animations: { image.alpha = 1.0 }
        )
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [ .curveEaseOut ],
            animations: { image.center.y -= 300 },
            completion: {_ in image.removeFromSuperview() })
    }
}
