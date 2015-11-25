//
//  ReLoginViewController.swift
//  Gocci
//
//  Created by Ma Wa on 24.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class ReLoginViewController : UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var usernameEditFiled: UITextField!
    
    @IBOutlet weak var passwordEditField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }

    
    func hideKeyboard(sender: UITapGestureRecognizer) {
        usernameEditFiled.resignFirstResponder()
        passwordEditField.resignFirstResponder()
    }

    @IBAction func loginClicked(sender: AnyObject) {

        guard let un = usernameEditFiled.text where !un.isEmpty else {
            // TRANSLATE
            Util.popup("Please enter a valid username")
            return
        }
        
        guard let pw = passwordEditField.text where !pw.isEmpty else {
            // TRANSLATE
            Util.popup("Please enter a password")
            return
        }
        
        NetOp.loginWithUsername(un, password: passwordEditField.text) { (result, emsg) -> Void in
            
            switch result {
                case .NETOP_SUCCESS:

                    AWS2.connectToBackEndWithUserDefData().continueWithBlock({ (task) -> AnyObject! in
                        let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                        self.presentViewController(tutorialViewController, animated: true, completion: nil)
                        return nil
                    })

                case .NETOP_USERNAME_PASSWORD_WRONG:
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                default:
                    // TRANSLATE
                    Util.popup("Unknown Error")
            }
        }
    }

    @IBAction func facebookLoginClicked(sender: AnyObject) {
        SNSUtil.loginWithFacebook(currentViewController: self) { (result) -> Void in
            print("Result: " + String(result))
            switch result {
                case .SNS_LOGIN_SUCCESS:
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                case .SNS_LOGIN_UNKNOWN_FAILURE:
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                case .SNS_LOGIN_CANCELED:
                    break
                case .SNS_USER_NOT_REGISTERD:
                    Util.popup("お使いのFacebookアカウントではまだGocciが登録されていません")
                case .SNS_PROVIDER_FAIL:
                    Util.popup("再ログインに失敗しました。Facebookが現在使用できません。大変申し訳ありません。")
            }
        }
    }
    
    @IBAction func twitterLoginClicked(sender: AnyObject) {
        SNSUtil.loginWithTwitter(self) { (result) -> Void in
            print("Result: " + String(result))
            switch result {
                case .SNS_LOGIN_SUCCESS:
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                case .SNS_LOGIN_UNKNOWN_FAILURE:
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                case .SNS_LOGIN_CANCELED:
                    break
                case .SNS_USER_NOT_REGISTERD:
                    Util.popup("お使いのTwitterアカウントではまだGocciが登録されていません")
                case .SNS_PROVIDER_FAIL:
                    Util.popup("再ログインに失敗しました。Twitterが現在使用できません。大変申し訳ありません。")

            }
        }
    }
}