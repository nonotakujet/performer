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
    // default ctor
    init()
    {
        records = []
    }
    
    // サーバーに保存されているSaveDataから作成するコンストラクタ
    init(reactionSaveData: ReactionSaveData)
    {
        records = []
        
        // reactionを再生する下限のreaction数を計算.
        let lowerLimitNum = UInt64(ceil(Double(reactionSaveData.reactionNum) * 0.01))
        
        for result in reactionSaveData.results {
            
            for index in [1,2,3,4] {
                let indexReactionNum = result.reactionNums[index - 1]
                if (indexReactionNum < lowerLimitNum) {
                    continue;
                }
                
                let record = TapRecord(time: Float64(result.timeSecond), index: index)
                records.append(record)
            }
        }
        
        // time順にsort
        records.sort(by: {$0.time < $1.time})
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
    
    // recordは必ず、time順にsordされていること
    var records : [TapRecord]
}
