//
//  MovieSelectViewController.swift
//  performer
//
//  閲覧する動画選択のViewController.
//
//  Created by Taku Nonomura on 2018/05/01.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class MovieSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct MovieRecord
    {
        var documentId : String
        var fileName : String
    }

    @IBOutlet var table: UITableView!
    var movies : [MovieRecord]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        movies = []
        let db = Firestore.firestore()
        db.collection("movies").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let documentId = document.documentID
                    let fileName = document.data()["file_name"] as! String
                    let record : MovieRecord = MovieRecord(documentId: documentId, fileName: fileName)
                    self.movies.append(record)
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
        let movie = movies[indexPath.row]
        cell.setUp(movieId: movie.documentId)
        return cell
    }

    // Cell の高さを80にする
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    // Touchされた時の処理.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toMovie", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath : IndexPath = sender as! IndexPath
        let movie = movies[indexPath.row]
        let nextView = segue.destination as! MovieViewController
        nextView.movieId = movie.documentId
        nextView.movieFileName = movie.fileName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
