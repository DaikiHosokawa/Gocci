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
        
        topLabel.text = topLabel.text! + ".4"
        
        if let iid = Util.getUserDefString("identity_id") {
            loginEditField.text = iid
        }
        signUpEditField.text = NSUserDefaults.standardUserDefaults().stringForKey("username") ?? Util.randomUsername()
        
        
        usernameEditField.text = signUpEditField.text

        
    }
    
    @IBAction func explode(sender: AnyObject) {
        
        //AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose

        
        print("WE AIM FOR: us-east-1:e28d3906-240b-4f8b-bd9e-d456f967a6ca")
        
        let token = "CAACG9jtU8M4BALGTI8ADZB3p4xssI2sxms5fnQbKBEztmMsrB8CuUOsKE0p4wNgJ6DGUkWrGYrkyjZAvDb4m5ZA4jx0RozMCuvTsm8cKp7QAMwI5F2Hxm2vkB4OvxOgaaeRr0V0zWlkizTI5jsebWoZBbQGaMv3UuaOZCHha2nKE44BebKL7xciFVHjV49DlSnh7n8oGYQAZDZD"
        
      //  let l = [FACEBOOK_PROVIDER_STRING: token];
        
        
        AWSManager.getIIDforSNSLogin(FACEBOOK_PROVIDER_STRING, token: token).continueWithBlock { (task) -> AnyObject! in
            if task.result == nil {
                print("Invalid login token. Expired or account is not linked to Gocci")
            }
            else {
                print("================================ We got an IID \(task.result)")
                
                
                NetOp.loginWithSNS(task.result as! String, andThen: { (code, emsg) -> Void in
                    
                    let uid: String = Util.getUserDefString("user_id")!
                    let iid: String = Util.getUserDefString("identity_id")!
                    let tok: String = Util.getUserDefString("token")!
                    
                    if code == NetOpResult.NETOP_SUCCESS {
                        AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
                            AWS2.storeSNSTokenInDataSet(FACEBOOK_PROVIDER_STRING, token: token)
                            return nil
                        })
                    }
                    else if code == NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD {
                        print("user not registerded :(")
                    }
                    else {
                        print("WTF? no internet?")
                    }

                })
            }

            return nil
        }
        
        
//        let tmpip = AWSEnhancedCognitoIdentityProvider(regionType: AWSRegionType.USEast1, identityId: nil, identityPoolId: COGNITO_POOL_ID, logins: nil)
        
        //let tmpip = GocciDevAuthIdentityProvider(region: AWSRegionType.USEast1, poolID: COGNITO_POOL_ID)
        
        
//        let tmpip = SNSIIDRetrieverIdentityProvider(region: AWSRegionType.USEast1, poolID: COGNITO_POOL_ID, iid: "fuck", logins: nil)
//        
//        tmpip.refresh().continueWithBlock { (task) -> AnyObject! in
//            tmpip.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
//                print("WE GOT BEF: \(tmpip.identityId)")
//                
//                tmpip.logins = l
//                
//                tmpip.refresh().continueWithBlock { (task) -> AnyObject! in
//                    tmpip.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
//                        print("WE GOT AFT: \(tmpip.identityId)")
//                        return nil
//                    })
//                }
//                return nil
//            })
//        }
        
