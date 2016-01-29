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

import Realm
import RealmSwift

// Define your models like regular Swift classes
class Dog: Object {
    dynamic var name = ""
    dynamic var age = 0
}
class Person: Object {
    dynamic var name = ""
    dynamic var picture: NSData? = nil // optionals supported
    let dogs = List<Dog>()
}




class BGTesterThread: DummyPlugTask {
    override func run(finished: State -> ()) {
        
            print("sleeping...")
            Util.sleep(3)
            print("WOKE...")
            
            let req = API4.get.follow()
            
            req.parameters.user_id = Persistent.user_id
            
            
            
            
            req.onAnyAPIError {
                print("BGTesterThread: ERROR")
                self.run(finished)
            }
            
            req.perform { payload in
                print("BGTesterThread: SUCCESS network connection. \(payload)")
                self.run(finished)
            }
    }
}



//
//  FacebookTasks.swift
//  Gocci
//
//  Created by Markus Wanke on 13.01.16.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class FacebookVideoSharingTaskXXX: PersistentBaseTask {
    let timelineMessage: String
    let relativeFilePath: String
    
    init(timelineMessage: String, relativeFilePath: String) {
        self.timelineMessage = timelineMessage
        self.relativeFilePath = relativeFilePath
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        
        self.timelineMessage = dict["timelineMessage"] as? String ?? "__PLACEHOLDER_4283492084092__"
        self.relativeFilePath = dict["relativeFilePath"] as? String ?? ""
        super.init(dict: dict)
        if timelineMessage == "__PLACEHOLDER_4283492084092__" || relativeFilePath == "" { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["timelineMessage"] = timelineMessage
        dict["relativeFilePath"] = relativeFilePath
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? FacebookVideoSharingTaskXXX {
            return task.timelineMessage == timelineMessage && task.relativeFilePath == relativeFilePath
        }
        return false
    }
    
    override func run(finished: State->()) {
        
        sep("PERFORM: FacebookVideoSharingTask")
        log("timelineMessage = \(timelineMessage)")
        log("relativeFilePath = \(relativeFilePath)")
        
        let fullFilePathURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("meat", ofType: "mp4")!)
        
        while true {
        
        print("sleeping...")
        Util.sleep(3)
        run(finished)
        }
        
        guard NSFileManager.fileExistsAtURL(fullFilePathURL) else {
            err("File \(fullFilePathURL) does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        
        let sharer = FacebookSharing()
        sharer.onSuccess = {
            //Toast.成功("Video sharing", "Video was successfully posted on Facebook.")
            self.sep("SUCCESS: FacebookVideoSharingTask")
            self.log("Facebook posting sucessful: Post ID: \($0)")

            print("ONCE AGAIN ^^")
            self.run(finished)
        }
        sharer.onFailure = {
            self.err("Facebook posting failed because of \($0)")
            
            switch($0) {
            case .ERROR_VIDEO_FILE_IO:
                finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
                
            case .ERROR_NETWORK:
                //Toast.情報("Facebook video sharing", "Network appears to be unstable. Will retry later")
                finished(PersistentBaseTask.State.FAILED_NETWORK)
                
            case .ERROR_FACEBOOK_API:
                // TODO more punishmend. set retry count or extend waiting time
                finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
                
            case .ERROR_AUTHENTICATION:
                
                OverlayWindow.oneTimeViewController { viewController in
                    
                    FacebookAuthentication.authenticateWithPublishRights(currentViewController: viewController) { token in
                        finished( token == nil ? .FAILED_IRRECOVERABLE : .FAILED_RECOVERABLE)
                    }
                }
            }
        }
        sharer.shareVideoOnFacebook(fullFilePathURL, description: timelineMessage, thumbnail: nil)
            
    }
    
    override var description: String {
        return super.description + " timelineMessage: \(timelineMessage), MP4File: \(relativeFilePath)"
    }
    
}




































class DebugViewController : UIViewController {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var signUpEditField: UITextField!
    @IBOutlet weak var loginEditField: UITextField!
    @IBOutlet weak var tokenEditField: UITextField!
    @IBOutlet weak var usernameEditField: UITextField!
    @IBOutlet weak var passwordEditField: UITextField!
    
    
//    override func viewWillAppear(animated: Bool) {
//        Lo.error("OverlayViewController: viewDidLoad")
//        super.viewWillAppear(animated)
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        Lo.error("OverlayViewController: viewDidAppear")
//        super.viewDidAppear(animated)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        Lo.error("OverlayViewController: viewWillDisappear")
//        super.viewWillDisappear(animated)
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        Lo.error("OverlayViewController: viewDidDisappear")
//        super.viewDidDisappear(animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subLabel.text = "Greatest Work - Gocci v" + (Util.getGocciVersionString() ?? "?.?.?")
        
        if let iid = Persistent.identity_id {
            loginEditField.text = iid
        }
        
        signUpEditField.text = Persistent.user_name ?? Util.randomUsername()
        usernameEditField.text = signUpEditField.text
        
        print("Realm: open " + Realm.Configuration.defaultConfiguration.path!)
        
    }
    

    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print(error)
    }
    /// LIVE SERVER MY IID: us-east-1:38c3e159-09fa-44d7-929f-22d2a6c0a004
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results ?? "nil")
    }
    
    @IBAction func explode(sender: AnyObject) {
        
        
        let fullFilePathURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("meat", ofType: "mp4")!)
        
        let sharer = FacebookSharing()
        sharer.onSuccess = { postid in
            print("UPLOAD SUCCESS, POST ID: \(postid)")
        }
        sharer.onFailure = {
            print("Facebook posting failed because of \($0)")
            
        }
        sharer.shareVideoOnFacebook(fullFilePathURL, description: Util.randomAlphaNumericStringWithLength(22), thumbnail: nil)

        return;
        
        
        
        let f: ()->() = {
            var i: Int = 0
            while true {
                print("I: \(++i)")
                Util.sleep(1)
            }
        }
        
        let que = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        
        let task = Util.createTaskThatWillEvenRunIfTheAppIsPutInBackground("bla", queue: que, task: f, expirationHandler: {
            print(" !!!!!!!!!!!!   BG TASK WAS KILLED BY THE OS!!")
        })
        
        task()
        
        print("gone)")
        return;
        
        
        
        
        
        BGTesterThread(msg: "wdw", sleepSec: 1, finalState: .DONE).schedule()
        
