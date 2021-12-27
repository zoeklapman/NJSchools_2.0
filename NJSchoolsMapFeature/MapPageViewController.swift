//
//  MapPageViewController.swift
//  NJSchoolsMapFeature
//
//  Created by Zoë Klapman on 10/13/21.
//

import UIKit
import MapKit
import CoreLocation

class MapPageViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var schoolMap: MKMapView!
    
    let njSchoolsModel = NJSchoolsModel.sharedInstance
    var selectedAnnotation: SchoolAnnotation?
    
    // array of school annotations
    // have to write the ParkAnnotations calss as a separate file before this
    var schoolAnnotations:[SchoolAnnotation] = []
    
    // constant for your region - 60K meters is ~12mi
    let region = 60000.00
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // our map becomes the delegate
        schoolMap.delegate = self

        // invoke method for locationManager to gte permission to access lcoation when in use
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // invoke methods in our class to center map, add a location, nad all the lcoations from parks model
        centerMapToNJ()
        addMULocation()
        showSchoolsOnMap()
        
        // check for location authorization status
        //      set the desired accuracy
        //      set the class as delegate for location manager
        //      start location tracking
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        // check if ratings changed
        if let thisAnnotation = selectedAnnotation {
            if let thisRating = njSchoolsModel.getSchoolRating(forSchoolId: thisAnnotation.schoolID) {
                if thisRating == 5 {
                    schoolMap.removeAnnotation(thisAnnotation)
                    schoolMap.addAnnotation(thisAnnotation)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // if authorized and tracking, stop when view disappears
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func centerMapToNJ() {
        let centerNJ = CLLocation(latitude: 40.2798587939248, longitude: -74.50477927051948)
        let centerofNJ2D = CLLocationCoordinate2D(latitude: centerNJ.coordinate.latitude, longitude: centerNJ.coordinate.longitude)
        let coordinateRegion = MKCoordinateRegion(center: centerofNJ2D, latitudinalMeters: region, longitudinalMeters: region)
        schoolMap.setRegion(coordinateRegion, animated: true)
    }
    
    func addMULocation() {
        let annotation = MUPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.2798587939248, longitude: -74.00477927051948)
        annotation.title = "MU"
        annotation.subtitle = "Go Hawks!!"
        schoolMap.addAnnotation(annotation)
    }
    
    func showSchoolsOnMap() {
        for school in njSchoolsModel.njSchools {
            let annotation = SchoolAnnotation(latitude: school.geometry.coordinates[1], longitude: school.geometry.coordinates[0], title: school.properties.name, subTitle: school.properties.county, schoolID: school.properties.objectId, schoolType: school.properties.schoolType)
            schoolAnnotations.append(annotation)
        }
            
        // add annotations in bulk
        schoolMap.addAnnotations(schoolAnnotations)
    }
    
    // customize the annotationView so it can be presented on touch of an annotation
    //      a. make sure the annotation is one of the ones we creates
    //      b. for School annotation, setup the custom marker icon - set the annotation to show callout
    //      c. create a UIButton obj, set its background image and set it as left accessory
    //      d. do the same as step c for MU annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard (annotation is SchoolAnnotation || annotation is MUPointAnnotation) else {
            return nil
        }
        
        var annotationView = MKMarkerAnnotationView()
        let identifier = "School"
        
        if annotation is SchoolAnnotation {
            if let dequeuedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                annotationView = dequeuedAnnotation
            } else {
                let thisAnnotation = annotation as! SchoolAnnotation
                // if rating is 5 stars, make the glyphImage an emoji star
                if let thisRating = njSchoolsModel.getSchoolRating(forSchoolId: thisAnnotation.schoolID) {
                    if thisRating == 5 {
                        annotationView.glyphImage = UIImage(systemName: "star")
                    } else {
                        annotationView.glyphImage = UIImage(systemName: "building.columns")
                    }
                } else {
                    annotationView.glyphImage = UIImage(systemName: "building.columns")
                }
                
                annotationView.glyphTintColor = .white
                annotationView.canShowCallout = true
                
                let schoolImageView = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 50.0)))
                if let _ = thisAnnotation.schoolType {
                    switch thisAnnotation.schoolType! {
                    case "CHARTER":
                        schoolImageView.setBackgroundImage(UIImage(named: "charter"), for: UIControl.State())
                    case "PRIVATE":
                        schoolImageView.setBackgroundImage(UIImage(named: "private"), for: UIControl.State())
                    case "PUBLIC":
                        schoolImageView.setBackgroundImage(UIImage(named: "public"), for: UIControl.State())
                        
                    default:
                        schoolImageView.setBackgroundImage(UIImage(systemName: "questionmark.square.dashed"), for: UIControl.State())
                    }
                } else {
                    schoolImageView.setBackgroundImage(UIImage(systemName: "questionmark.square.dashed"), for: UIControl.State())
                }
                annotationView.leftCalloutAccessoryView = schoolImageView
            }
            
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = UIColor.blue
            annotationView.image = UIImage(systemName: "building.columns.fill")
            annotationView.canShowCallout = true
            
            let muImageView = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 50.0)))
            muImageView.setBackgroundImage(UIImage(named: "mu"), for: UIControl.State())
            annotationView.leftCalloutAccessoryView = muImageView
            
            return annotationView
        }
        
    }
    
    // when user location changes, this method gets called
    // first item in the array is the current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        print(newLocation)
    }
    
    // after implementing the other MVC on selection of map annoationView accessory, we an now handle those UIButton control changes to perform segues
    
    // check for accessory is one we defined
    // based on whcih annotation type, perform the segue to school detail
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.leftCalloutAccessoryView == control {
        let thisAnnotation = view.annotation
            if thisAnnotation is SchoolAnnotation {
                selectedAnnotation = thisAnnotation as? SchoolAnnotation
                mapView.deselectAnnotation(view.annotation, animated: false)
                performSegue(withIdentifier: "schoolSegue", sender: self)
            } else {
                performSegue(withIdentifier: "muSegue", sender: self)
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if selectedAnnotation != nil {
            if(segue.identifier == "schoolSegue") {
                let dvc = segue.destination as! SchoolDetailViewController
                dvc.editedSchool = njSchoolsModel.getSchoolInfo(forSchoolId: selectedAnnotation!.schoolID)
            }
            /*
            if(segue.identifier == "muSegue") {
                let dvc = segue.destination as! UIViewController
            }*/
        }
    }

}
