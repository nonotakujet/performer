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
import Firebase
import FirebaseFirestore

class MovieViewController: UIViewController, ButtonTappedDelegate, AVAudioPlayerDelegate {
    
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
    
    // tapRecord
    var oldTapRecordHolder : TapRecordHolder!
    var tapRecordHolder : TapRecordHolder!
    var lastTime : Float64!
    
    override func viewDidLoad() {

        // 親クラスのLoad完了処理.
        super.viewDidLoad()
        
        // VideoPlayerの生成.
        if let videoBundlePath = Bundle.main.path(forResource: "Assets/Movies/onuma", ofType: "mov") {
            videoPlayer = AVPlayer(url: URL(fileURLWithPath: videoBundlePath))
        } else {
            print("not found movie file.")
            return
        }
        
        // AudioPlayerの生成
        if let soundBundlePath = Bundle.main.path(forResource: "Assets/Sounds/cheer", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundBundlePath))
                audioPlayer.volume = 0.2
                audioPlayer.prepareToPlay()

                // AVAudioPlayerのデリゲートをセット
                audioPlayer.delegate = self
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

        // 終了通知を受けつける.
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)

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
        
        // tapRecordを生成
        oldTapRecordHolder = TapRecordHolder()
        tapRecordHolder = TapRecordHolder()

        let db = Firestore.firestore()
        db.collection("reactions").limit(to: 1000).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let documents = querySnapshot!.documents.shuffled()
                for document in documents {
                    let json = document.data()["data"] as! String
                    if (!json.isEmpty)
                    {
                        self.oldTapRecordHolder.JsonToObject(json: json)
                        break;
                    }
                }
            }
        }

        /*
        let json = readJson()
        if (!json.isEmpty)
        {
            oldTapRecordHolder.JsonToObject(json: json)
        }
        */
        
        // MainLoop起動.
        Timer.scheduledTimer(timeInterval: 0.05,                     //ループなら間隔 1度きりなら発動までの秒数
            target: self,                                         //メソッドを持つオブジェクト
            selector: #selector(MovieViewController.loopUpdate),  //実行するメソッド
            userInfo: nil,                                        //オブジェクトに付けて送信する値
            repeats: true)                                       //繰り返し実行するかどうか
        lastTime = 0
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
    func onButton(index: Int, posX: CGFloat) {
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
        stampView.instantiateStamp(filePath: filePath, posX: posX)
        audioPlayer.currentTime = 0
        audioPlayer.play()
        
        let time : Float64 = CMTimeGetSeconds(videoPlayer.currentTime())
        tapRecordHolder.addRecord(time: time, index: index)
    }
    
    @objc func videoPlayerDidFinishPlaying() {
        // 再生が終了したら呼ばれる
        print("play finished!!")
        let json : String = tapRecordHolder.SerializeToJson()
        var ref: DocumentReference? = nil
        let db = Firestore.firestore()
        ref = db.collection("reactions").addDocument(data: [ "data": json ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    @objc func loopUpdate() {
        let time : Float64 = CMTimeGetSeconds(videoPlayer.currentTime())
        if (time <= 0.01)
        {
            return
        }
        
        let records = oldTapRecordHolder.GetRecords(bfTime: lastTime, afTime: time)
        lastTime = time

        for index in records {
            audioPlayer.currentTime = 0
            audioPlayer.play()

//            onButton(index, 200)
        }
    }
    
    func dumpJson(json : String) {
        let file_name = "data.txt"
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent( file_name )
            do {
                try json.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
            } catch {
                //エラー処理
            }
        }
    }
    
    // テキストを読み込むメソッド
    func readJson() -> String {
        let file_name = "data.txt"
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_file_name = dir.appendingPathComponent(file_name)
            do {
                let text = try String( contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                print( text )
                return text;
            } catch {
                //エラー処理
                return String();
            }
        }
        return String();
    }
}

