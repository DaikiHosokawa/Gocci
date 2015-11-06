//
//  File.swift
//  Gocci
//
//  Created by Markus Wanke on 21.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit


class DebugViewController : UIViewController {
    
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
        
        if let iid = Util.getUserDefString("iid") {
            loginEditField.text = iid
        }
        signUpEditField.text = NSUserDefaults.standardUserDefaults().stringForKey("username") ?? Util.randomUsername()
        
        
        usernameEditField.text = signUpEditField.text
    }
    
    /*
    NSLog(@"req: %@\n\n", request.allHTTPHeaderFields);
    //    NSLog(@"body: %@", request.HTTPBody);
    NSLog(@"body %@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    
    

    
    id parsed = removeNull([NSJSONSerialization JSONObjectWithData:(NSData *)retobj options:NSJSONReadingMutableContainers error:nil]);
    
    NSError *error = [self checkError:parsed];
    
    if (error) {
    return error;
    }
    
    return nil; // eventually return the parsed response
    }
    */
    

    

//    func tweet(mediaID: String) -> NSError? {
//        let baseURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
//        
//        let params = [
//            "media_ids": mediaID, //"601491637433475073"]
//            "status": "kyoukoso :( " + Util.randomUsername()]
//        
//        return FHSTwitterEngine.sharedEngine().sendPOSTRequestForURL(baseURL, andParams: params)
//    }
    
    @IBAction func explode(sender: AnyObject) {
        
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)

    
        let static_key = "4053862111-dU3JpaBk2Gv0b7k9BjAHK2Wcmtk8Twte6A9pZFc"
        let static_sec = "NfGYuvQrpCJCC0d8JzLmsyWQNtyUkhAJs8vaGsZb9woyq"
        
        
        FHSTwitterEngine.sharedEngine().rawLoginWithToken(static_key, secret: static_sec, userID: "4053862111", username: "XxxxxCarl")
        
        let sharer = TwitterSharing(fromViewController: self)
//        sharer.tweetVideo(Util.generateFakeDeviceID(), videoMediaID: "bejfejesfsefs")
        sharer.onSuccess = { print("Post ID: " + $0) }
        sharer.tweetMessage(Util.generateFakeDeviceID())
        
    }
        /*
        tweet_video("LOL 日本語ひらがなカタカナ~!@#$%^&*()_+-=\"`[]{};':\",./<>?\\| LOLv", video_media_id: "553656900508606464")
  
        return
        return
     
        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("short_vid", ofType: "mp4")!)
        
        let onLogin: STTwitterAPI->() = { engine in
            
            engine.postMediaUploadThreeStepsWithVideoURL(videoURL, uploadProgressBlock:{print($0, $1, $2)}, successBlock:
                { (mediaID, size, expiresAfter, videoType) -> Void in
               
                    print("mediaID: \(mediaID), size: \(size), expiresAfter: \(expiresAfter), videoType: \(videoType)")
                
                    self.tweet_video("http://gocci.me = \(mediaID)", video_media_id: mediaID)
                },
                errorBlock: {print("ERROR: \($0)")}
            )
        }
        
        
        let twit = STTwitterAPI.init(OAuthConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, oauthToken: static_key, oauthTokenSecret: static_sec)
        
        
        twit.verifyCredentialsWithUserSuccessBlock(//nil, errorBlock: nil)
            { (username, userID) -> Void in
                print("Succ: \(username)    ID: \(userID)")
                onLogin(twit)
            },
            errorBlock: { print("Twitter fail: \($0)") }
        )
        
    }
        
        */
        
        
//        let error = FHSTwitterEngine.sharedEngine().postTweet("raw login hhh " + Util.randomUsername())
//        let error = tweet("4367825638453953")
//        
//        if let error = error {
//            print("Zannen: \(error)")
//        }
//        else {
//            print("looks good to me")
//        }
        
        //tweet_video("measssaggggggge", video_media_id: "87234695237852")
        
