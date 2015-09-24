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
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var signUpEditField: UITextField!
    @IBOutlet weak var loginEditField: UITextField!
    
    @IBOutlet weak var tokenEditField: UITextField!
    //strong var facebookLogin: FBSDKLoginManager
    
    
    override func viewDidLoad() {
        // TODO once token
        print("============ DEBUG MODE ACTIVATED ==============")
        super.viewDidLoad()
        
        topLabel.text = topLabel.text ?? "" + ".1"
        loginEditField.text = NSUserDefaults.standardUserDefaults().stringForKey("identity_id") ?? "identity_id not set in user defs"
        signUpEditField.text = NSUserDefaults.standardUserDefaults().stringForKey("username") ?? Util.randomUsername()
        
        
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        //FHSTwitterEngine.sharedEngine().setDelegate(self)
        FHSTwitterEngine.sharedEngine().loadAccessToken()
        
        FBSDKSettings.setAppID(FACEBOOK_APP_ID)

        
    }

    @IBAction func deleteUserDefsClicked(sender: AnyObject)
    {
        print("=== DELETE userdefs")
        Util.removeAccountSpecificDataFromUserDefaults()
        
        loginEditField.text = Util.randomUsername()
        signUpEditField.text = loginEditField.text
    }

    @IBAction func signUpAsUserClicked(sender: AnyObject)
    {
        print("=== SIGNUP AS: " + (signUpEditField.text ?? "empty string^^"))
        NetOp.registerUsername(signUpEditField.text)
        {
            (code, emsg) -> Void in
            
            print("NetOpCode: \(code)  " + (emsg ?? ""))
            if code == NetOpResult.NETOP_SUCCESS {
                self.loginEditField.text = self.signUpEditField.text
            }
        }
        
    }

    @IBAction func loginAsUserClicked(sender: AnyObject)
    {
        guard let iid = NSUserDefaults.standardUserDefaults().stringForKey("identity_id") else
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
            }
        }
    }
    

    @IBAction func signUpWithTwitterClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH TWITTER")
        
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
        {
            (success) -> Void in
            
            if !success {
                print("=== Twitter login failed")
                return
            }
        
            let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
            let picurl: String = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal) as! String
            print("=== Twitter name:   \(username)")
            print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
            print("=== Twitter avatar: \(picurl)")
            print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
            
            NSUserDefaults.standardUserDefaults().setValue(picurl, forKey: "avatarLink")

            
            APIClient.connectWithSNS(TWITTER_PROVIDER_STRING,
                token: FHSTwitterEngine.sharedEngine().cognitoFormat(),
                profilePictureURL: picurl,
                handler:
                {
                    (result, code, error) -> Void in
                    print(result)
                })
        })

        self.presentViewController(vc, animated: true, completion: nil)

    }
        
        
    @IBAction func loginWithTwitterClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH TWITTER")
        
        SNSUtil.loginWithTwitter(self) { (succ) -> Void in
            print("0000000000000000000000000000000 \(succ)")
        }
        
