//
//  TapRecord.swift
//  performer
//
//  Created by Taku Nonomura on 2018/05/25.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import Foundation

struct TapRecord : Codable
{
    var time : Float64
    var index : Int
}

class TapRecordHolder
{
    init()
    {
        records = []
    }

    public func GetRecords(bfTime: Float64, afTime: Float64) -> [Int]
    {
        var targets : [Int] = []
        for record in records {
            if (record.time > bfTime && record.time <= afTime) {
                targets.append(record.index)
            }
        }
        return targets
    }

    /// タップ結果を追加します.
    ///
    /// - Parameters:
    ///   - time: 経過時間
    ///   - index: tapIndex
    public func addRecord(time: Float64, index: Int)
    {
        let newRecord = TapRecord(time: time, index: index)
        records.append(newRecord)
    }
    
    /// JsonをStringにSerializeする.
    ///
    /// - Returns: Jsonの文字列を返す.
    public func SerializeToJson() -> String
    {
        let encorder = JSONEncoder()
        encorder.outputFormatting = .prettyPrinted
        let encoded = try! encorder.encode(records)
        return String(data: encoded, encoding: .utf8)!
    }
    
    public func JsonToObject(json : String)
    {
        let list = json.data(using: .utf8)!
        let records = try? JSONDecoder().decode([TapRecord].self, from: list)
        self.records = records!
    }

    /*
     * member変数
     */
    
    var records : [TapRecord]
}
