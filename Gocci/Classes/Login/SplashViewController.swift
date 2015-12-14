//
//  SplashViewController.swift
//  Gocci
//
//  Created by Markus Wanke on 08.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

//import AVKit
//import AVFoundation
//
//enum ContinueConclusion {
//    case GO_TO_TIMELINE
//    case GO_TO_TUTORIAL
//    case NO_INTERNET
//    case BACKEND_CONNECTION_FAILED
//    case USER_DATA_MALFORMED
//    case NOT_SURE_YET
//}


class SplashViewController : UIViewController {
    
   // let moviePlayer = AVPlayerViewController()
    
//    var conclusion = ContinueConclusion.NOT_SURE_YET {
//        didSet {
//            Util.runOnMainThread {
//                self.handleEvent()
//            }
//        }
//    }
    
    
    var loggingIn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //////////// remove this if you use video splash again
        let bg = UIImage(named: "1334-750-g")!
        
        let iv = UIImageView(image: bg)
        iv.frame = self.view.frame
        self.view.insertSubview(iv, atIndex: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tabToReloginTry:"))
        view.addGestureRecognizer(tapGesture)
        
        //////////////////////////////////////////////////////
        
        
        // TODO Download an prebuffer first video. warning: you are not logged in here
        
//        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("splash_tmp_sample", ofType: "mp4")!)
//        moviePlayer.view.frame = view.frame
//        moviePlayer.showsPlaybackControls = false
//        moviePlayer.view.userInteractionEnabled = false
//        
//        //moviePlayer.videoGravity = AVLayerVideoGravityResize
//        //moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect
//        moviePlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
//        
//        //moviePlayer.view.alpha = 0.7
//        //view.backgroundColor = UIColor.blackColor()
//        
//        view.addSubview(moviePlayer.view)
//        view.sendSubviewToBack(moviePlayer.view)
//        
//        self.moviePlayer.player = AVPlayer(URL: url)
//        self.moviePlayer.player?.volume = 1.0
//        // remove the audio stream from the file: ffmpeg -i splash.mp4 -vcodec copy -an splash_with_no_sound.mp4
//        
//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector: "playerItemDidReachEnd",
//            name: AVPlayerItemDidPlayToEndTimeNotification,
//            object: nil)
//
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tabToSkipVideo:"))
//        view.addGestureRecognizer(tapGesture)
        

    }
    
    func tabToReloginTry(sender: UITapGestureRecognizer) {
        if !loggingIn {
            loggingIn = true
            login()
        }
    }
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        
        //self.moviePlayer.player?.play()
        
        self.login()
    }
    
    
    func login() {
        
        
        if Persistent.identity_id == nil && Util.getUserDefString("identity_id") == nil {
            self.performSegueWithIdentifier("goTutorial", sender: self)
        }
        else {
            APIHighLevel.simpleLogin { success in
                
                if success {
                    self.performSegueWithIdentifier("goTimeline", sender: self)

                }
                else {
                    let pop = Util.overlayPopup("Login failed :(", "Your userdata is malformed, this should never happen. Please login with username and password, or use an SNS service.")
                    pop.addButton("Retry", style: UIAlertActionStyle.Default) { self.login() }
                    pop.addButton("Relogin", style: UIAlertActionStyle.Default) {
                        self.performSegueWithIdentifier("goRelogin", sender: self)
                    }
                    pop.overlay()
                    
                    
                }
            }
            
            // Not really that ugly, but yeah, will be fixed one day
            Util.runInBackground {
                Util.sleep(3) {
                    self.loggingIn = false
                }
            }
        }
    }

    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
//    func playerItemDidReachEnd() {
//        
//        if handleEvent() {
//            moviePlayer.player?.seekToTime(kCMTimeZero)
//            moviePlayer.player?.play()
//        }
//    }
    

    
//    func tabToSkipVideo(sender: UITapGestureRecognizer) {
//        handleEvent()
//    }
//    
//    func handleEvent() -> Bool {
//        switch self.conclusion {
//            case .GO_TO_TIMELINE:
//                self.performSegueWithIdentifier("goTimeline", sender: self)
//                return false
//            
//            case .GO_TO_TUTORIAL:
//                self.performSegueWithIdentifier("goTutorial", sender: self)
//                return false
//            
//            case .NO_INTERNET:
//                // TODO TRANSLATION
//                let pop = Util.overlayPopup("Login failed :(", "You need internet for Gocci")
//                pop.addButton("Retry", style: UIAlertActionStyle.Default) { self.login() }
//                pop.overlay()
//            
//            case .BACKEND_CONNECTION_FAILED:
//                // TODO TRANSLATION
//                let pop = Util.overlayPopup("Login failed :(", "Gocci server are currently under maintance")
//                pop.addButton("Retry", style: UIAlertActionStyle.Default) { self.login() }
//                pop.overlay()
//
//            case .USER_DATA_MALFORMED:
//                // TODO TRANSLATION
//                let pop = Util.overlayPopup("Login failed :(", "Your userdata is malformed, this should never happen. Please login with username and password, or use an SNS service.")
//                pop.addButton("Retry", style: UIAlertActionStyle.Default) { self.login() }
//                pop.addButton("Relogin", style: UIAlertActionStyle.Default) {
//                    self.performSegueWithIdentifier("goRelogin", sender: self)
//                }
//                pop.overlay()
//                
//                return false
//                
//            case .NOT_SURE_YET:
//                // The user skipped the video before the server login happened. This function will be called again, don't worry
//                break
//        }
//
//        return true
//    }
    
}



