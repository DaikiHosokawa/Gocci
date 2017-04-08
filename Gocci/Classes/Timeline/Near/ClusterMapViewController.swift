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


// Rename this to RealmRestaurant
class HeatMapRestaurant: Object {
    dynamic var id = "none"
    dynamic var name = "none"
    dynamic var lat: Double = 0.0
    dynamic var lon: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func create(fromPayload pl: API4.get.heatmap.Payload.Rests) -> HeatMapRestaurant {
        let res = self.init()
        res.id = pl.rest_id
        res.name = pl.restname
        res.lat = pl.lat
        res.lon = pl.lon
        return res
    }
}



class ClusterMapViewController: UIViewController {
    
    //@IBOutlet var mapView: RealmMapView!
    
    @IBOutlet weak var mapView: ABFRealmMapView!
    
    weak var delegate: TimelinePageMenuViewController!
    
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // copy fake data
//        let rests = NSBundle.mainBundle().pathForResource("rest", ofType: "realm")!
//        let target = NSFileManager.documentsDirectory() + "/default.realm"
//        NSFileManager.cp(rests.asLocalFileURL(), target: target.asLocalFileURL())
        
        self.mapView.delegate = self
        
        mapView.entityName = "HeatMapRestaurant"
        mapView.latitudeKeyPath = "lat"
        mapView.longitudeKeyPath = "lon"
        mapView.titleKeyPath = "name"
        mapView.subtitleKeyPath = "id"
        
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        
        mapView.fetchResultsController.clusterTitleFormatString = "$OBJECTSCOUNT"
        
        mapView.showsUserLocation = true
    }
    
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let req = API4.get.heatmap()
        
        req.perform { payload in
            let realm = try! Realm()
            
            try! realm.write {
                
                for rest in payload.rests {
                    let tmp = HeatMapRestaurant.create(fromPayload: rest)
                    realm.add(tmp, update: true)
                }
            }
        }
        
        

//        req.parameters.user_id = Persistent.user_id
//
//        req.perform { payload in
//            
//            Util.sleep(4)
//            
//            let realm = try! Realm()
//            try! realm.write {
//                
//                realm.deleteAll()
//                
//                for post in payload.posts {
//                    let tmp = UserPost(usersPostPayload: post)
//                    realm.add(tmp, update: true)
//                }
//            }
//            
//            
//            let coordArr = realm.objects(UserPost).map { rest in CLLocationCoordinate2D(latitude: rest.lat, longitude: rest.lon) }
//            
//            self.mapView.centerMapViewingRegionAccordingTo(coordArr)
//            self.mapView.refreshMapView()
//        }
        
    }
    
    func refresh() {
//        let realm = try! Realm()
//        let coordArr = realm.objects(UserPost).map { rest in CLLocationCoordinate2D(latitude: rest.lat, longitude: rest.lon) }
//        mapView.centerMapViewingRegionAccordingTo(coordArr)
        self.mapView.refreshMapView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationClient.sharedClient().requestLocationWithCompletion { (location, error) -> Void in
            
            if error != nil {
                print("LocationClient failed \(error)")
                return
            }
            
            location.coordinate.latitude
            
            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let span = MKCoordinateSpanMake(0.2, 0.2)
            
            self.mapView.setRegion(MKCoordinateRegionMake(center, span), animated: true)
            
            //self.mapView.refreshMapView()
        }
    }
    
    

    func goBackToTimeLineAndFocusOnPosition(position: CLLocationCoordinate2D) {
        Lo.green("CLUSTER: Selected position: \(position)")
        Util.reverseLookUpPlaceNameFor(location: position) { (placeName) -> () in
            self.delegate.handleUserChosenGPSPosition(position, label: placeName ?? "地位")
            Lo.green("CLUSTER: Selected place: \(placeName ?? "Nothing found for that cluster :(")")
            
        }
    }
    
}

extension ClusterMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let view = view as? ClusterAnnotationView {
            print("cluster with \(view.count) rests clicked")
            print("Annotation: \(view.annotation)")
            
            if let annotation = view.annotation as? ABFAnnotation {
                
                var latCenter = 0.0
                var longCenter = 0.0
                var count = 0
                
                for safeObject in annotation.safeObjects {
                    if let rest = RBQSafeRealmObject.objectfromSafeObject(safeObject) as? HeatMapRestaurant {
//                        print("Rest ID: " + rest.id)
//                        print("Rest Na: " + rest.name)
                        latCenter  += rest.lat
                        longCenter += rest.lon
                        count += 1
                    }
                }
                
                if count == 0 {
                    return
                }
                
                latCenter /= Double(count)
                longCenter /= Double(count)
                
                print("Clicked cluster center position: LAT: \(latCenter)  /  LONG: \(longCenter)")
                
                
                goBackToTimeLineAndFocusOnPosition(CLLocationCoordinate2D(latitude: latCenter, longitude: longCenter))
                
                backButtonClicked(0)
            }
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




/*
func rnd() -> Double {
let tmp = Double(arc4random()) / Double(UINT32_MAX)
return (tmp - 0.5) / 3.0
}

func shiftEverythingAlittleBit(realm: Realm) {

let rests = realm.objects(UserPost)


try! realm.write {

for rest in rests {
let p = UserPost()
p.lat = rest.lat + rnd()
p.lon = rest.lon + rnd()
p.post_id = "\(arc4random())"
realm.add(p, update:  true)
}
}
}
*/
