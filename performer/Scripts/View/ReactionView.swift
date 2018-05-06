//
//  ReactionView.swift
//  performer
//
//  Created by Taku Nonomura on 2018/05/06.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

protocol ButtonTappedDelegate : class {
    func onButton(index : Int)
}

class ReactionView : UIView {
    
    /// outlet
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    /// button delegate
    weak var buttonDelegate : ButtonTappedDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func activate() {
        // ボタンのcallback登録.
        button1.addTarget(self, action: #selector(self.onButon), for: UIControlEvents.touchUpInside)
        button2.addTarget(self, action: #selector(self.onButon), for: UIControlEvents.touchUpInside)
        button3.addTarget(self, action: #selector(self.onButon), for: UIControlEvents.touchUpInside)
        button4.addTarget(self, action: #selector(self.onButon), for: UIControlEvents.touchUpInside)
    }

    /// ボタンが押された時のcallback.
    @objc func onButon(sender: UIButton) {
        self.buttonDelegate?.onButton(index: sender.tag)
    }
}
