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
                        $0.detailTextLabel?.textColor = Persistent.password_was_set_by_the_user ? UIColor.good : UIColor.bad
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
                        $0.detailTextLabel?.textColor = isCon ? UIColor.good : UIColor.bad
                    },
                    handleFacebook
                ),
                (
                    {
                        let isCon = Persistent.user_is_connected_via_twitter
                        $0.textLabel?.text = "Twitter"
                        $0.detailTextLabel?.text = isCon ? "接続済み" : "未接続"
                        $0.detailTextLabel?.textColor = isCon ? UIColor.good : UIColor.bad
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
                        $0.detailTextLabel?.text = wants ? "受信" : "未許可"
                        $0.detailTextLabel?.textColor = wants ? UIColor.good : UIColor.bad
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
                        let popup = FeedbackPopup(from: self, title: "アドバイスを送る", widthRatio: 92, heightRatio: 50)
   
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
                    {
                    #if TEST_BUILD
                        let versionStr = "TEST BUILD  " + Util.getGocciVersionString() ?? "?.?"
                    #else
                        let versionStr = Util.getGocciVersionString() ?? "?.?"
                    #endif
                        $0.textLabel?.text = "バージョン"
                        $0.detailTextLabel?.text = versionStr
                        $0.detailTextLabel?.textColor = UIColor.neutral },
                    nil
                ),
                (
                    { $0.textLabel?.text = "Gocciを初期状態にリセットする" ; $0.textLabel?.textColor = UIColor.blackColor() },
                    handleAccountReset
                ),
            ],
        ]

    }
    
    
    // TODO TARANSLATION
    func handlePushNotification(cell: UITableViewCell)
    {
        // don't think there is something better we can do here
        cell.detailTextLabel?.text = ""
        
        
        let disconnect = {
            
            // we don't really care if this worked or not
            API3.unset.device().perform {
                Persistent.registerd_device_token = nil
                cell.detailTextLabel?.text = "未許可"
                cell.detailTextLabel?.textColor = UIColor.bad
            }

        }
        
        let connect = {
            if !Permission.userHasGrantedPushNotificationPermission() {
                self.simplePopup("Permission not granted", "Please click again to visit the settings to grant the push messages permission", "OK")
            }
            
            // this will reschedule an permission check. The popup will never be shown here
            Permission.theHolyPopup { wants in
                // We pretend the task has succeeded for now...
                cell.detailTextLabel?.text = wants ? "受信" : "未許可"
                cell.detailTextLabel?.textColor = wants ? UIColor.good : UIColor.bad
            }
        }
        
        
        if !Permission.userHasGrantedPushNotificationPermission() {

            
            Persistent.do_not_ask_again_for_push_messages = true
            
            if Persistent.push_notifications_popup_has_been_shown {
                // Show settings page
                Permission.showTheHolyPopupForPushNotificationsOrTheSettingsScreen()
                
                // We have no idea what the permission status here is. Checking it here makes no sense
                // since the user will take some time set the settings and there is no return event.
                // because of that a neutral popup is needed. Asking is he wants or not.
                
                // User should see the popup when he returnn, not while the settings screen opens
                Util.sleep(1)
                
                self.simpleConfirmationPopup("確認", "Do you want to recieve push notifications about Likes and Messages to your videos?",
                    confirmButton: (text: "Yes, send me push messages", cb: connect),
                    cancelButton:  (text: "No, thank you", cb: disconnect))
            }
            else {
                // Show the holy popup
                Permission.theHolyPopup { wants in
                    // We pretend the task has succeeded for now...
                    cell.detailTextLabel?.text = wants ? "受信" : "未許可"
                    cell.detailTextLabel?.textColor = wants ? UIColor.good : UIColor.bad
                }
            }
        }
        else if Persistent.registerd_device_token == nil {
            // The server dows not send push messages to this device
            self.simpleConfirmationPopup("確認", "Currently you are not recieving Likes and Messages notifications",
                confirmButton: (text: "Yes, please send me notifications again", cb: connect),
                cancelButton:  (text: "キャンセル", cb: nil))
        }
        else if Persistent.registerd_device_token != nil {
            // The server does send push messages to this device
            self.simpleConfirmationPopup("確認", "You will recieve no further Likes and Messages notifications.",
                confirmButton: (text: "Yes, stop sending me messages", cb: disconnect),
                cancelButton:  (text: "キャンセル", cb: nil))
        }
        
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
            textField.placeholder = "確認のため、もう一度入力してください"
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
                    cell.detailTextLabel?.text = "設定済み"
                    cell.detailTextLabel?.textColor = UIColor.good
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
                    cell.detailTextLabel?.textColor = UIColor.good
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
                    cell.detailTextLabel?.textColor = UIColor.good
                }
            }
        }
        
        if !Persistent.user_is_connected_via_twitter {
            connect()
        }
        else {
            self.simpleConfirmationPopup("確認", "Twitter連携を解除してもよろしいですか？",
                confirmButton: (text: "解除", cb: disconnect),
                cancelButton:  (text: "キャンセル", cb: nil))
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
                    cell.detailTextLabel?.textColor = UIColor.good
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
                    cell.detailTextLabel?.textColor = UIColor.bad
                }
            }
        }
        
        if !Persistent.user_is_connected_via_twitter {
            connect()
        }
        else {
            self.simpleConfirmationPopup("確認", "Facebook連携を解除してもよろしいですか？",
                confirmButton: (text: "解除", cb: disconnect),
                cancelButton:  (text: "キャンセル", cb: nil))
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


        alertController.addAction(UIAlertAction(title: "完全にリセット", style: UIAlertActionStyle.Destructive) { action in
            self.simpleConfirmationPopup("最終確認", "すべてのデータが削除されます",
                confirmButton: (text: "削除", cb: reset), // TODO MARK AS DELETE BUTTON, not DEFAULT style
                cancelButton:  (text: "キャンセル", cb: nil))
        })


        alertController.addAction(UIAlertAction(title: "アカウントは保持", style: UIAlertActionStyle.Destructive) { action in
            iid = Persistent.identity_id
        
            self.simpleConfirmationPopup("最終確認", "すべてのデータが削除されますが、またログインすることができます",
                confirmButton: (text: "削除", cb: reset),
                cancelButton:  (text: "キャンセル", cb: nil))
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