//        FacebookVideoSharingTaskXXX(timelineMessage: Util.randomAlphaNumericStringWithLength(20), relativeFilePath: "egal").schedule()
        
        return;
        
        
        Persistent.identity_id = "us-east-1:4ce38d92-677d-4e30-807a-f9a6465e47c9"
        
        
        self.ignoreCommonSenseAndGoToViewControllerWithName("jumpHeatMapViewController")
        return;
//        
//        
//        
//        
//        let realm = try! Realm()
//        
//        
//        let req = API4.get.user()
//        req.parameters.user_id = Persistent.user_id
//        
//        req.perform { payload in
//            
//            try! realm.write {
//                for post in payload.posts {
//                    let tmp = UserPost(usersPostPayload: post)
//                    realm.add(tmp, update: true)
//                }
//            }
//            
//            self.ignoreCommonSenseAndGoToViewControllerWithName("jumpHeatMapViewController")
//        }
//        

        
        
        
        return;
        
        
        let url = NSURL(string: NSBundle.mainBundle().pathForResource("meat", ofType: "mp4")!)

        Export.saveMovieAtPathToCameraRoll(url!) { assetURL in
            print("RESULT: ")
            print(assetURL ?? "nil")
            
            if let assetURL = assetURL {
                
                let encodedURL = assetURL.absoluteString.percentEncodingSane()
                
                let instaURLraw = "instagram://library?AssetPath=\(encodedURL)&InstagramCaption=JESUS"
                
                
                UIApplication.sharedApplication().openURL(NSURL(string: instaURLraw)!)
            }
        }
        
        
        
        return;
        
        
//        let req = API4.get.heatmap()
//        
//        req.perform { payload in
//            
//            let realm = try! Realm()
//            
//            try! realm.write {
//                
//                for rest in payload.rests {
//                    let tmp = HeatMapRestaurant.create(fromPayload: rest)
//                    realm.add(tmp, update: true)
//                }
//            }
//            
//            self.ignoreCommonSenseAndGoToViewControllerWithName("HeatMapViewController")
//        }
//        
//        
        
    }
    
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
        
        let sharer = FacebookStorySharing(fromViewController: self)
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
        
        let sharer = FacebookStorySharing(fromViewController: self)
        sharer.onSuccess = { print($0) }
        sharer.onFailure = { print($0) }
        sharer.onCancel = { print("canceld :(") }
    
        
        sharer.shareGocchiVideoStoryOnFacebookWithDialog(clickURL: gurl, thumbURL: imgurl, mp4URL: mp4url, title: "Dialog", description: "kkkkk")
        print("Programmflow continues...")

    }
    
    @IBAction func d(sender: AnyObject) {

        let sharer = FacebookStorySharing(fromViewController: self)
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