//        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
//            {
//                (success) -> Void in
//                
//                if !success {
//                    print("=== Twitter login failed")
//                    return
//                }
//                
//                let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
//                let pic = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal)
//                print("=== Twitter name:   \(username)")
//                print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
//                print("=== Twitter avatar: \(pic)")
//                print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
//                
//                NetOp.loginWithSNS(TWITTER_PROVIDER_STRING, SNSToken: FHSTwitterEngine.sharedEngine().cognitoFormat(), andThen:
//                {
//                    (result, emsg) -> Void in
//                    print(result)
//                })
//                
//        })
//        
//        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    
    
    @IBAction func signUpWithFacebookClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH FACEBOOK")

        FBSDKLoginManager().logInWithReadPermissions(nil)
        {
            (result, error) -> Void in
            
            if error != nil {
                // TODO msg to the user
                print("error")
                return
            }
            else if result.isCancelled {
                return
            }

            print("=== Facebook login success")
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            let fbid = FBSDKAccessToken.currentAccessToken().userID
            
            print("FBID: \(fbid)")
            
            let picurl = "http://graph.facebook.com/\(fbid)/picture?width=640&height=640"
            NSUserDefaults.standardUserDefaults().setValue(picurl, forKey: "avatarLink")
            print("################################################################################")
            print("Set avatar link intern to \(picurl)")
            print("################################################################################")
            
            APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING, token: token, profilePictureURL: picurl, handler:
            {
                (result, code, error) -> Void in
                // TODO msg to the user on fail
                //             if (!error && [result[@"code"] integerValue] == 200){
                print(result)
            })
        }
    }
    
    
    @IBAction func loginWithFacebookClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH FACEBOOK")
        
        FBSDKLoginManager().logInWithReadPermissions(nil)
        {
            (result, error) -> Void in
            
            if error != nil {
                print("error")
                return
            }
            else if result.isCancelled {
                print("cancelld")
                return
            }
        
            print("=== Facebook login success")
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            print("=== token: \(token)")
            
            NetOp.loginWithSNS(FACEBOOK_PROVIDER_STRING, SNSToken: token, andThen:
                {
                    (result, emsg) -> Void in
                    print(result)
            })
        }
    }
    
    
    
    
    
    
    @IBAction func twitterTokentoIIDclicked(sender: AnyObject) {
        
//        APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING, token: "CAACG9jtU8M4BANq1hm78P2RiXNPBNvCfjMTHPqWtBh76WeHiTdZCDeyhtx0CVwgZC344wQMcqG1fytz55zTPzN1EhF8yZAaw0wv3lfAiLOC7ykmwHqZAgARW7WoEBbZBmne2M1s7P6YEwyE9HCAnWVZCgJze6z41eFMDPB4cCHU3ZCOYwl5ZADEG2o6INWuHZAbV2bSZAlx4lqWQZDZD", profilePictureURL: "none", handler:
//            {
//                (result, code, error) -> Void in
//                // TODO msg to the user on fail
//                //             if (!error && [result[@"code"] integerValue] == 200){
//                print(result)
//        })
    }
    
    
    
    @IBAction func facebookTokentoIIDclicked(sender: AnyObject) {
        
//        tokenEditField.text = "CAACG9jtU8M4BALWeCfRrAipUG68Chej01KZCufhwqV77wfwZAaHCDZC5WWsfUSfPR8d7Vh2dOAXYtXXgnxfN64TyBf3vYvzD8FhGAF0bdN1OPSYYfVmQS8PHJxtXAwzd8QPDlaAkGFR1uPvyJoL1tD9i9occtMZAnpCp3fWAZC0J1SK8F9r8bgZCEj5hBHLf1nAXR8lz8d3QZDZD"

        if let token = tokenEditField.text where token != "" {
            let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: token)
            
            NetOp.loginWithIID(iid, andThen: { (result, msg) -> Void in
                
                if result != NetOpResult.NETOP_SUCCESS {
                    print("=== FAILED: \(msg)")
                    return
                }
                print("=== Looks good :)")
            })
        }
        else {
            FBSDKLoginManager().logInWithReadPermissions(nil)
            {
                (result, error) -> Void in
                
                if error == nil && !result.isCancelled {
                    print("=== Request IID for FBID: \(FBSDKAccessToken.currentAccessToken().userID)")
                    
                    let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: FBSDKAccessToken.currentAccessToken().tokenString)
                    
                    NetOp.loginWithIID(iid, andThen: { (result, msg) -> Void in
                        
                        if result != NetOpResult.NETOP_SUCCESS {
                            print("=== FAILED: \(msg)")
                            return
                        }
                        print("=== Looks good :)")
                    })
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    @IBAction func gotoTimelinkeClicked(sender: AnyObject)
    {
        let stobo = UIStoryboard(name: Util.getInchString(), bundle: nil)
        let vc = stobo.instantiateViewControllerWithIdentifier("timeLineEntry")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func gotoTutorialClicked(sender: AnyObject)
    {
        let stobo = UIStoryboard(name: Util.getInchString(), bundle: nil)
        let vc = stobo.instantiateViewControllerWithIdentifier("Tutorial")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func normalStartClicked(sender: AnyObject)
    {
        let stobo = UIStoryboard(name: Util.getInchString(), bundle: nil)
        let vc = stobo.instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
}






