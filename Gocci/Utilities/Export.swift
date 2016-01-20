//
//  Export.swift
//  Gocci
//
//  Created by Ma Wa on 20.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

// TODO NIHONGO TARANSLATION


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
            Util.saveMovieAtPathToCameraRoll(localURL) { succ in
                if succ {
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
                
                Util.saveMovieAtPathToCameraRoll(fileURL) { succ in
                    if succ {
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
}




