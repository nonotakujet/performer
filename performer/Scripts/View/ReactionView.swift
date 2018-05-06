//
//  ReactionView.swift
//  performer
//
//  Created by Taku Nonomura on 2018/05/06.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

class ReactionView : UIView {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setHidden(isHidden : Bool) {
        self.isHidden = isHidden
    }
}
