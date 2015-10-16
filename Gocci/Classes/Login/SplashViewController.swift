//
//  SplashViewController.swift
//  Gocci
//
//  Created by Markus Wanke on 08.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

import AVKit
import AVFoundation

enum ContinueConclusion {
    case GO_TO_TIMELINE
    case GO_TO_TUTORIAL
    case NO_INTERNET
    case BACKEND_CONNECTION_FAILED
    case USER_DATA_MALFORMED
    case NOT_SURE_YET
}


class SplashViewController : UIViewController {
    
    let moviePlayer = AVPlayerViewController()
    var conclusion = ContinueConclusion.NOT_SURE_YET
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO Download an prebuffer first video. warning: you are not logged in here
        
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("splash_tmp_sample", ofType: "mp4")!)
        moviePlayer.view.frame = view.frame
        moviePlayer.showsPlaybackControls = false
        moviePlayer.view.userInteractionEnabled = false
        
        //moviePlayer.videoGravity = AVLayerVideoGravityResize
        //moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect
        moviePlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //moviePlayer.view.alpha = 0.7
        //view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(moviePlayer.view)
        view.sendSubviewToBack(moviePlayer.view)
        
        self.moviePlayer.player = AVPlayer(URL: url)
        self.moviePlayer.player?.volume = 1.0
        // remove the audio stream from the file: ffmpeg -i splash.mp4 -vcodec copy -an splash_with_no_sound.mp4
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItemDidReachEnd",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tabToSkipVideo:"))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        
        self.moviePlayer.player?.play()
        
        self.login()
    }
    
    func login() {
        
        let handleNetOpResult: (NetOpResult, String!) -> Void = { (code, msg) -> Void in
            switch code {
            case NetOpResult.NETOP_SUCCESS:
                AWS2.connectToBackEndWithUserDefData().continueWithBlock({ (task) -> AnyObject! in
                    self.conclusion = ContinueConclusion.GO_TO_TIMELINE
                    return nil
                })
            case NetOpResult.NETOP_NETWORK_ERROR:
                self.conclusion = ContinueConclusion.NO_INTERNET
            case NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD:
                self.conclusion = ContinueConclusion.USER_DATA_MALFORMED
            default:
                self.conclusion = ContinueConclusion.BACKEND_CONNECTION_FAILED
            }
        }
        
        
        if let iid = Util.getUserDefString("iid") {            NetOp.loginWithIID(iid, andThen: handleNetOpResult)
        }
        else if let un = Util.getUserDefString("username"), ava = Util.getUserDefString("avatarLink") {
            NetOp.loginWithAPIV2Conversation(un, avatar: ava, andThen: handleNetOpResult)
        }
        else {
            self.conclusion = ContinueConclusion.GO_TO_TUTORIAL

        }
        
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func playerItemDidReachEnd() {
        
        if handleEvent() {
            moviePlayer.player?.seekToTime(kCMTimeZero)
            moviePlayer.player?.play()
        }
    }
    

    
    func tabToSkipVideo(sender: UITapGestureRecognizer) {
        handleEvent()
    }
    
    // "TRANSLATION NEEDED"
    func handleEvent() -> Bool {
        switch self.conclusion {
            case .GO_TO_TIMELINE:
                self.performSegueWithIdentifier("goTimeline", sender: self)
                return false
            
            case .GO_TO_TUTORIAL:
                self.performSegueWithIdentifier("goTutorial", sender: self)
                return false
            
            case .NO_INTERNET:
                Util.popup("You need internet for Gocci :(")
            
            case .BACKEND_CONNECTION_FAILED:
                Util.popup("Gocci server are currently under maintance :(")

            case .USER_DATA_MALFORMED:
                Util.popup("Your userdate is malformed, this should never happen. Please login with username and password, or use an SNS service.")
                self.performSegueWithIdentifier("goRelogin", sender: self)
                return false
                
            case .NOT_SURE_YET:
                // The user skipped the video before the server login happened. This function will be called again, don't worry
                break
        }

        return true
    }
    
}