//    }
        /*
        TwitterAuthentication.authenticateWithTwitter(self) {
            (suc, key, sec) in
            
            print(key, "   ", sec)
            let error = FHSTwitterEngine.sharedEngine().postTweet("raw login hhh " + Util.randomUsername())
            
            if let error = error {
                print("Zannen: \(error)")
            }
            else {
                print("loks good to me")
            }
            //
            
        }
        return
        
        
        let videoURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("short_vid", ofType: "mp4")!)
        
        let onLogin: STTwitterAPI->() = { engine in
            
            engine.postMediaUploadThreeStepsWithVideoURL(videoURL, uploadProgressBlock:{print($0, $1, $2)}, successBlock: { (mediaID, size, expiresAfter, videoType) -> Void in
                print("mediaID: \(mediaID), size: \(size), expiresAfter: \(expiresAfter), videoType: \(videoType)")
                
                
                self.tweet_video("tilltheendddw", video_media_id: mediaID)
//                    let error = self.tweet(mediaID)
//                    
//                    if let error = error {
//                        print("Zannen: \(error)")
//                    }
//                    else {
//                        print("loks good to me")
//                    }
                
                    return
                },
                errorBlock: {print("ERROR: \($0)")}
            )
        }
        
        
        let twit = STTwitterAPI.init(OAuthConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, oauthToken: static_key, oauthTokenSecret: static_sec)
        
        
        twit.verifyCredentialsWithUserSuccessBlock(//nil, errorBlock: nil)
            { (username, userID) -> Void in
                print("Succ: \(username)    ID: \(userID)")
                onLogin(twit)
            },
            errorBlock: { print("Twitter fail: \($0)") }
            )
                
        
                
                
                
                
                
                
        return
        
        
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        //FHSTwitterEngine.sharedEngine().setDelegate(self)
        FHSTwitterEngine.sharedEngine().loadAccessToken()


        TwitterAuthentication.authenticateWithTwitter(self) {
            (suc, key, sec) in
            
            if(!suc) {
                print("login failed")
            }
            else {
                print("key: \(key), sec: \(sec)")
                
                let twit = STTwitterAPI.init(OAuthConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, oauthToken: key, oauthTokenSecret: sec)
                
                twit.verifyCredentialsWithUserSuccessBlock(//nil, errorBlock: nil)
                    { (username, userID) -> Void in
                        print("Succ: \(username)    ID: \(userID)")
                    },
                    errorBlock:
                    { (err) -> Void in
                        print("Twitter fail: \(err)")
                        
                })
                
            }
        }
    
    }
*/
    
    @IBAction func a(sender: AnyObject) {
        
        let mp4url = "http://test.mp4-movies.gocci.me/2015/10/2015-10-06-14-05-25_515_movie.mp4"

        let sharer = FacebookSharing(fromViewController: self)
        sharer.onSuccess = { print($0) }
        sharer.onFailure = { print($0) }
        sharer.onCancel = { print("canceld :(") }
        
        sharer.shareVideoOnFacebook(mp4URL: mp4url, title: "Video", description: Util.generateFakeDeviceID())
        
        print("Programmflow continues...")

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
        
        if real_register_id != "" {
            Util.setUserDefString("register_id", value: real_register_id)
        }
        
        NetOp.registerUsername(signUpEditField.text) {
            (code, emsg) -> Void in
            
            print("NetOpCode: \(code)  " + (emsg ?? ""))
            
            if code == NetOpResult.NETOP_SUCCESS {
                self.loginEditField.text = self.signUpEditField.text
                
                let uid: String = Util.getUserDefString("user_id")!
                let iid: String = Util.getUserDefString("iid")!
                let tok: String = Util.getUserDefString("token")!
                
                AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
                    AWS2.storeSignUpDataInCognito(Util.getUserDefString("username") ?? "no username set")
                    return nil
                })
            }
        }
        
    }
    @IBAction func signUpAsUserFakeClicked(sender: AnyObject) {
        print("=== SIGNUP AS: " + (signUpEditField.text ?? "empty string^^"))
        
        if real_register_id == "" {
            real_register_id = Util.getRegisterID()
        }
        Util.setUserDefString("register_id", value: Util.generateFakeDeviceID())
        
        NetOp.registerUsername(signUpEditField.text) {
            (code, emsg) -> Void in
            
            print("NetOpCode: \(code)  " + (emsg ?? ""))
            
            if code == NetOpResult.NETOP_SUCCESS {
                self.loginEditField.text = self.signUpEditField.text
                
                let uid: String = Util.getUserDefString("user_id")!
                let iid: String = Util.getUserDefString("iid")!
                let tok: String = Util.getUserDefString("token")!
                
                AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
                    AWS2.storeSignUpDataInCognito(Util.getUserDefString("username") ?? "no username set")
                    return nil
                })
            }
        }
    }
    
    @IBAction func loginAsUserClicked(sender: AnyObject)
    {
        //NSUserDefaults.standardUserDefaults().setObject("us-east-1:5403c205-8a2b-474e-b1c7-1a94663d9115", forKey: "iid")
        
        guard let iid = NSUserDefaults.standardUserDefaults().stringForKey("iid") else
        {
            print("ERROR: iid not set in user defs")
            return
        }
        
        print("=== LOGIN AS: " + iid)
        
        NetOp.loginWithIID(iid)
            {
                (code, emsg) -> Void in
                
                print("NetOpCode: \(code)  " + (emsg ?? ""))
                if code == NetOpResult.NETOP_SUCCESS {
                    self.loginEditField.text = self.signUpEditField.text
                    let uid: String = Util.getUserDefString("user_id")!
                    let iid: String = Util.getUserDefString("iid")!
                    let tok: String = Util.getUserDefString("token")!
                    
                    AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
                        AWS2.storeTimeInLoginDataSet()
                        return nil
                    })
                    
                    
                    //AWS2.connectWithBackend(iid, userID: uid, token: tok)
                }
        }
    }
    
    
    @IBAction func signUpWithTwitterClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH TWITTER")
        
        SNSUtil.connectWithTwitter(currentViewController: self) { (result) -> Void in
            print("=== Result: \(result)")
        }
    }
    
    
    @IBAction func loginWithTwitterClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH TWITTER")
        
        SNSUtil.loginWithTwitter(self) { (result) -> Void in
            print("=== Result: \(result)")
        }
    }
    
    
    @IBAction func signUpWithFacebookClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH FACEBOOK")
        
        SNSUtil.connectWithFacebook(currentViewController: self) { (result) -> Void in
            print("=== Result: \(result)")
        }
    }
    
    
    @IBAction func loginWithFacebookClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH FACEBOOK")
        
        SNSUtil.loginWithFacebook(currentViewController: self) { (result) -> Void in
            print("=== Result: \(result)")
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
        NetOp.loginWithUsername(usernameEditField.text, password: passwordEditField.text) { (res, msg) -> Void in
            print(res)
            //print(msg)
        }
    }
    
    
    @IBAction func setPasswordClicked(sender: AnyObject) {
        APIClient.setPassword(passwordEditField.text) { (result, code, error) -> Void in
            
            print("code: ", code)
        }
    }
    
    
    @IBAction func deleteUserDefsClicked(sender: AnyObject)
    {
        print("=== DELETE userdefs")
        Util.removeAccountSpecificDataFromUserDefaults()
        Persistent.resetGocciToInitialState()
        
        signUpEditField.text = Util.randomUsername()
        loginEditField.text = ""
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






