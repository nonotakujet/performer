//
//  File.swift
//  performer
//
//  Created by Taku Nonomura on 2019/01/01.
//  Copyright © 2019年 visioooon. All rights reserved.
//

import UIKit
import Foundation

// 指定URLから画像を読み込み、セットする
// defaultUIImageには、URLからの読込に失敗した時の画像を指定する
extension UIImageView {
    //画像を非同期で読み込む
    func loadImageAsynchronously(urlString: String) {
        let req = URLRequest(url: NSURL(string:urlString)! as URL,
                                cachePolicy: .returnCacheDataElseLoad,
                                timeoutInterval: Const.IMAGE_CACHE_SEC);
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main);

        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if ((err) == nil) { //Success
                    let image = UIImage(data:data!)
                    self.image = image;

                } else { //Error
                    print("AsyncImageView:Error \(err?.localizedDescription)");
                }
        }).resume();
    }
}
