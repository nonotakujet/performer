//
//  MovieEditViewController.swift
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

class MovieEditViewController: UIViewController, AVAudioPlayerDelegate  {

    var videoPlayer : AVPlayer!
    var nextButton : UIButton!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {

        // 親クラスのLoad完了処理.
        super.viewDidLoad()

        let url = Const.getTemporaryMoviePath()
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        videoPlayer = AVPlayer(playerItem: playerItem)

        // Viewを生成.
        let videoPlayerView = AVPlayerView(frame: self.view.bounds)
        
        // UIViewのレイヤーをAVPlayerLayerにする.
        let playerLayer = videoPlayerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.player = videoPlayer
        self.view.layer.insertSublayer(playerLayer, at: 0)

        // 終了通知を受けつける.
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)

        // 次へボタン
        nextButton = UIButton(frame: CGRect(x: 0,y: 0,width: 100,height: 50))
        nextButton.backgroundColor = UIColor.gray
        nextButton.layer.masksToBounds = true
        nextButton.setTitle("次へ", for: UIControlState.normal)
        nextButton.layer.cornerRadius = 20.0
        nextButton.layer.position = CGPoint(x: self.view.bounds.width/2 + 120, y:self.view.bounds.height - 50)
        nextButton.addTarget(self, action: #selector(MovieEditViewController.onClickNextButton(sender:)), for: .touchUpInside)
        self.view.addSubview(nextButton)

        // backボタン
        backButton.addTarget(self, action: #selector(self.onBackButtonClick), for: UIControlEvents.touchUpInside)

        videoPlayer.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 次へボタンが押された時のcallback.
    @objc func onClickNextButton(sender: UIButton) {
    }
    
    /// backボタンが押された時のcallback.
    @objc func onBackButtonClick(sender: UIButton) {
        videoPlayer.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func videoPlayerDidFinishPlaying() {
        print("play completed!!")

        // 再生が終了したら呼ばれる
        videoPlayer.seek(to: kCMTimeZero)
        videoPlayer.play()
    }
}

