//
//  HeatMapViewController.swift
//  Gocci
//
//  Created by Ma Wa on 13.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

class HeatMapViewController: UIViewController {
    
    //@IBOutlet var mapView: RealmMapView!
    
    @IBOutlet weak var mapView: ABFRealmMapView!
    
    override func viewDidLoad() {
        
        Lo.error("#############################")
        super.viewDidLoad()
        
        /**
         *   Set the Realm path to be the Restaurant Realm path
         */
        
////        config.path = ABFRestaurantScoresPath()
//         let docpath = NSFileManager.documentsDirectory() + "/rest2.realm"
//        
////        self.mapView.realmConfiguration = Realm.Configuration.defaultConfiguration
//        let rests = NSBundle.mainBundle().pathForResource("rest", ofType: "realm")!
//        
//        if !NSFileManager.fileExistsAtPath(rests) {
//            fatalError()
//        }
//        
//        let _ = try? NSFileManager.rm(NSURL.fileURLWithPath(docpath))
//        try! NSFileManager.defaultManager().copyItemAtPath(rests, toPath: docpath)
        

        mapView.realmConfiguration = RLMRealmConfiguration.defaultConfiguration()//Realm.Configuration.defaultConfiguration
//        mapView.realmConfiguration?.path =  docpath
        self.mapView.delegate = self
        
        mapView.entityName = "HeatMapRestaurant"
        mapView.latitudeKeyPath = "lat"
        mapView.longitudeKeyPath = "lon"
        mapView.titleKeyPath = "name"
        mapView.subtitleKeyPath = "name"
        
        mapView.fetchResultsController.clusterTitleFormatString = "$OBJECTSCOUNT restaurants in this area"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mapView.refreshMapView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HeatMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        print("clicked")
//        if let safeObjects = ABFClusterAnnotationView.safeObjectsForClusterAnnotationView(view) {
//            
//            if let firstObject = safeObjects.first?.toObject(ABFRestaurantObject) {
//                print("First Object: \(firstObject.name)")
//            }
//            
//            print("Count: \(safeObjects.count)")
//        }
    }
}

