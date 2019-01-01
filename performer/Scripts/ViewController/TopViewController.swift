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
import Firebase
import FirebaseFirestore

class TopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
    var movies : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        movies = []

        let db = Firestore.firestore()
        db.collection("movies").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.movies.append(document.documentID)
                }
                self.table.reloadData()
            }
        }
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        guard let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? TopViewCell else { fatalError("unexpected cell in collection view") }
        cell.setUp(movieId: movies[indexPath.row])
        return cell
    }

    // Cell の高さを80にする
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    // Touchされた時の処理.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let documentId = movies[indexPath.row]
        let db = Firestore.firestore()
        let docRef = db.collection("movies").document(documentId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let fileName = document.data()?["file_name"] as! String
                if (!fileName.isEmpty)
                {
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "Movie") as! MovieViewController
                    nextView.movieId = documentId
                    nextView.movieFileName = fileName
                    self.present(nextView, animated: true, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
