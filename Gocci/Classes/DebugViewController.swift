//
//  File.swift
//  Gocci
//
//  Created by Markus Wanke on 21.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary


class DebugViewController : UIViewController {
    
    var cnt: Int = 0
    
    var real_register_id: String = ""
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!

    
    @IBOutlet weak var signUpEditField: UITextField!
    @IBOutlet weak var loginEditField: UITextField!
    
    @IBOutlet weak var tokenEditField: UITextField!
    
    @IBOutlet weak var usernameEditField: UITextField!
    @IBOutlet weak var passwordEditField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subLabel.text = "Greatest Work - Gocci v" + (Util.getGocciVersionString() ?? "?.?.?")
        
        if let iid = Persistent.identity_id {
            loginEditField.text = iid
        }
        
        signUpEditField.text = Persistent.user_name ?? Util.randomUsername()
        usernameEditField.text = signUpEditField.text
        
//        UIApplication.sharedApplication().applicationIconBadgeNumber = 7
    }
    
//    [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CompletePopup new]];
//}
//}];
//
//}
//}
//

    func pop(vc: UIViewController) {

        let popup = STPopupController(rootViewController: vc)
        popup.cornerRadius = 4
        popup.transitionStyle = STPopupTransitionStyle.Fade
        STPopupNavigationBar.appearance().barTintColor = UIColor(red: 247.0/255.0, green: 85.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        STPopupNavigationBar.appearance().tintColor = UIColor.whiteColor()
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.Default
        //        STPopupNavigationBar.appearance().titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
        
        
        //
        //            [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil, nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17] } forState:UIControlStateNormal];
        
        
        popup.presentInViewController(self)
    }



    
    @IBAction func explode(sender: AnyObject) {
        
        
        
        print(NSHomeDirectory())
        print(NSFileManager.libraryDirectory())
        return;
        
        let wtf = Persistent.push_notifications_popup_has_been_shown
        print(wtf)
        
        return;
        
        Export.exportVideoToCameraRollForPostID("798")
        Export.exportVideoToCameraRollForPostID("798")
        
        
        return;
        
        
        let url = NSURL(string: "http://test.mp4-movies.gocci.me/2015/12/2015-12-20-16-18-13_1026_movie.mp4")!
        
        
        APILowLevel.cacheFile(url, filename: "55555.mp4") { path in
            print(path)
        }
        
        return;
        
        
        
        
        let ppp = NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!

        

        
        
        
        
        return;
        
        let user_enterd_text = "#Gocci " + Util.randomKanjiStringWithLength(105)
        
        let tp = TwitterPopup(from: self, title: "meh", widthRatio: 80, heightRatio: 35)
        tp.entryText = user_enterd_text
        
        
        let charsLeft = TwitterSharing.videoTweetMessageRemainingCharacters(user_enterd_text)

        print("charsLeft: \(charsLeft)")
        
        tp.pop()
        
        return;
        
        let popup = RequestPushMessagesPopup(from: self, title: "通知の許可", widthRatio: 80, heightRatio: 30)
        popup.pop()
        
        return;
        //let dt = "0000000077777777777777777777777777777777777777777777777700000000"
        
        //RegisterForPushMessagesTask(deviceToken: dt).schedule()
        

        let p = requestPushPopupViewController()
        
        self.pop(p)
        
        
        return;
        
        
        APIHighLevel.simpleLogin {
            if $0 {
                
                APILowLevel.fuelmid_session_cookie = "hfeufhsefuhsefishefiushfishfsuehfsihefsifhsi"
                let pwreq = API3.set.password()
                
                pwreq.parameters.password = "lollol"
                
                pwreq.perform {
                    print("looks good to me :)")
                }
            }
        }
        
        
        return;
        
        
        
        let req = API3.auth.login()
        
        req.parameters.identity_id = "us-east-1:53100da8-8b84-4f15-9bf8-7d6f1bc98f30"
        
        req.perform { (payload) -> () in
            print("Username:    \(payload.username)")
            print("User id:     \(payload.user_id)")
            print("Badge_num:   \(payload.badge_num)")
            print("Profile img: \(payload.profile_img)")
            

            
//            APIClient.setPassword("lollol", handler: { response, code, error in
//                print(response, code)
//                
//                print("=== AFTERFAFTERAFTERAFTER =====================================================")
//                if NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies != nil {
//                    for coo in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
//                        print("\(coo)")
//                    }
//                }
//            })
        }
        
        
//            if code == NetOpResult.NETOP_SUCCESS {
//                self.loginEditField.text = self.signUpEditField.text
//                
//                let uid: String = Persistent.user_id!
//                let iid: String = Persistent.identity_id!
//                let tok: String = Persistent.cognito_token!
//                
//                AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
//                    AWS2.storeSignUpDataInCognito(Persistent.user_name ?? "no username set")
//                    return nil
//                })
//            }
//        }
        
        
        
        
        
        return;
        
        // TODO need translation
        
        
        let alertController = UIAlertController(
            title: "Password setting",
            message: "Please enter your new password",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Please enter your password..."
            textField.secureTextEntry = true
        }
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "And once more for confirmation..."
            textField.secureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
            let pw1 = alertController.textFields?[0].text ?? ""
            let pw2 = alertController.textFields?[1].text ?? ""
            
            if pw1 == "" {
                self.simplePopup("Password setting", "Password 1 was empty", "OK")
            }
            else if pw2 == "" {
                self.simplePopup("Password setting", "Password 2 was empty", "OK")
            }
            else if pw1 != pw2 {
                self.simplePopup("Password setting", "Your passwords did not match", "OK")
            }
            else {
                Util.runOnMainThread {
                    self.simplePopup("Password setting", "Password was set successful :)", "OK")
                }
                Util.runOnMainThread {
                    self.simplePopup("Password setting", "Password setting failed :(", "OK")
                }
            }
            
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)

        return;
        
        
        
        Util.runInBackground {
            
            let pop = UIAlertController.makeOverlayPopup("aaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbb")
            
            pop.addButton("Banane", style: UIAlertActionStyle.Default) { print("Banane clicked") }
            pop.addButton("Apfel", style: UIAlertActionStyle.Cancel) { print("Apfel clicked") }
            pop.addButton("Kirsche", style: UIAlertActionStyle.Destructive) { print("Kirsche clicked") }
            
            pop.overlay()
            
        }
        return;
        
        
        
        VideoPostPreparation.resetPostData()
//        VideoPostPreparation.postData.rest_id = "1"
//        VideoPostPreparation.postData.category_id = "1"
//        VideoPostPreparation.postData.category_string = "1"
//        VideoPostPreparation.postData.value = "1"
//        
//        VideoPostPreparation.postData.memo = Util.randomKanjiStringWithLength(20)
//        VideoPostPreparation.postData.cheer_flag = true
        
        VideoPostPreparation.postData.prepared_restaurant = true
        VideoPostPreparation.postData.rest_name = Util.randomKanjiStringWithLength(20)
        VideoPostPreparation.postData.lat = 138.000000
        VideoPostPreparation.postData.lon = 35.000000
        
        let videoURLn = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!)

        VideoPostPreparation.initiateUploadTaskChain(videoURLn)
        
        return;
        
        
        
        
        

        
        
        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!)
        let videoPATH = NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!
        
        AWSS3VideoUploadTask(filePath: videoPATH, s3FileName: "delete_me_two_sec__per_task_upload.mp4").schedule()
        
        return;
        
        // TODO
        let mp4URL = NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!

        Bridge.scheduleTwitterVideoSharingTask(Util.randomKanjiStringWithLength(10), mp4VideoFilePath: mp4URL)
        
        
        return;
        
        
        
        
        
        //NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "kNetworkReachabilityChangedNotification", object: nil))
        
