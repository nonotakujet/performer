//
//  MovieCaptureViewController.swift
//  performer
//
//  Created by Taku Nonomura on 2019/01/02.
//  Copyright © 2019年 visioooon. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

class MovieCaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, LibraryDelegate {
    let fileOutput = AVCaptureMovieFileOutput()
    var recordButton: UIButton!
    var libraryButton: UIButton!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPreview()
    }

    func setUpPreview() {
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)

        do {
            if videoDevice == nil || audioDevice == nil {
                throw NSError(domain: "device error", code: -1, userInfo: nil)
            }
            let captureSession = AVCaptureSession()

            // video inputを capture sessionに追加
            let videoInput = try AVCaptureDeviceInput(device: videoDevice!)
            captureSession.addInput(videoInput)

            // audio inputを capture sessionに追加
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession.addInput(audioInput)

            // max 30sec
            self.fileOutput.maxRecordedDuration = CMTimeMake(30, 1)
            captureSession.addOutput(fileOutput)

            // プレビュー
            let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.frame = self.view.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.addSublayer(videoLayer)

            captureSession.startRunning()

            setUpButton()
        } catch {
            // エラー処理
        }
    }

    func setUpButton() {
        // 撮影ボタン
        recordButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
        recordButton.backgroundColor = UIColor.gray
        recordButton.layer.masksToBounds = true
        recordButton.setTitle("録画開始", for: UIControlState.normal)
        recordButton.layer.cornerRadius = 20.0
        recordButton.layer.position = CGPoint(x: self.view.bounds.width/2 - 100, y:self.view.bounds.height - 80)
        recordButton.addTarget(self, action: #selector(MovieCaptureViewController.onClickRecordButton(sender:)), for: .touchUpInside)
        self.view.addSubview(recordButton)
        
        // ライブラリボタン
        libraryButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
        libraryButton.backgroundColor = UIColor.gray
        libraryButton.layer.masksToBounds = true
        libraryButton.setTitle("ライブラリ", for: UIControlState.normal)
        libraryButton.layer.cornerRadius = 20.0
        libraryButton.layer.position = CGPoint(x: self.view.bounds.width/2 + 100, y:self.view.bounds.height - 80)
        libraryButton.addTarget(self, action: #selector(MovieCaptureViewController.onClickLibraryButton(sender:)), for: .touchUpInside)
        self.view.addSubview(libraryButton)
    }

    @objc func onClickRecordButton(sender: UIButton) {
        if !isRecording {
            // 録画開始
            let fileURL = Const.getTemporaryMoviePath()
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)

            isRecording = true
            changeButtonColor(target: recordButton, color: UIColor.red)
            recordButton.setTitle("録画中", for: .normal)
        } else {
            // 録画終了
            fileOutput.stopRecording()
            isRecording = false
            changeButtonColor(target: recordButton, color: UIColor.gray)
            recordButton.setTitle("録画開始", for: .normal)
        }
    }

    func changeButtonColor(target: UIButton, color: UIColor) {
        target.backgroundColor = color
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // ライブラリへ保存
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                print("Video is saved!")
            }
        }
    }
    
    @objc func onClickLibraryButton(sender: UIButton) {
        self.performSegue(withIdentifier: "toMovieLibrary", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextView = segue.destination as! MovieUploadViewController
        nextView.delegate = self
    }

    /// ライブラリで選択された時のコールバック
    ///
    /// - Parameter path: 保存されたパス
    func onSelected(path: String) {

    }
    
    /// ライブラリから選択されずに戻ったときのコールバック
    func onBack() {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
