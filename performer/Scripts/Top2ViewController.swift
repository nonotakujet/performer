//
//  TopViewController.swift
//  performer
//
//  TopのViewController.
//
//  Created by Taku Nonomura on 2018/05/01.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit

class Top2ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var table:UITableView!
    
    // section毎の画像配列
    let imgArray: NSArray = [
        "img0","img1",
        "img2","img3",
        "img4","img5",
        "img6","img7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        guard let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? TopViewCell else { fatalError("unexpected cell in collection view") }
        return cell
    }

    // Cell の高さを150にする
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