//        for i in 10...13 {
        let i = 88
            let dummy = DummyPlugTask(msg: "t\(i)", sleepSec: 1, finalState: .DONE)
            dummy.timeNextTry = dummy.timeNextTry + 10000
            dummy.schedule()
//        }
        

        
        return ;
        
        
        
        
        
        
        OverlayWindow.show { (viewController, hideAgain) -> () in
            
//            FBSDKLoginManager().logInWithReadPermissions(nil, fromViewController: viewController) {
//                (result, error) -> Void in
//                hideAgain()
//            }
            TwitterAuthentication.authenticate(currentViewController: viewController,
                and: { (token) -> () in
                    hideAgain()
                }
            )
//
//            let alert = UIAlertController(title: "Hello!", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
//            
//            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.Destructive) { _ in
//                hideAgain()
//                })
//            
//            viewController.presentViewController(alert, animated: true) { () -> Void in }
        }
        
        return;
        
        
//        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!)
//        
//        let sharer = TwitterSharing()
//                        sharer.onSuccess = { print("Post ID: " + $0) }
//                        sharer.onFailure = { print("FUCK: \($0)") }
//        let msg = Util.randomKanjiStringWithLength(100)
//        sharer.tweetVideo(localVideoFileURL: videoURL, message: msg)
//        
//        return;
        
