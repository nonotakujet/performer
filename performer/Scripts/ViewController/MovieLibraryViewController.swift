//
//  MovieLibraryViewController.swift
//  performer
//
//  Created by Taku Nonomura on 2018/09/17.
//  Copyright © 2018年 visioooon. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Firebase
import FirebaseFirestore

private let cellReuseIdentifier = "cell"
private let headerReuseIdentifier = "SectionHeader"

protocol LibraryDelegate {
    func onSelected(path: String)
    func onBack()
}
class MovieLibraryViewController: UICollectionViewController, MovieSelectHeaderButtonDelegate {

    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var headerView: MovieSelectHeaderView!
    var selectedIndex: IndexPath!
    var delegate: LibraryDelegate!

    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero

    override func viewDidLoad() {

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)

        // fetchResultが定義されてない時は、全てのAssetをFetchする.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: .video, options: allPhotosOptions)
        }

        super.viewDidLoad()
    }

    // TODO : nonomura - 調査
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let scale = UIScreen.main.scale
        let length = UIScreen.main.bounds.size.width / 3.0;
        let fl = collectionViewLayout as! UICollectionViewFlowLayout
        fl.itemSize = CGSize(width: length, height: length)
        fl.sectionHeadersPinToVisibleBounds = true
        
        thumbnailSize = CGSize(width: length * scale, height: length * scale) // NOTE : Retina対応で解像度高くしておく.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Cellの要素数を定義.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }

    // 各々のCellをinstantiateして、返す.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let asset = fetchResult.object(at: indexPath.item)

        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? MovieViewCell
            else { fatalError("unexpected cell in collection view") }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? MovieSelectHeaderView;

        if (kind == UICollectionElementKindSectionHeader) {
            headerView.activate()
            headerView.buttonDelegate = self
            return headerView
        }

        return UICollectionReusableView()
    }
    
    // Cell が選択された場合
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // すでに選択済みのrowが選択された
        if (selectedIndex == indexPath) {
            // 投稿ボタンを有効に.
            headerView.setPostButtonEnable(isEnabled: false)
            
            let currentCell = collectionView.cellForItem(at: indexPath) as? MovieViewCell
            currentCell?.isChecked = false

            selectedIndex = nil;
        } else {
            // 投稿ボタンを有効に.
            headerView.setPostButtonEnable(isEnabled: true)
            
            if (selectedIndex != nil)
            {
                let beforeCell = collectionView.cellForItem(at: selectedIndex) as? MovieViewCell
                beforeCell?.isChecked = false
            }
            let currentCell = collectionView.cellForItem(at: indexPath) as? MovieViewCell
            currentCell?.isChecked = true

            selectedIndex = indexPath
        }
    }

    // MARK: MovieSelectHeaderButtonDelegate

    //! 戻るボタンがおされた時のコールバック
    func onBack()
    {
        self.dismiss(animated: true, completion: { () in self.delegate.onBack()})
    }

    //! Postボタンがおされた時のコールバック
    func onPost()
    {
        let asset = self.fetchResult.object(at: self.selectedIndex.item)
        asset.getURL(completionHandler: { (url) in
            if (url != nil) {
                // コピー
                let destination : URL = Const.getTemporaryMoviePath()
                DispatchQueue.main.async {
                    do
                    {
                        // ファイルがすでに存在していたら削除.
                        if (FileManager.default.fileExists(atPath: destination.path))
                        {
                            try FileManager.default.removeItem(at: destination)
                        }
                        // コピー.
                        try FileManager.default.copyItem(at: url!, to: destination)

                        self.dismiss(animated: true, completion: {() in self.delegate.onSelected(path: destination.path)})
                    }
                    catch
                    {
                        self.showAlert(title: "エラー", message: "ライブラリの動画の選択に失敗しました")
                    }
                }
            } else {
                self.showAlert(title: "エラー", message: "ライブラリの動画の選択に失敗しました")
            }
        })
    }
    
   // アラート表示
    func showAlert(title: String, message: String) {
        // OKボタンの処理
        let defaultAction = UIAlertAction(title: "OK", style: .default)

        // アラート表示
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UIScrollView

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
         updateCachedAssets()
    }

    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }

        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }

        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }

        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
            targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
            targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)

        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }

    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                    width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                    width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                      width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                      width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }


}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension MovieLibraryViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }

        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}

