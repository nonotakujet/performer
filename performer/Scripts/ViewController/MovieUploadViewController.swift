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
import AWSS3

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

    // 選択しているファイルをS3へアップロード
    func uploadData(url: URL?, key: String, _ complete: @escaping () -> Void, _ failure: @escaping (Error?) -> Void) {
        let data = Bundle.main.infoDictionary! as Dictionary
        let bucket = data["Storage Bucket Name"] as! String
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = url!
        uploadRequest?.key = key
        uploadRequest?.bucket = bucket
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { task -> AnyObject? in
            if let error = task.error as NSError? {
                print("localizedDescription:\n\(error.localizedDescription)")
                print("userInfo:\n\(error.userInfo)")
                failure(error) // 失敗
            } else {
                complete() // 成功
            }
            return nil
        }
    }

    /// 投稿ボタンが押された時のcallback.
    @objc func onClickUploadButton(sender: UIButton) {
        // くるくる表示
        self.showIndicator()
    
        let date = Date()
        let fileKey = String(Int(floor(date.timeIntervalSince1970)))

        // アップロード処理
        self.uploadData(url: Const.getTemporaryMoviePath(), key: fileKey, {
            // くるくる非表示
            self.hideIndicator()
         
            // indexデータ作成
            let db = Firestore.firestore()
            db.collection("movies").document(fileKey).setData(["file_name": fileKey])
         
            self.showAlert(title: "アップロード", message: "アップロードが完了しました。")
        }, { error in
            if let e = error as NSError? {
                print("localizedDescription:\n\(e.localizedDescription)")
                print("userInfo:\n\(e.userInfo)")
            }
            // くるくる非表示
            self.hideIndicator()
            self.showAlert(title: "アップロード", message: "アップロードが失敗しました。")
        })

    }

    func showIndicator() {
        // メインスレッドに戻ってUIに絡む
        DispatchQueue.main.async {
            // インジケータビューの背景
            let indicatorBackgroundView = UIView(frame: self.view.bounds)
            indicatorBackgroundView.backgroundColor = UIColor.black
            indicatorBackgroundView.alpha = 0.4
            indicatorBackgroundView.tag = 100100

            let indicator = UIActivityIndicatorView()
            indicator.activityIndicatorViewStyle = .whiteLarge
            indicator.center = self.view.center
            indicator.color = UIColor.white
            // アニメーション停止と同時に隠す設定
            indicator.hidesWhenStopped = true

            // 作成したviewを表示
            indicatorBackgroundView.addSubview(indicator)
            self.view.addSubview(indicatorBackgroundView)

            indicator.startAnimating()
        }
    }

    func hideIndicator(){
        // メインスレッドに戻ってUIに絡む
        DispatchQueue.main.async {
            // viewにローディング画面が出ていれば閉じる
            if let viewWithTag = self.view.viewWithTag(100100) {
                viewWithTag.removeFromSuperview()
            }
        }
    }

   // アラート表示
    func showAlert(title: String, message: String) {
        // OKボタンの処理
        let defaultAction = UIAlertAction(title: "OK", style: .default)

        // アラート表示
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
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
