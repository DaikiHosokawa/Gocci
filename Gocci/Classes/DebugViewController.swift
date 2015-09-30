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
    
    
    @IBOutlet weak var usernameEditField: UITextField!
    @IBOutlet weak var passwordEditField: UITextField!
    
    override func viewDidLoad() {
        // TODO once token
        print("============ DEBUG MODE ACTIVATED ==============")
        super.viewDidLoad()
        
        topLabel.text = topLabel.text ?? "" + ".1"
        loginEditField.text = NSUserDefaults.standardUserDefaults().stringForKey("identity_id") ?? "identity_id not set in user defs"
        signUpEditField.text = NSUserDefaults.standardUserDefaults().stringForKey("username") ?? Util.randomUsername()
        
        
        usernameEditField.text = signUpEditField.text

        
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
        
        loginEditField.text = Util.randomUsername()
        signUpEditField.text = loginEditField.text
    }

    @IBAction func signUpAsUserClicked(sender: AnyObject)
    {
        print("=== SIGNUP AS: " + (signUpEditField.text ?? "empty string^^"))
        
        NetOp.registerUsername(signUpEditField.text) {
            (code, emsg) -> Void in
            
            print("NetOpCode: \(code)  " + (emsg ?? ""))
            
            if code == NetOpResult.NETOP_SUCCESS {
                self.loginEditField.text = self.signUpEditField.text
                
                let uid: String = Util.getUserDefString("user_id")!
                let iid: String = Util.getUserDefString("identity_id")!
                let tok: String = Util.getUserDefString("token")!
                
                AWS2.connectWithBackend(iid, userID: uid, token: tok)
                AWS2.printIID()
                AWS2.storeSignUpDataInCognito(Util.getUserDefString("username") ?? "noname")
                
            }
        }
        
    }

    @IBAction func loginAsUserClicked(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setObject("us-east-1:5403c205-8a2b-474e-b1c7-1a94663d9115", forKey: "identity_id")
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
                let uid: String = Util.getUserDefString("user_id")!
                let iid: String = Util.getUserDefString("identity_id")!
                let tok: String = Util.getUserDefString("token")!
                
                AWS2.connectWithBackend(iid, userID: uid, token: tok)
                AWS2.printIID()
            }
        }
    }
    

    @IBAction func signUpWithTwitterClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH TWITTER")

        SNSUtil.singelton.connectWithTwitter(self) { (result) -> Void in
            print("=== Result: \(result)")
        }
    }
        
        
    @IBAction func loginWithTwitterClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH TWITTER")
        
        SNSUtil.singelton.loginWithTwitter(self) { (result) -> Void in
            print("=== Result: \(result)")
        }
    }
    
    
    @IBAction func signUpWithFacebookClicked(sender: AnyObject)
    {
        print("=== SIGNUP WITH FACEBOOK")
        
        SNSUtil.singelton.connectWithFacebook(currentViewController: self) { (result) -> Void in
            print("=== Result: \(result)")
        }
    }
    
    
    @IBAction func loginWithFacebookClicked(sender: AnyObject)
    {
        print("=== LOGIN WITH FACEBOOK")
        
        Util.thisKillsTheFacebook()
        
        SNSUtil.singelton.loginWithFacebook(currentViewController: self) { (result) -> Void in
            print("=== Result: \(result)")
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
    
    
    
    
    @IBAction func fastRegFB(sender: AnyObject) {
        let token = "CAACG9jtU8M4BANN5ZAGOhjWoZAscCjrvdt1855kVH874OJ4LK9vGJs7ZBCSIFSinncGQUg4OjU7lh08weqTUOxAQj4w5tNwJQp6OPstojaFVUeVDGjHw7GmIy4oIcZADHv49w19Gx6TMnae7bxcFry8gJ4aXzRsZA2m5Tkn2sIAlkLLwC58R6XtBZBXVLPaRa6kH0mCaYrNgZDZD"
        
    
        
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
        
        let token = "CAACG9jtU8M4BANN5ZAGOhjWoZAscCjrvdt1855kVH874OJ4LK9vGJs7ZBCSIFSinncGQUg4OjU7lh08weqTUOxAQj4w5tNwJQp6OPstojaFVUeVDGjHw7GmIy4oIcZADHv49w19Gx6TMnae7bxcFry8gJ4aXzRsZA2m5Tkn2sIAlkLLwC58R6XtBZBXVLPaRa6kH0mCaYrNgZDZD"
        
        AWS2.addSNSProvider(FACEBOOK_PROVIDER_STRING, token: token)
        
        
//        let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: token)
//        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//        print("!!! GOT IID: \(iid)")
//        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//        NetOp.loginWithIID(iid) { (res, emsg) -> Void in
//            print("login Result: \(res)")
//        }
    }
    
    @IBAction func explode(sender: AnyObject) {
        

        
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






