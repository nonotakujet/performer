//
//  MovieUploadViewController.swift
//  performer
//
//  Created by Taku Nonomura on 2019/01/15.
//  Copyright © 2019年 visioooon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import FirebaseFirestore

class MovieUploadViewController: UIViewController {

    var uploadButton : UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {

        // 親クラスのLoad完了処理.
        super.viewDidLoad()

        // 次へボタン
        uploadButton = UIButton(frame: CGRect(x: 0,y: 0,width: 100,height: 50))
        uploadButton.backgroundColor = UIColor.red
        uploadButton.layer.masksToBounds = true
        uploadButton.setTitle("投稿", for: UIControlState.normal)
        uploadButton.layer.cornerRadius = 20.0
        uploadButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height - 50)
        uploadButton.addTarget(self, action: #selector(MovieUploadViewController.onClickUploadButton(sender:)), for: .touchUpInside)
        self.view.addSubview(uploadButton)

        // backボタン
        backButton.addTarget(self, action: #selector(self.onBackButtonClick), for: UIControlEvents.touchUpInside)
    }
    /// 投稿ボタンが押された時のcallback.
    @objc func onClickUploadButton(sender: UIButton) {
    }
    
    /// backボタンが押された時のcallback.
    @objc func onBackButtonClick(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
