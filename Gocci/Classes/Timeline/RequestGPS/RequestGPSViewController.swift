//
//  RequestGPSViewController.swift
//  Gocci
//
//  Created by Ma Wa on 28.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation


class RequestGPSViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    weak var delegate: TimelinePageMenuViewController!
    
    var checking: Bool = false
    var stop: Bool = false
    
    
    override func viewDidLoad() {
        locationManager.delegate = self;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stop = false
        //print("appearing...")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stop = true
        //print("hiding...")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
            Util.runOnMainThread() {
                self.delegate.setupPageMenu(1)
            }
        }
    }
    
    
    @IBAction func btnForGPSRequestClicked(sender: AnyObject) {
        
        let initialValue = CLLocationManager.authorizationStatus()
        
        switch initialValue {
            
        case CLAuthorizationStatus.NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case CLAuthorizationStatus.AuthorizedAlways: fallthrough
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            delegate.setupPageMenu(1)
            
        case CLAuthorizationStatus.Denied: fallthrough
        case CLAuthorizationStatus.Restricted:
            self.simplePopup("GPS", "設定画面より位置情報をONにしてください", "設定する") {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        
        if checking {
            return
        }
        checking = true
        
        Util.runInBackground {
            
            var status: CLAuthorizationStatus = initialValue
            while initialValue == status && !self.stop {
                
                // yes ugly, but it does the job soooo well. And catching both events is such a hassle...
                Util.sleep(1)
                print("checking.... \(status.rawValue)")
                
                status = CLLocationManager.authorizationStatus()
                
                if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
                    Util.runOnMainThread() {
                        self.delegate.setupPageMenu(1)
                    }
                }

            }
            self.checking = false
            
        }
        
    }
}



