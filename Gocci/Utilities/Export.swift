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
            let pop = UIAlertController.makeOverlayPopup("Warning", "Already exporting a video. Only one at a time")
            pop.addButton("Ok", style: UIAlertActionStyle.Cancel) { }
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
                    Toast.情報("Success", "Saved to your camera roll")
                }
                else {
                    Toast.失敗("Failure", "Failed to save the video to your camera roll")
                }
                inAction = false
            }
            return
        }
        
        
        let req = API3.get.post()
        
        req.parameters.post_id = postID
        
        req.onAnyAPIError {
            Toast.失敗("Failure", "Failed to save the video to your camera roll")
        }
        
        req.perform { payload in
            
            guard let url = NSURL(string: payload.mp4_movie) else {
                Toast.失敗("Failure", "Failed to save the video to your camera roll")
                inAction = false
                return
            }
            
            APILowLevel.cacheFile(url, filename: postID + ".mp4") { fileURL in
                
                guard let fileURL = fileURL else {
                    Toast.失敗("Failure", "Failed to save the video to your camera roll")
                    inAction = false
                    return
                }
                
                Util.saveMovieAtPathToCameraRoll(fileURL) { succ in
                    if succ {
                        Toast.情報("Success", "Saved to your camera roll")
                    }
                    else {
                        Toast.失敗("Failure", "Failed to save the video to your camera roll")
                    }
                    inAction = false
                }
            }
        }
    }
}




