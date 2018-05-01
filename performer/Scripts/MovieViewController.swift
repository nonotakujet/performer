//
//  MovieViewController.swift
//  performer
//
//  MovieシーンのViewController.
//
//  Created by Taku Nonomura on 2018/04/30.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MovieViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var reactionView: UIStackView!

    // VideoPlayer.
    var videoPlayer : AVPlayer!
    // AudioPlayer.
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {

        // 親クラスのLoad完了処理.
        super.viewDidLoad()
        
        // VideoPlayerの生成.
        if let videoBundlePath = Bundle.main.path(forResource: "Assets/Movies/baseball1", ofType: "mov") {
            videoPlayer = AVPlayer(url: URL(fileURLWithPath: videoBundlePath))
        } else {
            print("not found movie file.")
            return
        }
        
        // AudioPlayerの生成
        if let soundBundlePath = Bundle.main.path(forResource: "Assets/Sounds/cheer", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundBundlePath))
                audioPlayer.volume = 0.5
                audioPlayer.prepareToPlay()
            } catch {
                print("failed audio player instantiate.")
                return
            }
        } else {
            print("not found audio file.")
            return
        }
        
        // Viewを生成.
        let videoPlayerView = AVPlayerView(frame: self.view.bounds)
        
        // UIViewのレイヤーをAVPlayerLayerにする.
        let playerLayer = videoPlayerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.player = videoPlayer
        self.view.layer.addSublayer(playerLayer)
        
        // playボタンのcallback登録.
        playButton.addTarget(self, action: #selector(self.onPlayButtonClick), for: UIControlEvents.touchUpInside)

        // backボタンのcallback登録.
        backButton.addTarget(self, action: #selector(self.onBackButtonClick), for: UIControlEvents.touchUpInside)
        
        /*
        // seボタンを生成.
        let seButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        seButton.layer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 50)
        seButton.layer.masksToBounds = true
        seButton.layer.cornerRadius = 20.0
        seButton.backgroundColor = UIColor.orange
        seButton.tag = 2
        seButton.setTitle("拍手", for: UIControlState.normal)
        seButton.addTarget(self, action: #selector(self.onStartButtonClick), for: UIControlEvents.touchUpInside)
        seButton.isHidden = true; // as default.
        self.view.addSubview(seButton)
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// playボタンが押された時のcallback.
    @objc func onPlayButtonClick(sender: UIButton) {
        videoPlayer.play()
        playButton.isHidden = true
        reactionView.isHidden = false // reactionボタンたちを表示状態にする.
    }
    
    /// backボタンが押された時のcallback.
    @objc func onBackButtonClick(sender: UIButton) {
        videoPlayer.pause()
        self.dismiss(animated: true, completion: nil)
    }
}

