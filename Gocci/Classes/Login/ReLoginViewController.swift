//
//  ReLoginViewController.swift
//  Gocci
//
//  Created by Ma Wa on 24.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class ReLoginViewController : UIViewController {
    
    @IBOutlet weak var usernameEditFiled: UITextField!
    
    @IBOutlet weak var passwordEditField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginClicked(sender: AnyObject) {
        print("login clicked")
        print("username: \(usernameEditFiled.text)")
        print("password: \(passwordEditField.text)")
        
        Util.popup(usernameEditFiled.text ?? "nil")
    }

    @IBAction func facebookLoginClicked(sender: AnyObject) {
        SNSUtil.singelton.loginWithFacebook() { (result) -> Void in
            // TODO msg to the user
            switch result {
            case SNSUtil.LoginResult.SNS_LOGIN_SUCCESS:

                
                break
            case SNSUtil.LoginResult.SNS_LOGIN_UNKNOWN_FAILURE:
                break
            case SNSUtil.LoginResult.SNS_LOGIN_CANCELED:
                break
            case SNSUtil.LoginResult.SNS_USER_NOT_REGISTERD:
                break
            case SNSUtil.LoginResult.SNS_PROVIDER_FAIL:
                break
            }
            print("=== RESUTLT: \(result)")
        }
    }
    
    @IBAction func twitterLoginClicked(sender: AnyObject) {
        print("twit")
        SNSUtil.singelton.loginWithTwitter(self) { (result) -> Void in
            // TODO msg to the user
            switch result {
                case SNSUtil.LoginResult.SNS_LOGIN_SUCCESS:
                    twitterLoginSuccessful = true
                    break
                case SNSUtil.LoginResult.SNS_LOGIN_UNKNOWN_FAILURE:
                    break
                case SNSUtil.LoginResult.SNS_LOGIN_CANCELED:
                    break
                case SNSUtil.LoginResult.SNS_USER_NOT_REGISTERD:
                    break
                case SNSUtil.LoginResult.SNS_PROVIDER_FAIL:
                    break
            }
            print("=== RESUTLT: \(result)")
        }
    }

}