//        tmpip.refresh().continueWithBlock { (task) -> AnyObject! in
//            tmpip.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
//                print("WE GOT BEF: \(tmpip.identityId)")
//                
//                tmpip.connectWithSNSProvider(FACEBOOK_PROVIDER_STRING, token: token).continueWithBlock { (task) -> AnyObject! in
//                    tmpip.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
//                        print("WE GOT AFT: \(tmpip.identityId)")
//                        return nil
//                    })
//                }
//                return nil
//            })
//        }
        
        
//        let iid = "us-east-1:e28d3906-240b-4f8b-bd9e-d456f967a6ca"
//
//        NetOp.loginWithIID(iid)
//        {
//            (code, emsg) -> Void in
//            
//            print("NetOpCode: \(code)  " + (emsg ?? ""))
//            if code == NetOpResult.NETOP_SUCCESS {
//                self.loginEditField.text = self.signUpEditField.text
//                let uid: String = Util.getUserDefString("user_id")!
// //               let iid: String = Util.getUserDefString("identity_id")!
//                let tok: String = Util.getUserDefString("token")!
//                
////                tmpip.connectWithBackEnd(iid, userID: uid, token: tok).continueWithBlock { (task) -> AnyObject! in
////                    tmpip.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
////                        print("WE GOT AFT: \(tmpip.identityId)")
////                        print("LOGINS: \(tmpip.logins)")
////                        return nil
////                    })
////                }
//
//                let a = AWSGocciIdentityProvider(regionType: AWSRegionType.USEast1, identityPoolID: COGNITO_POOL_ID, identityID: iid, userID: uid, logins: [GOCCI_DEV_AUTH_PROVIDER_STRING: uid], providerName: GOCCI_DEV_AUTH_PROVIDER_STRING, initToken: tok)
//                a.refresh().continueWithBlock({ (task) -> AnyObject! in
//                    a.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
//                        print("WE GOT AFT: \(tmpip.identityId)")
//                        print("LOGINS: \(tmpip.logins)")
//                        return nil
//                    })
//                    return nil
//                })
//
//            }
//        }
//        
    }



    @IBAction func signUpAsUserClicked(sender: AnyObject)
    {
        //AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose

        
        print("=== SIGNUP AS: " + (signUpEditField.text ?? "empty string^^"))
        
        NetOp.registerUsername(signUpEditField.text) {
            (code, emsg) -> Void in
            
            print("NetOpCode: \(code)  " + (emsg ?? ""))
            
            if code == NetOpResult.NETOP_SUCCESS {
                self.loginEditField.text = self.signUpEditField.text
                
                let uid: String = Util.getUserDefString("user_id")!
                let iid: String = Util.getUserDefString("identity_id")!
                let tok: String = Util.getUserDefString("token")!
                
                AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
                    AWS2.storeSignUpDataInCognito(Util.getUserDefString("username") ?? "no username set")
                    return nil
                })
                //AWS2.printIID()
                
//                AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock(){
//                    (task) -> AnyObject! in
//                    AWS2.storeSignUpDataInCognito(Util.getUserDefString("username") ?? "noname")
//                    return nil
//                }
//

//                
//                let ip = AWSGocciIdentityProvider(regionType: AWSRegionType.USEast1, identityPoolID: COGNITO_POOL_ID, identityID: iid, userID: uid, logins: [GOCCI_DEV_AUTH_PROVIDER_STRING: uid], providerName: GOCCI_DEV_AUTH_PROVIDER_STRING, initToken: tok)
//                
//                ip
//                
//                
//                ip.refresh().waitUntilFinished()
//                print("hhhhhhhhhhhdwdww: \(ip.identityId)")
            }
        }
        
    }

    @IBAction func loginAsUserClicked(sender: AnyObject)
    {
        //NSUserDefaults.standardUserDefaults().setObject("us-east-1:5403c205-8a2b-474e-b1c7-1a94663d9115", forKey: "identity_id")
        
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

//        if let token = tokenEditField.text where token != "" {
//            let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: token)
//            
//            NetOp.loginWithIID(iid, andThen: { (result, msg) -> Void in
//                
//                if result != NetOpResult.NETOP_SUCCESS {
//                    print("=== FAILED: \(msg)")
//                    return
//                }
//                print("=== Looks good :)")
//            })
//        }
//        else {
//            FBSDKLoginManager().logInWithReadPermissions(nil)
//            {
//                (result, error) -> Void in
//                
//                if error == nil && !result.isCancelled {
//                    print("=== Request IID for FBID: \(FBSDKAccessToken.currentAccessToken().userID)")
//                    
//                    let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: FBSDKAccessToken.currentAccessToken().tokenString)
//                    
//                    NetOp.loginWithIID(iid, andThen: { (result, msg) -> Void in
//                        
//                        if result != NetOpResult.NETOP_SUCCESS {
//                            print("=== FAILED: \(msg)")
//                            return
//                        }
//                        print("=== Looks good :)")
//                    })
//                }
//            }
//        }
    }
    
    
    
    
    @IBAction func fastRegFB(sender: AnyObject) {
        let token = "CAACG9jtU8M4BANBYEhMXF0G2TbBEZCbmN1nhQTKibb93PuBw53LAa4FZAc9PcuWLE3a898SvX832Exm4TmzjPrquV9YQ1Yp4WYwWZAq6ptPMlDZBhuk9D7MeGxNIZADbx8ZCZAQtHJCmmlUWnfkgQlZANWkxaE8L3DOIAxkGpTLTZAztQY707lmusZC6boR3lqd5JTanvmZAFTM0wZDZD"
        
    
        
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
        
        signUpEditField.text = Util.randomUsername()
        loginEditField.text = ""
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






