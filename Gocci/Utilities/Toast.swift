//
//  Toast.swift
//  Gocci
//
//  Created by ワンケ マークス on 20.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

class Toast {
    
    enum 形 {
        case 成功っぽい
        case 失敗っぽい
        case 情報っぽい
    }
    
    class func 失敗(タイトル: String, _ メッセージ: String, _ 持続期: CGFloat = 4.0) {
        本番(タイトル: タイトル, メッセージ: メッセージ, 持続期: 持続期, 形: 形.失敗っぽい)
    }
    class func 成功(タイトル: String, _ メッセージ: String, _ 持続期: CGFloat = 4.0) {
        本番(タイトル: タイトル, メッセージ: メッセージ, 持続期: 持続期, 形: 形.成功っぽい)
    }
    class func 情報(タイトル: String, _ メッセージ: String, _ 持続期: CGFloat = 4.0) {
        本番(タイトル: タイトル, メッセージ: メッセージ, 持続期: 持続期, 形: 形.情報っぽい)
    }
    
    private class func 本番(タイトル タイトル: String, メッセージ:String, 持続期: CGFloat, 形: Toast.形) {
        var 何の = TWMessageBarMessageType.Success
        switch(形) {
            case .成功っぽい:
                何の = TWMessageBarMessageType.Success
            case .失敗っぽい:
                何の = TWMessageBarMessageType.Error
            case .情報っぽい:
                何の = TWMessageBarMessageType.Info
        }
        
        TWMessageBarManager.sharedInstance().showMessageWithTitle(タイトル, description: メッセージ, type: 何の, duration: 持続期)
    }
}