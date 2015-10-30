//
//  SettingsTableViewController.swift
//  Gocci
//
//  Created by Markus Wanke on 2015/10/26.
//  Copyright © 2015年 Massara. All rights reserved.
//

import UIKit


class SettingsTableViewController: UITableViewController {
    
    let sectionList = ["アカウント", "ソーシャルネットワーク", "お知らせ", "サポート"]
    
    var sectionMapping: [[(setCell:(UITableViewCell->())?, action:(UITableViewCell->())? )]] = []

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        sectionMapping = [
            
            // アカウント ===================================================================
            [
                (
                    {
                        $0.textLabel?.text = "パスワードを設定する"
                        $0.detailTextLabel?.text = Persistent.passwordWasSetByTheUser ? "" : "set an account password"
                        $0.detailTextLabel?.textColor = Persistent.passwordWasSetByTheUser ? UIColor.greenColor() : UIColor.redColor()
                    },
                    {
                        let popup = ConfirmationPopover(from: self, position: $0.frame, widthRatio:90, heightRatio:30)
                        popup.pop()
                    }
                ),
            ],
            // ソーシャルネットワーク =========================================================
            [
                (
                    {
                        let isCon = Persistent.userIsConnectedViaFacebook
                        $0.textLabel?.text = "Facebook"
                        $0.detailTextLabel?.text = isCon ? "connected!" : "not connected :("
                        $0.detailTextLabel?.textColor = isCon ? UIColor.greenColor() : UIColor.redColor()
                    },
                    { cell in
                        if !Persistent.userIsConnectedViaFacebook {
                            Persistent.userIsConnectedViaFacebook = true
                            cell.detailTextLabel?.text = "connected!"
                            cell.detailTextLabel?.textColor = UIColor.greenColor()

//                            self.connectWithFacebook{
//                                cell.detailTextLabel?.text = "connected!"
//                            }
                        }
                        else {
                            let popup = ConfirmationPopover(from: self, position: cell.frame, widthRatio:90, heightRatio:30)
                            popup.confirmationText = "Do you really want to disconnect you account from Facebook?"
                            popup.onConfirm = {
                                // TODO disconnect call
                                Persistent.userIsConnectedViaFacebook = false
                                cell.detailTextLabel?.text = "not connected :("
                                cell.detailTextLabel?.textColor = UIColor.redColor()
                            }
                            popup.pop()
                        }
                    }
                ),
                (
                    {
                        let isCon = Persistent.userIsConnectedViaTwitter
                        $0.textLabel?.text = "Twitter"
                        $0.detailTextLabel?.text = isCon ? "connected!" : "not connected :("
                        $0.detailTextLabel?.textColor = isCon ? UIColor.greenColor() : UIColor.redColor()
                    },
                    { _ in
                        self.connectWithTwitter()
                    }
                ),
                ( { $0.textLabel?.text = "Google+"; return }, nil),
                ( { $0.textLabel?.text = "Line"; return }, nil),
            ],
            // お知らせ =====================================================================
            [
                (
                    {
                        $0.textLabel?.text = "通知を設定する"
                        $0.detailTextLabel?.text = Util.randomUsername()
                    },
                    { _ in
                    }
                )
            ],
            // サポート =====================================================================             
            [
//                (
//                    { $0.textLabel?.text = "アドバイスを送る" },
//                    nil //{ Popup.show(from:self, content: AdvicePopup()) }
//                ),
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
//                (
//                    { $0.textLabel?.text = "バージョン" ; $0.detailTextLabel?.text = "iOS Gocci v" + (Util.getGocciVersionString() ?? "?.?") },
//                    { }
//                ),
            ],
        ]

    }

    func connectWithFacebook(andOnSucc:()->()) {
        SNSUtil.connectWithFacebook(currentViewController: self) { (result) -> Void in
            switch result {
            case .SNS_CONNECTION_SUCCESS:
                Persistent.userIsConnectedViaFacebook = true
                andOnSucc()
                //Util.popup("Facebook連携が完了しました")
            case .SNS_CONNECTION_UNKNOWN_FAILURE:
                Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
            case .SNS_CONNECTION_UN_AUTH:
                Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
            case .SNS_CONNECTION_CANCELED:
                break
            case .SNS_PROVIDER_FAIL:
                Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
            }
        }
    }
    
    func connectWithTwitter() {
        SNSUtil.connectWithTwitter(currentViewController:self) { (result) -> Void in
            switch result {
            case .SNS_CONNECTION_SUCCESS:
                Persistent.userIsConnectedViaTwitter = true
                self.tableView.reloadData()
                Util.popup("Twitter連携が完了しました")
            case .SNS_CONNECTION_UN_AUTH:
                Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
            case .SNS_CONNECTION_UNKNOWN_FAILURE:
                Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
            case .SNS_CONNECTION_CANCELED:
                break
            case .SNS_PROVIDER_FAIL:
                Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionMapping.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section] ?? "fail"
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionMapping[section].count ?? 0
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sectionMapping[indexPath.section][indexPath.row].action?(tableView.cellForRowAtIndexPath(indexPath)!)
        sectionMapping[indexPath.section][indexPath.row].setCell?(tableView.cellForRowAtIndexPath(indexPath)!)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        cell.detailTextLabel?.textColor = UIColor.blueColor()
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.fontWithSize(14)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        //cell.backgroundColor = UIColor.clearColor()

        sectionMapping[indexPath.section][indexPath.row].setCell?(cell)
        return cell
    }
    

}


