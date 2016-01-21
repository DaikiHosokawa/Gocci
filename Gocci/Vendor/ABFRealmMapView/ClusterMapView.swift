//
//  ClusterMapView.swift
//  Gocci
//
//  Created by Ma Wa on 20.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation
import RealmSwift



class ClusterMapView: MKMapView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var realm: Realm!
    
    var realmConfiguration: RLMRealmConfiguration!
    
    /**
    *  The internal controller that fetches the Realm objects
    *
    *  @see ABFLocationFetchedResultsController clusterTitleFormatString to localize the subtitle string
    */
    let fetchResultsController: ABFLocationFetchedResultsController = ABFLocationFetchedResultsController()
    
    /**
    *  The Realm object's name being fetched for the map view
    */
    var entityName: String!
    
    /**
    *  The key path on fetched Realm objects for the latitude value
    */
    var latitudeKeyPath: String!
    
    /**
    *  The key path on fetched Realm objects for the longitude value
    */
    var longitudeKeyPath: String!
    
    /**
    *  The key path on fetched Realm objects for the title of the annotation view
    */
    var titleKeyPath: String!
    
    /**
    *  The key path on fetched Realm objects for the subtitle of the annotation view
    */
    var subtitleKeyPath: String!
    
    /**
    *  Designates if the map view will cluster the annotations
    *
    *  Default is YES
    */
    var clusterAnnotations: Bool = true
    
    /**
    *  Designates if the map view automatically refreshes when the map moves
    *
    *  Default is YES
    */
    var autoRefresh: Bool = true
    
    /**
    *  Designates if the map view will zoom to a region that contains all points
    *  on the first refresh of the map annotations (presumably on viewWillAppear)
    *
    *  Default is YES
    */
    var zoomOnFirstRefresh: Bool = true
    
    /**
    *  Max zoom level of the map view to perform clustering on.
    *
    *  ABFZoomLevel is inherited from MapKit's Google days:
    *  0 is the entire 2D Earth
    *  20 is max zoom
    *
    *  Default is 20, which means clustering will occur at every zoom level if clusterAnnotations is YES
    */
    var maxZoomLevelForClustering: ABFZoomLevel = 20
    
    /**
    *  Creates a map view that automatically handles fetching Realm objects and displaying annotations
    *
    *  @param entityName       the class name for the Realm objects to fetch
    *  @param realm            the Realm in which the fetched Realm objects exists
    *  @param latitudeKeyPath  the key path on fetched Realm objects for the latitude value
    *  @param longitudeKeyPath the key path on fetched Realm objects for the longitude value
    *  @param titleKeyPath     the key path on fetched Realm objects for the title of the annotation view
    *  @param subtitleKeyPath  the key path on fetched Realm objects for the subtitle of the annotation view
    *
    *  @return instance of ABFRealmMapView
    */
//    - (nonnull instancetype)initWithEntityName:(nonnull NSString *)entityName
//    inRealm:(nonnull RLMRealm *)realm
//    latitudeKeyPath:(nonnull NSString *)latitudeKeyPath
//    longitudeKeyPath:(nonnull NSString *)longitudeKeyPath
//    titleKeypath:(nonnull NSString *)titleKeyPath
//    subtitleKeyPath:(nonnull NSString *)subtitleKeyPath;
    
    /**
    *  Performs a fresh fetch for Realm objects based on the current visible map rect
    *
    *  @see autoRefresh
    */
    func refreshMapView() {
        
    }
    
    let ANNOTATION_VIEW_REUSE_ID = "ABFAnnotationViewReuseId"
    
    
//    override func viewForAnnotation(annotation: MKAnnotation) -> MKAnnotationView? {
//        // normally this is a delegate calling method. so this isnt the fine engish way until we check the delegate...
//        
//        if let fetchedAnnotation = annotation as? ABFAnnotation {
//            
//            if let annotationView = self.dequeueReusableAnnotationViewWithIdentifier(ANNOTATION_VIEW_REUSE_ID) as? ABFClusterAnnotationView {
//                annotationView.count = fetchedAnnotation.safeObjects.count
//                annotationView.annotation = fetchedAnnotation
//                
//                return annotationView;
//            }
//            
//            let annotationViewNew = ABFClusterAnnotationView(annotation: fetchedAnnotation, reuseIdentifier: ANNOTATION_VIEW_REUSE_ID)
//            annotationViewNew.canShowCallout = true
//            annotationViewNew.count = fetchedAnnotation.safeObjects.count
//            annotationViewNew.annotation = fetchedAnnotation
//            return annotationViewNew
//        }
//        return nil
//    }
//    
//    
//    override func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//    }
//    
//    // mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
//    // The delegate can implement this method to animate the adding of the annotations views.
//    // Use the current positions of the annotation views as the destinations of the animation.
//    optional public func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView])
//    
//    
//    
    
    
    
    
    
    
    
    
}
