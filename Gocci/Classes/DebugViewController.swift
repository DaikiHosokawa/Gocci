//
//  File.swift
//  Gocci
//
//  Created by Ma Wa on 21.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit
//import Util



class DebugViewController : UIViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var signUpEditField: UITextField!
    @IBOutlet weak var loginEditField: UITextField!
    
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
        
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
            {
                (success) -> Void in
                
                if !success {
                    print("=== Twitter login failed")
                    return
                }
                
                let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
                let pic = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal)
                print("=== Twitter name:   \(username)")
                print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
                print("=== Twitter avatar: \(pic)")
                print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
                
                NetOp.loginWithSNS(TWITTER_PROVIDER_STRING, SNSToken: FHSTwitterEngine.sharedEngine().cognitoFormat(), andThen:
                {
                    (result, emsg) -> Void in
                    print(result)
                })
                
        })
        
        self.presentViewController(vc, animated: true, completion: nil)

    }
    @IBAction func signUpWithFacebookClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH FACEBOOK")
        
        FBSDKSettings.setAppID(FACEBOOK_APP_ID)
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(nil)
        {
            (result, error) -> Void in
            
            if error != nil {
                print("error")
            }
            else if result.isCancelled {
                print("cancelld")
            }
            else {
                print("=== Facebook login success")
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                print("=== token: \(token)")
            
            
                APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING,
                    token: token,
                    profilePictureURL: "none",
                    handler:
                {
                    (result, code, error) -> Void in
                    //             if (!error && [result[@"code"] integerValue] == 200){

                    print(result)
                })
            }
        }
    }
    
    
    @IBAction func loginWithFacebookClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH FACEBOOK")
        
        FBSDKSettings.setAppID(FACEBOOK_APP_ID)
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(nil)
            {
                (result, error) -> Void in
                
                if error != nil {
                    print("error")
                }
                else if result.isCancelled {
                    print("cancelld")
                }
                else {
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






