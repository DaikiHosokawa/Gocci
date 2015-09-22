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
    
    
    override func viewDidLoad() {
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
        
            print("=== Twitter name: \(FHSTwitterEngine.sharedEngine().authenticatedUsername)")
            print("=== Twitter auth: \(FHSTwitterEngine.sharedEngine().authenticatedID)")
            
            print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat)")
            
            APIClient.connectWithSNS(TWITTER_PROVIDER_STRING,
                token: FHSTwitterEngine.sharedEngine().cognitoFormat(),
                profilePictureURL: "none",
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
                
                print("=== Twitter name: \(FHSTwitterEngine.sharedEngine().authenticatedUsername)")
                print("=== Twitter auth: \(FHSTwitterEngine.sharedEngine().authenticatedID)")
                
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

    }
    @IBAction func loginWithFacebookClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH FACEBOOK")

    }
}






