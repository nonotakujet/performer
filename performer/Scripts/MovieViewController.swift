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

class MovieViewController: UIViewController, ButtonTappedDelegate {
    
    /// outlet.
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var reactionViewRoot: UIView!
    @IBOutlet var reactionView: ReactionView!
    
    // VideoPlayer.
    var videoPlayer : AVPlayer!
    // AudioPlayer.
    var audioPlayer : AVAudioPlayer!
    
    // stampView
    var stampView : StampView!
    
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
        self.view.layer.insertSublayer(playerLayer, at: 0)

        // playボタンのcallback登録.
        playButton.addTarget(self, action: #selector(self.onPlayButtonClick), for: UIControlEvents.touchUpInside)

        // backボタンのcallback登録.
        backButton.addTarget(self, action: #selector(self.onBackButtonClick), for: UIControlEvents.touchUpInside)

        // ReactionViewを追加.
        reactionView.activate()
        reactionView.buttonDelegate = self
        reactionViewRoot.addSubview(reactionView)
        
        // stampViewを追加.
        stampView = StampView()
        self.view.addSubview(stampView.GetViewNode())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// playボタンが押された時のcallback.
    @objc func onPlayButtonClick(sender: UIButton) {
        videoPlayer.play()
        playButton.isHidden = true
        reactionViewRoot.isHidden = false
    }
    
    /// backボタンが押された時のcallback.
    @objc func onBackButtonClick(sender: UIButton) {
        videoPlayer.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    /// reactionViewのbuttonのcallback.
    func onButton(index: Int) {
        var filePath = String()
        switch index {
        case 1:
            filePath = "Assets/Icons/onpu.png"
            break
        case 2:
            filePath = "Assets/Icons/onpu2.png"
            break
        case 3:
            filePath = "Assets/Icons/fire.png"
            break
        case 4:
            filePath = "Assets/Icons/good.png"
            break
        default:
            filePath = "Assets/Icons/good.png"
            break
        }
        stampView.instantiateStamp(filePath: filePath)
    }
}

