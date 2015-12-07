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
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                }
            )
        }
    }
    
    @IBAction func twitterLoginClicked(sender: AnyObject) {
        
        
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
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                }
            )
        }
        
    }
}