//
//  SettingsTableViewController.swift
//  Gocci
//
//  Created by Markus Wanke on 2015/10/26.
//  Copyright © 2015年 Massara. All rights reserved.
//

import UIKit

// TODO TRANSLATION


class SettingsTableViewController: UITableViewController
{
    
    let sectionList = ["アカウント", "ソーシャルネットワーク", "お知らせ", "サポート"]
    
    var sectionMapping: [[(setCell:(UITableViewCell->())?, action:(UITableViewCell->())? )]] = []

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        sectionMapping = [
            
            // アカウント ===================================================================
            [
                (
                    {
                        $0.textLabel?.text = "パスワードを設定する"
                        $0.detailTextLabel?.text = Persistent.password_was_set_by_the_user ? "" : "set an account password"
                        $0.detailTextLabel?.textColor = Persistent.password_was_set_by_the_user ? UIColor.greenColor() : UIColor.redColor()
                    },
                    handlePassword
                ),
            ],
            // ソーシャルネットワーク =========================================================
            [
                (
                    {
                        let isCon = Persistent.user_is_connected_via_facebook
                        $0.textLabel?.text = "Facebook"
                        $0.detailTextLabel?.text = isCon ? "connected!" : "not connected :("
                        $0.detailTextLabel?.textColor = isCon ? UIColor.greenColor() : UIColor.redColor()
                    },
                    handleFacebook
                ),
                (
                    {
                        let isCon = Persistent.user_is_connected_via_twitter
                        $0.textLabel?.text = "Twitter"
                        $0.detailTextLabel?.text = isCon ? "connected!" : "not connected :("
                        $0.detailTextLabel?.textColor = isCon ? UIColor.greenColor() : UIColor.redColor()
                    },
                    handleTwitter
                ),
                //( { $0.textLabel?.text = "Google+"; return }, nil),
                //( { $0.textLabel?.text = "Line"; return }, nil),
            ],
            // お知らせ =====================================================================
            [
                (
                    {
                        $0.textLabel?.text = "通知を設定する"
                        $0.detailTextLabel?.text = "TODO"
                    },
                    nil
                )
            ],
            // サポート =====================================================================             
            [
                (
                    {
                        $0.textLabel?.text = "アドバイスを送る"
                        $0.detailTextLabel?.text = "DONE"
                    },
                    { _ in
                        let popup = FeedbackPopup(from: self, title: "通知を設定する", widthRatio: 92, heightRatio: 50)
   
                        popup.pop()
                    }
                ),
                (
                    { $0.textLabel?.text = "利用規約" },
                    { _ in
                        let popup = WebViewPopup(from: self, title: "利用規約", widthRatio: 92, heightRatio: 80)
                        popup.url = INASE_RULES_URL
                        popup.pop()
                    }
                ),
                (
                    { $0.textLabel?.text = "プライバシーポリシー" },
                    { _ in
                        let popup = WebViewPopup(from: self, title: "プライバシーポリシー", widthRatio: 92, heightRatio: 80)
                        popup.url = INASE_PRIVACY_URL
                        popup.pop()
                    }
                ),
                (
                    { $0.textLabel?.text = "バージョン" ; $0.detailTextLabel?.text = "iOS Gocci v" + (Util.getGocciVersionString() ?? "?.?") },
                    nil
                ),
            ],
        ]

    }
    
    func handlePassword(cell: UITableViewCell)
    {
        let alertController = UIAlertController(
            title: "Password setting",
            message: "Please enter your new password",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Please enter your password..."
            textField.secureTextEntry = true
        }
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "And once more for confirmation..."
            textField.secureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
            let pw1 = alertController.textFields?[0].text ?? ""
            let pw2 = alertController.textFields?[1].text ?? ""
            
            if pw1 == "" {
                self.simplePopup("Password setting", "Password 1 was empty", "OK")
            }
            else if pw2 == "" {
                self.simplePopup("Password setting", "Password 2 was empty", "OK")
            }
            else if pw1 != pw2 {
                self.simplePopup("Password setting", "Your passwords did not match", "OK")
            }
            else {
                let succ = {
                    Util.runOnMainThread {
                        cell.detailTextLabel?.text = "Password was set!"
                        cell.detailTextLabel?.textColor = UIColor.greenColor()
                        Persistent.password_was_set_by_the_user = true
                        
                        self.simplePopup("Password setting", "Password was set successful :)", "OK")
                    }
                }
                let damn = {
                    Util.runOnMainThread {
                        self.simplePopup("Password setting", "Password setting failed :(", "OK")
                    }
                }
                
                APIClient.setPassword(pw1) { (result, code, error) -> Void in
                    
                    if error != nil {
                        damn()
                        return
                    }
                    
                    if code >= 200 && code < 300 {
                        if let result = result as? [String: AnyObject] {
                            if let rescode = result["code"] as? Int {
                                if rescode == 200 {
                                    succ()
                                    return
                                }
                            }
                        }
                    }
                    
                    damn()
                }
            }
            
            })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func handleTwitter(cell: UITableViewCell)
    {
        if Persistent.user_is_connected_via_twitter {
            let popup = ConfirmationPopover(from: self, position: cell.frame, widthRatio: 75, heightRatio: 30)
            popup.confirmationText = "Do you really want to disconnect your account from Twitter?"
            popup.onConfirm = {
                // TODO disconnect call
                Persistent.user_is_connected_via_twitter = false
                cell.detailTextLabel?.text = "not connected :("
                cell.detailTextLabel?.textColor = UIColor.redColor()
            }
            popup.pop()
            return
        }
        
        let onSuccess = {
            Persistent.user_is_connected_via_twitter = true
            cell.detailTextLabel?.text = "connected!"
            cell.detailTextLabel?.textColor = UIColor.greenColor()
        }

        TwitterAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
                return
            }
            
            APIClient.connectWithSNS(TWITTER_PROVIDER_STRING,
                token: token.cognitoFormat(),
                profilePictureURL: TwitterAuthentication.getProfileImageURL() ?? "none")
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
                else if result["code"] as! Int == 200 {
                    onSuccess()
                }
                else {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
            }
        }
    }
    
    
    func handleFacebook(cell: UITableViewCell)
    {
        if Persistent.user_is_connected_via_facebook {
            let popup = ConfirmationPopover(from: self, position: cell.frame, widthRatio: 75, heightRatio: 30)
            popup.confirmationText = "Do you really want to disconnect your account from Facebook?"
            popup.onConfirm = {
                // TODO disconnect call
                Persistent.user_is_connected_via_facebook = false
                cell.detailTextLabel?.text = "not connected :("
                cell.detailTextLabel?.textColor = UIColor.redColor()
            }
            popup.pop()
            return
        }
        
        let onSuccess = {
            Persistent.user_is_connected_via_facebook = true
            cell.detailTextLabel?.text = "connected!"
            cell.detailTextLabel?.textColor = UIColor.greenColor()
        }
        
        FacebookAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
                return
            }
            
            APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING,
                token: token.cognitoFormat(),
                profilePictureURL: FacebookAuthentication.getProfileImageURL() ?? "none")
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
                else if result["code"] as! Int == 200 {
                    onSuccess()
                }
                else {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
            }
        }
    }
    

    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.sectionMapping.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionList[section] ?? "fail"
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sectionMapping[section].count ?? 0
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        sectionMapping[indexPath.section][indexPath.row].action?(tableView.cellForRowAtIndexPath(indexPath)!)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        cell.detailTextLabel?.textColor = UIColor.blueColor()
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.fontWithSize(14)
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        sectionMapping[indexPath.section][indexPath.row].setCell?(cell)
        return cell
    }

}






