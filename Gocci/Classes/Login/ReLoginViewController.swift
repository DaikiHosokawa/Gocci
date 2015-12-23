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
        passwordEditField.secureTextEntry = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }

    
    func hideKeyboard(sender: UITapGestureRecognizer) {
        usernameEditFiled.resignFirstResponder()
        passwordEditField.resignFirstResponder()
    }

    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginClicked(sender: AnyObject) {

        guard let un = usernameEditFiled.text where !un.isEmpty else {
            // TRANSLATE
            Util.popup("ユーザー名を入力してください")
            return
        }
        
        guard let pw = passwordEditField.text where !pw.isEmpty else {
            // TRANSLATE
            Util.popup("パスワードを入力してください")
            return
        }
        

        let req = API3.auth.password()
        
        req.parameters.username = un
        req.parameters.password = pw
        
        // TODO better text
        req.on_ERROR_PASSWORD_NOT_REGISTERD { _, _ in
            Util.popup("入力されたアカウントではまだパスワード設定をしておりません")
        }
        
        // TODO better text
        req.on_ERROR_PASSWORD_WRONG { _, _ in
            Util.popup("入力されたパスワードが間違っております")
        }
        
        // TODO better text
        req.on_ERROR_USERNAME_NOT_REGISTERD { _, _ in
            Util.popup("入力されたユーザー名は登録されておりません")
        }
        
        req.on(.ERROR_PARAMETER_PASSWORD_MALFORMED) { code, msg in
            self.simplePopup("失敗しました。", "パスワードは6文字以上、25文字以下必要です。", "OK")
        }
        
        req.perform { (payload) -> () in
            Persistent.identity_id = payload.identity_id
            
            APIHighLevel.simpleLogin {
                if $0 {
                    let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
                    self.presentViewController(tutorialViewController, animated: true, completion: nil)
                }
                else {
                    Util.popup("再ログインに失敗しました。アカウント情報を再度お確かめください。")
                }
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