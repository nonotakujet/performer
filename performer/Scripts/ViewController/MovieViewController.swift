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

    var movieId : String = ""
    var movieFileName : String = ""

    // VideoPlayer.
    var videoPlayer : AVPlayer!
    
    // stampView
    var stampView : StampView!
    
    // tapRecord
    var oldTapRecordHolder : TapRecordHolder!
    var tapRecordHolder : TapRecordHolder!
    var lastTime : Float64!
    
    // sound.
    let se1 = Bundle.main.path(forResource: "Assets/Sounds/nobishiro", ofType: "m4a")!
    let se2 = Bundle.main.path(forResource: "Assets/Sounds/cheer", ofType: "mp3")!
    let se3 = Bundle.main.path(forResource: "Assets/Sounds/sugee", ofType: "m4a")!
    let se4 = Bundle.main.path(forResource: "Assets/Sounds/fuun", ofType: "m4a")!
    var soundPlayers : [AVAudioPlayer]!
    
    override func viewDidLoad() {

        // 親クラスのLoad完了処理.
        super.viewDidLoad()
        let path = String(format: "https://d1oiv9b8vu4q3j.cloudfront.net/%@/movies/%@.m3u8", movieFileName, movieFileName)
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url) // .m3u8 file
        let playerItem = AVPlayerItem(asset: asset)

        videoPlayer = AVPlayer(playerItem: playerItem)

        // AudioPlayerの生成
        let sePaths = [ se1, se2, se3, se4 ]
        soundPlayers = []
        for sePath in sePaths {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sePath))
                audioPlayer.volume = 0.2
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                soundPlayers.append(audioPlayer)
            } catch {
                print("failed audio player instantiate.")
                return
            }
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
        let docRef = db.collection("reactions").document(movieId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let json = document.data()?["data"] as! String
                if (!json.isEmpty)
                {
                    let serializer = ReactionSaveDataSerializer()
                    let saveData = serializer.deserialize(json: json)
                    self.oldTapRecordHolder = TapRecordHolder(reactionSaveData: saveData)
                }
            } else {
                // default data
                let serializer = ReactionSaveDataSerializer()
                let saveData = ReactionSaveData()
                db.collection("reactions").document(self.movieId).setData(["data": serializer.serialize(instance: saveData)]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
        }
        
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
        let audioPlayer = soundPlayers[index - 1]
        audioPlayer.currentTime = 0
        audioPlayer.play()
        
        let time : Float64 = CMTimeGetSeconds(videoPlayer.currentTime())
        tapRecordHolder.addRecord(time: time, index: index)
    }
    
    @objc func videoPlayerDidFinishPlaying() {
        // 再生が終了したら呼ばれる
        print("play finished!!")

        let db = Firestore.firestore()
        let sfReference = db.collection("reactions").document(movieId)
        
        // Transaction
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                print("[performer] fetch error pass")
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let saveData : ReactionSaveData
            let serializer = ReactionSaveDataSerializer()
            if sfDocument.exists {
                let json = sfDocument.data()?["data"] as! String
                if (!json.isEmpty)
                {
                    print("[performer] deserialize json")
                    saveData = serializer.deserialize(json: json)
                } else {
                    print("[performer] data is empty")
                    saveData = ReactionSaveData()
                }
            } else {
                print("[performer] document not existed")
                saveData = ReactionSaveData()
            }

            saveData.addTapRecord(records: self.tapRecordHolder.records)
            transaction.setData(["data" : serializer.serialize(instance: saveData)], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
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
            let audioPlayer = soundPlayers[index - 1]
            audioPlayer.currentTime = 0
            audioPlayer.play()

        }
    }
}

