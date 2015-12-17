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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

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
                        $0.detailTextLabel?.text = Persistent.password_was_set_by_the_user ? "設定済み" : "設定する"
                        $0.detailTextLabel?.textColor = Persistent.password_was_set_by_the_user ? UIColor.blackColor() : UIColor.blackColor()
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
                        $0.detailTextLabel?.text = isCon ? "接続済み" : "未接続"
                        $0.detailTextLabel?.textColor = isCon ? UIColor.blackColor() : UIColor.blackColor()
                    },
                    handleFacebook
                ),
                (
                    {
                        let isCon = Persistent.user_is_connected_via_twitter
                        $0.textLabel?.text = "Twitter"
                        $0.detailTextLabel?.text = isCon ? "接続済み" : "未接続"
                        $0.detailTextLabel?.textColor = isCon ? UIColor.blackColor() : UIColor.blackColor()
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
                        let wants = Permission.userHasGrantedPushNotificationPermission() && Persistent.registerd_device_token != nil
                        $0.detailTextLabel?.text = wants ? "recieving" : "blocked"
                        $0.detailTextLabel?.textColor = wants ? UIColor.greenColor() : UIColor.redColor()
                        
                    },
                    handlePushNotification
                )
            ],
            // サポート =====================================================================             
            [
                (
                    {
                        $0.textLabel?.text = "アドバイスを送る"
                        //$0.detailTextLabel?.text = "送る"
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
                    { $0.textLabel?.text = "バージョン" ; $0.detailTextLabel?.text = (Util.getGocciVersionString() ?? "?.?") },
                    nil
                ),
                (
                    { $0.textLabel?.text = "Gocciを初期状態にリセットする" ; $0.textLabel?.textColor = UIColor.blackColor() },
                    handleAccountReset
                ),
            ],
        ]

    }
    
    
    
    func handlePushNotification(cell: UITableViewCell)
    {
        // don't think there is something better we can do here
        cell.detailTextLabel?.text = ""
        
        if !Permission.userHasGrantedPushNotificationPermission() {
            if Persistent.push_notifications_popup_has_been_shown {
                Permission.showTheHolyPopupForPushNotificationsOrTheSettingsScreen()
                
                // User should see the popup when he returnn, not while the settings screen opens
                Util.sleep(1)
            }
            else {
                // Show the holy popup
                Permission.theHolyPopup { wants in
                    // We pretend the task has succeeded for now...
                    cell.detailTextLabel?.text = wants ? "recieving" : "blocked"
                    cell.detailTextLabel?.textColor = wants ? UIColor.greenColor() : UIColor.redColor()
                }
                return
            }
        }
        
        // at this point it is not clear if the user
        
        let disconnect = {
            
            // we don't really care if this worked or not
            API3.unset.device().perform {
                Persistent.registerd_device_token = ""
            }
            
            cell.detailTextLabel?.text = "blocked"
            cell.detailTextLabel?.textColor = UIColor.redColor()
        }
        
        let connect = {
            if !Permission.userHasGrantedPushNotificationPermission() {
                self.simplePopup("Permission not granted", "Please click again to visit the settings to grant the push messages permission", "OK")
            }
            
            // this will reschedule an permission check. The popup will never be shown here
            Permission.theHolyPopup { wants in
                // We pretend the task has succeeded for now...
                cell.detailTextLabel?.text = wants ? "recieving" : "blocked"
                cell.detailTextLabel?.textColor = wants ? UIColor.greenColor() : UIColor.redColor()
            }
        }
        
        self.simpleConfirmationPopup("Confirmation", "Do you want to recieve push notifications about Likes and Messages to your videos?",
            confirmButton: (text: "Yes, send me push messages", cb: connect),
            cancelButton:  (text: "No, thank you", cb: disconnect))
        
    }
    
    func handlePassword(cell: UITableViewCell)
    {
        let alertController = UIAlertController(
            title: "パスワード設定",
            message: "新しいパスワードを入力してください",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "あなたのパスワード"
            textField.secureTextEntry = true
        }
        
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "もう一度..."
            textField.secureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
            let pw1 = alertController.textFields?[0].text ?? ""
            let pw2 = alertController.textFields?[1].text ?? ""
            
            if pw1 == "" {
                self.simplePopup("パスワード設定", "1つめが空です", "OK")
            }
            else if pw2 == "" {
                self.simplePopup("パスワード設定", "2つめが空です", "OK")
            }
            else if pw1 != pw2 {
                self.simplePopup("パスワード設定", "1つめと2つめが違います", "OK")
            }
            else {
                let req = API3.set.password()
                
                req.parameters.password = pw1
                
                req.onAnyAPIError {
                    self.simplePopup("パスワード設定", "失敗しました。パスワードは6文字以上、25文字以下必要です。", "OK")
                }
                
                req.perform {
                    cell.detailTextLabel?.text = "設定する"
                    cell.detailTextLabel?.textColor = UIColor.blackColor()
                    Persistent.password_was_set_by_the_user = true
                    
                    self.simplePopup("パスワード設定", "成功しました", "OK")
                }
                
            }
        })
    
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    func handleTwitter(cell: UITableViewCell)
    {
        
        let connect = {
            TwitterAuthentication.authenticate(currentViewController: self) { token in
                
                guard let token = token else {
                    Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
                    return
                }
                
                let req = API3.set.sns_link()
                
                req.parameters.provider = TWITTER_PROVIDER_STRING
                req.parameters.sns_token = token.cognitoFormat()
                
                req.onAnyAPIError {
                    self.simplePopup("ERROR", "連携に失敗しました。アカウント情報を再度お確かめください。", "OK")
                }
                
                req.perform {
                    Persistent.user_is_connected_via_twitter = true
                    cell.detailTextLabel?.text = "接続済み"
                    cell.detailTextLabel?.textColor = UIColor.blackColor()
                }
            }
        }
        
        let disconnect = {
            TwitterAuthentication.authenticate(currentViewController: self) { token in
                
                guard let token = token else {
                    Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
                    return
                }
                
                let req = API3.unset.sns_link()
                
                req.parameters.provider = TWITTER_PROVIDER_STRING
                req.parameters.sns_token = token.cognitoFormat()
                
                req.onAnyAPIError {
                    self.simplePopup("ERROR", "連携に失敗しました。アカウント情報を再度お確かめください。", "OK")
                }
                
                req.perform {
                    Persistent.user_is_connected_via_twitter = false
                    cell.detailTextLabel?.text = "未接続"
                    cell.detailTextLabel?.textColor = UIColor.blackColor()
                }
            }
        }
        
        if !Persistent.user_is_connected_via_twitter {
            connect()
        }
        else {
            self.simpleConfirmationPopup("Confirmation", "Do you really want to disconnect your account from Twitter?",
                confirmButton: (text: "Disconnect", cb: disconnect),
                cancelButton:  (text: "Cancel", cb: nil))
        }
    }
    
    func handleFacebook(cell: UITableViewCell)
    {
        
        let connect = {
            FacebookAuthentication.authenticate(currentViewController: self) { token in
                
                guard let token = token else {
                    Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
                    return
                }
                
                let req = API3.set.sns_link()
                
                req.parameters.provider = FACEBOOK_PROVIDER_STRING
                req.parameters.sns_token = token.cognitoFormat()
                
                req.onAnyAPIError {
                    self.simplePopup("ERROR", "連携に失敗しました。アカウント情報を再度お確かめください。", "OK")
                }
                
                req.perform {
                    Persistent.user_is_connected_via_facebook = true
                    cell.detailTextLabel?.text = "接続済み"
                    cell.detailTextLabel?.textColor = UIColor.blackColor()
                }
            }
        }
        
        let disconnect = {
            FacebookAuthentication.authenticate(currentViewController: self) { token in
                
                guard let token = token else {
                    Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
                    return
                }
                
                let req = API3.unset.sns_link()
                
                req.parameters.provider = FACEBOOK_PROVIDER_STRING
                req.parameters.sns_token = token.cognitoFormat()
                
                req.onAnyAPIError {
                    self.simplePopup("ERROR", "連携に失敗しました。アカウント情報を再度お確かめください。", "OK")
                }
                
                req.perform {
                    Persistent.user_is_connected_via_facebook = false
                    cell.detailTextLabel?.text = "未接続"
                    cell.detailTextLabel?.textColor = UIColor.blackColor()
                }
            }
        }
        
        if !Persistent.user_is_connected_via_twitter {
            connect()
        }
        else {
            self.simpleConfirmationPopup("Confirmation", "Do you really want to disconnect your account from Facebook?",
                confirmButton: (text: "Disconnect", cb: disconnect),
                cancelButton:  (text: "Cancel", cb: nil))
        }
    
    }
    
    func handleAccountReset(cell: UITableViewCell)
    {
        var iid: String?
        
        let reset = {
            Persistent.resetPersistentDataToInitialState()
            if let iid = iid {
                Persistent.identity_id = iid
            }
            self.ignoreCommonSenseAndGoToInitialController()
        }
        
        
        let alertController = UIAlertController(
            title: "Gocciをやめる",
            message: "完全にGocciをリセットするか、アカウントは保存しておく方法があります",
            preferredStyle: UIAlertControllerStyle.ActionSheet)


        alertController.addAction(UIAlertAction(title: "Reset everything", style: UIAlertActionStyle.Destructive) { action in
            self.simpleConfirmationPopup("Last Chance", "All your data will be deleted",
                confirmButton: (text: "Do it", cb: reset),
                cancelButton:  (text: "Cancel", cb: nil))
        })


        alertController.addAction(UIAlertAction(title: "Reset but keep account", style: UIAlertActionStyle.Destructive) { action in
            iid = Persistent.identity_id
        
            self.simpleConfirmationPopup("Last Chance", "All your data will be deleted, but you can login again",
                confirmButton: (text: "Do it", cb: reset),
                cancelButton:  (text: "Cancel", cb: nil))
        })
        
        alertController.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel) { _ in
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
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
        cell.detailTextLabel?.textColor = UIColor.blackColor()
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.fontWithSize(14)
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        sectionMapping[indexPath.section][indexPath.row].setCell?(cell)
        return cell
    }
    


}






