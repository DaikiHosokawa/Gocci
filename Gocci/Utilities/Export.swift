//
//  Export.swift
//  Gocci
//
//  Created by Ma Wa on 20.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import Photos
import AssetsLibrary


@objc class Export: NSObject {
    
    
    // little bit... kinda ugly. not thread save etc
    static var inAction: Bool = false
    
    class func exportVideoToCameraRollForPostID(postID: String) {
        
        if inAction {
            let pop = UIAlertController.makeOverlayPopup("お知らせ", "一度に一個しかダウンロードできません")
            pop.addButton("OK", style: UIAlertActionStyle.Cancel) { }
            pop.overlay()
            return
        }
        inAction = true
        
        Util.runInBackground { realExportVideoToCameraRollForPostID(postID) }
    }
    
    class func realExportVideoToCameraRollForPostID(postID: String) {
        
        if let localURL = Util.mp4ForPostIDisAvailible(postID) {
            Export.saveMovieAtPathToCameraRoll(localURL) { url in
                if url != nil {
                    Toast.情報("成功", "カメラロールに保存しました")
                }
                else {
                    Toast.失敗("失敗", "保存に失敗しました")
                }
                inAction = false
            }
            return
        }
        
        
        let req = API4.get.post()
        
        req.parameters.post_id = postID
        
        req.onAnyAPIError {
            Toast.失敗("失敗", "保存に失敗しました")
        }
        
        req.perform { payload in
            
            guard let url = NSURL(string: payload.mp4_movie) else {
                Toast.失敗("失敗", "保存に失敗しました")
                inAction = false
                return
            }
            
            APILowLevel.cacheFile(url, filename: postID + ".mp4") { fileURL in
                
                guard let fileURL = fileURL else {
                    Toast.失敗("失敗", "保存に失敗しました")
                    inAction = false
                    return
                }
                
                Export.saveMovieAtPathToCameraRoll(fileURL) { url in
                    if url != nil {
                        Toast.情報("成功", "カメラロールに保存しました")
                    }
                    else {
                        Toast.失敗("失敗", "保存に失敗しました")
                    }
                    inAction = false
                }
            }
        }
    }
    
    
    
    class func saveMovieAtPathToCameraRoll(localFile: NSURL, and: NSURL?->()) {
        
        // this works only on the real device
        
        var localID: String?
        
        let doBlock = {
            if let req = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(localFile) {
                localID = req.placeholderForCreatedAsset?.localIdentifier
            }
        }
        
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges( doBlock ) { succ, error in
            if let error = error {
                Lo.error(error)
                and(nil)
                return
            }
            
            if !succ {
                Lo.error("export did not succeed")
                and(nil)
                return
            }
            
            guard let localID = localID else {
                Lo.error("localID id nil")
                and(nil)
                return
            }
            
            let assets = PHAsset.fetchAssetsWithLocalIdentifiers([localID], options: nil)
            
            guard let res: PHAsset = assets.firstObject as? PHAsset else {
                Lo.error("PHAsset result array empty")
                and(nil)
                return
            }
            
            and(NSURL(string: "assets-library://asset/asset.mp4?id=\(res.localIdentifier)&ext=mp4"))
        }
        
        

        
        
        //
        //            PHImageManager().requestAVAssetForVideo(res, options: nil) { asset, _, _ in
        //                if let ass: AVURLAsset =  asset as? AVURLAsset {
        //                    and(ass.URL)
        //                }
        //                else {
        //                    Lo.error("PHAsset request convert error")
        //                    and(nil)
        //                }
        //            }
        //
        //        }
        
        //        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(localFile) { url, error in
        //            
        //            if let e = error {
        //                Lo.error(e)
        //                and(nil)
        //            }
        //            else {
        //                Lo.green("Export to Camera Roll Complete. URL: \(url ?? nil)")
        //                and(url)
        //            }
        //        }
    }

}




