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
        
        // copy fake data
        let rests = NSBundle.mainBundle().pathForResource("rest", ofType: "realm")!
        let target = NSFileManager.documentsDirectory() + "/default.realm"
        NSFileManager.cp(rests.asLocalFileURL(), target: target.asLocalFileURL())
        
        
        
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
    
}

extension HeatMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let view = view as? ABFClusterAnnotationView {
            print("cluster with \(view.count) rests clicked")
        }
        
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

