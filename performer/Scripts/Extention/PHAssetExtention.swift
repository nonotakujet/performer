//
//  PHAssetExtention.swift
//  performer
//
//  Created by Taku Nonomura on 2018/09/30.
//  Copyright © 2018年 visioooon. All rights reserved.
//
import Foundation
import Photos

extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            PHImageManager.default().requestImageData(for: self, options: nil, resultHandler: { (_, _, _, info) in
                if let fileUrl = info?["PHImageFileURLKey"] as? URL {
                    completionHandler(fileUrl)
                } else {
                    completionHandler(nil)
                }
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
