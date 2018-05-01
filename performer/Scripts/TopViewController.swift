//
//  TopViewController.swift
//  performer
//
//  TopのViewController.
//
//  Created by Taku Nonomura on 2018/05/01.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
    
    override func viewDidLoad() {
        // 親クラスのLoad完了処理.
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// ボタンをTouchUpした時のコールバック.
    @IBAction func OnGoToNext(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "Movie")
        self.present(nextView, animated: true, completion: nil)
    }
}