//        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"お知らせ"
//        description:message
//        type:TWMessageBarMessageTypeSuccess
//        duration:4.0];
        
        TWMessageBarManager.sharedInstance().showMessageWithTitle("TTTTTTTT", description: "DDDDDDDDDDDD", type: TWMessageBarMessageType.Success, duration: 5.0)
        
        //Pop.show("Dwdw", "Dwdw")
        return;
        

        
        
//        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
//        let static_key = "4053862111-dU3JpaBk2Gv0b7k9BjAHK2Wcmtk8Twte6A9pZFc"
//        let static_sec = "NfGYuvQrpCJCC0d8JzLmsyWQNtyUkhAJs8vaGsZb9woyq"
//        FHSTwitterEngine.sharedEngine().rawLoginWithToken(static_key, secret: static_sec, userID: "4053862111", username: "XxxxxCarl")
//        
//        let x = FHSTwitterEngine.sharedEngine().verifyCredentials()
//        
//        print(x)
//        return;
        
//        TwitterAuthentication.authenticadedAndReadyToUse { ok in
//            print("res: \(ok)")
//        }
//        
//        return;
        
        //let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!)
//        let thumbURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("thumbnail", ofType: "jpg")!)
//        
////        let expired_token = "CAAJkM7KbcYYBAInz97XHPf166pPnpRcZBkK5D3YsAkxFHQeg5iWSWxa26306ghtMEAtK0VeiZABDBn5dZBNpAjN8S7Ydud53u9Cb6UY9ZCZBFUYXqrvOq1SgTJNFFF6ArNVrZBPwOP5ZAE1q7BgBLv9uCygmpFbFr1NAHVHYwO1XXGnBwHLWDWg8C4jPZAtfJ6GJ0EeiUqcLaAZDZD"
//        let token = "CAAJkM7KbcYYBAAnTZBzCuP1LIdxMdkqgZCkdbNwqZCY8zDOBZAMEJBDUmyYFkWq9IpZBD4iuLagNrEgZC1jIZCiWjAkGjPcBRXKW8QZBL30WiPP2ACeVJg8IdbzoATMZCfjyoerOJXk6wgfQGjgAJrf5LswGXE8pVMcLVeQJUGpDm9kqj4Wxk4DyFzNiGT0zQPBNN8PwWShaO8QZDZD"
////
////
////
//        let sharer = FacebookSharing(fromViewController: self)
//        sharer.onSuccess = { print("Post ID: " + $0) }
//        sharer.onFailure = { print("FUCK: \($0)") }
//        sharer.shareVideoOnFacebook(token, localVideoFileURL: videoURL, description: Util.randomKanjiStringWithLength(100), thumbnail: thumbURL)
//        return;
        
//        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
//        let static_key = "4053862111-dU3JpaBk2Gv0b7k9BjAHK2Wcmtk8Twte6A9pZFc"
//        let static_sec = "NfGYuvQrpCJCC0d8JzLmsyWQNtyUkhAJs8vaGsZb9woyq"
//        FHSTwitterEngine.sharedEngine().rawLoginWithToken(static_key, secret: static_sec, userID: "4053862111", username: "XxxxxCarl")
//        
        

