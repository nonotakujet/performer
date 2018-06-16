//
//  ReactionSaveData.swift
//  performer
//
//  Created by Taku Nonomura on 2018/06/16.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import Foundation

/*
 * Data Struct
 */

class ReactionSaveData : Codable
{
    var reactionNum : UInt64
    var results : [ReactionResult]
    
    init()
    {
        reactionNum = 0
        results = []
    }
    
    // 現在のresult結果に、tapRecordを加えます.
    func addTapRecord(records: [TapRecord])
    {
        for record in records {
            let time  = UInt32(ceil(record.time))
            let index = record.index

            var bFoundResult = false
            for result in results {
                if (result.timeSecond != time) {
                    continue
                }

                print("===find result===")

                print("time: \(time)")
                print("before reactions: \(result.reactionNums)")

                let reactionNum = result.reactionNums[index - 1] + 1
                result.reactionNums[index - 1] = reactionNum

                print("after reactions: \(result.reactionNums)")
                
                bFoundResult = true
                break
            }
            
            if (!bFoundResult) {
                let result = ReactionResult()
                result.timeSecond = time
                result.reactionNums[index - 1] = 1
                results.append(result)
            }
        }
        
        let recordsCount = UInt64(records.count)
        reactionNum = reactionNum + recordsCount
    }
}

class ReactionResult : Codable
{
    init()
    {
        timeSecond = 0
        reactionNums = [0,0,0,0]
    }
    
    var timeSecond: UInt32
    var reactionNums : [UInt64]
}

/*
 * Data Serialize/Deserialize
 */

class ReactionSaveDataSerializer
{
    func serialize(instance: ReactionSaveData) -> String {
        let encorder = JSONEncoder()
        encorder.outputFormatting = .prettyPrinted
        let encoded = try! encorder.encode(instance)
        return String(data: encoded, encoding: .utf8)!
    }
    
    func deserialize(json: String) -> ReactionSaveData {
        let jsonData = json.data(using: .utf8)!
        let instance = try? JSONDecoder().decode(ReactionSaveData.self, from: jsonData)
        return instance!
    }
}
