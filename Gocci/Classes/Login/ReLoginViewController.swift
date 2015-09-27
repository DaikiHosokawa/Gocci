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
            switch result {
                case SNSUtil.LoginResult.SNS_LOGIN_SUCCESS:
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                case SNSUtil.LoginResult.SNS_LOGIN_UNKNOWN_FAILURE:
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                case SNSUtil.LoginResult.SNS_LOGIN_CANCELED:
                    break
                case SNSUtil.LoginResult.SNS_USER_NOT_REGISTERD:
                    Util.popup("お使いのFacebookアカウントではまだGocciが登録されていません")
                case SNSUtil.LoginResult.SNS_PROVIDER_FAIL:
                    Util.popup("再ログインに失敗しました。Facebookが現在使用できません。大変申し訳ありません。")
            }
        }
    }
    
    @IBAction func twitterLoginClicked(sender: AnyObject) {
        SNSUtil.singelton.loginWithTwitter(self) { (result) -> Void in
            switch result {
                case SNSUtil.LoginResult.SNS_LOGIN_SUCCESS:
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                case SNSUtil.LoginResult.SNS_LOGIN_UNKNOWN_FAILURE:
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                case SNSUtil.LoginResult.SNS_LOGIN_CANCELED:
                    break
                case SNSUtil.LoginResult.SNS_USER_NOT_REGISTERD:
                    Util.popup("お使いのTwitterアカウントではまだGocciが登録されていません")
                case SNSUtil.LoginResult.SNS_PROVIDER_FAIL:
                    Util.popup("再ログインに失敗しました。Twitterが現在使用できません。大変申し訳ありません。")

            }
        }
    }

}