//        TwitterAuthentication.authenticate(currentViewController: self,
//            onSuccess: { (token) -> () in
//                let sharer = TwitterSharing()
//                sharer.onSuccess = { print("Post ID: " + $0) }
//                sharer.onFailure = { print("FUCK: \($0)") }
//                
//                let msg = Util.randomKanjiStringWithLength(115)
//                sharer.tweetVideo(localVideoFileURL: videoURL, message: msg)
//            },
//            onFailure: {
//                print("twitter login failed")
//            }
//        )
    

    
//        let sharer = TwitterSharing(fromViewController: self)
//        sharer.onSuccess = { print("Post ID: " + $0) }
//        sharer.onFailure = { print("FUCK: \($0)") }
//        
//        let msg = Util.randomKanjiStringWithLength(115)
//        sharer.tweetVideo(localVideoFileURL: videoURL, message: msg)
    }
        /*
    
        FacebookAuthentication.enableFullDebugOutput()

        let token = "CAAJkM7KbcYYBAInz97XHPf166pPnpRcZBkK5D3YsAkxFHQeg5iWSWxa26306ghtMEAtK0VeiZABDBn5dZBNpAjN8S7Ydud53u9Cb6UY9ZCZBFUYXqrvOq1SgTJNFFF6ArNVrZBPwOP5ZAE1q7BgBLv9uCygmpFbFr1NAHVHYwO1XXGnBwHLWDWg8C4jPZAtfJ6GJ0EeiUqcLaAZDZD"
        
        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!)
        let rawData = NSData(contentsOfURL: videoURL)!
        print("video length: " + String(rawData.length))
        
//        NSMutableString* resultAsHexBytes = [NSMutableString string];
        
//        [data enumerateByteRangesUsingBlock:^(const void *bytes,
//            NSRange byteRange,
//            BOOL *stop) {
//            
//            //To print raw byte values as hex
//            for (NSUInteger i = 0; i < byteRange.length; ++i) {
//            [resultAsHexBytes appendFormat:@"%02x", ((uint8_t*)bytes)[i]];
//            }
//            
//            }];
        

        var encoded: String = ""
        
        rawData.enumerateByteRangesUsingBlock { (buffer, range, stop) -> Void in

            let bytes = UnsafePointer<UInt8>(buffer)
            
            var i: Int
            for i = range.location; i < range.length; ++i {
                encoded += String(format:"%%%02X", bytes[i])
            }
        }
        
     //   print(encoded)
        
        let params = [
//            "title": Util.randomAlphaNumericStringWithLength(30),
//            "description": Util.randomAlphaNumericStringWithLength(50),
//            "source": encoded.asUTF8Data()
//            "source": ("%7B" + encoded + "%7D")
//            "source": encoded.asUTF8Data()
//            "file_url": "http://btest.api.gocci.me/movie/twosec.mp4"
            "source": "Dwd"
        ]
        
        let params2: NSDictionary = [ "source": encoded]
//        params.setValue(rawData, forKey: "source")[NSObject : AnyObject]
        
        // API reference: https://developers.facebook.com/docs/graph-api/video-uploads
        //            let rq = FBSDKGraphRequest(graphPath: "me/videos", parameters: params, HTTPMethod: "POST")
        let rq = FBSDKGraphRequest(graphPath: "me/videos", parameters: params as [NSObject : AnyObject], tokenString: token, version: "v2.5", HTTPMethod: "POST")
        
        rq.startWithCompletionHandler { (conn, result, error) -> Void in
            if error != nil {
                print(error.localizedDescription)
            }
            else {
                let postid = (result as? [String:String])?["id"]
                print(postid ?? "Posting successful, but no postid")
            }
        }
        
    } 
    
    */
    
     /*
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        let static_key = "4053862111-dU3JpaBk2Gv0b7k9BjAHK2Wcmtk8Twte6A9pZFc"
        let static_sec = "NfGYuvQrpCJCC0d8JzLmsyWQNtyUkhAJs8vaGsZb9woyq"
        FHSTwitterEngine.sharedEngine().rawLoginWithToken(static_key, secret: static_sec, userID: "4053862111", username: "XxxxxCarl")
        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("splash_tmp_sample", ofType: "mp4")!)

        
        
      //          let twit = STTwitterAPI.init(OAuthConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, oauthToken: static_key, oauthTokenSecret: static_sec)
       // twit.postMediaUploadINITWithVideoURL(videoURL, successBlock: {print($0, "  ", $1)}, errorBlock: {print($0)})
        
//        twit.postMediaUploadAPPENDWithVideoURL(videoURL, mediaID: "72398472942", uploadProgressBlock: nil, successBlock: nil, errorBlock: nil)
        
       // let ddd = FHSTwitterEngine.sharedEngine().getDetailsForTweet("664377329167151104")
        
        //NSLog("%@", ddd as! NSDictionary)
        let sharer = TwitterSharing(fromViewController: self)
        sharer.onSuccess = { print("Post ID: " + $0) }
        sharer.onFailure = { print("FUCK: \($0)") }
        
//        let msg = "1234567890" + Util.randomKanjiStringWithLength(130)
        let msg = Util.randomKanjiStringWithLength(115)
//        let msg = "あああ日本語ひらがなカタカナ~!@#$%^&()_+-="
        
        print(msg)
        print("Is this over 140? : " + String(msg.length) + "   Pecentage encode: \(msg.percentEncodingSane().length)")
       // sharer.tweetMessage(msg)
//        sharer.videoUploadINIT(videoURL)
        sharer.tweetVideo(mp4URL: videoURL, message: msg)

    }*/
    /*
        //tweet_video("LOL 日本語ひらがなカタカナ~!@#$%^&*()_+-=\"`[]{};':\",./<>?\\| LOLv", video_media_id: "553656900508606464")
  
    https://api.twitter.com/1.1/statuses/show.json?id=664377329167151104

    
        
        let onLogin: STTwitterAPI->() = { engine in
            
            engine.postMediaUploadThreeStepsWithVideoURL(videoURL, uploadProgressBlock:{print($0, $1, $2)}, successBlock:
                { (mediaID, size, expiresAfter, videoType) -> Void in
               
                    print("mediaID: \(mediaID), size: \(size), expiresAfter: \(expiresAfter), videoType: \(videoType)")
                
                    let sharer = TwitterSharing(fromViewController: self)
                    sharer.onSuccess = { print("Post ID: " + $0) }
                    sharer.onFailure = { print("FUCK: \($0)") }
                    sharer.tweetVideo("http://gocci.me = \(mediaID)", videoMediaID: mediaID)
                },
                errorBlock: {print("ERROR: \($0)")}
            )
        }
        
        onLogin(twit)
        */
        
        