//class PopupReadyWebView: UIViewController, UIWebViewDelegate {
//    
//    var web: UIWebView!
//    var url: String?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.title = "利用規約"
//        self.contentSizeInPopup = self.view.frame.size.makeScale(widthDiff: -40, heightDiff: -140)
//        
//        web = UIWebView()
//        web.delegate = self
//        web.frame = self.view.frame.makeScale(widthDiff: -40, heightDiff: 0)
//        web.scalesPageToFit = true
//        self.view.addSubview(web)
//        if url != nil {
//            web.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
//        }
//    }
//    
//    func webViewDidStartLoad(webView: UIWebView) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    }
//    
//    func webViewDidFinishLoad(webView: UIWebView) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//    }
//    
//}

class PasswordPopup: UIViewController, UITextFieldDelegate {
    
    let label = UILabel()
    let textField = UITextField()
    let separatorView = UIView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentSizeInPopup = CGSizeMake(300, 100)
        self.landscapeContentSizeInPopup = CGSizeMake(300, 200)
        
        //label.numberOfLines = 0;
        label.text = "パスワードを設定します";
        label.textColor = UIColor(white: 0.2, alpha: 1)
        label.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(label)
        
        separatorView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(separatorView)
        
        textField.delegate = self;
        textField.placeholder = "ここに入力";
        //textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        //textField.leftViewMode = UITextFieldViewModeAlways;
        self.view.addSubview(textField)
    }
    
    override func viewDidLayoutSubviews()
    {   // TODO ugly
        super.viewDidLayoutSubviews()
        textField.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)
        separatorView.frame = CGRectMake(0, self.textField.frame.origin.y - 0.5, self.view.frame.size.width, 0.5)
        label.frame = CGRectMake(20, 10, self.view.frame.size.width - 40, self.view.frame.size.height - 20 - textField.frame.size.height)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.length < 6 {
            label.text = "6文字以上入力してください"
            label.textColor = UIColor.redColor()
        }
        else {
            APIClient.setPassword(textField.text) { (result, code, error) -> Void in
                if code == 200 {
                    Persistent.passwordWasSetByTheUser = true
                    textField.resignFirstResponder()
                    self.popupController?.pushViewController(CompletePopup(), animated: true)
                }
            }
        }

        return false
    }
}




