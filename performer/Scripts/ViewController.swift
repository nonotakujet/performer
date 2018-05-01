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

    // AVPlayer.
    var videoPlayer : AVPlayer!
    
    override func viewDidLoad() {

        // 親クラスのLoad完了処理.
        super.viewDidLoad()
        
        // VideoPlayerの生成.
        if let bundlePath = Bundle.main.path(forResource: "Assets/Movies/baseball1", ofType: "mov") {
            
            // Player.
            videoPlayer = AVPlayer(url: URL(fileURLWithPath: bundlePath))
            
            // Viewを生成.
            let videoPlayerView = AVPlayerView(frame: self.view.bounds)
            
            // UIViewのレイヤーをAVPlayerLayerにする.
            let playerLayer = videoPlayerView.layer as! AVPlayerLayer
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            playerLayer.player = videoPlayer
            self.view.layer.addSublayer(playerLayer)
            
            // 動画の再生ボタンを生成.
            let startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            startButton.layer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 50)
            startButton.layer.masksToBounds = true
            startButton.layer.cornerRadius = 20.0
            startButton.backgroundColor = UIColor.orange
            startButton.setTitle("Start", for: UIControlState.normal)
            startButton.addTarget(self, action: #selector(self.onStartButtonClick), for: UIControlEvents.touchUpInside)
            self.view.addSubview(startButton)
            
        } else {
            print("no such file")
            return
        }        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onStartButtonClick(sender: UIButton) {
        if sender.titleLabel?.text == "Start" {
            videoPlayer.play()
            sender.setTitle("Stop", for: UIControlState.normal)
        } else {
            videoPlayer.pause()
            sender.setTitle("Start", for: UIControlState.normal)
        }
    }
}

