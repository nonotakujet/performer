//
//  Const.swift
//  performer
//
//  Created by Taku Nonomura on 2019/01/01.
//  Copyright © 2019年 visioooon. All rights reserved.
//
import UIKit

class Const
{
    static let BASE_URL = "https://d1oiv9b8vu4q3j.cloudfront.net"
    static let IMAGE_CACHE_SEC : Double = 5 * 60; // 5分キャッシュ

    static func getTemporaryMoviePath() -> URL
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String = "\(documentsDirectory)/temp.mp4"
        return URL(fileURLWithPath: filePath)
    }
}
