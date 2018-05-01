//
//  ViewController.swift
//  performer
//
//  Created by Taku Nonomura on 2018/04/30.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        // 親クラスのLoad完了処理.
        super.viewDidLoad()
        
        // ボタンを生成
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(self.playMovieFromProjectBundle), for: .touchUpInside)
        button.sizeToFit()
        button.center = self.view.center
        self.view.addSubview(button)
    }

    // アプリにBundleされたMovieFileを再生します.
    @objc func playMovieFromProjectBundle() {
        if let bundlePath = Bundle.main.path(forResource: "Assets/baseball1", ofType: "mov") {
            
            let videoPlayer = AVPlayer(url: URL(fileURLWithPath: bundlePath))
            
            // 動画プレイヤーの用意
            let playerController = AVPlayerViewController()
            playerController.showsPlaybackControls = false;
            playerController.player = videoPlayer
            
            // AVPlayerViewControllerへの遷移処理.
            // 遷移完了で、再生.
            self.present(playerController, animated: true, completion: {
                videoPlayer.play()
            })
        } else {
            print("no such file")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