//        twit.verifyCredentialsWithUserSuccessBlock(//nil, errorBlock: nil)
//            { (username, userID) -> Void in
//                print("Succ: \(username)    ID: \(userID)")
//                onLogin(twit)
//            },
//            errorBlock: { print("Twitter fail: \($0)") }
//        )
    
        
    class func afterAppLaunch() {
        
        let fm = NSFileManager.defaultManager()
        
        let task = NSBundle.mainBundle().pathForResource("unfinished_upload_task", ofType: "plist")!
        
        let dest = NSFileManager.documentsDirectory() + "/unfinishedTasks.plist"
        
        let _ = try? fm.removeItemAtPath(dest)
        
        try! fm.copyItemAtPath(task, toPath: dest)
        
        
        let path = NSFileManager.documentsDirectory() + "/user_posted_videos"
        
        if !fm.fileExistsAtPath(path) {
            try! fm.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        
        let videoFile = NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!
        
        let _ = try? fm.copyItemAtPath(videoFile, toPath: path + "/2015-12-11-10-04-26_949.mp4")
        
        
    }
    
    @IBAction func a(sender: AnyObject) {
        
        TaskScheduler.loadTasksFromDisk()
        
//        FacebookAuthentication.enableFullDebugOutput()
//        
//        let mp4url = "http://test.mp4-movies.gocci.me/2015/10/2015-10-06-14-05-25_515_movie.mp4"
//
//        let sharer = FacebookSharing(fromViewController: self)
//        sharer.onSuccess = { print($0) }
//        sharer.onFailure = { print($0) }
//        sharer.onCancel = { print("canceld :(") }
//        
//        sharer.shareVideoOnFacebookIndirect(mp4URL: mp4url, title: "Video", description: Util.generateFakeDeviceID())
//        
//        print("Programmflow continues...")

    }
    
    @IBAction func b(sender: AnyObject) {
        let gurl = "http://inase-inc.jp/gocci/" + "id832948/"
        let imgurl = "http://www.hycclub.org/Resources/Pictures/Events/pancakes_t479.jpg"
        let mp4url = "http://test.mp4-movies.gocci.me/2015/10/2015-10-06-14-05-25_515_movie.mp4"
        
        let sharer = FacebookSharing(fromViewController: self)
        sharer.onSuccess = { print($0) }
        sharer.onFailure = { print($0) }
        sharer.onCancel = { print("canceld :(") }
        
        FacebookAuthentication.enableFullDebugOutput()
        
        sharer.shareGocchiVideoStoryOnFacebookDirect(clickURL: gurl, thumbURL: imgurl, mp4URL: mp4url, title: "Direct", description: "kkkkk")

        print("Programmflow continues...")

    }
    
    @IBAction func c(sender: AnyObject) {
        
        let gurl = "http://inase-inc.jp/gocci/" + "id832948/"
        let imgurl = "http://www.hycclub.org/Resources/Pictures/Events/pancakes_t479.jpg"
        let mp4url = "http://test.mp4-movies.gocci.me/2015/10/2015-10-06-14-05-25_515_movie.mp4"
        
        let sharer = FacebookSharing(fromViewController: self)
        sharer.onSuccess = { print($0) }
        sharer.onFailure = { print($0) }
        sharer.onCancel = { print("canceld :(") }
    
        
        sharer.shareGocchiVideoStoryOnFacebookWithDialog(clickURL: gurl, thumbURL: imgurl, mp4URL: mp4url, title: "Dialog", description: "kkkkk")
        print("Programmflow continues...")

    }
    
    @IBAction func d(sender: AnyObject) {

        let sharer = FacebookSharing(fromViewController: self)
        sharer.onSuccess = { print($0) }
        sharer.onFailure = { print($0) }
        sharer.onCancel = { print("canceld :(") }
        
        
        FacebookAuthentication.enableFullDebugOutput()
        print("Programmflow continues...")
        
    }
    

    
    
    @IBAction func signUpAsUserClicked(sender: AnyObject)
    {
        print("=== SIGNUP AS: " + (signUpEditField.text ?? "empty string^^"))
        
        
        APIHighLevelOBJC.signupAndLogin(signUpEditField.text!, onUsernameAlreadyTaken: {
            print("username already taken :(")
        },
            and:  {             print( $0 ? "Worked :)" : "Login failed :(" )
        })
    
        
    }
    @IBAction func signUpAsUserFakeClicked(sender: AnyObject) {
        print("=== SIGNUP AS: " + (signUpEditField.text ?? "empty string^^"))
        
        APIHighLevelOBJC.signupAndLogin(signUpEditField.text!, onUsernameAlreadyTaken: {
            print("username already taken :(")
            },
            and:  {             print( $0 ? "Worked :)" : "Login failed :(" )
        })
        
    }
    
    @IBAction func loginAsUserClicked(sender: AnyObject)
    {
        
        guard let iid = Persistent.identity_id else
        {
            print("ERROR: iid not set in user defs")
            return
        }
        
        APIHighLevel.simpleLogin{
            print( $0 ? "Worked :)" : "Login failed :(" )
        }
        
    }
    
    
    @IBAction func signUpWithTwitterClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH TWITTER")
        
        TwitterAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("twitter failed")
                return
            }
            
            APIClient.connectWithSNS(TWITTER_PROVIDER_STRING,
                token: token.cognitoFormat(),
                profilePictureURL: TwitterAuthentication.getProfileImageURL() ?? "none")
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    Util.popup("server sice failure, internet failure")
                }
                else if result["code"] as! Int == 200 {
                    print("=== connected with twitter")
                }
                else {
                    Util.popup("something went wrong")
                }
            }
        }
    }
    
    
    @IBAction func loginWithTwitterClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH TWITTER")
        
        TwitterAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("再ログインに失敗しました。Twitterが現在使用できません。大変申し訳ありません。")
                return
            }
            
            AWS2.loginInWithProviderToken(TWITTER_PROVIDER_STRING, token: token.cognitoFormat(),
                onNotRegisterdSNS: {
                    Util.popup("お使いのTwitterアカウントではまだGocciが登録されていません")
                },
                onNotRegisterdIID: {
                    Util.popup("お使いのTwitterアカウントではまだGocciが登録されていません")
                },
                onUnknownError: {
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                },
                onSuccess: {
                    Util.popup("=== Twitter login Success !!")
                }
            )
        }
    }
    
    
    @IBAction func signUpWithFacebookClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH FACEBOOK")
        
        FacebookAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
                return
            }
            
            APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING,
                token: token.cognitoFormat(),
                profilePictureURL: FacebookAuthentication.getProfileImageURL() ?? "none")
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
                else if result["code"] as! Int == 200 {
                    print("=== connected with facebook")
                }
                else {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
            }
        }
    }
    
    
    @IBAction func loginWithFacebookClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH FACEBOOK")
        
        FacebookAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("再ログインに失敗しました。Facebookが現在使用できません。大変申し訳ありません。")
                return
            }
            
            AWS2.loginInWithProviderToken(FACEBOOK_PROVIDER_STRING, token: token.cognitoFormat(),
                onNotRegisterdSNS: {
                    Util.popup("お使いのFacebookアカウントではまだGocciが登録されていません")
                },
                onNotRegisterdIID: {
                    Util.popup("お使いのFacebookアカウントではまだGocciが登録されていません")
                },
                onUnknownError: {
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                },
                onSuccess: {
                    print("=== Facebook login successful")
                }
            )
        }
    }
    
    
    
    
    
    
    @IBAction func twitterTokentoIIDclicked(sender: AnyObject) {
        
        
    }
    
    
    
    @IBAction func facebookTokentoIIDclicked(sender: AnyObject) {
        
        
    }
    
    
    
    
    @IBAction func fastRegFB(sender: AnyObject) {
        let token = "CAACG9jtU8M4BACZB1xFVuAaAXiv0jqoZBO4FdkhUW3HfOSKkZCQQQQ0RRSeePbsOcwT93pmth0ZABiloZAVwDjBfz1NJTMb5j26sUHYzG2m7EfyD7ncemkSBLF1RBPrFggmZAevjBTA3JPkhYnZBJIS5WQzbTDZBjfOKA7FIDtFSBI3Xd4oI7fnmDFFSiotc0TQVGqjGBs1tkAZDZD"
        
        
        
        APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING, token: token, profilePictureURL: "none", handler:
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 || !(result is NSDictionary) || result["code"] == nil{
                    print("SNS_CONNECTION_UNKNOWN_FAILURE " + String(error ?? "nil"))
                }
                    //print("SNS_CONNECTION_UNKNOWN_FAILURE, result %@", result)
                    
                    //            else if result["code"] as! String == "401" {
                    //                print("SNS_CONNECTION_UN_AUTH")
                    //            }
                else if result["code"] as! Int == 200 {
                    print("SNS_CONNECTION_SUCCESS, result %@", result)
                }
                else {
                    print("SNS_CONNECTION_UNKNOWN_FAILURE, result %@", result)
                }
        })
    }
    
    @IBAction func fastLoginFB(sender: AnyObject) {
        
        // let token = "CAACG9jtU8M4BANN5ZAGOhjWoZAscCjrvdt1855kVH874OJ4LK9vGJs7ZBCSIFSinncGQUg4OjU7lh08weqTUOxAQj4w5tNwJQp6OPstojaFVUeVDGjHw7GmIy4oIcZADHv49w19Gx6TMnae7bxcFry8gJ4aXzRsZA2m5Tkn2sIAlkLLwC58R6XtBZBXVLPaRa6kH0mCaYrNgZDZD"
        
        //AWS2.addSNSProvider(FACEBOOK_PROVIDER_STRING, token: token)
        
        
        //        let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: token)
        //        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        //        print("!!! GOT IID: \(iid)")
        //        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        //        NetOp.loginWithIID(iid) { (res, emsg) -> Void in
        //            print("login Result: \(res)")
        //        }
    }
    
    
    
    
    
    
    
    @IBAction func loginWithPasswordClicked(sender: AnyObject) {
//        NetOp.loginWithUsername(usernameEditField.text, password: passwordEditField.text) { (res, msg) -> Void in
//            print(res)
//            //print(msg)
//        }
    }
    
    
    @IBAction func setPasswordClicked(sender: AnyObject) {
        APIClient.setPassword(passwordEditField.text) { (result, code, error) -> Void in
            
            print("code: ", code)
        }
    }
    
    
    @IBAction func deleteUserDefsClicked(sender: AnyObject)
    {
        print("=== DELETE userdefs")
        Util.wipeUserDataFromDevice(false)
        
        signUpEditField.text = Util.randomUsername()
        loginEditField.text = ""
    }
    
    
    @IBAction func clearAllCookiesClikced(sender: AnyObject) {
        Util.deleteAllCookies()
    }
    
    
    @IBAction func gotoTimelinkeClicked(sender: AnyObject)
    {
        self.ignoreCommonSenseAndGoToViewControllerWithName("timeLineEntry")
    }
    
    @IBAction func gotoTutorialClicked(sender: AnyObject)
    {
        self.ignoreCommonSenseAndGoToViewControllerWithName("Tutorial")
    }
    
    @IBAction func normalStartClicked(sender: AnyObject)
    {
        self.ignoreCommonSenseAndGoToInitialController()
    }
    
    @IBAction func gotoSettingsClicked(sender: AnyObject) {
        self.ignoreCommonSenseAndGoToViewControllerWithName("jumpSettingsTableViewController")
    }
    

}






