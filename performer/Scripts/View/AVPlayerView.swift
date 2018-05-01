//
//  AVPlayerView.swift
//  performer
//
//  レイヤーをAVPlayerLayerにする為のラッパークラス.
//
//  Created by Taku Nonomura on 2018/05/01.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit
import AVFoundation

final class AVPlayerView : UIView {
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    func player() -> AVPlayer {
        return playerLayer.player!
    }
    
    func setPlayer(player: AVPlayer) {
        playerLayer.player = player
    }    
}
